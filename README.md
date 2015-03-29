# atom-tree-view

Provides a configurable view for arbitrary tree lists.

### Usage

In package.json:
```json
"dependencies": {
  "atom-tree-view": "git://github.com/redefiance/atom-tree-view.git"
}
```

In .coffee:
```coffee
{TreeItem, TreeView} = require 'atom-tree-view'

item1 = new TreeItem('this is a top-level entry', 'icon-file-directory')
item2 = new TreeItem('another top-level entry without icon')
subitem1 = new TreeItem('this is a lower-level entry', 'icon-file-submodule')
subitem1.confirm = ->
  subitem1.destroy()
  console.log('selected and removed subitem!')

view = new TreeView
view.addItem item1
view.addItem item2
item1.addItem subitem1
```
