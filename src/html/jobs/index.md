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
  {% assign today = 'now' | date: '%s' %}
  {% assign jobs = site.jobs | sort: 'url' %}
  {% for job in jobs reversed %}
    {% assign expires = job.expire | date: '%s' %}
      {% if expires > today %}
        {% include jobs/excerpt.html job=job %}
      {% endif %}
  {% endfor %}
</article>

<script>
  uio.jobListing.init(".job-listing")
</script>
