{$, View} = require 'space-pen'
TreeItem = require './tree-item'

module.exports =
class TreeView extends View
  @content: ->
    @ol tabindex: -1, class: 'tree-view list-tree '+
      'has-collapsable-children focusable-panel'

  initialize: ->
    @items = {}

    @css
      'padding-left':         '10px'
      'user-select':          'none'
      '-moz-user-select':     'none'
      '-khtml-user-select':   'none'
      '-webkit-user-select':  'none'

    atom.commands.add @element,
      'core:move-down':  => @moveDown()
      'core:move-up':    => @moveUp()
      'core:page-down':  => @pageDown()
      'core:page-up':    => @pageUp()
      'core:confirm':    => @confirm()
      'tree-view:collapse-directory': => @collapse()
      'tree-view:expand-directory':   => @expand()

    @on 'click', '.entry', (e)=> @clickedOnEntry(e)

  ###
  Events
  ###

  # None, apparently

  ###
  Items
  ###

  addItem: (item)->
    @append item
    @items[item.id] = item
    item.onRemove => delete @items[item.id]
    @select()

  getItem: (idOrPath)->
    if typeof(idOrPath) is 'array'
      it = @
      it = it?.getItem id for id in idOrPath
      it
    else
      @items[idOrPath]

  createItems: (path, creator)->
    it = @
    for id, i in path
      e = it.getItem id
      unless e?
        e = creator i, id
        it.addItem e
      it = e

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
  Expansion State
  ###

  expand: ->
    return unless @selected
    if @selected.isExpanded()
      @select @selected.subItems()[0]
    else
      @selected.expand()

  collapse: ->
    return unless @selected
    if @selected.isExpanded()
      @selected.collapse()
    else
      prev = @selected.parents('.entry').first()
      @select prev.view() if prev[0]

  ###
  Navigation
  ###

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

  scrollTo: (item)->
    top = item.position().top
    bot = top + item.outerHeight()

    p = @offsetParent()
    if bot > p.scrollBottom()
      p.scrollBottom bot
    if top < p.scrollTop()
      p.scrollTop top

  alignTop: ->
    return unless @selected
    scroller = @offsetParent()
    scroller.scrollTop scroller.scrollTop() + @selected.position().top
