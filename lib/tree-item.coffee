{$, View} = require 'space-pen'
{Emitter} = require 'atom'

module.exports =
class TreeItem extends View
  @content: ->
    @li class: 'entry list-item', =>
      @div outlet: 'header', class: 'header list-item', =>
        @span outlet: 'label', class: 'icon'
      @ol outlet: 'list', class: 'list-tree'

  initialize: (name, icon)->
    @label.text     name
    @label.addClass icon if icon

    @events = new Emitter

  #
  # Events
  #

  onConfirm:  (f)-> @events.on 'confirmed',  f.bind @
  onSelect:   (f)-> @events.on 'selected',   f.bind @
  onDeselect: (f)-> @events.on 'deselected', f.bind @
  onRemove:   (f)-> @events.on 'removed',    f.bind @

  #
  # Interaction
  #

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

  #
  # Subitems
  #

  addItem: (item)->
    @list.append item
    unless @is '.list-nested-item'
      @removeClass 'list-item'
      @addClass 'list-nested-item'
      @addClass 'collapsed' unless @is '.expanded'
    item.onRemove => if @subItems().length == 0
      @removeClass 'list-nested-item collapsed expanded'
      @addClass 'list-item'

  #
  # Expansion state
  #

  toggleExpansion: ->
    return @collapse() if @is '.expanded'
    return @expand()   if @is '.collapsed'

  expand: ->
    @addClass 'expanded'
    @removeClass 'collapsed'

  collapse: ->
    @addClass 'collapsed'
    @removeClass 'expanded'
  #
  # TreeView navigation
  #

  parentItem: ->
    @parents('.entry:first').view()

  subItems: ->
    $(e).view() for e in @list.children('.entry')

  prevItem: ->
    @prev('.entry').view()

  nextItem: ->
    @next('.entry').view()
