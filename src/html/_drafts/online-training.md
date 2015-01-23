---
layout: page
title: Rethinking Online Training
---

If you are providing training in 2015 you have to be thinking about online delivery. We had some unsatisfactory experiments with teaching [Essential Scala](http://underscore.io/training/courses/essential-scala/) online last year, where we essentially delivered our onsite training over Google Hangouts. Online is a different media to face-to-face communication and over the Christmas break we decided to rethink our online courses to take best advantage of the opportunities if offers.

<!-- break -->

Our first step was to revisit the goals of Essential Scala. Our primary aim to for people to leave understanding the patterns of functional programming and be able to apply them in their own work. That's why Essential Scala is built around core patterns of algebraic data types, structural recursion, and so on.

Essential Scala evolved from a two-day onsite training course, and the constraints of onsite training has had a profound effect on its structure. Over two days you really only get one and half days of teaching, because everyone is tired and their brain full by that point. This means relatively small exercises, and little chance for reflection. 

We know learning takes time. We know people need to work with larger programs. I we know they need to make mistakes and fix those mistakes, to really internalise the patterns we are teaching. We also know that it just isn't viable to do this onsite -- the time and hence cost is too high. But when we sat down and thought about it, we realised we *could* do this online.

When we teach onsite we have a lot of dead time. We have regular breaks, and we have time when everyone is working on an exercise and doesn't need assistance. We realised we don't have to be around for this if we teach online, and if we are not around we don't have to charge for it. This means we can expand the scope of our exercises without also increasing the cost. This was our first insight.

The second insight came when we started thinking about how to structure the online course. We are big believers in reading the literature. People far more intelligent than us have been spending a long time on the problem of teaching programming. Essential Scala draws its structure from [How to Design Programs](http://htdp.org/), whose authors have received multiple awards for teaching. We started doing some research, and discovered the idea of [studio style teaching](http://slice.cs.uiuc.edu/pubs/Studio-SIGCSE2006.pdf). In a studio style course students work on a project over a number of weeks. Critically, they regularly discuss their code and incorporate feedback into their ongoing development. We realised that studio style teaching would allow us to deliver on our goals.

So that’s what we’re going to do. We’re going to continue to offer our very successful on-site training as is, but we’re also going to offer a studio style curriculum for online students. 

We have a number of examples in the works. The first is Doodle, a compositional graphics library. This is a classic functional langugage application dating back at least as far as SICP. Using the library is going to make for some fun exercises, and recreating the library is going to make a great case study. 
