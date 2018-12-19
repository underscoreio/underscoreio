---
layout:     post
title:      Our Talks from 2018
author:     Team Underscore
date:       '2018-12-21 09:00:00'
---

This posts collects together our talks from 2018.
Inside you'll find a delicious selection of topics, including:
algebras, interpreters, DLSs, compiler enhancements, avoiding string typing, and deep learning.
Enjoy, and come over and say hi to us if you're at a Scala conference in 2019.

<!-- break -->

# Droidspeak: A DSL for constructing binary decision trees in a friendly way

### Doug Clinton and Martin Carolan, flatMap (Oslo).

<iframe width="560" height="315" src="https://www.youtube.com/embed/pTCR-VfBB0s?start=6" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

Doug and Martin described how they captured a customer's business processes in a DSL.
A consequence is that the decision process was provably complete. I.e., no gaps in the complex decisions being made.
It's also a nice example of a cycle of: delivering working software, learning more, refining the software.


# Adding kind-polymorphism to the Scala programming language

### Miles Sabin, Curry On

<iframe width="560" height="315" src="https://www.youtube.com/embed/WtPFvLfHYtM" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

Moar Polymorphism FTW!

Shapeless is the tool that people reach for when they have problems involving abstraction over data types of different shapes and sizes. But suppose we wanted to support this sort of data type generic programming directly in Scala? What sort of primitive mechanisms would we choose?

In this talk, Miles argued that kind-polymorphism, the ability to abstract over type constructors of any arity, is one we should give serious consideration to.
He demonstrate a prototype implementation in the Typelevel compiler and show how it can be used to dramatically simplify generic programming in Scala.

# Functional interpreters and you

### Dave Gurnell, Scala Days

<iframe width="560" height="315" src="https://www.youtube.com/embed/MfpXcaG-Wog" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

Mark Mynsted also presented a version of <a href="https://slideslive.com/38908795/functional-interpreters-and-you">this talk at Scala Days New York</a>.

Phrases like "free monads" and "finally tagless" get thrown around in the Scala community like they're going out of fashion.
But what do they mean and why are they so popular?

In this talk Dave discussed "interpreters", an essential functional programming pattern that underpins these terms.
It shows: how any problem in functional programming can be described using the interpreter pattern, and how modelling things this way naturally gives rise to abstractions like the free monad and encodings like finally tagless.


# Why do Functional Programmers always talk about Algebra(s)?

### Adam Rosien, Fun(c)

<iframe width="560" height="315" src="https://www.youtube.com/embed/s2ay9nEW3ak" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

Adam shows us what an algebra is, tells us why functional programmers talk about them constantly, and how you can use them in your projects.
Algebras *are* structure, and he talks about their various forms: algebraic data types, F-algebras, object algebras, and more!


# Strings are Evil: Methods to hide the use of primitive types

### Adam Rosien and Noel Welsh, Scala Days Berlin

<iframe width="560" height="315" src="https://www.youtube.com/embed/w7FuQiSi48w" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

Most primitive types we use are "too wide" for how we are using them; for example, there are an infinite number of Strings, but we are only using the String (hex!) representation of a 128-bit UUID.
This is a huge source of bugs in our programs.

This talk went go over the many ways we can reduce these kinds of errors in Scala, such as wrapper types, refined types, type restrictions, and more.

# Differentiable Functional Programming

### Noel Welsh, Scala Days Berlin

<iframe width="560" height="315" src="https://www.youtube.com/embed/nETDYWAHAfE" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

What do deep learning and functional programming have in common?

In this talk Noel explored the basic ideas behind deep learning, and deep learning frameworks like Tensorflow.
He showed that underpinning it all are concepts familiar to functional programmers.

He then implemented a toy deep learning system in Scala, and speculated a bit on the future of deep learning frameworks and the rise of "differentiable programming".




