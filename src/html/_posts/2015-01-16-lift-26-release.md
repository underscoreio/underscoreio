---
layout: post
title: Highlights of the Lift Web Framework 2.6 Release
author: Richard Dallaway
date: '2015-01-16'
---

Lift 2.6 is out. The [announcement links to the tickets](http://liftweb.net/26) for the details. I [count the changes from 2.5 to 2.6](https://gist.github.com/d6y/942d0780f9a166eea887) as 321 commits from [25 people](https://gist.github.com/d6y/9a9bed8d3eaab641af87).

Here's my personal selection of some of those changes.

<!-- break -->

## Menu.param Enhancements

You can now customize `Menu.param` for situations where a request almost, but doesn't quite, match.

For example, say we're matching on a request that contains an ID parameter, such as _/product/123_. Maybe you're looking up that ID (123) in a database. If the ID isn't in the database, Lift will 404 the request. That's sane, but in practice you might want to do something else, like redirect the user someplace. You can easily do that now with Lift 2.6.

Here's a regular `Menu.param`:

~~~ scala
lazy val product = Menu.param[ProductInfo]("product", "Product Detail Page",
  id => database.get(id),
  info => info.id.toString
) / "product" / *
~~~

We've supplied two functions:

- one from a `String` request parameter ID to an optional `ProductInfo` class (that I've made up for this example); and

- one going the other way from a `ProuctInfo` class into the value to use when generating a URL.

So that would 404 for products that don't exist. To do something else we use the new `MatchWithoutCurrentValue`:

~~~ scala
lazy val product = Menu.param[ProductInfo]("product", "Product Detail Page",
  id   => database.get(id),
  info => info.id.toString
  ) / "product" / * >> MatchWithoutCurrentValue >> FallbackToSearchPage

val FallbackToSearchPage =
  IfValue[ProductInfo](_.isDefined, () => RedirectResponse("/search"))
~~~

The change is on the fourth line. We've flagged that we want to match without a value (`>> MatchWithoutCurrentValue`), and also added a fallback behaviour (`>> FallbackToSearchPage`).

That fallback is saying "If you want to progress with this request as normal, you must have a defined value. If you don't, you're going to get redirected".

That's one very useful addition. I've put [a full example on Github](https://github.com/d6y/MatchWithoutCurrentValueExample).


## HTML5 by Default

The HTML5 parser is now the default, which removes one line of configuration. Yeah, this is a small one, but good to get done.

Historically, Lift parsed templates as XHTML, but we all [love the HTML5 goodness](http://html5shirt.com/) and want to be strict about that. So now, by default, if you have an HTML template containing, say, `<div />`, Lift is going to give that [the HTML5 interpretation](http://stackoverflow.com/questions/3558119/are-self-closing-tags-valid-in-html5). In other words, process it as an opening `<div>`.

And that's what you want if you're thinking in terms of HTML5, and it's now the default in Lift 2.6.


## Markdown Included

Lift now has a markdown parser. Markdown has become an important text format for sites, and Lift can now parse that format and convert it to HTML.  This is available in the _net.liftweb.markdown_ package. It's the Actuarius implementation using Scala parser combinators.

It looks like this:

~~~ scala
scala> import net.liftweb.markdown._

scala> new ActuariusTransformer().apply("""
     | # Hello World
     |
     | In which we:
     |
     | * Have a list
     | * Containing two items
     |
     | _etc_...""")
res0: String =
"<h1>Hello World</h1>
<p>In which we:</p>
<ul>
<li>Have a list</li>
<li>Containing two items</li>
</ul>
<p><em>etc</em>...</p>
"
~~~

The best place to see how to use this is [at the Actuarius wiki](https://github.com/chenkelmann/actuarius/wiki/How-To-Use-Actuarius), where you can also see [how it works](https://github.com/chenkelmann/actuarius/wiki/How-Actuarius-Works-Under-The-Hood).


## MongoDB Improvements

Lift 2.6 includes quite a few upgrades for MongoDB support:

- the new `MongoClient` interface has been adopted, for the [new and better way](http://mongodb.github.io/node-mongodb-native/driver-articles/mongoclient.html) of connecting to Mongo;
- JodaTime is supported via `JodaTimeField`;
- there are lifecycle callbacks you can hook into for `beforeUpdate` and `afterUpdate`;
- you can use `ObjectId` to access the document creation timestamp; and
- there's a `dirty_?` check to test to see if a record has changed since being loaded.

They may all seem small, but collectively they add up to a good chunk of MongoDB enhancements.


## Ajax Form Submissions

You've always been able to submit forms over JavaScript with Lift. But there were hoops you had to jump through to preserve your button styling. I've [written about this before](http://chimera.labs.oreilly.com/books/1234000000030/ch03.html#_see_also_24) if you want more background. This has been improved with 2.6.

A quick example. Lift can bind functions to elements of a form.  Maybe you have a HTML form with a submit button, and when the button is pressed, the form is serialized to the server and a function called `process` is evaluated. The binding looks something like this on the server-side:

~~~ scala
def render = {
  def process(): JsCmd = Alert("Thanks")
  "type=submit" #> ajaxSubmit("Click Me", process)
}
~~~

The problem with this is that `ajaxSubmit` creates an `<input type="submit">` element, blowing away any styling you had on your submit button in your HTML template.

The fix is to replace `ajaxSubmit` with `ajaxOnSubmit`, which can bind to an `<input>` or `<button>`.


## JSON in For Comprehensions

Anyone who has used Lift's [JSON support](https://github.com/lift/lift/tree/master/framework/lift-base/lift-json/) in a for comprehension may have seen:

    `withFilter' method does not yet exist on net.liftweb.json.JsonAST.JValue,
    using `filter' method instead

A very annoying warning, which we won't see again, because `withFilter` has now been implemented. \o/


## Security Paranoia

Lift continues with the security paranoia (a good thing). [X-Frame-Option](https://developer.mozilla.org/en-US/docs/Web/HTTP/X-Frame-Options) support has been added, which aims to prevent [clickjacking](http://en.wikipedia.org/wiki/Clickjacking) of content.

The new header signals to the browser whether it should render content in a frame. It's not an official standard, but has some degree of support across all the browsers.  Lift's default is to set the value as "SAMEORIGIN", which means:

> "A browser receiving content with this header field MUST NOT
      display this content in any frame from a page of different origin
      than the content itself." ---[RFC17034](http://tools.ietf.org/html/rfc7034)


## Conclusions

Those are a few of the changes I think are most notable for me.

The [Lift Cookbook](http://chimera.labs.oreilly.com/books/1234000000030) was written with Lift 2.5 in mind. The getting started guide has already been updated on-line for 2.6, although it was all cosmetic for version numbers. I'll go through the rest of the text, but I doubt anything much will need updating.
