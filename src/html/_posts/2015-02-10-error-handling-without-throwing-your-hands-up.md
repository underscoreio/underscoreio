---
layout: post
title:  Error handling without throwing your hands up
author: Jonathan Ferguson
---

At Underscore we have been performing code reviews for customers and I thought I'd share a few of the findings.

In this post I'll focus on several examples where we can replace throwing an exception with encoding the possibility of failure in the return type. First, let's look at some examples based on common errors:

{% highlight scala %}
  //List with a minimum length
  final case class FavouriteNumbers(l: List[Int]) {
   require(l.nonEmpty)
  }

  // Integer only valid with in a given range
  sealed trait Angle { val degrees: Int }
  final case class Right(degrees:Int) extends Angle {
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
  }
{% endhighlight %}

The examples above all have an idiomatic Java way of handling invalid input --- throwing exceptions. There are two issues with treating invalid input in this manner. Firstly, they break type-safety. Given the type signature `List[Int] => FavouriteNumbers`, there is no way of telling that it may throw an exception. Secondly, they are partially defined on their inputs. That is, there isn't a valid return value for all input values.

It should be noted a partially defined function and a partial applied function are two quite different things. There is an excellent explaination on [Stack Overflow](http://stackoverflow.com/questions/8650549/using-partial-functions-in-scala-how-does-it-work).

These two issues mean we can not reason about the methods. This increases our cognitive load. The solution is to encode the [invariants](http://en.wikipedia.org/wiki/Invariant_(computer_science)) into the type system.

#### What does "encode the invariants into the type system" mean?

<!-- I DONT LIKE THE WORD VALIDATION -->
It means moving the validation of input data into the types themselves ---  we encode our requirements using types, rather than throwing exceptions. This means the compiler, rather than the runtime will inform us if we attempt to instantiate an object with bad data.

### How can we achieve this in the examples above?

First the requirement for `FavouriteNumbers` is that the input is a list that must contain at least one element.
 [Scalaz](https://github.com/scalaz/scalaz) has just the thing we need --- `NonEmptyList[T]`. As its name suggests it's a list which guarantees to be non-empty. So we can rewrite `FavouriteNumbers` as:

{% highlight scala %}
final case class FavouriteNumbers(l: NonEmptyList[Int])
{% endhighlight %}

Second `Angle` is only valid for a subset of the input type. Rather than attempting to encode this for each of the classes implementing the trait, we can make their constructors private and use a method companion object to enforce the requirements at instantiation:

{% highlight scala %}
sealed trait Angle { val degrees: Int }
private final case object Right extends Angle { val degrees = 90 }
private final case object Straight extends Angle { val degrees = 180 }
private final case class Acute(degrees: Int) extends Angle
private final case class Obtuse(degrees: Int) extends Angle
private final case class Reflex(degrees: Int) extends Angle

object Angle {

  def apply(degrees: Int): String \/ Angle = degrees match {
    case _ if degrees == 90                  ⇒
      Right.right
    case _ if degrees == 180                 ⇒
      Straight.right
    case _ if degrees >= 0 && degrees < 90    ⇒
      Acute(degrees: Int).right
    case _ if degrees > 90 && degrees < 180  ⇒
      Obtuse(degrees: Int).right
    case _ if degrees > 180 && degrees < 360 ⇒
      Reflex(degrees: Int).right
    case _ ⇒
      s"Invalid angle $degrees. Needs to be between 0 and 360.".left
  }
}
{% endhighlight %}

The first thing to note is that we have made `Right` and `Straight` case objects. There only ever needs to be a single instance of both.  Second is the return type of the companion object's `apply` method.  Which is `String \/ Angle`, this is another Scalaz type this time disjunction --- Scalaz' implementation of Scala's `Either`.

Disjunction allows us to encode an error into our types. This is useful when we are unable to encode our requirements using the type system. For example, we can not easily encode the requirement that the integer must be less than 360 in the type system. We can however signal to the caller that the method will return a type containing either an error message or the expected instance.

We can use this same technique to improve our first example:

{% highlight scala %}
object FavouriteNumbers {

  def apply(l: List[Int]): String \/ FavouriteNumbers = l match {
    case x :: xs ⇒ FavouriteNumbers(NonEmptyList.nel(x, xs)).right
    case Nil     ⇒ "Need at least 1 favourite number".left
  }
}
{% endhighlight %}

In the examples above we are using a `String` as the error type of the disjunction, normally we would use a richer type.

### Why are these code examples prefered to the original?

We are able to reason about the methods based on the type signatures. They are no longer partially defined functions --- we now have a valid return value for all input values. We are encoding the error into the type signature, which forces the caller to think about and handle the failure case.

This is allowing the compiler to help us. If we supply bad input values we will either get a compilation error as the type is incorrect, or a disjunction containing an error type.