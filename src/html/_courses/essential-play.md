---
id: essential-play
title: Essential Play
layout: course
navbar: training
icon: play
color: "#a0c556"
courseDirectory:
  level: Intermediate
  length: 1 day
  icons: [ book, onsite ]
products:
  selfDirected:
    single:
      type: gumroad
      title: Get the Book
      url: "https://gum.co/essential-play"
      buttonLabel: "Buy now - £20"
      description: |
        Download the course textbook, complete with exercises and solutions, in HTML, PDF, and ebook formats.
    team:
      type: gumroad
      title: "20% Team Discount"
      url: "https://gum.co/essential-play"
      buttonLabel: "Buy now - <strike>£200</strike> £160"
      description: |
        Get your whole team up to speed with a <em>10 developer license</em> for 20% off individual pricing.
      comingSoon: true
  instructorLed:
    public:
      type: public
      title: "Public Courses"
      buttonLabel: "Register your interest"
      comingSoon: true
    private:
      type: private
      title: "Private Courses"
      buttonLabel: "Book now - £2000/team"
---

## Overview

This course covers a comprehensive set of topics required to create web sites and web services in Play.

Use Play's *Twirl* templating language to populate web pages with dynamic content. Build HTML5 content using your choice of Javascript, Coffeescript, Less, and/or CSS. Integrate client and server with AJAX and JSON. Write functional tests using Fluentlenium.

Write fast, non-blocking asynchronous code using futures and promises. Efficiently process and validate JSON data. Integrate with third party web services using Play’s WS client API. Build your APIs using clean, testable development practices.

## Learning Outcomes

- Understand Play routing, controllers, and actions
- Confidently write HTML and text page templates using Twirl templates
- Deploy significant Javascript, Coffeescript, Less CSS, and CSS codebases using the Play build system
- Use JSON AJAX to communicate between browser and server
- Know how to write functional web tests using Fluentlenium

## Table of Contents

- The Basics
  - Actions, Controllers, and Routes
  - Routes in Depth
  - Parsing Requests
  - Constructing Results
  - Handling Failure
- HTML and Forms
  - Twirl Templates
  - Form Handling
  - Generating Form HTML
- Working with JSON
  - Modelling JSON
  - Writing JSON
  - Reading JSON
  - JSON Formats
  - Custom Formats
  - Handling Failure
- Async and Concurrency
  - Futures
  - Thread Pools and ExecutionContexts
  - Asynchronous Actions
  - Calling Remote Web Services
  - Handling Failure