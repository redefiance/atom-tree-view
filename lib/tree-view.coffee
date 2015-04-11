{$, View} = require 'space-pen'
TreeEntryView = require './tree-item'

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

    @on 'focus', =>
      @select()

    @on 'click', '.entry', (e)=>
      e.stopImmediatePropagation()
      entry = $(e.target).view()
      @select entry
      clickedHandle = e.pageX - entry.find('.header').position().left <= 15
      return entry.toggleExpansion() if clickedHandle
      @confirm()

  addEntry: (entry)->
    @append entry
    @select()

  select: (entry)->
    if not entry and @selected then return
    if not entry then entry = @find('.entry').first().view()
    if not entry then return
    @selected?.deselect()
    entry.select()
    @selected = entry
    @scrollTo @selected.header

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
      return @select @selected.find('.entry').first().view()
    sel = @selected
    next = sel.next('.entry')
    while not next[0]
      sel = sel.parents('.entry').first()
      return unless sel[0]
      next = sel.next('.entry')
    @select next.view()

  moveUp: ->
    return unless @selected
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
    return unless @selected
    scroller = @offsetParent()
    scroller.scrollTop scroller.scrollTop() + @selected.position().top

  pageDown: ->
    return unless @selected
    next = @selected.next('.entry')
    if next[0]
      if @selected.swap?(next)
        @selected.insertAfter next
      else
        @select next.view()
      @postPage()

  pageUp: ->
    return unless @selected
    prev = @selected.prev('.entry')
    if prev[0]
      if @selected.swap?(prev)
        @selected.insertBefore prev
      else
        @select prev.view()
      @postPage()
