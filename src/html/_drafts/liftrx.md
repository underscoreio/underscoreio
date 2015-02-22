---
layout: post
title:  Reactive Web Components with LiftWeb and RxScala
author: Channing Walton
---

### Overview

[LiftWeb](http://liftweb.net) makes building dynamic, comet and ajax websites extremely easy. [RxScala](http://reactivex.io/rxscala/) is a Scala adapter for RxJava, "a library for composing asynchronous and event-based programs using observable sequences for the Java VM". This blog describes how we combined Lift and RxScala for event-based UI components using observable sequences.

### The Basic Idea


### A Label

Driven by Observable[String], has no output Observable[String], has Observable[JsCmd]

### An Input Element

Driven by Observable[String], outputs Observable[String] and Observable[JsCmd]


### Composite Elements

Lenses and Endos

### Conclusions


See [RxLift](https://github.com/channingwalton/rxlift)