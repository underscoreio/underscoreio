---
layout: post
title: "What is an Effect?"
author: "Noel Welsh"
---

When I published my [last blog post][opaque] a reader asked me to define what an effect is.
In this post I want to give a simple model of effects in terms of substitution.
I then try to explain why functional programmers care so much about controlling effects,
and constrast this with the object-oriented approach that focuses more on the run-time behaviour of programs.
Finally, I'll talk a bit about why thinking about these issues is more than a fun mental exercise.

<!-- break -->

## The Substitution Model of Evaluation

We're going to start with a simple model for understanding what a program will do when it's run---without running it.
In the terminology of of programming language theory this is called the (operational) semantics,
and the model of semantics we're looking at is called the substitution model. 

The substitution model says: *we can replace any expression with the value it evaluates to without changing the meaning of the program.*

This description has some technical terms that we need to explain: *evaluation*, *expression*, and *value*. 
Evaluation means to run a program.
An expression is program text, like `1 + 1`. 
We can write program text into a file, onto a whiteboard, or, even, in a blog post. 
It's just text. 
A value is something that lives in the computer's memory. 
While we can write that `1 + 1` evaluates to `2`, what we really mean is that `1 + 1` evaluates to a specific 32-bit bit-pattern at a specific location in the computer's memory,
and that specific bit-pattern is the same as `2`.

Most Scala code consists of expressions, 
but we also need to be aware of *declarations*
Declarations give names to values.
For example `val foo = 2` gives the name `foo` (in some particular scope) to the value `2`.

Some languages also have *statements*, 
which are like expressions but do not evaluate to a value. 
As far as I know, everything in Scala evaluates to a value and therefore Scala has no statements. 
In Java `if`, `for`, and `while` are all statements.

With those definitions out of the way we can turn back to substitution.

Remember the substitution model says we can replace any expression with the value it evaluates to without changing the meaning of the program.

So if we see the program

```scala
1 + 1
```

we can replace it with

```scala
2
```

and nothing changes[^meaning].

Substitution has many nice properties. 
It is *compositional*.
This means we can determine the meaning of a program fragment in isolation, 
and the meaning of the entire program is determined by the meaning of those individual fragments along with the rules for combining those fragments.

For example, if we see the program

```scala
(1 + 1) + (1 + 1)
```

we can tackle each expression within brackets in isolation, giving

```scala
(2) + (2)
```

and then combine these two fragments yielding the final result

```scala
4
```

The other nice thing about substitution is it is really simple.
You probably learned substitution in high school algebra,
though probably not under this name.

Substitution works with declarations as well.
If we have the program

```scala
val x = 2
x + x
```

We can substitute the value `2` wherever we see `x`, giving us

```scala
2 + 2
```

which we can combine to give

```scala
4
```

Similarly with methods, 
we can substitute a method call with the method body,
so long as we consistently substitute values for the method parameters.

Take

```scala
def square(x: Int): Int =
  x * x
square(2)
```

We can substitute `square(2)` with `x * x`, substituting `2` for `x` and giving us

```scala
2 * 2
```

which in turn gives us

```scala
4
```

[^meaning]: We have to make a decision about what constitutes the "meaning" of the program, and what falls outside our model. For example, `1 + 1` and `2` probably differ in execution time and memory consumption but we usually decide we are not interested in these differences and declare them to be equivalent.

[opaque]: {% post_url 2016-06-27-opaque-transparent-interpreters %}
