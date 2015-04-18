{$, $$, View} = require 'space-pen'
{Emitter} = require 'atom'

module.exports =
class TreeItem extends View
  @content: ->
    @li class: 'entry list-item', =>
      @div outlet: 'header', class: 'header list-item'

  initialize: (@id, iconOrDOM)->
    if typeof(iconOrDOM) is 'object'
      @header.append idOrDOM
    else
      label = $$ -> @span id
      label.addClass 'icon '+iconOrDOM if iconOrDOM
      @header.append label
    @events = new Emitter

  ###
  Events
  ###

  onConfirm:  (f)-> @events.on 'confirmed',  f.bind @
  onSelect:   (f)-> @events.on 'selected',   f.bind @
  onDeselect: (f)-> @events.on 'deselected', f.bind @
  onRemove:   (f)-> @events.on 'removed',    f.bind @

  ###
  Interaction
  ###

  confirm: =>
    @toggleExpansion()
    @events.emit 'confirmed'

  select: =>
    @addClass 'selected'
    @events.emit 'selected'

  deselect: =>
    @removeClass 'selected'
    @events.emit 'deselected'

  remove: ->
    super()
    @events.emit 'removed'

  ###
  Subitems
  ###

  addItem: (item)->
    unless @list?
      @list = $$ -> @ol class: 'list-tree'
      @list.items = {}
      @append @list
      @removeClass 'list-item'
      @addClass 'list-nested-item'
      @addClass 'collapsed' unless @isExpanded()
    @list.items[item.id] = item
    @list.append item
    item.onRemove =>
      delete @list.items[item.id]
      if @subItems().length == 0
        @list.remove()
        @list = undefined
        @removeClass 'list-nested-item'
        @addClass 'list-item'

  getItem: (id)->
    @list?.items[id]

  ###
  Expansion state
  ###

  isExpanded: ->
    @list? and @is '.expanded'

  toggleExpansion: ->
    if @isExpanded() then @collapse() else @expand()

  expand: (recursive)->
    @addClass 'expanded'
    @removeClass 'collapsed'
    if recursive
      parentItem().expand(true)

  collapse: (recursive)->
    @addClass 'collapsed'
    @removeClass 'expanded'
    if recursive
      item.collapse(true) for item in @subItems()

  ###
  TreeView navigation
  ###

  parentItem: ->
    @parents('.entry:first').view()

  subItems: ->
    $(e).view() for e in @list.children('.entry')

  prevItem: ->
    @prev('.entry').view()

  nextItem: ->
    @next('.entry').view()
