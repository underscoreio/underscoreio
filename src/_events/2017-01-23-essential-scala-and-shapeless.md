---
layout: event
title: "Essential Scala and Shapeless in LA"
course: essential-scala
date: 2017-01-23 09:00
timezone: PST
location: Los Angeles
duration: 3 days
navbar: events
summary: |
  Essential Scala comes to LA,
  along with a free evening Shapeless workshop
bookingLinks:
  - text: Purchase a ticket for Essential Scala
    url: https://www.eventbrite.com/e/essential-scala-tickets-31019172179
---

Underscore is running two events in late January in Los Angeles: Essential Scala, our course on Scala best practices, and a free Shapeless workshop the evening of the 24th.


## Essential Scala, 23-25 Jan 2017

This three-day course is aimed at the working Scala developer who wants to learn to use the best parts of Scala to write code that is type safe, modular, and extensible.

Most Scala developers have a background in imperative and object-oriented languages like Java, Ruby, or Python, and start using Scala in this style.
To get the most out of Scala we need to adopt the new tool that Scala brings to the table, which is the functional style of coding.
This training course covers the key functional programming patterns, and the Scala language features needed to implement them.
Our experiences in writing Scala code over many years is that these patterns cover the majority of our code.
Code written in this style uses is simple to read and write, because it uses only a few key ideas over and over again, and it leverages the type system to have maximum safety.

The curriculum covers three main patterns:
  - algebraic data types and structural recursion, for straightforward representation and transformation of data respectively;
  - sequencing computations with `map`, `flatMap`, and `fold`; and
  - type classes, for highly modular and extensible interfaces.

The course spends two days covering the foundational patterns, and a full day at the end dedicated to case studies. This is a great opportunity so bring problems from your work to the class and have our expert instructor show how you can use the new tools in Scala to solve them.

Attending will receive a free copy of the book [Essential Scala][essential-scala-book], along with lifetime updates to the material.

Attendees should bring their own laptop, with Scala and the development environment of their choice preinstalled.


### When, Where, and How Much?

The course will run from the 23rd to the 25th of January inclusive, at the LA offices of Nordstromrack.com: [700 S. Flower Street, Suite #1600 Los Angeles, CA, 90017][la-office].

Parking in the attached garage is $12 for arrivals before 10am and $32 if arriving after. There are cheaper lots nearby. The office is located directly across the street from the 7th St./Metro Center metro stop, which is accessible not only by the Expo line but also the red/purple and blue lines.

Tickets are [on-sale now][eventbrite-essential-scala], starting at a discounted rate of $1499 per person.


### About the instructor

Adam Rosien is an associate at Underscore, where he writes code, teaches classes, and mentors organisations large and small in the efficient adoption of Scala. He previously helped various startups in many domains develop back-end systems and implement continuous deployment practices, and also spent five years as a developer at Xerox PARC.



## Establishing Orbit with Shapeless, 24 Jan 2017

On the evening of the 24th, Adam will give a talk about [Shapeless][shapeless], the type generic programming library for Scala.

Type classes are one of the most important programming patterns in Scala. However, they come with a cost in terms of boilerplate. In this talk we'll discuss eliminating that boilerplate using shapeless.

The verbosity of type classes stems from the proliferation of the instances we have to define for every type in our business model. The code for these instances tends to be simple and mechanical in structure... wouldn't it be great if we could abstract over them and eliminate a whole load of redundant code?

Enter Shapeless, opening up a new world of generic programming. Shapeless gives us a boilerplate-free way of abstracting over algebraic data types (case classes and sealed traits). This allows us to write a small kernel of type class instances to support a huge variety of types, including a large portion of most business models.

This talk is aimed at intermediate Scala developers. You don't need to know what a type class is, or what shapeless is. However, you should have a familiarity with Scala syntax and know about things like Options and flatMapping.


### When, Where, and How Much?

The evening of 24 Jan 2017, at the LA offices of Nordstromrack.com: [700 S. Flower Street, Suite #1600 Los Angeles, CA, 90017][la-office]. Doors open at 6:30pm, talk starts at 7pm.

Parking in the attached garage is $12 for arrivals before 10am and $32 if arriving after. There are cheaper lots nearby. The office is located directly across the street from the 7th St./Metro Center metro stop, which is accessible not only by the Expo line but also the red/purple and blue lines.

It's completely free, but you must [sign up][shapeless-sign-up] before the event.

[la-office]: https://www.google.com/maps/place/700+S+Flower+St+%231700,+Los+Angeles,+CA+90017,+USA/@34.0482805,-118.2611318,17z/data=!3m1!4b1!4m5!3m4!1s0x80c2c7b6aee44e37:0x1e19794512737662!8m2!3d34.0482805!4d-118.2589431 
[essential-scala-book]: http://underscore.io/books/essential-scala/
[shapeless]: https://github.com/milessabin/shapeless
[eventbrite-essential-scala]: https://www.eventbrite.com/e/essential-scala-tickets-31019172179
[shapeless-sign-up]: https://www.eventbrite.com/e/establishing-orbit-with-shapeless-tickets-31068083474
