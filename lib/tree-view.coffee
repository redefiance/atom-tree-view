{$, View} = require 'space-pen'
TreeItem = require './tree-item'

module.exports =
class TreeView extends View
  @content: ->
    @ol tabindex: -1, class: 'tree-view list-tree '+
      'has-collapsable-children focusable-panel'

  initialize: ->
    @css
      'padding-left':         '10px'
      'user-select':          'none'
      '-moz-user-select':     'none'
      '-khtml-user-select':   'none'
      '-webkit-user-select':  'none'

    atom.commands.add @element,
      'core:move-left':  => @moveLeft()
      'core:move-right': => @moveRight()
      'core:move-down':  => @moveDown()
      'core:move-up':    => @moveUp()
      'core:page-down':  => @pageDown()
      'core:page-up':    => @pageUp()
      'core:confirm':    => @confirm()

    @on 'click', '.entry', (e)=> @clickedOnEntry(e)

    @lookup = {}
  ###
  Events
  ###

  # None, apparently

  ###
  Items
  ###

  createItems: (path, creator)->
    it = @
    for name, i in path
      e = it.find(".entry[path='#{name}']").view()
      unless e?
        e = creator i, name
        e.attr 'path': name
        it.addItem e
      it = e

  addItem: (item)->
    @append item
    @select()

  ###
  Interaction
  ###

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

  ###
  Internal
  ###

  clickedOnEntry: (e)->
    e.stopImmediatePropagation()
    item = $(e.currentTarget).view()
    return @select item unless item is @selected

    handleClicked = e.pageX - item.header.position().left <= 15
    return item.toggleExpansion() if handleClicked

    @confirm()

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

  moveLeft: ->
    return unless @selected
    if @selected.isExpanded()
      @selected.collapse()
    else
      prev = @selected.parents('.entry').first()
      @select prev.view() if prev[0]

  moveRight: ->
    return unless @selected
    @selected.expand()

  moveDown: ->
    return unless @selected
    if @selected.isExpanded()
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
    while prev.isExpanded()
      sub = prev.subItems()
      prev = sub[sub.length-1]
    @select prev

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

  alignTop: ->
    return unless @selected
    scroller = @offsetParent()
    scroller.scrollTop scroller.scrollTop() + @selected.position().top
