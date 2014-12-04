---
layout: post
title:  Scala Enumerations
author: Richard Dallaway
date: '2014-09-03 08:00:00'
---

Should you use Scala's built in `scala.Enumeration` class, or roll your own sealed class objects?  The answer depends on which you value more: having a single lightweight class, or better type safety.

If you want to skip the detail, just know to use `scala.Enumeration` if you need to limit the number of classes; otherwise prefer case objects or classes.

<!-- break -->

The rest of this post describes:

* the problem with Enumeration;
* the benefits of Enumeration; and
* the alternatives you can use.

## What's the problem with scala.Enumeration?

> "Enumerations must D.I.E."
([thread on scala-internals mailing list](https://groups.google.com/forum/#!topic/scala-internals/8RWkccSRBxQ))

Here are the main criticisms I've seen of `scala.Enumeration` (which I'll mostly just refer to as Enumeration from now on):

1. Enumerations have the same type after erasure.
2. There's no exhaustive matching check during compile.
3. They don't inter-operate with Java's `enum`.

If 3 is your main concern, just use Java's `enum`s. You can mix Java and Scala source files in a project.

Points 1 and 2 deserve examples, so you can decide if you care about this behaviour or not.

First, if you want method overloading with different Enumerations, that's not going to work out:

{% highlight scala %}
scala> :paste
// Entering paste mode (ctrl-D to finish)

object Colours extends Enumeration {
  val Red, Amber, Green = Value
}

object WeekDays extends Enumeration {
  val Mon,Tue,Wed,Thu,Fri = Value
}

object Functions {
  def f(x: Colours.Value)  = "That's a colour"
  def f(x: WeekDays.Value) = "That's a weekday"
}


// Exiting paste mode, now interpreting.

<console>:19: error: double definition:
def f(x: Colours.Value): String at line 18 and
def f(x: WeekDays.Value): String at line 19
have same type after erasure: (x: Enumeration#Value)String
         def f(x: WeekDays.Value) = "That's a weekday"
             ^
{% endhighlight %}

Second, if you want to use Enumeration in pattern matching, you will not get a "match may not be exhaustive" warning:

{% highlight scala %}
scala> :paste
// Entering paste mode (ctrl-D to finish)

def traffic(colour: Colours.Value) = colour match {
 case Colours.Green => "Go"
}

// Exiting paste mode, now interpreting.

traffic: (colour: Colours.Value)String
{% endhighlight %}

Note: the compiler is happy to accept that, even though the function can fail at runtime with a `scala.MatchError`.

You may or may not care about those points.

## What is an Enumeration?

For me, I'd expect an Enumeration to not have the problems listed above. This is fine, because Scala allows me to look at enumerations another way, which we will see in a moment.

To understand `scala.Enumeration`, look at it with a different view:

> I really think that enums should be lightweight. One class (or even two) per value is not acceptable. If you are willing to pay that sort of price, it's not too burdensome to just define the case objects directly. Enums fill a different niche: essentially as efficient as integer constants but safer and more convenient to define and to use. ([Martin on the scala-internals mailing list](https://groups.google.com/d/msg/scala-internals/8RWkccSRBxQ/U4y0XpRJfdQJ))

Under that view, you can see how Enumeration gives you plenty of positives:

- Values have an automatic identifier, which is a consecutive integer.
- Values have an nice name, which you don't have to declare yourself.
- Enumerations have an order (`Mon < Tue` is `true`).
- You can iterate the members.
- You do not end up with a class per member.

Except for the last point, you can have everything via a sealed case objects.  This is why we say it's the key deciding point on using `scala.Enumeration` or not.

## Sealed case objects

The alternative can be as simple or as involved as you need it to be for your problem.

As an example, let's say you're happy building up the list of values yourself, don't care about order or automatic naming:

{% highlight scala %}
object WeekDay {
  sealed trait EnumVal
  case object Mon extends EnumVal
  case object Tue extends EnumVal
  case object Wed extends EnumVal
  case object Thu extends EnumVal
  case object Fri extends EnumVal
  val daysOfWeek = Seq(Mon, Tue, Wed, Thu, Fri)
}
{% endhighlight %}

That's a minimal example. You can then build anything extra you need. To illustrate, here's the Oracle Java [Planets enum example](http://docs.oracle.com/javase/tutorial/java/javaOO/enum.html) converted to this style:

{% highlight scala %}
object SolarSystemPlanets {

  sealed abstract class Planet(
    val orderFromSun : Int,
    val name         : String,
    val mass         : Kilogram,
    val radius       : Meter) extends Ordered[Planet] {

      def compare(that: Planet) = this.orderFromSun - that.orderFromSun

      lazy val surfaceGravity = G * mass / (radius * radius)

      def surfaceWeight(otherMass: Kilogram) = otherMass * surfaceGravity

      override def toString = name
  }

  case object MERCURY extends Planet(1, "Mercury", 3.303e+23, 2.4397e6)
  case object VENUS   extends Planet(2, "Venus",   4.869e+24, 6.0518e6)
  case object EARTH   extends Planet(3, "Earth",   5.976e+24, 6.3781e6)
  case object MARS    extends Planet(4, "Mars",    6.421e+23, 3.3972e6)
  case object JUPITER extends Planet(5, "Jupiter", 1.9e+27,   7.1492e7)
  case object SATURN  extends Planet(6, "Saturn",  5.688e+26, 6.0268e7)
  case object URANUS  extends Planet(7, "Uranus",  8.686e+25, 2.5559e7)
  case object NEPTUNE extends Planet(8, "Neptune", 1.024e+26, 2.4746e7)

  import EnumerationMacros._
  val planets: Set[Planet] = sealedInstancesOf[Planet]

  type Kilogram = Double
  type Meter   = Double
  private val G = 6.67300E-11 // universal gravitational constant  (m3 kg-1 s-2)
}
{% endhighlight %}

This version has an ordered enumeration, and uses a macro to generate the set of all values.

{% highlight scala %}
scala> import SolarSystemPlanets._
import SolarSystemPlanets._

scala> println(planets)
TreeSet(Mercury, Venus, Earth, Mars, Jupiter, Saturn, Uranus, Neptune)

scala> EARTH < MARS
res1: Boolean = true

scala> planets.filter(_.radius > 7.0e6)
res2: scala.collection.immutable.Set[SolarSystemPlanets.Planet] = TreeSet(Jupiter, Saturn, Uranus, Neptune)
{% endhighlight %}

You don't need macros to achieve this. The set of enumeration values can be automatically populated in a parent class of your enumeration.  A good example of this
is the [Viktor Kalang "DIY Enum"](https://gist.github.com/viktorklang/1057513).  I've also made the long Oracle Planets example of the DIY Enum available as [a gist](https://gist.github.com/d6y/376f1a4b178c343ff415), and all the code in this post is available in a [git repository](https://github.com/d6y/enumeration-examples).


## Conclusion

`scala.Enumeration` has a particular view of what it means to be an enumeration. Use it where it fits your view of an enumeration.

A sealed set of case objects is a good way to represent an enumeration.  You can make this as simple or as sophisticated as you need for your project.
