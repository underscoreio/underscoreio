---
layout: post
title: |
   Playing "Type Tetris"
author: "Adam Rosien"
---

I'm going to try to explain a technique called type-driven development.
It's where we write as much code as possible using *only* types, deferring
any non-type details until later. We'll see how it helps us as we develop a small service
that supports authentication.
Along the way we'll see how we can use abstract types, the `???` method, and the Scala compiler itself to converge towards a good solution to our task.

Since type-driven development doesn't sound very fun, I like to call it "Type Tetris".
How is programming with (only) types like Tetris?

<!-- break -->

* Main goal: we want horizontal lines of blocks to disappear (*We want the code to compile*)
* Tetriminos (Tetris blocks) fit together in space. Sometimes they align in useful ways, other times they don't. (*Types combine by making new types, and expressions can successfully, or unsuccessfully typecheck.*)
* Blocks have already been dropped, accumulating at the bottom of the board. There are gaps we'd like to fill, to make them disappear, using new pieces that fall from above. (*We figure out the type(s) we need to so our code will compile*)

To spell out the analogy:

| Tetris  | Type Tetris |
| ------------- | ------------- |
| blocks | expressions |
| block shapes *(e.g., L-shape vs. Z-shape)* | expressions have a type |
| blocks fit together in space | we compose expressions into new expressions |
| there are horizontal gaps we need to fill | the code doesn't typecheck |
| horizontal lines of blocks disappear | the code is successfully typechecked by the compiler |

<a title="By Cezary Tomczak, Maxime Lorant (Own work) [CC BY-SA 4.0 (http://creativecommons.org/licenses/by-sa/4.0) or BSD (http://opensource.org/licenses/bsd-license.php)], via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File%3ATetris_basic_game.gif"><img width="256" alt="Tetris basic game" src="https://upload.wikimedia.org/wikipedia/commons/c/c4/Tetris_basic_game.gif"/></a>

This is a powerful, and fun, technique because we specifically *avoid* implementation details, and instead focus solely on creating the correct types and (function) type signatures. (*We're going to specifically talk about **function types**: types that have types for inputs, and an output type.*)

Let's use "Type Tetris" to start working on the following toy problem:

> Create a service skeleton that reads a request and produces a response.
>
> The request needs to be authorized: pass some credentials and authorize them.
> Do some work only if the request is authorized. The work should be completed asynchronously.

Let's code!

## Start with the types

Let's start with the barest skeleton of code to define our service. We're going to *only* create types and function signatures (where are simply *function* types):

```scala
object TypeTetris {
  import scala.concurrent.Future

  // abstract types!
  type Request
  type Response

  def service(request: Request): Future[Response] = ???
}
// defined object TypeTetris
```

What's that [`???`](http://www.scala-lang.org/api/2.11.4/index.html#scala.Predef$@???:Nothing)?

```scala
// defined in Prelude.scala
def ??? : Nothing = throw new NotImplementedError
```

You put it anywhere where you need to return a value, but *haven't actually computed it* yet. It has type `Nothing`, which is a subtype of every type, so your methods will compile (but *not* run without an error).

## Modeling authorization

Hmm, what's authorization? We certainly need to do it, whatever it is, before we "really" process the request. So maybe authorization transforms a `Request` into another `Request`:

```scala
object TypeTetris {
  import scala.concurrent.Future

  type Request
  type Response

  def service(request: Request): Future[Response] =
    // transform the request and then really process it (we don't know how yet, so write ???)
    (authorize _ andThen ???)(request)

  def authorize(request: Request): Request = ??? // defer writing this by using ???
}
// defined object TypeTetris
```

Something like that.

Maybe we need different `Request` subtypes, one for unauthorized, one for authorized. Let's try that:

```scala
object TypeTetris {
  import scala.concurrent.Future

  sealed trait Request // algebraic data type!

  object Request {
    final case class Unauthorized() extends Request
    final case class Authorized() extends Request
  }

  type Response

  def service(request: Request): Future[Response] = {
    val authorized = authorize(request)

    ???
  }

  def authorize(request: Request.Unauthorized): Option[Request.Authorized] = ???
}
// <console>:25: error: type mismatch;
//  found   : TypeTetris.Request
//  required: TypeTetris.Request.Unauthorized
//            val authorized = authorize(request)
//                                       ^
```

Ahh, we split `Request` into two cases, so we need to start in the correct, unauthorized request state:

```scala
object TypeTetris {
  import scala.concurrent.Future

  sealed trait Request

  object Request {
    final case class Unauthorized() extends Request
    final case class Authorized() extends Request
  }

  type Response

  // ensure request is unauthorized
  def service(request: Request.Unauthorized): Future[Response] = {
    val authorized = authorize(request)

    ???
  }

  def authorize(request: Request.Unauthorized): Option[Request.Authorized] = ???
}
// defined object TypeTetris
```

## Handling authorization success and failure

Ok, we've attempted to authorize an unauthorized request. Let's put `???` placeholders in for the two cases:

```scala
object TypeTetris {
  import scala.concurrent.Future

  sealed trait Request

  object Request {
    case class Unauthorized() extends Request
    case class Authorized() extends Request
  }

  type Response

  def service(request: Request.Unauthorized): Future[Response] = {
    val authorized = authorize(request)

    authorized map (r => ???) getOrElse ???
  }

  def authorize(request: Request.Unauthorized): Option[Request.Authorized] = ???
}
// defined object TypeTetris
```

Let's handle unauthorized requests first. We need a `Response` that means "unauthorized":

```scala
object TypeTetris {
  import scala.concurrent.Future

  sealed trait Request

  object Request {
    case class Unauthorized() extends Request
    case class Authorized() extends Request
  }

  sealed trait Response

  object Response {
    case class Unauthorized() extends Response
  }

  def service(request: Request.Unauthorized): Future[Response] = {
    val authorized = authorize(request)

    authorized map (r => ???) getOrElse Future.successful(Response.Unauthorized())
  }

  def authorize(request: Request.Unauthorized): Option[Request.Authorized] = ???
}
// defined object TypeTetris
```

Now let's handle the case if our request is authorized:

```scala
object TypeTetris {
  import scala.concurrent.Future

  sealed trait Request

  object Request {
    case class Unauthorized() extends Request
    case class Authorized() extends Request
  }

  sealed trait Response

  object Response {
    case class Unauthorized() extends Response
  }

  def service(request: Request.Unauthorized): Future[Response] = {
    val authorized = authorize(request)

    authorized map doWork getOrElse Future.successful(Response.Unauthorized())
  }

  def authorize(request: Request.Unauthorized): Option[Request.Authorized] = ???

  // again, we don't implement this yet
  def doWork(request: Request.Authorized): Future[Response] = ???
}
// defined object TypeTetris
```

## Implement the remaining unimplemented methods

Finally we can fill in the implementation of `authorize`:

```scala
object TypeTetris {
  import scala.concurrent.Future

  sealed trait Request

  object Request {
    case class Unauthorized(secret: String) extends Request
    case class Authorized() extends Request
  }

  sealed trait Response

  object Response {
    case class Unauthorized() extends Response
  }

  def service(request: Request.Unauthorized): Future[Response] = {
    val authorized = authorize(request)

    authorized map doWork getOrElse Future.successful(Response.Unauthorized())
  }

  def authorize(request: Request.Unauthorized): Option[Request.Authorized] =
    if (request.secret == "secret") Some(Request.Authorized())
    else None

  def doWork(request: Request.Authorized): Future[Response] = ???
}
// defined object TypeTetris
```

Now somebody else can write `doWork`. :)

## Summary

In this post we have seen how we can incrementally build a program to match our specification, delaying the need for implementation details until we really need them. Specifically:

* Use abstract types to name concepts. Defer the need for data or methods on them! They can be useful without them.
* Use `???` when you don't care, yet, what an implementation should be.
* When you fill in a `???` in an expression, first create methods with no implementation, using `???`, to name operations. Again, naming, by creating a type, comes before implementation. (In this case, creating an unimplemented method is equivalent to creating a function type)
* Don't forget to implement the code you didn't write yet via `???`. You can turn on compiler option `-Ywarn-dead-code` with options `-Xfatal-warnings`, `-Xlint` to have the compiler help you remember. (Annoyingly, the compiler doesn't always find them, so *caveat lector*)

Programming with types can be fun in itself, like playing a game of Tetris, and they get you most of the way to working programs. Have fun! (*cue the [Коробейники](https://en.wikipedia.org/wiki/Korobeiniki)*)
