---
layout: event
title: "Macros vs Shapeless vs Code Generation"
type: talk
location: Scala Days Copenhagen
date: 2017-06-01 14:30:00 CET
timezone: CET
duration: 45 mins
navbar: events
course: advanced-shapeless
summary: |
  Dave will talk about
  different approaches to meta-programming in Scala.
  Which techniques work, in which situations, and to what extent?
bookingLinks:
  - text: Sign up for the conference
    url: http://event.scaladays.org/scaladays-cph-2017
---

# Abstract

In this talk we will compare three techniques
for meta-programming in Scala:
macros, shapeless, and code generation.
Through a sequence of simple examples
we will attempt to characterise
the relative pros and cons of each each technique,
where they become appropriate,
and when they might turn around and bite you.

We can solve many Scala programming problems using simple tools:
algebraic data types, higher order functions, and type classes.
Sometimes, however, the code becomes verbose or unwieldy,
and we search for ways to make our code cleaner and more maintainable.
"Meta-programming" is a broad term describing techniques
for generating code using code,
but the meta programming techniques listed above
could not be more different.
Sometimes, being able to identify the correct technique
may save hours of frustration attempting to go down blind alleys.
This is the problem we are trying to solve in this talk.

The talk is aimed at intermediate Scala developers
who have a basic awareness of each technique.
You don't need to know shapeless or macro programming to benefit.
