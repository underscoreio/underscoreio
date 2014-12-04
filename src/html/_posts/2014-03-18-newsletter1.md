---
layout: post
title: Newsletter 1
author: Noel Welsh
date: '2014-03-18 12:00:00'
categories: [ newsletter ]
---

So, what's in the newsletter? To begin with there is a summary of recent blogs posts and events from us, as well as details of upcoming events.  I thought it would also be interesting to talk about some work in progress that isn't at the state where we'd blog about it. So the second half of the newsletter has some discussion of the scalaz-stream project and Akka cluster. I hope you enjoy reading this! Do let me know what you like and what you don't like. Replying to this email will go directly to me.

<!-- break -->

## On The Blog

Distributed systems is a bit of theme at the moment. Consistency, meaning all machines see the same data, is a core issue in distributed systems. In a sequence of blog posts Richard and I explored CRDTs, a data structure that makes it simple to regain consistency from a certain type of inconsistent data. [My post](http://underscoreconsulting.com/blog/posts/2013/12/20/crdts-for-fun-and-eventual-profit.html) described some of the theoretical background and a few of the fundamental data structure for counters and sets. [Richard's post](http://underscoreconsulting.com/blog/posts/2014/01/06/crdt.html) described a more complex data structure for collaborative text editing.

The other big news on the blog was our announcement of the [Core Scala](http://underscoreconsulting.com/blog/posts/2014/03/10/teaching-scala.html) training material. Having recently rewritten the course from scratch we think it's too good to keep to our on-site training customers, so we're developing material to sell online. Expect to hear more about this in the coming months. Speaking of training, we're expanding our training offerings. Nigel Warren has just started delivering a series of workshops on distributed systems for the BBC.

Finally we had some posts on moderately advanced techniques in Scala: [monad transformers](http://underscoreconsulting.com/blog/posts/2013/12/20/scalaz-monad-transformers.html) and [unboxed tagged types](http://underscoreconsulting.com/blog/posts/2014/01/29/unboxed-tagged-angst.html).


## Functional Media

The most recent edition of our [Functional Media](http://www.meetup.com/Functional-Media/) meetup was hosted by [Time Out](http://www.timeout.com/). The presentation was full of Scala goodness, and is online [here](http://prezi.com/3pq-fjwxbatb/a-type-safe-solar-system/). The next Functional Media event will be in May and will be hosted by [Mind Candy](http://mindcandy.com/).


## Scala Days

If you haven't seen the [Scala Days](http://scaladays.org/) programme yet, stop what you're doing and check it out -- it's an amazing selection of talks! Amongst the talks are two from Underscore members:

- Dave Gurnell will be bringing his years of experience with Scheme macros to [explain Scala macros](http://scaladays.org/#schedule/Macros-for-the-Rest-of-Us) in an approachable manner.

- Miles Sabin will describe [how Scala has changed](http://scaladays.org/#schedule/Scala--The-First-Ten-Years) in the last 10 years. He's joined by Jon Pretty, another stalwart of the London Scala community.

I hope we'll see you at Scala Days. It really does look to be a fantastic event.


## scalaz-stream and Akka Cluster

Two projects that I've recently been exploring are [scalaz-stream](https://github.com/scalaz/scalaz-stream) and [Akka Cluster](http://doc.akka.io/docs/akka/snapshot/common/cluster.html). I see them as complimentary tools, with scalaz-stream handling single machine concurrency and Akka Cluster handling the distributed systems part. I don't yet have enough experience with either to give a detailed impression but let me write a bit about why I find them interesting.

Scalaz-stream is everything you'd expect from a Scalaz project: lots of intricate little pieces that slot together perfectly. The goal of scalaz-stream is to write programs that process streaming I/O in a type-safe and composable manner. This model is a natural fit of a service-oriented architecture. Each service is a `Process`, and services compose in a straight-forward way. Concurrency is an orthogonal issue in scalaz-stream, so you can choose the right concurrency model for your code. Scalaz-stream provides utilities for queues and actors and so forth.

I think most Scala users will have experience with single machine concurrency, and so can appreciate scalaz-stream. This is perhaps not the case with Akka Cluster which provides tools for building a particular type of distributed system, so I'll give a more detailed explanation of what it provides.

If you're interested in distributed systems you will have heard of the [CAP theorem](http://en.wikipedia.org/wiki/CAP_theorem). If not, it basically says you can have any two of consistency (all nodes see the same data), availability (all requests receive a response), and partition tolerance (the system operates despite inability of components to communicate). Many Internet systems, with geographically distributed users and always-on requirements, need availability and partition tolerance but this requires giving up consistency.

Giving up consistency doesn't need to bring big headaches. Above I linked to two blog posts about CRDTs, which make it easy to handle data in an inconsistent system. CRDTs mean we can deal with data in a distributed system where machines can't always talk to one another (due to network failures or other issues), but how do we build such a system? This is what Akka Cluster provides. The main components are:

- a so called [gossip protocol](http://en.wikipedia.org/wiki/Gossip_protocol) for establishing membership as machines enter and leave the system;
- a failure detector, which does what the name suggests; and
- [consistent hashing](http://en.wikipedia.org/wiki/Consistent_hashing) to distribute load across a varying number of machines.

This is well established technology, used in [Riak](http://basho.com/riak/) and [Amazon's Dynamo](http://en.wikipedia.org/wiki/Dynamo_%28storage_system%29) for example. Akka Cluster systems can grow and shrink dynamically. There are no master nodes, so any machine can leave the system without impacting other machines. This means very robust and flexible systems are possible.

I'll be playing around with Akka Cluster more in the coming months and will report back experiences.

## Conclusion

That's it. Hope you enjoyed reading the newsletter, and do let me know if you have any suggestions for the next edition.

Regards,<br>
Noel
