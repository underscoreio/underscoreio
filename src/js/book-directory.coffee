$ = require "jquery"
_ = require "underscore"

init = (sel) ->
  root = $(sel)

  root.on "click", ".book", (evt) ->
    evt.stopPropagation()
    return

  root.on "click", ".book-excerpt", (evt) ->
    elem     = $(evt.currentTarget)
    bookId = $(elem).data("bookId")
    if bookId
      window.location = "/books/#{bookId}/"
    return

  return

module.exports = {
  init
}