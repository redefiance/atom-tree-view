{$, View} = require 'space-pen'
TreeEntryView = require './tree-entry-view'

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

    @on 'click', '.entry', (e)=>
      @select $(e.target).view()
      @confirm()

  addEntry: (entry)->
    @append entry
    @select entry unless @selected?

  confirm: ->
    return @collapse() if @selected.is('.expanded')
    return @expand() if @selected.is('.collapsed')
    @selected.confirm()

  select: (entry)->
    @deselect()
    @selected = entry
    @selected.addClass 'selected'
    @scrollTo @selected.header

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

  deselect: ->
    @selected?.removeClass 'selected'
    @selected = null

  collapse: ->
    if @selected.is('.expanded')
      @selected.collapse()
    else
      prev = @selected.parents('.entry').first()
      @select prev.view() if prev[0]

  expand: ->
    @selected.expand()

  moveDown: ->
    if @selected.is '.expanded'
      return @select @selected.find('.entry').first().view()
    sel = @selected
    next = sel.next('.entry')
    while not next[0]
      sel = sel.parents('.entry').first()
      return unless sel[0]
      next = sel.next('.entry')
    @select next.view()

  moveUp: ->
    prev = @selected.prev('.entry')
    if prev[0]
      if prev.is '.expanded'
        @select prev.find('.entry').last().view()
      else
        @select prev.view()
    else
      prev = @selected.parents('.entry').first()
      return @select prev.view() if prev[0]

  postPage: ->
    scroller = @offsetParent()
    scroller.scrollTop scroller.scrollTop() + @selected.position().top

  pageDown: ->
    next = @selected.next('.entry')
    if next[0]
      @select next.view()
      @postPage()

  pageUp: ->
    prev = @selected.prev('.entry')
    if prev[0]
      @select prev.view()
      @postPage()
