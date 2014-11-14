$ = require 'jquery'

watching = []

oldPosition = -10000
newPosition = -10000

register = (selector, callback) ->
  elem = $(selector)

  if elem.length == 0 then return

  top    = elem.first().offset().top
  bottom = elem.first().height() + top

  test = (position) ->
    if position < top
      "above"
    else if position > bottom
      "below"
    else
      "inside"

  watching.push({ selector, test, callback })
  return

$(window).on "scroll", ->
  oldPosition = newPosition
  newPosition = $(window).scrollTop()

  for { selector, test, callback } in watching
    oldRel = test(oldPosition)
    newRel = test(newPosition)
    unless newRel == oldRel
      callback(newRel)

module.exports = {
  register
}
