---
layout: jobs
title: The Underscore Job Board
navbar: jobs
---

<p class="text-center">
  Recruiting is a problem for the entire community. We're doing something about it.
</p>

<p class="text-center">
  This is a service to the Scala community. <em>There's no charge.</em>
</p>

{% include jobs/links.html %}

<article class="job-listing">
  {% assign jobs = site.jobs | sort: 'url' %}
  {% for job in jobs reversed %}
  {% include jobs/excerpt.html job=job %}
  {% endfor %}
</article>

<script>
  uio.jobListing.init(".job-listing")
</script>
