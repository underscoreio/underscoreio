---
layout: post
title: "Video from the Slick Workshop at Scala Exchange 2015"
author: "Dave Gurnell"
---

My workshop at Scala Exchange was entitled "Essential Slick: Hands-On with Slick 3". In my experience, Slick is routinely difficult for new Scala developers to pick up. This workshop provides a light introduction to the main concepts in the library, with more in-depth information available in [Richard and Jonathan's book][book]. You can find a video of the talk and links to the content after the break:

<!-- break -->

<iframe src="https://player.vimeo.com/video/148074461?title=0&amp;byline=0&amp;portrait=0"
        width="500"
        height="313"
        frameborder="0"
        style="display: block; margin: 1em auto"
        webkitallowfullscreen
        mozallowfullscreen
        allowfullscreen></iframe>

Here's a quick guide to the content covered:

- 0:00 - *Introduction.* Housekeeping etc.
- 3:30 - *Tables.* Mapping Scala data types onto the database.
- 23:30 - *Queries.* Selecting data, query types, query combinators.
- 46:30 - *Actions.* Inserting/updating/deleting, sequencing actions, transactions.
- 1:17:30 - *Joins.* Selecting data from multiple tables.
- 1:34:50 - *Profiles.* Selecting profiles, [Freeslick][freeslick], writing database-generic code.

The slides and sample code can be found [on our Github account][github]. If you have trouble with any of the exercises or getting set up, feel free to ask questions [on our Gitter channel][gitter].

[github]: https://github.com/underscoreio/scalax15-slick
[gitter]: https://gitter.im/underscoreio/scalax15-slick
[book]: http://underscore.io/books/essential-slick
[freeslick]: https://github.com/smootoo/freeslick
