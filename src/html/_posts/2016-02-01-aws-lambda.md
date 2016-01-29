---
layout: post
title: "Scala and AWS Lambda Blueprints"
author: "Richard Dallaway"
---

[AWS Lambda] is a service that allows you deploy a function to the web.
There are no servers to maintain,
and billing is based on the compute time your function uses.

At the end of 2015, Amazon launched a set of AWS Lambda [blueprints] to help developers get up and running with Lambda.
These consists of Python and JavaScript examples, based around integrating with [Slack] ("chat-based DevOps", in their words).

But Amazon omitted to mention the JVM.
This post fills the gap and shows you how to use AWS Lambda with Scala and Slack.

[AWS Lambda]: https://aws.amazon.com/lambda/
[API Gateway]: https://aws.amazon.com/api-gateway/
[code]: https://github.com/d6y/aws-lambda-scala-slack
[Slack]: https://slack.com/
[commands]: https://api.slack.com/slash-commands
[blueprints]: https://aws.amazon.com/about-aws/whats-new/2015/12/aws-lambda-launches-slack-integration-blueprints/
[slackdotscala]: https://github.com/d6y/aws-lambda-scala-slack/blob/master/src/main/scala/example/slack.scala
[circe]: https://github.com/travisbrown/circe
[sbt-assembly]: https://github.com/sbt/sbt-assembly
[tim-and-sean]: https://aws.amazon.com/blogs/compute/writing-aws-lambda-functions-in-scala/
[playground]: https://github.com/d6y/aws-gateway-mapping-playground
[cew]: (https://github.com/christianewillman/aws-api-gateway-bodyparser)
[velocity]: https://en.wikipedia.org/wiki/Apache_Velocity

<!-- break -->

# What we're going to make

The Amazon blueprints echo back what you type into Slack. I want to do something more useful than that.  I want this kind of interaction:

![Screen Shot of /time command in Slack](/images/blog/2016-02-01-aws-lambda-slack.png)

I ask for the time in a bunch of places via `/time place-name` and my AWS Lambda function sends back the current time in all those places.

## Lambda and the API gateway

Using AWS Lambda to do this involves three things:

- configuring Slack to recognize the command;
- writing some code; and
- deploying the code to AWS Lambda.

To be more precise, AWS Lambda is a compute service, not a web service. What triggers the computation is an event. That can be something like a object being changed in an S3 bucket.

For the blueprint examples to integrated with Slack, they have to be triggered from a web request. Here's the scenario:

1. I type `/time new-york` in Slack;
2. Slack is configured to send information about the command to a web service; and
3. Slack shows me the output from calling the web service.

To trigger a Lambda via the web you need the [Amazon API Gateway][API Gateway]. That's what the [blueprints] use.

## Scala code

Before we dig into the deployment details,
let's deal with the easiest part: the Scala code.

The first question you probably have is:
what's the type-signature of the Lambda?
Amazon will recognize a range of type signatures,
but at the core the service is a transformation from JSON to JSON.

There's automatic serialization for various data types,
but they are focused on Java conventions.
As a Scala developer, I don't make a lot of use of JavaBeans, so I'm going to work with the raw input and output:

~~~ scala
import java.io.{InputStream, OutputStream}

def time(in: InputStream, out: OutputStream): Unit = ???
~~~

Not the prettiest thing, but something we can work with. The `in` stream will be JSON as text; and the `out` stream will be JSON as text.

The [example code I've put on GitHub][slackdotscala] does this:

1. Reads the input stream.
2. Uses [Circe] to decode it into a case class.
3. Extracts what it needs, and produces another case case with all the results in it.
4. Uses Circe again to serialize the results back as JSON to Amazon, and there onward to Slack.

The Lambda function runs on a Java 8 JVM, and I use the built in `java.time` API to do compute all the different time information.

## Deployment

The deploy the code we need to package it, and we need something to deploy it to.

The packaging is done with [sbt-assembly], as Tim Wagner and Sean Reque have done in their [example for S3][tim-and-sean]. This produces a JAR file.

To deploy it, you can create a Lambda environment and connect it to the API Gateway. But there's a trick you can use to save some time. In the AWS Lambda Console, use the existing "slack-echo-command-pyton" example, and at the last step switch from Python to Java 8. You'll be promoted to upload a JAR file.

If all goes well, you'll end up with an API Gateway that looks like this:

![API Gateway Screengrab](/images/blog/2016-02-01-aws-lambda-gateway.png)

The "Integration Request" has some interesting settings, which we will now take a look at.

## The web is not JSON

This is the messy part.
AWS Lambda is based on JSON, but the web is not all about JSON.

In fact, the Slack service posts standard web form data, not JSON.
We need to convert it to JSON before our Lambda function is called.

This can be handled by the AWS API Gateway's "mapping template" functionality. Hold your nose, because this smells.

For us, we need to go from `x-www-form-urlencoded` data that Slack sends us, into JSON:

![Screen Shot of Template Mapping](/images/blog/2016-02-01-aws-lambda-mapping.png)

That stuff on the right is [Velocity] markup. Amazon have a scripting engine which you can use to re-write a web request into JSON.

Thankfully, [Christian E Willman][cew] has figured out what that template should be.
And I've started [a rudimentary emulation][playground] of the Amazon Mapping Template environment to be able to debug these kinds of templates.

As terrifying as that is, it does turn a request into JSON. Hopefully Amazon will add support for form encoding to Lambda one day.

## The final step: plugging in Slack

Configuring a new command in Slack is [best explained by Slack][commands].
The one thing you need is the Amazon Gateway URI to your Lambda service.
It's shown in the AWS API Gateway Dashboard.
It'll be something like: `https://2s4x4kkp.execute-api.us-west-2.amazonaws.com/prod/`.

## Summary

With those pieces in place, we have deployed a JAR file containing a Scala function to AWS Lambda.
We've wired up Slack to call the function, and arranged for the API Gateway to turn Slack's form data into JSON.

In theory, our function can now scale out to as many clients as Amazon can support. That should be a pretty big number.

As for performance, I only have informal information at the moment.
The function typically executes in something like 80ms.
However, there's a great deal of variation in that.

For cold-start up,
if no requests have been seen for some time,
those values go almost to 3s.

AWS Lambda works.
You can use it with Scala,
and may play an important role in web development.
I can see the immediate benefit for micro-sites and services,
as well for scheduled work or work reacting to other events.
