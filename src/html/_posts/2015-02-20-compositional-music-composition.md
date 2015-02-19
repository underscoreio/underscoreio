---
layout: post
title: Compositional Music Composition
author: Dave Gurnell
date: '2015-02-20'
---

Noel [recently wrote about](studio-scala) [Doodle](doodle),
the compositional drawing library we are featuring
in our new studio-format Essential Scala course.
Today I want to introduce you to another library
that we will be introducing in future courses.
Called [Compose](compose), the new library
applies the same functional programming principles
to music composition.

<!-- break -->

Doodle and Compose are both examples of classical functional programming.
The user builds a representation of the desired output using a set of
primitive objects and combinator functions.
The library then compiles/interprets the representation
to produce the final result.

This separation of representation and interpretation
offers a number of advantages:

 - User code is simple and declarative,
   describing only the expected output,
   and doesn't get bogged down implementation-specific details.

 - The representation, if defined correctly,
   allows the user to easily change aspects of the output,
   such as relocating an image to a different part of the screen
   or playing the composition back at a different tempo.

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

![<a href="https://www.flickr.com/photos/jonnyentropy/8237873224">
  Photograph by Tris Linnell, CC-BY-NC-SA.
</a>](/images/blog/2015-02-01-compositional-music-composition.jpg)

Piano keys are a convenient represenation of pitch:
`C4` is middle C, `D4` the next white note, `Cs4` the C sharp between the two,
and so on.

Durations are measured in *beats*.
There are typically four beats a bar but many notes are much shorter than that.
Compose provides representations for whole, half, quarter, eighth, sixteenth,
and thirty-second beats, and combinators to produce
["dotted" variants](https://en.wikipedia.org/wiki/Dotted_note).

![Pitches on a piano keyboard](/images/blog/2015-02-01-compositional-music-composition-pitches.jpg)

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
and save this for a future addition to Compose.

## Composition: Scores

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

## Playback

To play songs back, we have to think of them as
programs to be compiled and interpreted.
You can review the code Compose uses for this on [Github](compose).
The essential idea is to compile the score into a
sequence of `Commands` that can be interpreted directly:

~~~ scala
sealed trait Command
case class NoteOn(channel: Int, freq: Double) extends Command
case class NoteOff(channel: Int) extends Command
case class Wait(millis: Long) extends Command
~~~

The player, which uses the [ScalaCollider](scalacollider) library
to communicate with [SuperCollider](supercollider),
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
We model a problem domain using *primitive* notes and rests
and parallel and sequential *combinator* operations,
and *compile and interpret* the resulting scores
using structural recursion.

This design allows library users to concentrate on the
notes, intervals, and temporal relationships in their songs,
without being concerned with implementation details such
as then number of channels available for playback.
Songs can be trivially composed and manipulated to create new songs
with different patterns or in different keys.
The only limitation is the user's understanding of musical theory
to know which notes sound good together.

You might validly argue that, while the DSL used in Compose is
expressive enough to represent many songs,
it isn't as readable as regular sheet music.
I'll leave you with a little idea I have for a future addition --
the guitar tablature string interpolator macro:

~~~ scala
val freebird = tab"""
|-------------------------------|----------------------------|
|-3------------3---3---3-3------|-5--x-----------------------|
|-4------------3-x-3-x-3-3--x-x-|-5--x-----------------------|
|-5--x-------x-3-x-3-x-3-3--x-x-|-5--x-----5----5----5----5--|
|-5--x---0-2-x-1-x-1-x-1-1--x-x-|-3----5h7----7----7----7----|
|-3--x-3-----x------------------|----------------------------|
"""
~~~

Pull requests would be most welcome :)

[studio-training]: 2015-01-26-rethinking-online-training.html
[doodle]: https://github.com/underscoreio/doodle
[compose]: https://github.com/underscoreio/compose
[scalacollider]: http://www.sciss.de/scalaCollider/
[hanns-rutz]: http://sciss.de/
[supercollider]: http://audiosynth.com/