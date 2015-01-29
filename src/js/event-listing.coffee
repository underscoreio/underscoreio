$ = require "jquery"
_ = require "underscore"

init = (sel) ->
  root = $(sel)

  root.on "click", ".event-link", (evt) ->
    evt.stopPropagation()
    return

  root.on "click", ".event-excerpt", (evt) ->
    elem     = $(evt.currentTarget)
    eventUrl = $(elem).data("eventUrl")
    if eventUrl
      window.location = eventUrl
    return

  return

module.exports = {
  init
}