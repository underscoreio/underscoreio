svg4everybody = require 'svg4everybody'
$             = require 'jquery'
ua            = require './ua'
navbar        = require './navbar'
currencies    = require './currencies'
gaLink        = require './ga-link'

$ ->
  navbar.init()
  currencies.init()
  gaLink.init()
  return

window.uio = module.exports = {
  $
  navbar
  currencies
  scrollSpy         : require './scrollspy'
  trainingformats   : require './training-formats'
  eventListing      : require './event-listing'
  jobListing        : require './job-listing'
  trainingDirectory : require './training-directory'
  bookingForm       : require './booking-form'
  contactForm       : require './contact-form'
}
