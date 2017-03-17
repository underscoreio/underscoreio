---
layout: event
title: "Adventures in Meta-Programming"
type: talk
location: Scalar Warsaw
date: 2017-04-07 09:00:00 CET
timezone: CET
duration: 30 mins
navbar: events
course: advanced-shapeless
summary: |
  Dave will talk about fun things to do with meta-programming in Scala.
  Which techniques work, in which situations, and to what extent?
bookingLinks:
  - text: Sign up for the conference
    url: http://scalar-conf.com
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
