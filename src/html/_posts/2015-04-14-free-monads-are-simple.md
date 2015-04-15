---
layout: post
title: Free Monads Are Simple
author: Noel Welsh
---

I recently gave [a talk][slides] on free monads at the [Advanced Scala meetup][advanced-scala] in London. Despite the name of the group, I think that free monads are eminently simple as well as being extremely useful. Let me explain.

<!-- break -->

The free monad brings together two concepts, monads and interpreters, allowing the creation of composable monadic interpreters. That's a bunch of big words, but why should we care? Because it allows simple solutions to difficult problems.

Take the example of Facebook's [Haxl][haxl] and Twitter's [Stitch][stitch]. Both systems solve a problem faced by companies that have aggressively adopted a service oriented architecture:[^etsy] service orchestration.

Consider rendering a user's Twitter stream. Hypothetically, the process might first retrieve the list of recent tweets from one service. Then for each tweet it might fetch the tweeter's name and picture to go alongside the tweet, which could require a request to two more services. No doubt there are logging and analytics services that would also be involved. All told a great number of services and requests can be involved in answering what is a single request from the UI perspective. With this explosion of requests there are a number of problems: increased network traffic, increased latency (which goes hand-in-hand with traffic), and consistency.

The last point deserves some explanation. Imagine two tweets by the same person are in the stream. That person could change their details inbetween fetching the name and photo for the first and second tweet. If we allow this inconsistency to occur it makes for a very poor user experience, as the user can't tell at a glance that the two tweets are by the same person.

It's fairly clear that we could avoid this inconsistency *and* solve our network traffic and latency issues if we just cached data. We could implement this by writing special-purpose request aggregation and caching for each request type, which is quickly going to be a losing battle as APIs and interfaces evolve. Or we could write a general purpose tool that allows us to describe the data we need and takes care of the optimisation for us. The free monad allows us to easily do this. Sold? Ok, let's get back to describing the free monad.

## Monads

Remember I said the free monad brings together monads and interpreters. Let's start with the monad part. I'm going to assume you understand monads already. If not, don't worry. They're just like cats or burritos or something.

Now recall that a monad is defined by two operations[^laws], `point` and `flatMap`, with signatures

- `point[M[_], A](a: A): M[A]`; and
- `flatMap[M[_], A, B](fa: M[A])(f: A => M[B]): M[B]`.

`Point` is not very interesting --- it just wraps a monad around a value. `FlatMap` is, however, the distinguishing feature of a monad and it tells us something very important: *monads are fundamentally about control flow*. The signature of `flatMap` says you combine a `M[A]` and a function `A => M[B]` to create a `M[B]`. The only way to do this is to get the `A` out of the `M[A]` and apply it to the `A => M[B]` function. There is a clear ordering of operations here, and repeated applications of `flatMap` creates a sequence of operations that must execute from left to right. So we see that monads explicitly encode control flow[^continuation-monad].

We usually use monads to glue together pure functions with special purpose control-flow, such as fail fast error handling (using `\/` or `Either`) or asynchronous computation (using `Future`). The free monad allows us to abstractly specify control flow between pure functions, and separately define an implementation.

## Interpreters

Ok, so that's monads: control flow. What about interpreters. Interpreters are about separating the representation of a computation from the way it is run. Any interpreter has two parts[^two-parts]:

1. an *abstract syntax tree* (AST) that represents the computation; and
2. a process that gives meaning to the abstract syntax tree. That is, the bit that actually runs it.

A simple example is in order. Consider the expression `1 + 2 + 3`. We can execute this directly, evaluating to `6`, or we could represent it as an abstract syntax tree such as `Add(1, Add(2, 3))`. Given the AST we could choose from many different ways to interpret it:

- We could represent results using `Ints`, `Doubles`, or arbitrary precision numbers.
- We could perform our calculations using [dual numbers][dual-numbers], calculating the derivative at the same time (very useful for machine learning applications).
- We could transform our calculation to run on the processor's vector unit, or on a GPU.

Hopefully this gives you a feel for the structure and power of the interpreter pattern.

## Free Monads

We have talked about monads and interpreters. I said the free monad is just the combination of the two. Concretely this means the free monad provides:

- an AST to express monadic operations;
- an API to write interpreters that give meaning to this AST.

What does the AST look like? It simply represents the monad operations without giving meaning to them. The usual representation of the free monad represents the monadic operations in terms of `point` along with `join`, instead of the more familiar `flatMap`, but the idea is still the same. An example encoding is

~~~ scala
sealed trait Free[F[_], A]
final case class Point[F[_], A](a: A) extends Free[F, A]
final case class Join[F[_], A](s: F[Free[F, A]]) extends Free[F, A]
~~~

Now what does a free monad interpreter look like? It's just a function from `F[_]`, the representation inside the free monad, to `G[_]`, some monad in which we really run the computation (the `Id` monad is a popular choice). This type of function has a special name, a [natural transformation][natural-transformation]

Here's a simple example of service orchestration.

We start with some imports and other basic definitions. The `Requestable` type is described below.

~~~ scala
import scalaz.{Free, ~>, Id, Coyoneda}
import scalaz.std.list._
import scalaz.syntax.traverse._

object Orchestration {

  type UserId = Int
  type UserName = String
  type UserPhoto = String

  type Requestable[A] = Coyoneda[Request, A] // this is described below

  final case class Tweet(userId: UserId, msg: String)
  final case class User(id: UserId, name: UserName, photo: UserPhoto)
~~~

Next we need to define the data we're going to store in the free monad. This is the `Request` type, which represents a request to fetch some data (but doesn't actually fetch any data). The `Service` type represents different services we may contact.

~~~ scala
  // Services represent web services we can call to fetch data
  sealed trait Service[A]
  final case class GetTweets(userId: UserId) extends Service[List[Tweet]]
  final case class GetUserName(userId: UserId) extends Service[UserName]
  final case class GetUserPhoto(userId: UserId) extends Service[UserPhoto]

  // A request represents a request for data
  sealed trait Request[A]
  final case class Pure[A](a: A) extends Request[A]
  final case class Fetch[A](service: Service[A]) extends Request[A]
~~~

For technical reasons we need to have a `Functor` instance to put inside the free monad. Scalaz provides a convenience called the `Coyoneda` that automatically constructs one for us. The `Requestable` type represents this. We define some constructors to hide the application of the `Coyoneda`.

~~~ scala
  object Request {
    def pure[A](a: A): Free[Requestable, A] =
      Free.liftFC(Pure(a) : Request[A])

    def fetch[A](service: Service[A]): Free[Requestable, A] =
      Free.liftFC(Fetch(service) : Request[A])
  }
~~~

Now we define an interpreter for `Request`. This interpreter just prints to the console. It's a simple example such as you might use in testing. You can imagine a more elaborate interpreter that make parallel calls to web services and caches the results.

~~~ scala
  object ToyInterpreter extends (Request ~> Id.Id) {
    import Id._

    def apply[A](in: Request[A]): Id[A] =
      in match {
        case Pure(a) => a
        case Fetch(service) =>
          service match {
            case GetTweets(userId) =>
              println(s"Getting tweets for user $userId")
              List(Tweet(1, "Hi"), Tweet(2, "Hi"), Tweet(1, "Bye"))

            case GetUserName(userId) =>
              println(s"Getting user name for user $userId")
              userId match {
                case 1 => "Agnes"
                case 2 => "Brian"
                case _ => "Anonymous"
              }

            case GetUserPhoto(userId) =>
              println(s"Getting user photo for user $userId")
              userId match {
                case 1 => ":-)"
                case 2 => ":-D"
                case _ => ":-|"
              }
          }
      }
  }
~~~

Finally here's an example of definition and use.

~~~ scala
  object Example {
    import Request._

    val theId: UserId = 1

    def getUser(id: UserId): Free[Requestable, User] =
      for {
        name  <- fetch(GetUserName(id))
        photo <- fetch(GetUserPhoto(id))
      } yield User(id, name, photo)

    val free: Free[Requestable, List[(String, User)]] =
      for {
        tweets <- fetch(GetTweets(theId))
        result <- (tweets map { tweet: Tweet =>
          for {
            user <- getUser(tweet.userId)
          } yield (tweet.msg -> user)
        }).sequenceU
      } yield result

    def run: List[(String, User)] =
      Free.runFC(free)(ToyInterpreter)
  }
}
~~~

## Conclusions

That's the basics of the free monad: it's something we can wrap around an arbitrary type constructor (a `F[_]`) to construct a monad. It allows us to separate the structure of the computation from its interpreter, thereby allowing different interpretation depending on context.

There are a lot of conveniences for using the free monad. The example showed the use of the `Coyoneda` to automatically convert a type constructor into a functor that the free monad requires. We can compose different types wrapped in the free monad, and different interpreters, using coproducts. This is all useful stuff but not essential for understanding the core idea.

The core idea, separating the structure and interpretation of computer programs, is incredibly powerful (wizardly, even). Haxl and Stitch are just two prominent examples of this. In some sense *all* of functional programming is writing interpreters, a view echoed by many [experienced][don-stewart] [FPer][runar]

If you are interested in learning more about these ideas, we are writing a book [Essential Interpreters][advanced-scala-scalaz] that covers the basics of interpreters up to the free monad.

[^etsy]: Etsy, for example, faces the same problem but [their solution](https://codeascraft.com/2015/04/06/experimenting-with-hhvm-at-etsy/) is rather less elegant and performant.
[^laws]: And the monad laws.
[^two-parts]: Some very simple interpreters entwine these two parts, but they are conceptually if not literally separate.
[^continuation-monad]: Related to this, the continuation monad can be used to [encode any other monad][continuation-monad]. What is a [continuation][continuation]? It's a universal control flow primitive. *Any* control flow can be expressed using continuations.

[advanced-scala-scalaz]: /training/courses/advanced-scala-scalaz
[dual-numbers]: http://en.wikipedia.org/wiki/Dual_number
[natural-transformation]: http://docs.typelevel.org/api/scalaz/nightly/#scalaz.NaturalTransformation
[slides]: http://noelwelsh.com/assets/downloads/advanced-scala-2015-free-monads.pdf
[advanced-scala]: http://www.meetup.com/london-scala/events/220942615/
[haxl]: https://github.com/facebook/Haxl
[stitch]: https://www.youtube.com/watch?v=VVpmMfT8aYw
[continuation]: http://en.wikipedia.org/wiki/Continuation
[continuation-monad]: http://blog.sigfpe.com/2008/12/mother-of-all-monads.html
[don-stewart]: http://stackoverflow.com/a/27860072
[runar]: https://thenewcircle.com/s/post/1730/the_interpreter_pattern_revisited_runar_bjarnason_video
