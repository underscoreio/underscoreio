$ = require "jquery"
_ = require "underscore"

init = (sel) ->
  root = $(sel)

  toggle = root.find(".training-format-features-toggle")
  list   = root.find(".training-format-features")
  icon   = toggle.find(".fa")

  list.hide()

  toggle.on "click", (evt) ->
    list.slideToggle("fast")
    icon.toggleClass("fa-chevron-down fa-chevron-up")
    return
  return

module.exports = {
  init
}