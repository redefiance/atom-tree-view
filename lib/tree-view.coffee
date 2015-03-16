createEntries = ->
  entries = []
  addEntry = (arr, depth)->
    entry =
      title: Math.random()
      icon: 'icon-file-directory'
    n = Math.floor(Math.random() * 3)
    if n > 0 and depth < 4
      entry.children = []
      for i in [1..n]
        addEntry(entry.children, depth+1)
    arr.push entry
  for i in [1..3]
    addEntry(entries, 0)
  entries

{$, View} = require 'atom-space-pen-views'
TreeItemView = require './tree-item-view'

module.exports =
class TreeView extends View
  @content: ->
    @div =>
      @ol class: 'full-menu list-tree has-collapsable-children focusable-panel', tabindex: -1, outlet: 'list'

  initialize: ->
    @on 'click', '.entry', (e) => @entryClicked(e)

    atom.commands.add @element,
     'core:move-up': => @moveUp()
     'core:move-down': => @moveDown()
     'core:move-left': => @collapseEntry()
     'core:move-right': => @expandEntry()
     'core:page-up': => @pageUp()
     'core:page-down': => @pageDown()
     'tool-panel:unfocus': => @unfocus()

    for entry in createEntries()
      view = new TreeItemView
      view.initialize(entry)
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
    if $(entry).is('.list-nested-item')
      entry.toggleExpansion()
    false

  selectEntry: (entry) ->
    return unless entry?
    @list.find('.selected').removeClass 'selected'
    entry.classList.add('selected')

    displayElement = $(entry.header)

    top = displayElement.position().top
    bottom = top + displayElement.outerHeight()

    scroller = @list.parentsUntil(@list.offsetParent()).last()

    if bottom > scroller.scrollBottom()
      scroller.scrollBottom(bottom)
    if top < scroller.scrollTop()
      scroller.scrollTop(top)
