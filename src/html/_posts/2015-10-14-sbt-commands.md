---
layout: post
title: SBT Tricks
author: Richard Dallaway
---

We all pick up SBT tricks: the settings, commands, or clues we wish we'd figured out earlier.
This post contains a section of some we use.
What lesser-known tricks do you make use of?

<!-- break -->

# Changing JVM Options

Mid-session you sometimes want to change JVM flags.
The `jvmOption` setting is good for that. For example..

## Trace Typesafe Config Files

~~~
project foo
set javaOptions := Seq("-Dconfig.trace=loads")
run
~~~

## Cheap and Cheerful Profiling

Nothing like as good as Mission Control or JProfiler, but still...

~~~
project foo
set fork in run := true
set javaOptions in run += "-agentlib:hprof=cpu=samples"
runMain code.MyMain
~~~

...and then look in _foo/java.hprof.txt_.


# Triggered Execution

Running `~test:compile` rather than `~compile` when writing code is often what you really need.

You always want the console cleaned at the the start of each run:

~~~
triggeredMessage in ThisBuild := Watched.clearWhenTriggered
~~~

You sometimes need `test:run` or `test:runMain` when that important application is in _src/test/scala_.


#  The Place for Everything

* _~/.sbt/0.13/plugins/_ folder for the plugins you use everywhere, such as ensime-sbt.

*  _~/.sbt/0.13/global.sbt_ for settings relating to those plugins.

* _~/.sbtrc_ for commands you expect to run.

* _/usr/local/etc/sbtopts_ exists, and you hope to never have to touch it.

For example:

    $ cat ~/.sbt/0.13/plugins/build.sbt
    addSbtPlugin("net.virtual-void" % "sbt-dependency-graph" % "0.7.5")
    addSbtPlugin("com.typesafe.sbteclipse" % "sbteclipse-plugin" % "4.0.0")
    addSbtPlugin("com.github.mpeltonen" % "sbt-idea" % "1.6.0")
    addSbtPlugin("org.ensime" % "ensime-sbt" % "0.1.7")

    $ cat ~/.sbt/0.13/global.sbt
    resolvers += "Type" at "http://repo.typesafe.com/typesafe/maven-releases"
    net.virtualvoid.sbt.graph.Plugin.graphSettings
    triggeredMessage in ThisBuild := Watched.clearWhenTriggered

    $ cat ~/.sbtrc
    alias cd = project

# Problem Solving

It's always something to do with scopes.

So sometimes you want to make a setting the same for all projects in a build:

~~~
scalaVersion in ThisBuild := "2.11.7"
~~~

You should regularly re-read the [scoping rules](http://www.scala-sbt.org/release/tutorial/Scopes.html).


