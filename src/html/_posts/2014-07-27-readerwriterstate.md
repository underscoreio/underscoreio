---
layout:     post
title:      A Small (Real) Example of the Reader and Writer Monads
author:     Channing Walton
date:       '2014-07-27 21:00:00'
---

This is an example of using the Reader and Writer monads to solve a problem which cropped up on a project I am working on.

Before getting to the problem, what are the Reader and Writer monads?

A Reader, sometimes called the environment monad, treats functions as values in a context (see [LYAH](http://learnyouahaskell.com/for-a-few-monads-more)).
Loosely speaking, it allows you to build a computation that is a function
of some context (configuration, session, database connection, etc.), rather than passing the context as an argument to the function.

A Writer is a monad that attaches a log or some other accumulated data to a value.

A nice example of both is given in Tony Morris's [Dependency Injection without the Gymnastics](http://phillyemergingtech.com/2012/system/presentations/di-without-the-gymnastics.pdf),
and the example below will help with the intuition for Reader and Writer too.

(Note that the code below is also available on
 [Github](https://github.com/channingwalton/simple-examples/blob/master/src/main/scala/io/underscore/examples/readerwriter/ReaderWriterDatabase.scala).)

## The Problem

The problem arose working with a database in a web app. Obviously the following are desirable:

  * Operations should run in a transaction/connection/context
  * Transactions should be rolled back in the event of a failure
  * Post commits should be supported

## A Problematic Start

{% highlight scala %}
object TheProblem {

  type Key = String

  object Database {

    // Run a function in a transaction, rolling back on failure
    def run[T](f: => T): T =
      try {
        startTransaction()
        val result = f
        commit()
        result
      } catch {
        case whatever => rollback(); throw whatever
      }

    def startTransaction() = {}
    def commit() = {}
    def rollback() = {}

    def addPostCommit(f: () => Unit): Unit = {}

    def put[A](a: A): Unit = {}

    def find[A](key: String): Option[A] = None
  }

  val result: Option[String] = Database.run {
    Database.put("stuff")
    Database.addPostCommit(() => println("blah"))
    Database.find("foo")
  }
}
{% endhighlight %}

Wow. Side-effect-tastic. But typical.

The first problem is that devs must remember to use 'run' to get transactions as there is no compile time enforcement. In our case the framework
we were using would just magic one up, who knows what was going on.

Another problem is the lack of an explicit declaration of the context code is running in so that devs have no idea whether code is running database
work or not. And since the only error management is exceptions, code becomes very guarded and messy.

So, nested calls to 'run', no calls to 'run', no way to know if functions make database calls so layers of abstraction above the database look like
simple functions, all contribute to a confused state of affairs.

Lets solve the transaction problem first.

## Introducing the Reader

Note that to compile the following code you need [Scalaz 7.0.6](https://github.com/scalaz/scalaz).

{% highlight scala %}
object ReaderToTheRescue {

  import scalaz.Reader

  type Key = String

  trait Transaction

  /* Work represents a unit of work to do against the Database
   * It is a type alias for a scalaz.Reader, which wraps
   * a Transaction => A
   */
  type Work[+A] = Reader[Transaction, A]

  object Database {

    object MyTransaction extends Transaction

    // Run now requires Work
    def run[T](work: Work[T]): T =
      try {
        startTransaction()
        val result = work.run(MyTransaction)
        commit()
        result
      } catch {
        case whatever => rollback(); throw whatever
      }

    def startTransaction() = {}
    def commit() = {}
    def rollback() = {}

    // lift operations into Work - note both of these do nothing here
    def put[A](key: Key, a: A): Work[Unit] =
      Reader(Transaction => {})

    def find[A](key: Key): Work[Option[A]] =
      Reader(Transaction => None)
  }

  // the program
  val work: Work[Option[String]] =
    for {
      _ <- Database.put("foo", "Bar")
      found <- Database.find[String]("foo")
    } yield found

  // now run the program
  val result: Option[String] = Database.run(work)
}
{% endhighlight %}

###  Observations

Everything is now in for-comprehensions rather than the usual imperative style.
The value returned from the for-comprehension is a Work[A], so nothing happens until that Work is run in Database.run.

Importantly, it is no longer possible to operate on the Database outside of a Transaction.

Any functions building on the Database will return Work[A] thus making it very obvious what the context of those functions are.
In the project that this example comes from, this alone revealed a number of of sins which were resolved resulting in clearer
code.

## What about post-commits and errors?

We will solve the post commits issue using a Writer that accumulates post commits - functions run when the transaction succeeds. But,
to avoid wrapping the Reader in a Writer, and getting nested for-comprehensions as a result,
a [monad transformer](http://underscoreconsulting.com/blog/posts/2013/12/20/scalaz-monad-transformers.html) will be used to combine the Reader with the Writer. Fortunately,
scalaz provides a ReaderWriterState monad which will suffice if we ignore the State, setting it to Unit.

Errors will be handled by scalaz's answer to scala's Either, \/[Throwable, A], with the left being an exception and the right being the result.

{% highlight scala %}
object ReaderWriterForPostCommits {

  import scalaz.Scalaz._
  import scalaz._

  type Key = String

  trait Transaction

  // A class to hold the post commit function
  case class PostCommit(f: () => Unit)

  /* Work represents some work to do on the Database
   * It is a Reader that takes a Transaction and returns a result
   * It is a Writer that records post commit actions in a List
   * It is also a State which is ignored here
   * ReaderWriterState's type args are:
   *   the Reader type, Writer type, State type and A
   */
  type Work[+A] =
    ReaderWriterState[Transaction, List[PostCommit], Unit, A]

  // helper to create Work for some Transaction => T
  def work[T](f: Transaction => T): Work[T] =
    ReaderWriterState {
      (trans, ignored) => (Nil, f(trans), ())
    }

  // helper to create Work for a post commit,
  // PostCommits are added to the written value
  def postCommit(f: () => Unit): Work[Unit] =
    ReaderWriterState {
      (trans, ignored) => (List(PostCommit(f)), (), ())
    }

  object Database {

    object MyTransaction extends Transaction

    // a convenient method to drop the state part of the result
    // and also could be used in tests to check post commits
    def runWork[T](work: Work[T]): (List[PostCommit], T) = {
      val results = work.run(MyTransaction, ())
      val (postCommits, result, ignoredState) = results

      (postCommits, result)
    }

    def run[T](work: Work[T]): \/[Throwable, T] =
      \/.fromTryCatch{
        startTransaction()
        val (postCommits, result) = runWork(work)
        postCommits foreach addPostCommit
        commit()
        result
      }.leftMap(err => {rollback(); err})

    def addPostCommit(pc: PostCommit): Unit = {}
    def startTransaction() = {}
    def commit() = {}
    def rollback() = {}

    def put[A](key: Key, a: A): Work[Unit] =
      work(Transaction => {})

    def find[A](key: Key): Work[Option[A]] =
      work(Transaction => None)
  }

  // The program with a post commit
  val work2: Work[Option[String]] =
    for {
      _ <- Database.put("foo", "Bar")
      _ <- postCommit(() => println("wahey"))
      found <- Database.find[String]("foo")
    } yield found

  // note that the result type is now \/
  val result2: \/[Throwable, Option[String]] =
    Database.run(work2)
}
{% endhighlight %}

Now its impossible to run code outside a transaction, post commits are easily added, errors are returned nicely and not thrown.
Furthermore, operations are easy to test since they return values which can be checked easily, rather than side-effects which must be captured.
