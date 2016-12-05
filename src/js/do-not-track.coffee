_ = require 'underscore'

# If the browser has "Do Not Track" set,
# ga("send", "event", ...) never calls our hitCallback function.
#
# We test window.ga.loaded to check whetner DNT is enabled,
# and bypass Google Analytics if it is.
sendGaEvent = (category, action, label = undefined, hitCallback = (->)) ->
  if window.ga?.loaded
    window.ga('send', 'event', category, action, label, { hitCallback })
  else
    hitCallback()

module.exports = {
  sendGaEvent
}
