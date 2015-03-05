---
layout: post
title: Designing Fail-Fast Error Handling
author: Noel Welsh
---

In this post I want to explore the design space for error handling techniques in Scala. We previously [posted]({% post_url 2015-02-13-error-handling-without-throwing-your-hands-up %}) about some basic techniques for error handling in Scala. That post generated quite a bit of discussion. Here I want to expand the concepts Jonathon introduced by showing how we can systematically design a mechanism for error handling, introduce some moderately advanced techniques, and discuss some of the tradeoffs.

<!-- break -->

## Goals

Before we can design our system we must lay out the goals we hope to accomplish. There are two goals we are aiming for.

Our first goal is to **stop as soon as we encounter an error**, or in other words, fail-fast. Sometimes we want to accumulate all errors -- for example when validating user input -- but this is a different problem and leads to a different solution.

Our second goal is to **guarantee we handle every error we intend to handle**. As every programmer knows, if you want something to happen every time you get a computer to do it. In the context of Scala this means using the type system to guarantee that **code that does not implement error handling will not compile**.

There are two corollaries of our second goal:

1. if there are errors we don't care to handle, perhaps because they are so unlikely, or we cannot take any action other than crashing, don't model them; and

2. if we add or remove an error type that we do want to handle, the compiler must force us to update the code.


## Design

There are two elements to our design:

- how we represent the act of encountering an error (to give us fail-fast behaviour); and
- how we represent the information we store about an error.


## Failing Fast

Our two tools for fail-fast behaviour are throwing exceptions and sequencing computations using monads.

We can immediately discard using exceptions. Exceptions are unchecked in Scala, meaning the compiler will not force us to handle them. Hence they won't meet our second goal.

This leaves us with monads. The term may not be familiar to all Scala programmers, but most will be familiar with `Option` and `flatMap`. This is essentially the behaviour we are looking for. `Option` gives us fail-fast behaviour when we use `flatMap` to sequence computations[^type-inference].

[^type-inference]: I use `Option.empty[A]` to construct an instance of `None` with the type I want. If I instead used a plan `None` (which is a sub-type of `Option[Nothing]`) type inference in this case infers `Option[String]`. This is due to the overloading of `+` for string concatentation as well as numeric addition.

~~~ scala
scala> Option(1) flatMap { x =>
  println("Got x")
  Option.empty[Int] flatMap { y =>  // The computation fails here and later steps do not run
    println("Got y")
    Option(3) map { z =>
      println("Got z")
      x + y + z
    }
  }
}

Got x
res0: Option[Int] = None
~~~

It's normally clearer to write this using a for-comprehension:

~~~ scala
for {
  x <- Option(1)
  y <- Option.empty[Int]
  z <- Option(3)
} yield (x + y + z)
res1: Option[Int] = None
~~~

There are a lot of data structures that implement variations of this idea. We might also use `Either` or `Try` from the standard library, or Scalaz's disjuction, written `\/`.

We want some information on errors for debugging. This means we can immediately drop `Option` from consideration, as when we encounter an error the result is simply `None`. We know that an error *has* happened, but we don't know *what* error it is.

We can also drop `Try` from consideration. `Try` always stores a `Throwable` to represent errors. What is a `Throwable`? It can be just about anything. In particular, it's not a sealed trait so the compiler can't help us to ensure we handle all the cases we intend to handle. Therefore we can't meet goal two if we use `Try`.

`Either` allows us to store any type we want as the error case. Thus we could meet our goals with `Either`, but in practice I prefer not to use it. The reason being it is cumbersome to use. Whenever you `flatMap` on an `Either` you have to decide which of the left and right cases is considered that success case (the so-called left and right projections). This is tedious and, since the right case is always considered the succesful case, only serves to introduce bugs[^bugs]. Here's an example of use, showing the continual need to specify the projection.

[^bugs]: Admittedly this is not a common source of bugs. However, I sometimes get my right and left mixed up (I'm left-handed) and this *is* the kind of mistake I could make.

~~~ scala
// Given a method that returns `Either`:
def readInt: Either[String, Int] =
  try {
    Right(readLine.toInt)
  } catch {
    case exn: NumberFormatException =>
      Left("Please enter a number")
  }

// We can call right-biased flatMap...
readInt.right.flatMap { number =>
}

/// ...or left-biased flatMap:
readInt.left.flatMap { errorMessage =>
  // flatMap is left-biased here
}

// This makes for-comprehensions cumbersome:
for {
  x <- readInt.right
  y <- readInt.right
  z <- readInt.right
} yield (x + y + z)
~~~

My preferred choice is Scalaz's `\/` type, which is *right-biased*. This means it always considers the right hand to be the successful case for `flatMap` and `map`. It's much more convenient to use than `Either` and can be used as a mostly drop-in replacement for it. Herea's an example of use.

~~~ scala
import scalaz.\/

def readInt: \/[String, Int] = // String error or Int success
  try {
    \/.right(readLine.toInt) // Creates a right-hand (success) value
  } catch {
    case exn: NumberFormatException =>
      \/.left("Please enter a number") // Creates a left-hand (failure) value
  }

// \/ is a monad, so it has a flatMap method and we can use it in for
// comprehensions
for {
  x <- readInt
  y <- readInt
  z <- readInt
} yield (x + y + z)
~~~


## Representing Errors

Having decided to use the disjunction monad for fail-fast error handling, let's turn to how we represent errors. 

Errors form a logical disjunction. For example, database access could fail because the record is not found *or* no connection could be made *or* we are not authenticated, and so on. As soon as we see this structure we should turn to an algebraic data type (a sum type in particular), which we implement in Scala with code like

~~~ scala
sealed trait DatabaseError
final case class NotFound(...) extends DatabaseError
final case class CouldNotConnect(...) extends DatabaseError
final case class CouldNotAuthenticate(...) extends DatabaseError
...
~~~

When we process a `DatabaseError` we will typically use a `match` expression, and because we have used a `sealed` trait the compiler will tell us if we have forgotten a case. This meets our second goal, of handling every error we intend to handle.


I strongly recommend defining a separate error type for each logical subsystem. Defining a system wide error hierarchy quickly becomes unwieldy, and you often want to expose different information at different layers of the system. For example, it is useful to include authentication information if a login fails but making this information available in our HTTP service could lead to leaking confidential information if we make a programming error.

A complete code example is in [this Gist](https://gist.github.com/noelwelsh/9cacc8683bf3231b9219).


## Unexpected Errors

We have the basic structure in place -- use `\/` for fail fast behaviour along with an algebraic data type to represent errors. However we still have a few issues to address to really polish our system. One is how we handle unexpected errors. This can either be legacy code throwing exceptions, or they can be errors that we just aren't interested in dealing with. For example, running out of disk space may be possibility that we decide is so unlikely that we don't care to devote error handling logic to it. To handle this case I like to add a case to our algebraic data types to store unexpected errors. This usually has a single field that stores a `Throwable`.


## Locating Error Messages

It is very useful to know the location (file name and line number) of an error. Exceptions provide this through the stack trace, but if we roll our own error types we must add the location ourselves. We can use macros to extract location information, but it is probably simpler to created a sealed subtype of `Exception` as the root of our algebraic data types, and use `fillInStackTrace` to capture location information. Wrap this up behind a convenience constructor and we'll always have location information for debugging.


## Union types

Finally, we see that we often repeat error types as we move between layers. For example, both the database and service layers [in the example](https://gist.github.com/noelwelsh/9cacc8683bf3231b9219) have `NotFound` errors that mean essentially the same thing. Inheritance restricts us to tree shaped subtyping relationships. We can't "reach into" the `DatabaseError` type to pull out just the `NotFound` case for inclusion in `ServiceError`.

If we used a logical extension of `Either` (or `\/`) that we can piece together types in an ad-hoc way. For example, we could use `\/[NotFound, BadPassword]` to represent our errors, and if we wanted to extend to more cases we could use `\/[NotFound, \/[BadPassword, NotFound]]` and so on, forming a list structure. The [shapeless](https://github.com/milessabin/shapeless) `Coproduct` provides a generalisation of this idea.

We can go one step further with [unboxed union types](http://www.chuusai.com/2011/06/09/scala-union-types-curry-howard/) to achieve the same effect with less runtime cost. This might be a step too far for most teams, but do note that union types are [slated for inclusion in a future version of Scala](http://www.scala-lang.org/news/roadmap-next).


## Conclusions

We have seen how to construct an error handling framework that meets our two goals of failing fast and handling all the errors we intend to handle. As always, use techniques appropriate for the situation. For example, many people commented on `Try` in our [previous post]({% post_url 2015-02-13-error-handling-without-throwing-your-hands-up %}). `Try` won't help us ensure we handle all the errors we want to handle, our second design in this post. For this reason I don't like using it. However, if you can accept losing the guarantees on error handling it imposes then it is worth considering. If you are writing a one off script maybe you don't need error handling at all.

We've also seen systematic application of Scala features. Whenever we have a structure that is *this* or *that* we should recognise it is a sum type and reach for a `sealed trait`. Whenever we find ourselves sequencing computation there is probably a monad involved. Understanding these patterns is the foundation for successful programming in Scala. If you are interested in learning more they are explained in more depth in our books and courses, particularly [Essential Scalaz](http://underscore.io/training/courses/essential-scalaz/). The next two Essential Scala courses are running in [San Francisco](/events/2015-03-19-essential-scalaz.html) and [Edinburgh](/events/2015-03-30-advanced-scala.html).
