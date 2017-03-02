---
layout: event
title: "SBT Plugins: How and Why"
type: talk
location: Scala Central, The Guardian, London
date: 2017-03-15 18:30:00 GMT
timezone: GMT
duration: 20 mins
navbar: events
course: essential-scala
summary: |
  Danielle Ashley will show how to build a simple SBT plugin,
  shining some light on the architecture of SBT along the way.
bookingLinks:
  - text: Sign up for the meetup
    url: https://www.meetup.com/Scala-Central/

---

# Abstract

In this talk we'll learn about the inner workings of SBT
by walking through the creation of a simple plugin.
In large projects and/or organisations,
building the project involves more than just compiling the code.
Using plugins we can customise SBT to automate almost any task imaginable: t
esting, publishing, reporting, generating documentation, code analysis, and so on.
However, we might wonder what we would do on the fateful day
when the plugin we are looking for doesn't exist
and we have to write it ourselves.

This talk will give us a headstart on such a day.
We will start by lifting the lid on some existing SBT plugins,
learning more about how they are constructed and how they work.
Then, we will take control and develop a simple one of our own.
We'll see how plugins interact with the build
and in the process learn more about SBT in general,
demystifing this sometimes maligned tool.
