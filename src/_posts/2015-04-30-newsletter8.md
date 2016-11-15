---
layout: post
title: "Newsletter 8: Free Monads and Free Courses"
author: Noel Welsh
categories: [ newsletter ]
---
Hi,

There's just time to squeeze in April's newsletter before the month is over. In this edition we discuss the free monad and let you know about some free events running at Scala Days Amsterdam.

Our mini-series on error handling [last newsletter][newsletter-7] had a great reception. We decided to repeat the idea, this time focusing on a more advanced topic: the free monad.

The free monad is one of those functional programming tools that from the outside seems both incredibly powerful (see [Facebook's Haxl][haxl] and [Twitter's Stich][stitch] for compelling applications) and incredibly unapproachable (if "left adjoint to a forgetful functor" means anything to you, I suggest you don't need a tutorial on the free monad).

What we've tried to do is break down the free monad to its essential elements, and show that when you remove the jargon there are just a few simple concepts involved.

<!-- break -->

We have three posts on the blog for you that cover the free monad.

[The first post][free-monad-simple] in the series explains the basic idea behind the free monad: separating the representation of a computation from its interpreter.

[The followup post][free-monad-deriving] goes deeper into the structure of the free monad, showing how it can be derived from the monad operations. As a bonus we also derive the free monoid.

[The final post][free-monad-io] explores the role of laziness in monadic IO operations, and ties this back to the free monad.

The final post made it to the front page on Hacker News and garnered some [great comments][hn-comments]. I particularly want to highlight [this comment][hn-final] that I found very insightful.


## Free Courses and Talks at Scala Days Amsterdam

[Scala Days Amsterdam][scala-days-amsterdam] is the next big event in the Scala calendar, and we will be there running some free events. In particular:

- before Scala Days we're running an [introduction to Scala][creative-scala] via computer graphics, using our open source book [Creative Scala][creative-scala-book]; and
- immediately following Scala Days Miles is running a [Shapeless workshop][shapeless].

In the interests of fairness tickets for both events are allocated by lottery. The first drawings of the lottery will take place very soon, so sign up now if you'd like to attend!

We also have a few talks at Scala Days Amsterdam:

- Richard is talking about [CRDTs, web apps, and Scala.js][scala-days-amsterdam-richard], which is going to be one hell of a talk and one I'm already excited about.
- Dave is showing how to systematically design a [functional validation library][scala-days-amsterdam-dave].
- For some reason I've been allowed to speak on [essential patterns in Scala][scala-days-amsterdam-noel].

If you're planning to go to Amsterdam and haven't booked a ticket yet, you should be able to use the code `elsh50` for a discount.


## Videos from Scala Days SF

Can't make it to Scala Days Amsterdam? I'm such a hack I gave the same talk in SF, and the [video is online][parleys-essential]. Miles has a great [talk on Shapeless][parleys-shapeless] that you should probably watch.

Hope you enjoyed this edition of the newsletter. Is there a theme you'd particularly like us to cover next time? Let me know your thoughts by replying to this email.

Regards,
Noel

[newsletter-7]: http://underscore.io/blog/posts/2015/03/05/newsletter7.html
[haxl]: https://github.com/facebook/Haxl
[stitch]: https://www.youtube.com/watch?v=bmIxIslimVY
[free-monad-simple]: http://underscore.io/blog/posts/2015/04/14/free-monads-are-simple.html
[free-monad-deriving]: http://underscore.io/blog/posts/2015/04/23/deriving-the-free-monad.html
[free-monad-io]: http://underscore.io/blog/posts/2015/04/28/monadic-io-laziness-makes-you-free.html
[hn-comments]: https://news.ycombinator.com/item?id=9452379
[hn-final]: https://news.ycombinator.com/item?id=9459006
[scala-days-amsterdam]: http://event.scaladays.org/scaladays-amsterdam-2015
[shapeless]: http://underscore.io/events/2015-06-11-advanced-scala-shapeless.html
[creative-scala]: http://underscore.io/events/2015-06-08-creative-scala.html
[creative-scala-book]: http://underscore.io/training/courses/creative-scala/
[scala-days-amsterdam-noel]: http://event.scaladays.org/scaladays-amsterdam-2015#!#schedulePopupExtras-6914
[scala-days-amsterdam-dave]: http://event.scaladays.org/scaladays-amsterdam-2015#!#schedulePopupExtras-6958
[scala-days-amsterdam-richard]: http://event.scaladays.org/scaladays-amsterdam-2015#!#schedulePopupExtras-6925
[parleys-essential]: https://www.parleys.com/tutorial/essential-scala-six-core-principles-learning-scala
[parleys-shapeless]: https://www.parleys.com/tutorial/swiss-army-knife-generic-programming-shapeless-typeclass-type-class-action
