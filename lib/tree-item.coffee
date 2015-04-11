{$, View} = require 'space-pen'
{Emitter} = require 'atom'

module.exports =
class TreeEntryView extends View
  ## public
  onConfirm:  (f)=> @events.on 'confirmed',  f.bind @
  onSelect:   (f)=> @events.on 'selected',   f.bind @
  onDeselect: (f)=> @events.on 'deselected', f.bind @
  onRemove:   (f)=> @events.on 'removed',    f.bind @

  remove: ->
    super()
    @events.emit 'removed'

  toggleExpansion: ->
    return @collapse() if @is '.expanded'
    return @expand() if @is '.collapsed'

  expand: ->
    @addClass 'expanded'
    @removeClass 'collapsed'

  collapse: ->
    @addClass 'collapsed'
    @removeClass 'expanded'

  addEntry: (entry)->
    @list.append entry
    unless @is 'list-nested-item'
      @removeClass 'list-item'
      @addClass 'list-nested-item'
      @expand()
    entry.onRemove => unless @list.find('.entry')[0]
      @removeClass 'list-nested-item collapsed expanded'
      @addClass 'list-item'

  ## private
  @content: ->
    @li class: 'entry list-item', =>
      @div outlet: 'header', class: 'header list-item', =>
        @span outlet: 'name', class: 'name icon'
      @ol outlet: 'list', class: 'list-tree'

  initialize: (name, icon)->
    @name.text name
    @name.addClass icon if icon
    @events = new Emitter

  confirm: =>
    @toggleExpansion()
    @events.emit 'confirmed'

  select: =>
    @addClass 'selected'
    @events.emit 'selected'

  deselect: =>
    @removeClass 'selected'
    @events.emit 'deselected'
