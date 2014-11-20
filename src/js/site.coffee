retina          = require 'retina.js/src/retina'
$               = require 'jquery'
navbar          = require './navbar'

retina.Retina.init(window)

$ ->
  navbar.init()
  return

window.uio = module.exports = {
  $
  navbar
  scrollSpy       : require './scrollspy'
  blogPager       : require './blog-pager'
  trainingFormats : require './training-formats'
  courseDirectory : require './training-course-directory'
  bookingForm     : require './booking-form'
  contactForm     : require './contact-form'
}
