---
layout: post
title: "Uniting Church and State"
author: Noel Welsh
---

In this blog post I want to describe Church encoding, which give us a tool 

performance characteristics

unify OO and FP techniques.

systematic program development.

<!-- break -->

For a recent project Maana blah blah.

## Reactive Streams

Let's start by implementing a reactive stream system using classic functional programming techniques.
This will 

 - show we can develop software in a systematic way; and
 - give us baseline performance metrics.
 
### API
 
The first step is to write down the API we want to implement.
This is almost the only point in the entire process that we have to do much deep thought as it's here that we define the capabilities of the system.
Luckily, in this case there are many existing systems from which we can take inspiration, and this system is only for demonstration purposes so it doesn't have to be very featureful.
The following API will do.
I find it best to write down the API in an abstract form in terms of the functions we'll support.
This helps separate the API from the implementation.

```scala
fromIterator: Iterator[A] => Stream[A]
map[A,B]: Stream[A] × (A => B) => Stream[B]
zip[A,B]: Stream[A] × Stream[B] => Stream[(A,B)]
foldLeft[A,B]: Stream[A] × B × ((B, A) => B) => B
```

This API is fairly straightforward.
We have a type `Stream[A]` representing a stream of values of type `A`.
We support construction (`fromIterator`) and composition (`map`, and `zip`) and evaluation (`foldLeft`).
For convenience we've chosen to have input data come from an `Iterator`.
In a real system we would have some kind of asynchronous boundary (perhaps a concurrent queue) to interface with the outside world.

Converting this API to Scala is entirely mechanical. 
If the first parameter to one of the functions above is `Stream`, that function becomes a method on the `Stream` type. 
Otherwise it becomes a method on the companion object.
The result is

```scala
sealed trait Stream[A] {
  def zip[B](that: Stream[B]): Stream[(A,B)] = ???

  def map[B](f: A => B): Stream[B] = ???

  def foldLeft[B](zero: B)(f: (A, B) => B): B = ???
}
object Stream {
  def fromIterator[A](source: Iterator[A]): Stream[A] = ???
}
```

At this point we can compile the code and check we haven't made any logic errors, a process sometimes known as type driven development.

### Reification

Our next step is to implement all the stubbed out methods.
This process is again almost entirely mechanical.
We can use a technique known as [reification][reification] to implement all the methods except for `foldLeft`.
The idea is simply to turn the methods into data.
In simpler words, each method will simply return a class that represents the method but performs no actions.

```scala
sealed trait Stream[A] {
  import Stream._

  def zip[B](that: Stream[B]): Stream[(A,B)] =
    Zip(this, that)

  def map[B](f: A => B): Stream[B] =
    Map(this, f)

  def foldLeft[B](zero: B)(f: (A, B) => B): B = ???
}
object Stream {
  def fromIterator[A](source: Iterator[A]): Stream[A] =
    FromIterator(source)

  // Stream algebraic data type

  final case class Zip[A,B](left: Stream[A], right: Stream[B]) extends Stream[(A,B)]
  final case class Map[A,B](source: Stream[A], f: A => B) extends Stream[B]
  final case class FromIterator[A](source: Iterator[A]) extends Stream[A]
}
```

I want to emphasise that this process is entirely formulaic.
We could program a computer to do this job for us, if we wished.

### Interpreter

Now we need to implement `foldLeft`.
This method has to actually do something---run the `Stream`---so we have to apply a modicum of thought here.
Before we need to engage our brain we can recognise that `Stream` is an algebraic data type (in Scala this means a family of types containing a `sealed trait` and `case classes` extending that trait) and thus we can use structural recursion to transform it (in Scala this usually means pattern matching, though we can also use polymorphism).
This gets us the outline of an implementation.

```scala
sealed trait Stream[A] {
  import Stream._

  def zip[B](that: Stream[B]): Stream[(A,B)] =
    Zip(this, that)

  def map[B](f: A => B): Stream[B] =
    Map(this, f)

  def foldLeft[B](zero: B)(f: (A, B) => B): B = 
    this match {
      case FromIterator(source) => ???
      case Map(source, f) => ???
      case Zip(left, right) => ???
    }

}
object Stream {
  def fromIterator[A](source: Iterator[A]): Stream[A] =
    FromIterator(source)

  // Stream algebraic data type

  final case class Zip[A,B](left: Stream[A], right: Stream[B]) extends Stream[(A,B)]
  final case class Map[A,B](source: Stream[A], f: A => B) extends Stream[B]
  final case class FromIterator[A](source: Iterator[A]) extends Stream[A]
}
```

We can push on with this implementation but the natural end point is not what we want: we'll end up processing all the elements at once.
To finish the implementation we need to make one leap of imagination: we need to recognise that we wish to process the elements one at a time and we should write a function to get the next element. 
Implementing `next` is straightforward. 
It is a structural recursion, so we can immediately write down

```scala
def next[A](stream: Stream[A]): A =
  stream match {
    case FromIterator(source) => ???
    case Map(source, f) => ???
    case Zip(left, right) => ???
  }
```

We can follow the types for most of the implementation; when we get to `FromIterator` we must remember we get the next element by calling the `next` method on `source`.

```scala
def next[A](stream: Stream[A]): A =
  stream match {
    case FromIterator(source) => source.next()
    case Map(source, f) => f(next(source))
    case Zip(left, right) => (next(left), next(right))
  }
```

Now we can implement `foldLeft` in terms of `next`.

```scala
def foldLeft[B](zero: B)(f: (A, B) => B): B = {
  def next[A](stream: Stream[A]): A =
    stream match {
      case FromIterator(source) => source.next()
      case Map(source, f) => f(next(source))
      case Zip(left, right) => (next(left), next(right))
    }

  def loop(result: B): B =
    loop(f(next(this)), result)

  loop(zero)
}
```

You might have noticed as issue with this implementation.
We'll address it in the next section.
The point of this section is to demonstrate how:

 - we can systematically write most of the implementation using a few patterns; and
 - the separation between describing (most of the API) and executing (`foldLeft`) allows us to introduce effects in a controlled manner.

This second point is really important as it is *the* trick in functional programming that allows us to work with effects without giving up the nice properties, like substitution, that we love about FP.

**TODO The complete code is on Github**

### Termination

There is one big problem with the implementation as it stands: when we hit the end of an `Iterator` we crash.
Our patterns did not protect us from this issue because `Iterator` is not an algebraic data type, so we can't safely work with it using structural recursion.
We have to fall back on memory, and hence human fallibility, to remember to check if the `Iterator` has elements.

We need to change the result type of `next` to indicate if more elements exist.
A simple way to do this is to return an `Option[A]`.

```scala
def next[A](stream: Stream[A]): Option[A] =
  stream match {
    case FromIterator(source) =>
      if(source.hasNext) Some(source.next()) else None
    case Map(source, f) =>
      next(source).map(f)
    case Zip(left, right) =>
      for {
        l <- next(left)
        r <- next(right)
      } yield (l, r)
  }
```

We have to make a change to `foldLeft` as well.

```scala
def foldLeft[B](zero: B)(f: (A, B) => B): B = {
  def next[A](stream: Stream[A]): Option[A] =
    stream match {
      case FromIterator(source) =>
        if(source.hasNext) Some(source.next()) else None
      case Map(source, f) =>
        next(source).map(f)
      case Zip(left, right) =>
        for {
          l <- next(left)
          r <- next(right)
        } yield (l, r)
    }

  def loop(result: B): B =
    next(this) match {
      case None => result
      case Some(a) => loop(f(a, result))
    }

  loop(zero)
}
```

Now we have a complete system that doesn't crash.
We can implement some benchmarks to get baseline performance measurements.
Benchmarks blah blah blah
**TODO Link to Github**

On my machine the benchmark result is

```
[info] Result "termination.StreamBenchmark.zipAndAdd":
[info]   569.189 ±(99.9%) 5.915 ms/op [Average]
[info]   (min, avg, max) = (520.228, 569.189, 628.885), stdev = 25.043
[info]   CI (99.9%): [563.274, 575.104] (assumes normal distribution)
```

In other words about **569ms**, with a variance that is small enough we can ignore it in this situation.

Let's think about the performance model for this code, which will motivate our Church encoding.
The `Stream` type forms a directed acyclic graph that `foldLeft` walks from downstream to upstream.
There are many optimisatinos we could make.
For example, we could fuse adjacent nodes in the graph, rewriting, for example, a sequence of `Map` into a single `Map` node.
This may---or may not---improve performance by avoiding extra calls in `next` and opening up more opportunities for inlining.
One area where we might think we can make large gains is in avoiding allocation.
Right now we allocate an `Option` for every element we process.
In fact, if there are `n` nodes in the graph and `m` elements we process, we allocate `n * m` `Options`.
Now `n` is typically small, but `m` is typically very large, so we might think that if we avoid this allocation there are some easy performance improvements to be had.


**TODO The complete code is on Github**

### The Diamond Problem

### Church Encoding

Church encoding.

Performance.

Inversion of control flow.


### Benchmarks

[info] Result "termination.StreamBenchmark.zipAndAdd":
[info]   569.189 ±(99.9%) 5.915 ms/op [Average]
[info]   (min, avg, max) = (520.228, 569.189, 628.885), stdev = 25.043
[info]   CI (99.9%): [563.274, 575.104] (assumes normal distribution)

[info] Result "church.StreamBenchmark.zipAndAdd":
[info]   400.804 ±(99.9%) 5.202 ms/op [Average]
[info]   (min, avg, max) = (381.642, 400.804, 600.779), stdev = 22.024
[info]   CI (99.9%): [395.603, 406.006] (assumes normal distribution)

## Church Encodings

Type classes

Finally tagless interpreters

Objects
