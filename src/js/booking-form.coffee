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
    msg = 'Thank you for your booking request. We will be in touch shortly.'
    $('#feedback').removeClass('label-info').addClass('label-success').text msg
    return

  # HTML form -> Map[key, List(value)]
  formToJson = (form) ->
    data = {}
    $.each $('#booking-form :input').serializeArray(), (i, e) ->
      if e.value != ''
        if data[e.name]
          data[e.name].push(e.value)
        else
          data[e.name] = [e.value]
      return
    data

  validate = (json) ->

    missing = (key) ->
      _.isUndefined json[key]

    errors = []
    if missing('email')
      errors.push 'a valid email address'
    if missing('name')
      errors.push 'your name'
    if missing('course')
      errors.push 'one or more courses'
    if missing('people')
      errors.push 'how many people on your team'
    if missing('g-recaptcha-response')
      errors.push 'proof you are not a robot'
    errors

  onFormSubmission = ->
    json = formToJson(elem)
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
        error 'There was an error submitting your booking request. Please get in touch by phone or email.'
        return

      allCourses = json.course.join('\n- ')

      json.subject = "Booking Request"
      json.name    = json.name[0]
      json.email   = json.email[0]
      json['g-recaptcha-response'] = json['g-recaptcha-response'][0]
      json.message = """
                      A booking request was submitted on underscore.io:

                      Courses:
                      - #{allCourses}

                      #{json.behalf[0]}
                      People: #{json.people[0]}
                      Location: #{json.location?[0]}

                      Additional notes:
                      #{json.notes?[0]}

                      --
                      Underscore Bookings Robot
                      http://underscore.io
                     """

      $.ajax
        type        : 'POST'
        url         : endpoint
        dataType    : 'json'
        contentType : 'application/json; charset=utf-8'
        data        : JSON.stringify(json)
        success     : onResponse
        error       : onFatal
    false

    false

  $(elem).each ->
    form = $(this)

    _.each queryString.values("course"), (item) ->
      courseId = _.last item.split('/')
      form.
        find("input[value=#{courseId}]").
        attr("checked", "checked")

        if item.toLowerCase() == "custom"
          $(".hero h1").text("Book a Custom Course")

    form.find("[name=name]").focus()

    form.find("button[type=submit]").on 'click', (evt) ->
      evt.preventDefault()
      window.ga 'send', 'event', 'booking', 'submit', hitCallback: ->
        onFormSubmission()
        return
      return

    return
  return

module.exports = {
  init
}
