---
layout: post
title: Designing Error Handling
author: Noel Welsh
---

In this post I want to explore the design space for error handling techniques in Scala. We previously [posted]({ post_url 2015-02-13-error-handling-without-throwing-your-hands-up }) about some basic techniques for error handling in Scala. That post generated quite a bit of discussions. Here I want to show how we can systematically move from goals to solution, introduce some moderately advanced techniques, and discuss some of the tradeoffs.

## Goals

Before we can design our system we must lay out the goals we hope to accomplish. There are two gaols we are aiming for.

Our first goal is to **stop as soon as we encounter an error**, or in other words, fail-fast. Sometimes we want accumulate all errors -- for example when validating user input -- but this is a different problem and leads to a different solution.

Our second goal is to **guarantee we handle every error we intend to handle**. As every programmer knows, if you want something to happen every time you get a computer to do it. In the context of Scala this means using the type system to guarantee that **code that does not implement error handling will not compile**.

There are two corollaries our second goal:

1. if there are errors we don't care to handle, perhaps because they are so unlikely, or we cannot take any action other than crashing, don't model them; and

2. if we add or remove an error type that we do want to handle, the compiler must force us to update the code.


## Design

There are two elements to our design:

- how we represent the act of encountering an error (to give us fail-fast behaviour); and
- how we represent the information we store about an error.


## Exceptions and Monads

Our two tools for fail-fast behaviour are throwing exceptions and sequencing computations using monads.

We can immediately discard using exceptions. Exceptions are unchecked in Scala, meaning the compiler will not force us to handle them. Hence they won't meet our second goal.

This leaves us with monads. The term may not be familiar to all Scala programmers, but all but beginning Scala programmers should be familiar with `Option` and `flatMap`. This is essentially the behaviour we are looking for. `Option` gives us fail-fast behaviour when we use `flatMap` to sequence computations[^type-inference].

[^type-inference]: I use `Option.empty` to construct an instance of `None` with the type I want. If I instead used a plan `None` (which is a sub-type of `Option[Nothing]`) type inference in this case infers `Option[String]`. This is due to the overloading of `+` to mean string concatentation as well as numeric addition.

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

There are a lot of data structures that implement variations of this idea. We might use `Either` or `Try` from the standard library, or Scalaz's disjuction, written `\/`.


## Representing Errors

We've seen we can use a monad like `Option`, `Try`, or `\/` to implement fail-fast behaviour. Now we turn to how we actually represent the errors we encounter.

We want some level of debuggability. This means we can immediately drop `Option` from consideration as it doesn't allow us to record any information on the reason the error occurred.

A typical situation is the we have a logical disjunction of errors that can occur. For example, or database access could fail because the record is not found *or* no connection could be made *or* we are not authenticated correctly, and so on. As soon as we see this structure we should turn to an algebraic data type, which we implement in Scala with code like

~~~ scala
sealed trait DatabaseError
final case class NotFound(...) extends DatabaseError
final case class CouldNotConnect(...) extends DatabaseError
final case class CouldNotAuthenticate(...) extends DatabaseError
...
~~~

When we process a `DatabaseError` we will typically use a `match` expression, and because we have used a `sealed` trait the compiler will tell us if we have forgotten to handle a case. This meets our second goal, of handling every error we intend to handle.

I strongly recommend defining a separate error type for each logical subsystem. Defining a system wide error hierarchy quickly becomes unweildy, and you often want to expose different information at different layers of the system. For example, it is useful to include authentication information if a login fails but making this information available in our HTTP service could lead to leaking confidential information if we make a programming error.

Once we have made this decision we can drop `Try` from consideration. `Try` always stores a `Throwable` to represent errors. What is a `Throwable`? It could be just about anything, and this means the compiler is not going to help us with exhaustiveness checking. Therefore we can't meet goal two if we use `Try`.

`Either` allows us to store any type we want as the error case. Thus we could meet our goals with `Either`, but in practice is prefer not to use it. The reason it that it is cumbersome to use. Whenever you `flatMap` on an `Either` you have to decide which of the left and right cases is considered that success case (the so-called left and right projections). This is tedious and, since the right case is always considered the succesful case, adds no value but serves as a way to introduce bugs[^bugs].

[^bugs]: Admittedly this is no a common source of bugs. However, as a leftie I sometimes get my right and left mixed up and it is conceivable this *is* the kind of mistake I could make.

My preferred choice is Scalaz's `\/` type, which is *right-biased*. This means it always considers the right hand to be the successful case. It's much more convenient to use than `Either`.


## Unexpected Errors

We have the basic structure in place -- use `\/` for fail fast behaviour along with an algebraic data type to represent errors. However we still have a few issues to address to really polish our system. One is how we handle unexpected errors. This can either be legacy code throwing exceptions, or they can be errors that we just aren't interested in dealing with. For example, running out of disk space may be possibility that we decide it is so unlikely that we don't care to devote error handling logic to it. To handle this case I like to add case to our algebraic data types to store unexpected errors. This usually has a single field that stores a `Throwable`.

Complete example ...


## Locating Error Messages

It is very useful to know the location (file name and line number) of an error. Exceptions provide this through the stack trace, but if we roll our own error types we must add the location ourselves. We can use macros to extract location information, but it is probably simpler to created a sealed subclass of `Exception` as the root of our algebraic data types.

fillInStackTrace? private constructors.

Example two...


## Union types.

## Conclusions

This meets all our goals. If we have weaker goals we can use weaker methods. For example, many people like `Try`. If you can accept losing the guarantees on error handling it imposes, use that. If you are writing a one off script maybe you don't need error handling at all.

Systematic application of Scala features to overcome design issues. Read Essential Scalaz.