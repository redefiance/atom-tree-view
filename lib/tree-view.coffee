{$, View} = require 'atom-space-pen-views'
TreeItemView = require './tree-item-view'

module.exports =
class TreeView extends View
  @content: ->
    @div =>
      @ol tabindex: -1, outlet: 'list'

  initialize: ->
    @list.addClass 'list-tree has-collapsable-children focusable-panel'
    @list.css
      'padding-left': '10px'
      'user-select': 'none'
      '-moz-user-select': 'none'
      '-khtml-user-select': 'none'
      '-webkit-user-select': 'none'

    @on 'click', '.entry', (e) => @entryClicked(e)

    atom.commands.add @element,
     'core:move-up': => @moveUp()
     'core:move-down': => @moveDown()
     'core:move-left': => @collapseEntry()
     'core:move-right': => @expandEntry()
     'core:page-up': => @pageUp()
     'core:page-down': => @pageDown()
     'core:confirm': => @confirm()
     'tool-panel:unfocus': => @unfocus()

  addItem: (item)->
    view = new TreeItemView
    view.initialize(item)
    @list[0].appendChild view

  focus: ->
    @list.focus()

  unfocus: ->
    atom.workspace.getActivePane().activate()

  moveDown: ->
    current = @list.find('.selected')

    if not current?
      return @selectEntry list.find('.entry')?[0]

    if current.is('.expanded')
      return @selectEntry current.find('.entry')[0]

    next = current.next('.entry')
    while current?[0] and not next?[0]
      current = current.parents('.entry').first()
      next = current.next('.entry')
    @selectEntry next[0] if next[0]?

  moveUp: ->
    current = @list.find('.selected')

    if not current?
      return @selectEntry list.find('.entry').last()?[0]

    prev = current.prev('.entry')
    if not prev?[0]
      return @selectEntry current.parents('.entry').first()?[0]

    if prev.is('.expanded')
      return @selectEntry prev.find('.entry:not(:hidden)').last()[0]

    @selectEntry prev[0]

  pageUp: ->
    current = @list.find('.selected')
    @selectEntry current.prev('.entry')[0]

  pageDown: ->
    current = @list.find('.selected')
    @selectEntry current.next('.entry')[0]

  expandEntry: ->
    @list.find('.selected.list-nested-item.collapsed')[0]?.expand()

  confirm: ->
    selected = $('.selected')
    selected[0].toggleExpansion() if selected.is('.list-nested-item')
    selected[0].item.confirm?()

  collapseEntry: ->
    selected = @list.find('.selected')
    if selected.is('.list-nested-item.expanded')
      selected[0].collapse()
    else
      header = selected.parents('.list-nested-item.expanded').first()[0]
      header?.collapse()
      @selectEntry header if header?

  entryClicked: (e) ->
    entry = e.currentTarget
    @selectEntry(entry)
    @confirm()
    false

  selectEntry: (entry) ->
    return unless entry?
    @list.find('.selected').removeClass 'selected'
    entry.classList.add('selected')
    @scrollTo entry

  scrollTo: (entry)->
    displayElement = $(entry.header)
    scroller = @list.offsetParent()

    top = displayElement.position().top + scroller.scrollTop()
    if top < scroller.scrollTop()
      scroller.scrollTop top

    bot = top + displayElement.outerHeight()
    if bot > scroller.scrollBottom()
      scroller.scrollTop bot-scroller.height()
