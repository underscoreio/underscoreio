$ = require 'jquery'

# string -> { browser: string, version: string }
uaMatch = (ua) ->
  ua = ua.toLowerCase()

  match = /(chrome)[ \/]([\w.]+)/.exec( ua ) ||
    /(webkit)[ \/]([\w.]+)/.exec( ua ) ||
    /(opera)(?:.*version|)[ \/]([\w.]+)/.exec( ua ) ||
    /(msie) ([\w.]+)/.exec( ua ) ||
    ua.indexOf("compatible") < 0 && /(mozilla)(?:.*? rv:([\w.]+)|)/.exec( ua ) ||
    []

  return {
    browser: match[ 1 ] || ""
    version: match[ 2 ] || "0"
  }

# -> { browser: string, version: string }
get = ->
  # Don't clobber any existing jQuery.browser in case it's different
  if $.browser?
    $.browser
  else
    matched = uaMatch( navigator.userAgent )
    browser = {}

    if matched.browser
      browser[ matched.browser ] = true
      browser.version = matched.version

    # Chrome is Webkit, but Webkit is also Safari.
    if browser.chrome
      browser.webkit = true
    else if browser.webkit
      browser.safari = true

    browser

isIE10 = ->
  ua = get()
  ua.msie && /^10/.test(ua.version)

module.exports = {
  get
  isIE10
}
