---
layout: post
title:  RxLift, Reactive Web Components with LiftWeb and RxScala
author: Channing Walton
---

### Overview

[LiftWeb](http://liftweb.net) makes building dynamic, comet and ajax websites extremely easy. [RxScala](http://reactivex.io/rxscala/) is a Scala adapter for RxJava, "a library for composing asynchronous and event-based programs using observable sequences for the Java VM". This blog describes how we combined Lift and RxScala for event-based UI components using observable sequences.

 <!-- break -->

(If you would like an introduction to Rx please refer to [ReactiveX](http://reactivex.io), and to [Exploring Lift](http://exploring.liftweb.net/master/index.html) to learn about LiftWeb).

### The Basic Ideas

There are several fundamental ideas in the RxLift model: 

* an Observable stream of values is mapped to JavaScript, which is pushed via Lift's Comet support to the client, to update elements on the client
* AJAX updates from the client are mapped into an Observable stream of values
* Lift's existing mechanism for binding the HTML for these reactive components into templates is still used

The core model:

{% highlight scala %}

case class RxComponent[I, O](consume: Observable[I] ⇒ RxElement[O])

case class RxElement[T](values: Observable[T], jscmd: Observable[JsCmd], ui: NodeSeq, id: String)

{% endhighlight %}

RxComponent wraps a function that accepts an Observable[T] and returns an RxElement[O]. It will become clear why this is necessary later but for now think of it as a function for building an RxElement given an Observable.

RxElement.values is the output stream of values, the jscmd is the stream of Lift JsCmds containing JavaScript to send to the browser to make whatever changes are required in response to the input stream, and the ui is the html to bind into templates as usual in Lift.

To send the JsCmds emitted by RxElement.jscmd to the browser, each JsCmd needs to be sent to a comet actor that forwards it to the client:

RxLift's [RxCometActor](https://github.com/channingwalton/rxlift/blob/master/core/src/main/scala/com/casualmiracles/rxlift/RxCometActor.scala) wraps up the mechanics of sending Javascript to the client and managing subscription to the observables where necessary.

### A Label

The simplest example to start with is a text label since it maps an Observable[String] to a stream of values pushed to the browser.

{% highlight scala %}
class LabelExample extends RxCometActor {

  // generate a string containing the time every second
  val ticker: Observable[String] = 
    Observable.interval(Duration(1, TimeUnit.SECONDS)).map(_ ⇒ new Date().toString)

  // construct a label with the ticker
  val timeLabel: RxElement[String] = Components.label.consume(ticker)

  // send JsCmds emitted by the label to the actor to send to the UI
  publish(timeLabel)

  // initial render uses the label's ui
  def render = bind("time" -> timeLabel.ui)
}
{% endhighlight %}

Thats it! The two lines of interest are the construction of the timeLabel and the call to publish, the rest is vanilla RxScala or Lift.

### An Input Element

The label above doesn't emit anything so here is an example of an input element, whose values are emitted as an Obserable[String]

{% highlight scala %}
class InputExample extends RxCometActor {

  // construct an input element with an empty input Observable
  val in: RxElement[String] = Components.text().consume(Observable.empty)

  // in.values is an Observable[String] which you can do whatever you need to with

  def render = bind("in" -> in.ui)
}
{% endhighlight %}

All thats needed to get values from the input field is to subscribe to in.values, an Observable[String].

### Composite Elements

So far we can build UIs for simple streams of values. How can we build a reusable UI component for an Observable of some richer structure?

The solution we opted for was to use scalaz Lenses. The input Observable is mapped to Observables for each field with a set of lenses. But the complication is what to do with the results emitted by each field's component. The set of Observable values need to be combined in some way to effect a change on the original value.

The solution is to map each field's Observable[T] to an Observable[Endo[T]]. (An Endo wraps a function of T ⇒ T). The set of Observable[Endo[T]] for each field can be merged and applied to the original datatype.

The resulting component's type is RxComponent[T, Endo[T]].

I think this is one of those cases where code speaks louder than explanations.

First, a model and an RxComponent that renders it.

{% highlight scala %}
case class Person(firstName: String, lastName: String)

object PersonComponent {

  def apply(): RxComponent[Person, Endo[Person]] = {
    val fnLens = Lens.lensu[Person, String](
                 (p, fn) ⇒ p.copy(firstName = fn), (_: Person).firstName)
    val lnLens = Lens.lensu[Person, String](
                 (p, ln) ⇒ p.copy(lastName = ln), (_: Person).lastName)

    val fn: RxComponent[Person, Endo[Person]] =
      focus(text(), fnLens).mapUI(ui ⇒ <span>First Name&nbsp;</span> ++ ui)

    val ln: RxComponent[Person, Endo[Person]] =
      focus(text(), lnLens).mapUI(ui ⇒ <span>Last Name&nbsp;</span> ++ ui)

    fn + ln
  }
}
{% endhighlight %}

The interesting code here is the focus method from RxLift's [Components.scala](https://github.com/channingwalton/rxlift/blob/master/core/src/main/scala/com/casualmiracles/rxlift/Components.scala). It applies a lens to an Observable to produce an Observable suitable for the given RxComponent. This in turn brings us back to why RxComponent is needed. An RxElement is the result of applying an Observable to an RxComponent, so its not possible to modify its input after construction. By working with RxComponents, Observables can be worked with before being finally applied to UI components.

Here is a UI that uses the component.

{% highlight scala %}
class Composites extends RxCometActor {

  import PersonComponent._

  // In practice this will be a filtered stream
  val person: Subject[Person] = BehaviorSubject[Person](Person("", ""))

  // construct our UI component from the stream
  val pc = PersonComponent().consume(person)

  // for demo purposes we will apply this stream to the original person
  // observable and send it back to the UI
  // In a real system you might get the person from a database, modify
  // it with the Endo and save it.
  val newPerson = person.distinctUntilChanged.combineLatest(pc.values).map {
    case (old, update) ⇒ update(old)
  }.distinctUntilChanged.map(person.onNext(_))

  // manage the subscription to the newPerson stream
  handleSubscription(newPerson)

  def render = pc.ui
}
{% endhighlight %}


### Conclusions


See [RxLift](https://github.com/channingwalton/rxlift)
