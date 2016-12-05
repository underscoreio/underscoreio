---
layout: post
title: "Newsletter 9: Scala Jobs, Slick, Sealed Traits, Strata, and Scala Days"
author: Noel Welsh
categories: [ newsletter ]
---
Hi,

It's time for *cough* May's *cough* newsletter, and the theme of this edition is database access.

Since the last newsletter went out we have published a new book, [Essential Slick][essential-slick]. As most of you will know, [Slick][slick] is a Scala library for relational database access. Essential Slick covers version 2.1 of the library. The next version, 3.0, was announced shortly before the book was published so we're currently offering 50% off with the code *slick2*. This discount won't last forever, so if you don't have a copy of Essential Slick you might want to take advantage of this now.

But before we talk about databases, let's touch on another subject that's of great interest to many: money.

<!-- break -->


## Jobs for the People; People for the Jobs

We've launched a [jobs board][job-board].

We often hear from clients that they have problems hiring Scala developers. We know the market for Scala developers is hot right now, but at the same time we hear from students at [Creative Scala][creative-scala-book] that they have difficulty breaking into the industry. The job board is our attempt to do something about this.

It's completely free to post a job on the board, and if your company is hiring we're hoping you will encourage them to do so. We particularly want to see jobs that accept juniors or allow remote work. Those that do so are highlighted in the board.

The job board currently has open positions at the Guardian (including [one open to juniors][guardian-juniors]), McLaren, Twilio, and Lunatech. If you're looking for a new challenge do take a look.


## Database Access

As usual we've run a little mini-series on the blog, this time on database access.

The [first post][slick-enrichment] describes how to use implicit classes to make Slick queries easier to read and less error-prone

Slick is not the only game in town. The second post compares how Slick and [Doobie][doobie] perform type checking of SQL string literals.

Tying into the [free monad][free-monad-simple] we talked about last newsletter, note that both Slick 3.0 and Doobie adopt the free monad pattern in their implementation.


## Also of Note

Sealed traits are the core of algebraic data types, one of the most important patterns in Scala. However I've found they are perplexing to many developers new to Scala so we've written a [comprehensive post][sealed-traits] on their use

At the beginning of the month I spoke at O'Reilly's Strata conference on A/B testing. In a definite change from the last time I attended Strata, interest in Scala is off the charts. This, of course, is largely down to Spark. My slides and more thoughts are [here][strata].

Finally, [Shapeless 2.2][shapeless-2.2] is out, which includes support for Scala.js and Spark.


## Free Courses and Talks at Scala Days Amsterdam

[Scala Days Amsterdam][scala-days-amsterdam] is next week, and we will be running some free events. In particular:

- before Scala Days we're running an [introduction to Scala][creative-scala] via computer graphics, using our open source book [Creative Scala][creative-scala-book]; and
- immediately following Scala Days Miles is running a [Shapeless workshop][shapeless].

At the time of writing we have had some dropouts from Creative Scala and have a few spots left. If you want to attend Creative Scala, or want to go onto the waitlist for Shapeless, drop me an email *now*. No guarantees but if we can get you in we will.

We also have a few talks at Scala Days Amsterdam:

- Richard is talking about [CRDTs, web apps, and Scala.js][scala-days-amsterdam-richard], which is going to be one hell of a talk and one I'm already excited about.
- Dave is showing how to systematically design a [functional validation library][scala-days-amsterdam-dave].
- For some reason I've been allowed to speak on [essential patterns in Scala][scala-days-amsterdam-noel].

If you're in Amsterdam do come and say hi!


## Final Thoughts

That's it for *May's* newsletter. Last time we asked you what theme we should cover next and had some great responses, including deep learning, Scala.js, and Cats. It takes time to create material, but you can influence what we produce by getting in touch in letting me know what you want to hear about. Just reply to this email to do so.

Look forward to hearing from you.

Regards,<br/>
Noel

[free-monad-simple]: http://underscore.io/blog/posts/2015/04/14/free-monads-are-simple.html
[scala-days-amsterdam]: http://event.scaladays.org/scaladays-amsterdam-2015
[shapeless]: http://underscore.io/events/2015-06-11-advanced-scala-shapeless.html
[creative-scala]: http://underscore.io/events/2015-06-08-creative-scala.html
[creative-scala-book]: http://underscore.io/training/courses/creative-scala/
[scala-days-amsterdam-noel]: http://event.scaladays.org/scaladays-amsterdam-2015#!#schedulePopupExtras-6914
[scala-days-amsterdam-dave]: http://event.scaladays.org/scaladays-amsterdam-2015#!#schedulePopupExtras-6958
[scala-days-amsterdam-richard]: http://event.scaladays.org/scaladays-amsterdam-2015#!#schedulePopupExtras-6925
[guardian-juniors]: http://underscore.io/jobs/2015-05-20-guardian-content-api/
[job-board]: http://underscore.io/jobs
[slick-enrichment]: http://underscore.io/blog/posts/2015/05/15/slick-enrichment.html
[strata]: http://underscore.io/blog/posts/2015/05/14/strata-hadoop-world.html
[sealed-traits]: http://underscore.io/blog/posts/2015/06/02/everything-about-sealed.html
[shapeless-2.2]: http://milessabin.com/blog/2015/05/27/shapeless-2.2.0/
[essential-slick]: http://underscore.io/training/courses/essential-slick/
[slick]: http://slick.typesafe.com/
[doobie]: https://github.com/tpolecat/doobie
