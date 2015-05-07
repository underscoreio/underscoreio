---
id: essential-macros
title: Essential Scala Macros
layout: course
navbar: training
icon: macro
color: "#F58B40"
courseDirectory:
  level: Intermediate
  length: 1 hour
  icons: [ video ]
  buttonLabel: "Watch for free"
coursePage:
  showSidebar: false
customHeader: |
  <div class="parleys">
    <div data-parleys-presentation="53a7d2c4e4b0543940d9e542" style="width:100%; height:400px">
      <script type = "text/javascript" src="//parleys.com/js/parleys-share.js"></script>
    </div>
  </div>
---


## Overview

This talk from ScalaDays 2014 is aimed at developers who want to learn the power of Scala Macros. Dave covers the basics of the macro API from a new developer's perspective, before going in-depth to implement several complete libraries. Examples include: a data validation DSL, boilerplate-free user-driven sorting and filtering, and boilerplate-free type-class-based data serialization.

<p class="text-center">
  <a class="btn btn-primary" href="https://github.com/underscoreio/essential-macros">
    Get the example code
  </a>
</p>

## Learning Outcomes

- Incorporate macros into your Scala 2.10 or 2.11 project
- Use quasiquotes to create and inspect abstract syntax trees
- Use generic macros to replace boilerplate code for custom data types
- Implement the type class pattern using generic and implicit macros

# Table of Contents

- Setup
  - Separate compilation and project structure
  - Basic code layout
  - Macro bundles

- Trees
  - Understanding common tree structures
  - Building trees using quasiquotes
  - Inspecting trees using pattern matching and traversal algorithms

- Types
  - Generic macros
  - Type tags and weak type tags
  - Inspecting and traversing types and symbols
  - Inspecting annotations on methods and case class fields

- Context
  - Implementing macros as methods
  - Error reporting with source locations

- Implicits
  - Writing implicit macros
  - Automatic type class materialization
  - Priority-based implicit packaging
