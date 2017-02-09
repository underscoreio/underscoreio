###The Free Monad with Multiple Algebras

The `Free` Monad has required me to read through several posts several time before it began to sink in at all. More than once I have abandoned my attempts before I fully grasped it. As a result it remained something mysterious in my mind.
(Incidentally, one of my mistakes was to try to read too much into the word "free", polluting my mind with preconceptions of what "freedom" was meant to look like!)

There are several good posts about it, and Cats makes it easy to use it, but I concluded that I needed to look under the surface a little bit in order to really comprehend what was happening.

For an overview of `Free` in general, please see any of the good posts given as references at the end. In this post in particular, I will have a look at the machinery that makes it possible to use `Free` with more than one algebra at once.

The usual scenario with the `Free` monad is that of constructing DSLs, representing computations as immutable values and separating their execution into a separate structure known as an interpreter.

It's not so uncommon in functional programming to find ourselves reifying the steps of a procedure or computation in order to represent them without actually executing them.
We would normally represent these steps, or actions, as an algebraic data type (here chosen to be very simple):
```scala
sealed trait Action[A] // parameterised on return type
case class ReadData(port: Int) extends Action[String]
case class TransformData(data: String) extends Action[String]
case class WriteData(port: Int, data: String) extends Action[Unit]
```
As they are at the moment, we can't compose these without modification. If this 'instruction set' was a monad however, we could sequence instructions in a `for` comprehension, for example.
It turns out that a practical way of achieving this is by wrapping these types into the `Free` monad.
In Cats, we can 'lift' a type constructor into the `Free` monad with `Free.liftF`.
Let us write a little bit of boilerplate to help us do that:
```scala
object ActionFree {
  def readData(port: Int): Free[Action, String] = Free.liftF(ReadData(port))
  def transformData(data: String): Free[Action, String] = Free.liftF(TransformData(data))
  def writeData(port: Int, data: String): Free[Action, Unit] = Free.liftF(WriteData(port, data))
}
```
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

####Multiple DSLs

The interesting part is yet to come.
One of the main attractions of going down this avenue is the possibility of mixing 'instruction sets' and still getting them to compose.
For example, imagine that in the example above we wanted to have some other actions, say `EncryptData` and `DecryptData`. We would need these new case classes to be a subtypes of `Action` for it to fit in. But this would mean modifying and recompiling the code, and this may not be an option (if the original `Action` is part of a library over which we have no control) or may not be a good idea (for code architecture/organisation reasons).
There's no common supertype, either, that we can take advantage of. What can we do, then?

Let's imagine having `EncryptData` and `DecryptData` in a completely separate ADT, with no ties to `Action`:
```scala
trait AdvancedAction[A]
case class EncryptData(key: String) extends AdvancedAction[String]
case class DecryptData(key: String) extends AdvancedAction[String]
```
We are not concerning ourselves at all about how any of these operations will be executed in practice. That will be the job for the _interpreter_ of our DSL. We simply want to _represent_ them.

If we wanted to make use of operations from both `Action[A]` and `AdvancedAction[A]`, Cats offers a `Coproduct` type we can use, which is roughly an `Either` but for higher kinded types. The idea is to use this to 'merge' the two algebras into a common type.

```scala
type ActionOrAdvanced[A] = Coproduct[Action, AdvancedAction, A]
```

We would like to use the newly-defined `ActionOrAdvanced` in place of either `Action` alone or `AdvancedAction` alone. At least in principle, this should work and give us a way to do what we want.
We would end up with `Free` instances of type `Free[ActionOrAdvanced, A]`.

But how would it work in practice?

If you've been reading other posts on this subject, this is the point where, usually, the word "inject" starts to appear, requiring an act of faith on the part of any readers who haven't encountered it before, and quite possibly at the same point their ability to follow what's going on may begin to waver.

What follows here, then, is an exploration of the type-level workings of this solution, which are, in the blogger's opinion, very clever and interesting.

####Coproduct Basics

Before getting too far ahead, let's have a look at how `Coproduct` works, to get familiar with it.
Let's take this example:
```scala
type MyCoproduct[A] = Coproduct[List, Option, A]
```
Now, assuming I have a `List`, how do I 'put it' inside a coproduct?
Like this:
```scala
val c1: MyCoproduct[Int] = Coproduct.leftc(List(1,2,3))
// c1 = Coproduct(Left(List(1, 2, 3)))
```
Similarly if I have an `Option` instead:
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

Let's envision a typeclass that, given a type and a coproduct, 'knows' how to correctly lift it to the coproduct level.

####Inject

Let's introduce a typeclass, `Inject`, defined thusly:

```scala
trait Inject[F[_], G[_]] {
  def inj[A](fa: F[A]): G[A]
}
```
(N.B. The code above is a simplification of the actual library code available in `cats`.)

If an `Inject` instance exists for `F` and `G`, then we have a way of transforming an `F[A]` into a `G[A]`.
Stated this way, this seems overly general and in fact the concept seems to overlap with natural tranformations. But let's think of it in the more specific context of our need to 'put things inside coproducts'. If `F` was our DSL, such as `Action`, and `G` was `Coproduct[...,...,?]`, we can think of `Inject` as a way of injecting types into suitable coproducts. 
Is it possible to come up with a way to automatically derive an instance of `Inject` so that stuffing our `Coproduct` types happened by magic?

#####Left Hand
Let's start by examining the case where `F` is our DSL and `G` is a coproduct with our desired type `F` on the left-hand side. That is, `G[A]` is `Coproduct[F,X,A]`, that is to say, a coproduct with our desired type on the left hand side. Then, writing an instance for this case is as simple as calling `leftc` as we did in the examples earlier:

```scala
implicit def injectCoproductLeft[F[_], X[_]]: Inject[F, Coproduct[F, X, ?]] =
  new Inject[F, Coproduct[F, X, ?]] {
    def inj[A](fa: F[A]): Coproduct[F, X, A] = Coproduct.leftc(fa)
  }
```

The above will work for any `X` and so the left-hand problem is solved.

#####Right Hand
At this point we could do the same with the right-hand side of the coproduct and end up with enough tools in our box to automatically (i.e. by implicit provision of `Inject` instances) handle simple two-way coproducts appropriately.
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
Don't worry though, this code is already in Cats and we won't actually have to write it ourselves.

####Finishing up

Now, back to our multiple DSLs, then.
We have seen how to lift a single type constructor to the `Free` monad:
```scala
def readData(port: Int) = Free.liftF[Action, String](ReadData(port))
```
What if instead we had a coproduct `Cop[A]`, which contains `Action` and possibly other algebras?
We don't need to know the exact structure of `Cop`. We can simply call:
```scala
def readData(port: Int): Free[Cop, String] = Free.inject[Action, Cop](ReadData(port))
```
We haven't seen the method `Free.inject` before, but `Free.inject[F, Cop]` is simply shorthand for:
1. implicitly resolving an instance of `Inject[F, Cop]`,
2. using it to inject `F[A]` into `Cop[A]`, and finally
3. lifting `Cop[A]` into the `Free` monad.

In fact, the `Inject` mechanism is more general and in theory doesn't seem to be limited to injecting into coproducts, but this has to be the original and main use.

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

####Conclusion
I hope the post above is not seen as containing gratuitous detail. For me, looking at the underlying mechanism for injecting different algebras into the `Free` monad allowed me to understand it much better than if I hadn't done so.
In addition, I feel that stopping and prying apart type tricks such as these adds to my repertoire and makes it easier to spot and recognise similar techniques in code I may encounter in the future.

####References
On `Free`:
-  [Free Monads Are Simple](http://underscore.io/blog/posts/2015/04/14/free-monads-are-simple.html), by Noel Welsh
-  [Understanding Free Monads](http://perevillega.com/understanding-free-monads) by Pere Villega
-  [Overview of free monad in cats](https://blog.scalac.io/2016/06/02/overview-of-free-monad-in-cats.html) by Krzysztof Wyczesany

On injector classes:
- [Data types à la carte](http://www.staff.science.uu.nl/~swier004/publications/2008-jfp.pdf) by Wouter Swierstra

