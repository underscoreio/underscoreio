---
layout:     post
title:      "Modelling JavaScript in Scala with Scala.js"
author:     "Richard Dallaway"
---

Surely there's something in JavaScript that [Scala.js][sjs] can't handle?
If there is, I've not found it yet.
Each time I've faced some JavaScript obstacle I've been overjoyed to find an answer in Scala.js.

In this post I'll highlight 3 features from Scala.js 1.x that I've recently used to dig myself out of a hole.
The features are: representing JavaScript global scope values, importing Node modules,
and working with JavaScript's `this`.

The common thread is that these features let you safely model JavaScript concepts in Scala.

<!-- break -->

[sjs]: http://www.scala-js.org/
[presentations]: http://www.scala-js.org/community/presentations.html
[post]: https://underscore.io/blog/posts/2015/06/10/scalajs-scaladays.html
[video]: https://www.youtube.com/watch?v=Ohu2cajjTdw
[global]: https://www.scala-js.org/doc/interoperability/global-scope.html
[import]: https://www.scala-js.org/doc/interoperability/facade-types.html#a-nameimporta-imports-from-other-javascript-modules
[fun]: https://www.scala-js.org/doc/interoperability/types.html#jsthisfunction-and-its-subtypes
[libs]: https://www.scala-js.org/libraries/libs.html
[handler]: https://github.com/alexa/alexa-skills-kit-sdk-for-nodejs/wiki/Developing-Your-First-Skill#creating-the-lambda-handler
[facade]: https://www.scala-js.org/doc/interoperability/facade-types.html
[bundler]: https://scalacenter.github.io/scalajs-bundler/

# Scala.js

Scala.js is a Scala to JavaScript compiler.

In practical terms this means:

- you write regular code, using [cross-compiled Scala libraries][libs] if you like;
- then run `fastOptJs` in sbt to have your program output as JavaScript; and
- run that code in a browser, with Node, or wherever you find a JavaScript environment.

That's the basics. If you'd like a little bit more of an introduction, I've [written and spoken about this before][post] ([video][video]), as have many [others][presentations].

That's only half of the story.
It's true, we can use Scala to write JavaScript,
but I think the best part is how Scala.js interfaces to the rest of the JavaScript ecosystem.
In other words, how you can model JavaScript concepts in Scala.

# An example application

We need an example to help make sense of the three features I want to describe.

I've been working on serverless application that runs under Node.
The plan is: use Scala to write the application, but deploy it to a Node environment.

In the Node environment there are libraries I need.
Specifically, I want to use the Amazon Alexa APIs.
We don't need to go into that too much, except for two things.

First, we'll need to reference existing JavaScript library code from our Scala code.
That means importing a library and working with global JavaScript scope.

The second thing to know is that we're writing a `Request => Response` function.
The request will be an "intent" (such as "TellJoke") and the response will be the text to be spoken (such as a terrible Dad joke).
However, we're going to have to turn that into a `() => Unit`. The side-effect is calling the Node APIs to read values and set the response.
Not nice, but the point here is that Scala.js can represent the JavaScript API we've been handed.

# Feature 1: JSGlobalScope -- representing global JavaScript values to Scala

To get started, we need to access the JavaScript global state.
The Alexa/Lambda platform expects you to [register a handler][handler].
This happens in JavaScript as something like this:

```javascript
// This is JavaScript, using the Alexa v1 API

exports.handler = function (event, context) {
  // Set up our handler, which we'll see later.
};
```

This registration happens when the JavaScript loads and runs.
What's the Scala.js equivalent of that going to be? It'll be a `main` method:

```scala
def main(args: Array[String]): Unit =
  exports.handler = (event, context) => registrationCodeHere()
```

So the first trick is how that `exports.handler` is represented in Scala:

```scala
@js.native
@JSGlobal("exports")
object exports extends js.Object {
  var handler: js.Function2[RequestBody[Request], Context, Unit] = js.native
}
```

What's happening here is that we're declaring, typing, and positioning the `exports.handler`.
Here's what I mean by that...

For Scala, we're defining an object with a variable so we can write `exports.handler = ...`.
The type of that value is a JavaScript function, as that's what the JavaScript environment is expecting.
The type parameters come from a [facade] to the Alexa Node library, which is detail I'm mostly skipping in this post.

The implementation of that `handler` value is provided by the JavaScript environment.
It has, in other words, a `js.native` implementation.

The `exports` object itself is also provided for our program at runtime,
and is annotated as `@js.native`.
The [`@JSGLobal`][global] means it's living outside of the modular world Scala.js creates for our programme,
and won't be created by Scala.js: it had better exist when the program runs.

In other words, we can model the environment we're running in,
reach out and modify it.

# Feature 2: JSImport -- referencing provided node libraries

We can now register a function, so let's take another step and implement the Alexa pattern for responding to an intent:

```javascript
// This is JavaScript, using the Alexa v1 API

// Load the Node module for Alexa SDK:
const Alexa = require('alexa-sdk);

exports.handler = function (event, context) {
  const alexa = Alexa.handler(event, context);
  alexa.registerHandlers(ourCodeHere);
  alexa.execute();
};
```

This is boilerplate for getting `ourCodeHere` called.

The hurdle for our Scala code is how to get access to the `alexa-sdk` from Scala.js.
The way I like to do that is to annotate the Scala facade with an import name.
This is a second feature to help us model JavaScript in a Scala programme.

Here's the relevant part of the facade:

```scala
@js.native
@JSImport("alexa-sdk", JSImport.Namespace)
object Alexa extends js.Object {
  def handler[T <: Request](e: RequestBody[T], c: Context): AlexaObject[T] =
    js.native
}
```

Again, we're modelling a provided (`js.native`) object.
This time we're also marking it as a module that will be [imported][import].
The module is called `alexa-sdk` and we're importing the module itself (`JSImport.Namespace`),
rather than say a specific member of the module.

What that means in practice is that the JavaScript output from `fastOptJs` will end up containing something like this:

```javascript
// This is JavaScript, using the Alexa v1 API
var Alexa = require("alexa-sdk");
```

...effectively loading the library and giving us access to it as `Alexa`.

Now, in my particular case, the node module is provided already, so this is enough.
I know it will be there when my JavaScript is loaded.

However, for packing and checking Node libraries [scalajs-bundler][bundler] looks like the right solution
(at the time of writing not available for Scala.js 1.x).

# Feature 3: ThisFunction -- modelling the type changing under you

At this point we have loaded a library and registered a function. In Scala this is:

```scala
def main(args: Array[String]): Unit = {
  exports.handler = (event, context) => {
    val alexa = Alexa.handler(event, context)
    alexa.registerHandlers( ??? )
    alexa.execute()
   }
}
```

Now we need to figure out what to put in place of the `???` in `alexa.registerHandlers`.

A JavaScript handler might look something like this:

```javascript
// This is JavaScript, using the Alexa v1 API
const handlers = {
  Greet() {
    this.emit(":tell", "Hello Sailor");
  }
}
```

Seems straightforward, but where is that `emit` method coming from?
It's not a parameter (there are none!), it's not on a class, it's not in scope of `handlers`.

What's happening is `Greet` is being placed into a context that has `emit`,
and many other fields, down in the JavaScript [library code](https://github.com/alexa/alexa-skills-kit-sdk-for-nodejs/blob/master/lib/alexa.js#L244-L261).
We don't need to worry about the JavaScript native implementation, but we do need to model this in Scala.

I initially thought that perhaps a self type would solve this.
That is, maybe my Scala version of `Greet` could be mixed in with something that has an `emit` method.
But the problem with that is we are not implementing `emit` in Scala. We just need to model it from JavaScript.

The solution Scala.js provides is neat: we are given the `this` type as a parameter to the Scala function.
It is modelled as [`ThisFunction`][fun].
This is like `Function0`, `Function1` and friends, but with an extra type parameter to represent the changed value for `this`.

In this specific example, the Scala.js model for `Greet` becomes a...

```scala
js.ThisFunction0[Handler[Request], Unit]
```

This is a `() => Unit` method, with an addition parameter.
The additional parameter is `Handler[Request]` which (in the facade) is the model for the JavaScript `this` in this context.
I.e., `Handler[Request]` happens to be the thing with that `emit` method we wanted.

Finally, the Scala implementation of `Greet` might be:

```scala
def greet(handler: Handler[Request]): Unit =
  handler.emit("Hello Sailor")
```

This means we can write a sane looking Scala method: it takes an explicit dependency we need.
Behind the scenes, Scala.js arranges for `this` to be passed even though the JavaScript API
provides no parameters.

# Summary

When interfacing to a JavaScript environment, the question to ask is: how do I model the JavaScript interface in Scala?
Scala.js has a set of tools to help with this.

We've seen three techniques in this post:

- global scope access;
- depending on existing Node libraries; and
- modelling the dynamic `this` value.

The Scala.js [types page](https://www.scala-js.org/doc/interoperability/types.html) describe more useful tricks for JavaScript interop.

