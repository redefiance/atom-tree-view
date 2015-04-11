{$, View} = require 'space-pen'
{Emitter} = require 'atom'

module.exports =
class TreeEntryView extends View
  ## public
  onConfirm:  (f)-> @emitter.on 'confirmed',  => f()
  onSelect:   (f)-> @emitter.on 'selected',   => f()
  onDeselect: (f)-> @emitter.on 'deselected', => f()
  onRemove:   (f)-> @emitter.on 'removed',    => f()

  remove: ->
    super()
    @emitter.emit 'removed'

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
    @emitter = new Emitter

  confirm: ->
    @toggleExpansion()
    @emitter.emit 'confirmed'

  select: ->
    @addClass 'selected'
    @emitter.emit 'selected'

  deselect: ->
    @removeClass 'selected'
    @emitter.emit 'deselected'
