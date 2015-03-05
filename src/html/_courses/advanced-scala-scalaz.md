---
id: advanced-scala-scalaz
title: Advanced Scala with Scalaz
layout: course
navbar: training
icon: scala
color: "#d62a7c"
courseDirectory:
  level: Intermediate
  length: 1 day
  icons: [ book, public, private ]
coursePage:
  showSidebar: true
products:
  selfDirected:
    single:
      type: gumroad
      title: Get the Book
      url: "https://gum.co/advanced-scala-scalaz"
      buttonLabel: "Buy now - $50"
      description: |
        Download the course textbook, complete with exercises and solutions, in HTML, PDF, and ePub formats.
      comingSoon: true
    team:
      type: gumroad
      title: "Get both Books"
      url: "https://gum.co/advanced-scala-scalaz-essential-interpreters"
      buttonLabel: "Buy now - $89"
      description: |
        Download the course textbook, along with advanced material on building interpreters. Both texts come in HTML, PDF, and ePub formats.
      comingSoon: true
  instructorLed:
    public:
      type: eventbrite
      title: "Public Courses"
      url: "http://underscore.io/events/"
      buttonLabel: "View upcoming events"
      description: |
        Courses are currently scheduled for San Francisco and Edinburgh in March.
    private:
      type: private
      title: "Private Courses"
      buttonLabel: "Book now - $3000"
---

## Overview

Advanced Scala with Scalaz is aimed at experienced Scala developers who want to take the next step in engineering robust and scalable systems. The course teaches five key abstractions of *monoids*, *functors*, *monads*, *monad transformers*, and *applicative functors*, using the implementations in the Scalaz library. Through a series of projects we show you how these abstractions can be used to engineer solutions to practical problems in data analysis, data validation, input parsing, error handling, and more.

The main goal of this course is to teach system architecture and design using the techniques of modern functional programming. This means designing systems as small composable units, expressing constraints and interactions via the type system, and using composition to guide the construction of large systems in a way that maintains the original architectural vision.

The course also serves as an introduction to the Scalaz library. We use abstractions from Scalaz, and we explain the structure of Scalaz so you can use it without fear in your own code base. The broad ideas are not specific to Scalaz, but Scalaz provides an excellent implementation that is beneficial to learn in its own right.

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

- Scalaz
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
  - Applicative builders in Scalaz

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
