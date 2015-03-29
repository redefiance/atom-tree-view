{$, Emitter} = require 'atom'

module.exports =
class TreeItem

  constructor: (@content, @icon)->
    @emitter = new Emitter

  addItem: (item)->
    @children ?= []
    @children.push item
    item.emitter.on 'destroyed', =>
      @children = $.grep @children, (v)-> v != item
      @emitter.emit 'itemRemoved', item
    @emitter.emit 'itemAdded', item

  destroy: ->
    @emitter.emit 'destroyed'
