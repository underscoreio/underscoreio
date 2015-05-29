---
layout: post
title: Typechecking SQL in Slick and doobie
author: Richard Dallaway
---

Querying a database is sometimes best done with hand-written SQL.
Of course the trick is to find a way to avoid syntax errors and type errors at run time.
This post will look at how Slick and doobie approach this problem.

[Essential Slick]: http://underscore.io/training/courses/essential-slick/
[book of doobie]: http://tpolecat.github.io/doobie-0.2.1/00-index.html
[dcheck]: http://tpolecat.github.io/doobie-0.2.1/06-Checking.html
[dtest]: http://tpolecat.github.io/doobie-0.2.1/11-Unit-Testing.html
[pins]: https://www.artima.com/pins1ed/combining-scala-and-java.html#i-855208314-1

<!-- break -->

To keep things simple, we're just going to look at one SQL statement:

~~~ scala
select "content" from "message"
~~~

The table for the query is:

~~~ sql
create table "message" (
  id      serial primary key,
  content varchar(255)
);
~~~

The type we want from executing this query will be some kind of `Seq[String]`.  
Given the SQL is, in effect, a arbitrary hunk of text, we'd like to know:

1. Is the SQL valid?
2. Do the types in the SELECT match the types we expect?

And we want to know it sooner rather than later.

Slick is... TODO
doobie is... TODO.

The approaches to this problem taken by Slick and doobie differ in that:

[TODO SUMMARY]

Let's look at each in detail.

## Slick

Slick supports arbitrary SQL via _Plain SQL_ queries. These interpolators, `sql` and `sqlu`, wrap a SQL statement, do the right thing to substitute in values safely, and convert values into Scala types. We've described this in Chapter 6 of [Essential Slick].

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

First, if we change the query to also select the ID column:

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

(Note the `$` in the class name is not a typo. The class name is being passed to Java's `Class.forName`, but of course Java doesn't have a singleton as such. The Slick configuration does the right thing to the name for Java when it sees `$`. These shenanigans are described in [Chapter 29 of _Programming in Scala_][pins].)

A consequence of supplying a `@StaticDatabaseConfig` is that you can define a one databases configuration for your application and a different one for the compiler to use.  That is, perhaps you are running an application, or test suite, against an in-memory database, but validating the queries at compile time against a production-like integration database.

It's also worth nothing that `tsq` works with inserts and updates too:

~~~ scala
val greeting = "Hello"
val program: DBIO[Seq[Int]] =
  tsql"""insert into "message" ("content") values ($greeting)"""
~~~

At run time, when we execute the query, a new row will be inserted.
At compile time, Slick uses a facility in JDBC to compile the query and retrieve the meta data without having to run the query.
In other words, at compile time, the database is not mutated.


## doobie

Both doobie and Slick 3 use similar patterns for executing a query -- in fact, doobie was the first database technology I saw doing this. The excellent [book of doobie] is the place to go to learn about the project.


## Conclusions

TODO
