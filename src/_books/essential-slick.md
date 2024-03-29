---
id: essential-slick
title: Essential Slick
layout: book
navbar: training
icon: scala
color: "#F58B40"
level: Intermediate
cover: "/images/books/essential-slick.png"
mailchimp:
  host: underscore.us16.list-manage.com
  user: 974a09ebc30fbb878c41436ec
  list: d99e5ae861
summary: |
  Learn to use Lightbend's Slick to interact with relational databases.
  For new to intermediate Scala developers.
buyButtons:
- label: "Read the book"
  url: "https://books.underscore.io/essential-slick/essential-slick-3.html"
- label: "Download as PDF"
  url: "https://books.underscore.io/essential-slick/essential-slick-3.pdf"
- label: "Download as ePub"
  url: "https://books.underscore.io/essential-slick/essential-slick-3.epub"
---

## Overview

Essential Slick is a tutorial to building application using the Slick database library.
It is aimed at Scala developers who need to become productive with Slick quickly.

The book covers Slick 3.

## Praise for Essential Slick

> "I’ve found the book to be highly informative---and, if you’re using Slick, necessary, compared to the other Slick resources out there. Highly recommended."

> "Having worked in Scala almost 2 years, but never used Slick, I recommend this book. It got me up and running quickly."

> "This book is the missing Slick documentation. I like the style and clear content."

Read full reviews from [Yann Simon](http://yanns.github.io/blog/2015/12/07/review-of-essential-slick/),
[Joe Ottinger](http://enigmastation.com/2015/11/20/essential-slick-review/), and
the recommendation from [Debasish Ghosh](https://twitter.com/debasishg/status/671038191969951745).

## Prerequisites

We've seen that developers using Slick for the first time often
need help getting started with the library.

For example, there are unfamiliar concepts to learn and work with, such as
_database actions_.
This book gives an understanding of how to work with Slick by walking through the common tasks,
explaining the methods and types you see, and providing exercises.

To benefit from this material you will need to know the fundamentals of the Scala language. We recommend [Underscore's Essential Scala](../essential-scala) as the perfect complement to this book.

## Learning Outcomes

- Practical knowledge of working with Slick applications
- Understanding the core concepts required to work with Slick
- Knowing how to use Slicks features for selecting and modifying data
- Modelling schemas in Slick
- Making use of the Scala type system with Slick
- Working with lower-level Plain SQL for fine control over queries

## Introductory Video

Dave Gurnell ran a hands-on workshop at Scala Exchange 2015 based on the material in this book. Check out the video below for broad, brief tour of the concepts discussed in depth in the book:

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
