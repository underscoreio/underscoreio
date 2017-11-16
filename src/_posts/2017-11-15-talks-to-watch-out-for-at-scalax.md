---
layout: post
title: "Talks to Watch Out For at Scala Exchange"
author: Dave Gurnell
---

Scala Exchange is only a month away and excitement is building at Underscore HQ. We thought we'd write a series of posts about our involvement with the conference. Watch this space over the coming weeks for announcements and Scalax-related content, and subscribe to the newsletter to take advantage of some upcoming promotions and discounts.

<!-- break -->

We have an amazing programme this year (admittedly I'm biased---I helped select it). Our four keynotes---Bartosz Milewski, Debasish Ghosh, Holden Karau, and Rúnar Bjarnasson---all speak for themselves, so here are some of my personal picks from the rest of the programme.

You can find the complete schedule on the [Scala Exchange web site][link-programme] where you can [grab tickets][link-scalax] if you haven't already done so. We'll also have some discounts available in our [December newsletter][link-newsletter], out next week.

<!--
We're also running a [Cats training course][link-advanced-scala-event] on the 12th and 13th December right before the conference. [Book your place now][link-advanced-scala-eventbrite] on our Eventbrite page.
-->

## Gabriele Petronella -- Move Fast and Fix Things

<span class="label label-success">Beginner friendly</span>

Scalafix has been getting a lot of attention recently. Initially intended as a tool to help migrate between Scala versions, it is now a fully fledged migration and refactoring tool that has been picked up by several open source libraries (most notably Cats) as a way to automate upgrades through breaking API changes. You can even use it for your own refactorings!

## Heiko Seeberger -- Farewell Any => Unit, Welcome Akka Typed!

<span class="label label-success">Beginner friendly</span>

I have a few criticisms of actors but chief among them is the lack of type safety. It's hard to think of a less precise type than `Any => Unit`, and this is unfortunately the type you get in the receive loop of an actor... until now. Akka Typed is here to save the day, so come and speak to Heiko and find out how to sprinkle your actor systems with a little type safety.

## Noel Markham -- Creating a Physics Simulation with Scala.js

<span class="label label-success">Beginner friendly</span>

I love graphics, physics, and front end development. The quick visual feedback loop is perfect for creative, fun programming. Scala.js provides a great way to to all of this goodness from a language that puts statically typed functional programming first. At Scala Exchange, Noel will be showing us the power of Scala.js by live coding a simple physics demo from scratch, right in front of our eyes. What's not to like?

## Peter Hilton -- How to Name Things: The Hardest Problem in Programming

<span class="label label-success">Beginner friendly</span>

Peter is a great speaker who brings fascinating topics out of left field and turns them into compelling and enlightening talks. At Scala Exchange he'll be comparing software development to writing, showing us how we can be better developers by following the advice set out for us by authors like Stephen King and Neil Gaiman. I'm intrigued by this---one to attend, for sure!

These are just four of the 40+ talks on [the programme][link-programme]. We're super excited to have Gabriele, Heiko, Noel, and Peter with us, and we're looking forward to seeing you [in Islington, London on 14th December][link-scalax].

[link-scalax]: http://scala-exchange.com
[link-programme]: https://skillsmatter.com/conferences/8784-scala-exchange-2017#program
[link-newsletter]: https://underscore.io/blog/newsletters/
[link-advanced-scala-event]: /events/2017-12-12-advanced-scala/
[link-advanced-scala-eventbrite]: https://www.eventbrite.com/e/advanced-scala-with-cats-public-course-tickets-37809147177
