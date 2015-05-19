---
layout: post
title: Slick Query Enrichment
author: Richard Dallaway
---

Query _enrichment_ (or _query extensions_) in Slick can provide a concise way to express domain-specific logic. This gives extra flexibility beyond Slick's combinators, such as `map` and `filter`. This post builds up an example micro DSL, showing the benefits in clarity and reduced repetition.

[Essential Slick]: http://underscore.io/training/courses/essential-slick/
[implicit classes]: http://docs.scala-lang.org/sips/completed/implicit-classes.html
[Patterns for Slick Database Applications]: https://skillsmatter.com/skillscasts/4577-patterns-for-slick-database-applications
[Christopher Vogt]: https://twitter.com/cvogt
[gist]: https://gist.github.com/d6y/56d982cadb609f91d1fc

<!-- break -->

## Three Valued Flags

The example we're focusing on here concerns users setting flags against records. If we had a message and we wanted to flag it as important, or not, we could model that as a `Boolean` with a default value of `false`. But it's not unusual to have three states: true, false, or no value.

That "no value" part, often in legacy SQL systems, is a `NULL`.  In Scala we represent the `NULL` possibility via an `Option[Boolean]`:

~~~ scala
case class Message(content: String, important: Option[Boolean] = None)
~~~

And this is fully supported in the way we construct a table definition in Slick:

~~~ scala
class MessageTable(tag: Tag) extends Table[Message](tag, "message") {
  def content   = column[String]("content")
  def important = column[Option[Boolean]]("important")
  def * = (content, important) <> (Message.tupled, Message.unapply)
  }
~~~

That's straight-forward, and causes no problems.  What's annoying is when you want to do something like search for messages that _haven't_ been flagged as important.  Consider the possible values:

- `None`, no flag has been set (which we treat as not important)
- `Some(false)`, explicitly flagged as not important.
- `Some(true)`, flagged as important.

You might think we could search for records where `important =!= false`, but that's not the way SQL works. In SQL we have to for records where `important IS NULL` or `important = false`:

~~~ scala
val query = messages.filter(m => m.important.isEmpty || m.important === false)
~~~

That works just fine, but:

- it gets repetitive, fast (imagine you have multiple columns that are flags); and
- it's also easy to get this query logic wrong.

What we can do is add our own application DSL for this, and write:

~~~ scala
val query = messages.notFlagged(_.important)
~~~

Enrichment lets us do that.

## Enrichment

Enrichment is a standard aspect of Scala development, introduced as [implicit classes]. It allows us to add methods to a type:

~~~scala
implicit class IntOps(n: Int) {
  def stars: String = (1 to n).map(_ => '*').mkString
}

5.stars
// res0: String = *****
~~~

Providing the implicit `IntOps` is in scope, the compiler will use it to supply a `stars` method to any `Int` that wants it.

We'll copy and paste this as the basis of our `notFlagged` method.

## Query Enrichment

To use this approach, we need to change the types and method name in `IntOps`:

~~~scala
import scala.language.higherKinds

implicit class QueryEnrichment(q: ???) {
  def notFlagged(???) =
    q.filter(???)
  }
~~~

This implicit needs to apply to a query, rather than an `Int`. In fact, we're happy for it to apply to any query, and the type of any query in Slick is `Query[M, U, C]`:

- `M` is called the mixed type (the types that take part in a query);
- `U` is called the unpacked type (the types you end up with); and
- `C` is called the collection type (e.g., a `Seq` or `Vector` or similar, as appropriate).

That allows us to fill in the `q` part of our enrichment:

~~~scala
implicit class QueryEnrichment[M,U,C[_]](q: Query[M,U,C]) {
  def notFlagged(???): Query[M,U,C] =
    q.filter(???)
  }
~~~

The argument for `notFlagged` is going to be something to select an `Option[Boolean]` column. In Slick 3, the column is represented as a `Rep[T]` so the type of the expression `_.important` will be `M => Rep[Option[Boolean]]`:

~~~scala
implicit class QueryEnrichment[M,U,C[_]](q: Query[M,U,C]) {
  def notFlagged(selector: M => Rep[Option[Boolean]]): Query[M,U,C]  =
    q.filter(???)
  }
~~~

That is, whatever we pass to `notFlagged`, it had better be something that is given an `M` and gives us back a `Rep[Option[Boolean]]`.  In other words, it's a compiler error to pass in `_.content` (that's a `Rep[String]`), but fine to pass in `_.important` (that's an `Rep[Option[Boolean]]`).

Finally, we fill in the query by replacing the `_.important` in our original example with our selector function:

~~~ scala
implicit class QueryEnrichment[M,U,C[_]](q: Query[M,U,C]) {
  def notFlagged(selector: M => Rep[Option[Flag]]): Query[M,U,C] =
    q.filter(m => selector(m).isEmpty || selector(m) === false)
}
~~~

Putting this together we can write a program to create a database, populate it, and select the messages with our `notFlagged`:

~~~scala
def testData = Seq(
  Message("First!"),
  Message("Party details",      Some(true)),
  Message("Timesheet reminder", Some(false))
)

val program = for {
  _    <- messages.schema.create
  _    <- messages ++= testData
  msgs <- messages.notFlagged(_.important).result
} yield msgs
~~~

## Conclusions

Enrichment provides a neat way to simplify repetitive, error-prone queries.  

The first time I saw this kind of trick in action was in [Christopher Vogt]'s 2013 [Patterns for Slick Database Applications] presentation. If you want to see different examples, do check out that video.

The example above builds this up for an `Option[Boolean]`. That's a very general type, possibly in use for things other than flags. In that case, it would make sense to create a type, `Flag`, and restrict the `notFlagged` method to apply only to `Option[Flag]`. I've created an example of that as a [gist].

This is the kind of material we're including in [Essential Slick]. Working with the type system and Slick is something we consider part of the essentials you need.
