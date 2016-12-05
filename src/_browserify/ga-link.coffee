$          = require "jquery"
_          = require "underscore"
doNotTrack = require './do-not-track'


init = (sel = "body") ->
  root = $(sel)

  root.on "click", ".ga-link", (evt) ->
    # This code will cancel clicks on the application link if GA isn't present:
    unless window.ga?.loaded then return

    # Gather the click-through URL and tracking ID from the element:
    elem     = $(evt.currentTarget)
    category = elem.data('category') ? throw new Error('No category on ga-link')
    action   = elem.data('action')   ? throw new Error('No action on ga-link')
    label    = elem.data('label')    ? throw new Error('No label on ga-link')
    url      = elem.attr('href')

    # Cancel the default click event:
    evt.stopPropagation()
    evt.preventDefault()

    # Debugging message in case stuff goes bad:
    window.console?.log?('Logging outbound link and redirecting', category, action, label, url)

    # Record a custom "job application outbound" event on GA and
    # continue to the application link:
    doNotTrack.sendGaEvent category, action, label, ->
      document.location = url
      return

    return

  return

module.exports = {
  init
}
