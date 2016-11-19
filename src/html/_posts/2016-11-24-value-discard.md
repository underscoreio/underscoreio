---
layout: post
title: "Value Discarding"
author: "Richard Dallaway"
---

Objective:

- Reminder about value discarding.
- In particular when encoding side effects that signal just success or failure, without a resulting value. I.e., unit
- example
- turn on the flag

[vd]: http://scala-lang.org/files/archive/spec/2.11/06-expressions.html#value-discarding
[ff]: link to fast fail blog post

<!- break ->

## Fast-fail side effects

If you're working with side-effects that might fail,
there are [various ways][ff] you can express that in Scala.
One way is to use `Either`:

TODO: flag we're using scala 2.12 Either

``` scala
import scala.util.{Either, Right, Left}

case class Failed(msg: String)

def run(): Either[Failed, Unit] = ???
```

That is, when `run` runs, it either fails and we have a reason for the failure.
Or it worked and there's nothing more to say.

For context, let's try to run two side effects.
Maybe we want to write a file, and then log that we have written the file.
(Or write a file, and write the meta data for the file in a database.
Any two methods you like with this type signature).

```scala
def write(): Either[Failed, Unit] = {
  Right( () ) // Pretend that worked
}

def log(): Either[Failed, Unit] = {
  Left(Failed("during log"))
}
```

In these placeholder implementations the `write` always succeeds and the `log` always fails.

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
Because `write` is an `Either`, we _might expect_ the result of the `map` to be
`Either[Failed,Either[Failed,Unit]]`.
If you run the code in the REPL, indeed it is `Right(Left(Failed("during log")))`.

As this does not match the `Either[Failed,Unit]` signature on `run`
we _might expect_ this to be a compile error, or a warning, indicating our mistake.

This code does compile without error or warning.
The result of `run` is `Right(())`, signalling to us that all was well with the computation,
even though we know the `log` failed.

We have just met value discarding.

## Value Discarding

[Section 6.26.1][vd] of the Scala Language Specification] defines value discarding:

> If _e_ has some value type and the expected type is `Unit`, _e_ is converted to the expected type by embedding it in the term `{ e; () }`.

TODO: expand and illustrate

TODO: why do we get no warning in our case?

```
scala> val r: Either[Int,Unit] = Right( () ).map( _ => 7 )
<console>:14: warning: a pure expression does nothing in statement position
       val r: Either[Int,Unit] = Right( () ).map( _ => 7 )
                                                       ^

scala> val r: Either[Int,Unit] = Right( () ).map( _ => Left(7) )
r: Either[Int,Unit] = Right(())
```

## Working with value discarding

### Turn on warnings

```
scalacOptions ++= Seq(
  "-Ywarn-value-discard",
  "-Xfatal-warnings"      
)
```


```
[error] main.scala:18: discarded non-Unit value
[error]    write().map(_ => log())
[error]                        ^
```

TODO: are there legitimate cases where you want value discarding?

TODO: Link to tpolecat's page of flags.

### Alternative encodings

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

def run(): Either[Failed, Success] = {
  write().map(_ => log()) // Hurrah! Won't compile
}
```

## Summary

- be aware of it
- turn on the flag
- if you're tripped up by this often, use an alternative encoding


