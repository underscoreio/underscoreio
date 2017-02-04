---
layout: event
title: "Doodle: Visualisation in Scala"
type: talk
location: Scala Days Copenhagen
date: 2017-06-02 11:35:00 CET
timezone: CET
duration: 45 mins
navbar: events
summary: |
  Noel will talk about Doodle,
  a Scala library for data visualisation that renders in the browser,
  to files, and on the desktop.
bookingLinks:
  - text: Sign up for the conference
    url: http://event.scaladays.org/scaladays-cph-2017

---

# Abstract

In this talk I'll introduce Doodle, a Scala library for data visualisation that renders in the browser, to files, and on the desktop.

Scala is an integral part of many data analysis workflows, but when it comes to visualising the results practitioners must often turn to Javascript libraries like d3 or Highcharts, or Python libraries such as matplotlib. These libraries have several disadvantages. For a start, they require switching environments. Furthermore, they often lack useful abstractions, being either easy to use or flexible, but not both. For example, matplotlib provides a rigid system of predefined graphs, while d3 provides many low-level building blocks but lacks tools to easily combine them for common graphs.

Doodle is a new 2D visualisation library for Scala. It can render graphs on the desktop, to files (PDF and PNG), and, using Scala.js, to the browser as SVG. In this talk I will briefly describe how to use Doodle for common tasks, and then delve into its architecture. I'll show how standard functional programming techniques allows Doodle to provide powerful functionals at multiple levels of abstraction, yielding a library that is both easy to use and extremely flexible.
