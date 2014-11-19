$ = require "jquery"
_ = require "underscore"

init = (sel) ->
  root = $(sel)

  toggle = root.find(".format-features-toggle")
  list   = root.find(".format-features")

  list.hide()

  toggle.on "click", (evt) ->
    list.slideToggle("fast")
    return
  return

module.exports = {
  init
}