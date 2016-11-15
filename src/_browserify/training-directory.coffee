$ = require "jquery"
_ = require "underscore"

init = (sel) ->
  root = $(sel)

  root.on "click", ".panel", (evt) ->
    elem = $(evt.currentTarget)
    url  = $(elem).data("url")
    if url then window.location = url
    return

  return

module.exports = {
  init
}
