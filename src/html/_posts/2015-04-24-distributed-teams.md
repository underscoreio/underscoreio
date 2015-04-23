---
layout: post
title: Practices for Distributed Scala Teams
author: Richard Dallaway
---

Jutta Eckstein's [recent presentation][infoq] on distributed teams rang true for me.
We've leaned much about distributed teams, about what works, and what causes issues.
In this post I'll note the challenges for new Scala teams,
and ways to tackle them.

[infoq]: http://www.infoq.com/presentations/agile-practices-distributed-teams
[book]: http://www.jeckstein.com/distributed-teams/
[remote]: http://stackoverflow.com/research/developer-survey-2015#work-remote-by-job

<!-- break -->

Here are four problems new Scala teams have to deal with:

* getting to grips with the language and tooling;
* gaining experience in the ecosystem;
* working at distance, across timezones; and, oh, the small matter of
* solving the customer's problem.

You can view these all as issues of communication.
The first two are about communication within the development team.
The last two are with the customer.  I'm going to look at the first two.

## Culture

If you're following along with her talk,
Eckstein's slide 20 (scan to 43:20 in the video) describes aspects of a common development culture. It includes:

* ensuring everyone has the required skills;
* using mentors and peer coaches; and
* learning from each other.

From a Scala perspective, the point here is gain the minimum skills, and then spread the adoption of idiomatic Scala and functional programming ideas.
If you're building a new team from developers with Java experience---not uncommon in our experience---this has added importance: you're at risk of not making the best use of the language.

_Disclosure:
I'm going to say more on pairing, training, and mentoring.
Although these are services we offer,
you do not need to go outside your own company to get the benefits.
Look around, and see who in your teams can fill these kinds of roles._

Peer coaches are pretty much the ideal way to achieve this adoption of a way of writing code.
What's a peer coach in this context?
They'll be a regular team member, perhaps a little more advanced than the average,
but who are able and willing to share ideas and tricks.

The help from mentoring---either in person, via pairing, or code review---is a role that need more experience. As Eckstein says in [her book on the subject][book]:

> "Mentors benefit protégés not only by their experience and advice but also by their encouragement to adopt and adapt project culture, especially if changes in attitude are required, as, for example, with test-driven development requests."

I would add to that: especially if adopting a new language and libraries, or adopting a functional way of tackling problems.

## Pairing

Pair programming is a great way to share experience through a team.
The tooling we have available means that there are no technical obstacles to remote pairing with a distributed team.
Personally, I enjoy it.

But what's the _purpose_ of pairing in this context? The two key points for me, noted at 6:50 in the video, are:

* continuous code review; and
* sharing the development culture.

Pairing provides immediate review, which is the best kind.
It's an opportunity to discuss the code interactively,
and talk about why it might be one way or another.
(We sometimes forget how effective talking can be as a form of communication.)

## Conclusion

Distributed teams are amazing: follow-the-sun-coding,
finding the best team members regardless of location, or having [happy developers][remote]... the benefits are clear.

If there are problems, such as low team velocity or low quality from review, there are options to try. The practices to consider include:

* encourage the team to share ideas and talk about the challenges they face;
* offer the team the support they need, such as time to explore or time to take training;
* establish peer coaches practices;
* use pair programming; and
* introduce mentoring.
