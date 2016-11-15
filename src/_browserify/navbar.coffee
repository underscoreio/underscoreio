$         = require 'jquery'
scrollSpy = require './scrollspy'

# Mobile navbar expand/contract:
init = ->
  $(".navbar-toggle").click (evt) ->
    evt.preventDefault()
    evt.stopPropagation()
    $(this).parents(".navbar").find(".navbar-collapse").toggleClass("in")
    return

  $("html").click (evt) ->
    if $(evt.target).parents(".navbar").length == 0
      $(".navbar").removeClass("navbar-expanded")
      return
    return

  fixedNavbar = $(".navbar-fixed-top")

  uio.scrollSpy.register ".hero", (position, direction) ->
    if position == "below" # and direction == "up"
      fixedNavbar.addClass("navbar-visible")
    else
      fixedNavbar.removeClass("navbar-visible")
      fixedNavbar.find(".navbar-collapse").removeClass("in")
    return

module.exports = {
  init
}
