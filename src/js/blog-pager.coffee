$ = require 'jquery'

init = (element) ->
  $(element).each ->
    root        = $(this)
    prevPaddle  = root.find(".home-blog-paddle-prev")
    nextPaddle  = root.find(".home-blog-paddle-next")
    prevLink    = root.find(".home-blog-link-prev")
    nextLink    = root.find(".home-blog-link-next")
    postWrapper = root.find(".home-blog-posts")
    posts       = postWrapper.find(".blog-post")
    curr        = 0

    resizePaddles = (post) ->
      postWrapper.innerHeight(post.height())
      prevPaddle.innerHeight(post.height())
      nextPaddle.innerHeight(post.height())
      return

    showPost = (next) ->
      prev = curr

      if posts.length > 0
        len = posts.length
        while next <  0   then next += len
        while next >= len then next -= len

      curr = next

      prevPost = $(posts.get(prev))
      nextPost = $(posts.get(next))

      prevPost.fadeOut "fast", ->
        resizePaddles(nextPost)
        nextPost.fadeIn("fast")
        return

      return

    gotoPost = (evt) ->
      url = $(this).data("postUrl")
      if url then window.location = url
      return

    prevPaddle.add(prevLink).on("click", (evt) -> showPost(curr - 1))
    nextPaddle.add(nextLink).on("click", (evt) -> showPost(curr + 1))
    postWrapper.on("click", ".blog-post", gotoPost)
    showPost(curr)
    return

  return

module.exports = {
  init
}