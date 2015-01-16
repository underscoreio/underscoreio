---
layout: page
title: Rethinking Online Training
---

Online training is a thing.

We've done online training last year, but it was just our onsite training done online. That's not the best way to use online training. There are also MOOCs, but that is not really delivering the kind of learning we want to. 

We do we want to do? We want people to understand the patterns of functional programming and apply them in their own work. That's why Essential Scala is built around core patterns of algebraic data types, structural recursion, and so on.

But there is a problem with Essential Scala! It comes from a two-day training course. Over two days you really only get 1.5 days, because everyone is fried. And learning takes time. You simply can't ram any more material into people's heads. And you need to write larger programs that we have the time for, and make mistakes, and discuss your mistakes, so you can develop those pattern recognition algorithms you need to spot where the ES patterns apply in your own code. But taking more time is very difficult onsite. 

I spent some time over Christmas thinking about how we could do a better job of this, and I had some inspiration: studio teaching, done online. Studio style teaching is here: http://slice.cs.uiuc.edu/pubs/Studio-SIGCSE2006.pdf It's something I've be aware of for a while. It's a better way to teach programming, which involves writing larger projects, and more importantly, rewriting them. Getting feedback AND learning from feedback.

The second eureka moment was realising that we could do this online. When we teach online we don't have the dead time while we have lunch, or people work on exercises and I wander around, or peoples' brains are full. We've got the time to learn and I don't have to be around for all of it.

There is the book. It's a good book. People can read it on their own and do the exercises. They don't need me to read it out to them; that's not providing value. We can discuss the exercises online. But better than that we can set larger exercises and discuss those online. And refine them to discuss again, doing it studio style. That's doing something online that we can't (affordably) do face-to-face.

So that's what we're going to do. We're going to continue to offer on-site training, and it will be one or two days. But we're also going to offer an extended curriculum for online students, and for those who can manage it onsite.

We're still developing this material, but we have already got an idea for a project. It's [Doodle](https://github.com/underscoreio/doodle), a compositional graphics library. This is a classic functional langugage application dating back at least as far as [SICP](http://mitpress.mit.edu/sicp/full-text/book/book-Z-H-15.html#%_sec_2.2.4). Using the library is going to make for some fun exercises, and recreating the library is going to make a great case study. 
