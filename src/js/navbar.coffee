$         = require 'jquery'
scrollSpy = require './scrollspy'

# Mobile navbar expand/contract:
init = ->
  $(".navbar-toggle").click (evt) ->
    evt.preventDefault()
    evt.stopPropagation()
    $(this).parents(".navbar").toggleClass("navbar-expanded")
    return

  autohideNavbar = $(".navbar-fixed")

  uio.scrollSpy.register ".hero", (position) ->
    if position == "below"
      autohideNavbar.addClass("active")
    else
      autohideNavbar.removeClass("active navbar-expanded")
    return

module.exports = {
  init
}
