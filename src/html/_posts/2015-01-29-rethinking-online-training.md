---
layout: post
title: Rethinking Online Training
author: Noel Welsh
---

Since the beginning on the year we have been rebuilding the online version of [Essential Scala](training/courses/essential-scala/)
around studio style learning.
We delivered Essential Scala online last year,
but found the result unsatisfactory.
We taught the course in a similar way to our onsite version,
and it didn't survive the transition from face-to-face to online communication.
We realised we needed to radically change the course
to take advantage of the different medium.
We are really excited by the result,
and think it will offer a much better experience for our students.

<!-- break -->

### Context

Our goal with Essential Scala is to teach students to write simple, maintainable, and idiomatic Scala code.
To this end, Essential Scala focuses on core patterns of algebraic data types, structural recursion, sequencing computation, and type classes.

Students often stumble when transferring the lessons from the classroom to their own code,
reverting to their older, more familiar, coding patterns.
To really internalise the patterns 
we know we need to work with larger examples.
We know students need the time to make mistakes and explore dead-ends
but time is something we don't have in an onsite course.

### Studio Style Learning

We realised that a lot of the time during an onsite course,
we aren't delivering value to the students.
We have regular breaks.
We have time when everyone is working on an exercise and doesn't need assistance.
We spend time describing the material in the book that students could read faster for themselves.
We are valuable when we are talking with students about their code.
We realised that this is the only time we should be around in an online course.
It we reduce our contact to these times
we can give our students more time to learn
without increasing the cost of the course.

We still needed a structure for our online courses.
We are big believers in reading the literature,
where people far more intelligent than us have explored the problem of teaching programming.
For example, Essential Scala draws its structure from [How to Design Programs](http://htdp.org/),
whose authors have received multiple awards for teaching.
Doing a literature review led us to [studio style teaching](http://slice.cs.uiuc.edu/pubs/Studio-SIGCSE2006.pdf).
In a studio style course students work on a project over a number of weeks.
Critically, they regularly discuss their code and incorporate feedback into its ongoing development.
The ideas and goals of studio style teaching resonated strongly with us
and we realised that we could deliver this online.

<div class="captioned">
  <img src="/images/blog/rethinking-online-training-studio.jpg">
  <div class="caption"><a href="https://www.flickr.com/photos/geishaboy500/1391045289/in/photolist-37Vtit-2b7abD-8dbJJa-9PGJCA-boM6Tg-6uW7sj-bKzvHR-nR7UCt-71chKo-718CjH-bDFDjU-718M7r-718Gnv-71cyn9-71cFYU-718M9D-71cvzW-71cvxj-718LZT-71cyiA-718KWR-71cAL7-5aeNME-5rathi-6a4z7H-71cHM3-ccQyCh-71cG4s-71cAFA-5reNRf-69daNY-71ciCN-71cwZf-71cmbQ-71cnpG-718gMa-71cjPS-718Nrn-71cPhC-71cu1E-71cEJf-71cDEs-718pYz-718t3D-xWdvq-5reNT9-37VtdF-bsb83A-bF61SK-71coGq">London Artists Studio by THOR</a> <a href="https://creativecommons.org/licenses/by/2.0/">CC BY 2.0</a></div>
</div>

Our new online courses will run over four weeks.
Each week students will work through a chapter or two of Essential Scala.
This introduces new concepts
and solidifies their understanding.
We will also ask them to work on a larger project,
adding new features every week using the concepts they have learned.

We will spend the majority of our time
in our weekly meetings
critically discussing project code.
It is this discussion,
and the opportunity to apply its outcomes in the next week's work,
that solidifies learning.

Once we had the course structure down
we quickly assembled a list of project ideas.
The first is [Doodle](https://github.com/underscoreio/doodle),
a compositional graphics library.
This is a classic functional langugage application
dating back at least as far as [SICP](http://mitpress.mit.edu/sicp/full-text/book/book-Z-H-15.html#%_sec_2.2.4).
Doodle is a great case study
and will make for some fun exercises.

### Course Open Now

We are very excited by this new style of course.
The new studio style Essential Scala is ready to go
and our first intakes are listed on our [events calendar](/events).
**For our very first course we are running a huge discount**,
with a preference given to diversity candidates.
Once we have experience with studio style learning via Essential Scala
we will be adding studio learning components to our other online courses.
Expect announcements on those in the coming months. 



