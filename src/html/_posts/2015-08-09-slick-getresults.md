---
layout: post
title: Using Slickless with Plain SQL
author: Richard Dallaway
---

With [shapeless] `HList` support available for [Slick], we can make further use of shapeless to reduce boilerplate code. This post explores how to do this for the Slick `GetResult` type class.

[shapeless]:           https://github.com/milessabin/shapeless
[Slickless]:           https://github.com/underscoreio/slickless
[Slick]:               http://slick.typesafe.com/
[slickless-announce]:  http://example.com/todo
[Generic]:             https://github.com/milessabin/shapeless/wiki/Feature-overview:-shapeless-2.0.0#generic-representation-of-sealed-families-of-case-classes
[Sam Halliday]: https://twitter.com/fommil
[github]: http://example.org/todo


<!-- break -->

## Plain SQL

Slick allows you to write _plain SQL_ queries. They look like this:

~~~ scala
val action =
  sql""" SELECT "id", "email" FROM "users" """.as[Long :: String :: HNil]
~~~

Here we are using a shapeless `HList` to represent a row as a `Long :: String :: HNil`. We can do that via the [Slickless] library, which was introduced in a [recent post][slickless-announce].

When we run this query we'll get back a `Seq[Long :: String :: HNil]`. But there's a catch: we need to provide Slick with an instance of `GetResult[Long :: String :: HNil]` so it knows how to map from our query columns ("id" and "email") into that HList structure.

## Generating `GetResult` for an `HList`

It's pretty easy to create such a type class instance. Here's one that will work:

~~~ scala
import slick.jdbc.{ GetResult, PositionedResult }

implicit val longStringGetResult =
  new GetResult[Long :: String :: HNil] {
    def apply(r: PositionedResult) =
      r.nextLong :: r.nextString :: HNil
  }
~~~

The `PositionedResult` is a value Slick gives us at runtime to read column values.
Using it is easy, but tedious. Thankfully shapeless can automate this for us.
(This is not an original idea: I saw this suggested by [Sam Halliday]).  

To get that working we can make use of three facts:

1. Slick provides `GetResult[T]` instances for basic types, such as `String` and `Long`;
2. Rather than use `r.nextLong` and `r.nextString` we can use `r.<<[T]`, which Slick provides for the `T`s it can get the next value of; and
3. We can recurse on the `HList` types, just as you would recurse on the head and tail of a regular list.

Let's do it. We going to need to write a method like this:

~~~ scala
// Incomplete: won't compile
implicit def hlistConsGetResult[HLst] =
  new GetResult[HList] {
    def apply(r: PositionedResult) = ???
  }
~~~

That is, we want an implicit method that Slick can use to create a `GetResult` for any `HList`.
To fill this in we note that an `HList` is made up of a head and a tail:

~~~ scala
implicit def hlistConsGetResult[H, T <: HList]
  new GetResult[H :: T] {
    def apply(r: PositionedResult) = ???
  }
~~~

We need to be able to get to a `GetResult` instance for the head and tail types, and then use them to build up an `HList` value. We can ask the compiler to find those implicitly for us, because we know Slick provides `GetResult` instances for the basic types.


~~~ scala
implicit def hlistConsGetResult[H, T <: HList]
  (implicit
    h: GetResult[H],
    t: GetResult[T]
  ) =
    new GetResult[H :: T] {
      def apply(r: PositionedResult) = ???
    }
~~~

The final step is to fill in the `apply` method and call the implicit `GetResult` for the head element, and then recurse on the tail:

~~~ scala
implicit def hlistConsGetResult[H, T <: HList]
  (implicit
    h: GetResult[H],
    t: GetResult[T]
  ) =
    new GetResult[H :: T] {
      def apply(r: PositionedResult) = r.<<[H] :: t(r)
    }
~~~

Notice how the `apply` method makes use of `r` to create a value, then recurses on the tail of the HList. We need a stopping condition for this, which is a `GetResult[HNil]`:

~~~ scala
implicit object hnilGetResult extends GetResult[HNil] {
  def apply(r: PositionedResult) = HNil
}
~~~

Thiese two implicits will generate a `GetResult` for any `Hlist` without us having to write it by hand.

## What about case classes?

We have the same problem if we want to use plain SQL to get to a case class:

~~~ scala
case class Contact(id: Long, Email: String)

val action =
  sql""" SELECT "id", "email" FROM "users" """.as[Contact]
~~~

We need to provide a `GetResult[Contact]` for this to compile. But having done the work for `HList` we can employ shapeless [Generic] to do the hard work.

Generic lets us map between a case class and, among other things, an `Hlist`:

~~~ scala
val contact = Contact(0L, "jo@example.org")
// contact: Contact = Contact(0,jo@example.org)

import shapeless._
implicit val gen = Generic[Contact]
// gen: shapeless.Generic[Contact]{type Repr = shapeless.::[Long,shapeless.::[String,shapeless.HNil]]} = fresh$macro$3$1@39a18225

gen.to(contact)
// res0: gen.Repr = 0 :: jo@example.org :: HNil

gen.from(1L :: "bob@example.org" :: HNil)
// res1: Contact = Contact(1,bob@example.org)
~~~

This gives us the ability to go from an `HList` to a case class value, using `gen.from`. We already have a way to create a `GetResult` for an `HList` from the first half of this post. We now need to combine the two to compile our `.as[Contact]` query.

The combining, then, needs a `Generic[T]` (for a case class `T`), and also a `GetResult` for the `HList` encoding of `T`.  How do we get to that `HList` encoding?  Well, shapeless has a variant of `Generic[T]` for that: `Generic.Aux[T,R]`, where `R` is in this case the `HList` encoding.

Putting the pieces together we have:

~~~ scala
implicit def caseClassGetResult[T,R]
  (implicit
    gen:       Generic.Aux[T,R],
    getResult: GetResult[R]
  ): GetResult[T] =
    new GetResult[T] {
      def apply(r: PositionedResult) = gen.from(getResult(r))
    }
~~~

The two implicits are our demand that the compiler can find a `Generic` for the case class, but also a `GetResult` for the `HList`.  If those are found, the implementation of `GetResult.apply` becomes simple: call the `GetResult`, and use `gen.from` to give a case class value.

## Conclusions

By using a shapeless `HList` as a row representation, we can start to make of the other funky features in shapeless. An example is to create `GetResult` instances for case classes without having to implement them by hand.

If you want to try this out, there's an [example Github project][github]. We'll probably be shortly including `GetResult` support in a release of [Slickless].
