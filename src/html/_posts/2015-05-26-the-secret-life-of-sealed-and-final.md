---
layout: post
title: The Secret Life of Sealed and Final
author: Noel Welsh
---

Sealed and final traits and classes are essential for idiomatic Scala code, but many developers are hazy on the details of their workings. In this post we describe why you want to use them, and how to use them correctly to increase the guarantees you can make about your code.

<!-- break -->

# Why Sealed and Final?

We can explain sealed and final in terms of their low-level semantics, but I find it much more useful to start with the big picture. The most important use of sealed and final is in defining *algebraic data types*. Algebraic data types are really really important. The standard library, for example, is chock full of them (`Option`, `List`, and `Try` are some examples) and in our experience well written Scala code bases continue this pattern.

Despite their fancy name, algebraic data types are just a way of defining data in terms of two patterns:

- *logical ors*, such as [`List`][list] is a `::` or `Nil`; and
- *logical ands*, such as [`::`][double-colon] has a `head` and `tl`.

These two patterns have a corresponding implementation in Scala[^full-pattern]:

~~~ scala
sealed trait List[+A] {
  // lotsa methods in here ...
}
final case class ::[A](head: A, tl: List[A]) extends List[A]
final case class Nil extends List[Nothing]
~~~



[double-colon]: http://www.scala-lang.org/api/2.11.6/#scala.collection.immutable.$colon$colon
[list]: http://www.scala-lang.org/api/2.11.6/#scala.collection.immutable.List

[^full-pattern]: ...
