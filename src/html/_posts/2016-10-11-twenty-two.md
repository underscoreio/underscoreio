---
layout: post
title: "Scala and 22"
author: "Richard Dallaway"
---

Back in 2014, when Scala 2.11 was released, an important limitation was removed:
"Case classes with > 22 parameters are now allowed".
This may lead you to think there are no 22 limits in Scala, but that's not the case.
The limit lives on in functions and tuples.
This post explores the limit, looks at an example from Slick, and notes two ideas for what you can do about it.

[SI-7296]: https://issues.scala-lang.org/browse/SI-7296
[scala211]: https://www.lightbend.com/blog/scala-211-has-arrived
[edge cases]: https://issues.scala-lang.org/browse/SI-8468
[extractor]: https://www.artima.com/pins1ed/extractors.html
[partially apply]: https://www.artima.com/pins1ed/functions-and-closures.html#8.6
[Function2]: https://github.com/scala/scala/blob/2.12.x/src/library/scala/Function2.scala
[Product2]: https://github.com/scala/scala/blob/2.12.x/src/library/scala/Product2.scala

<!-- break -->

## History

In Scala 2.10 and earlier we could not exceed 22 parameters on a case class:

```scala
Welcome to Scala version 2.10.2 (Java HotSpot(TM) 64-Bit Server VM, Java 1.8.0_60).
Type in expressions to have them evaluated.
Type :help for more information.

scala> case class Large(
     |   a: Int, b: Int, c: Int, d: Int,
     |   e: Int, f: Int, g: Int, h: Int,
     |   i: Int, j: Int, k: Int, l: Int,
     |   m: Int, n: Int, o: Int, p: Int,
     |   q: Int, r: Int, s: Int, t: Int,
     |   u: Int, v: Int, w: Int)
<console>:7: error: Implementation restriction: case classes cannot have more than 22 parameters.
```

It was pretty easy to run into this limitation when modelling JSON or mapping large database tables using case classes.

So it's great that the restriction was relaxed in Scala 2.11.
However, while the 22 limit was lifted for some common cases, it was not universally removed.

## What is a Case Class?

To understand where the 22 limit still exists,
we need to take a look at what a case class gives us.
Let's start with a small case class:

```scala
case class Small(a: Int, b: String)
```

This small line gives us a lot.
We have field accessors, a constructor, equality, hash code, copy, and product methods, but also these two methods:

- `unapply` - from [Product2] (via `Tuple2`); and
- `tupled` - from [Function2].

These two methods crop up frequently when using libraries such as Slick.
They are used to take or produce tuples.
And that's where we are going to run into problems.

As a quick reminder, here's how the methods can be used:

```scala
Welcome to Scala 2.12.0-M5 (Java HotSpot(TM) 64-Bit Server VM, Java 1.8.0_60).
Type in expressions for evaluation. Or try :help.

scala> Small.unapply _
res0: Small => Option[(Int, String)] = $$Lambda$2485/2130301106@781b1665
```

`Small.unapply` is the [extractor] method. If we [partially apply] using `_` we end up with a function value.
In this form, as `res0`,  we can see it takes us from an instance of `Small` to the tuple that makes up the instance.

We can go the other way:

```scala
scala> Small.tupled
res1: ((Int, String)) => Small = scala.Function2$$Lambda$1599/918185213@7e8a7131
```

Here we have a function that takes a single argument.
The argument is a tuple of two values and the result is an instance of `Small`.
(Note that `tupled` returns a function when called, so we didn't need to use `_`.)

These two are going to bite us in a moment, but first let's see the good news.

## Beyond 22 in Scala 2.11

Since Scala 2.11 we can create large case classes:

```scala
// w is the 23rd letter of the English alphabet
scala> case class Large(
     |   a: Int, b: Int, c: Int, d: Int,
     |   e: Int, f: Int, g: Int, h: Int,
     |   i: Int, j: Int, k: Int, l: Int,
     |   m: Int, n: Int, o: Int, p: Int,
     |   q: Int, r: Int, s: Int, t: Int,
     |   u: Int, v: Int, w: Int)
defined class Large
```

And we can construct instances, access fields, and pattern match:

```scala
scala> val large = Large(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23)
large: Large = Large(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23)

scala> large.w
res0: Int = 23

scala>  val w = large match {
     |    case Large(a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w) => s"w is $w"
     |  }
w: String = w is 23
```

But you won't find `Large.tupled` or `Large.unapply`. Those methods don't exist on `Large`.

## Tuples and Functions

[The fix](https://github.com/scala/scala/pull/2305) introduced in Scala 2.11 removed the limitation for the above common scenarios:
constructing case classes, field access (including `copy`ing), and pattern matching (baring [edge cases]).

It did this by omitting `unapply` and `tupled` for case classes above 22 fields.
In other words, the limit to `Function22` and `Tuple22` still exists.

You can see it by trying to construct a tuple with 23 fields:

```scala
scala> (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23)
<console>:1: error: too many elements for tuple: 23, allowed: 22
```

Or by trying to construct a function that takes more than 22 parameters:

```scala
scala> Large.apply _
<console>:14: error: implementation restricts functions to 22 parameters
       Large.apply _
```

## Hitting the Limit

One place where this limit is visible is in Slick table definitions:

```scala
final case class Message(
  sender:  String,
  content: String,
  id:      Long = 0L
)

final class MessageTable(tag: Tag)
    extends Table[Message](tag, "message") {

  def id      = column[Long]("id", O.PrimaryKey, O.AutoInc)
  def sender  = column[String]("sender")
  def content = column[String]("content")

  def * = (sender, content, id) <> (Message.tupled, Message.unapply)
}
```

We don't need to go into too much detail here.
The `def *`, called the "default projection", is the important part.
It says that the tuple of database columns `(sender, content, id)` can be turned into a `Message` via the `tupled` and `unapply` methods on the case class.

From what we've discussed so far you know this is going to be a problem for tables with more than 22 columns.
As soon as you have 23 columns or more, the code won't compile because `tupled` and `unappy` won't exist.

## Working around the Limit

There are two common tricks for getting around this limit.

The first is to use nested tuples.  Although it's true a tuple can't contain more than 22 elements, each element itself could be a tuple:

```scala
scala> ( (1,2,3,4,5,6,7), (8,9,10,11,12,13,14,15), (16,17,18,19,20), (21,22,23) )
res1: ((Int, Int, Int, Int, Int, Int, Int), (Int, Int, Int, Int, Int, Int, Int, Int), (Int, Int, Int, Int, Int), (Int, Int, Int)) = ((1,2,3,4,5,6,7),(8,9,10,11,12,13,14,15),(16,17,18,19,20),(21,22,23))
```

This `res1` tuple contains four elements.  Each of those elements happens to be a tuple.
The total number of elements inside those four tuples is 23.

We can use this to nest groups of columns as tuples inside the default projection tuple.
On the right hand side of the Slick `<>` function we can provide custom methods to construct our `Message` case class from the nested tuples. Pattern matching on the tuple is one way to do that.

The other common trick is to use heterogeneous lists (HLists), where there's no 22 limit.

Slick has a built-in HList implementation,
and the Slick code generator will automatically use it when encountering tables with more than 22 columns.
It looks something like this:

```scala
finae class MessageTable(tag: Tag)
    extends Table[Long :: String :: String :: HNil](tag, "message") {

  def id      = column[Long]("id", O.PrimaryKey, O.AutoInc)
  def sender  = column[String]("sender")
  def content = column[String]("content")

  def * = id :: sender :: content :: HNil
}
```

Slick knows how to map columns into HLists. You can work with values like `1L :: "Dave" :: "Hello!" :: HNil`.

But if you want to make use of case classes, you may be better off using the shapeless HList implementation. We've created the [Slickless](https://github.com/underscoreio/slickless) library to make that easier. In particular [the recent `mappedWith` method](https://github.com/underscoreio/slickless/releases/tag/0.3.0) converts between shapeless HLists and case classes. It looks like this:

```scala
import slick.driver.H2Driver.api._
import shapeless._
import slickless._

class LargeTable(tag: Tag) extends Table[Large](tag, "large") {
  def a = column[Int]("a")
  def b = column[Int]("b")
  def c = column[Int]("c")
  /* etc */
  def u = column[Int]("u")
  def v = column[Int]("v")
  def w = column[Int]("w")

  def * = (a :: b :: c :: /* etc */ :: u :: v :: w :: HNil)
    .mappedWith(Generic[Large])
}
```

There's a full [example with 26 columns](https://github.com/underscoreio/slickless/blob/master/src/test/scala/userapp/LargeSpec.scala) in the Slickless code base.

## Summary

We've seen...

- How the 22 limit on case classes was removed in Scala 2.11 for some uses, but not all.
- Where the limit still applies, on `FunctionN` and `TupleN`.
- An example of how the limit manifests itself in libraries such as Slick.
- Workarounds using nested tuples and HLists.

If you thought the 22 limit had been removed in Scala, that's not quite true.
The situation was made considerably better, but it's worth knowing where you might run into these limits, and what tricks you can use to work around them.





