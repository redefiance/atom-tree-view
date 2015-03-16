class TreeItemView extends HTMLElement
  initialize: (entry)->
    @classList.add 'entry'

    @header = document.createElement('div')
    @appendChild(@header)
    @header.classList.add('header', 'list-item')

    @name = document.createElement('span')
    @header.appendChild(@name)
    @name.classList.add('name', 'icon')

    @entries = document.createElement('ol')
    @appendChild(@entries)
    @entries.classList.add('entries', 'list-tree')

    @name.classList.add(entry.icon)
    @name.textContent = entry.title

    unless entry.children?
      @classList.add 'list-item'
    else
      @classList.add 'list-nested-item', 'collapsed'
      for child in entry.children
        view = new TreeItemElement()
        view.initialize(child)
        @entries.appendChild(view)
      @expand()

  toggleExpansion: ->
    if @isExpanded then @collapse() else @expand()

  expand: ->
    @isExpanded = true
    @classList.add('expanded')
    @classList.remove('collapsed')

  collapse: ->
    @isExpanded = false
    @classList.remove('expanded')
    @classList.add('collapsed')

module.exports = TreeItemElement = document.registerElement('tree-item-view', prototype: TreeItemView.prototype, extends: 'li')
