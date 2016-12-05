---
layout: post
title:  Error Handling Without Throwing Your Hands Up
author: Jonathan Ferguson
---

Error handling is an issue that often comes up in our reviews.
Different programs have different goals with respect to error handling.
In a simple script it might be acceptable to just crash if an error occurs.
The techniques we are showing here are for high reliability programs,
where we want to ensure we handle a selected set of errors.

 <!-- break -->

We have some example code below using an idiomatic Java way of handling invalid input
--- throwing exceptions.
The issue with treating invalid input in this manner is it breaks type-safety.
Given the type signature `List[Int] => FavouriteNumbers`
there is no way of telling that it may throw an exception.
Another way of saying this is the methods are partially defined on their inputs.
That is, there isn't a valid return value for all input values.[^1]

This issue mean we can not reason about the methods,
which increases our cognitive load.

{% highlight scala %}
// Java Style - avoid this
// List with a minimum length
final case class FavouriteNumbers(l: List[Int]) {
 require(l.nonEmpty)
}

// Integer only valid with in a given range
sealed trait Angle { val degrees: Int }
final case class Perpendicular(degrees:Int) extends Angle {
  require(degrees == 90)
}

final case class Straight(degrees:Int) extends Angle {
  require(degrees == 180)
}

final case class Acute(degrees: Int) extends Angle {
  if (degrees > 0 || degrees < 90)
  throw new IllegalArgumentException(
    s"degrees needs to be between 0 and 90, $degrees is invalid.")
}

final case class Obtuse(degrees: Int) extends Angle {
  assert(degrees > 90 || degrees < 180)
}

final case class Reflex(degrees: Int) extends Angle {
  assume(degrees > 180 || degrees < 360,
    s"degrees must be between 180 & 360 degrees")

{% endhighlight %}


The solution is to encode the [invariants](http://en.wikipedia.org/wiki/Invariant_(computer_science)) into the type system.
This means we move the validation of input into the types themselves,
meaning we can only create valid instances.
As a result, the compiler,
rather than the runtime,
will inform us if we attempt to instantiate an object with bad data.

### How can we achieve this?

The requirement for `FavouriteNumbers` is the input is a list that must contain at least one element.
[Scalaz](https://github.com/scalaz/scalaz) has just the thing we need --- `NonEmptyList[T]`.
As its name suggests it's a list that is guaranteed to be non-empty.
We can rewrite `FavouriteNumbers` as:

{% highlight scala %}
final case class FavouriteNumbers(l: NonEmptyList[Int])
{% endhighlight %}


Creating an `Angle` can either succeed (with an `Angle`) or fail (with an error message).
Scala provides what we need in the type [`Either`](http://www.scala-lang.org/api/current/#scala.util.Either).
The value of `Either` must be an instance of `Left` or `Right`.
By convention `Left` is used for failure and `Right` for success.
In our case a we fail with a `String` or succeed with an `Angle`, giving: `Either[String,Angle]`.

Rather than attempting to encode this for each of the classes implementing the trait,
we can make their constructors private and use a method on the companion object to enforce the requirements at instantiation.
Finally, there only ever needs to be a single instance of both `Perpendicular` and `Straight`
so let's make them case objects.

{% highlight scala %}
sealed trait Angle { val degrees: Int }
private final case object Perpendicular extends Angle { val degrees = 90 }
private final case object Straight extends Angle { val degrees = 180 }
private final case class Acute(degrees: Int) extends Angle
private final case class Obtuse(degrees: Int) extends Angle
private final case class Reflex(degrees: Int) extends Angle

object Angle {

  def apply(degrees: Int): Either[String,Angle] = degrees match {
    case _ if degrees == 90                  ⇒
      Right(Perpendicular)
    case _ if degrees == 180                 ⇒
      Right(Straight)
    case _ if degrees >= 0 && degrees < 90   ⇒
      Right(Acute(degrees: Int))
    case _ if degrees > 90 && degrees < 180  ⇒
      Right(Obtuse(degrees: Int))
    case _ if degrees > 180 && degrees < 360 ⇒
      Right(Reflex(degrees: Int))
    case _                                   ⇒
      Left(s"Invalid angle $degrees. Needs to be between 0 and 360.")
  }
}
{% endhighlight %}


We could use this same technique to improve our `FavouriteNumbers` example, instead of using the `NonEmptyList` type for the input.
This time using Scalaz's implementation of `Either`, called disjunction.
We can read the type of the [disjunction](http://scalaz.github.io/scalaz/scalaz-2.10-7.0.3/doc/index.html#scalaz.$bslash$div) just as we read `Either`'s.
`String \/ Angle` is the same as `Either[String,Angle]`

{% highlight scala %}
object FavouriteNumbers {

  def apply(l: List[Int]): String \/ FavouriteNumbers = l match {
    case x :: xs ⇒ FavouriteNumbers(NonEmptyList.nel(x, xs)).right
    case Nil     ⇒ "Need at least 1 favourite number".left
  }
}
{% endhighlight %}

Scalaz also offers the sugar of `.right` and `.left`, which is nice.
In the examples above we are using a `String` as the error type; normally we would use a richer type.

### Handling failure

We now need to explicitly tell the compiler how we want to handle failure.
There are two typical ways to do this.
First, we can transform a result to a common type using `fold`:

{% highlight scala %}
val a:Either[String,Angle] = ???
val failure:String => Int = _.length()
val success:Angle => Int = _.degrees

val result:Int = a.fold( failure, success)
{% endhighlight %}


Second, we can fail fast.
`map` ignores the failure case and applies the function only to the success case:

{% highlight scala %}
  val result:Either[String,Int] = a.map(success)
{% endhighlight %}


### Conclusions

We are now able to reason about our methods based on the type signatures.
They are no longer partially defined functions --- we now have a valid return value for all input values.
We are encoding the error into the type signature,
which forces the caller to think about and handle the failure case.
This allows the compiler to help us.

[^1]: It should be noted a partially defined function and a partial applied function are two quite different things. There is an excellent explaination on [Stack Overflow](http://stackoverflow.com/questions/8650549/using-partial-functions-in-scala-how-does-it-work).

