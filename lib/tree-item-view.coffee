class TreeItemView extends HTMLElement
  initialize: (@item) ->
    @classList.add 'entry'

    @header = document.createElement 'div'
    @appendChild @header
    @header.classList.add 'header', 'list-item'

    @name = document.createElement 'span'
    @header.appendChild @name
    @name.classList.add 'name', 'icon'

    @entries = document.createElement 'ol'
    @appendChild @entries
    @entries.classList.add 'entries', 'list-tree'

    @name.classList.add item.icon  if item.icon?
    if typeof(item.content) is 'string'
      @name.textContent = item.content
    else
      @name.appendChild item.content

    @classList.add 'list-item'

    item.emitter.on 'destroyed', => @remove()

    item.emitter.on 'itemAdded', (item) =>
      @classList.remove 'list-item'
      @classList.add 'list-nested-item'
      view = new TreeItemElement()
      view.initialize item
      @entries.appendChild view
      @expand()

    item.emitter.on 'itemRemoved', =>
      if item.children.length == 0
        @classList.remove 'list-nested-item'
        @classList.add 'list-item'

  toggleExpansion: ->
    if @isExpanded then @collapse() else @expand()

  expand: ->
    @isExpanded = true
    @classList.add 'expanded'
    @classList.remove 'collapsed'

  collapse: ->
    @isExpanded = false
    @classList.remove 'expanded'
    @classList.add 'collapsed'

module.exports = TreeItemElement = document.registerElement 'tree-item-view', prototype: TreeItemView.prototype, extends: 'li'
