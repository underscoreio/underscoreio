---
layout:     post
title:      A Small Example of Phantom Types
author:     Channing Walton
date:       '2012-06-16 21:43:00'
sourceSite: Casual Miracles
sourceUrl:  http://www.casualmiracles.com/2012/06/16/a-small-example-of-phantom-types-with-covariance-thrown-in/
---

<p>Here is an example of so-called phantom types and covariance in Scala to improve type safety and correctness. The example is a simplified version from a real project.</p>

<p>I present the example as source code so you can copy into an editor and play with it. References for further reading are given at the bottom.</p>

{% highlight scala %}
object Phantoms {

  /* Here is a Button, some implementations and an ActionPanel
   * that uses two Buttons. */
  trait Button

  case object Accept extends Button
  case object Reject extends Button
  case object Disabled extends Button

  /* Here is a panel containing an accept and reject button.
   * The types of accept and reject are simply Button because
   * we want to construct the ActionPanel with a DisabledButton
   * too. */
  class ActionPanel(accept: Button, reject: Button)

  /* The problem is that nothing is enforcing the order of the
   * arguments, it would be easy to get them the wrong way around.
   *
   * We can fix this with so-called phantom types, types used at
   * compile-time to assist in correctness but are not required at
   * runtime.
   *
   * Some phantoms... */
  trait Acceptor
  trait Rejector

  // Now a new Button parameterised by T but makes no use of T
  trait Button2[T]

  // New buttons that use the phantom types.
  case object Accept2 extends Button2[Acceptor]
  case object Reject2 extends Button2[Rejector]

  /* and now an ActionPanel that requires Buttons
   * using types to ensure the correct ones are
   * supplied */
  class ActionPanel2(accept: Button2[Acceptor],
                     reject: Button2[Rejector])

  /* Getting the order wrong results in compilation errors.
   * This will not compile:
   *
   * class ActionPanel2(accept: Button2[Rejector],
   *                    reject: Button2[Acceptor])
   */

  /* But what about the DisabledButton? As things stand,
   * subclasses of each button type would be needed,
   * which is duplication.
   *
   * Introducing the Covariant Phantom */
  trait Button3[+T]

  // and the usual subclasses
  case object Reject3 extends Button3[Rejector]
  case object Accept3 extends Button3[Acceptor]

  // and panel
  case class ActionPanel3(accept: Button3[Acceptor],
                          reject: Button3[Rejector])

  // And now the DisabledButton
  case object Disabled3 extends Button3[Nothing]

  // and in use
  ActionPanel3(Disabled3, Reject3)

  /* What?! How did that work?
   *
   * The Nothing type extends everything, its the
   * bottom type. Since Button3 is covariant,
   * Button3[Nothing] is a subclass of all Button3's
   * and can be used in their place. */
}
{% endhighlight %}

<p>In summary, using a covariant phantom type has enabled the ActionPanel to enforce the types of its arguments more strongly and supporting a Disabled (default) implementation.</p>

<p>This was exactly what I needed in my real project, I hope its useful to you.</p>

<h3>Further Reading</h3>

<ol>
<li>James Iry's <a href="http://james-iry.blogspot.co.uk/2010/10/phantom-types-in-haskell-and-scala.html">Phantom Types In Haskell and Scala</a></li>
<li>Phantom Types at the <a href="http://engineering.foursquare.com/2011/01/31/going-rogue-part-2-phantom-types/">Foursquare Engineering Blog</a></li>
<li>The <a href="http://www.scala-lang.org/api/current/scala/Nothing.html">Nothing</a> type.</li>
</ol>