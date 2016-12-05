---
layout: event
title: "Codecs for Free! Shapless Type Class Derivation in Action"
color: "#25aae1"
date: 2016-03-21 18:30
timezone: GMT
location: London, UK
cost: Free
navbar: events
summary: Miles Sabin describes how Shapeless can automatically create type class instances.
bookingLinks:
  - text: "RSVP to the Meetup"
    url: http://www.meetup.com/GOTO-Nights-London-UK/events/228636806/
---

### What

Many idiomatic Scala libraries for serialization use type classes to express their ability to encode or decode values of particular Scala types to and from the formats they support.

Typically those libraries provide default instances for "standard" types and various ways of combining them. Library users must write instances for their own data types in terms of those. This is usually a time consuming and laborious process, but it is nevertheless completely mechanical, based entirely on the structure of the types involved.

So wouldn't it be nice if we could persuade the Scala compiler to use the structure of those types and do the work for us? Building on shapeless's core generic programming primitives and support for automatic type class derivation we can! In this talk Miles will introduce some of the projects which have adopted this strategy---Scodec, Circe, spray-json-shapeless and argonaut-shapeless to name just a few---and explain the surprisingly simple underlying mechanisms that allow them to do what they do.

### Where and When

The talk will be given by Miles Sabin at [Goto Nights][goto-night] on Monday, 21 March 2016.

[goto-night]: http://www.meetup.com/GOTO-Nights-London-UK/events/228636806/
