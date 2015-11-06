$ = require "jquery"
_ = require "underscore"

init = (sel) ->
  root = $(sel)

  root.on "click", ".btn-job-apply", (evt) ->
    # This code will cancel clicks on the application link if GA isn't present:
    unless window.ga then return

    # Cancel the default click event:
    evt.stopPropagation()
    evt.preventDefault()

    # Gather the click-through URL and tracking ID from the element:
    elem       = $(evt.currentTarget)
    trackingId = elem.data('trackingId') ? '_blank'
    url        = elem.attr('href')

    # Debugging message in case stuff goes bad:
    window.console?.log?('Logging outbound link and redirecting', trackingId, url)

    # Record a custom "job application outbound" event on GA and
    # continue to the application link:
    window.ga('send', 'event', 'job', 'application-outbound', trackingId, {
      hitCallback: ->
        document.location = url
        return
    })

    return

  return

module.exports = {
  init
}