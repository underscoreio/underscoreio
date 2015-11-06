retina          = require 'retina.js/src/retina'
svg4everybody   = require 'svg4everybody'
$               = require 'jquery'
ua              = require './ua'
navbar          = require './navbar'
currencies      = require './currencies'

retina.Retina.init(window)

appendIE10Stylesheet = ->
  # HACK: Detect IE 10:
  if ua.isIE10()
    $("<link>").attr({ rel: "stylesheet", href: "/css/ie10.css" }).appendTo("head")
  return


$ ->
  appendIE10Stylesheet()
  navbar.init()
  currencies.init()
  return

window.uio = module.exports = {
  $
  navbar
  currencies
  scrollSpy       : require './scrollspy'
  blogPager       : require './blog-pager'
  trainingFormats : require './training-formats'
  eventListing    : require './event-listing'
  jobSidebar      : require './job-sidebar'
  jobListing      : require './job-listing'
  courseDirectory : require './training-course-directory'
  bookingForm     : require './booking-form'
  contactForm     : require './contact-form'
}
