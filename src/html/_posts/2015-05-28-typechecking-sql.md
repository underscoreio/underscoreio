---
layout: post
title: Typechecking SQL in Slick and doobie
author: Richard Dallaway
---

Querying a database is sometimes best done with hand-written SQL.
Of course the trick is to find a way to avoid syntax and type errors at run time.
This post will look at how [Slick] and [doobie] approach this problem.

[Essential Slick]: http://underscore.io/training/courses/essential-slick/
[book of doobie]: http://tpolecat.github.io/doobie-0.2.1/00-index.html
[pins]: https://www.artima.com/pins1ed/combining-scala-and-java.html#i-855208314-1
[dtest]: http://tpolecat.github.io/doobie-0.2.1/11-Unit-Testing.html
[Github project]: https://github.com/d6y/typechecking-sql
[doobie]: https://github.com/tpolecat/doobie
[Slick]: http://slick.typesafe.com/
[free]: /blog/posts/2015/04/14/free-monads-are-simple.html

<!-- break -->

To keep things simple, we're just going to look at one SQL statement:

~~~ sql
select "content" from "message"
~~~

The type we want from executing this query will be some kind of `Seq[String]`.  

The table for the query is:

~~~ sql
create table "message" (
  id      serial primary key,
  content varchar(255)
);
~~~

Given that the SQL is, in effect, an arbitrary hunk of text, we'd like to know:

1. Is the SQL valid?
2. Do the types in the SELECT (and therefore, the table) match the types we expect?

And we want to know it sooner rather than later.

Both Slick and doobie have an approach to this problem.  

[Slick] is, I suspect, reasonably well known as the database library in Typesafe's stack. In version 3.0 it added support for type-checked queries.  Perhaps less well known is [doobie], which provides a "principled way to construct programs (and higher-level libraries) that use JDBC." We think of it as the database layer in a Typelevel stack.  

Let's look in turn, and how they let us discover problems with our SQL.

## Slick

Slick supports arbitrary SQL via _Plain SQL_ queries. Plain SQL is just one of the ways Slick allows you to access a database. But it's the style we're focusing on in this post.

The support is via interpolators: `sql` and `sqlu`, which wrap a SQL statement, do the right thing to substitute in values safely, and convert values into Scala types. We've described this in Chapter 6 of [Essential Slick].

What's new in Slick 3 is type-checked SQL, available via the `tsql` interpolator:

~~~scala
val program: DBIO[Seq[String]] =
  tsql"""select "content" from "message""""
~~~

Note that this is constructing a query, not running it. To run it, we hand the query to an interpreter, and it gives an asynchronous result back.

What's interesting with our `program` is:

- the syntax is checked at compile time; and
- the types of the columns are discovered at compile time.

To explore this, we can play with the query to see what happens if we screw up.

First, if we change the query to also select the ID column...

~~~scala
val program: DBIO[Seq[String]] =
  tsql"""select "content", "id" from "message""""
~~~

That's a compile time type error:

~~~
type mismatch;
[error]  found   : SqlStreamingAction[Vector[(String, Int)],(String, Int),Effect]
[error]  required: DBIO[Seq[String]]
[error]     (which expands to)  DBIOAction[Seq[String],NoStream,Effect.All]
~~~

This is because I've declared the result of each row to be a `String`, but `tsql` has figued out it's really a `(String,Int)`.
If I'd omitted the type declaration, my `program` would have the inferred type of `DBIO[Seq[(String,Int)]]`. So it's going to be good practice to declare the type you expect for `tsql`.

Let's now just break the SQL:

~~~scala
val program: DBIO[Seq[String]] =
  tsql"""select "content" from "message" where"""
~~~

This is incomplete SQL, and the compiler tells us:

~~~
exception during macro expansion: ERROR: syntax error at end of input
[error]   Position: 38
[error]     tsql"""select "content" from "message" WHERE"""
[error]     ^
~~~

And if we get a column name wrong...

~~~scala
val program: DBIO[Seq[String]] =
  tsql"""select "text" from "message" where"""
~~~

...that's also a compile error too:

~~~
Exception during macro expansion: ERROR: column "text" does not exist
[error]   Position: 8
[error]     tsql"""select "text" from "message""""
[error]     ^
~~~

From those errors we know `tsql` is a macro. How is it getting the information it needs to do these checks? We have to give it a database connection.

The connection is via an annotation on a class:

~~~ scala
import slick.backend.StaticDatabaseConfig

@StaticDatabaseConfig("file:src/main/resources/application.conf#tsql")
object PlainExample extends App {
  ...
}
~~~

The annotation is specifying an entry in a configuration file. That configuration file looks like this:

~~~
tsql = {
  driver = "slick.driver.PostgresDriver$"
  db {
    driver = "org.postgresql.Driver"
    url = "jdbc:postgresql://localhost/chat"
    username = "richard"
    password = ""
    connectionPool = disabled
  }
}
~~~

(Note the `$` in the class name is not a typo. The class name is being passed to Java's `Class.forName`, but of course Java doesn't have a singleton as such. The Slick configuration does the right thing to load `$MODULE` when it sees `$`. These shenanigans are described in [Chapter 29 of _Programming in Scala_][pins].)

A consequence of supplying a `@StaticDatabaseConfig` is that you can define one databases configuration for your application and a different one for the compiler to use.  That is, perhaps you are running an application, or test suite, against an in-memory database, but validating the queries at compile time against a production-like integration database.

It's also worth noting that `tsql` works with inserts and updates too:

~~~ scala
val greeting = "Hello"
val program: DBIO[Seq[Int]] =
  tsql"""insert into "message" ("content") values ($greeting)"""
~~~

At run time, when we execute the query, a new row will be inserted.
At compile time, Slick uses a facility in JDBC to compile the query and retrieve the meta data without having to run the query.
In other words, at compile time, the database is not mutated.


## doobie

Both doobie and Slick 3 use similar patterns for executing a query -- in fact, doobie was the first database technology I saw doing this. Queries are represented using our friend the free monad and interpreter that Noel has been describing in [recent posts][free].

We're just looking at the query checking part of doobie here. The excellent [book of doobie] is the place to go to learn more about the whole project.

The select query we've been using in the post looks like this in doobie:

~~~ scala
val query: Query0[String] =
  sql""" select "content" from "message" """.query
~~~

I've given the type declaration for clarity, although you might write `.query[String]` instead (which reads better to my eyes).

In terms of checking this query, doobie gives us a `check` method:

~~~ scala
val xa = DriverManagerTransactor[Task](
 "org.postgresql.Driver", "jdbc:postgresql:chat", richard, ""
)

import xa.yolo._
query.check.run
~~~

This outputs:

~~~
select "content" from "message"

✓ SQL Compiles and Typechecks
✕ C01 content VARCHAR (varchar) NULL  →  String
 - Reading a NULL value into String will result in a runtime failure. Fix this by
  making the schema type NOT NULL or by changing the Scala type to Option[String]
~~~

This is telling me I forgot to add a `NOT NULL` constraint on my PostgreSQL schema.  Fixing that problem (`alter table "message" alter column "content" set not null`) gives a clean bill of health:

~~~
select "content" from "message"

✓ SQL Compiles and Typechecks
✓ C01 content VARCHAR (varchar) NOT NULL  →  String
~~~

Now `check` is a run-time check, which is a bit too late to be learning about possible problems. What doobie provides is a way to execute checks as tests.  This is set out in [chapter 11 of the _book of doobie_][dtest], but here's a quick example:


~~~ scala
import doobie.contrib.specs2.analysisspec.AnalysisSpec
import org.specs2.mutable.Specification

object Queries {
  val allMessages =
    sql""" select "content" from "message" """.query[String]
}

object AnalysisTestSpec extends Specification with AnalysisSpec {
  val transactor = DriverManagerTransactor[Task](
    "org.postgresql.Driver", "jdbc:postgresql:chat", "richard", ""
  )
  check(Queries.allMessages)
}
~~~

Here we're using doobie's add on for specs2 to perform analysis of a query. Note that I've changed the query to be a value in an object. Pulling queries out into some kind of module is going to be good practice if you're using this style of query checking.

Notice, as with Slick, we're providing database connection information that could be different from the database we're developing against. You can probably test against multiple databases, if that's useful to you.

We can run our test suite as we usually would:

~~~
> test
[info] Compiling 1 Scala source to target/scala-2.11/test-classes...
[info] AnalysisTestSpec
[info]
[info] Query0[String] defined at query-specs.scala:9
[info]   select "content" from "message"
[info] + SQL Compiles and Typechecks
[info] + C01 content VARCHAR (varchar) NOT NULL  →  String
[info]
[info] Total for specification AnalysisTestSpec
[info] Finished in 25 ms
[info] 2 examples, 0 failure, 0 error
~~~

As you might imagine, "+ SQL Compiles and Typechecks" fails if you have a typo in the SQL, incorrect column names, or the types don't align. Here's one example where I've said I expect a `String` from a query, but selected the `id` column:

~~~
[info] Query0[String] defined at query-specs.scala:9
[info]   select "id" from "message"
[info] + SQL Compiles and Typechecks
[info] x C01 id INTEGER (serial) NOT NULL  →  String
[error]    x INTEGER (serial) is ostensibly coercible to String according to the JDBC
[error]      specification but is not a recommended target type. Fix this by changing the
[error]      schema type to CHAR or VARCHAR; or the Scala type to Int or JdbcType. (query-specs.scala:9)
~~~

The test fails, which is what we want.

## Conclusions

I find it easier to think about queries in terms of SQL than alternative formulations. However, I've tended to avoid using straight SQL in a project because it's so easy to introduce an error when changing code.  But here we have two projects offering great opportunities to remove that risk.

Both doobie and Slick are using the same mechanisms (prepared statements and JDBC meta data). The routes taken at the moment are different, focusing on analysis and test-time checking (doobie) and compile-time checking (Slick).

If you want to try out the code in this post, I've created a [Github project] for you.

