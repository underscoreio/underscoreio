---
id: essential-scala
title: Essential Scala
layout: course
navbar: training
icon: scala
color: "#e8515b"
courseDirectory:
  level: Beginner
  length: 2 days
  icons: [ book, public, private ]
coursePage:
  showSidebar: true
products:
  selfDirected:
    single:
      type: gumroad
      title: Get the Book
      url: "https://gum.co/essential-scala"
      buttonLabel: "Buy now - $50"
      description: |
        Download the course textbook, complete with exercises and solutions, in HTML, PDF, and ePub formats.
    team:
      type: gumroad
      title: "20% Team Discount"
      url: "https://gum.co/essential-scala-team"
      buttonLabel: "Buy now - <strike>$500</strike> $400"
      description: |
        Get your whole team up to speed with <em>10 licenses</em>
        for Essential Scala at a 20% discount.
  instructorLed:
    public:
      type: public
      title: "Public Courses"
      buttonLabel: "View upcoming events"
      comingSoon: true
    private:
      type: private
      title: "Private Courses"
      buttonLabel: "Book now - {% currencies $7,500 £5,000 €7,000 %}"
---

## Overview

Essential Scala is a two day course aimed at experienced developers who are encountering Scala for the first time. Put your existing skills to use mastering Scala's combination of object-oriented and functional programming.

The course teaches you Scala from the basics of its syntax to advanced problem solving techniques. We place a heavy emphasis on developing the functional programming mindset you need to get the most out of the language. Each section has a practical focus, mixing presentation with in-depth hands-on labs and exercises.

If you are an experienced developer, taking your first steps in Scala and wanting to get up to speed quickly, then this is the course for you.

## Prerequisites

To benefit from this course you should have one or two years' experience with an object-oriented (e.g. Java, C#) or functional (e.g. Haskell, Lisp) programming language, and a good general understanding of object-oriented or functional programming language concepts.

## Learning Outcomes

Take away a working knowledge of object-oriented and functional programming in Scala. Learn the common patterns needed to get the most out of Scala's extensive collections framework.

Develop a conceptual framework by which we can judge good Scala. Use equational reasoning to understand how to read and write simple, testable, scalable programs.

Understand key functional programming concepts and their encoding in Scala:

- Model data using algebraic data types, encoded in Scala as families of sealed traits and case classes.

- Use structural recursion and pattern matching to traverse and transform data.

- Gain a deep understanding of `map`, `flatMap`, and `fold`, the three most important methods for sequencing computations in Scala.

- Learn how to extend existing libraries using type classes---a simpler, more flexible alternative to object oriented inheritance.

Learn how Scala's flexible syntax and laguage features support the creation of fluent interfaces and sophisticated domain specific languages.

## Table of Contents

 - Introduction
   - Expressions, Types, and Values
   - Interacting with Objects
   - Immutability and Equational Reasoning

 - Algebraic Data Types
   - Case Classes and Sealed Traits
   - Structural Recursion
   - Pattern Matching

 - Functions
   - Function Literals
   - Functions as Values
   - Functions as Objects
   - Higher Order Functions and Methods

 - Generics
   - Generic Types and Methods
   - Using Functions to Decouple Concepts
   - Variance

 - Sequencing Computations
   - Map and FlatMap
   - Iterating and Looping
   - Folding
   - For Comprehensions
   - Sequencing Computations

 - Standard Library
   - Packages and Companion Objects
   - Options
   - Tuples
   - Lists, Ranges, and Sequences
   - Maps and Sets

 - Type Classes
   - The Type Class Pattern
   - Implicit Parameters
   - Implicit Values
   - Type Enrichment
   - Combining Type Classes and Type Enrichment

 {% comment %}
 - Growing the Language
   - Operators
   - Special Methods
   - Operator Associativity
   - Custom Control Structures
   - Extractor Patterns
 {% endcomment %}
