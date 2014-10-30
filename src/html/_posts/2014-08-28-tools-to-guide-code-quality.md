---
layout: post
title:  Tools to guide code quality
author: Jonathan Ferguson
---

Earlier this month Noel wrote [about appropriate use of code reviews](http://underscoreconsulting.com/blog/posts/2014/08/05/code-reviews-dont-produce-quality-code.html).

In this post I am going to look at a couple of tools you can use to cover the mechanical aspects of code reviews.  Automated tools provide a low effort way of staying on top of the health of your code base. They can not tell you everything, but they will ensure that common issues are found without it requiring a lot of human cycles.

Linters highlight lint in a code base. Lint is redundant or poorly structured code that is likely to lead to bugs. [FindBugs](findbugs.sourceforge.net/) is a popular example from the Java world.

Linters help direct developers to good practices. By pointing out both bad practice and where Scala doesn't behave as expected. Examples of bad practice include calling functions that will generate exceptions. Such as `List.head` and `Try.get` rather than the safer alternatives `List.headOption` and `Try.getOrElse`. Examples of Scala misbehaving include implicit conversion to a String and inferring uninformative types such as `Any`, `Product` or `Serializable`.

## [WartRemover](https://github.com/typelevel/wartremover)

WartRemover was started by Brian McKenna. Brian [describes his reason](http://brianmckenna.org/blog/wartremover_point_four) for creating the project as providing a flexible tool for writing lint rules over Scala code.

WartRemover is easiest used as a compiler plugin within `sbt`, but can be also used as a macro or via the command line.  Within `sbt` WartRemover can be configured to either generate errors or warnings; the default action is neither.

There are two types of Wart. Those that stop you doing things you shouldn't, such as calling `Option.get` or `List.head`.  And those that stop you doing things that will let the compiler get you into trouble. Such as Scala implicitly converting anything to a `String`.

WartRemover development moves slowly, being firmly focused on correctness. This can be frustrating as there are issues open for some brilliant warts. The solution to this is of course, fork and implement.

At Underscore we use WartRemover to assess the health of a code base. This allows us to focus on how the code hangs together and where we can provide value.

## [Scapegoat](https://github.com/sksamuel/scalac-scapegoat-plugin)

Scapegoat is a younger project than WartRemover and requires the use of `sbt` 0.13.5 and Scala 2.11.x. `sbt` support is via an external project. There is some mention of false positives. I've not tried Scapegoat yet, so can not attest to whether this is problematic.  Scapegoat appears to support more Inspections (the Scapegoat equivalent of a wart). However these seem less around idiomatic Scala and more around general soundness of code and bad OO style.

##  Scalac Flags

For completeness there is of course Scalac flags such as `-Xlint`. I'll leave these for the reader to explore.

## Finally

Those interested in FP purity in a Scala world, you'll want WartRemover. If you are in an OO world, or moving from an OO world. You'll want a mix of Scapegoat and WartRemover, tuned to nudge your developers in the right direction.  Having the Scalac lint flags on is good practice.

WartRemover feedback is via the compiler as errors and warnings. Which is readable and generally explains how to remove the wart. Whereas, by default an error in  Scapegoat is a line in the output and isn't as easy to find and review as WartRemover's. It does however produce a nice html document of its results.

Example of the different default output styles, WartRemover:

    [error] /Users/jonoabroad/developer/scratch/linter-explore/src/main/scala/in-need-of-linting.scala:11: List#head is disabled - use List#headOption instead
    [error]   val boom2 = list.head
    [error]                    ^

compared with, Scapegoat:

    [error] Use of Traversable.head - in-need-of-linting.scala:11

These tools should not be used to punish programmers. Rather to help guide them. Nobody wants a return to the horrifically unproductive days of Enterprise Java. With 100% code coverage or documented methods. Both of which lead to rubbish generated to the detriment of the code.

A very brief example showing how the three tools are used within `sbt` can be found  on [github](https://github.com/underscoreio/linter-explorer).
