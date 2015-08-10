---
layout: post
title: Using shapeless HLists with Slick 3
author: Richard Dallaway, Miles Sabin, and Dave Gurnell.
---

We've developed a tiny library called [slickless] that enables use of [shapeless HLists][hlist] in [Slick][slick]. This post explains what that means, how you can use it, and what we had to do to make this possible.

[Slick]: http://slick.typesafe.com/
[slickless]: https://github.com/underscoreio/slickless
[shapeless]: https://github.com/milessabin/shapeless
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
[gitter]: https://gitter.im/underscoreio/scala

<!-- break -->

## The story so far...

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

A query for all `users` will result in a collection of values for each row. In this case, the type of each row will be `Long :: String :: HNil`. `HLists` provide the strong element typing associated with tuples, with the abitrary lengths of regular `Lists`. They are the recommended way of mapping tables with more than 22 columns in Slick 2 and 3. The coverage of HLists in the Slick documentation is surprisingly bare, but we dive into them in detail in Chapter 4 of [Essential Slick].

Slick currently treats `HLists` as a way of beating the "22 column limit" imposed by the maximum arity of Scala functions and tuples. By contrast, shapeless uses `HLists` as the basis of a whole suite of generic programming tools. We've seen a lot of demand from the community for compatibility with [shapeless] HLists (see Slick issues [943], [519], [538], [536] and [Stackoverflow][so] for examples). A quick check for existing shapeless/Slick integrations turned up no results, so we sat down to figure it out.

## Supporting shapeless in Slick

The crux of the problem is to derive instances of Slick's `Shape` type class for shapeless `HLists`. Slick uses `Shapes` to manage mappings between the types of `Queries` and the types of their results. We create a shape implicitly whenever we define a default projection for a `Table`, and shapes are carried around by queries on the table.

For example, the shape of `users` in the example above tells us that the value inside the query (the parameter passed to `map`, `flatMap`, and `filter` functions) is of type `Users` and the result of running the query will be our Slick `HList` type:

~~~ scala
users.shaped.shape
// res0: slick.lifted.Shape[_, Users, HCons[Long, HCons[String, HNil]], _] = ...
~~~

If we change the default projection of the table (for example using the bidirectional mapping operator `<>`), we change the shape of the queries. We can also cause queries to change shape using `map` or `flatMap`:

~~~ scala
users.map(u => (u.id, u.email)).shaped.value
// res1: slick.lifted.Shape[_, _ <: (Rep[Long], Rep[String]), (Long, String), _] = ...
~~~

## Introducing slickless

The result of our efforts is a tiny library, slickless, that uses approximately 40 lines of code to generate shapes for shapeles `HLists`. The implementation is similar to the one provided for Slick's own `HLists`, and the use is almost identical. We simply substitute the imports for Slick `HLists`:

~~~ scala
import slick.collection.heterogeneous.{ HList, HCons, HNil }
import slick.collection.heterogeneous.syntax._
~~~

with imports for shapeless and slickless:

~~~ scala
import shapeless.{ HList, ::, HNil }
import slickless._
~~~

and the rest of the code compiles as normal. We can define default projectiong using shapeless `HLists`, transform them with `<>`, and `map` and `flatMap` over queries in all of the usual ways.

## Conclusions

As you can see, slickless provides dead-simple interop between Slick and shapeless. However, this is hopefully just the beginning. Now the groundwork has been laid, we should be able to use shapeless' range of generic programming tools to build boilerplate-free conversions and type-mappings that aren't possible with vanilla Slick.

We'd love to get some feedback on slickless. Get in touch via the comments, [Github][slickless], or our [Gitter channel][gitter], to let us know what you're doing with Slick, your thoughts on slickless, how shapeless support might be able to help, or how you might be able to contribute to take things further.
