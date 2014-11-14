retina    = require 'retina.js/src/retina'

$         = require 'jquery'
scrollSpy = require './scrollspy'
navbar    = require './navbar'
blogPager = require './blog-pager'

retina.Retina.init(window)

$ ->
  navbar.init()
  return

window.uio = module.exports = {
  $
  scrollSpy
  navbar
  blogPager
}
