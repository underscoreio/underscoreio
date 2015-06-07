---
layout: event
title: "Towards Browser and Server Utopia with Scala.JS: an example using CRDTs" 
type: talk
location: Amsterdam
date: 2015-06-10 13:20:00 CEST
timezone: CEST
duration: 45 mins
navbar: events
summary: |
    This session demonstrates the practical application of Scala.JS using the example of a collaborative text editing algorithm, written once in Scala, but used from the JVM and JavaScript. 
---
This session demonstrates the practical application of Scala.JS using the example of a collaborative text editing algorithm, written once in Scala, but used from the JVM and JavaScript.
     
Scala.JS is a compelling way to build JavaScript applications using Scala. It also addresses an important and related problem, namely using the same algorithm client-side and server-side.
     
After this session you'll have an appreciation of:
     
- where Scala.JS can help with mixed environment projects;
- some of the gotchas you might encounter; and
- an understanding of collaborative text editing and CRDTs.
     
This session is relevant to anyone wanting to execute Scala code in JavaScript. In particular I'll focus on exposing Scala code for use from JavaScript, rather than a complete application written solely in Scala. This mitigates the risk of adopting Scala.JS, while still benefiting from shared code usage.
     
The demonstration will be based around a CRDT. CRDTs are an important class of algorithms for consistently combining data from multiple distributed clients. As such they are a great target for Scala.JS: the algorithms and data-structures involved will typically need to run on browsers and servers and we'd like to avoid implementing the (moderately complex) code twice. The specific algorithm will be WOOT, a text CRDT for correctly combining changes (think: Google Docs).
