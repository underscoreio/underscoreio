---
id: essential-slick
title: Essential Slick
layout: course
navbar: training
icon: scala
color: "#F58B40"
level: Intermediate
book: essential-slick
summary: |
  Learn to use Lightbend's Slick to interact with relational databases.
  For new to intermediate Scala developers.
onsite:
  duration: "1 day"
  buttonLabel: "Book now - {% currencies $3,750 £2,500 €3,500 %}"
online:
  duration: "3 weeks"
  buttonLabel: "Book now - {% currencies $3,750 £2,500 €3,500 %}"
---

## Overview

Essential Slick is a guide to building a database application using the Slick library. It is aimed at Scala developers who need to become productive with Slick quickly.

We've seen that developers using Slick for the first time often need help getting started with the library.
For example, there are unfamiliar concepts to learn and work with, such as _database actions_.
This text gives an understanding of how to work with Slick by walking through the common tasks, explaining the methods and types you see, and providing exercises.

## Learning Outcomes

- Practical knowledge of working with Slick applications
- Understanding the core concepts required to work with Slick
- Knowing how to use Slicks features for selecting and modifying data
- Modelling schemas in Slick
- Making use of the Scala type system with Slick
- Working with lower-level Plain SQL for fine control over queries

## Prerequisites

To benefit from this material you will need to know the fundamentals of the Scala language. We recommend [Underscore's Essential Scala](../essential-scala) as the perfect complement to this course.

## Introductory Video

Dave Gurnell ran a hands-on workshop at Scala Exchange 2015 based on the material in this course. Check out the video below for a broad, brief tour of the concepts discussed in depth in the course:

<iframe src="https://player.vimeo.com/video/148074461?title=0&amp;byline=0&amp;portrait=0"
        width="500"
        height="313"
        frameborder="0"
        style="display: block; margin: 1em auto"
        webkitallowfullscreen
        mozallowfullscreen
        allowfullscreen></iframe>

- 0:00 - *Introduction.* Housekeeping etc.
- 3:30 - *Tables.* Mapping Scala data types onto the database.
- 23:30 - *Queries.* Selecting data, query types, query combinators.
- 46:30 - *Actions.* Inserting/updating/deleting, sequencing actions, transactions.
- 1:17:30 - *Joins.* Selecting data from multiple tables.
- 1:34:50 - *Profiles.* Selecting profiles,  writing database-generic code.

Due to a problem with the recording, the video is missing five minutes of audio around the 45 minutes mark.

The slides and sample code for the workshop can be found [on our Github account][github]. If you have trouble with any of the exercises or getting set up, feel free to ask questions [on our Gitter channel][gitter].

[github]: https://github.com/underscoreio/scalax15-slick
[gitter]: https://gitter.im/underscoreio/scalax15-slick
