---
layout: post
title: Compositional Music Composition
author: Dave Gurnell
date: '2015-02-01'
---

Noel [recently wrote about](2015-01-26-rethinking-online-training.html)
[Doodle](https://github.com/underscoreio/doodle),
the compositional drawing library that we will be featuring
in the new studio format of Essential Scala.
Today I want to introduce you to another compositional library,
this time for... composing music.

<!-- break -->

<img src="/images/blog/2015-02-01-compositional-music-composition.jpg">

<p class="text-center">
  <a href="https://www.flickr.com/photos/jonnyentropy/8237873224">Photograph by Tris Linnell, CC-BY-NC-SA.</a>
</p>

Musical notation has a long and rich history.
Modern sheet music, the end result of centuries of evolution,
is an extremely efficient tool.
We can think of it as a programming language for musicians:
it stores precise instructions on how to play a song, and
conveys them in a simple, clutter-free manner
that can be read by sight during a performance.

Although the aesthetic similarities between musical notation and
program code are clear, the differences in practical terms are stark.
It is practically impossible to create musical score
without a graphical editor<sup>1</sup> and
most file formats are binary (or worse, XML<sup>2</sup>).
Oddly, the closest thing we have to simple music format
that can be easily be version controlled is guitar tablature:

<pre class="text-center">
Freebird - Allen Collins Solo - Bars 1 and 2

|-------------------------------|----------------------------|
|-3------------3---3---3-3------|-5--x-----------------------|
|-4------------3-x-3-x-3-3--x-x-|-5--x-----------------------|
|-5--x-------x-3-x-3-x-3-3--x-x-|-5--x-----5----5----5----5--|
|-5--x---0-2-x-1-x-1-x-1-1--x-x-|-3----5h7----7----7----7----|
|-3--x-3-----x------------------|----------------------------|

</pre>

As an interesting thought experiment let's consider how we would
represent musical score in a functional programming language like Scala.
To simplify the problem we'll concentrate on storing the music
for execution by a computer as opposed to a musician.
We'll use the standard FP design strategy I talked about at
[Scala Exchange](https://skillsmatter.com/skillscasts/5837-functional-data-validation)
of determining the smallest building blocks first
and then creating functions to compose them in interesting ways.

## Notes, Rests, Pitch, and Duration

The smallest building blocks in a score are *notes* and *rests*.
Notes have a *pitch* and *duration* and rests simply have a *duration*.
Let's look at these first.

A convenient represenation of pitch would be
the corresponding key on the piano:
`C4` for middle C, `D4` for the next white note,
`Cs4` for the C sharp between the two, and so on:

<img src="/images/blog/2015-02-01-compositional-music-composition-pitches.jpg">

<p class="text-center">
  <a href="https://www.flickr.com/photos/124497826@N08/14121388525">Photograph from the Leeds Piano Competition, CC-BY.</a>
</p>

~~~ scala
case class Note(value: Int)

object Note {
  def apply(offset: Int, octave: Int) =
    Note(offset + 12 * octave)

  val C4  = Note(0, 4)
  val Cs4 = Note(1, 4)
  val D4  = Note(2, 4)
  // ...

  val C5  = Note(0, 5)
  val Cs5 = Note(1, 5)
  // ...
}
~~~

Durations are measured in *beats*.
There are typically four beats a bar but notes may be much shorter
so we represent things like half beats, quarter beats, and so on.
We'll start with a set of binary dubdivisions and
worry about things like triplets and dotted notes later on:

~~~ scala
case class Duration(value: Int)

object Duration {
  val Whole        = Duration(64)
  val Half         = Duration(32)
  val Quarter      = Duration(16)
  val Eighth       = Duration(8)
  val Sixteenth    = Duration(4)
  val ThirtySecond = Duration(2)
  val SixtyFourth  = Duration(1)
}
~~~

There is another important component that we're ignoring here -- *volume*.
Without volume dynamics our musical compositions will sound
quite inhuman and computer generated.
We'll save this for a future feature addition.

## Scores

Now we have the basics of pitch and duration out of the way,
let's think about how we can combine notes to make musical scores.
In the simplest possible terms we can combine pieces of music in
*sequence* (played one after the other) and
*parallel* (played at the same time).
A piece of music is either a note, a rest,
or another sequential or parallel combination.
From this description we can derive a sealed trait `Score`
that we can use to represent any piece of music:

~~~ scala
sealed trait Score
case class NoteScore(note: Note, duration: Duration) extends Score
case class RestScore(duration: Duration) extends Score
case class SeqScore(a: Score, b: Score) extends Score
case class ParScore(a: Score, b: Score) extends Score
~~~

With this model a simple C chort would look like this:

~~~ scala
import Note._
ParScore(
  ParScore(
    NoteScore(C4, Duration.Eighth),
    NoteScore(E4, Duration.Eighth)),
  NoteScore(C4, Duration.Eighth))
~~~

Not the shortest of code fragments.
Let's simplify things with a simple DSL.
First we'll add some methods to `Note` to generate `NoteScores`:

~~~ scala
case class Note(value: Int) {
  def w = NoteScore(this, Duration.Whole)
  def h = NoteScore(this, Duration.Half)
  def q = NoteScore(this, Duration.Quarter)
  def e = NoteScore(this, Duration.Eigth)
  def s = NoteScore(this, Duration.Sixteenth)
  def t = NoteScore(this, Duration.ThirtySecond)
}
~~~

Then we'll add some combinator methods to `Score`
to eliminate calls to `ParScore.apply` and `SeqScore.apply`:

~~~ scala
sealed trait Score {
  def +(that: Score) = SeqScore(this, that)
  def |(that: Score) = ParScore(this, that)
}
~~~

With these improvements our code looks a lot clearer:

~~~ scala
import Note._
C4.e | E4.e | G4.e
~~~

We can represent sequences of notes in a similar way.
Here's a C major scale:

~~~ scala
C4.e ~ D4.e ~ E4.e ~ F4.e ~ G4.e ~ A4.e ~ B4.e
~~~

And, of course, sequential and parallel notes compose nicely.
Here's a simple chord progression:

~~~ scala
val Cmaj   = C3.q | E3.q | G3.q
val Fmaj   = C3.q | F3.q | A3.q
val Gmaj   = D3.q | G3.q | B3.q
val chords = Cmaj ~ Fmaj ~ Gmaj ~ Fmaj ~ Cmaj
~~~

## Playback

It's one thing to be able to write music as code.
It's another thing to be able to play it back.

*Compose* plays music back using [ScalaCollider](scalacollider),
[Hanns Holger Rutz'](hanns-rutz) client to [SuperCollider](supercollider).

Our `Scores` can involve arbitrary numbers of simultaneous notes.
However, any audio hardware we care to use will only have a maximum polyphony.
ScalaCollider allows us to create a pool of monophonic synthesizers
(that can only play one note at a time).
We need to convert our `Scores` into a playable representation
that sends specific notes to specific synths at specific times.

Compose's playable representation is a flat sequence of `Command` objects
of the following types:

~~~ scala
sealed trait Command
final case class NoteOn(channel: Int, pitch: Int) extends Command
final case class NoteOff(channel: Int) extends Command
final case class Wait(millis: Long) extends Command
~~~

We create the sequence of `Commands` from a `Score`
using simple structural recursion:

 -  `NoteScore` and `RestScore` are our base cases --
    they compile to short, obvious sequences of commands;

 -  compiling a `SeqScore` involves compiling its children
    and appending the results;

 -  compiling a `ParScore` involves compiling its children
    and *merging* the results (see below).

~~~ scala
def compile(score: Score): Vector[Command] = score match {
  case NoteScore(note, dur) =>
    Vector(
      NoteOn(0, frequency(note)),
      Wait(tempo.millis(dur)),
      NoteOff(0)
    )

  case RestScore(dur) =>
    Vector(Wait(tempo.millis(dur)))

  case SeqScore(a, b) =>
    compile(a) ++ compile(b)

  case ParScore(a, b) =>
    merve(compile(a), compile(b))
}
~~~

Merging two parallel sequences of commands is a little tricky.
First we renumber the channels so there are no conflicts.
Then we iterate through the sequences, merging `Wait` commands
and scheduling `NoteOn` and `NoteOff` commands
immediately after one another.
Finally we renumber the resulting command sequence again
to normalize the channel numbers back:

~~~ scala
def merge(a: Vector[Command], b: Vector[Command]): Vector[Command] = {
  @tailrec def loop(
      a: Vector[Command],
      b: Vector[Command],
      accum: Vector[Command] = Vector.empty): Seq[Command] =
    a match {
      case (ah: NoteOn) +: at => loop(at, b, accum :+ ah)
      case (ah: NoteOff) +: at => loop(at, b, accum :+ ah)
      case (ah: Wait) +: at =>
        b match {
          case (bh: NoteOn) +: bt => loop(a, bt, accum :+ bh)
          case (bh: NoteOff) +: bt => loop(a, bt, accum :+ bh)
          case (bh: Wait) +: bt =>
            if(ah > bh) {
              loop((ah - bh) +: at, bt, accum :+ bh)
            } else {
              loop(at, (bh - ah) +: bt, accum :+ ah)
            }
          case Seq() => accum ++ a
        }
      case Seq() => accum ++ b
    }

  val aRenumbered = renumberChannels(a, 0)
  val bRenumbered = renumberChannels(b, maxChannel(a) + 1)

  val mergedCommands = loop(aRenumbered, bRenumbered)

  renumberChannels(mergedCommands)
}

def renumberChannels(
    cmds: Vector[Command],
    base: Int = 0): Vector[Command] = {
  val origChans: Vector[Int] =
    cmds.collect {
      case NoteOn(channel, _) => channel
      case NoteOff(channel)   => channel
    }.distinct.sorted

  val renumber: Int => Int =
    origChans.zipWithIndex.map {
      case (a, b) => (a, b + base)
    }.toMap

  cmds map {
    case NoteOn(channel, freq) => NoteOn(renumber(channel), freq)
    case NoteOff(channel)      => NoteOff(renumber(channel))
    case Wait(duration)        => Wait(duration)
  }
}

def minChannel(cmds: Vector[Command]): Int =
  cmds.collect {
    case NoteOn(channel, _) => channel
    case NoteOff(channel)   => channel
  }.min

~~~

---

## Summary

So there you have it. *Compose*, the fun functional library for compositional music composition (say that ten times fast). It's

Coming to a Scala studio near you.

<sup>1</sup> Emacs developers likely have a major mode for this already.

<sup>2</sup> [musicXML](http://www.musicxml.com) is an interchange format supported by several major score editors.

[scalacollider]: http://www.sciss.de/scalaCollider/
[hanns-rutz]: http://sciss.de/
[supercollider]: http://audiosynth.com/