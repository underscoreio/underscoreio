---
layout: event
title: "Uniting Church and State: FP and OO Together"
type: talk
location: Scala Days Copenhagen
date: 2017-06-02 13:20:00 CET
timezone: CET
duration: 45 mins
navbar: events
summary: |
  Noel will describe how Church encoding
  allows us to achieve FP simplicity with OO performance.
bookingLinks:
  - text: Sign up for the conference
    url: http://event.scaladays.org/scaladays-cph-2017
---

# Abstract

In this talk we describe an underappreciated tool, Church encoding, that allows us to combine the best parts of FP and OO.
By Church encoding our program we can reatin the simple semantics that characterises FP code, while achieving performance that may seem out of reach in a pure FP system.

Late last year [Maana][maana], a Seattle based enterprise knowledge platform startup, contracted us to write a time series analysis engine. 
They commonly dealt with multi-TB data, but needed to achieve interactive speed.
We recognised that providing a streaming API, similar to Monix, Akka Streams, or Reactive Extensions, would make the software accessible to data scientists already used to Spark, but there were issues about semantics and performance.
Classic FP pull-based systems are simple to use but perform poorly, while OO push-based systems are fast but tricky to reason about.
By employing Church encoding, also known as refunctionalisation, we were able to get the best of both worlds. 
The user sees a straightforward API and semantics, while under the hood the system has no runtime memory allocation and is extremely efficient.
This tool is not so widely known and the purpose of our talk is to introduce it to a wider audience.

Church encoding is a general purpose tool you can apply to your own code no matter what software you build.
It provides a relationship between the classic FP tool of algebraic data types (represented in Scala using `sealed` traits) and OO-style classes. 
We can use it to convert FP-style code into an OO equivalent, which can use mutable state and other optimisations without affecting the clean semantics the user sees.
Church encoding also gives us a coherent design principle to unite FP and OO.
This provides a bridge to truly unlocking Scala's multiparadigm nature while retaining an overall architecture that is simple and consistent.

[maana]: http://maana.io/
