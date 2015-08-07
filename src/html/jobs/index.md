---
layout: jobs
title: The Underscore Job Board
navbar: jobs
---

<article class="job-listing">
    {% assign jobs = site.jobs | sort: 'junior' %}
    {% for job in jobs reversed %}
    {% include jobs/excerpt.html job=job %}
    {% endfor %}
</article>

<p class="text-center">
  Recruiting is a problem for the entire community. We're doing something about it.
</p>

{% comment %}
- Scala is all we do and write about.
- Our audience is extremely targeted - every visitor is demonstrating an interest in Scala.
- We are putting our site traffic to work helping you recruit the Scala developers your business needs.
{% endcomment %}

<p class="text-center">
  This is a service to the Scala community. <em>There's no charge.</em>
</p>

{% comment %}
Conditions:

- Listings absolutely have to be for a role involving Scala.
- We are limiting each company to a maximum of three listings --- if you want use one listing to advertise multiple roles, that is absolutely fine and indeed preferred.
- We are giving preference to roles suitable for junior developers, as that's where we see the biggest need in the community.
- The other usual legal T&amp;Cs are on the submission form.
{% endcomment %}

<script>
  uio.jobListing.init(".job-listing")
</script>
