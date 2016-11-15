_ = require 'underscore'

values = (name) ->
  search = window.location.search

  unless search then return []

  if search[0] == '?'
    search = search.substring(1)

  _.chain(search.split("&")).
    map((item) -> item.split("=")).
    filter((item) -> item[0] == name).
    map((item) -> decodeURIComponent(item[1])).
    value()

module.exports = {
  values
}
