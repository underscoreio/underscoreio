---
id: advanced-scala
title: Advanced Scala with Cats
layout: course
navbar: training
icon: cats
color: "#d62a7c"
level: Intermediate
book: advanced-scala
summary: |
  Dive deep into functional patterns using Scala and Cats.
  For experienced Scala developers.
onsite:
  duration: "2 days"
  buttonLabel: "Book now - {% currencies $7,500 £5,000 €7,000 %}"
online:
  duration: "6 weeks"
  buttonLabel: "Book now - {% currencies $7,500 £5,000 €7,000 %}"
---

## Overview

Advanced Scala with Cats is aimed at experienced Scala developers who want to take the next step in engineering robust and scalable systems. The course teaches five key abstractions of *monoids*, *functors*, *monads*, *monad transformers*, and *applicative functors*, using the implementations in the Cats library. Through a series of projects we show you how these abstractions can be used to engineer solutions to practical problems in data analysis, data validation, input parsing, error handling, and more.

The main goal of this course is to teach system architecture and design using the techniques of modern functional programming. This means designing systems as small composable units, expressing constraints and interactions via the type system, and using composition to guide the construction of large systems in a way that maintains the original architectural vision.

The course also serves as an introduction to the Cats library. We use abstractions from Cats, and we explain the structure of Cats so you can use it without fear in your own code base. The broad ideas are not specific to Cats, but Cats provides an excellent implementation that is beneficial to learn in its own right.

## Prerequisites

To benefit from this course you should have about a year's experience with Scala, or equivalent experience with a functional language such as Haskell, O'Caml, or Lisp.

## Learning Outcomes

- Understand how to express abstractions using type classes
- Learn the key type classes of: Functor, Monoid, Applicative, and Monad.
- Understand how to apply type classes to solve practical problems across a variety of domains.

## Written Material

There are two books that accompany Advanced Scala: the Advanced Scala textbook which contains all the course material, exercises, and case studies. There is also a supplemental book called Essential Interpreters that covers the construction of interpreters in three styles: classic untyped interpreters, monadic interpreters, and composable interpreters using the free monad. Interpreters are *the* primal functional programming pattern. To quote Haskell luminary [Don Stewart](http://stackoverflow.com/questions/27852709/enterprise-patterns-with-functional-programming/27860072#27860072) "almost all designs fall into the 'compiler' or 'interpreter' pattern, using a model of the data and functions on that data".

Attendees of any Advanced Scala training course receive a complementary copy of both books. The books are also available for purchase as standalone products.

## Table of Contents - Advanced Scala

- Type classes
  - Type classes as ad-hoc polymorphism
  - Type class implementation in Scala

- Cats
  - Code organisation
  - Relationship to other libraries

- Show and Equal

- Monoid
  - The definition of Monoid
  - Basic examples
  - Extended analytics example

- Controlling type class selection
  - Unboxed tags
  - Value classes

- Functor
  - Functor definition
  - Higher-kinded types
  - Implementation in Scala

- Monad
  - The definition of Monad
  - Monads for error handling
  - Monads for concurrency
  - "Reader, Writer, and more"

- Monad Transformers
  - Squashing a stack of monads
  - Constructing and deconstructing monad stacks
  - Lifting into monad stacks

- Applicative
  - The definition of Applicative
  - Applicative validation
  - Applicative builders in Cats

- Case Study: MapReduce

- Case Study: Validation

- Case Study: Parser Combinators

## Table of Contents - Essential Interpreters

- Untyped Interpreters
  - Abstract syntax trees
  - Folding over ASTs

- Monadic Interpreters

- The Free Monad
  - Natural Transformations
  - Composing Interpreters with Coproducts
