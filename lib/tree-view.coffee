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

    scroller = @offsetParent()
    top = entry.position().top + scroller.scrollTop()
    if top < scroller.scrollTop()
      scroller.scrollTop top
    bot = top + entry.outerHeight()
    if bot > scroller.scrollBottom()
      scroller.scrollTop bot-scroller.height()

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

  pageDown: ->
    next = @selected.next('.entry')
    @select next.view() if next[0]

  pageUp: ->
    prev = @selected.prev('.entry')
    @select prev.view() if prev[0]
