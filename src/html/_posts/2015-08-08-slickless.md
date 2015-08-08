---
layout: post
title: Using shapeless HLists with Slick 3
author: Richard Dallaway, Miles Sabin, and Dave Gurnell.
---

You can now use [the shapeless HList][hlist] with [Slick][slick]. This post explains what that means, how you can use it, and what we had to do to make this possible.

[Slick]: http://slick.typesafe.com/
[Slickless]: https://github.com/underscoreio/slickless
[example]: https://github.com/d6y/slick-shapeless-so-31764514
[hlist]: https://github.com/milessabin/shapeless/wiki/Feature-overview:-shapeless-2.0.0#heterogenous-lists
[generic]: https://github.com/milessabin/shapeless/wiki/Feature-overview:-shapeless-2.0.0#generic-representation-of-sealed-families-of-case-classes
[so]: http://stackoverflow.com/questions/31764514/using-slick-with-shapeless-hlist
[943]: https://github.com/slick/slick/issues/943
[519]: https://github.com/slick/slick/issues/519
[538]: https://github.com/slick/slick/issues/538
[536]: https://github.com/slick/slick/issues/536
[Essential Slick]: http://underscore.io/training/courses/essential-slick/
[existing-shape]: https://github.com/slick/slick/blob/e9ab33083bfa1ae642a93d4e52b4ac87b42dc917/slick/src/main/scala/slick/collection/heterogeneous/HList.scala#L130-L136
[our-shape]: https://github.com/underscoreio/slickless/blob/master/src/main/scala/slickless/HListShape.scala#L8-L33

<!-- break -->

## The Story So Far...

The Slick database library knows how to deliver rows in terms of tuples, case classes, and its own heterogeneous list (HList) implementation. Here's what that looks like in code:

~~~ scala
import slick.collection.heterogeneous.{ HList, HCons, HNil }
import slick.collection.heterogeneous.syntax._

class Users(tag: Tag) extends Table[Long :: String :: HNil](tag, "users") {
  def id    = column[Long]( "id", O.PrimaryKey, O.AutoInc )
  def email = column[String]("email")

  def * = id :: email :: HNil
}

lazy val users = TableQuery[Users]
~~~

A query for all `users` will result in a collection of values for each row. The type of each row will be `Long :: String :: HNil`. Notice how this looks like a regular list, but each element can have a different type. These types are preserved and enforced when you operate on the HList.

## Adding shapeless

What we've just showed is the HList implementation that Slick provides. HList are suggested as a way to handle tables with a large number of columns, as we discuss in Chapter 4 of the [Essential Slick] book.

However: A number of people have asked instead to use the shapeless HList.  For example, you'll see shapeless crop up on Slick issues ([943], [519], [538], [536]) and [Stackoverflow][so].

As no-one had shapeless/Slick integration working, we sat down to figure it out.

The challenge is to produce a "Shape" for a shapeless HList. The shape is a type class that encodes the knowledge of how to pack and unpack the various representations that Slick uses. (Disclaimer: we've not made the effort to fully understand the hows and whys of Shape: we had a morning to do this in).

Our starting point was the existing [Slick HList shape][existing-shape]. Various steps forward and back led us to understand that `MappedScalaProductShape` was not the right position in the Shape hierarchy to insert shapeless.  We found we had to drop Scala product out of the equation, and fit in with `MappedProductShape`.  This gave us our own [`HListShape`][our-shape].

The final step is to provide implicits to conjure-up a `HListShape` from a shapeless HList.

## The Slickless Library

There are 43 lines of code to make this happen. But we've packaged them for you as a library called [Slickless].

The code example we started with stays the same, but the imports change.  Remove the Slick HList imports and instead use:

~~~ scala
import shapeless.{ HList, ::, HNil }
import slickless._
~~~

You're now working with shapeless HLists.

## Conclusions

You can now work with shapeless HLists with Slick, using the [Slickless] library. There's also an [example] project on Github you can use to try out Slickless.

But _why_ do you want to do that? We'd love to hear how you're using shapeless with Slick, and what problems it solves for you.

