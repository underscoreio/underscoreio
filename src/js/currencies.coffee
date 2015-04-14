_       = require 'underscore'
$       = require 'jquery'
storage = require './storage'

# Selector used below:
$.expr[':'].parents = (a,i,m) ->
  jQuery(a).parents(m[3]).length > 0

VALID_CURRENCIES = [ 'usd', 'gbp' ,'eur' ]

get = ->
  console.log('get')
  storage.get('Currency', 'usd')

set = (id) ->
  console.log('set', id)
  if _.contains(VALID_CURRENCIES, id)
    storage.set('Currency', id)
    $("body")
      .removeClass(_.map(VALID_CURRENCIES, (cur) -> "selected-currency-#{cur}").join(" "))
      .addClass("selected-currency-#{id}")
    $(".currency").hide()
    $(".currency-#{id}").show()
  return

initCurrency = ->
  set(get())
  return

initPopover = ->
  itemHtml = (cur) ->
    """<li><a href="javascript:void(0)" class="currency-select-#{cur}">#{cur.toUpperCase()}</a></li>"""

  popoverHtml =
    """
    <div class="currencies-popover popover bottom">
      <div class="arrow"></div>
      <div class="popover-content">
        <p>Available in multiple currencies</p>
        <ul>#{_.map(VALID_CURRENCIES, itemHtml).join("")}</ul>
      </div>
    </div>
    """

  body    = $('body')
  popover = $(popoverHtml).appendTo(body)

  _.each VALID_CURRENCIES, (cur) ->
    $(".currency-select-#{cur}").on 'click', (evt) ->
      evt.stopPropagation()
      set(cur)

  $('.currencies').removeClass('currencies-nojs').hover(
    (evt) ->
      self = $(this)
      evt.stopPropagation()
      popover.appendTo(self).addClass('in').css {
        top  : self.height()
        left : self.width()/2 - popover.width()/2 + 5 # padding
      }
      return
    (evt) ->
      popover.removeClass('in')
      return
  )

  return

init = ->
  $ ->
    initCurrency()
    initPopover()
    return
  return

module.exports = {
  set
  init
}
