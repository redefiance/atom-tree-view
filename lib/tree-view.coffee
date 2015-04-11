{$, View} = require 'space-pen'
TreeItem = require './tree-item'

module.exports =
class TreeView extends View
  @content: ->
    @ol class: 'list-tree has-collapsable-children focusable-panel', tabindex: -1

  initialize: ->
    @css
      'padding-left':         '10px'
      'user-select':          'none'
      '-moz-user-select':     'none'
      '-khtml-user-select':   'none'
      '-webkit-user-select':  'none'

    atom.commands.add @element,
      'core:move-left':  => @collapse()
      'core:move-right': => @expand()
      'core:move-down':  => @moveDown()
      'core:move-up':    => @moveUp()
      'core:page-down':  => @pageDown()
      'core:page-up':    => @pageUp()
      'core:confirm':    => @confirm()

    @on 'focus', => @select()
    @on 'blur',  => setTimeout (=> @deselect() unless @is ':focus'), 0
    @on 'click', '.entry', (e)=> @clickedOnEntry(e)

  addItem: (item)->
    @append item
    @select()

  clickedOnEntry: (e)->
    e.stopImmediatePropagation()
    item = $(e.target).view()
    @select item
    handleClicked = e.pageX - item.find('.header').position().left <= 15
    return item.toggleExpansion() if handleClicked
    @confirm()

  select: (item)->
    if item is undefined
      return if @selected?
      first = @find('.entry').first().view()
      if first then @select first
      return
    @deselect()
    @selected = item
    @selected.select()
    @scrollTo @selected.header

  deselect: ->
    @selected?.deselect()
    @selected = null

  confirm: ->
    return unless @selected
    @selected.confirm()

  scrollTo: (dom)->
    scroller = @offsetParent()
    top = dom.position().top
    bot = scroller.height() - top - dom.outerHeight()
    amount = 0
    if bot < 0
      amount -= bot
      top -= amount
    if top < 0
      amount += top
    scroller.scrollTop scroller.scrollTop() + amount

  collapse: ->
    return unless @selected
    if @selected.is('.expanded')
      @selected.collapse()
    else
      prev = @selected.parents('.entry').first()
      @select prev.view() if prev[0]

  expand: ->
    return unless @selected
    @selected.expand()

  moveDown: ->
    return unless @selected
    if @selected.is '.expanded'
      return @select @selected.subItems()[0]
    e = @selected
    next = null
    while e and not next
      next = e.nextItem()
      e = e.parentItem()
    @select next

  moveUp: ->
    return unless @selected
    prev = @selected.prevItem()
    return @select @selected.parentItem() unless prev
    while prev.is '.expanded'
      sub = prev.subItems()
      prev = sub[sub.length-1]
    @select prev

  alignTop: ->
    return unless @selected
    scroller = @offsetParent()
    scroller.scrollTop scroller.scrollTop() + @selected.position().top

  pageDown: ->
    next = @selected?.nextItem()
    return unless next
    if @selected.swap? next
      @selected.insertAfter next
    else
      @select next
      @alignTop()

  pageUp: ->
    prev = @selected?.prevItem()
    return unless prev
    if @selected.swap? prev
      @selected.insertBefore prev
    else
      @select prev
      @alignTop()
