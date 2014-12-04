$         = require 'jquery'
scrollSpy = require './scrollspy'

# Mobile navbar expand/contract:
init = ->
  $(".navbar-toggle").click (evt) ->
    evt.preventDefault()
    evt.stopPropagation()
    $(this).parents(".navbar").toggleClass("navbar-expanded")
    return

  $("html").click (evt) ->
    if $(evt.target).parents(".navbar").length == 0
      $(".navbar").removeClass("navbar-expanded")
      return
    return

  fixedNavbar = $(".navbar-fixed")

  uio.scrollSpy.register ".hero", (position, direction) ->
    if position == "below" # and direction == "up"
      fixedNavbar.addClass("active")
    else
      fixedNavbar.removeClass("active navbar-expanded")
    return

module.exports = {
  init
}
