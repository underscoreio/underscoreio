---
layout:     post
title:      Beginner pitfalls when using FS2
author:     Pere Villega
date:       '2018-03-04 13:50:00'
---

The new release of [fs2][3] (v0.10) has changed its API a lot. [Http4s][1] v0.18 has adopted this newest version, as well as [cats 1.0][2]. The direct consequence of these changes is that a user of Http4s must now become more familiar with fs2 to avoid some unexpected behaviour, more so if you try to do fancy stuff with WebSockets. In this blog post we will explore some pitfalls related to the use of [fs2][3] which I, as someone not very familiar with fs2 at the time, spent too much time figuring out.

<!-- more -->
Without further ado, let's talk about some 'gotchas' you may find when working with [fs2][3].

# Flatmap all the things...except Streams

One of the first *surprises* one finds when working with streams is the behaviour of `flatMap`. In most of our code we are used to call `flatMap` operations a lot, usually inside `for-comprehensions`. But with streams, you have to be slightly more careful on the consequences of doing so. 

Let's start with the following code:
 
```scala
import cats.effect.IO
import fs2._
import scala.concurrent.ExecutionContext.Implicits.global

object SampleCode extends App {

  val s  = Stream(1, 2, 3).covary[IO]
  val s1 = s.flatMap(i ⇒ Stream.emit(i * 2))
  val s2 = s.flatMap(i ⇒ Stream.emit(i + 2))

  val res1 = s1.compile.toList.unsafeRunSync()
  println(res1) // List(2, 4, 6)

  val res2 = s2.compile.toList.unsafeRunSync()
  println(res2) // List(3, 4, 5)
}
```

Streams are immutable, as usual in functional programming. Which means that `s1` and `s2` in the example above will not modify the original stream `s` in any way, thus the expected results for both `res1` and `res2`. 

This seems pretty clear, but as you add more and more functions to properly partition your logic, it is easy to call `flatMap` at the wrong moment. *If you see data is not flowing through, this is most likely the issue*. We will see another example in the next section.

# Working with external data sources

Use of queues is one of the [recommended ways][7] to integrate data from the external data sources onto your streams. In particular the documentation example shows the following:

```scala
import fs2._
import fs2.async
import scala.concurrent.ExecutionContext
import cats.effect.{ Effect, IO }

type Row = List[String]

trait CSVHandle {
  def withRows(cb: Either[Throwable,Row] => Unit): Unit
}

def rows[F[_]](h: CSVHandle)(implicit F: Effect[F], ec: ExecutionContext): Stream[F,Row] =
  for {
    q <- Stream.eval(async.unboundedQueue[F,Either[Throwable,Row]])
    _ <-  Stream.eval { F.delay(h.withRows(e => async.unsafeRunAsync(q.enqueue1(e))(_ => IO.unit))) }
    row <- q.dequeue.rethrow
  } yield row
``` 

where we do a callback to `withRows` to enqueue data, and we receive a stream from dequeuing this data. Let's build a self-contained snippet that does something similar:

```scala
import cats.effect.{ Effect, IO }
import fs2._
import fs2.async.mutable.Queue
import scala.concurrent.ExecutionContext.Implicits.global
import scala.concurrent.duration._

object SampleCode extends App {

  val streamData: Stream[IO, String] = Scheduler[IO](corePoolSize = 1).flatMap { scheduler =>
    scheduler.awakeEvery[IO](1.second).map(_ => (System.currentTimeMillis() % 10000).toString)
  }

  def enqueueData[F[_]](q: Queue[F, String])(implicit F: Effect[F]) =
    Stream.eval(
      F.delay(
        streamData
          .map(s => {
            async.unsafeRunAsync(q.enqueue1(s))(_ => IO.unit)
          })
          .compile
          .drain
          .unsafeToFuture()
      )
    )

  def dequeueData[F[_]](q: Queue[F, String])(implicit F: Effect[F]) = q.dequeue.take(4)

  def withQueue[F[_]](implicit F: Effect[F]): Stream[F, String] = {
    val queue: Stream[F, Queue[F, String]] = Stream.eval(async.circularBuffer[F, String](5))

    val enqueueStream = queue.flatMap { q =>
      enqueueData(q)
    }

    val dequeueStream = queue.flatMap { q ⇒
      dequeueData(q)
    }

    dequeueStream.concurrently(enqueueStream)
  }

  val resultQueue = withQueue[IO].compile.toVector.unsafeRunSync()
  println(s"Queue >> $resultQueue") // hangs

}

```
In this code we generate an infinite stream of String via an `Scheduler` (1 `String` per second) and we queue them, so another process can read the values from the queue itself.

If you weren't warned by the fact we discussed `flatMap` in the previous section, this seems like a reasonable piece of code. Inside `withQueue` we use `flatMap` to call the support functions that queue and dequeue data and then we run both streams concurrently. 

This doesn't work, and running the example will hang the process.

The reason is that `queue`, which is a `Stream` of `Queue[F, String]`, creates new streams on each `flatMap`. This means `enqueueStream` and `dequeueStream` are using different `queue` inside the streams, and they don't have visibility on each other's data. I found it specially easy to miss this when working with queues and the provided `Streams`


To get the code working, replace `withQueue` with:

```scala
  def withQueue[F[_]](implicit F: Effect[F]): Stream[F, String] = {
    val queue: Stream[F, Queue[F, String]] = Stream.eval(async.circularBuffer[F, String](5))

    queue.flatMap { q =>
      val enqueueStream = enqueueData(q)

      val dequeueStream = dequeueData(q)

      dequeueStream.concurrently(enqueueStream)
    }
  }
```

In this new snippet we call the support functions inside `flatMap` and return as result of the operation the concatenation of both streams. Now both operations share the same queue and the result is printed as expected.

# Topics

Topics are a very useful structure which is, unfortunately, barely documented. Topics are the implementation of the [publish-subscribe][6] pattern, but they come with the standard functional programming twist: no side effects allowed.

What this means in practice is that creating a topic is simple:

```scala
import cats.effect.{ Effect, IO }
import fs2._
import scala.concurrent.ExecutionContext.Implicits.global

object SampleCode extends App {

  def withTopic[F[_]](implicit F: Effect[F]): Stream[F, String] = {
    val topicStream = Stream.eval(fs2.async.topic[F, String]("Topic start"))

    topicStream.flatMap { topic =>
      val publisher = Stream.emit("1").repeat.covary[F].to(topic.publish)

      val subscriber = topic.subscribe(10).take(4)

      subscriber.concurrently(publisher)
    }

  }

  val resultTopic = withTopic[IO].compile.toVector.unsafeRunSync()
  println(s"Topic >> $resultTopic") // prints Topic >> Vector(Topic start, 1, 1, 1)

}
```
but, as an `Stream`, each `flatMap` will create a new topic with its own subscribers and publishers, and data won't be shared across.

The solution is simple: store your `Topic` in a structure you can share across your clients, for example a `Map`:

```scala
val topicMap: mutable.Map[String, Topic[F, String]] = mutable.Map.empty
```

but there are some nuances to it. Let's see some working code first:

```scala
import fs2._
import cats.effect._
import fs2.async.mutable.Topic

import scala.collection.mutable
import scala.concurrent.ExecutionContext.Implicits.global

object SampleCode extends App {

  val topicMap: mutable.Map[String, Topic[IO, String]] = mutable.Map.empty

  //we create and store topic before we call publishers and subscribers
  val topicStream = Stream
    .eval(fs2.async.topic[IO, String]("Topic start"))
    .map(topic ⇒ { topicMap += ("k" -> topic); topic })
    .compile
    .drain
    .unsafeRunSync()

  def addPublisher(id: String): Stream[IO, Unit] = {
    val topic = topicMap("k")
    Stream.emit(id).covary[IO].repeat.to(topic.publish)
  }

  def addSubscriber: Stream[IO, String] = {
    val topic = topicMap("k")

    topic
      .subscribe(10)
      .take(4)
  }

  val publisher     = addPublisher("1")
  val subscriber    = addSubscriber
  val joinedStreams = subscriber.concurrently(publisher)

  val output = joinedStreams.compile.toVector.unsafeRunSync()
  println(s"Topic >> $output") // prints Topic >> Vector(1, 1, 1, 1)

}
```
If you read the implementation of `topicStream` you will notice that we store the topic in the map as soon as we create it, in a `map` operation with a side effect (sorry). The reason we do this here and not, for example, when calling `addPublisher` is concurrency. If you create the topic inside the `addPublisher` method, it may not be in the map when `addSubscriber` tries to read from it. Of course not always is possible to create the topics in advance, but this means your `subscribers` must be ready to wait or retry until a topic is available.

Another detail on `topicStream` which can be easy to miss is the fact that we `compile` and `run` the stream. Without this step, the topic won't be created! Just calling `fs2.async.topic[IO, String]("Topic start")` is not enough, and as we want the topic stored in the map before we add publishers and subscribers, we must run it now.

The last relevant piece of code is `joinedStreams`. Both `addPublisher` and `addSubscriber` create streams using the stored topic. We must run these streams concurrently, otherwise data won't flow correctly. You can verify this yourself by replacing these lines of code with:

```scala
  val publisher  = addPublisher("1").compile.drain.runAsync(_ ⇒ IO.unit)
  val subscriber = addSubscriber.compile.toVector.runAsync(e ⇒ IO(println(s"Topic >> $e")))
```

Despite running asynchronously and having an infinite stream as publisher, the process will hang in the subscriber, waiting for data.

# Conclusions

We have reviewed some possible pitfalls you may encounter when you start working with [fs2][3]. We have provided sample code to demonstrate the problematic code snippets as well as the solution for these issues. Hopefully this will help you with the transition to [http4s][1] v0.18, specially when working with WebSockets!

[1]: http://http4s.org
[2]: https://typelevel.org/cats/
[3]: https://functional-streams-for-scala.github.io/fs2/
[4]: https://github.com/typelevel/cats-effect
[5]: https://blog.scalac.io/exploring-tagless-final.html
[6]: https://en.wikipedia.org/wiki/Publish–subscribe_pattern
[7]: https://functional-streams-for-scala.github.io/fs2/guide.html#talking-to-the-external-world
