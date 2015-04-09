---
layout: post
title:  "Deriving the Free Monad"
author: Noel Welsh
---

The free monad is defined by this structure[^defn]:

~~~ scala
sealed trait Free[F[_], A]
final case class Return[F[_], A](a: A) extends Free[F, A]
final case class Suspend[F[_], A](s: F[Free[F, A]]) extends Free[F, A]
~~~

but it certainly wasn't obvious to me *why* this is correct. Reading the literature quickly devolves into "doughzoids in the category of pretzelmorphisms" land but there is actually a very simple explanation that doesn't involve abstract alphabet-soup. 

<!-- break -->

## Preliminaries

The goal of the free monad is to represent a monad with the minimal possible structure. Concretely this means separating the structure of the computation from the process that gives it meaning.

Let me give a simple example that doesn't involve any monads. Consider the expression

~~~ scala
1 + 2 + 3
~~~

When we write this expression we bundle the structure of the computation (two additions) with the meaning given to that computation (`Int` addition).

We could separate structure and meaning by representing the structure of the computation as data, perhaps as[^oops]

~~~ scala
Add(1, Add(2, 3))
~~~

Now we can write a simple interpreter to give meaning to this structure. Having separated the *abstract syntax tree* from the interpreter we can choose different interpretations for a given tree, such as computing with [dual numbers][dual-numbers] to automatically compute derivatives, or running the code on a GPU.

The free monad is just an abstract syntax tree representation of a monad. This means we should be able to derive the free monad from the operations required to define a monad. Before we dive into the free monad, I want to return to our example of addition and derive the free monoid.


## The Free Monoid

Our goal with implementing the free monoid is to represent computations like

~~~ scala
1 + 2 + 3
~~~

in a generic way without giving them any particular meaning.

A monoid for some type `A` is defined by:

1. an operation `append` with type `(A, A) => A`; and
2. an element `zero` of type `A

The following laws must also hold:

1. `append` is associative, meaning `append(x, append(y, z)) == append(append(x, y), z)` for all `x`, `y`, and `z`, in `A`.
2. `zero` is an identity of `append`, meaning `append(a, zero) == append(zero, a) == a` for any `a` in `A`.

The monoid operations (`append` and `zero`) suggest we want a structure something like

~~~ scala
sealed trait FreeMonoid[+A]
final case object Zero extends FreeMonoid[Nothing]
final case class Append[A](l: A, r: A) extends FreeMonoid[A]
~~~

but this doesn't work -- we can't write, for instance, `Append(Zero, Zero)` because the types don't line up. We can use the monoid laws to make the final step. Let's do some algebraic manipulation on `1 + 2 + 3` to normalize it into something we can implement.

The identity law means we can insert the addition of zero in any part of the computation without changing the result, and likewise we can remove any zeros (unless the entire expression consists of just zero). We're going to decree that any normalized expression must have a single zero at the end of the expression like so: 

~~~ scala
1 + 2 + 3 + 0
~~~

The associativity law means we can place brackets wherever we want. We're going to decide to bracket expressions so traversing the expression from left to right goes from outermost to innermost, like so:

~~~ scala
(1 + (2 + (3 + 0)))
~~~

With these changes -- which by the monoid laws make no difference to the meaning of the expression -- we can easily construct an abstract syntax tree.

~~~ scala
sealed trait FreeMonoid[+A]
final case object Zero extends FreeMonoid[Nothing]
final case class Append[A](l: A, r: FreeMonoid[A]) extends FreeMonoid[A]
~~~

We can represent `1 + 2 + 3` (normalized to `(1 + (2 + (3 + 0)))`) as

~~~ scala
Append(1, Append(2, Append(3, Zero)))
~~~

The final step is to recognise that this structure is isomorphic (in the real, not the [Javascript][js-iso], sense) to `List`. So we could just as easily write

~~~ scala
1 :: 2 :: 3 :: Nil
~~~

or

~~~ scala
List(1, 2, 3)
~~~

High fives all around -- we've derived the free monoid from first principles.

## The Free Monad

We are now ready to tackle the free monad. We can take the same approach starting with the monad operations `point` and `flatMap`, but our task will be easier if we reformulate monads in terms of `point`, `map`, and `join`.

[dual-numbers]: http://en.wikipedia.org/wiki/Dual_number
[js-iso]: http://isomorphic.net/

[^defn]: There are other ways of defining the free monad, but this is the most common in my reading.
[^oops]: This data structure can't actually be implemented. The right-hand element of `Add` is an `Add` in one case and an `Int` in another. We'll see how to actually implement this in the next section.




