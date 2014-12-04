$           = require 'jquery'
_           = require 'underscore'
queryString = require './query-string'

init = (elem) ->
  $(elem).each ->
    form = $(this)

    _.each queryString.values("course"), (item) ->
      form.
        find("input[name=course-#{item}]").
        attr("checked", "checked")

      if item.toLowerCase() == "custom"
        $(".hero h1").text("Book a Custom Course")

    form.find("[name=name]").focus()

    form.find("button[type=submit]").on 'click', (evt) ->
      evt.preventDefault()
      window.ga 'send', 'event', 'booking', 'submit', hitCallback: ->
        form.submit()
        return
      return

    return
  return

module.exports = {
  init
}