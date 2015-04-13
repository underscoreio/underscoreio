---
layout: post
title: Free Monads Are Simple
author: Noel Welsh
date: '2015-03-05'
---

I recently gave a talk at the Advanced Scala meetup in London on free monads. Despite the name of the group, I think that free monads are eminently simple as well as being extremely useful. Let me explain. 

<!-- break -->

The free monad brings together two concepts, monads and interpreters, allowing the creation of composable monadic interpreters. That's a bunch of big words, but why should we care? Because it allows simple solution to difficult problems.

Take the example of Facebook's Haxl and Twitter's Stitch. Both systems solve a problem faced by companies that have aggressively adopted a service oriented architecture:[^etsy] service orchestration. Consider rendering a user's Twitter stream. Hypothetically, the process might first retrieve the list of recent tweets from one service. Then for each tweet it might fetch the tweeter's name and picture to go alongside the tweet, which could require a request to two more services. No doubt there are logging and analytics services that would also be involved. All told a great number of services and requests can be involved in answering what is a single request from the UI perspective. With this explosion of requests there are a number of problems: increased network traffic, increased latency (which goes hand-in-hand with traffic), and consistency. The last point deserves some explanation. Imagine two tweets by the same person are in the stream. Their details could change inbetween fetching the name and photo for the first and second tweet. If we allow this inconsistency to occur it makes for a very poor user experience, as the user can't tell at a glance that the two tweets are by the same person. It's fairly clear that we could avoid this inconsistency *and* solve our network traffic and latency issues if we just cached data. We could implement this by writing special-purpose request aggregation and caching for each request type, which is quickly going to be a losing battle as APIs and interfaces evolve. Or we could write a general purpose tool that allows us to describe the data we need and takes care of the optimisation for us. The free monad allows us to easily do this. Sold? Ok, let's get back to describing the free monad.

## Monads

Remember I said the free monad brings together monads and interpreters. Let's start with the monad part. I'm going to assume you understand monads already. If not, don't worry. They're just like cats or burritos or something.

Now recall that a monad is defined by two operations[^laws], `point` and `flatMap`, with signatures

- `point[M[_], A](a: A): M[A]`; and
- `flatMap[M[_], A, B](fa: F[A])(f: A => F[B]): F[B]`.

`Point` is not very interesting -- it just wraps a monad around a value. `FlatMap` is, however, the distinguishing feature of a monad and it tells us something very important: *monads are fundamentally about control flow*. You see, the signature of `flatMap` says you combine a `F[A]` and a function `A => F[B]` to create a `F[B]`. The only way to do this is to get the `A` out of the `F[A]` and apply it to the `A => F[B]` function. There is a clear ordering of operations here, and repeated applications of `flatMap` creates a sequence of operations that must execute from left to right. So we see that monads explicitly encode control flow.

There are two monads facts that relate to this. First, the continuation monad can be used to encode any other monad. What is a continuation? It's a universal control flow primitive. *Any* control flow can be expressed using continuations. Second, monads we originally proposed to model programming language semantics, and in particular control flow.

To repeat, the take home points are:

1. monads are for modelling control flow; and
2. control flow is an important part of constructing a programming language.

## Interpreters

Ok, so that's monads: control flow. What about interpreters. Interpreters are about separating the representation of a computation from the way it is run. Any interpreter has two parts[^two-parts]:

1. an *abstract syntax tree* (AST) that represents the computation; and
2. a process that gives meaning to the abstract syntax tree. That is, the bit that actually runs it.

A simple example is in order. Consider the expression `1 + 2 + 3`. We can execute this directly, evaluating to `6`, or we could represent it as an abstract syntax tree such as `Add(1, Add(2, 3))`. Given the AST we could choose from many different ways to interpret it:

- We could represent results using `Ints`, `Doubles`, or arbitrary precision numbers.
- We could perform our calculations using [dual numbers][dual-numbers], calculating the derivative at the same time (very useful for machine learning applications).
- We could transform our calculation to run on the processor's vector unit, or on a GPU.

Hopefully this gives you a feel for the structure and power of the interpreter pattern.

## Free Monads

We have talked about monads and interpreters. I said the free monad is just the combination of the two. Concretely this means the free monad provides:

- an AST to express monadic operations;
- an API to write interpreters that give meaning to this AST.

What does the AST look like? It simply represents the monad operations without giving meaning to them. As a monad is just `point` and `flatMap`, the AST is almost literally[^almost-literally] just representations of these as data like so:

~~~ scala
sealed trait Free[F[_], A]
final case class Point[F[_], A](a: A) extends Free[F, A]
final case class FlatMap[A, B](f: A => F[B])
~~~

Now what does a free monad interpreter look like? It's just a function from `F[_]`, the representation inside the free monad, to `G[_]` some monad in which we really run the computation (the `Id` monad is a popular choice). This type of function has a special name, a [natural computation][natural-computation].

Here's a simple example.

~~~
CODE HERE
~~~

[^etsy]: Etsy, for example, faces the same problem but there solution is rather less elegant and performant.
[^laws]: And the monad laws.
[^two-parts]: Some very simple interpreters entwine these two parts, but they are conceptually if not literally present.
[^almost-literally]: There are two ... Functor. Trampolining

[dual-numbers]: 
[natural-transformation]:
