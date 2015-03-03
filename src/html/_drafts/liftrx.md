---
layout: post
title:  "RxLift: Reactive Web Components with LiftWeb and RxScala"
author: Channing Walton
---

### Overview

[LiftWeb](http://liftweb.net) makes building dynamic websites extremely easy whilst hiding away a lot of the plumbing. [RxScala](http://reactivex.io/rxscala/) is a Scala adaptor for [RxJava](https://github.com/ReactiveX/RxJava), "a library for composing asynchronous and event-based programs using observable sequences for the Java VM".

This blog describes how we combined Lift and RxScala for event-based UI components consuming and producing observable sequences.

 <!-- break -->

The original motivation for combining Rx and Lift was simply as an experiment - could we treat UI components as sources and sinks of Observable streams of values.

The idea proved to be quite successful, particularly when the backend system is built with Rx so there is no impedance mismatch. We ended up using these ideas in a large financial institution in London for a greenfield project.

To try all the examples in this blog, clone [RxLift](https://github.com/channingwalton/rxlift), and assuming you have [SBT](http://www.scala-sbt.org) installed, type the following on the command line at the root of the project: sbt ~container:start

Finally, point your browser at [http://127.0.0.1:8080](http://127.0.0.1:8080) to try out the examples.

### The Basic Ideas

There are several fundamental ideas illustrated in the following figure:

<img src="/images/blog/rxlift.jpg">

* SHtml is Lift's library for building UI components which RxElement is built on
* an Observable stream of values, Obs[T], is mapped to Lift's JavaScript abstraction, JsCmd, and pushed via Lift's Comet support to the client which updates elements on the client, using Lift's JavaScript library
* AJAX updates from the client are mapped into an Observable stream of values

The are two fundamental data types:

{% highlight scala %}

case class RxComponent[I, O](consume: Observable[I] ⇒ RxElement[O])

case class RxElement[T](values: Observable[T], jscmd: Observable[JsCmd], ui: NodeSeq, id: String)

{% endhighlight %}

RxComponent wraps a function that accepts an Observable[T] and returns an RxElement[O]. It will become clear why this is necessary later but for now think of it as a function for building an RxElement given an Observable.

_RxElement.values_ is the output stream of values, the _jscmd_ is the stream of Lift JsCmds containing JavaScript to send to the browser to make whatever changes are required in response to the input stream, and _ui_ is the HTML to bind into templates as usual in Lift.

To send the JsCmds emitted by _RxElement.jscmd_ to the browser, each JsCmd needs to be sent to a comet actor that forwards it to the client.

RxLift's [RxCometActor](https://github.com/channingwalton/rxlift/blob/master/core/src/main/scala/com/casualmiracles/rxlift/RxCometActor.scala) wraps up the mechanics of sending JavaScript to the client and managing subscription to the observables where necessary. Here is the code which should help your understanding of what it to follow.

{% highlight scala %}
trait RxCometActor extends CometActor {

  // subscriptions that must be unsubscribed to when the actor dies
  val subscriptions: ListBuffer[Subscription] =
    ListBuffer.empty[Subscription]

  // publish each RxElement's jscmd by sending values from the stream
  // to this actor for sending to the client
  def publish(components: RxElement[_]*): Unit =
  components.foreach(o ⇒
    handleSubscription(o.jscmd.map(partialUpdate(_))))

  // convenient method to subscribe to an Observable and manage the subscription 
  def handleSubscription[T](obs: Observable[T]): Unit =
    subscriptions += obs.subscribe()

  // unsubscribe to all subscriptions
  override def localShutdown() =
    subscriptions.foreach(_.unsubscribe())
}
{% endhighlight %}

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

That's it! The two lines of interest are the construction of _timeLabel_ and the call to _publish_, the rest is vanilla RxScala or Lift. _Components_ is a collection of reusable UI components I've supplied, and publish is a method available via _RxComentActor_.

### An Input Element

The label above doesn't emit anything so here is an example of an input element, whose values are emitted as an Observable[String].

{% highlight scala %}
class InputExample extends RxCometActor {

  // construct an input element with an empty input Observable
  val in: RxElement[String] = Components.text().consume(Observable.empty)

  // in.values is an Observable[String] which you can do whatever you need to with

  def render = bind("in" -> in.ui)
}
{% endhighlight %}

To get values from the input field, subscribe to _in.values_ which is an Observable[String].

### Composite Elements

So far we can build UIs for simple streams of values. How can we build a reusable UI component for an Observable of some richer structure?

The solution we opted for was to use Scalaz [Lens](http://eed3si9n.com/learning-scalaz/Lens.html). The input Observable is mapped to Observables for each field with a set of lenses. But the complication is how to apply values emitted by each field's component to the original data. The set of Observable values need to be combined in some way to effect a change on the original value.

The solution is to map each field's Observable to an Observable[[Endo](https://oss.sonatype.org/service/local/repositories/releases/archive/org/scalaz/scalaz_2.11/7.1.1/scalaz_2.11-7.1.1-javadoc.jar/!/index.html#scalaz.Endo)[T]], where T is the type of the composite datatype. (An Endo wraps a function of T ⇒ T). The set of Observable[Endo[T]] for each field can be merged and applied to the original datatype.

The resulting component's type is RxComponent[T, Endo[T]].

I think this is one of those cases where code speaks louder than explanations.

Here is a model and an RxComponent for the model.

{% highlight scala %}
case class Person(firstName: String, lastName: String)

object PersonComponent {

  def apply(): RxComponent[Person, Endo[Person]] = {
    val fnLens = Lens.lensu[Person, String](
                   (p, fn) ⇒ p.copy(firstName = fn),
                   (_: Person).firstName)
    val lnLens = Lens.lensu[Person, String](
                   (p, ln) ⇒ p.copy(lastName = ln),
                   (_: Person).lastName)

    // focus a text component with the fnLens and
    // prefix the textfield with a label
    val fn: RxComponent[Person, Endo[Person]] =
              focus(text(), fnLens).mapUI(
	            ui ⇒ <span>First Name&nbsp;</span> ++ ui)

    val ln: RxComponent[Person, Endo[Person]] =
              focus(text(), lnLens).mapUI(
	            ui ⇒ <span>Last Name&nbsp;</span> ++ ui)

    fn + ln // + is a method on RxComponent
  }
}
{% endhighlight %}

The interesting code here is the focus method from RxLift's [Components.scala](https://github.com/channingwalton/rxlift/blob/master/core/src/main/scala/com/casualmiracles/rxlift/Components.scala). It applies a Lens[T, F] to an RxComponent[F, F] producing an RxComponent[T, Endo[T]]. This brings us back to why RxComponent is needed. An RxElement is the result of applying an Observable to an RxComponent, so it is not possible to modify its input after construction. By working with RxComponents, Observables can be worked with before being finally applied to UI components.

The last line, fn + ln, combines each field into a RxComponent[Person, Endo[Person]]. It does so by merging the Observable streams of fn and ln, and joining the UI NodeSeqs.

By merging the Observable[Endo[T]] value streams, a change in any field will result in an Endo[T] to be emitted. Multiple updates to a datatype by different users will be safe, since changes are applied on a field by field basis. Hence, one user's update will not overwrite anothers, unless they edit the same field simultaneously of course.

Here is a UI that uses the component.

{% highlight scala %}
class Composites extends RxCometActor {

  import PersonComponent._

  // In practice this will be a filtered stream
  val person = BehaviorSubject[Person](Person("", ""))

  // construct our UI component from the stream
  val pc = PersonComponent().consume(person)

  // for demo purposes we will apply this stream to the original
  // person observable and send it back to the UI
  // In a real system you might get the person from a database,
  // modify it with the Endo and save it.
  val newPerson = person.distinctUntilChanged.combineLatest(pc.values).map {
    case (old, update) ⇒ update(old)
  }.distinctUntilChanged.map(person.onNext(_))

  // manage the subscription to the newPerson stream
  handleSubscription(newPerson)

  def render = pc.ui
}
{% endhighlight %}


### Conclusions

Building reactive UI components based on RxScala and Lift has proven to be fairly straightforward. [RxLift](https://github.com/channingwalton/rxlift) is an example
project illustrating the basic ideas which have been used to build a fairly sophisticated UI in a large financial institution in London.
