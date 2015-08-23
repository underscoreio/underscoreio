---
layout: post
title: Using slickless with Plain SQL
author: Richard Dallaway
---

With [shapeless] `HList` support available for [Slick], we can make further use of shapeless to reduce boilerplate code. This post explores how to do this for the Slick `GetResult` type class.

[shapeless]:           https://github.com/milessabin/shapeless
[Slickless]:           https://github.com/underscoreio/slickless
[Slick]:               http://slick.typesafe.com/
[slickless-announce]:  /blog/posts/2015/08/08/slickless.html
[Generic]:             https://github.com/milessabin/shapeless/wiki/Feature-overview:-shapeless-2.0.0#generic-representation-of-sealed-families-of-case-classes
[Sam Halliday]: https://twitter.com/fommil
[example]:             https://github.com/d6y/slickless-hlist-getresult

<!-- break -->

## Plain SQL

Slick allows you to write _plain SQL_ queries. They look like this:

~~~ scala
val action =
  sql""" SELECT "id", "email" FROM "users" """.as[Long :: String :: HNil]
~~~

Here we are using a shapeless `HList` to represent a row as a `Long :: String :: HNil`. We can do that via the [slickless] library, which was introduced in a [recent post][slickless-announce].

When we run this query we'll get back a `Seq[Long :: String :: HNil]`. But there's a catch: we need to provide Slick with an instance of `GetResult[Long :: String :: HNil]`. This tells Slick how to map from our query columns ("id" and "email") into that `HList` structure.

## Generating `GetResult` for an `HList`

It's pretty easy to create such a type class instance by hand. Here's one that will work:

~~~ scala
import slick.jdbc.{ GetResult, PositionedResult }

implicit val longStringGetResult =
  new GetResult[Long :: String :: HNil] {
    def apply(r: PositionedResult) =
      r.nextLong :: r.nextString :: HNil
  }
~~~

The `PositionedResult` is a value Slick gives us to read column values.
Using it is easy, and there's a shorter `GetResult.apply`-style, but it's still tedious. Thankfully shapeless can automate this for us. (This is not an original idea: I saw this, or something like it, first suggested by [Sam Halliday]).  

To get this working we can make use of three facts:

1. Slick provides `GetResult[T]` instances for basic types, such as `String` and `Long`;
2. Rather than use `r.nextLong` and `r.nextString` we can use `r.<<[T]`, which Slick provides for the `T`s it can get the next value of; and
3. We can recurse on the `HList` types, just as you would recurse on the head and tail of a regular list.

Let's do it. We're going to need a method like this:

~~~ scala
// Incomplete: won't compile
implicit def hlistConsGetResult[HList] =
  new GetResult[HList] {
    def apply(r: PositionedResult) = ???
  }
~~~

That is, we want an implicit method that the compiler can use to create a `GetResult` for any `HList`.
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
      def apply(r: PositionedResult) = (r << h) :: t(r)
    }
~~~

Notice how the `apply` method makes use of `r` to create a value, then recurses on the tail of the `HList`. We need a stopping condition for this, which is a `GetResult[HNil]`:

~~~ scala
implicit object hnilGetResult extends GetResult[HNil] {
  def apply(r: PositionedResult) = HNil
}
~~~

These two implicits will generate a `GetResult` for any `Hlist` without us having to write it by hand.


## Conclusions

By using a shapeless `HList` as a row representation we can start to make use of the other funky features in shapeless. We've seen an example of creating `GetResult` instances without having to implement them by hand.  You can find [this example on Github][example].

Once we've kicked the tires on this some more, we may roll this into a release of [Slickless].
