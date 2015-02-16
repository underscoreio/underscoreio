---
layout: post
title: Designing Error Handling
author: Noel Welsh
---

In this post I want to explore the design space for error handling techniques in Scala. We previously [posted]({ post_url 2015-02-13-error-handling-without-throwing-your-hands-up }) about some basic techniques for error handling in Scala. That post generated quite a bit of discussions. Here I want to show how we can systematically move from goals to solution, introduce some moderately advanced techniques, and discuss some of the tradeoffs.

## Goals

Our first goal is to **stop as soon as we encounter an error**, or in other words, fail-fast. Sometimes we want accumulate all errors -- for example when validating user input -- but this is a different problem and leads to a different solution.

Our second goal is to **guarantee we handle every error we intend to handle**. As every programmer knows, if you want something to happen every time you get a computer to do it. In the context of Scala this means using the type system to guarantee that **code that does not implement error handling will not compile**.

There are two corollaries of this:

1. if there are error we don't care to handle, perhaps because they are so unlikely, or we cannot take any action other than crashing, or the type of software we are writing just doesn't demand high reliability, don't model them; and

2. if we add or remove an error type that we do want to handle the computer must force us to update the code.

## Design

There are two elements to our design:

- how we represent the act of encountering an error (to give us fail-fast behaviour); and
- how we represent the information we store about an error.

## Exceptions and Monads

Our two tools for fail-fast behaviour are exceptions and monads.

We can immediately discard using exceptions. Exceptions are unchecked in Scala, meaning the compiler will not force us to handle them. Hence they won't meet our second goal.

Monads implement fail-fast. flatMap must be fail-fast. `Option`, `Try`, `Either`, and `\/`

## Representing Errors

We want debugability. Drop `Option` because we can't include any information on the error.

`Try` always stores a `Throwable`. What is a `Throwable`? Could be just about anything. No exhaustiveness checking. Can't make guarantees we'll handle all the error cases (goal two).

`Either` allows us to store any type we want as the error case. Can store an algebraic data type, get exhaustiveness checking. `Either` is a PITA to use. Just use `\/` which is a right-biased equivalent (explain this in more detail).

How do we represent errors? Two ways:

- a normal ADT. We can lose location information, but we can regain this with macros
- a sealed subclass of `Exception`. Then we get stack traces.

Which one? It doesn't greatly matter. The former requires a bit more infrastructure, mostly in setting up the macros. The latter bring along a bunch of stuff from `Exception` that we might not want.

Either way, we need to catch exceptions that badly behaved code we call might raise. Define an ADT to represent errors at each system boundary (don't try to create one error ADT for the entire application; it doesn't work). Include one case for "other" or "unexpected" errors. Use this to hold exceptions. Utility function to wrap a block and convert exceptions to this case.

Example project

## Conclusions

This meets all our goals. If we have weaker goals we can use weaker methods. For example, many people like `Try`. If you can accept losing the guarantees on error handling it imposes, use that. 

