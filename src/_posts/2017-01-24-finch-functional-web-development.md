---
layout: post
title: "Finch - Functional Web Development"
author: Pere Villega
---

A considerable number of Scala developers are attracted by the promises of type safety and functional programming in Scala, as can be seen by the adoption of libraries like Cats and Shapeless. When building an HTTP API, the choices for a pure functional programming approach are limited. Finch is a good candidate to fill that space and provide a full-stack FP experience.

<!-- break -->

My introduction to Finch happened when I was reviewing talks from the last [Scala eXchange 2016](https://skillsmatter.com/conferences/7432-scala-exchange-2016#program) and I stumbled upon [this good talk](https://skillsmatter.com/skillscasts/9093-scala-services-in-action) by [Sofia Cole](https://twitter.com/@sofiacole35) and [Kingsley Davies](https://twitter.com/kings13y). 

They covered a lot of ground in just 45 minutes, but the thing that caught my attention was [Kingsley](https://twitter.com/kings13y) was speaking about [Finch](https://github.com/finagle/finch/). Probably I noticed it because I've used the other frameworks before, either formally or in exploratory pet-projects, but I wasn't aware of the existence of [Finch](https://github.com/finagle/finch/) itself.

So, as usual when facing a new technology, I tried to understand the so called 'angle of Finch'. Why should I care about it, when there are plenty of solid alternatives? Let's do a high-level overview of Finch to see if it is a library worth spending our time on.

## Functional programming in the web

If we open [Finch](https://github.com/finagle/finch/)'s README file we see that Finch describes itself as:

> Finch is a thin layer of purely functional basic blocks atop of Finagle for building composable HTTP APIs.
> Its mission is to provide the developers simple and robust HTTP primitives being as close as possible to the bare metal Finagle API.

It can't be stated more clearly: Finch is about using functional programming to build HTTP APIs. If you are not interested in functional programming you should stop reading, as you are in the wrong blog.

Finch promotes a healthy separation between HTTP operations and the implementation of your services. Finch's aim is to manage all the IO in HTTP via a very thin layer that you create, a set of request endpoints that will cover all the HTTP IO in your server. It being a simple and composable layer also means that it will be easy to modify as your API evolves or, if it comes to that, it will be easily replaced by another library or framework. 

How does Finch work? Let's see a very simple example:

```scala
// string below (lowercase) matches a String in the URL
val echoEndpoint: Endpoint[String] = 
  get("echo" :: string) { (phrase: String) =>
      Ok(phrase)
  }

val echoApi: Service[Request, Response] = 
  echoEndpoint.toServiceAs[Text.Plain]
```

The example above defines an `echoEndpoint` that returns whatever the user sends back to them, as a text response. The `echoEndpoint` defines a single `get` endpoint, as we can see from the implementation, and will be accessed via the path `/echo/<text>`. We also define our api at `echoAPI` as a set of endpoints, although in this particular case we have a single endpoint. 

Even if this is a simplistic example you can see there is little overhead when defining endpoints. You can easily call one of your services within the endpoint, keeping both layers cleanly separated. 

## A world of endpoints

Finch core structure is a set of endpoint you use to define your HTTP APIs, aiming to facilitate your development. How does it achieve that? If you think about all the web apps you have built, there are a few things that you commonly do, some patterns. Finch tries to alleviate these instances of repetition or boilerplate. 

### Composable endpoints

Let's start with the fact that Finch is a set composable endpoints. Let's assume you are creating a standard Todo list application using a REST API. As you proceed with the implementation you may produce the following list of URI in it:

```
GET     /todo/<id>/task/<id>
PATCH   /todo/<id>/task/<id>
DELETE  /todo/<id>/task/<id>	
```

As you can see, we have a lot of repetition. If we decided to modify those endpoints in the future, there's a lot of room for manual error. 

Finch solves that via the aforementioned composable endpoints. This means we can define a generic endpoint that matches the path we saw in the example above:

```scala
val taskEndpoint: Endpoint[Int :: Int :: HNil] = 
  "todo" :: param("todoId").as[Int] :: "task" :: param("taskId").as[Int]
```

The endpoint `taskEndpoint` will match the pattern we saw defined previously and will extract both `id` as integers. Now we can use it as a building block for other endpoints. See the next example:

```scala
final case class Task(id: Int, entries: List[Todo])
final case class Todo(id: Int, what: String)

val getTask: Endpoint[Task] = 
  get(taskEndpoint) { (todoId: Int, taskId: Int) =>
    println(s"Got Task: $todoId/$taskId")
    ???
  }

val deleteTask: Endpoint[Task] = 
  delete(taskEndpoint) { (todoId: Int, taskId: Int) => ??? }
```

We have defined both a `get` and a `delete` endpoint, both reusing the previously defined `taskEndpoint` that matches our desired path. If down the road we need to alter our paths we only have to change one entry in our codebase, the modification will propagate to all the relevant entry points. You can obviously do much more with endpoint composition, but this example gives you a glimpse of what you can achieve.

### Typesafe endpoints

Reducing the amount of code to be modified is not the only advantage of composable endpoints. If you look again at the previously defined implementation:

```scala
val taskEndpoint: Endpoint[Int :: Int :: HNil] = 
  "todo" :: param("todoId").as[Int] :: "task" :: param("taskId").as[Int]

val deleteTask: Endpoint[Task] = 
  delete(taskEndpoint) { (todoId: Int, taskId: Int) => ??? }
```

We see that the `deleteTask` endpoint maps over two parameters, `todoId` and `taskId`, which are extracted from the definition of `taskEndpoint`. If we were to modify the endpoint to cover a new scenario, like adding API versioning to the path:

```scala
val taskEndpoint: Endpoint[Int :: Int :: Int :: HNil] = 
  "v" :: param("version").as[Int] :: "todo" :: param("todoId").as[Int] :: "task" :: param("taskId").as[Int]
```

We can see that the type of the endpoint has changed from `Endpoint[Int :: Int :: HNil]` to `Endpoint[Int :: Int :: Int :: HNil]`, an additional `Int` in the `HList`. As a consequence, all the endpoints that compose over `taskEndpoints` will now fail to compile as they are currently not taking care of the new parameter. We will need to update them as required for the service to run.

This is a very small example, but we already see great benefits. Endpoints are strongly typed, and if you are reading this you probably understand the benefits of strong types and how many errors they prevent. In Finch this means that a change to an endpoint will be enforced by the compiler onto any composition that uses that endpoint, making any refactor safer and ensuring the coherence of the implementation.

### Testable endpoints

The previous section considered the type-safety of endpoints. Unfortunately this only covers the server side of our endpoints, we still need to make sure they are defined consistently with the expectations of clients.

Typical ways to ensure this include defining a set of calls your service *must* process correctly and to process them as part of your CI/CD step. But running these tests can be both cumbersome to set up, due to the need to launch in-memory servers to execute the full service, as well as slow because you may need to launch the full stack of your application.

Fortunately, ‘Finch’s approach to endpoints provides the means to verify that your service follows the agreed protocol. Endpoints are functions that receive an Http request and return a response. As such, you can call an individual endpoint with a customised request and ensure it returns the expected result.

Let's see an endpoint test taken from the [documentation](https://github.com/finagle/finch/blob/master/docs/user-guide.md#testing):

```scala
// int below (lowercase) matches an integer in the URL
val divOrFail: Endpoint[Int] = post(int :: int) { (a: Int, b: Int) =>
  if (b == 0) BadRequest(new Exception("div by 0"))
    else Ok(a / b)
  }

divOrFail(Input.post("/20/10")).value == Some(2)

divOrFail(Input.get("/20/10")).value == None

divOrFail(Input.post("/20/0")).output.map(_.status) == Some(Status.BadRequest)
```

We test the `divOrFail` endpoint by passing different `Input` objects that simulate a request. We see how a `get` request fails to match the endpoint and returns `None` while both `post` requests behave as expected. 

Obviously more complex endpoints may require you to set up some stubs to simulate calls to services, but you can see how Finch provides an easy and fast way to ensure you don't break an expected protocol when changing your endpoints.

### Json endpoints

Nowadays, Json is the *lingua franca* of REST endpoints. When processing a POST request one of the first tasks is to decode the body from Json to a set of classes from your model. When sending the response, if you are sending back data, the last step is to encode that fragment of your model as a Json object. Json support is essential.

Finch excels in this department by providing support of multiple libraries like *Jackson*, *Argonaut*, or *Circe*. Their [Json documentation](https://github.com/finagle/finch/blob/master/docs/json.md) gives more details on what they support.

By using libraries like [Circe](https://github.com/circe/circe) you can delegate all the serialisation to be automatically managed by Finch, with no boilerplate required. For example, look at the following snippet taken from one of [Finch examples](https://github.com/finagle/finch/blob/master/examples/src/main/scala/io/finch/todo/):

```scala
import io.finch.circe.jacksonSerializer._
import io.circe.generic.auto._

case class Todo(id: UUID, title: String, completed: Boolean, order: Int)

def getTodos: Endpoint[List[Todo]] = get("todos") {
  val list = ... // get a list of Todo objects
  Ok(list)
}
```

If you look at the `getTodos` endpoint, it states its return type is `List[Todo]`. The body obtains such a list and returns it as the response. There is no code to convert that list to the corresponding Json object that will be sent through the wire, all this is managed for you via the two imports defined at the top of the snippet. Circe automatically creates an encoder (and a decoder) for the `Todo` case class, and that it used by Finch to manage the serialisation.

Using Circe has an additional benefit for a common case scenario. When you receive a POST request to create a new object, usually the data receive doesn't include the id to assign to the object, you create this while saving the values. A standard pattern on these cases is to define your model with an optional `id` field, like follows:

```scala
case class Todo(id: Option[UUID], title: String, completed: Boolean, order: Int)
```
With Finch and Circe you can standardise the treatment of these scenarios via partial Json matches, which allow you to deserialise Json objects with missing fields into a partial function that will return the object when executed. See the following snippet:

```scala
def postedTodo: Endpoint[Todo] = jsonBody[UUID => Todo].map(_(UUID.randomUUID()))

def postTodo: Endpoint[Todo] = post("todos" :: postedTodo) { t: Todo =>
  todos.incr()
  Todo.save(t)

  Created(t)
}
```

In it the endpoint `postedTodo` is matching the `jsonBody` received as a function `UUID => Todo`. This will match any Json object that defines a `Todo` object but is missing the `id`. The endpoint itself maps over the result to call the function with a random UUID, effectively assigning a new `id` to the object and returning a complete `Todo` object to work with.

Although this looks like nothing more than convenient boilerplate, don't dismiss the relevance of these partial deserialisers. The fact that your endpoint is giving you a full object, complete with a proper `id`, removes a lot of scenarios where you would need to be aware of the possible lack of `id` or use `copy` calls to create new instances. You work with a full and valid model from the moment you process the data in the endpoint, and this reduces the possibility of errors.

## Metrics, metrics, metrics

The current trends in software architecture towards microservices and [canary releases](https://martinfowler.com/bliki/CanaryRelease.html) mean knowing what is going on in your application matters more than ever. Logging, although still important, is no longer enough. Unfortunately many frameworks and libraries assume you will use a third party tool, like [Kamon](http://kamon.io/) or [New Relic](https://newrelic.com/), to manage your metrics. Which, in a context of microservices, can get expensive quite fast.

Although plain Finch doesn't include any monitoring by itself, the [best practices](https://github.com/finagle/finch/blob/master/docs/best-practices.md) recommend using [Twitter Server](https://twitter.github.io/twitter-server/) when creating a service with Finch. TwitterServer provides extras tooling, including a comprehensive set of [metrics](https://twitter.github.io/twitter-server/Features.html#metrics) along a complete [admin interface](https://twitter.github.io/twitter-server/Admin.html) for your server. 

Having a set of relevant metrics by default means you start your service using best practices, instead of trying to retrofit measurements once you realise they are needed. These metrics can also be retrieved via Json endpoints, which allows you to integrate them with your standard monitoring tools for alerting.

## Performance

Performance is always a tricky subject, as benchmarks can be misleading and, if we are honest, for most of the applications we implement the performance of our HTTP library is not the bottleneck.

That said, Finch is built on top of [Finale](https://twitter.github.io/finagle/), a very performant RPC system built by Twitter. Finch developers claim that "Finch performs on 85% of Finagle's throughput". Their tests show that using Finch along Circe the server can manage 27,126 requests per second. More detailed benchmarks show that Finch is [one of the fastest](http://vkostyukov.net/posts/how-fast-is-finch/) Scala libraries for HTTP.

So there you have it. Finch is not only easy to use, but it also provides more than decent performance, so you don't have to sacrifice its ease of use even on your most demanding projects.

## Good documentation

You may be convinced at this point to use Finch, but with every new library your learn there come a crucial question: how well documented is Finch? It's an unfortunate truth that open source projects often lack good documentation, a fact which increases the complexity of the learning curve.

Luckily for us Finch provides decent [documentation](https://github.com/finagle/finch/blob/master/docs/user-guide.md) for the users, including sections like [best practices](https://github.com/finagle/finch/blob/master/docs/best-practices.md) and a [cookbook](https://github.com/finagle/finch/blob/master/docs/cookbook.md). 

In fact, all of the examples in this post are taken from Finch's documentation. I can say the documentation provided is enough to get you set up and running, and to start with your first services. For more advanced scenarios you may want to check the [source code](https://github.com/finagle/finch) itself, which is well structured and legible.

## Caveats

No tool is perfect, as the worn out "there is no silver bullet" adage reminds us. Finch, albeit quite impressive, has some caveats you need to be aware of before choosing it as your library.

The first and more important one is the lack of Websocket support. Although Finch has a [SSE](https://en.wikipedia.org/wiki/Server-sent_events) module, it lacks a full Websocket library. On many applications this is not an issue and you can work around it. But if you do need Websockets, you need to look elsewhere.

Related to the above limitation is the fact that Finch is still at version *0.11*. Granted, nowadays software in pre-1.0 version can be  (and is) stable and usable in production. And Finch is used in production successfully in many places, as stated by their Readme document. Finch is quite complete and covers the most common needs, but the library is growing and it may lack support for some things you may want. Like the aforementioned Websockets. Before choosing Finch, make sure it provides everything you need.

The last caveat is the backbone of Finch, Finagle. Finagle has been developed by Twitter, and although stable and with a strong open source community, Twitter remains the main interested party on it. 

## In conclusion

Finch is a good library for creating HTTP services, more so if you are keen on functional programming and interested on building pure services with best practices. It benefits from a simple but powerful abstraction (endpoints), removal of boilerplate by leveraging libraries like Circe, and great tooling (Twitter Server).

There are some caveats to be aware of, but we recommend you to build some small service with it. We are confident you will enjoy the experience.




