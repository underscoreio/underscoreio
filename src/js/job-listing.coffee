$ = require "jquery"
_ = require "underscore"

init = (sel) ->
  root = $(sel)

  root.on "click", ".job-link", (evt) ->
    evt.stopPropagation()
    return

  root.on "click", ".job-excerpt", (evt) ->
    elem     = $(evt.currentTarget)
    jobUrl = $(elem).data("jobUrl")
    if jobUrl
      window.location = jobUrl
    return

  return

module.exports = {
  init
}