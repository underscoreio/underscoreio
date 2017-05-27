---
layout: post
title: "Why We Open Sourced our Books"
author: Noel Welsh
---

From today we're open-sourcing all of our [books][books]. 
They can all be [downloaded for free][books], 
or you can checkout the source from their [Github][github] repositories.
In this post I explain why we made this decision 
and what is means for our books in the future

<!-- break -->

## Why Open Source?

Open sourcing our books is something we've been considering for a while.
For a while now we've had two free and open source books, 
[Creative Scala][creative-scala] and [The Type Astronaut's Guide to Shapeless][shapeless].
These books have reached an order-of-magnitude more people than our paid books.
On the other hand, we're not making money[^paper] from our free books, and it takes a long time to write a book.
When we considered the tradeoffs we decided that the contribution to the Scala community 
outweighed the relatively small amount (compared to other revenues) we earned from the books.
Basically, we believe there is some great stuff in our books---and our readers 
seem to agree---and we want more people to be able to access it.


## What Happens Now?

Not all our books are complete. 
In the last few days we've pushed out updates to 
[Advanced Scala][advanced-scala] and [Creative Scala][creative-scala], 
and we'll continue to work on the unfinished titles.
Once Advanced Scala is complete, which should be very soon, 
we'll turn our attention to finishing the long-neglected [Essential Interpreters][essential-interpreters].
In short, the decision to open source our books has no impact on our intention to develop them further.


## How Can I Get Involved?

The first thing you can do is [grab a copy][books] of any of our books in PDF, HTML, and ePUB format.
We ask for your email address so we can keep you aware of any updates.

If you want to build the book yourself, or contribute to development, go to our [Github][github] repositories.
All our books have a simple Docker based build process that should be straightforward to work with.
However, if you encounter difficulties please open an issue and we'll sort it out.

[books]: http://underscore.io/books/
[github]: https://github.com/underscoreio/
[creative-scala]: http://underscore.io/books/creative-scala/
[advanced-scala]: http://underscore.io/books/advanced-scala/
[shapeless]: http://underscore.io/books/shapeless-guide/

[^paper]: We do make a some money from donations, 
and from sales of paper copies of the Shapeless book, 
but it isn't a significant amount.
