---
layout:     post
title:      "Tips for moving from tut to mdoc"
author:     "Richard Dallaway"
---

[Creative Scala][cs] and [Essential Slick][eslick] use [mdoc],
as will [_Scala with Cats_ in the next edition][cats2].
mdoc helps us be sure the code we describe works,
no matter how often we update the text.
It does this by typechecking and running the Scala source in our text.

Before mdoc we used the mighty [tut].
We've learnt a few tricks as we switched from one to the other, 
and collected them together in this post.

[cs]: https://underscore.io/training/courses/creative-scala/
[eslick]: https://underscore.io/books/essential-slick/
[withcats]: https://underscore.io/books/scala-with-cats/
[cats2]: https://github.com/underscoreio/scala-with-cats/issues/170
[mdoc]: https://scalameta.org/mdoc/
[tut]: https://tpolecat.github.io/tut/
[migration guide]: https://scalameta.org/mdoc/docs/tut.html
[mbp]: https://scalameta.org/mdoc/blog/2019/12/30/introduction.html
[Twitter]: https://twitter.com/underscoreio


<!-- break -->

# Overview

mdoc processes the Scala code inside named code fences:

    ```scala mdoc
    val x = 1
    ```

The code is type-checked and executed, and the output inserted into a markdown file:

    ```scala
    val x = 1
    // x: Int = 1
    ```

Before mdoc, tut did the same job, but tut is now deprecated.
Everyone should move to mdoc, and we have.

In doing that, we learned a few key tricks:

1. Resetting digs you out of the semantic differences between tut and mdoc.

2. Understand how mdoc nests your code inside a class (or object).

3. Hidden validation is a useful tool to use.

Let's see some examples.

# Reset and semantic differences

As the excellent [migration guide] tells you, there's one big difference between tut and mdoc:

- Working with tut is like typing into the REPL.
Working in a REPL means you can redefine thing as you go,
but also you sometimes have to nest expressions in objects for the REPL.

- On the other hand, mdoc is like writing a program and compiling it. 
In other words, redefining a variable name is not permitted, 
but you don't have to worry about REPL-specific behaviour. 

For good or bad, using tut I often redefine values.
For example, I'll build up to a solution to give a foundation for how something works,
but then redefine the solution to show a more compressed way most people use a feature.
Or we'll set an exercise, and then implement it (redefining placeholders with working code) in the solutions section.
Reusing the same variable names for both is fine in tut, but not in mdoc.

When porting to mdoc, you can introduce new names as you go.
That works, but can be awkward or forced in some situations.
Naming is, after all, one of the hard problems in computer science.

The alternative in mdoc is to reset and start a new scope. 
This means you can "redefine" a value again (as far as the reader is concerned).
The downside is that you have to re-establish any context you rely on.

For example, in _Essential Slick_ a common sequence is:

    ```scala mdoc:reset:invisible
    import slick.jdbc.H2Profile.api._
    ```

That's establishing a new context, and invisibly importing the API.
Invisible means the code is run, but no output is included in the book.

With this in place, I can redefine whatever I wanted to and carry on writing.
It's a sledgehammer, and perhaps a sign of a problem in the text if you have to do it a lot, but invaluable when:

- working on a tutorial-style text with repeated definitions; and

- presenting problems and solutions.

A reset between major sections is probably a good practice.
Writing shorter chapters would have the same effect.


# Reset object

Reset introduces a new scope by wrapping code in a class.
That's great until you define a value class and you see:

```
value class may not be a member of another class
class EmailAddress(val value: String) extends AnyVal
      ^^^^^^^^^^^^
```

The trick to know here is to define value classes inside an object,
which is what `reset-object` gives you:

    ```scala mdoc:reset-object
    class EmailAddress(val value: String) extends AnyVal
    ```

That'll work fine.

There's a useful [mdoc blog post][mbp] giving an example of how a document is translated into code,
if you want to see more on that.


# Hidden validation

In the last chapter of _Essential Slick_ we give the concise way to define an instance
of the `SetParameter` type class for a `DateTime`:

    ```scala
    implicit val setDateTime = SetParameter[DateTime](
      (dt, pp) => pp >> new Timestamp(dt.getMillis))
    ```

The `>>` part looks a bit too much like line noise,
but in the book we've built up to this and showed you the long way to do this already.

Notice that the `setDateTime` value is _not_ an mdoc expression.
It's a plain markdown Scala code block, so will not be run by `mdoc`.

I did that because redefining an implicit would be a problem here:
I've already defined an implicit instance earlier to work up to this,
and you cannot have multiple instances in scope.
Renaming won't help here.

Resetting away the whole scope was over-kill in this case,
so I just literally showed what the code would be.
But under that block is an invisible section to validate it:

    ```scala mdoc:invisible
    // validate the above code without introducing a duplicate implicit:
    object Hidden1 {
      implicit val setDateTime = SetParameter[DateTime](
        (dt, pp) => pp >> new Timestamp(dt.getMillis))
    }
    ```

This kind of hidden validation is another trick worth having to hand. 
It doesn't come up often, best if you don't need to do it, but great that you can.

# Summary

We've converted a few hundred pages that used tut to now use mdoc.
It's been reasonably straightforward,
and tools like `reset`, `reset-object`, and `invisible`
let you get the output you want.

If you have any mdoc (or tut) tricks,
do share them using our Gitter channel (see below)
or via [Twitter].

