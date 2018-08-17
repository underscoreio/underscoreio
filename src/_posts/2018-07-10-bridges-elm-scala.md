---
layout:     post
title:      Bridging Scala and Elm
author:     Pere Villega
date:       '2018-07-10 22:10:00'
---

In this blog post we will talk about [Bridges][1], a simple library that generates front-end code from your Scala ADTs and reduces the friction of changing your data model. We will present the project, show how to use it, and list some common traps to avoid when creating your ADTs. We will also showcase some advanced features for projects using Scala and [Elm][8].

<!-- break -->

When developing a web-based application (or any application with separate back- and front-end codebases), changes to the back-end model often cause a cascade of manual changes on the forward layers. We need to modify the corresponding data types in the front-end, and also utilities such as encoders and decoders for JSON and URL parameters. The industry has developed solutions as [Protocol Buffers][5] to tackle this problem, and one of the main features people like about [Scala.js][3] is being able to reuse your back-end model in the front-end.

But we can't always use [Scala.js][3], and sometimes we may just want something simpler than [Protocol Buffers][5]. Ideally we want a lightweight tool that keeps our front-end in sync with our back-end data model, without having to use a 3rd intermediate language to define them.

We propose [Bridges][1] as a solution for this issue. Bridges is in the early stages of development, but is already being used in production at Underscore in codebases front-ends written in [Elm][8] and [Flow][10].

# Introducing Bridges

[Bridges][1] is, at its core, a simple library: it uses [shapeless][6] to translate our ADTs into an intermediate language. Then we can use that language to generate valid representations of those ADTs in the front-end.

The advantage of using an intermediate representation is that Bridges can generate output for multiple front-end languages. Currently there is support for [Typescript][7], [Flow][10], and [Elm][8], but that can be easily extended for other languages.

The main difference with other tools like [Protocol Buffers][5] is that the intermediate model is automatically derived at compile time. We are writing code in Scala and obtaining the front-end representation automatically, so any change to our Scala ADT is automatically picked up by the type-checker for our front-end codebase.

# Using Bridges

To use Bridges in our application, we simply need to import the library using the latest version (currently `0.9.0`):

```scala
libraryDependencies += "com.davegurnell" %% "bridges" % "0.9.0"
```

At its core, Bridges is based in two methods:

* `declaration[A]` generates an intermediate language representation of one of our data types `A`;

* `render[L](declarations: List[Declaration])` generates a `String` of code in some front-end language `L` for all `declarations` provided.

Let's see it in action with some sample ADTs:

```scala
final case class Color(red: Int, green: Int, blue: Int)

sealed abstract class Shape extends Product with Serializable
final case class Circle(radius: Double, color: Color) extends Shape
final case class Rectangle(width: Double, height: Double, color: Color) extends Shape
```

We'll start by generating the intermediate representation of `Color`:

```scala
import bridges.syntax._

val decl = declaration[Color]
// decl: bridges.core.Declaration =
//   Declaration(
//     Color,
//     Struct(List((red,Num), (green,Num), (blue,Num))))

```

As you can see, Bridges tells us the `Color` is a structure with three numeric fields. Now let's request the `Typescript` representation of this declaration:

```scala
import bridges.typescript._

Typescript.render(decl)
// res0: String = export type Color = { red: number, green: number, blue: number };
```

Or we can request the implementation for all our ADTs, as follows:

```scala
import bridges.syntax._
import bridges.typescript._

Typescript.render(List(declaration[Color],
  declaration[Circle],
  declaration[Rectangle],
  declaration[Shape]
))
// res1: String =
//   export type Color = {
//     red: number,
//     green: number,
//     blue: number
//   };
//
//   export type Circle = {
//     radius: number,
//     color: Color
//   };
//
//   export type Rectangle = {
//     width: number,
//     height: number,
//     color: Color
//   };
//
//   export type Shape = (
//     ({ type: "Circle" } & Circle) |
//     ({ type: "Rectangle" } & Rectangle)
//   );

```

The output of `render()` is a typical representation of an ADT in Typescript: a set of structural types and a tagged union based on a discriminator field called `type`.

# Bridging Scala and Elm

Instead of `Typescript` we may want the `Elm` output, which we can obtain by replacing the language type parameter:

```scala
import bridges.elm._

Elm.render(List(declaration[Color],
  declaration[Circle],
  declaration[Rectangle],
  declaration[Shape]
))

// res2: String =
//   type alias Color = { red: Int, green: Int, blue: Int }
//
//   type alias Circle = { radius: Float, color: Color }
//
//   type alias Rectangle = { width: Float, height: Float, color: Color }
//
//   type Shape = Circle Float Color
//     | Rectangle Float Float Color

```

Elm has direct language support for ADTs, which is represented in the definition of `Shape`.

## Generating JSON encoders and decoders

Now that we can generate code from our ADTs we have reduced the impact of changing our back-end model. But we still need to adapt our decoders to match the new model, which is an error prone task. We can do better.

For projects that use `Elm` we can also generate JSON encoders and decoders (support for Typescript and Flow codes is coming). This makes a few assumptions about our data model:

* All `Elm` types generated by `Bridges` will belong to the same module;

* Our Elm project *must* include the [NoRedInk/elm-decode-pipeline][11] and [danyx23/elm-uuid][14] dependencies;

* When we encode the ADTs into Json, any `CoProduct` we generate will use a field `type` to discriminate between values. For [Circe][12] users, see [this example][13] on how to achieve this.

These assumptions mean that we can predict the shape of the decoder and generate valid Elm syntax.

Bridges provides two methods to generate Json encoders and decoders:

* `jsonDecoder[L](dec: Declaration)` will generate the decoder for our ADT;

* `jsonEncoder[L](dec: Declaration)` will generate the encoder for our ADT.

Let's see some examples, using the ADT we defined in the previous section. First let's generate a decoder for `Color`:

```scala
import bridges.syntax._
import bridges.elm._

Elm.jsonDecoder(declaration[Color])

// res1: String =
//   decoderColor : Decode.Decoder Color
//   decoderColor = decode Color
//     |> required "red" Decode.int
//     |> required "green" Decode.int
//     |> required "blue" Decode.int
```

And let's build the encoder for the same type:

```scala
Elm.jsonEncoder(declaration[Color])

// res1: String =
//   encoderColor : Color -> Encode.Value
//   encoderColor obj = Encode.object [
//      ("red", Encode.int obj.red),
//      ("green", Encode.int obj.green),
//      ("blue", Encode.int obj.blue) ]
```

For a more complex ADT like `Shape`, we get a more complex decoder that expects the `type` field as a discriminator:

```scala
Elm.jsonDecoder(declaration[Shape])

// res1: String =
//   decoderShape : Decode.Decoder Shape
//   decoderShape = Decode.field "type" Decode.string
//      |> Decode.andThen decoderShapeTpe
//
//   decoderShapeTpe : String -> Decode.Decoder Shape
//   decoderShapeTpe tpe =
//      case tpe of
//         "Circle" -> decode Circle
//            |> required "radius" Decode.float
//            |> required "color" (Decode.lazy (\\_ -> decoderColor))
//         "Rectangle" -> decode Rectangle
//            |> required "width" Decode.float
//            |> required "height" Decode.float
//            |> required "color" (Decode.lazy (\\_ -> decoderColor))
//         "ShapeGroup" -> decode ShapeGroup
//            |> required "leftShape" (Decode.lazy (\\_ -> decoderShape))
//            |> required "rightShape" (Decode.lazy (\\_ -> decoderShape))
//         _ -> Decode.fail ("Unexpected type for Shape: " ++ tpe)
```

As well as the matching encoder:

```scala
Elm.jsonEncoder(declaration[Shape])

// res1: String =
// encoderShape : Shape -> Encode.Value
// encoderShape tpe =
//    case tpe of
//       Circle radius color -> Encode.object [
//          ("radius", Encode.float radius),
//          ("color", encoderColor color),
//          ("type", Encode.string "Circle") ]
//       Rectangle width height color -> Encode.object [
//          ("width", Encode.float width),
//          ("height", Encode.float height),
//          ("color", encoderColor color),
//          ("type", Encode.string "Rectangle") ]
//       ShapeGroup leftShape rightShape -> Encode.object [
//          ("leftShape", encoderShape leftShape),
//          ("rightShape", encoderShape rightShape),
//          ("type", Encode.string "ShapeGroup") ]
```

The Bridges codebase includes several examples of different ADTs along with expected output for each. Check the tests, specifically `JsonDecoderSpec` and `JsonEncoderSpec`, for more information.

## Creating complete Elm modules

To compile the Elm code we've produced so far, we need we to join the fragments and add the required imports. Bridges' Elm module provides another method to help with this:

* `buildFile[L](module: String, decls: List[Declaration])` returns a pair of `Strings`: a file name and the contents of the file.

`buildFile` uses the other methods discussed above to provide a convient, batteries-included way of generating Elm code. Let's see an example based on an ADT we have used on this post:

```scala
import bridges._
import bridges.syntax._

Elm.buildFile("CustomModule", List(declaration[Color]))

// res1: (String, String)
// res1._1: String =
//   Color.elm
//
// res1._2: String =
//   module CustomModule.Color exposing (..)
//
//   import Json.Decode as Decode
//   import Json.Decode.Pipeline exposing (..)
//   import Json.Encode as Encode
//
//   type alias Color = { red: Int, green: Int, blue: Int }
//
//   decoderColor : Decode.Decoder Color
//   decoderColor = decode Color
//      |> required "red" Decode.int
//      |> required "green" Decode.int
//      |> required "blue" Decode.int
//
//   encoderColor : Color -> Encode.Value
//   encoderColor obj = Encode.object [
//      ("red", Encode.int obj.red),
//      ("green", Encode.int obj.green),
//      ("blue", Encode.int obj.blue) ]
```

## Integrating with SBT

You can use the filename and content from `buildFile` to create an Elm source file at a relevant location. The easiest way to do this is to add a separate project to your SBT build definition:

```scala
// Main application code:
lazy val app = project.in(file("app"))

// Bridges-based code generation:
lazy val generate = project.in(file("generate"))
  .dependsOn(app)
  .settings(
    libraryDependencies ++= "com.davegurnell" %% "bridges" % "0.9.0",
    publish := {},
    publishLocal := {},
  )
```

The application code for the `generate` project can be quite simple:

```scala
object GenerateElmCode extends App {
  val module = "Generated"

  // generate Elm types for the following ADTs
  val map = Map(
    Elm.buildFile(module, declaration[Color]),
    Elm.buildFile(module, declaration[Shape])
  )

  // Write files to disk
  map.foreach {
    case (fileName, content) ⇒
      new PrintWriter(fileName) {
        write(content)
        close()
      }
  }
}
```

We make sure to run this before any `Elm` build in our local and `ci` environments, to verify the code matches expectations.

# Gotchas

Here are a few problems and workarounds you may encounter using Bridges:

## Overriding definitions for specific types

Sometimes, a case class in the back-end may include a type that we don't want to derive in the front-end.
For example, we may have a custom data type `Foo` on the back-end
that we want to represent with a simple type like `Int` in the UI.

We can modify the way values are translated to the intermediate language using implicits.
For this example, we would add the following to our code generator:

```scala
implicit val fooEncoder: BasicEncoder[Foo] =
  Encoder.pure(Num)
```

This will convert any reference to `Foo` to a numeric value in our generated code.

## Recursive types

Bridges is not currently able to handle self-recursive data types:

```scala
final case class Bar(name: String, children: List[Bar])
```

We're working on this support. In the meantime if you try to generate declarations for similar structures,
it will fail to compile (with a pretty spectacular error message).
One possible solution is to break the offending data types into mutually recursive parts:

```scala
sealed trait Bar
final case class BarOne(name: String, children: List[Bar]) extends Bar
```

Another is to create the declarations by hand using our handy DSL:

```
import bridges.core._
import bridges.core.Type._
import bridges.syntax._

"Bar" := Struct("name" -> Str, "children" -> Array(Ref("Bar")))

// res0: bridges.core.Declaration =
//   Declaration(
//     Bar,
//     Struct(List(
//       (name, Str),
//       (children, Array(Ref(Bar))))))
```

## Refined types

[Refined][15] is a Scala library for refining types with type-level predicates that constrain the set of values described by some underlying type (for example, the set of positive integers, or the set of strings of a certain length). When using Bridges on Refined values, we need to provide some additional implicits:

```scala
type ShortStringRefinementType = Size[ClosedOpen[W.`1`.T, W.`100`.T]]

type ShortString = String Refined ShortStringRefinementType

final case class ClassWithRefinedType(name: ShortString)
```

In this example we need to provide the following implicits to generate a declaration for `ShortString`:

```scala
import eu.timepit.refined._

implicit val refinedTypeEncoder: BasicEncoder[ShortString] =
  Encoder.pure(Str)

implicit val refinedTypeTypeable: Typeable[ShortString] =
  new Typeable[ShortString] {
      def cast(t: Any): Option[ShortString] = {
         if (t != null && t.isInstanceOf[String])
           refineV[ShortStringRefinementType](t.asInstanceOf[String]).toOption
         else None
      }

      def describe: String =
        "ShortString"
  }
```

# Conclusions

We have presented [Bridges][1], a library to generate front-end code for our apps based on our back-end ADTs. We showed how we use this in to generate valid code for `Elm`, simplifying development and reducing the effort needed to keep both front-end and back-end in sync.

# Acknowledgements

Bridges is a collaboration between [Dave Gurnell][2] and myself inspired by work by [Stephen Kennedy][16]. Thanks to [Miles Sabin][4] for his help solving shapeless-related queries.

[1]: https://github.com/davegurnell/bridges
[2]: https://twitter.com/davegurnell
[3]: http://www.scala-js.org
[4]: https://twitter.com/milessabin
[5]: https://developers.google.com/protocol-buffers/
[6]: https://github.com/milessabin/shapeless
[7]: http://www.typescriptlang.org
[8]: http://elm-lang.org
[10]: https://flow.org
[11]: https://github.com/NoRedInk/elm-decode-pipeline
[12]: https://circe.github.io/circe/
[13]: https://github.com/circe/circe/pull/429
[14]: https://github.com/danyx23/elm-uuid
[15]: https://github.com/fthomas/refined
[16]: https://github.com/skennedy