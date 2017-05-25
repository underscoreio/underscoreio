---
layout: post
title: "Refining your data from configuration to database"
author: "Pere Villega"
---

One of the promises of strongly typed languages is that the compiler will catch your errors instead of throwing unexpected exceptions at runtime. In this post we will cover all stages of an application from model, user input, configuration, and database, seeing how far one can take this approach without hitting a 'diminishing returns' wall.

<!-- break -->

# The prelude

The road to true type safety is not hard, but requires some commitment. At the initial stage you have chosen a typed language that enforces some restrictions at compile time, so you know that if you try the following:

```scala
def add(a: Int, b: Int): Int = a + b

def getHttpQueryParam: String = ???

add(getHttpQueryParam, 2) 

// Error:(10, 8) type mismatch;
      found   : String
      required: Int
      add(queryParam, 2)
          ^
``` 

That is, the code above is warning you that when you obtained a query parameter from a request you got a String, which you are trying to use as an Integer, which won't work. You are forced to convert that String to an Integer first, considering the cases where the String is not a valid Integer, and managing them.

This is nice and saves a lot of hassle, but probably we all have seen a class like follows:

```scala
case class Person(firstName: String, lastName: String)
```

which seems good enough until you start seeing errors due to some method mistakenly passing the `lastName` in the first position, where the `firstName` should go.

There is a standard pattern to solve this issue, using [value classes](http://docs.scala-lang.org/overviews/core/value-classes.html) to ensure the proper values go to the right position:

```scala
class FirstName(val firstName: String) extends AnyVal
class LastName(val lastName: String) extends AnyVal

case class Person(firstName: FirstName, lastName: LastName)
 
val player = Person(new FirstName("Light"), new LastName("Yagami"))
```

This is a common pattern, and most likely something you use daily. Slightly more effort declaring a few new types ensures some silly mistakes won't happen. And thanks to the `AnyVal` magic there is no runtime penalty over using the more generic representation.

But can we do better?

# A case: Refined configuration

Let's consider an area with frequent mistakes: application configuration. In Scala is common to use the [Typesafe Config](https://github.com/typesafehub/config) structure where your configuration is stored in a file, `application.conf`. As such it is not part of the code and you can't apply the previous pattern to it.

Let's assume you have the following in your `application.conf` file:

```
server.interface="0.0.0.0"

server.port=8080
server.port=${?http.port}
```

You could load it manually, which is cumbersome and requires you to convert each type to the proper value. Or you can just use [PureConfig](https://github.com/melrief/pureconfig) to take care of that for you, giving you some extra type safety in the process:

```scala
import pureconfig.loadConfig
import scala.util.{ Failure, Success }

case class Server(interface: String, port: Int)
case class Settings(server: Server)

val config: Settings = loadConfig[Settings] match {
  case Success(conf) => conf
  case Failure(ex) =>
    println(s"Error loading configuration: $ex.\nProgram will now exit.")
    throw ex
}
```

This snippet will automatically load your `application.conf` and map it to a set of nested case classes, `Settings` and `Server`. It will also fail if the configuration doesn't match what you expect. For example a mistake defining the case classes:

```
case class Server(interface: Int, port: Int)
case class Settings(server: Server)
```

will cause an exception when loading the configuration:

```
Error loading configuration: java.lang.NumberFormatException: For input string: "0.0.0.0".
Program will now exit.
java.lang.NumberFormatException: For input string: "0.0.0.0"
```

But some changes, although wrong, will go unnoticed. Let's say you have a typo in the configuration and define your `application.conf` file:

```
server.interface="0.0.0.0"

server.port=808
server.port=${?http.port}
```

Now, port `808` is a reserved port, as are all ports below 1024, so you would need to be root to get hold of it. But if you test the configuration file, even with [PureConfig](https://github.com/melrief/pureconfig), it will succeed as it is a valid value for an Integer.

Can we do better?

Yes, we can. Enter [Refined](https://github.com/fthomas/refined), a [Typelevel project](http://typelevel.org/projects/), a library for refining types with type-level predicates which constrain the set of values described by the refined type. We will see shortly what does this mean in practice.

Luckily [PureConfig](https://github.com/melrief/pureconfig) has a module to [integrate with Refined](https://github.com/melrief/pureconfig#integrating-with-other-libraries), and a very good explanation on how to use both together by [Viktor Lövgren](https://blog.vlovgr.se/posts/2016-12-24-refined-configuration.html).

In our example, this means that we can define two new refined types:

```scala
import eu.timepit.refined.W
import eu.timepit.refined.api.Refined
import eu.timepit.refined.collection.NonEmpty
import eu.timepit.refined.numeric.Greater

type NonEmptyString = String Refined NonEmpty
type ServerPort     = Int Refined Greater[W.`1024`.T]
```

The first type identifies a non-empty string, the second a port for a server ensuring the selected port will not be within the restricted area.

We then modify the way we defined our configuration tree so we take advantage of these new types:

```scala
import pureconfig.loadConfig
import eu.timepit.refined.auto._
import eu.timepit.refined.pureconfig._
import scala.util.{Failure, Success}
  
case class Server(interface: NonEmptyString, port: ServerPort)
case class Settings(server: Server)

val config: Settings = loadConfig[Settings] match {
  case Success(conf) => conf
  case Failure(ex) =>
    println(s"Error loading configuration: $ex.\nProgram will now exit.")
    throw ex
}  
```

Using the incorrect configuration now will return the following error:

```
Error loading configuration: eu.timepit.refined.pureconfig.error.PredicateFailedException: Predicate failed: (808 > 1024)..
Program will now exit.
eu.timepit.refined.pureconfig.error.PredicateFailedException: Predicate failed: (808 > 1024).
```

and we can use it to search for the culprit (value `808`) and understand what went wrong.
Obviously this gets better when you run unit tests on your code that verify the static configuration is valid. You do run them, don't you? Just in case, an example:

```scala
import com.typesafe.config.ConfigFactory
import pureconfig.loadConfig
import eu.timepit.refined.pureconfig._
import org.scalatest.{FreeSpec, Matchers}

import scala.util.{Failure, Success}

class ConfigSpec extends FreeSpec with Matchers {

  "Hardcoded configuration" - {
    // this assumes files 'application.conf', 'application.uat.conf', etc
    val confFiles = List("", ".prod", ".uat").map(s => s"application$s")
    "is valid and can be loaded by pure config" - {
      confFiles.foreach { file =>
        s"Testing config for file $file.conf" in {
          // we load files explicitly, to avoid System.setValue magic
          val tsfConfig = ConfigFactory.load(file)
          loadConfig[Settings](tsfConfig) match {
            case Success(_) =>
              ()
            case Failure(ex) =>
              fail(s"Error loading configuration: $ex.\nProgram will now exit.", ex)
          }
        }
      }
    }
  }

}
```

With this we have removed most of the errors caused by bad configuration. You could even create a custom predicate to ensure the url of your servers are aiming to the right environment servers by using [Refined](https://github.com/fthomas/refined)'s `Regex`. 

I'm quite confident you will easily remember scenarios where stronger validation on your configuration would have saved you pain. We have achieved that, which is great, and all thanks to type safety.

But, can we do better?

# Refining your model

Let's rescue the model we defined in the first section:

```scala
class FirstName(val firstName: String) extends AnyVal
class LastName(val lastName: String) extends AnyVal

case class Person(firstName: FirstName, lastName: LastName)
```

This was an improvement over using `String` everywhere, but it still allows you to do this:
 
```scala
val player = Person(new FirstName(""), new LastName("Yagami"))
```

Which may not be what you want, after all a first name is usually important. So we can convert this model to one that integrates [Refined](https://github.com/fthomas/refined), as we did with our configuration. It is quite easy:

```scala
import scala.util.Random
import eu.timepit.refined._
import eu.timepit.refined.auto._
import eu.timepit.refined.api.Refined
import eu.timepit.refined.collection.NonEmpty

type NonEmptyString = String Refined NonEmpty
class FirstName(val firstName: NonEmptyString)
class LastName(val lastName: NonEmptyString)
 
case class Person(firstName: FirstName, lastName: LastName)
Person(new FirstName(""), new LastName("Yagami"))
```

which will fail compilation with:

```
 error: type mismatch;
 found   : String("")
 required: NonEmptyString
    (which expands to)  eu.timepit.refined.api.Refined[String,eu.timepit.refined.boolean.Not[eu.timepit.refined.collection.Empty]]
    Person(new FirstName(""), new LastName("Yagami"))
                        ^
```

So we avoid more errors in our model thanks to typed. But, of course, most of our data is not hardcoded, but comes from external sources. If you try to define a single String variable and pass it to refine, it will complain at compile time about a type mistmatch. How do we solve this?

Refined itself provides the solution by allowing us to use the same refined types we defined for validation. An example:

```scala
import scala.util.Random
import eu.timepit.refined._
import eu.timepit.refined.string._
import eu.timepit.refined.auto._
import eu.timepit.refined.api.Refined
import eu.timepit.refined.collection.NonEmpty

type NonEmptyString = String Refined NonEmpty

val refinedNonEmptyName: Either[String, String Refined NonEmptyString] =
    refineV[NonEmptyString](if(Random.nextBoolean()) "" else "Light")
```

the snippet above uses `refineV` and our definition of `NonEmptyString` to create a validation method that returns an `Either`. If the string is valid we will gt a `Right(NonEmptyString)`, otherwise a `Left(String)` with the error message.

Initially this may look like additional boilerplate to restrict the types, and one may wonder if it is worth the effort. But the truth is we always need to validate data coming from outside the system and this approach forces us to make sure any contact with data outside our inner model is properly secured. You can't be lazy and just accept a possibly wrong value when the compiler doesn't allow you :)

At this point, if we stop and recap what we have done, we see that we have an application that has strongly typed configuration, avoiding common pitfalls like typos or bad selection of ports for the server.

Our application also has a clearly defined model that, by virtue of its types, makes it impossible to have invalid states like a person without a name. This is more important that in seems, as you know at the point you send the data to another service or when you render the details on a website that the value will always be present. 

And, lastly, our application enforces, at compile time, that all the data that is used to generate our internal model has been validated. There is no scope to skip that, besides hardcoding a value, which ensures we reject invalid states from the outset.

But, again, can we do better?

# The last frontier: the database

The summary above is lacking one last element: our interactions with the database. We like to use [Doobie](https://github.com/tpolecat/doobie), Typelevel's pure functional JDBC layer for Scala, when working with the database.

As our model disallows invalid states we can assume that all the data in the database will be compliant and we just need for Doobie to build our case class from the data. Something like:

```scala
  def getAllPersons[M[_]](xa: Transactor[M]) =
    sql"SELECT firstName, lastName FROM Person"
      .query[Person]
      .process
      .list
      .transact(xa)
```

Which is sound, and it would be great except... it doesn't compile. Doobie currently doesn't support Refined types. This could be a show stopper, as if we can't store our perfect and valid model to a database, maybe it's not so useful after all. 

Luckily thanks to [@beefyhalo](https://twitter.com/beefyhalo) an his comments on [Gitter](https://gitter.im/tpolecat/doobie/archives/2015/12/22) we can add a couple of implicits that make things work:

```scala
// allows generation of doobie Meta objects from Refined types
implicit def refinedMeta[T: Meta, P, F[_, _]](implicit tt: TypeTag[F[T, P]],
                                                ct: ClassTag[F[T, P]],
                                                validate: Validate[T, P],
                                                refType: RefType[F]): Meta[F[T, P]] =
    Meta[T].xmap(refType.refine[P](_) match {
      case Left(err) => throw InvalidObjectMapping(ct.runtimeClass, ct.getClass)
      case Right(t)  => t
    }, refType.unwrap)

// allows generation of doobie Composite objects from Refined types
implicit def refinedComposite[T: Composite, P, F[_, _]](implicit tt: TypeTag[F[T, P]],
                                                          ct: ClassTag[F[T, P]],
                                                          validate: Validate[T, P],
                                                          refType: RefType[F]):  Composite[F[T, P]] =
    Composite[T].imap(refType.refine[P](_) match {
      case Left(err) => throw InvalidObjectMapping(ct.runtimeClass, ct.getClass)
      case Right(t)  => t
    })(refType.unwrap)
```

With these Doobie is happy again and all your code compiles. Well, you can either use this or you can wait for [Doobie 0.4.2](https://github.com/tpolecat/doobie/pull/456) to have direct native support!

And so, we have achieved it: now we have a strongly refined model for our application that brings the benefits of type safety from configuration to the database. No diminishing returns and minimal boilerplate on top, to bring the benefit of finding errors at compile time and to banish invalid state from your application.

Say goodbye to invalid state and the mysterious bugs it causes!


