---
layout: post
title: "Late Binding and Overloading in Scala"
author: Noel Welsh
---

In a recent training course I was asked if Scala supports static or dynamic polymorphism. These are not terms I had heard before, so I had some homework to do. A bit of research showed this terminology refers to the same thing as early and late binding, which I'm more familiar with. So, here we have a quick discussion of early binding (or static polymorphism) and late binding (or dynamic polymorphism), and how it relates to Scala's polymorphic methods and overloading.

### Types and Tags

For this discussion we'll need to be precise about our terminology surrounding types. We're going to use the term *type* in the way used in type theory. It refers to a constraint on a value known at *compile-time*. In this view types only exist at compile-time.

Programmers sometimes refer to run-time or dynamic types. This is information available at runtime about a value. We're going to use the term *tags* to refer to these. The tag may sometimes contain the same information as a type, but sometimes it will not. For example, in the following code the type is `Option[Int]` but the tag is `Some`.

~~~ scala
val anOption: Option[Int] = Some(1)
~~~ 

### Early and Late Binding

Given class definitions like

~~~ scala
class Foo() {
  def doIt: String =
    "Foo"
}

class Bar() extends Foo() {
  override def doIt: String =
    "Bar"
}
~~~ 

what method is chosen when we write

~~~ scala
val foo: Foo = new Bar()
foo.doIt
~~~ 

There are two possibilities:

- the type of the value (in this case `Foo`) is used to choose the method so `foo.doIt` evaluates to `"Foo"`; or
- the tag of the value (in this case `Bar`) is used to choose the method so `foo.doIt` evaluates to `"Bar"`.

The former choice is early binding (static polymorphism), while the latter is late binding (dynamic polymorphism). Scala, like Java and most other OO languages, uses late binding. The above code will evaluate to `"Bar"`.


### Overloading

We've seen that the tag of the method receiver (the object on which we call the method) is involved in determining which method is used. We might also ask if the method parameters are also involved in making that decision. Take the following code.

~~~ scala
class Foo() {
  def doEet(foo: Foo): String =
    "FooFoo"

def doEet(foo: Bar): String =
    "FooBar"
}

class Bar() extends Foo() {
}
~~~ 

Here we have two overloaded variants of `doEet`. What is the result of the following expressions?

~~~ scala
val aFoo: Foo = new Foo()

val foo: Foo = new Bar()
val bar: Bar = new Bar()

aFoo.doEet(foo)
aFoo.doEet(bar)
~~~ 

The expression `aFoo.doEet(foo)` evaluates to `"FooFoo"`, while `aFoo.doEet(bar)` evaluates to `"FooBar"`. This shows that the type, not the tag, of method parameters is used to choose between overloaded methods.

Therefore we can say that Scala has late binding for the method receiver (the object on which we call the method) but early binding for method parameters (to resolve overloading).


### Multiple Dispatch

It's worth noting that some languages use the tags of all method parameters to choose between implementations. This is known as multiple dispatch. The choice made in Scala, where only a single tag is used, is known as single dispatch. 

Multiple dispatch is very uncommon. It has a few issues:

- there can be multiple methods that are equally specific for a given set of method parameters;
- it's difficult to reconcile with modularity; and
- it's difficult to efficiently implement.

Multiple dispatch is mainly found in the Lisp family of languages. CLOS, the standard object system for Common Lisp, features multiple dispatch, for example.


### Goofiness

It's possible to run into confusing situations using overloading. Take the following code for example. What does `new Foo().doEet(new Bar())` evaluate to?


~~~ scala
class Foo() {
  def doEet(foo: Foo): String =
    "FooFoo"

def doEet(bar: Bar): String =
    "FooBar"
}

class Bar() extends Foo() {
}
~~~ 

The answer is `"FooFoo"`, not `"FooBar"` as we would expect. The difference from the code above that did evaluate to `"FooBar"` is very subtle: the two overloaded variants of `doEet` have different parameter names.

There is no doubt there is some crazy goofiness in Scala, a lot of which come from constraints imposed by the JVM. The [Scala Puzzlers][scala-puzzlers] website describes many other corner cases. 

The good news is you never need to run into this goofiness. In our [training][essential-scala] we break Scala down into a few core patterns that make for simple, comprehendable code, and stay well away from the goof. These are the same patterns we use in our programming; they aren't just toys that don't fit real code. I would never run into the problem above with overloading, for example, because it doesn't fit any pattern I would ever use in Scala.

[scala-puzzlers]: http://scalapuzzlers.com/
[essential-scala]: /training/courses/essential-scala/
