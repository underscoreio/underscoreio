$ = require "jquery"
_ = require "underscore"

init = (sel) ->
  root = $(sel)

  toggle = root.find(".training-format-features-toggle")
  list   = root.find(".training-format-features")

  list.hide()

  toggle.on "click", (evt) ->
    list.slideToggle("fast")
    return
  return

module.exports = {
  init
}