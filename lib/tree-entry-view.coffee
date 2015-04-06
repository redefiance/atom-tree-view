{$, View} = require 'space-pen'
{Emitter} = require 'atom'

module.exports =
class TreeEntryView extends View
  @content: ->
    @li class: 'entry list-item', =>
      @div outlet: 'header', class: 'header list-item', =>
        @span outlet: 'name', class: 'name icon'
      @ol outlet: 'list', class: 'list-tree'

  initialize: (@config)->
    @name.text @config.text
    @name.addClass @config.icon if @config.icon?

    @emitter = new Emitter

  addEntry: (entry)->
    @list.append entry
    unless @is('list-nested-item')
      @removeClass 'list-item'
      @addClass 'list-nested-item'
      @expand()

    entry.emitter.on 'destroyed', =>
      unless @list.find('.entry')[0]
        @removeClass 'list-nested-item collapsed expanded'
        @addClass 'list-item'

  destroy: ->
    @emitter.emit 'destroyed'
    @remove()

  confirm: ->
    @config.confirm?()

  expand: ->
    @addClass 'expanded'
    @removeClass 'collapsed'

  collapse: ->
    @addClass 'collapsed'
    @removeClass 'expanded'
