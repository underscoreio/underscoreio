---
id: essential-distributed-systems
title: Essential Distributed Systems
layout: course
icon: network
color: "#21a9e1"
level: Intermediate Java or Scala
summary: |
  For Java or Scala developers who want to learn
  the theory and practice of building distributed systems.
onsite:
  duration: "2 days"
  buttonLabel: "Book now - {% currencies $7,500 £5,000 €7,000 %}"
---

## Overview

Distributed systems introduce new challenges in building reliable, scalable software. This course teaches the core theoretical principles for constructing distributed systems and invites particpants to build their own systems using Scala or Java and a set of elemental tools.

We cover three approaches -- message queues, distributed caches, and eventual consistency -- and learn the benefits and drawbacks of each. Finally, in a review session, we bring together all of the principles covered to build a non-trivial distributed system in its entirety.

The workshops are designed to maximise theoretical and practical learning, by ﬁrst giving background and examples and then participants are asked to build their own systems based on the most simple ( elemental ) implementations of various tools which will be provided. The ﬁnal half day session is based around a larger practical to bring together the various techniques and systems the participants have used in the other sessions.

The workshops are suited to both Java and Scala programmers and workshop have run very well with a mix of Java and Scala programmers.

## Prerequisites

This course is aimed at experienced Scala and Java developers. You choose the language to use during the course.

## Learning Outcomes

Delegates will gain a wide understanding of the various distributed tools at their disposal when designing and building distributed systems. They will understand the strengths and weaknesses of each tool in various contexts.

By examining one or a number of underlying distributed systems patterns by example and implementation, delegate will be able to understand and apply these patterns in new contexts, leading to better overall systems design and implementations which are independent of the speciﬁc language of implementation.

## Table of Contents

- Message Queues
  - Introduction and Background
  - Lookup
  - Messages and Message passing style
  - Publish/Subscribe
  - Message Channels
  - Practical 1 - Most simple Publish/Subscribe
  - The Hungry Worker Pattern
  - Practical 2 - Many Hungry Worker Practical
  - Load Considerations
  - Failure Considerations
  - CAP Theory and Practice
  - Fan In / Fan Out Patterns
  - Pipelines
  - Practical 3 - DAG Pipelines
  - DAG Executors
  - *Optional: Overview of various Message Queue Implementations - ActiveMQ, RabbitMQ, Push, Solace*
  - Review, Conclusions and follow up links and material.
  - Practicals continuation and extension.

- Distributed Caches
  - Introduction and Background
    - Local Caches and Maps
    - Keys and Values and Hashes
    - Distribution
  - Practical 1 - Most simple Cache case - HTTP Cache.
  - Distributed Cache
  - Practical 2 - Multi Consumer
  - Load Considerations
  - Failure Considerations
  - Practical 3 - Size Limited Cache
    - Eviction Policies
  - Keys with Time to Live
  - Redis and Memcached
    - Redis Data Types
    - Memcached details
  - ObjectSpaces
    - *Optional: ObjectSpace Practical*
  - Review, Conclusions and follow up links and material.
  - Practicals continuation and extension.

- Eventually Consistent Systems
  - Introduction and Background
    - Consistent Hashing
    - Dynamo and Derivatives
  - Practical 1 - Consistent Hashing
  - Distribution
  - Practical 2 - Multi Hash
     - Opt. Add a Node
  - CAP Theory Revisited
  - Eventually Consistent Data
  - CRDTs in General
    - Cassandra / Riak 2.0
  - Practical 3 - G Counter
  - Eventually Consistent Values
  - Practical 4 - NP-Counter
  - Review, Conclusions and follow up links and material.
  - Practicals continuation and extension.

- Review Project
  - Project Description and Background
    - Content Distribution Network
    - Global Reach
    - Team Working
  - Design Goals
  - Service Design Details
  - Client Simulator
  - Project Phases
  - Optional : Review Various Topics as required
