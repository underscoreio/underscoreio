---
layout: post
title:  RxLift, Reactive Web Components with LiftWeb and RxScala
author: Channing Walton
---

### Overview

[LiftWeb](http://liftweb.net) makes building dynamic, comet and ajax websites extremely easy. [RxScala](http://reactivex.io/rxscala/) is a Scala adapter for RxJava, "a library for composing asynchronous and event-based programs using observable sequences for the Java VM". This blog describes how we combined Lift and RxScala for event-based UI components using observable sequences.

(If you would like an introduction to Rx please refer to [ReactiveX](http://reactivex.io), and to [Exploring Lift](http://exploring.liftweb.net/master/index.html) to learn about LiftWeb).

### The Basic Ideas

There are two fundamental sides to the RxLift model: mapping an Observable stream of values to JavaScript pushed via Lift's Comet support to the client to update elements on the client; and a stream of values from AJAX updates from the client in the form of an Observable.

We will use Lift's existing mechanism for binding the HTML for these reactive components into templates which is well understood and very simple.

The above leads to this model:
{% highlight scala %}
case class RxComponent[I, O](consume: Observable[I] ⇒ RxElement[O])

case class RxElement[T](values: Observable[T], jscmd: Observable[JsCmd], ui: NodeSeq, id: String)
{% endhighlight %}

The RxComponent wraps a function that accepts an Observable[T] and returns an RxElement[O]. It will become clear why this is necessary later but for now think of it as a factory for building an RxElement given an Observable.

The RxElement.values is the output stream of values, the jscmd is the stream of JsCmds to send to the browser to make whatever changes are required in response to the input stream, and the ui is the html to bind into templates as usual in Lift.

The JsCmds emitted by RxElement.jscmd needs to be sent to the browser. Lift's CometActor will do this for us, all thats needed is for the JsCmds emitted by the Observable[JsCmd] to be sent to the actor that forwards it to the client:

{% highlight scala %}
  // in a CometActor
  
  element.jscmd.map(cmd => this ! cmd)
  
  def lowPriority : PartialFunction[Any, Unit] = {
    case cmd: JsCmd ⇒ partialUpdate(cmd)
  }
{% endhighlight %}

### A Label

The simplest example to start with is a text label since it maps an Observable[String] to a stream of values pushed to the browser.

The label for an Observable[String] can be built rather simply:

{% highlight scala %}
val id = UUID.randomUUID().toString

val js: Observable[JsCmd] = in.map(v ⇒ JsCmds.SetHtml(id, Text(v)))

RxElement(Observable.empty, js, <span id={id}></span>, id)
{% endhighlight %}

The UI is simply a span with an id. The interesting part is the Observable[JsCmd] which maps the input stream of Strings into a JsCmd that sets the content of the span to the stream value. Finally, the RxElement does not emit any values hence its value is an Observable.empty.

Wrapping the above up as an RxComponent gives:
{% highlight scala %}
def label: RxComponent[String, String] = RxComponent { (in: Observable[String]) ⇒
  val id = UUID.randomUUID().toString
  val js: Observable[JsCmd] = in.map(v ⇒ JsCmds.SetHtml(id, Text(v)))

  RxElement(Observable.empty, js, <span id={id}></span>, id)
}
{% endhighlight %}

### An Input Element

Driven by Observable[String], outputs Observable[String] and Observable[JsCmd]


### Composite Elements

Lenses and Endos

### Conclusions


See [RxLift](https://github.com/channingwalton/rxlift)