---
layout: post
title: "Scala.js is Important for Cloud Services"
author: "Richard Dallaway"
---

More people are using serverless architectures than I would have guessed, and they are getting significant benefits from doing so.
Scala is a great fit for these kinds of architectures because it can use the JVM and, thanks for Scala.js, JavaScript runtimes too.
This post is a small observation regarding this.

<!-- break -->

[Scala.js]: https://www.scala-js.org/
[Scale Summit]: http://www.scalesummit.org/
[video]: https://www.parleys.com/tutorial/towards-browser-server-utopia-scala-js-example-using-crdts
[post]: http://underscore.io/blog/posts/2016/02/01/aws-lambda.html
[chr]: https://www.chathamhouse.org/about/chatham-house-rule


## Examples from production

At [Scale Summit] this year I convened a session on "serverless" architectures.
The session attracted something like 25 people (out of 150 attendees) interested in sharing their experiences.

Of that group plenty seemed to be experimenting or interested, but three or four already had some significant production use.
This is on AWS Lambda, a service that launched as a preview 16 months ago.

For example, one company is triggering Lambda functions based on sales events.
The function updates another data store.
They are doing something like 1,000 calls a minute, with no reliability problems.

The service is 80 times cheaper for them than the equivalent pre-Lambda solution they had in place.

## Scala.js

[Scala.js] comes into this because AWS Lambda supports node as well as the JVM as a runtime.

Scala.js is a Scala to JavaScript compiler, with great JavaScript interoperability.
This means we can write a Lambda service in Scala, and deploy it on the Lambda node environment.

I've been experimenting with this, and so far it looks like the start up times under node are significantly smaller than those for the JVM.
For example, in a previous [post] we described running a Scala function on AWS Lambda and noted 3 second cold start up times.
Compiling a service to Scala.js and running that on Lambda shows no latency anywhere near that.
At the moment, this is anecdotal: I'm not comparing exactly the same service under Scala.js and Scala.

A potential gain from running under node is maybe not a surprise. If AWS is launching a service for one use, then destroying it again, you have a different set of needs compared to a long-running process.


## Conclusion

AWS Lambda is being used, and companies are seeing benefits.
My sample size for this is small, and from a technically advanced group.

Scala is in a good position for these kinds of services:

- you can use Scala.js to target the node runtime, and that's probably going to turn out to be a good default route

- if you need access to JVM-only facilities (JDBC, for example), or you think the JVM JIT is going to benefit you, you can target the JVM.

In both cases, you're writing Scala.


