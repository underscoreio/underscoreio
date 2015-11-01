---
layout: post
title:  "Why 3x5 is and isn't 5x3"
author: Noel Welsh
---

I saw this blah blah blah

http://i.imgur.com/KtKNmXG.png

It raises many interesting issues that we often talk about here. So why isn't 3x5 the same as 5x3?

Background assumptions: programmers.

What does it mean for 3x5 to *equal* 5x3. One answer is that we can substitute one expression for another with no observable change. That is, wherever we see 5x3 we can write down 3x5, and vice versa, and there is no change in meaning. This requires us to define what is "observable", or what an expression "means", and it's here that we begin to peel back the ... The usual model is to define meaning as the result that expressions evaluate to. The expressions 3x5, 5x3, and 15 are all equivalent because they evaluate to the same value, namely 15. But as programmers we know that this mathematical model does not capture all aspects of meaning. For a very concrete example let's briefly switch to sort algorithms.

You've probably studied sort algorithms at some point. There are many sort algorithms that if considered only in terms of their output are all equivalent---they all sort their input! But a basic part of studying them is learning that they are not equivalent along other dimensions. For example, bubble sort has $O(n^2)$ complexity in the average case, is stable, and can run in-place. Quick sort has average case complexity of $O(n log n)$, is in-place, but is not stable. Merge sort has average case complexity of $O(n log n)$, it is stable, but it is not in-place. These are a just few of the properties we can consider. We could also look at worst-case complexity (quick sort's is $O(n^2)$), ease of parallelisation, locality of reference, and many many more. 

We can do the same with 3x5, 5x3, and 15. They are all equivalent under what we might call the standard interpretation. That is, the all evaluate to the same value. But there are other interpretations where they are not equivalent, such as the number of operations each expression requires. Let's write some code to illustrate this. 

Representation as sequences of additions (as given in the question). They are not the same sequence. They have different runtime costs, measured in terms of operations. We can ask this (which is proportional to the length of the list), yielding a non-standard interpretation.

Hey look, this list is effectively an AST and we're creating interpreters on it. It's the same separation of representation and interpretation that we've talked about before.

In fact the list is the free monoid. We are leveraging associativity to have this canoncial representation. [link]. What else can do? Well, we can leverage commutivity to transform one list into a shorter list (e.g. 5x3 to 3x5) with lower runtime cost. This is why we care about laws for our type classes. They tell us what transformations are legal.

So the teacher is correct. 3x5 is not equal to 5x3, but under the standard interpretation they are equivalent. There is some deep stuff going on here. I'm not equipped to say if this is appropriate to teach children, but if it works it's awesome stuff. Maths is not about calculating but about manipulating structure, and if the students are being taught that structure it seems to me to be a good thing. And it's entirely possible that this example will have given some adults, including me, a deeper appreciation of the depth of structure in simple arithmetic expressions.
