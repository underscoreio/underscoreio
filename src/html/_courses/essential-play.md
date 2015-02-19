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
  icons: [ book, public, private ]
coursePage:
  showSidebar: true
products:
  selfDirected:
    single:
      type: gumroad
      title: Get the Book
      url: "https://gum.co/essential-play"
      buttonLabel: "Buy now - $40"
      description: |
        Download the course textbook, complete with exercises and solutions, in HTML, PDF, and ePub formats.
    team:
      type: gumroad
      title: "20% Team Discount"
      url: "https://gum.co/essential-play-team"
      buttonLabel: "Buy now - <strike>$400</strike> $320"
      description: |
        Get your whole team up to speed with <em>10 licenses</em>
        for Essential Play at a 20% discount.
  instructorLed:
    public:
      type: public
      title: "Public Courses"
      buttonLabel: "View upcoming events"
      comingSoon: true
    private:
      type: private
      title: "Private Courses"
      buttonLabel: "Book now - $3000"
---

## Overview

This course covers a comprehensive set of topics required to create web sites and web services in Play.

Use Play's *Twirl* templating language to populate web pages with dynamic content. Build HTML5 content using your choice of Javascript, Coffeescript, Less, and/or CSS. Integrate client and server with AJAX and JSON. Write functional tests using Fluentlenium.

Write fast, non-blocking asynchronous code using futures and promises. Efficiently process and validate JSON data. Integrate with third party web services using Play’s WS client API. Build your APIs using clean, testable development practices.

## Prerequisites

To benefit from this course you will need to know the fundamentals of the Scala language. We recommend [Underscore's Essential Scala](essential-scala.html) as the perfect complement to this course.

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
