---
layout: post
title: The Secret Life of Sealed and Final
author: Noel Welsh
---

Sealed and final traits and classes are essential for idiomatic Scala code, but many developers are hazy on the details of their workings. In this post we describe why you want to use them, and how to use them correctly to increase the guarantees you can make about your code.

<!-- break -->

# Algebraic Data Types

We can explain sealed and final in terms of their low-level semantics, but I find it much more useful to start with the big picture. The most important use of sealed and final is in defining *algebraic data types*. Algebraic data types are really really important. The standard library, for example, is chock full of them (`Option`, `List`, and `Try` are some examples) and in my experience well written Scala code bases are chock full of them too.

Despite their fancy name, algebraic data types are just a way of modelling data in terms of two patterns:

- *logical ors*, such as [`List`][list] is a `::` or `Nil`; and
- *logical ands*, such as [`::`][double-colon] has a `head` and `tl`.

In functional programming lingo we call the logical or a *sum type* and the logical and a *product type*.

You can probably think of examples from your own work. A common example is modelling different types of users. You might have a structure like a `Account` is an `Admin` or a normal `User`. An `Account` will have certain properties like an `emailAddress`, a `username` and so on, and `Admin`s probably have properties unique to them (such as an `accessLevel`). This complex definition is just an algebraic data type --- it is defined entirely in terms of ands and ors --- and we can mechanically translate this description into code.

I won't go into the detailed implementation of the sum and product type patterns in Scala here, but let's see a quick example for `List`[^full-pattern]:

~~~ scala
sealed trait List[+A] {
  // lotsa methods in here ...
}
final case class ::[A](head: A, tl: List[A]) extends List[A]
final case class Nil extends List[Nothing]
~~~

Notice the use of `sealed` and `final`.

## Structural Recursion

So, algebraic data types are really useful and we define them using `sealed` and `final`, but what does these two keywords actually get us? It's time to look at how we write code that uses algebraic data types. This also has a fancy name, *structural recursion*, but the basic idea is simple.

Let's start with a very familiar example, `Option`. `Option` is `Some` or `None` (a sum type), and `Some` has an element `x` (a product type, albeit a very simple one). How do we write a `match` expression for `Option`? We need:

- one case for `Some` and one for `None`; and
- the case for `Some` should do something with the element `x`.

In code

~~~ scala
anOption match {
  case None    => doNoneCase
  case Some(x) => doSomeCase(x)
}
~~~

We can abstract this pattern to any algebraic data type, and this is all that structural recursion is.

Now we've seen three neat things: we can model a very general class of data as algebraic data types, we can mechanically convert an algebraic data type into Scala definitions, and we can mechanically write Scala code use any algebraic data type via structural recursion. But we still haven't said what `sealed` and `final` get us. Let me seal the deal and finally explain their importance.

## Exhaustiveness Checking

When we define an algebraic data type using `sealed` traits and `final` case classes we allow the compiler to perform exhaustiveness checking for us. In simpler terms, this means the compiler will shout at us if we miss out a case in our structural recursion.

Here's an example at the Scala console:

~~~ scala
scala> Option(1) match {
     |   case None => "Yeah"
     | }
<console>:8: warning: match may not be exhaustive.
It would fail on the following input: Some(_)
              Option(1) match {
                    ^
~~~

This is great. For example, if we change the definition of an algebraic data type (say we add a new type of `User`) the compiler will tell us every place in our code base that needs to be updated! Exhaustiveness checking allows us to make stronger guarantees about the correctness of our code, but only if we write our code in a way that tells the compiler everything it needs to know to do these checks for us. Scala has a simple rule: if you want exhaustiveness checking you must ensure that everything about a given type is defined in one file. This is where `sealed` and `final` come in.

## Finally, Sealed and Final

A `sealed` trait can only be extended within the file in which it defined. A `final` class cannot be extended anywhere.

We use `sealed` traits to define product types (logical ors). As the compiler knows all the subtypes are defined within the same file it can check ...

final ...

sealed is *not* transitive.

[double-colon]: http://www.scala-lang.org/api/2.11.6/#scala.collection.immutable.$colon$colon
[list]: http://www.scala-lang.org/api/2.11.6/#scala.collection.immutable.List

[^full-pattern]: In addition to illustrating sum and product types, this example also contains covariance. I decided it was better to use a more realistic example in this blog post, rather than an abstract definition showing just sum and product types.
