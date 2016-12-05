---
layout: post
title: Towards Browser and Server Utopia with Scala.js
author: Richard Dallaway
---

At Scala Days 2015 in Amsterdam I talked about Scala.js, and in particular focussed on the great interoperability with JavaScript. This post gives additional links if you want to dig deeper.

[over at Github]: https://github.com/d6y/wootjs
[paper]: http://www.loria.fr/%7Eoster/pmwiki/pub/papers/OsterRR05a.pdf
[noel]: /blog/posts/2013/12/20/crdts-for-fun-and-eventual-profit.html
[before]: /blog/posts/2014/01/06/crdt.html
[scalajs]: http://www.scala-js.org/

<!-- break -->

## Background

If you're looking for more background information on CRDTs, [Noel posted on this a while back][noel].

The algorithm I ran through (fairly quickly) I've described [before].  The theory and analysis of the WOOT algorithm I presented is from: Oster _et al._ (2005) [Real time group editors without Operational transformation (PDF)][paper], report paper 5580, INRIA.

## Talk

The slides from my presentation are below:

<script async class="speakerdeck-embed" data-id="fcc82d3416b84588937cba16a0ccce1f" data-ratio="1.33333333333333" src="//speakerdeck.com/assets/embed.js"></script>

The source for the example project is [over at Github].

## Scala.js

To get into Scala.js, I recommend:

- taking the tutorial at [Scala-js.org][scalajs], and dig into the _Pages_ part of that site for more details.

- join the [Gitter room](https://gitter.im/scala-js/scala-js).

## Main Points

The main points I wanted to make were that:

- Scala.js is part of the story for _Making Change Easier_.  We want to make it cheap, quick, and safe to evolve a code base over time; and

- You can gradually add Scala.js into an existing project. You don't have to throw everything away, because Scala.js plays nicely with others.


