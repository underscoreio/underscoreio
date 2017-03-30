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
  duration: "3 days"
  buttonLabel: "Book now - {% currencies $11,250 £7,500 €10,500 %}"
online:
  duration: "6 weeks"
  buttonLabel: "Book now - {% currencies $11,250 £7,500 €10,500 %}"
---

## Overview

Advanced Scala with Cats is aimed at experienced Scala developers who want to take the next step in engineering robust and scalable systems. The course teaches five key abstractions of *monoids*, *functors*, *monads*, *monad transformers*, and *applicative functors*, using the implementations in the Cats library. Through a series of projects we show you how these abstractions can be used to engineer solutions to practical problems in data analysis, data validation, input parsing, error handling, and more.

The main goal of this course is to teach system architecture and design using the techniques of modern functional programming. This means designing systems as small composable units, expressing constraints and interactions via the type system, and using composition to guide the construction of large systems in a way that maintains the original architectural vision.

The course also serves as an introduction to the [Cats][cats] library. We use abstractions from Cats, and we explain the structure of Cats so you can use it without fear in your own code base. The broad ideas are not specific to Cats, but Cats provides an excellent implementation that is beneficial to learn in its own right.

## Prerequisites

To benefit from this course you should have about a year's experience with Scala, or equivalent experience with a functional language such as Haskell, O'Caml, or Lisp.

## Learning Outcomes

- Understand how to express abstractions using type classes
- Learn the key type classes of: Functor, Monoid, Applicative, and Monad.
- Understand how to apply type classes to solve practical problems across a variety of domains.

## Timetable

The course runs over three days, or six weeks if delivered online.

Day one covers:

 - background: algebraic data types and type classes;
 - monoids;
 - functors; and
 - monads.

Day two covers:

 - applicative functors; and
 - case studies.

Day three continues the case studies.

Case studies are chosen by discussion between the teacher and students.

If time is short we can drop the third day, though the longer course is a much bettter experience.

The online course follows a similar pattern but meets one per week for about two hours, and students have to complete homework outside the meeting.
The extra time allows us to cover more material but this only works if the students have sufficient time to complete the homework.
For the majority of people we recommend the onsite course, but if you're sure students can schedule four hours per week for coursework the online course is a good option.

## Written Material

There are two books that accompany Advanced Scala: the Advanced Scala textbook which contains all the course material, exercises, and case studies. There is also a supplemental book called Essential Interpreters that covers the construction of interpreters in three styles: classic untyped interpreters, monadic interpreters, and composable interpreters using the free monad. Interpreters are *the* primal functional programming pattern. To quote Haskell luminary [Don Stewart](http://stackoverflow.com/questions/27852709/enterprise-patterns-with-functional-programming/27860072#27860072) "almost all designs fall into the 'compiler' or 'interpreter' pattern, using a model of the data and functions on that data".

Attendees of any Advanced Scala training course receive a complementary copy of both books. The books are also available for purchase as standalone products.

## Table of Contents - Advanced Scala

- Introduction
  - Anatomy of a Type Class
    - The Type Class
    - Type Class Instances
    - Interfaces
    - Exercise: Printable Library
    - Take Home Points
  - Meet Cats
    - Importing Type Classes
    - Importing Default Instances
    - Importing Interface Syntax
    - Defining Custom Instances
    - Exercise: Cat Show
    - Take Home Points
  - Example: Eq
    - Equality, Liberty, and Fraternity
    - Comparing Ints
    - Comparing Options
    - Comparing Custom Types
    - Exercise: Equality, Liberty, and Felinity
    - Take Home Points
  - Summary
- Monoids and Semigroups
  - Definition of a Monoid
  - Definition of a Semigroup
  - Exercise: The Truth About Monoids
  - Exercise: All Set for Monoids
  - Monoids in Cats
    - The Monoid Type Class
    - Obtaining Instances
    - Default Instances
    - Monoid Syntax
    - Exercise: Adding All The Things
  - Controlling Instance Selection
    - Type Class Variance
    - Identically Typed Instances
  - Applications of Monoids
    - Big Data
    - Distributed Systems
    - Monoids in the Small
  - Summary
- Functors
  - Examples of Functors
  - More Examples of Functors
  - Definition of a Functor
  - Aside: Higher Kinds and Type Constructors
  - Functors in Cats
    - The Functor Type Class
    - Functor Syntax
    - Instances for Custom Types
    - Exercise: Branching out with Functors
  - Contravariant and Invariant Functors
    - Contravariant functors and the contramap method
    - Invariant functors and the imap method
    - What’s With the Name?
  - Contravariant and Invariant in Cats
    - Contravariant in Cats
  - Summary
- Monads
  - What is a Monad?
    - Monad Definition and Laws
    - Exercise: Getting Func-y
  - Monads in Cats
    - The Monad Type Class
    - Default Instances
    - Monad Syntax
  - The Identity Monad
    - Exercise: Monadic Secret Identities
  - Either and Xor
    - Left and Right Bias
    - Creating Xors
    - Transforming Xors
    - Fail-Fast Error Handling
    - Representing Errors
    - Swapping Control Flow
    - Exercise: What is Best?
  - The Eval Monad
    - Eager, lazy, memoized, oh my!
    - Eval’s models of evaluation
    - Eval as a Monad
    - Trampolining and Eval.defer
    - Exercise: Safer Folding using Eval
  - The Writer Monad
    - Creating and Unpacking Writers
    - Composing and Transforming Writers
    - Exercise: Show Your Working
  - The Reader Monad
    - Creating and Unpacking Readers
    - Composing Readers
    - Exercise: Hacking on Readers
    - When to Use Readers?
  - The State Monad
    - Creating and Unpacking State
    - Composing and Transforming State
    - Exercise: Post-Order Calculator
  - Defining Custom Monads
    - Exercise: Branching out Further with Monads
  - Summary
- Monad Transformers
  - A Transformative Example
  - Monad Transformers in Cats
    - The Monad Transformer Classes
    - Building Monad Stacks
    - Constructing and Unpacking Instances
    - Usage Patterns
    - Default Instances
  - Exercise: Monads: Transform and Roll Out
  - Summary
- Cartesians and Applicatives
  - Cartesian
    - Joining Two Contexts
    - Joining Three or More Contexts
  - Cartesian Builder Syntax
    - Fancy Functors and Cartesian Builder Syntax
  - Cartesian Applied to Different Types
    - Cartesian Applied to Future
    - Cartesian Applied to List
    - Cartesian Applied to Xor
    - Cartesian Applied to Monads
  - Validated
    - Creating Instances of Validated
    - Combining Instances of Validated
    - Methods of Validated
    - Exercise: Form Validation
  - Apply and Applicative
    - The Hierarchy of Sequencing Type Classes
  - Summary
- Foldable and Traverse
  - Foldable
    - Folds and Folding
    - Exercise: Reflecting on Folds
    - Exercise: Scaf-fold-ing other methods
    - Foldable in Cats
  - Traverse
    - Traversing with Futures
    - Traversing with Applicatives
    - Traverse in Cats
    - Unapply, traverseU, and sequenceU
  - Summary
- Case Study: Pygmy Hadoop
  - Parallelizing map and fold
  - Implementing foldMap
  - Parallelising foldMap
    - Futures
    - Partitioning Sequences
    - Parallel foldMap
  - Monadic foldMap
    - Exercise: Everything is Monadic
    - Exercise: Seeing is Believing
  - Parallel Monadic foldMap
  - foldMap in the Real World
- Case Study: Data Validation
  - Sketching the Library Structure
  - The Check Datatype
  - Basic Combinators
  - Transforming Data
    - Predicates
    - Checks
  - Kleislis
  - Conclusions
- Case Study: Commutative Replicated Data Types
  - Eventual Consistency
  - The GCounter
    - Simple Counters
    - GCounters
    - Exercise: GCounter Implementation
  - Generalisation
    - Implementation
    - Exercises
  - Abstracting GCounter to a Type Class
  - Summary
- Case Study: Parser Combinators

## Table of Contents - Essential Interpreters

- Untyped Interpreters
  - Abstract syntax trees
  - Folding over ASTs
- Monadic Interpreters
- The Free Monad
  - Natural Transformations
  - Composing Interpreters with Coproducts

## Feedback from Students

> "The concepts are powerful and elegant. Truly something every software engineer should have in their arsenal and which I am now pleased to add to my own. The instructors have a clear command of these foundational principles and are able to communicate them in an intelligible and digestible format, building on concepts from first primitives. My only concern after taking the course was, "when can I come back for more?"

-- David, StumbleUpon

> "The introduction was great and extremely valuable. The actual implementation of a use case –the map-reduce system– is crucial, as it reveals what aspects are more relevant in practical terms."

-- Ignacio, Stanford

> "There was a really good balance between theory and real-world examples. I feel the course will definitely help me to use some of the concepts we learned at work. The learning material is really helpful as well and will help me continue to learn about the most difficult concepts."

-- Emmanuelle, The Guardian

[cats]: http://typelevel.org/cats
