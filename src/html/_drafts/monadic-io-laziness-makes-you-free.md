---
layout: post
title: "Monadic IO: Laziness Makes You Free"
author: Noel Welsh
---

The use of laziness in monadic IO was something that took me a long time to grasp. It's particularly relevant to the free monad, which we have been covering in [recent][free-monad-interpreter] [posts][free-monad-deriving].

Understanding monads is a puzzle with many parts. Understanding the monad interface was easy enough for me, as I'd been programming in functional languages for a while when I first started exploring them, but I didn't get for a long time how they made IO operations pure. The answer is to add an extra wrinkle, usually glossed over in Haskell oriented sources, by making all IO actions lazy. Let's see what this means.

<!-- break -->

We start with a very simple Scala program.

~~~ scala
println("Monads are da bomb!")
~~~

We now that `println` is impure, meaning it breaks substitution. We can't substitute a call to `println` with the result of that call (`()`) without changing the semantics of our program. This is in contrast to pure programs, such as `1 + 2 + 3`, which we can freely substitute.

Concretely

~~~ scala
println("Monads are da bomb!")
~~~

is not equivalent to

~~~ scala
()
~~~

whereas

~~~ scala
1 + 2 + 3
~~~

is equivalent to

~~~ scala
6
~~~

Our goal is transform `println` so it returns something that does allow for substitution. I've already hinted we need a monad. But how exactly should this monad be implemented? The solution comes back to the idea we talked about when [introducing the free monad][free-monad-interpreter]: separate the representation and the interpreter.

What we're going to do is make `println` return an action that, when we run it, really does the printing. An implementation like this will do:

~~~ scala
object Pure {
  def println(msg: String) =
    () => Predef.println(msg)
}
~~~

`Predef.println` is the "real" `println` that prints to the console. Our implementation, within `Pure`, returns a function of no arguments (a thunk) that calls the real `println` when applied. We can freely substitute calls to `Pure.println` with the result of calling `Pure.println`. In other words

~~~ scala
Pure.println("Monads are da bomb!")
~~~

is equivalent to

~~~ scala
() => Predef.println("Monads are da bomb!")
~~~

There are two things we need to sort out for this to be a useful representation:

- we need to somehow tie together our uses of `println` so we don't just have thunks randomly littered throughout our code; and
- at some point we must actually run these thunks to print stuff out.

How can we tie together these thunks? Define a monadic API for them! I recommend undertaking this exercise yourself. It's a bit more subtle than I thought it would be; the main issue is defining `flatMap` without running actions prematurely. Here's my solution:

~~~ scala
object Pure {
  sealed trait IO[A] {
    def flatMap[B](f: A => IO[B]): IO[B] =
      Suspend(() => f(this.run))

    def map[B](f: A => B): IO[B] =
      Return(() => f(this.run))

    def run: A =
      this match {
        case Return(a) => a()
        case Suspend(s) => s().run
      }
  }
  final case class Return[A](a: () => A) extends IO[A] 
  final case class Suspend[A](s: () => IO[A]) extends IO[A]

  object IO {
    def point[A](a: => A): IO[A] =
      Return(() => a)
  } 

  def println(msg: String): IO[Unit] =
    IO.point(Predef.println(msg))
}
~~~

and an example showing it's use

~~~ scala
object Example {
  val io =
    for {
      _ <- Pure.println("Monads are da bomb!")
      // Do some pure work
      x = 1 + 2 + 3
      _ <- Pure.println("All done. Home time.")
    } yield x

  def run =
    io.run
}
~~~

The key problem, as I mentioned above, is implementing `flatMap`. With an object of type `IO[A]`, and a function of type `A => IO[B]`, it seems that we must run the `IO[A]` to get the `A` to apply to the function. However, once we run actions we break substitution. The solution is to introduce a separate case to our algebraic data type to represent a call to `flatMap` without actually running anything. This is the `Suspend` case in my implementation.

Avid readers of the blog will recognise that this is almost exactly the algebraic data type we used when [deriving the free monad][free-monad-deriving]! That's no accident. The free monad is all about [separating the structure of the computation from the interpreter that gives it meaning][free-monad-interpreter]. *We are doing exactly the same thing here.* The structure of the computation is represented by the algebraic data type, and we give meaning to the structure when we `run` it.

There are a few lessons we can draw from this.

This trick of delaying actions is very useful. It's the same implementation technique used in Scalaz's [`Task`] (a better alternative to `Future`) and in the free monad.

We can't maintain substitution after we run our IO actions. The way Haskell handles the `IO` monad is to only allow the runtime to run it (with the exception, I believe, of `unsafePerformIO`). Therefore all programs are pure from the programmer's point of view. In Scala we just have to be careful to separate the two phases so we don't try to use substitute actions after they've been run.

The idea of representing actions as data is very general. I've tried this point in depth in the [prior post][free-monad-interpreter] introducing the free monad. We've seen another example here. We're also seeing the same implementation pattern come up again. So as a general point, if you find yourself implementing some monad variant and you don't want to use the free monad, you probably need an algebraic data type like the one we used here.

Finally, we can derive a useful lesson about monad composition in the free monad. If you know about monad transformers, you'll know they are one approach to composing monads. The free monad offers another, via the [a la carte][a-la-carte] technique. However, I find it best to only encode IO actions within the free monad, which are the only actions we need to delay. This leaves other monads, such as `Option`, outside the free monad. This means occasionally seeing nested `for` comprehensions but I find it simpler and more performant to work this way. Now I must admit I'm fairly new to the free monad so my opinion might change over time.

[free-monad-interpreter]: {% post_url 2015-04-14-free-monads-are-simple %}
[free-monad-deriving]: {% post_url 2015-04-23-deriving-the-free-monad %}
[`Task`]: http://docs.typelevel.org/api/scalaz/nightly/#scalaz.concurrent.Task
[a-la-carte]: http://www.cs.ru.nl/~W.Swierstra/Publications/DataTypesALaCarte.pdf
