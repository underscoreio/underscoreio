---
id: tigertap
name: Tigertap
sector: Media
role: Complete Product Delivery, AWS Hosting
tech: Scala, Lift, Postgres
logo: "/images/customers/tigertap.jpg"
title: "Tigertap"
lead: "Meaningful mobile interactions"
layout: page
---

## Mobile interactions at scale

Tigertap is a platform
for easily creating mobile marketing interactions.
Campaigns include simple information look up,
quizzes and competitions, data capture,
and coupons and loyalty cards.
Consumers tap NFC tags to interact with a service.

Campaigns are rolled out at high profile events,
such as conferences and sports events.

<p class="text-center">
  <img src="/images/case-studies/tigertap/tigertap.png"
       alt="Tigertap"
       height="300">
</p>

## Challenges of the services

These events are, by their nature,
unpredictable and extremely spiky.
Before a sport event there could be low levels of traffic,
then a peak during a game, especially during intervals,
tailing off over a small number of days or hours.
Consequently the service needs to scales up for demand,
and down to control cost.

## Challenges in the market

As Tigertap's mobile interactions
are used by customers,
new use cases become apparent.
It is vital to add and extend services when needed.
These changing requirements
need to interact well with existing services.

<p class="text-center">
  <img src="/images/case-studies/tigertap/screenshot.png"
       alt="Tigertap screenshot">
</p>

## Underscore's role

Underscore provided all the
remote software engineering
and cloud delivery effort,
including performance testing
and on-the-day event support.

Typically a new feature would be discussed over Skype,
and then Underscore would sketch out a solution
in terms of the user experience and the service logic.
This process would flush out consequences,
and may lead to simplification or generalisation of the service.
Implementation, testing, and production deployment would then follow.

<div class="testimonial">
  <blockquote>
    Calm purposeful approach to the problems and proposing solutions
  </blockquote>

  <p class="attribution">
    &mdash;Mathew Smith, Founder
  </p>
</div>

## Scala

The product consists of two main components:
a real-time administrative interface to control and monitor campaigns;
and a REST API for mobile clients to interact with.

Scala and functional principles were used throughout.
A key aspect of the work was
maintaining a coherent design in the face of changing requirements.
This enabled us to easily extend the platform as the product grew.
Using functional programming approaches helped achieve this
and allowed the team to "say yes" to change within a budget more often.

## Amazon Web Services

The services was deployed to AWS Beanstalk,
backed by RDS datastore,
and AWS SNS messaging.
This provides manual and auto-scaling capabilities to handle the spikes in traffic.

## Analytics

In addition to the standard reports provided by the platform,
the Tigertap team carried out their own custom reporting for clients.
Underscore supported the team,
helping design queries or discussing the data model behind the tap stream.

## The result

Tigertap's client feedback indicates the success of the platform:

> Tigertap has been such a pleasure to work with.
> We have used them for some of our highest profile events,
> and they have delivered NFC services flawlessly every time.
>
> When we talk about deploying millions
> or 100’s of millions of smart advertisements,
> most of the companies we talk to clam up.
> Tigertap built their system from day one with this sort of scale in mind.
> If you have large scale NFC projects, these are the guys.
