---
layout:     post
title:      Bridging Scala and the Front-End
author:     Pere Villega
date:       '2018-12-12 20:01:00'
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

# Bridges intermediate language

Bridges intermediate language tries to directly represent a Scala ADT using another ADT. At the core we have two types:

The type `DeclF[A]` represents a named declaration, that is the representation of a type along its name. This named declaration can be used as a top level element, or as a field when defining a Product or Sum for the representation of an ADT.

The type `Type` maps elements found in a Scala ADT. We have a definition for `Prod` (Product) and `Sum`, as well as definitions for basic types in Scala. We also use the special type `Ref` to represent types defined by the user. 

The definitions for both types follow:

```scala
final case class DeclF[+A](name: String, tpe: A)

sealed abstract class Type extends Product with Serializable
final case class Prod(fields: List[Decl])      extends Type
final case class Sum(products: List[ProdDecl]) extends Type
final case class Ref(id: String)               extends Type
final case object Str                          extends Type
// and others...
```

With these definitions we can transform a given case class into a corresponding `Type` structure:

```scala
case class Value(value: String) extends AnyVal

DeclF("Value", Str)

// second example
case class Pair(a: String, b: Int)

DeclF("Pair", Prod(List(
          DeclF("a", Str),
          DeclF("b", Intr)
        )))
```


# DeclF and multiple target languages

Note that `DeclF` (defined in the previous section) is parameterised by `A`. By default `A` is `Type`, as In

```scala
type Decl = DeclF[Type]
```

but this representation allows us to swap the `Type` representation used by our intermediate language, if needed. This is a requirement that has been added as Bridges started targeting several languages with different capabilities.

Currently Bridges is targeting 3 languages: `Elm`, `Typescript` and `Flow`. `Elm` has a Haskell-like syntax that matches perfectly the intermediate language we described in the previous section. But `Flow`, for example, differentiates between `union types`, `intersection types`, and `structs`. This doesn't map in a straightforward way to our ADT `Products` and `Sums`. 

Solving this mismatch between the target languages was creating friction in the intermediate language, thus the solution to add `A` to `DeclF`: if your language may need to cover special cases, you can create your own intermediate language and use it, so your resulting code matches expectations.

# From intermediate to final representation

Once we have our `DeclF` representing the `Scala` code to translate, we need a way to obtain a `String` with the syntax for the target language. This is achieved via the `Renderer[A]` trait and its various implementations. `Renderer` is defined as:

```scala
trait Renderer[A] {
  def render(decl: DeclF[A]): String
}
```

and we implement one instance for each target language. For example, for `Elm` and `Flow` we have:

```scala
class ElmRenderer extends Renderer[Type] { ... }
class FlowRenderer extends Renderer[FlowType] { ... }
```
Note that while `Elm` used the default `Type` describe before, the `FlowRenderer` class uses its own `FlowType` intermediate representation to be able to define `intersection types`.


# Using Bridges with Typescript

With the above, we have all the pieces we need to generate our final representations. To use Bridges in our application, we simply need to import the library using the latest version (currently `0.11.0`):

```scala
libraryDependencies += "com.davegurnell" %% "bridges" % "0.11.0"
```

Let's see it in action with some sample ADTs:

```scala
final case class Color(red: Int, green: Int, blue: Int)

sealed abstract class Shape extends Product with Serializable
final case class Circle(radius: Double, color: Color) extends Shape
final case class Rectangle(width: Double, height: Double, color: Color) extends Shape
```

We'll start by generating the intermediate representation of `Color` for `Typescript`:

```scala
import bridges.typescript.syntax._

val declaration = decl[Color]
// declaration: bridges.typescript.TsDecl = 
//	  DeclF(Color,
//			Struct(List(DeclF(red,Intr), DeclF(green,Intr), DeclF(blue,Intr))))
```

As you can see, Bridges tells us the `Color` is a structure tagged as `Color` that forms a `Struct` with three numeric fields, one per each field in our class. Note that `declaration` is of type `TsDecl` which is defined as `DeclF[TsType]` as `Typescript` requires its own intermediate language.

Now let's request the `Typescript` representation of this declaration:

```scala
import bridges.typescript._

TsTypeRenderer.render(declaration)
// res0: String = export type Color = { red: number, green: number, blue: number };
```

Or we can request the implementation for all our ADTs, as follows:

```scala
import bridges.typescript._
import bridges.typescript.syntax._

TsTypeRenderer.render(List(decl[Color],
  decl[Circle],
  decl[Rectangle],
  decl[Shape]
))
// res1: String =
//		export type Color = { red: number, green: number, blue: number };
//		export type Circle = { radius: number, color: Color };
//		export type Rectangle = { width: number, height: number, color: Color };
//		export type Shape = { type: "Circle", radius: number, color: Color } | { type: "Rectangle", width: number, height: number, color: Color };
```

The output of `render()` is a typical representation of an ADT in `Typescript`: a set of structural types and a tagged union based on a discriminator field called `type`.

## Typescript and guards

Having an intermediate language means that we can do more than just `render` our types in the syntax of the target language. For example, once we are running our `Typescript` code we will need to load `Json` and convert it to one of the types defined above. This is a repetitive task, as we can use Bridges to generate that code for us.

By creating a new trait `TsGuardRenderer` that uses `DeclF[TsType]` as inout we can generate the following:

```scala
TsGuardRenderer.render(decl[Color])
// res0: String =
// export function isColor(v: any): boolean {
//   return typeof v.red === "number" && typeof v.green === "number" && typeof v.blue === "number";
// }
//
// export function asColor(v: any): ?Color {
//   return isColor(v)
//     ? v as Color
//     : throw new Error("Expected Color, received " + JSON.stringify(v, null, 2));
// }
```

The code we generated allows us to verify some `Json` is a valid `Color` by using `isColor` and, if it is, we can obtain a `Color` using `asColor`. 


# Bridging Scala and Elm

Instead of `Typescript` we may want the `Elm` output, which we can obtain by replacing the language type parameter:

```scala
import bridges.core.syntax._
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

Elm has direct language support for ADTs, which means we can use the default `Type` instead of having to create our own intermediate representation.

## Generating JSON encoders and decoders

For projects that use `Elm` we can also generate JSON encoders and decoders (support for `Typescript` and `Flow` codebases is coming). This means we can use these encoders and decoders in our `Elm` code, ensuring we are working with a version that matches the `Json` sent by the back-end.

For this functionality to work, we make a few assumptions about our data model:

* All `Elm` types generated by `Bridges` will belong to the same module;

* Our Elm project *must* include the [NoRedInk/elm-decode-pipeline][11] and [danyx23/elm-uuid][14] dependencies;

* When we encode the ADTs into Json, any `CoProduct` we generate will use a field `type` to discriminate between values. For [Circe][12] users, see [this example][13] on how to achieve this.

These assumptions mean that we can predict the shape of the decoder and generate valid Elm syntax.

Bridges provides two methods to generate Json encoders and decoders:

* `decoder(dec: DeclF[Type])` will generate the decoder for our ADT;

* `encoder(dec: DeclF[Type])` will generate the encoder for our ADT.

Let's see some examples, using the ADT we defined in the previous section. First let's generate a decoder for `Color`:

```scala
import bridges.core.syntax._
import bridges.elm._

Elm.decoder(decl[Color])

// res1: String =
//   decoderColor : Decode.Decoder Color
//   decoderColor = decode Color
//     |> required "red" Decode.int
//     |> required "green" Decode.int
//     |> required "blue" Decode.int
```

And let's build the encoder for the same type:

```scala
import bridges.core.syntax._
import bridges.elm._

Elm.encoder(decl[Color])

// res1: String =
//   encoderColor : Color -> Encode.Value
//   encoderColor obj = Encode.object [
//      ("red", Encode.int obj.red),
//      ("green", Encode.int obj.green),
//      ("blue", Encode.int obj.blue) ]
```

For a more complex ADT like `Shape`, we get a more complex decoder that expects the `type` field as a discriminator:

```scala
import bridges.core.syntax._
import bridges.elm._

Elm.encoder(decl[Shape])

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
import bridges.core.syntax._
import bridges.elm._

Elm.encoder(decl[Shape])

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

The Bridges codebase includes several examples of different ADTs along with expected output for each. Check the tests, specifically `ElmJsonDecoderSpec` and `ElmJsonEncoderSpec`, for more information.

## Creating complete Elm modules

To compile the Elm code we've produced so far, we need we to join the fragments and add the required imports. Bridges' Elm module provides another method to help with this:

* `buildFile[L](module: String, decls: List[Declaration])` returns a pair of `Strings`: a file name and the contents of the file.

`buildFile` uses the other methods discussed above to provide a convenient, batteries-included way of generating Elm code. Let's see an example based on an ADT we have used on this post:

```scala
import bridges.core.syntax._
import bridges.elm._

Elm.buildFile("CustomModule", decl[Color])

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

You can use the filename and content from `buildFile` to create an Elm source file at a relevant location as part of your build pipeline. 

# Gotchas

Here are a few problems and workarounds you may encounter using Bridges:

## Overriding definitions for specific types

Sometimes, a case class in the back-end may include a type that we don't want to derive in the front-end.
For example, we may have a custom data type `Foo` on the back-end that we want to represent with a simple type like `Int` in the UI.

We can modify the way values are translated to the intermediate language using implicits.
For this example, we would add the following to our code generator:

```scala
implicit val fooEncoder: BasicEncoder[Foo] =
  Encoder.pure(Num)
```

This will convert any reference to `Foo` to a numeric value in our generated code.

## Refined types

[Refined][15] is a Scala library for refining types with type-level predicates that constrain the set of values described by some underlying type (for example, the set of positive integers, or the set of strings of a certain length). When using Bridges on Refined values, it is very important that the following import from `refined-shapeless` is in scope, to avoid compilation errors:

```scala
import eu.timepit.refined.shapeless.typeable._
````

For example, given the following refined type `RefinedString` we can generate our declaration as follows:

```scala
import eu.timepit.refined._
import eu.timepit.refined.api.Refined
import eu.timepit.refined.collection.Size
import eu.timepit.refined.numeric.Interval.ClosedOpen
import eu.timepit.refined.shapeless.typeable._

type RefinedString = String Refined Size[ClosedOpen[W.`1`.T, W.`100`.T]]

final case class ClassWithRefinedType(name: RefinedString)

decl[ClassWithRefinedType] 
// res0: bridges.typescript.TsDecl = 
// 		DeclF(ClassWithRefinedType,
			Struct(List(DeclF(name,Str))))
```

Note that the type for `RefinedString` is `Str` when using the intermediate language, we have removed the refinement and preserved the base type.

# Conclusions

We have presented [Bridges][1], a library to generate front-end code for our apps based on our back-end ADTs. We showed how we use this in to generate valid code for `TypeScript` and `Elm`, simplifying development and reducing the effort needed to keep both front-end and back-end in sync.

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