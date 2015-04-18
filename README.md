# atom-tree-view

Easily create a nested tree view in the style of Atoms built-in [TreeView](https://github.com/atom/tree-view).

This package provides two classes:
```coffee
{TreeView, TreeItem} = require 'atom-tree-view'
```

### TreeView
```coffee
constructor: ()->
```
Creates a new `TreeView` which extends from [SpacePen](https://github.com/atom/space-pen) `View`.

```coffee
addItem: (item)->
```
Adds a `TreeItem` as new top-level item. It will be inserted at
the end of the list.

```coffee
getItem: (id)->
# or
getItem: (path)->
```
* `id`: A String that denotes the id of a top-level item.  
* `path`: An Array of Strings that denote the id of an item at
each hierarchy level, starting with a top-level item.  
Returns a `TreeItem` or `undefined` if none is found.

```coffee
createItems: (path, createFunction)->
```
* `path`: An Array of Strings that denote the id of an item at
each hierarchy level, starting with a top-level item.  
* `createFunction`: A function that is called for each item in `path` that does
not yet exist. It takes the id and the hierarchy level (starting at 0) as
parameters and is expected to return a `TreeItem`.

```coffee
select: (item)->
```
Selects a specific `TreeItem`.

### TreeItem
```coffee
constructor: (id)->
# or
constructor: (id, icon)->
# or
constructor: (id, dom)->
```
* `id`: A String that uniquely identifies this TreeItem within a hierarchy layer
of a `TreeView`. It will be used as the text on the item unless `dom` is specified.  
* `icon` [Optional]: A String that describes an icon css class like 'icon-file-directory'.  
* `dom` [Optional]: A DOM node or jQuery wrapper that will be used as the content of this item instead of the regular icon and text.

Creates a new `TreeItem` which extends from [SpacePen](https://github.com/atom/space-pen) `View`.

```coffee
onConfirm:  (f)->
onSelect:   (f)->
onDeselect: (f)->
onRemove:   (f)->
```
Adds the callback function f to various events. `@` is bound to the instance of `TreeItem`.  
`onConfirm` is triggered when the item was clicked twice or the enter key is hit.  
`onSelect` is triggered when the item was selected.  
`onDeselect` is triggered when the item was deselected.  
`onRemove` is triggered when `remove()` was called.

```coffee
addItem: (item)->
```
Adds a `TreeItem` as a subitem of this item. It will be inserted at
the end of the list.

```coffee
getItem: (id)->
```
* `id`: A String that denotes the id of a subitem.  
Returns a `TreeItem` or `undefined` if none is found.

```coffee
isExpanded: ()->
```
Returns true if this item has subitems and is expanded. `TreeItem` will default to being collapsed unless `expand()` is called.

```coffee
expand: (recursive = false)->
```
* `recursive`: If true, all parent items will be expanded as well, so this item is guaranteed to be visible.

```coffee
collapse: (recursive = false)->
```
* `recursive`: If true, all subitems (recursively) will be collapsed as well.
