---
layout: post
title: "Value Discarding"
author: "Richard Dallaway"
---

Scala includes a feature called "value discarding".
This interacts in possibly surprising ways when combining functions that side effect.
In this post we'll look at an example, and describe ways to work safely with value discarding.

[vd]: http://scala-lang.org/files/archive/spec/2.11/06-expressions.html#value-discarding
[ff]: /blog/posts/2015/02/23/designing-fail-fast-error-handling.html

<!-- break -->

## Fast-fail with `Unit`

If you're working with side-effects that might fail,
there are [various ways][ff] you can express that in Scala.
One way is to use `Either` and `Unit`:

``` scala
import scala.util.{Either, Right, Left}

case class Failed(msg: String)

def run(): Either[Failed, Unit] = ???
```

What we've expressed here is that when `run` runs, it either fails and `Failed` can give us the reason for the failure.
Or it worked and there's nothing more to say (`Unit`).

We're now going to try this out and mess it up.

Maybe we want to write a file, and then log that we did so.
(Or write a file, and write the meta data for the file in a database. Or...
any two methods you like with this type signature).

```scala
def write(): Either[Failed, Unit] = {
  Right( () ) // Success
}

def log(): Either[Failed, Unit] = {
  Left(Failed("during log"))
}
```

In these placeholder implementations the `write` always succeeds and the `log` always fails.

## Unexpected compilation success

When it comes to using these methods we need to take care.
This code block compiles but is wrong:

```scala
// Buggy
def run(): Either[Failed, Unit] =
 write().map(_ => log())
}
```

We have incorrectly used `map`, when we should have used `flatMap`.

The `map` method expects a `Unit => T` argument, and we've given it a `Unit => Either[Failed,Unit]`.
This is fine: as `write` is an `Either[Failed,Unit]`,
the result of `map` looks like it should be
`Either[Failed,Either[Failed,Unit]]`.
Indeed, if you run that line of code in the REPL it is `Right(Left(Failed("during log")))`.

What's perhaps surprising is that this result (`Either[Failed, Either[Failed,Unit]]`) does not match the `Either[Failed,Unit]` signature on `run`.
It seems like this should be a compile error, or a warning, indicating our mistake.
But this code does compile without error or warning.

The result of `run` is `Right(())`, signalling to us that all was well with the computation,
even though we know the `log` failed.

We have just met "value discarding".

## Value Discarding

[Section 6.26.1][vd] of the Scala Language Specification defines value discarding:

> If _e_ has some value type and the expected type is `Unit`, _e_ is converted to the expected type by embedding it in the term `{ e; () }`.

To illustrate this, when we type...

```scala
val r: Either[Failed,Unit] =
  Right(()).map(_ => Left(Failed("boom")))
```

...the compiler will treat this as:

```scala
val r: Either[Failed,Unit] =
  Right(()).map(_ => { Left(Failed("boom")); () } )
```

We can simplify the example further. As the `Left[Failed]` value is discarded,
we can put anything we want there. Let's throw in an `Some[Int]` for the hell of it:

```scala
scala> val r: Either[Failed,Unit] = Right(()).map(_ => Some(1) )
r: scala.util.Either[Failed,Unit] = Right(())
```

Note that this is happening because we've used `Unit` as our target type.
If you look at the definition of `Either`...

```scala
// Much simplified
sealed abstract class Either[+A, +B] {
 def map[Y](f: B => Y): Either[A, Y] = ???
}
```

...it's reasonably clear that `Y` has to be `Unit` because we know best and we've said the result is `Either[Failed, Unit]`.

Without annotating the result the compiler would not trigger value discarding,
and would infer the type we expect:

```scala
scala> Right(()).map(_ => Some(1))
res1: scala.util.Either[Nothing,Some[Int]] = Right(Some(1))
```

## Turn on the warnings

There are some situations where the compiler will give you a hint that something is amiss.
If you have a simple expression, the compiler will warn you:

```scala
val r: Either[Failed,Unit] = Right(()).map(_ => 1)
warning: a pure expression does nothing in statement position
       val r: Either[Failed,Unit] = Right(()).map(_ => 1)
                                                       ^
```

For a more general way to detect value discarding there is a better compiler flag:

```
scalacOptions ++= Seq(
  "-Ywarn-value-discard",
  "-Xfatal-warnings"
)
```

If you can turn on that warning (and optionally make it fatal),
you will catch the kind of problem we illustrated:

```
[error] main.scala:18: discarded non-Unit value
[error]    write().map(_ => log())
[error]                        ^
```

We suggest turning this flag on by default if you can.

### Alternative encodings

If for some reason your project can't turn on that warning,
you can a look at alternative encodings of "side effect with no result".

For example:

```scala
sealed trait Success
object success extends Success {
  override def toString: String = "success"
}

def write(): Either[Failed, Success] = {
  Right(success)
}

def log(): Either[Failed, Success] = {
  Left(Failed("in log"))
}
```

We're now using a case object to flag a happy outcome.
As this is not `Unit`, value discarding will not come into play,
and our mix up with `map` can't happen:

```scala
// Hurrah! Won't compile
def run(): Either[Failed, Success] = {
  write().map(_ => log())
}

error: type mismatch;
 found   : scala.util.Either[Failed,Success]
 required: Success
         write().map(_ => log())
                             ^
```

But that's just if you cannot turn on the discarded values warning.

## Summary

Be aware of value discarding, and turn on `-Ywarn-value-discard` by default.
Check out [tpolecat's Scalac flags post](https://tpolecat.github.io/2014/04/11/scalac-flags.html) for other recommended options.

If you can't turn on the flag, and are stumbling into issues around value discarding,
try an alternative encoding.

If you have better ways to encode computations with no value,
please do share them in the comments below this post.



