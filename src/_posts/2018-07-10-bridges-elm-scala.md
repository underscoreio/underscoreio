---
layout:     post
title:      Bridging Scala and Elm
author:     Pere Villega
date:       '2018-07-10 22:10:00'
---

In this blog post we will talk about [Bridges][1], a project by [Dave Gurnell][2] which can be used generate front-end code from your Scala ADTs, reducing friction whenever you change your back-end model. We will present the project, how to use it, and list some common traps to avoid when creating your ADTs. We will also showcase some advanced features for projects using Scala and [Elm][8].

<!-- break -->

A typical issue when working on a web-based application (or any software where presentation and back-end are separate codebases) is that changes to the back-end model cause a cascade of manual changes on the upper layers: we need to modify the classes in the front-end, and also the corresponding encoders and decoders. The industry has developed solutions as [Protocol Buffers][5] to tackle it, and one of the features people like about [Scala.js][3] is being able to reuse your back-end model in the front-end.

But we can't always use [Scala.js][3], and sometimes we may just want something simpler than [Protocol Buffers][5]. A tool that helps keeping our front-end in sync with a subset of ADTs, without having to use a 3rd intermediate language to define them.

We propose [Bridges][1] as a solution for this issue. Please note this is not an experimental tool, it is being used in a Scala project for real-world use cases.

# Introducing Bridges

[Bridges][1] is, at its core, a simple library: it uses [Shapeless][6] to translate our ADTs into an intermediate language. Then we can use that language to generate valid representations of those ADTs in a front-end language like [Typescript][7] or [Elm][8].

The advantage of using an intermediate language representation is that we can use Bridges to generate output for multiple front-end languages. Currently there is some support for [Typescript][7], [Flow][10], and [Elm][8], but that can be easily extended for other languages.

The main difference with other tools like [Protocol Buffers][5] is that the intermediate language is automatically derived at compile time. This means that we are writing your code in Scala, and through the power of [Shapeless][6] we obtain the final representation in our target language. We don't have to learn a new intermediate language, it exists but it is transparent to use. As a direct consequence a change to our ADT is automatically propagated, without us having to edit non-scala code.

# Using Bridges

To use Bridges in our application, we simply need to import the library using the latest version (currently `0.8.1``):

```$scala
libraryDependencies += "com.davegurnell" %% "bridges" % "0.8.1"
```

That's all the dependencies we need. Bridges doesn't require `cats` or other libraries, although please note that it will transitively import `Shapeless`.

At its core, Bridges is based in two methods:

* `declaration[A]` will generate the intermediate language representation of `A`.
* `render[L](tpes: List[Declaration])` will generate a representation for language `L` of all declarations provided. Returns a `String`.


Let's see it in action. To generate some front-end code, we need some ADTs in our code, like:

```$scala
final case class Color(red: Int, green: Int, blue: Int)

sealed abstract class Shape extends Product with Serializable
final case class Circle(radius: Double, color: Color) extends Shape
final case class Rectangle(width: Double, height: Double, color: Color) extends Shape
```

Next we can request the `Typescript` implementation of `Color`, with:

```$scala
import bridges._
import bridges.syntax._

render[Typescript](declaration[Color]) 

// res1: String = 
// export type Color = { red: number, green: number, blue: number };
```

Or we can request the implementation of all our ADTs, as follows:

```$scala
import bridges._
import bridges.syntax._

render[Typescript](List(declaration[Color],
  declaration[Circle],
  declaration[Rectangle],
  declaration[Shape]
)) 

// res1: String =
// export type Color = {
//   red: number,
//   green: number,
//   blue: number
// };
//
// export type Circle = {
//   radius: number,
//   color: Color
// };
//
// export type Rectangle = {
//   width: number,
//   height: number,
//   color: Color
// };
//
// export type Shape =
//   ({ type: "Circle" } & Circle) |
//   ({ type: "Rectangle" } & Rectangle);
```

Instead of `Typescript` we may want the `Elm` output, which we can obtain by replacing the target language:

```$scala
import bridges._
import bridges.syntax._

render[Elm](declaration[Color]) 

// res1: String = 
// type alias Color = { red: Int, green: Int, blue: Int }
```

Note we have changed the language parameter from `Typescript` to `Elm`. 

# Working with Json

Now that we can generate code from our ADTs we have reduced the impact of changing our back-end model. But we still need to adapt our decoders to match the new model, which is an error prone task. We can do better.

For projects that use `Elm` (and please note this functionality is currently only supported for `Elm`) we can generate Json encoders and decoders. Note that this makes a few assumptions about our back-end model, as to facilitate the task of generating these methods in valid `Elm`:

* All `Elm` types generated by `Bridges` will belong to the same module.
* Our Elm project *must* include the [NoRedInk/elm-decode-pipeline][11] and [danyx23/elm-uuid][14] dependencies
* When we encode the ADTs into Json, any `CoProduct` we generate will use a field `type` to discriminate between values. For [Circe][12] users, see [this example][13] on how to achieve this.

These assumptions mean that we can predict the shape of the decoder and generate valid Elm syntax. 

Bridges provides two methods to generate Json encoders and decoders:

* `jsonDecoder[L](dec: Declaration)` will generate the decoder for our ADT
* `jsonEncoder[L](dec: Declaration)` will generate the encoder for our ADT

Let's see some examples, using the ADT we defined in the previous section. First let's generate a decoder for `Color`:

```$scala
import bridges._
import bridges.syntax._

jsonDecoder[Elm](declaration[Color])

// res1: String =          
// decoderColor : Decode.Decoder Color
// decoderColor = decode Color |> required "red" Decode.int |> required "green" Decode.int |> required "blue" Decode.int
```

And let's build the encoder for the same type:

```$scala
import bridges._
import bridges.syntax._

jsonEncoder[Elm](declaration[Color])

// res1: String =          
// encoderColor : Color -> Encode.Value
// encoderColor obj = Encode.object [ ("red", Encode.int obj.red), ("green", Encode.int obj.green), ("blue", Encode.int obj.blue) ]
```

For a more complex ADT, like `Shape`, we get a more complex decoder that expects the `type` field to distinguish between the union type members:

```$scala
import bridges._
import bridges.syntax._

jsonDecoder[Elm](declaration[Shape])

// res1: String =          
// decoderShape : Decode.Decoder Shape
// decoderShape = Decode.field "type" Decode.string |> Decode.andThen decoderShapeTpe
//
// decoderShapeTpe : String -> Decode.Decoder Shape
// decoderShapeTpe tpe =
//    case tpe of
//       "Circle" -> decode Circle |> required "radius" Decode.float |> required "color" (Decode.lazy (\\_ -> decoderColor))
//       "Rectangle" -> decode Rectangle |> required "width" Decode.float |> required "height" Decode.float |> required "color" (Decode.lazy (\\_ -> decoderColor))
//       "ShapeGroup" -> decode ShapeGroup |> required "leftShape" (Decode.lazy (\\_ -> decoderShape)) |> required "rightShape" (Decode.lazy (\\_ -> decoderShape))
//       _ -> Decode.fail ("Unexpected type for Shape: " ++ tpe)
```

As well as the matching encoder:

```$scala
import bridges._
import bridges.syntax._

jsonEncoder[Elm](declaration[Shape])

// res1: String =          
// encoderShape : Shape -> Encode.Value
// encoderShape tpe =
//    case tpe of
//       Circle radius color -> Encode.object [ ("radius", Encode.float radius), ("color", encoderColor color), ("type", Encode.string "Circle") ]
//       Rectangle width height color -> Encode.object [ ("width", Encode.float width), ("height", Encode.float height), ("color", encoderColor color), ("type", Encode.string "Rectangle") ]
//       ShapeGroup leftShape rightShape -> Encode.object [ ("leftShape", encoderShape leftShape), ("rightShape", encoderShape rightShape), ("type", Encode.string "ShapeGroup") ]
```

[Bridges][1] codebase includes several examples, along expected output, for multiple ADT constructs. Check the tests, specifically `JsonDecoderSpec` and `JsonEncoderSpec`.

# Creating a working file

Up to now we have built fragments in `Elm` based on our `Scala` types. But, by themselves, they wouldn't compile. We need a way to join them, including the required imports. To that end, we provide (yet another) construct in Bridges:

* `buildFile[L](module: String, dec: Declaration)` will return a pair of `String`. The first element returned is a file name. The second, the contents for that file. Currently only supports `Elm`.

The reason we return both the filename and the contents as `String` is to give flexibility on how to generate and store those values in each project. Each build step or tool can manage this as it fits the project.

Note that `buildFile` is, most likely, the only call one will run on a given project when trying to generate `Elm` code. Behind the scenes it calls the methods explained above and aggregates the output, ensuring we get a valid file that doesn't raise compiler errors.

Let's see an example, based on an ADT we have used on this post:

```$scala
import bridges._
import bridges.syntax._

buildFile[Elm]("CustomModule", declaration[Color])

// res1: (String, String)
// res1._1: String = Color.elm
//
// res1._2: String = 
//
// module CustomModule.Color exposing (..)
//
// import Json.Decode as Decode
// import Json.Decode.Pipeline exposing (..)
// import Json.Encode as Encode
//
// type alias Color = { red: Int, green: Int, blue: Int }
//
// decoderColor : Decode.Decoder Color
// decoderColor = decode Color |> required "red" Decode.int |> required "green" Decode.int |> required "blue" Decode.int
//
// encoderColor : Color -> Encode.Value
// encoderColor obj = Encode.object [ ("red", Encode.int obj.red), ("green", Encode.int obj.green), ("blue", Encode.int obj.blue) ]
```

As we can see, we have generated a working file including imports, type, decoders, and encoder. All the elements are exposed so other modules can use them as required.

Note that `buildFile` will return a single file even if you provide multiple ADT as input. This allows us to keep related ADT together in a single file as well as to avoid  circular dependencies, which `Elm` compiler complains about *loudly*. 


# How to integrate with a project

Once we have the file name and contents, we only need to store it at the proper location. This can vary depending on project and build tools used. We currently use a small App to generate the code we need, similar to:

```$scala
object GenerateElmCodeFromADTs extends App {
  def save(fileName: String, content: String): PrintWriter = new PrintWriter(fileName) { write(content); close(); }

  val module = "Generated"

  // generate Elm types for the following ADTs
  val map = Map(
    buildFile[Elm](module, declaration[Color]),
    buildFile[Elm](module, declaration[Shape])
  )

  // Write files to disk
  map.foreach {
    case (fileName, content) ⇒
      save(fileName, content)
  }
}
```

and we make sure to run this before any `Elm` build in our local and `ci` environments, to verify the code matches expectations.


# Known traps using Bridges

When using a project like Bridges in a real environment, certain special situations are detected. We list a few we found, along with known solutions.

## Overrides for intermediate languages

Sometimes our case classes may include a type we don't want derived. For example, a case class may have a value of type `Foo` for backend use, but when we encode that class we don't return the full `Foo`, instead we encode it to some other type, like an `Int`.

We can modify the way values are translated to Bridges intermediate language via implicits. This help us solve this or similar situations in our codebase. For this example, we would add the following to our code generator:

```$scala
implicit val fooEncoder: BasicEncoder[Foo] = Encoder.pure(Num)
```

This will convert any reference to `Foo` to a numeric value in our generated code.

## Uuid

`Uuid` is a type we use a lot in our project, to uniquely identify elements, and it is a type available in the JVM without any special library. `Elm` provides support for `Uuid` via the [danyx23/elm-uuid][14] module. 

In Bridges intermediate language we treat `Uuid` as a special case: when deriving the structure of an ADT a value of type `Uuid` will preserve the type. Please note this is true only for `Elm`.

We can override this behaviour via an implicit, as explained before. For example the following will assume any `Uuid` is in fact `String` when in the front-end:

```$scala
implicit val uuidEncoder: BasicEncoder[java.util.UUID] = Encoder.pure(Str)
```

If we do not override then our `Elm` types, encoders, and decoders will use `Uuid`. The `Uuid` import will be automatically added to our generated files, if needed.
 
## Recursive types

Scala allows us to create self-referencing types like:

```$scala
final case class Bar(name: String, children: List[Bar])
```

This will compile and work. But, unfortunately, this is not a good construct for Shapeless derivation,and  you will get a stack overflow as something like this happens:

* deriving type `Bar`
* first element is `name`, of type `String`. I know `String`.
* second element is `children`, `List` of `Bar`. I know `List`. I don't know (yet) `Bar`
* deriving type `Bar`
* ...  
  
If you try to run Bridges on similar structures, it won't work. A possible solution is to break them onto a 'fake' ADT:

```$scala
sealed trait Bar
final case class BarOne(name: String, children: List[Bar]) extends Bar
```

Bridges will generate a valid Union type from the code above.
  
## Lazy decoders

When we look at code generated by Bridges we notice any call to a decoder for an Elm `Record` (that is, not a basic type) is built as a `lazy` decoder. The reason is that for certain constructs in which ADTs refer to each other, or when the amount of data to decode exceeds a particular size, Elm can fail.

By building all the decoders as `lazy` we can sidestep this issue.

## Refined types
 
[Refined][15] is a Scala library for refining types with type-level predicates which constrain the set of values described by the refined type. When using Bridges on Refined values, we need to provide some implicits for the process to work. Otherwise we may find values missing from our front-end code.

For example, assuming the following refinement:

```$scala
type ShortStringRefinementType = Size[ClosedOpen[W.`1`.T, W.`100`.T]]
type ShortString = String Refined ShortStringRefinementType

final case class ClassWithRefinedType(name: ShortString)
```

We need to provide the following implicits:

```$scala
import eu.timepit.refined._

implicit val refinedTypeEncoder: BasicEncoder[ShortString] = Encoder.pure(Str)

implicit val refinedTypeTypeable: Typeable[ShortString] =
  new Typeable[ShortString] {
      def cast(t: Any): Option[ShortString] = {
         if (t != null && t.isInstanceOf[String])
           refineV[ShortStringRefinementType](t.asInstanceOf[String]).toOption
         else None
      }
      def describe: String = "ShortString"
  }
```

to convert our `ShortString` to `String`.

# Conclusions

We have presented [Bridges][1], a library to generate front-end code for our apps based on our back-end ADTs. We showed how we use this in to generate valid code for `Elm`, simplifying development and reducing the effort needed to keep both front-end and back-end in sync.

# Acknowledgements

Thanks to [Dave Gurnell][2] for creating [Bridges][1], which we could extend for our own use case. Thanks to [Dave Gurnell][2] and [Miles Sabin][4] for their help solving Shapeless-related queries. And thanks to Underscore for allowing me to publish this here :)

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
