---
layout: post
title: Rethinking Online Training
---

If you are providing training in 2015 you have to be thinking about online delivery.
We had some unsatisfactory experiments teaching [Essential Scala](http://underscore.io/training/courses/essential-scala/) online last year,
where we essentially delivered our onsite training over Google Hangouts.
Online is a different medium,
and what works well face-to-face does not necessarily translate online.
Over Christmas we rethought the structure of our online courses to take advantage of the opportunities it offers,
and we are very excited by the new course structure we have developed.

<!-- break -->

### Goals

Our first step was to revisit the goals of Essential Scala.
Our aim is for people to understand the main patterns of functional programming
and be able to apply them to their own work.
That's why Essential Scala is built around core patterns of algebraic data types, structural recursion,
and so on.

Essential Scala evolved from a two-day onsite training course,
and the constraints of onsite training has had a profound effect on its structure.
Two days is not very much time.
For example, it's about one third of the contact hours for a course over a University semester.
Teaching two days back-to-back further limits the time available.
By the final afternoon everyone is tired and has difficulty with new concepts.
The result is that Essential Scala has relatively small exercises,
and little time for reflection.

This is not optimal.
We know learning takes time.
We know people need to work with larger programs.
We know they need to make mistakes and explore dead-ends.
We also know that it just isn't viable to do this in the context of onsite training
-- the time and hence cost is too high.
But when we sat down and thought about it, we realised we *could* do this online.

### Studio Style Learning

Teaching onsite naturally involves a lot of dead time.
We have regular breaks.
We have time when everyone is working on an exercise and doesn't need assistance.
We realised we don't have to be around for this if we teach online,
and if we are not around we don't have to charge for it.
This means we can expand the scope of our exercises without also increasing the cost.
This was our first insight.

The second insight came when we started thinking about how to structure online courses.
We are big believers in reading the literature.
People far more intelligent than us have spent a long time on the problem of teaching programming.
Essential Scala draws its structure from [How to Design Programs](http://htdp.org/), whose authors have received multiple awards for teaching.
When we did research on course structure we discovered the idea of [studio style teaching](http://slice.cs.uiuc.edu/pubs/Studio-SIGCSE2006.pdf).
In a studio style course students work on a project over a number of weeks.
Critically, they regularly discuss their code and incorporate feedback into its ongoing development.
The ideas and goals of studio style teaching resonated strongly with us
and we realised that we could deliver this online.

<div class="captioned">
  <img src="/images/blog/rethinking-online-training-studio.jpg">
  <div class="caption"><a href="https://www.flickr.com/photos/geishaboy500/1391045289/in/photolist-37Vtit-2b7abD-8dbJJa-9PGJCA-boM6Tg-6uW7sj-bKzvHR-nR7UCt-71chKo-718CjH-bDFDjU-718M7r-718Gnv-71cyn9-71cFYU-718M9D-71cvzW-71cvxj-718LZT-71cyiA-718KWR-71cAL7-5aeNME-5rathi-6a4z7H-71cHM3-ccQyCh-71cG4s-71cAFA-5reNRf-69daNY-71ciCN-71cwZf-71cmbQ-71cnpG-718gMa-71cjPS-718Nrn-71cPhC-71cu1E-71cEJf-71cDEs-718pYz-718t3D-xWdvq-5reNT9-37VtdF-bsb83A-bF61SK-71coGq">London Artists Studio by THOR</a> CC Licensed.</div>
</div>
  
When we got into the details
we quickly assembled a list of project ideas.
The first is [Doodle](https://github.com/underscoreio/doodle),
a compositional graphics library.
This is a classic functional langugage application dating back at least as far as [SICP](http://mitpress.mit.edu/sicp/full-text/book/book-Z-H-15.html#%_sec_2.2.4).
Doodle is going to make for some fun exercises,
and recreating the library is going to make a great case study.

### Course Open Now

We are very excited by this new style of teaching.
Essential Scala is ready to go,
and our first online courses are listed on our [events calendar](/events).
**For our very first course we are running a huge discount**,
with a preference given to diversity candidates.
Once we have experience with studio style learning via Essential Scala we will be adding studio learning components to our other online courses.
Expect announcements on those soon.



