---
layout: post
title: "Uniting Church and State"
author: Noel Welsh
---

In this blog post I want to describe Church encoding, which give us a tool 

performance characteristics

unify OO and FP techniques.

<!-- break -->

For a recent project Maana blah blah.

## Reactive Streams

Let's start by implementing a reactive stream system using classic functional techniques.
This will show

 - we can develop software in a systematic way; and
 - give us baseline performance metrics.
 
Write down the API.

Reify.

Implement.

Separation between describe and execute allows us to introduce effects.

Performance.


### Termination

Iterators.

Termination. Option. Boxing.

Performance.


### Church Encoding

Church encoding.

Performance.

Inversion of control flow.


### Benchmarks

[info] Result "termination.StreamBenchmark.zipAndAdd":
[info]   569.189 ±(99.9%) 5.915 ms/op [Average]
[info]   (min, avg, max) = (520.228, 569.189, 628.885), stdev = 25.043
[info]   CI (99.9%): [563.274, 575.104] (assumes normal distribution)

[info] Result "church.StreamBenchmark.zipAndAdd":
[info]   400.804 ±(99.9%) 5.202 ms/op [Average]
[info]   (min, avg, max) = (381.642, 400.804, 600.779), stdev = 22.024
[info]   CI (99.9%): [395.603, 406.006] (assumes normal distribution)

## Church Encodings

Type classes

Finally tagless interpreters

Objects
