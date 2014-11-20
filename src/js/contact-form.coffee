$           = require 'jquery'
_           = require 'underscore'
queryString = require './query-string'

init = (elem) ->
  $(elem).each ->
    form = $(this)

    _.each queryValues("subject"), (subject) ->
      form.find('input[name=subject]').attr("value", subject)
      return

    $("[name=name]").focus()

    form.find("button[type=submit]").on 'click', (evt) ->
      evt.preventDefault()
      window.ga 'send', 'event', 'contact', 'submit', hitCallback: ->
        form.submit()
        return
      return
    return
  return

return {
  init
}