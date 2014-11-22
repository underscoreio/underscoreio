$ = require "jquery"
_ = require "underscore"

init = (sel) ->
  root = $(sel)

  toggle = root.find(".training-format-features-toggle")
  list   = root.find(".training-format-features")
  icon   = toggle.find(".icon-uio-chevron-down")

  list.hide()

  toggle.on "click", (evt) ->
    list.slideToggle("fast")
    icon.toggleClass("icon-uio-chevron-down icon-uio-chevron-up")
    return
  return

module.exports = {
  init
}