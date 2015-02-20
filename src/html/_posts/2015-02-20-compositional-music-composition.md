---
layout: post
title: Compositional Music Composition
author: Dave Gurnell
date: '2015-02-20'
---

Noel [recently wrote about][studio-scala] [Doodle][doodle],
the compositional drawing library we are featuring
in our new studio-format [Essential Scala][essential-scala].
Today I want to introduce you to another library called *Compose*
([code on Github][compose]).
This new library, which will be featured in future courses,
applies the same functional programming principles to music.

<!-- break -->

Doodle and Compose are both designed in a classicly functional manner.
The user builds a representation of the desired output
using a set of primitive objects and combinators.
The library then compiles/interprets the representation
to produce the final result.
This design, separating composition and interpretation,
offers a number of advantages,
and can be worked into many business logic applications:

 - User code is simple and declarative,
   describing only the expected output
   and ignoring implementation-specific details.

 - The intermediate representation, if defined correctly,
   allows the user to easily change aspects of the output:
   relocating an image to a different part of the screen,
   or playing a song back at a different tempo.

 - We can provide different interpreters for different situations
   without changing any user code.
   For example, Doodle has an interpreter for Swing/Java2D
   and an interpreter for HTML5/Canvas.

 - Finally, it is possible to clone and re-use
   parts of images and songs within other images and songs.
   This is the fundamental nature of a *composable* representation.

## Representing Music as Code

Doodle is based on simple geometric primitives
such as Squares, circles, and triangles.
Its composition operations are spatial functions such as
`beside`, `above`, and `below`.
Let's look at the language Compose uses to represent music
and how it allows us to build complex songs from simple parts.

## Primitives: Notes, Rests, Pitch, and Duration

The primitives in a musical score are *notes* and *rests*.
Notes have a *pitch* and *duration* and rests simply have a *duration*:

<div class="captioned">
  <img src="/images/blog/2015-02-01-compositional-music-composition.jpg">
  <div class="caption">
    <a href="https://www.flickr.com/photos/jonnyentropy/8237873224">
      Photograph by Tris Linnell, CC-BY-NC-SA.
    </a>
  </div>
</div>

Piano keys are a convenient represenation of pitch:
`C4` is middle C, `D4` the next white note,
`Cs4` the C sharp between the two, and so on.

Durations are measured in *beats*.
There are typically four beats a bar but many notes are much shorter than that.
Compose provides representations for whole, half, quarter, eighth, sixteenth,
and thirty-second beats, and combinators to produce
["dotted" variants][dotted-notes].

<div class="captioned">
  <img src="/images/blog/2015-02-01-compositional-music-composition-pitches.jpg">
  <div class="caption">
    <a href="https://www.flickr.com/photos/124497826@N08/14121388525">
      Photograph from the Leeds Piano Competition, CC-BY.
    </a>
  </div>
</div>

The end result is a DSL for producing notes with any cross section of
pitch and duration:

~~~ scala
import Note._

C4.e        // C4,  eighth beat duration
Fs4.h       // F#4, half beat duration
D5.w.dotted // D5,  dotted whole beat duration
~~~

Note that we are omitting another important component of music -- *dynamics*.
Without changes in volume, our musical compositions will sound
artificial and computer generated.
However, we've opted to keep things simple for now
and save this for a future addition to the library.

## Composition

Now we have our primitive building blocks,
let's think about how we can combine them to create musical scores.
We can combine notes in in *sequence* (played one after the other) and
*parallel* (played at the same time).
Compose uses the `+` operator for sequentual composition and
the `|` operator for parallel composition:

~~~ scala
import Note._

// A C major chord:
C4.e | E4.e | G4.e

// A C major scale:
C4.e ~ D4.e ~ E4.e ~ F4.e ~ G4.e ~ A4.e ~ B4.e
~~~

And, of course, sequential and parallel forms compose nicely.
Here's a simple chord progression:

~~~ scala
val Cmaj   = C3.q | E3.q | G3.q
val Fmaj   = C3.q | F3.q | A3.q
val Gmaj   = D3.q | G3.q | B3.q
val chords = Cmaj ~ Fmaj ~ Gmaj ~ Fmaj ~ Cmaj
~~~

Behind the scenes Compose builds up a representation of the
music using `Score` objects. There are `Score` wrappers
for notes, rests, sequences, and parallel combinations:

~~~ scala
sealed trait Score {
  def +(that: Score) = SeqScore(this, that)
  def |(that: Score) = ParScore(this, that)
}
case class NoteScore(note: Note, duration: Duration) extends Score
case class RestScore(duration: Duration) extends Score
case class SeqScore(a: Score, b: Score) extends Score
case class ParScore(a: Score, b: Score) extends Score
~~~

Ignoring dynamics and volume,
we can represent any composition using `Scores`.
Dynamics can easily be added by adding a field on `NoteScore`
and updating the composition DSL accordingly.

## Playback

To play songs back, we have to think of them as
programs to be compiled and interpreted.
You can review the code Compose uses for this on [Github][compose].
The essential idea is to compile the score into a
sequence of `Commands` that can be interpreted directly:

~~~ scala
sealed trait Command
case class NoteOn(channel: Int, freq: Double) extends Command
case class NoteOff(channel: Int) extends Command
case class Wait(millis: Long) extends Command
~~~

The player, which uses the [ScalaCollider][scalacollider] library
to communicate with [SuperCollider][supercollider],
allocates a fixed number of *channels* to play back sounds.
If we have 4 channels it means we can play 4 samples at the same time.
The `NoteOn` and `NoteOff` commands affect a specified channel
and the `Wait` command delays for a specified time period.

`NoteOn` and `NoteOff` commands with too high a `channel`
are ignored during playback, allowing for graceful degradation
if the song we're playing contains
more simultaneous notes than we have channels.
The compiler also has a notion of tempo,
allowing us to play the same score quickly or slowly
depending on user preferences.

## Summary

*Compose* demonstrates how classical
functional programming principles can be applied to music.
We model a problem domain using *primitives* such as notes and rests,
and *combine* them using parallel and sequential operators.
Finally, we *interpret* the resulting score to produce a useful output.

Functional library design allows library users to concentrate on the
components and relationships in their compositions
without concerning themselves with implementation details such
as then number of channels available for playback.
Songs can be combined and transformed to create new songs
with different patterns or in different keys.

You might validly argue that,
while the DSL used in Compose is expressive enough to store music,
it isn't particuarly readable as regular sheet music.
One final feature of a functional library design is the ability
to create new DSLs on top of the existing representations and interpreters.
Here, for example, is the quintissential example of a DSL---a
string interpolator macro for parsing guitar tablature:

~~~ scala
import compose.tab._

val freebird: Score =
  tab"""
  |-------------------------------|----------------------------|
  |-3------------3---3---3-3------|-5--x-----------------------|
  |-4------------3-x-3-x-3-3--x-x-|-5--x-----------------------|
  |-5--x-------x-3-x-3-x-3-3--x-x-|-5--x-----5----5----5----5--|
  |-5--x---0-2-x-1-x-1-x-1-1--x-x-|-3----5h7----7----7----7----|
  |-3--x-3-----x------------------|----------------------------|
  """
~~~

`tab""` expressions are compile-time checked and evaluate to
`Score` expressions written in the DSL discussed above.
See the [unit tests][tab-unit-tests] for a complete worked example
and absolute proof that functional programming in Scala rocks!

[studio-scala]: 2015-01-26-rethinking-online-training.html
[essential-scala]: /training/courses/essential-scala
[doodle]: https://github.com/underscoreio/doodle
[compose]: https://github.com/underscoreio/compose
[scalacollider]: http://www.sciss.de/scalaCollider/
[hanns-rutz]: http://sciss.de/
[supercollider]: http://audiosynth.com/
[tab-unit-tests]: https://github.com/underscoreio/compose/blob/master/src/test/scala/compose/tab/TablatureSyntaxSpec.scala
[dotted-notes]: https://en.wikipedia.org/wiki/Dotted_note