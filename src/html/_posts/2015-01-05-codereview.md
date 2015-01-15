---
layout: post
title: Code Review at Scala eXchange
author: Richard Dallaway
date: '2015-01-05 10:10:00'
categories: []
---

I normally give talks about something technical: "Look! A thing we did!". But this talk, from Scala eXchange, was different. It's really about Scala team experiences we've had over the last couple of years.

<!-- break -->

The sort of experiences are when get asked to review Scala projects and report back on how they look. Maintainable? Making use of the features of Scala? And yes, we see problems, but rather just list them out I wanted to show the way these reviews pan out.

<script async="async" class="speakerdeck-embed" data-id="7bd44f305d1b0132feae261f207a90b3" data-ratio="1.33333333333333" src="//speakerdeck.com/assets/embed.js"></script>


So I gave three examples with the aim of getting the audience to discuss what's good or bad about the code. It worked reasonably well. The part I enjoyed the most was talking about an example from my own code: review makes you hyper-critical of your own work.

There is [video of the talk](https://skillsmatter.com/skillscasts/5848-code-reviews-gems). Reflecting on this, I think the true summary is something like: _don't settle for crappy code_. There's a lot we can do--and a lot Scala helps with--to up the quality.  But you need to jump in early.


What I didn't go into in the talk is how you help a team if they are struggling. We've tried a few things, including Q&A sessions, pair-programming, and teaching specific topics. The results have been variable, but we have some pretty good ideas about why that is:

* For pairing, you need to put in quite a few hours. If you don't, it doesn't seem to make a lasting difference.

* Q&A works well at fixing specific problems. I think of it like a support arrangement. But when it turns out you really need full-time help, it's not enough. Sometimes you just need good old hands-on development. Especially if you have a complex domain.

* Reviewing does help, but leaving it late in development can mean there's a lot that needs fixing. It needs to be some kind of constant activity, which takes some organizing and discipline.

You should treat this as anecdotal. We've not carried out any kind of scientific survey here. We don't have huge numbers backing this up (this is from working with maybe 50 developers at most).

I'll finally comment that we can't help with silent teams. If you're not willing to talk about code and ideas, any kind of intervention is tough. But teams that talk, that's where we've had the best experiences.

