---
layout: post
title: "The Free Monad with Multiple Algebras"
author: "Danielle Ashley"
---

In this post I will look at the machinery that makes it possible to use `Free` with more than one algebra at once: `Coproducts` and the `Inject` type class.
This technique was first described in the paper [Data types à la carte][a-la-carte], and [Cats][cats] and other libraries provide implementations.
However we're going to build our own implementation in this post, so we understand how it all works.
I'm going to assume you understand `Free` at a basic level.
If not, there are [several][free-simple] [good][understanding-free] [posts][overview-free-cats] that introduce the concept.

<!-- break -->

The usual scenario with the `Free` monad is that of constructing DSLs, representing computations as immutable values and separating their execution into a separate structure known as an interpreter.

It's not so uncommon in functional programming to find ourselves reifying the steps of a procedure or computation in order to represent them without actually executing them.
We would normally represent these steps, or actions, as an algebraic data type, without necessarily providing an implementation at the same time.
Here is a very simple example of a set of operations represented in this way:

```scala
sealed trait Action[A] // parameterised on return type
case class ReadData(port: Int) extends Action[String]
case class TransformData(data: String) extends Action[String]
case class WriteData(port: Int, data: String) extends Action[Unit]
```
Note how none of the types above have implementations, they are purely descriptive.
So, what good is it?
It starts to look more useful when we imagine being able to sequence these things and compose them into other actions, using them as building blocks of bigger abstract 'programs'. (The obvious example here would be sequencing `ReadData` and then `TransformData` and then `WriteData` into a combined action)
As they are at the moment, though, we can't compose these directly; right now we have defined no mechanism to allow it. We could go and write some methods on `Action` for this purpose, but there is a more general way: if this 'instruction set' was a monad, we could sequence instructions in a `for` comprehension, for example.
And there is no need to make `Action` a monad 'manually', either: a practical way of achieving the same is by wrapping these types into the `Free` monad.
(For a more general discussion of `Free` please see any of the references to this post. For now, we'll just use it in a practical context to lead us to the next topic, multiple algebras.)

In Cats, the `Free` monad is already defined for us, and we can 'lift' a type constructor into the it with `Free.liftF`.
Let us write a little bit of boilerplate to help us do that:
```scala
object ActionFree {
  def readData(port: Int): Free[Action, String] = Free.liftF(ReadData(port))
  def transformData(data: String): Free[Action, String] = Free.liftF(TransformData(data))
  def writeData(port: Int, data: String): Free[Action, Unit] = Free.liftF(WriteData(port, data))
}
```
The general pattern above is to turn an `F[A]` into a `Free[F, A]` so we have access to the monadic operations such as `flatMap` provided by `Free`.
Now we can do this:
```scala
import ActionFree._
val program = for {
  d <- readData(123)
  t <- transformData(d)
  _ <- writeData(789, t)
} yield ()
// program: Free[Action, Unit]
```
We can then take `program` and in turn compose it with other structures with the same signature.

(Note that in the convenience methods defined in `ActionFree`, we ensure that the resulting instances of `Free` are of type `Free[Action, A]` rather than allowing the compiler's type inference to narrow them excessively and end up with a too-specific `Free[ReadData, A]` which wouldn't compose with e.g. `Free[WriteData, A]`.)

#### Multiple DSLs

The interesting part is yet to come.
One of the main attractions of going down this avenue is the possibility of mixing 'instruction sets' and still getting them to compose.

Back to our example, we want to do more with data besides reading, writing and 'transforming' it. We want to add the following operations:

```scala
case class EncryptData(key: String)
case class DecryptData(key: String)
```

But let's assume that we can't just make them subclasses of `Action`, because `Action` is a `sealed` trait in a library over which we have no control (or for other good conceptual or architecture reasons).
Whatever the reason, imagine that this is how we end up writing them:

```scala
trait AdvancedAction[A]
case class EncryptData(key: String) extends AdvancedAction[String]
case class DecryptData(key: String) extends AdvancedAction[String]
```

`Action` and `AdvancedAction` are separate data types. They have no meaningful common supertype. How can we group them so we can build programs from commands of each type?

(Let's remind ourselves that we're not concerned with how any of these combined operations will be executed in practice. We simply want to find a suitable _representation_ for them. Executing will be the job of the _interpreter_ of our DSL.)

If we wanted to make use of operations from both `Action[A]` and `AdvancedAction[A]`, Cats offers a `Coproduct` type we can use, which is roughly an `Either` but for higher kinded types. The idea is to use this to 'merge' the two algebras into a common type.

```scala
type ActionOrAdvanced[A] = Coproduct[Action, AdvancedAction, A]
```

We would like to use the newly-defined `ActionOrAdvanced` in place of either `Action` alone or `AdvancedAction` alone. At least in principle, this should work and give us a way to do what we want.
We would end up with `Free` instances of type `Free[ActionOrAdvanced, A]`.

But how would it work in practice?

If you've been reading other posts on this subject, this is the point where, usually, the word "inject" starts to appear, requiring an act of faith on the part of any readers who haven't encountered it before, and quite possibly at the same point their ability to follow what's going on may begin to waver.
So, let's look at `Coproduct` and `Inject` in more detail to find out how they work, as they rely on a very interesting type-level mechanism.

#### Coproduct Basics

Before getting too far ahead, let's have a look at how `Coproduct` works, to get familiar with it.
Let's take this example:
```scala
type MyCoproduct[A] = Coproduct[List, Option, A]
```
A reminder that the above is akin to saying `Either[List[A], Option[A]]` _for any `A`_.

Now, assuming I have a `List`, how do I 'put it' inside a coproduct?
Like this:
```scala
val c1: MyCoproduct[Int] = Coproduct.leftc(List(1,2,3))
// c1 = Coproduct(Left(List(1, 2, 3)))
```
Similarly if I have an `Option`:
```scala
val c2: MyCoproduct[Int] = Coproduct.rightc(Some(5))
// c2 = Coproduct(Right(Some(5)))
```
So, as per the original definition of `MyCoproduct`, `List` is left, `Option` is right, and everything makes sense. If I try it any other way, it predictably fails:
```scala
// trying to put an Option on the left
val c3: MyCoproduct[Int] = Coproduct.leftc(Some(7))
// Error: type mismatch
// found   : Some[Int]
// required: List[Int]
```

Let's apply this to our DSL example. One possibility would be to directly use `leftc` and `rightc` in the convenience methods that create the `Free` instances we need:
```scala
object NaiveActionFree {
  def readData(port: Int): Free[ActionOrAdvanced, String] = Free.liftF[ActionOrAdvanced, String](Coproduct.leftc(ReadData(port)))
  //...
}
```
We would then do a similar thing for the case classes of `AdvancedAction`
Note, though, that in so doing we are tied to the particular coproduct we are choosing to use at the moment: first of all, we mention it by name (in the type arguments to `liftF`) and we rely on the knowledge that in it, `ReadData` is on the left side (otherwise it wouldn't compile).
This in turn means that if we want to use another type of coproduct, i.e. another mix of DSLs (it's easy to imagine wanting to add more instructions later!), the code snippet above (and all of the convenience methods thus defined) will have to be scrapped and rewritten.
Nobody likes doing that, so is there a more automatic solution?

#### Inject

Let's envision a typeclass that, given a type and a coproduct, 'knows' how to correctly lift it to the coproduct level.
Introducing `Inject`, defined thusly:

```scala
trait Inject[F[_], G[_]] {
  def inj[A](fa: F[A]): G[A]
}
```
(N.B. The code above is a simplification of the actual library code available in `cats`.)

`Inject` is a type class that allows us to embed one algebra within another.
An instance of `Inject[Action, ActionOrAdvanced]`, for example, allows us to "lift" instances of `Action` to type `ActionOrAdvanced`.

(As an aside, you may notice that `Inject` has the same type structure as a natural transformation. This is no coincidence: in a sense, an instance `Inject[F, G]` allows us to "interpret" instances of `F` as `G`. However, the similarity is effectively academic.
In practice we use `Inject` to embed algebras in coproducts and `~>` to interpret them to meaningful results.)

Is it possible to come up with a way to automatically derive an instance of `Inject` so that stuffing our `Coproduct` types happened by magic?

##### Left Hand
Let's start by examining the case where `F` is our DSL and `G` is a coproduct with our desired type `F` on the left-hand side. That is, `G[A]` is `Coproduct[F,X,A]`, that is to say, a coproduct with our desired type on the left hand side. Then, writing an instance for this case is as simple as calling `leftc` as we did in the examples earlier:

```scala
implicit def injectCoproductLeft[F[_], X[_]]: Inject[F, Coproduct[F, X, ?]] =
  new Inject[F, Coproduct[F, X, ?]] {
    def inj[A](fa: F[A]): Coproduct[F, X, A] = Coproduct.leftc(fa)
  }
```

The above will work for any `X` and so the left-hand problem is solved.

##### Right Hand
We could do the same with the right-hand side of the coproduct and end up with enough tools in our box to automatically (i.e. by implicit provision of `Inject` instances) handle simple two-way coproducts appropriately.
But we can do better.
If we wanted 'three-way coproducts' or more, it is possible to define them by nesting them:
```scala
Coproduct[F1, Coproduct[F2, F3, ?], ?] // 3-way
Coproduct[F1, Coproduct[F2, Coproduct[F3, F4, ?], ?], ?] // 4-way
// ...
```
And we can _still_ derive automatically `Inject` instances that work with these extended coproducts.
As long as the 'nested coproduct' is in the right-hand position, at least.
This is because we define the `Inject` instance for the right-hand side like this:
```scala
implicit def injectCoproductRight[F[_], R[_], X[_]](implicit I: Inject[F, R]): Inject[F, Coproduct[X, R, ?]] =
  new Inject[F, Coproduct[X, R, ?]] {
    def inj[A](fa: F[A]): Coproduct[X, R, A] = Coproduct.rightc(I.inj(fa))
  }
```
Note that, unlike the left-hand case earlier, we don't try to match the case where `F` itself is in the right-hand position. Rather, we identify the right-hand as another type constructor (`R`), about which we know nothing, except that _we demand, as an implicit argument, proof that we are able to inject `F` into it_. Which we then use to do exactly that.
So, if this additional implicit `I: Inject[F, R]` can be found, we are done and the right-hand case also ties up. It boils down to how we get that proof, i.e. that additional `Inject[F, R]` instance we require.
- Case 1:
`R` is another coproduct with `F` on its left-hand side. We know how to handle this case: we've written it earlier (`injectCoproductLeft`).
- Case 2:
`R` is another coproduct with `F` on its right-hand side. In this case `injectCoproductRight` will be called recursively again and we'll be back at this point!
- Case 3:
`R` is actually `F` itself. in other words, the type that we were trying to inject is the same type as what's in the right-hand side of the coproduct. In this case we're looking for an `Inject[F, F]`, which will be trivial to write:
```scala
implicit def injectReflexive[F[_]]: Inject[F, F] =
  new Inject[F, F] {
    def inj[A](fa: F[A]): F[A] = fa
  }
```
- And what if there is a Case 4, which is to say, `R` is something else entirely? Then the implicit resolution will fail, as is reasonable to expect, as we can't put something into a coproduct that doesn't have it as its options!

With these three implicit instances of `Inject` (the left, right and reflexive) we are able to automatically derive mechanisms to inject any desired type into any coproduct that contains it.
Don't worry though, all of these implicits are already in Cats and we won't actually have to write them ourselves.

#### Finishing up

Back to our multiple DSLs.
We have seen how to lift a single type constructor to the `Free` monad:
```scala
def readData(port: Int) = Free.liftF[Action, String](ReadData(port))
```
What if instead we had a coproduct `Cop[A]`, which is a coproduct of `Action` and other algebras?
We don't need to know the exact structure of `Cop`. We can simply call:
```scala
def readData(port: Int): Free[Cop, String] = Free.inject[Action, Cop](ReadData(port))
```
`Free.inject[F, Cop]` is simply shorthand for:
1. implicitly resolving an instance of `Inject[F, Cop]`,
2. using it to inject `F[A]` into `Cop[A]`, and finally
3. lifting `Cop[A]` into the `Free` monad.

So, let's bring our mind back to those convenience methods we defined at the start, to lift those `Action`s into `Free`:
```scala
object ActionFree {
  def readData(port: Int): Free[Action, Int] = Free.liftF(ReadData(port))
  def transformData(data: String): Free[Action, Int] = Free.liftF(TransformData(data))
  def writeData(port: Int, data: String): Free[Action, Unit] = Free.liftF(WriteData(port, data))
}
```
Let's generalise them with what we have learnt. We'll no longer have a static object but a class with a type parameter:
```scala
class ActionFree[C[_]](implicit inject: Inject[Action, C]) {
  def readData(port: Int): Free[C, String] = Free.inject[Action, C](ReadData(port))
  def transformData(data: String): Free[C, String] = Free.inject[Action, C](TransformData(data))
  def writeData(port: Int, data: String): Free[C, Unit] = Free.inject[Action, C](WriteData(port, data))
}
```

The `C` type parameter is the coproduct definition we use, and we can change it easily if we need to.
We could swap the terms, from `Coproduct[Action, AdvancedAction, ?]` to `Coproduct[AdvancedAction, Action, ?]` or we could add more, like `Coproduct[Action, Coproduct[AdvancedAction, AdminAction, ?], ?]`, and the implicit resolution of `inject` would still find the correct `Inject` instance to deal with it.

#### Conclusion
In this post we discussed the implementation of `Free` in Cats. We went into a lot of depth about the implementation of `Coproduct` and `Inject`, and their application to mixing free algebras. I found this detail useful when trying to understand `Free`. I hope you found it useful as well.

#### References
On `Free`:
-  [Free Monads Are Simple][free-simple], by Noel Welsh
-  [Understanding Free Monads][understanding-free] by Pere Villega
-  [Overview of free monad in cats][overview-free] by Krzysztof Wyczesany

On injector classes:
- [Data types à la carte][a-la-carte] by Wouter Swierstra


[a-la-carte]: http://www.staff.science.uu.nl/~swier004/publications/2008-jfp.pdf
[cats]: http://typelevel.org/cats/
[free-simple]: http://underscore.io/blog/posts/2015/04/14/free-monads-are-simple.html
[understanding-free]: http://perevillega.com/understanding-free-monads
[overview-free-cats]: https://blog.scalac.io/2016/06/02/overview-of-free-monad-in-cats.html 
