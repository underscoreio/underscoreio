$ = require "jquery"
_ = require "underscore"

init = (sel) ->
  root = $(sel)

  root.on "click", ".course-book", (evt) ->
    evt.stopPropagation()
    return

  root.on "click", ".course-excerpt", (evt) ->
    elem     = $(evt.currentTarget)
    courseId = $(elem).data("courseId")
    if courseId
      window.location = "#{courseId}/"
    return

  return

module.exports = {
  init
}
