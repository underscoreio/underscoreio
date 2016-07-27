$           = require 'jquery'
_           = require 'underscore'
queryString = require './query-string'

init = (elem) ->

  endpoint = 'https://7a1z3bah1m.execute-api.eu-west-1.amazonaws.com/prod/contact'

  notice = (msg) ->
    $('#feedback').removeClass('label-danger').addClass('label-info').text msg
    return

  error = (msg) ->
    $('#feedback').removeClass('label-info').addClass('label-danger').text msg
    return

  done = ->
    msg = 'Thank you for submitting your message. We will be in touch shortly.'
    $('#feedback').removeClass('label-info').addClass('label-success').text msg
    return

  formToJson = ->
    data = {}
    $.each $('#contact-form :input').serializeArray(), (i, e) ->
      if e.value != ''
        data[e.name] = e.value
      return
    data

  validate = (json) ->
    # TODO: improve validation: trimming, better email detection

    blank = (s) ->
      !s or s == ''

    notEmail = (s) ->
      !s or s == ''

    errors = []
    if notEmail(json.email)
      errors.push 'a valid email address'
    if blank(json.name)
      errors.push 'your name'
    if blank(json.message)
      errors.push 'a message'
    if blank(json.subject)
      errors.push 'a subject'
    if blank(json['g-recaptcha-response'])
      errors.push 'proof you are not a robot'
    errors

  onFormSubmission = ->
    json = formToJson()
    missing = validate(json)
    if missing.length != 0
      error 'Please supply: ' + missing.join(', ') + '.'
    else
      notice 'Sending...'

      onResponse = (response) ->
        if response.errorMessage
          error response.errorMessage
        else
          done()
        return

      onFatal = (e) ->
        error 'There was an error submitting your message. Please get in touch by phone or email.'
        return

      $.ajax
        type        : 'POST'
        url         : endpoint
        dataType    : 'json'
        contentType : 'application/json; charset=utf-8'
        data        : JSON.stringify(json)
        success     : onResponse
        error       : onFatal
    false

  $(elem).each ->
    form = $(this)

    _.each queryString.values("subject"), (subject) ->
      form.find('input[name=subject]').attr("value", subject)
      return

    $("[name=name]").focus()

    form.find("button[type=submit]").on 'click', (evt) ->
      evt.preventDefault()
      window.ga 'send', 'event', 'contact', 'submit', hitCallback: ->
        onFormSubmission()
        return
      return
    return
  return

module.exports = {
  init
}
