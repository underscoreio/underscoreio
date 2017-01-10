---
layout: post
title: "Option is not a replacement for Null"
author: "Channing Walton"
---

Option seems to cause a lot of confusion. These are some of the things said
about it:

[Tired of Null Pointer Exceptions? Consider Using Java SE 8's Optional!](http://www.oracle.com/technetwork/articles/java/java8-optional-2175753.html)

[Optional object is used to represent null with absent value.](https://www.tutorialspoint.com/java8/java8_optional_class.htm)

[Java 8 Optional: What's the Point?](http://huguesjohnson.com/programming/java/java8optional.html)

[Java 8: Removing null checks with Optional](http://www.deadcoderising.com/2015-10-06-java-8-removing-null-checks-with-optional/)

There are many discussions on twitter and other forums about it too.

The basic argument and central confusion is that Option is some kind of
replacement for null.

It isn't. That idea is precisely backwards. The use of null in code to represent
a missing value is a very poor substitute for modelling optional values
properly, as a type.

An Option is used to represent a value *that may not exist*. A value that is
*optional*. That is all.

In languages supporting modern type systems, like Scala, it is possible for
types to support a number of powerful abstractions such as Functor, Applicative,
and Monad that make working with Options, amongst other things, convenient.

There are languages, such
as [Kotlin](https://kotlinlang.org/docs/reference/null-safety.html)
or
[Ceylon](https://ceylon-lang.org/documentation/reference/operator/nullsafe-member/),
that offer special support for values that may not exist. For managing libraries
that return null from methods or functions, that is great and possibly useful.
But using these features as an alternative to Option is a mistake. Doing so
makes values communicate nothing about their optionality, complicates the
language, and removes the possibility of composition and abstraction (functors,
monad, etc.).

In summary, do not use null as a substitute for an optional value. Doing so is
lazy, leads to bugs, and is a poor substitute for modelling optional values.
