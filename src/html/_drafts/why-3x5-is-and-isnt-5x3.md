---
layout: post
title:  "Why 3x5 is and isn't 5x3"
author: Noel Welsh
---

I saw this blah blah blah

http://i.imgur.com/KtKNmXG.png

It raises many interesting issues that we often talk about here. So why isn't 3x5 the same as 5x3?

Background assumptions: programmers.

What does it mean for 3x5 to *equal* 15. One answer is that we can substitute one expression for another with no observable change. That is, wherever we see 15 we can write down 3x5, and vice versa, and there is no change in meaning. This requires us to define what is "observable", or what an expression "means", and it's here that we begin to peel back the ... The usual model is to define meaning as the result that expressions evaluate to. The expressions 3x5, 5x3, and 15 are all equivalent because they evaluate to the same value, namely 15. But as programmers we know that this mathematical model does not capture all aspects of meaning. For a very concrete example let's briefly switch to sort algorithms.

You've probably studied sort algorithms at some point. There are many sort algorithms that if considered only in terms of their output are all equivalent---they all sort their input! But a basic part of studying them is learning that they are not equivalent along other dimensions. For example, bubble sort has $O(n^2)$ complexity in the average case, is stable, and can run in-place. Quick sort has average case complexity of $O(n log n)$, is in-place, but is not stable. Merge sort has average case complexity of $O(n log n)$, it is stable, but it is not in-place. These are a just few of the properties we can consider. We could also look at worst-case complexity (quick sort's is $O(n^2)$), ease of parallelisation, locality of reference, and many many more. 

We can do the same with 3x5, 5x3, and 15. They are all equivalent under what we might call the standard interpretation. That is, the all evaluate to the same value.
