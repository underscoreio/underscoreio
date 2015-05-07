---
layout: jobs
title: The Underscore Job Board
navbar: jobs
---

<article>
    {% for job in site.jobs %}
      {% include jobs/excerpt.html job=job %}
    {% endfor %}
</article>

<script>
  uio.jobListing.init(".job-listing")
</script>

Recruiting is a problem the entire community has. We're doing something about it.

<!--
- Scala is all we do and write about.
- Our audience is extremely targeted --- every visitor is demonstrating an interest in Scala.
- We are putting our site traffic to work helping you recruit the Scala developers your business needs.
-->

This is a service to the Scala community. **There's no charge.**

<!--
Conditions:

- Listings absolutely have to be for a role involving Scala.
- We are limiting each company to a maximum of three listings --- if you want use one listing to advertise multiple roles, that is absolutely fine and indeed preferred.
- We are giving preference to roles suitable for junior developers, as that's where we see the biggest need in the community.
- The other usual legal T&amp;Cs are on the submission form.

-->