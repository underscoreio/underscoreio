---
layout: post
title: "Highlights from Scala Exchange 2015"
author: "Richard Dallaway, Dave Gurnell, and Noel Welsh"
---

Scala Exchange holds a special place in the hiveheart of Underscore. We've been attending since the very beginning in 2011 (before Underscore was formed!) and have more recently taken an active role growing the conference as part of the program committee.

We'd like to highlight some of the talks we most enjoyed from this year's edition of the conference, which was easily the biggest and busiest so far.

<!-- break -->

We've had many people tell us that [Jessica Kerr's][jessitron] opening keynote was the best talk of the conference. No doubt about it, she rocked, speaking about broad and important themes of community and teaching.

Jessica also included some concrete points that gained a lot of attention from later speakers: include imports in all code samples, and avoid using unhelpful words like "simply" and "obviously". Expect people to reference these points online in the coming months.

More importantly for us, Jessica's keynote really complimented a newcomer-friendliness that we tried to get across in the programme. There were over 750 attendees at Scala Exchange this year, an impromptu poll on the first morning revealing that around 75% were attending for the first time[^selection].

[^selection]: Expect a more detailed breakdown of our approach to selecting speakers in the coming days.

[Laura's Blėdaitė][lrb] was a new speaker at Scala Exchange who delivered an [awesome talk on the Count-Min Sketch][count-min] algorithm. Count-Min Sketch is not a cartoon villian, but a way of counting the occurrence of specific items without consuming much memory. The secret to this is... well, go watch the talk! It's a very neat algorithm, and Laura does a great job explaining it and giving examples of its use at Twitter.

This year lighting talks were included in Scala Exchange. We caught a few of them, and will have to catch up on the rest when [all the recordings are online][videos].

In the [second lightning talk][lt2] session, [Jeff Smith][jeffsmith] built up a system for _Collecting Uncertain Data the Reactive Way_. The problem he's addressing is machine learning in the context of infinite and uncertain data, and how immutable facts (aka. events) are the cornerstone of a scalable system. His talk was wonderfully entertaining thanks to his examples featuring savanna animals.

Following Jeff, [Bas Geerdink][bas] spoke on _The rise of Scala at ING_. There's plenty of interesting material in those 15 minutes: ING introduce Scala via a classroom setting; why they focus on functional programming rather than Scala specifically; and what the appeal of Scala is to the business.  Good stuff.

First time speaker [Sofia Cole][sofia] also discussed adopting Scala, in this case at Yoox Net-A-Porter Group. The teams at NAP follow a more Scala-centric approach, but like ING the key is knowledge sharing via a variety of routes: workshops, cross-team clinics, pairing, and a heavy emphasis on peer review.

Last but by no means least, another first-time speaker, Danielle Ashley, gave a talk that many people considered the best of the conference. [She spoke][inappropriate] about the practical problems of trying to keep functionally pure and avoid state. But she did this in the context of projects you wouldn't normally associate with Scala: a MP3 decoder, and a Nintendo Gameboy emulator. The cheer of the crowd as she cleared a line in Tetris was quite remarkable.


[inappropriate]: https://skillsmatter.com/skillscasts/6846-inappropriate-applications-for-scala

[lt2]: https://skillsmatter.com/skillscasts/7038-lightning-talks-2
[videos]: https://skillsmatter.com/conferences/6862-scala-exchange-2015#skillscasts
[jeffsmith]: https://twitter.com/jeffksmithjr
[bas]: https://www.linkedin.com/profile/in/geerdink
[sofia]: https://www.linkedin.com/in/sofiacole

[sx]: http://scala.exchange
[jessitron]: https://twitter.com/jessitron
[lrb]: https://twitter.com/__lrb__
[count-min]: https://skillsmatter.com/skillscasts/6844-count-min-sketch-in-real-data-applications
