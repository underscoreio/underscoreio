---
layout: post
title: "Advanced Scala Scalaz to Cats"
author: "Noel Welsh"
---

Yesterday we released a new version of [Advanced Scala][advanced-scala], which changes the library used for examples from [Scalaz][scalaz] to [Cats][cats]. This post explains that change.

<!-- break -->

## It's Not About the Code

When we started writing Advanced Scala we thought it was a book about how to use Scalaz. This made it natural to put Scalaz in the title. Our thinking has evolved a lot since then. Advanced Scala has become a book about how to structure thinking about code using core abstractions like applicatives and monads. It's about architecture and design, which is implemented using a specific library, but learning the library is not the goal of the book.

By analogy, consider painting. Painting is not about placing paint onto a canvas using a brush. It's about using colour and form to convey the artist's intent. The artist must be skillful in their craft to accurately achieve their desired effect, but the craft is only a means to an end. Similarly programming is not about `import` statements, though it is necessary to know how to use them to be an effective Scala programmer.

It is far to say our thinking has evolved more quickly than our writing has, but over time Advanced Scala will focus more on "thinking in types" than on the code level details.

## Why Cats?

So, if Advanced Scala is not about the particular library why change from Scalaz to Cats? For a variety of reasons we prefer Cats. We like it has a focus on approachability. We like that is putting effort into buildling a community, via [Typelevel][typelevel]. We think Scala needs this and we want to support it. Thus we're doing a small bit to help by targeting Cats in Advanced Scala.

## But I Use Scalaz!

If you're using Scalaz you will still find Advanced Scala useful. Cats and Scalaz are very similar and many concepts translate directly from one library to another. Instead of importing, say, `cats.Monad` you import `scalaz.Monad`, for example. The only important differences I have encountered are:

- Cats has a different structure to it's applicative implementation; and
- A syntax import in Cats only imports syntax for the specific named typeclass, not for typeclasses the named typeclass extends. Concretely, `import scalaz.syntax.monoid._` will import syntax for `Semigroup` as well (`|+|`), while in Cats you must use `import cats.syntax.semigroup._` to have the same effect. This prevents collisions between imports that both import the same syntax, as can happen with, say, `import scalaz.syntax.traverse._` and `import scalaz.syntax.applicative._`, which both define `|@|`.

[advanced-scala]: http://underscore.io/books/advanced-scala-scalaz/
[typelevel]: http://typelevel.org/
[cats]: http://typelevel.org/cats/
[scalaz]: https://github.com/scalaz/scalaz
