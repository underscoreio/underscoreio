$ = require 'jquery'

require 'jquery.cookie'

$.cookie.defaults = { expires: 7, path: '/' }

# string [any] -> any
get = (key, orElse = undefined) ->
  json = $.cookie(key)
  try
    return if json then JSON.parse(json) else orElse
  catch exn
    return orElse

# string -> void
remove = (key) ->
  $.removeCookie(key)
  return

# string any -> void
set = (key, value) ->
  if value == undefined
    remove(key)
  else
    $.cookie(key, JSON.stringify(value))
  return

module.exports = {
  get
  set
  remove
}
