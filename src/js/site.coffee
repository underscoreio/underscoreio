retina          = require 'retina.js/src/retina'
svg4everybody   = require 'svg4everybody'
$               = require 'jquery'
ua              = require './ua'
navbar          = require './navbar'

retina.Retina.init(window)

appendIE10Stylesheet = ->
  # HACK: Detect IE 10:
  if ua.isIE10()
    $("<link>").attr({ rel: "stylesheet", href: "/css/ie10.css" }).appendTo("head")
  return


$ ->
  appendIE10Stylesheet()
  navbar.init()
  return

window.uio = module.exports = {
  $
  navbar
  scrollSpy       : require './scrollspy'
  blogPager       : require './blog-pager'
  trainingFormats : require './training-formats'
  eventListing    : require './event-listing'
  courseDirectory : require './training-course-directory'
  bookingForm     : require './booking-form'
  contactForm     : require './contact-form'
}
