---
layout: post
title: SBT Tricks
author: Richard Dallaway
---

We all pick up SBT tricks: the settings, commands, or clues we wish we'd figured out earlier.
This post contains a section of some we use at Underscore.
What lesser-known tricks do you make use of?

<!-- break -->

## Changing JVM Options

Mid-session you sometimes want to change JVM flags.
The `javaOptions` setting is good for that. For example...

### Trace Typesafe Config Files

~~~ scala
project foo
set javaOptions := Seq("-Dconfig.trace=loads")
run
~~~

### Cheap and Cheerful Profiling

Here is another `javaOptions` example.
Nothing like as good as Mission Control or JProfiler, but still...

~~~ scala
project foo
set fork in run := true
set javaOptions in run += "-agentlib:hprof=cpu=samples"
runMain code.MyMain
~~~

...and then look in _foo/java.hprof.txt_.

## Triggered Execution

Running `~test:compile` rather than `~compile` when writing code is often what you really need.
Make sure *everything* in your codebase compiles as you go,
rather than checking the tests right before you commit.

Try this if you always want the console cleaned at the the start of each run:

~~~ scala
triggeredMessage in ThisBuild := Watched.clearWhenTriggered
~~~

You sometimes need `test:run` or `test:runMain` when that important application is in _src/test/scala_.

## Testing

This is a better-known trick: `testOnly` allows you to run a single test suite quickly as you write code:

~~~ scala
~testOnly mypackage.MyClass
~~~

You can also use `*` (not `_`) as a wildcard to run a set of test suites:

~~~ scala
~testOnly mypackage.*
~~~

## Stopping

When you run an application from SBT and hit CTRL-C it, it normally quits to your OS. This is annoying and can be prevented with:

~~~ scala
cancelable in Global := true
~~~

## Latest Dependencies

Ivy dependencies allow you to select "latest.integration" as the revision number:

~~~ scala
addSbtPlugin("org.ensime" % "ensime-sbt" % "latest.integration")
~~~

This will give you the latest and greatest version.
Use it for global plugins (see below) for you development environment.
Avoid it for core build dependencies because you want a reproducible build at all times.

##  The Place for Everything

SBT allows you to configure global settings and plugins for use in all your projects.
This content goes in several account-wide configuration files in `~/.sbt`:

* _~/.sbt/0.13/plugins/_ folder for the plugins you use everywhere such as ensime-sbt;

*  _~/.sbt/0.13/global.sbt_ for settings relating to those plugins;

* _~/.sbtrc_ for commands you expect to run on startup;

* _/usr/local/etc/sbtopts_ exists, and you can hope to never have to touch it.

Here are some useful examples of what you might do in each file:

~~~ bash
$ cat ~/.sbt/0.13/plugins/build.sbt
addSbtPlugin("net.virtual-void" % "sbt-dependency-graph" % "latest.integration")
addSbtPlugin("com.typesafe.sbteclipse" % "sbteclipse-plugin" % "4.0.0")
addSbtPlugin("com.github.mpeltonen" % "sbt-idea" % "latest.integration")
addSbtPlugin("com.orrsella" % "sbt-sublime" % "latest.integration")

$ cat ~/.sbt/0.13/global.sbt
net.virtualvoid.sbt.graph.Plugin.graphSettings
triggeredMessage in ThisBuild := Watched.clearWhenTriggered
cancelable in Global := true

$ cat ~/.sbtrc
alias cd = project
~~~

In fact, did you know that SBT will read *every* `.sbt` file in a directory when loading a project?
Use this to split up complex build files and modularise global settings:

~~~ bash
$ cat ~/.sbt/0.13/clear.sbt
// Handy `clear` command:
def clearConsoleCommand = Command.command("clear") { state =>
  val cr = new jline.console.ConsoleReader()
  cr.clearScreen
  state
}

commands += clearConsoleCommand
~~~

## Problem Solving

SBT-related problems are always something to do with scopes.

You can find the value of a setting in a particular scope using `inspect`:

~~~ scala
inspect project1/libraryDependencies
inspect project2/libraryDependencies
~~~

Sometimes you want to make a setting the same for all projects in a build, without having to repeat the configuration for each project:

~~~ scala
scalaVersion in ThisBuild := "2.11.7"
~~~

Regularly re-reading the [scoping rules](http://www.scala-sbt.org/release/tutorial/Scopes.html) helps with debugging scopes.

## Suggestions from the Community

Via [twitter](https://twitter.com/mglvl/status/663784551966224384), Miguel Vilá suggests `test-quick`: run all tests that failed previously, tests that are new, or tests that are affected by changes in existing code.

In the comments, Stefan Schwetschke suggests using the [Ammonite REPL][ammonite] as a replacement for the standard REPL (also known as the console). Ammonite features pretty printing, loading of dependencies directly from the REPL, multiline input and many more. Add to `global.sbt`

~~~ scala
libraryDependencies += "com.lihaoyi" % "ammonite-repl" % "0.4.8" % "test" cross CrossVersion.full

initialCommands in (Test, console) := """ammonite.repl.Repl.run("")"""
~~~

[ammonite]: http://lihaoyi.github.io/Ammonite/
