---
layout: post
title: Roundup of the New Speakers at Scala Exchange
author: Noel Welsh
date: '2015-01-14'
hashtags : scalax
---

Now that [Scala Exchange](https://skillsmatter.com/conferences/1948-scala-exchange-2014#program) over, it's a good time to look back and celebrate the achievements of the nine speakers that came to Scala Exchange via our [diversity programme](http://underscoreconsulting.com/blog/posts/2014/06/30/underscores-new-speaker-program.html). Below I have collected their talks, slides, and thoughts on the conference.

<!-- break -->

<!-- break -->

### Tomer Gabel

> Scala eXchange for me was all about great talks, interleaved with ad-hoc discussions with amazingly smart and talented people; I believe I learned a lot more than I taught, which is always the hallmark of a great conference! 

Tomer talked about the design of a validation library DSL. My colleague Dave Gurnell also presented on the same topic, and it is interesting to [compare his design](https://skillsmatter.com/skillscasts/5837-functional-data-validation) with [Tomer's](https://skillsmatter.com/skillscasts/5947-a-field-guide-to-dsl-design). Tomer's slides are [here](http://www.slideshare.net/holograph/a-field-guide-to-dsl-design-in-scala).


### Andrew Harmel-Law

Tomer is a very experienced Scala developed, while our next speaker, Andrew Harmel-Law,  represents the other end of spectrum. His [talk](https://skillsmatter.com/skillscasts/5835-bootstrapping-a-scala-mindset) described his experiences learning Scala as a Java veteran. He did a great job conveying the struggle to rewire his mental model of programming from an imperative to a functional model. I asked Andrew for his thoughts on the conference and diversity programme and he replied:

> What struck me most was the number and range of attendees - diverse in background, expertise, industry and more.  It made for an exciting conference to both attend and talk at.  I'll definitely submit a session next year.
>
> [The] shepherding was excellent, giving me the confidence to talk in front of a diverse crowd, knowing I was presenting a coherent and structured session. 

Andrew's slides are [here](http://www.slideshare.net/al94781/bootstrapping-a-scala-mindset-scala-exchange-2014). Andrew will happily supply a PPT version of the slides with full speaker notes, please ping him on [Twitter](https://twitter.com/al94781).


### David Brooks

David Brooks [talked](https://skillsmatter.com/skillscasts/5838-shopping-around-with-crdts-at-whisk) about the application of CRDTs to cross-device synchronisation at [Whisk](http://whisk.co.uk). I'm a big fan of CRDTs, having [talked about them before](http://underscore.io/blog/posts/2013/12/20/crdts-for-fun-and-eventual-profit.html), so I was very interested to see what he had to say. His talk didn't disappoint, as he adopted quite a different implementation strategy to that which I have used when implementing CRDTs.

Dave tells me his talk had a great reception, including an email from one of the leading researchers in the field suggesting some optimisations to their system. Dave's slides are [here](http://www.slideshare.net/junglebarry/shopping-around-with-crdts-at-whisk).


### Gary Higham

Gary Higham from the BBC described [how the Future Media Children's team transitioned](https://skillsmatter.com/skillscasts/5839-playing-with-scala-moving-children-into-scala-and-play-at-the-bbc) to Scala from PHP. I think Gary's talk represents growing maturity in the Scala community. We've moved on from the early adopters, who focused mainly on language features, to mainstream organisations like the BBC where the focus is on integrating Scala into a corporate environment with diverse developer backgrounds.


### Rebecca Grenier

Rebecca Grenier described [her experiences using Slick](https://skillsmatter.com/skillscasts/5851-slick-bringing-scala-s-powerful-features-to-your-database-access) at EatingWell Magazine. Her background is similar to the BBC team's: migrating from PHP to Scala. Becky [has blogged](http://www.rebeccagrenier.com/speaking-at-scalax-2014) about her experiences at Scala Exchange. Go read it now!


### Pere Villega

> I think it is just fair to say that without Richard and Dave help probably I would have not spoken at the conference, or my talk would have bombed. All the advice was great, and I'm sure Becky will agree in that it made the difference when preparing for the event :) 

Kafka and other distributed systems goodness at Gumtree was the subject of Pere Villega's [talk](https://skillsmatter.com/skillscasts/5845-the-process-using-kafka-to-drive-microservices-architecture). I didn't get to see Pere's talk, but as a big fan of [Kafka](http://kafka.apache.org/) I've put it on my list of ones to catch up on. Pere's slides are [here](https://github.com/pvillega/talk_scalaX2014).


### Paulo Siqueira

> Scala eXchange 2014 was a great event. It is really refreshing to see how big the Scala community is, and what it is achieving. Like any good event, I learned a lot, teached a bit and met old and new people. I hope I can make it to 2015! -- Paulo "JCranky" Siqueira

Perhaps the most fun talk at Scala Exchange, Paulo delved into the [world of Minecraft mods](https://skillsmatter.com/skillscasts/5850-minecraft-and-scala-creating-a-dsl-to-enable-kids-to-create-minecraft-mods) using Scala. I'm sure all of us with young children will be studying Paulo's work, and putting it to practice. Paulo's slide are [here](http://www.slideshare.net/jcranky/minecraft-and-scala-creating-a-dsl-to-enable-kids-to-create-minecraft-mods).


### Martin Kühl

> Speaking at Scala Exchange was a brilliant experience. Thanks to Underscore for their help getting us started! -- Martin Kühl

Martin [presented](https://skillsmatter.com/skillscasts/5985-concrete-abstraction-with-scalaz) one of a number of talks at the conference on Scalaz. Martin's [slides](https://speakerdeck.com/mkhl/concrete-abstraction-with-scalaz-scala-exchange-2014) have a nice visual representation of the core abstractions in Scalaz, and he has some great examples in his talk. 


### Patrick Premont

Patrick Premont had the last slot in the conference, and also gets the closing position in this post. [His talk](https://skillsmatter.com/skillscasts/5949-evolving-identifiers-and-total-maps) delves into type level programming. His particular application is creating a `Map` where we statically ensure all keys have values. Type level programming, exemplified by [Shapeless](https://github.com/milessabin/shapeless), is extremely powerful and well worth adding to your toolbox.




