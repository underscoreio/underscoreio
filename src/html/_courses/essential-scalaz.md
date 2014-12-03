---
id: essential-scalaz
title: Essential Scalaz
layout: course
navbar: training
icon: scalaz
color: "#d62a7c"
courseDirectory:
  level: Intermediate
  length: 1 day
  icons: [ book, public, private ]
products:
  selfDirected:
    single:
      type: gumroad
      title: Get the Book
      url: "https://gum.co/essential-scalaz"
      buttonLabel: "Buy now - $50"
      description: |
        Download the course textbook, complete with exercises and solutions, in HTML, PDF, and ePub formats.
      comingSoon: true
    team:
      type: gumroad
      title: "20% Team Discount"
      url: "https://gum.co/essential-scalaz"
      buttonLabel: "Buy now - <strike>$500</strike> $400"
      description: |
        Get your whole team up to speed with a <em>10 developer license</em> for 20% off individual pricing.
      comingSoon: true
  instructorLed:
    public:
      type: public
      title: "Public Courses"
      buttonLabel: "Register your interest"
      comingSoon: true
    private:
      type: private
      title: "Private Courses"
      buttonLabel: "Book now - $3000"
---

## Overview

Essential Scalaz is aimed at experienced Scala developers who want to take the next step in engineering robust and scalable systems. The course focuses on four key abstractions in the Scalaz library: *Monoid*, *Functor*, *Applicative Functor*, and *Monad*. Through a series of mini-projects we shouw you how to apply these abstractions across a broad range of practical problems.

The Scalaz library provides a variety of abstractions taken from abstact algebra. These abstractions are incredibly general---so general that many developers have difficulty understanding how they apply to practical issues. In fact Scalaz is eminently practical, and it is the generality of the abstractions that allows them to apply to a wide range of problem domains.

## Prerequisites

To benefit from this course you should have about a year's experience with Scala, or equivalent experience with a functional language such as Haskell, O'Caml, or Lisp.

## Learning Outcomes

- Understand how to express abstractions using type classes
- Learn the key type classes in Scalaz: Functor, Monoid, Applicative, and Monad.
- Explore how to apply type classes in solving real world problems in analytics, web services, and more.

## Table of Contents

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

- Applicative
  - The definition of Applicative
  - Applicative validation
  - Applicative builders in Scalaz
