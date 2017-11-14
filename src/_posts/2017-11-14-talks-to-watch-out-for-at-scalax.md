---
layout: post
title: "Talks to Watch Out For at Scala Exchange"
author: Dave Gurnell
---

Scala Exchange is only a month away and excitement is building at Underscore HQ. We thought we'd write a series of posts about our involvement with the conference. Watch this space over the coming weeks for announcements and Scalax-related content, and subscribe to the newsletter to take advantage of some upcoming promotions and discounts.

<!-- break -->

We have an amazing programme this year (admittedly I'm biased---I helped select it). Our four keynotes---Bartosz Milewski, Debashish Gosh, Holden Karau, and Runar Bjarnasson---all speak for themselves, so here are some of my personal picks from the rest of the programme.

You can find the complete schedule on the [Scala Exchange web site][link-programme] where you can [grab tickets][link-scalax] if you haven't already done so. We'll also have some discounts available in our [December newsletter][link-newsletter], out next week.

## Gabriele Petronella -- Move Fast and Fix Things

(Beginner friendly)

Scalafix has been getting a lot of attention recently. Initially intended as a tool to help migrate between Scala versions, it is now a fully fledged migration and refactoring tool that has been picked up by several open source libraries (most notably Cats) as a way to automate upgrades through breaking API changes. You can even use it for your own refactorings, too!

## Heiko Seeberger -- Farewell Any => Unit, Welcome Akka Typed!

(Beginner friendly)

I have a few criticisms of actors but chief among them is the lack of type safety. It's hard to think of a less precise type than `Any => Unit`, and this is unfortunately the type you get in the receive loop of an actor... until now. Akka Typed is here to save the day, so come listen to Heiko's talk and find out how to sprinkly your actor systems with a little type safety.

## Noel Markham -- Creating a Physics Simulation with Scala JS

(Beginner friendly)

I love graphics, physics, and front end development. The quick visual feedback loop is great for creative, fun programming. Scala JS provides a great way to to all of this goodness from a language that puts statically typed functional programming first. In this talk, Noel will be showing us the power of Scala JS by live coding a simple physics demo from scratch, right in front of our eyes. What's not to like?

## Peter Hilton -- How to Name Things: The Hardest Problem in Programming

(Beginner friendly)

Peter is a great speaker who brings fascinating talk topics out of left field and turns them into compelling and enlightening talks. In this talk he'll be comparing software development to writing, showing us how we can be better developers by following the advice set out for us by authors like Stephen King and Neil Gaiman. I'm intrigued by this---one to attend, for sure!

[link-scalax]: http://scala-exchange.com
[link-programme]: https://skillsmatter.com/conferences/8784-scala-exchange-2017#program
[link-newsletter]: https://underscore.io/blog/newsletters/
