---
layout:     post
title:      "Review Seq matching when porting to 2.13"
author:     "Richard Dallaway"
---

You know the routine for porting from Scala 2.12 to 2.13: you'll get a bunch of compiler errors and warnings, and you can quickly enough hack your way through them.

There is, though, one runtime issue I've bumped into. When pattern matching on `Seq` from a library, you need to be careful about what kind of a `Seq` you've been handed.

<!-- break -->

# Good news

The [migration guide] for 2.13 explains that the `scala.Seq[+A]` alias has changed from `scala.collection.Seq[A]` to `scala.collection.immutable.Seq[A]`. (That's a great guide, BTW, and you'll want to read it).

This is good news because the `Seq` you get by default in Scala 2.13 is immutable.

# The issue

The short-term cost to this gain is an issue under specific circumstances. 

If:

- you use pattern matching on a `scala.Seq` (or `IndexedSeq`) in 2.12
- where the `Seq` comes from a library
- and you upgrade to 2.13

...then you may find your patterns no longer match at runtime.

The reason is that in 2.12 your `Seq` is the agnostic `scala.collection.Seq`,
but in 2.13 it's the strong `scala.collection.immutable.Seq`. 

The library, however, may still be giving you a `scala.collecton.Seq`.
The 2.13 default `Seq` is _specifically_ immutable, which has more constraints on it that `scala.collection.Seq`.
They won't match in a pattern.

To be clear, you should check what kind of `Seq` you're getting.
A library might be designed to give you an immutable `Seq`, 
in which case you'll have no problems.

# Example

Consider pattern matching on `Seq` handed to us in a `JsArray` from [Play JSON]:

```
// Using "com.typesafe.play" %% "play-json" % "2.8.1"

import play.api.libs.json._

def main(args: Array[String]): Unit = {

  // We will parse this into `JsArray(scala.collection.IndexedSeq)`
  val json = Json.parse(""" [ "hat", "dog" ]  """)

  json match {
    case JsArray(Seq(s1, s2)) => println(s"Matched: $s1, $s2")
    case otherwise => println(s"Unexpected: $otherwise")
  }
}
```

What does this code do? 

- Compiled with 2.12, this code prints `Matched: hat, dog`.

- Under 2.13, the `otherwise` branch matches.

You can try it in [Scastie](https://scastie.scala-lang.org/d6y/zC8ALBU8RZe573GPAxL40w/4), adjusting the compiler in "Build settings".

The fix in this case could be to specify which `Seq` we mean:

```
case JsArray(scala.collection.Seq(s1, s2)) =>
  println(s"Matched: $s1, $s2")
```

In other words, we've loosened the match, no longer demanding an immutable `Seq`.

Perhaps in the future (issue [388]) the library will return an immutable `Seq`.

# Recommendations

- Do read the [migration guide] which contains several options for handling the `Seq` change.

- Your tests can help you catch this, and code coverage can help you find gaps. Search your code coverage looking for uncovered matches on `Seq`, where the `Seq` originates from a library.

- If that's hard, a quick and dirty `grep` pipeline or similar would be worth doing.

- Be ready for libraries changing to the new `Seq` or adding variations of methods that return the new `Seq`.

I'm not aware of a [scalafix] for this change, but if anyone knows of one, do share it.

_Originally posted [on Richard's site](https://richard.dallaway.com/2020/05/05/seq-porting.html)_.

[migration guide]: https://docs.scala-lang.org/overviews/core/collections-migration-213.html
[scalafix]: https://scalacenter.github.io/scalafix/
[Play JSON]: https://github.com/playframework/play-json
[388]: https://github.com/playframework/play-json/issues/388
[Miles]: https://twitter.com/milessabin/
