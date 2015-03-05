---
layout: post
title: "Newsletter 7: Error Handling and Two New Books"
author: Noel Welsh
categories: [ newsletter ]
---
Hi,

Let's talk about when things go wrong. It, inevitably, happens and every program needs an error handling strategy. The right strategy depends on the context -- a throwaway script might not even need to handle errors -- but the tasks for which Scala is typically used demand a robust approach.

In our code reviews we often see ad-hoc approaches to error handling that rely too much on people remembering to do the right thing. Last month we ran a mini-series on this topic on the blog, presenting some intermediate-level techniques that you can apply to make your code more robust.

<!-- break -->

[This first post][error-handling-1] in the series shows how the type system can be used to prevent errors in the first place, and to ensure remaining errors are dealt with.

[The followup post][error-handling-2] goes deep into handling errors, showing how to systematically build robust code that is guaranteed to deal with errors (a teaser: don't use exceptions or `Try`).

At the end of the second article we talk a little about union types. When that article was written we didn't know a really satisfactory way to represent them in Scala. The very next day [this blog post][union-types] was published, presenting a straight-forward approach to representing union types in Scala.

These approaches have worked very well for us. Give them a try and let us know how they pan out in your code base. 


## Pre-release of Advanced Scala with Scalaz 

This type of design knowledge is what we're trying to capture in our latest book, Advanced Scala with Scalaz (formerly known as Essential Scalaz), which we've literally just released as an [early access version][advanced-scala].

The main goal of the book is to teach system architecture and design using the techniques of modern functional programming. This means designing systems as small composable units, expressing constraints and interactions via the type system, and using composition to guide the construction of large systems in a way that maintains the original architectural vision.

The book also serves as an introduction to Scalaz. We use abstractions from Scalaz, and we explain the structure of Scalaz so you can use it without fear in your own code base. The broad ideas are not specific to Scalaz, but Scalaz provides an excellent implementation that is beneficial to learn in its own right.

Advanced Scala is also available bundled with Essential Interpreters, a short book we're writing on building interpreters, which is [considered by many][don-stewart-so] in the functional programming community to be *the* primal FP pattern. Essential Interpreters will cover the basics all the way up to free monads -- used to great effect in [Facebook's Haxl][haxl], [Twitter's Stich][stitch], and more.

The [book page](http://underscore.io/training/courses/advanced-scala-scalaz/) has more information on the books, including the tables of contents.

## Creative Scala

Last week we released a short book called [Creative Scala][creative-scala]. It's designed for people with no previous Scala or functional programming experience who want a short and fun introduction to Scala. The exercises are all built around computer graphics using [Doodle][doodle]. 

Creative Scala is free and [open source][creative-scala-github], and already over 1'600 people have downloaded it.


## Edinburgh Events

Later this month I'll be in Edinburgh teaching two Scala courses:

- a free [Creative Scala][creative-scala-ed]; and
- a paid [Advanced Scala][advanced-scala-ed].


## Scala Days SF

There are still a few places left in our [one day Advanced Scala course](http://underscore.io/events/2015-03-19-essential-scalaz.html) in San Francisco.

We could also really use some more experienced Scala developers to act as teaching assistants in the [Creative Scala course][creative-scala-sf] we're running before Scala Days. We have some seventy-odd students who want to attend, and a few more teaching assistants would make all the difference in giving them a great experience trying out Scala for the first time. If you, or any of your friends, are based in San Francisco please consider helping out. See [the course page][creative-scala-sf] for more.

Now, if you'll excuse me, I have a book chapter to finish. Till next time.

Regards,
Noel

[error-handling-1]: http://underscore.io/blog/posts/2015/02/13/error-handling-without-throwing-your-hands-up.html
[error-handling-2]: http://underscore.io/blog/posts/2015/02/23/designing-fail-fast-error-handling.html
[union-types]: http://japgolly.blogspot.co.uk/2015/02/zero-overhead-recursive-adt-coproducts.html
[creative-scala-ed]: http://underscore.io/events/2015-03-28-creative-scala.html
[advanced-scala-ed]: http://underscore.io/events/2015-03-30-advanced-scala.html
[creative-scala]: http://underscore.io/training/courses/creative-scala/ 
[doodle]: https://github.com/underscoreio/doodle
[creative-scala-github]: https://github.com/underscoreio/creative-scala 
[advanced-scala]: http://underscore.io/training/courses/advanced-scala-scalaz/
[creative-scala-sf]: http://underscore.io/events/2015-03-15-creative-scala.html 
[don-stewart-so]: http://stackoverflow.com/a/27860072
[haxl]: https://github.com/facebook/Haxl
[stitch]: https://www.youtube.com/watch?v=bmIxIslimVY
