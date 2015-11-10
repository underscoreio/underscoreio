---
id: advanced-scala-scalaz
title: Advanced Scala with Scalaz
layout: book
navbar: books
icon: scala
color: "#d62a7c"
level: Intermediate
price: "$50"
description: Advanced Scala with Scalaz is aimed at experienced Scala developers who want to take the next step in engineering robust and scalable systems. The book teaches five key abstractions of *monoids*, *functors*, *monads*, *monad transformers*, and *applicative functors*, using the implementations in the Scalaz library.
products:
  selfDirected:
    single:
      type: gumroad
      title: Get the Book
      url: "https://gum.co/advanced-scala-scalaz"
      buttonLabel: "Buy now - $50"
      cover: "/images/books/advanced-scala.png"
      description: |
        Download the textbook, complete with exercises and solutions, in HTML, PDF, and ePub formats.
    team:
      type: gumroad
      title: "Get both Books"
      url: "https://gum.co/advanced-scala-scalaz-essential-interpreters"
      buttonLabel: "Buy now - $89"
      cover: "/images/books/essential-interpreters.png"
      description: |
        Download Advanced Scala along with additional material on building interpreters. Both books come in HTML, PDF, and ePub formats.
bookPage:
  showSidebar: true
---

## Overview

The main goal of this book is to teach system architecture and design using the techniques of modern functional programming. This means designing systems as small composable units, expressing constraints and interactions via the type system, and using composition to guide the construction of large systems in a way that maintains the original architectural vision.

The book also serves as an introduction to the Scalaz library. We use abstractions from Scalaz, and we explain the structure of Scalaz so you can use it without fear in your own code base. The broad ideas are not specific to Scalaz, but Scalaz provides an excellent implementation that is beneficial to learn in its own right.

## Prerequisites

To benefit from this book you should have about a year's experience with Scala, or equivalent experience with a functional language such as Haskell, O'Caml, or Lisp.

## Learning Outcomes

- Understand how to express abstractions using type classes
- Learn the key type classes of: Functor, Monoid, Applicative, and Monad.
- Understand how to apply type classes to solve practical problems across a variety of domains.

## Supplemental

Essential Interpreters covers the construction of interpreters in three styles: classic untyped interpreters, monadic interpreters, and composable interpreters using the free monad. Interpreters are *the* primal functional programming pattern. To quote Haskell luminary [Don Stewart](http://stackoverflow.com/questions/27852709/enterprise-patterns-with-functional-programming/27860072#27860072) "almost all designs fall into the 'compiler' or 'interpreter' pattern, using a model of the data and functions on that data".
