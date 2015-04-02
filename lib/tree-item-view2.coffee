{$, View} = require 'atom-space-pen-views'

module.exports =
class TreeItemView2 extends View
  @content: ->
    @li class: 'entry list-item', =>
      @div outlet: 'header', class: 'header list-item', =>
        @span outlet: 'name', class: 'name icon'
      @ol outlet: 'entries', class: 'list-tree'

  initialize: (item)->
    if typeof(item.content) is 'string'
      @name.text item.content
    else
      @name.append item.content

    @name.addClass item.icon if item.icon?

    item.emitter.on 'destroyed', => @remove()
    item.emitter.on 'itemAdded', (item)=>
      @removeClass 'list-item'
      @addClass 'list-nested-item'
      @entries.append new TreeItemView2 item
      @expand()
    item.emitter.on 'itemRemoved', =>
      if item.children.length == 0
        @addClass 'list-item'
        @removeClass 'list-nested-item'

  toggleExpansion: ->
    if @isExpanded then @collapse() else @expand()

  expand: ->
    @isExpanded = true
    # @addClass 'expanded'
    @removeClass 'collapsed'

  collapse: ->
    @isExpanded = false
    # @removeClass 'expanded'
    @addClass 'collapsed'
