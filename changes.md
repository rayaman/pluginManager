# Version 1.0.0

Reference
---
**Note:** There are two versions of the "plugin" namespace. One that is exposed to the main code that loads the plugins and another that is exposed to each loaded plugin.

Main plugin(namespace exposed by host):
---
**plugin.version** -- The version of the library

**plugin.setPluginFolder(path)** -- Sets the path that plugins should be located

**plugin.setProtection(set)** -- Defaults to true, if true all plugins are loaded in pcall

**plugin.expose(table or string)** -- Exposes modules or features that plugins are allowed to use

**plugin.load()** -- loads plugins

**plugin.grant(path, table)** -- exposes features to a certain plugin

Plugins plugin(namespace Exposed to plugins):
---
**plugin.version** -- The version of the library

**plugin.OnLoaded(func)** -- A connection that can be bound to inside of a plugin that is triggered when all plugins have been loaded

**plugin.OnPreload(func)** -- A connection that can be bound to inside of a plugin that is triggered when each plugin is loaded

**plugin.OnReboot(func)** -- Not yet implemented, but when it is, this will allos plugins to be able to clean up garbage that they create and handle being reloaded

**plugin.init(name,version)** -- Sets the plugins name and an option to set its version when exposing an object to other plugins to use

**plugin.requeat(feature/module,cry)** -- returns true if the plugin has access to these features in it global space, false otherwise. If cry is set to true then a message of what is lacking is printed on the console

**plugin.fileExists(path)** -- Returns true if a plugin exists

**plugin.openFreshFile(path)** -- Opens a fresh streamed file. This uses the bin library so refer to it for working with these. All files are written to in seperate folders that are the same as the plugins name.

**plugin.openFile(path)** -- Opens a file in stream mode, where data is kept from the last session

**plugin.deleteFile(path)** -- Delets a file

**plugin.setGlobal(name,value)** -- sets a global value that all plugins can see as long as they use getGlobal()

**plugin.getGlobal(name)** -- returns a global value

**plugin.getPluginList()** -- returns a list of all loaded plugins

**plugin.getPluginRef(name)** -- returns a readnly reference to a plugins exposed namespace

**plugin.register(name,value)** -- registers an element to the plugins exposed namespace

**plugin.expose()** -- returns a reference to the current plugins exposed namespace, what other plugins can see

**plugin.getName()** -- returns the name of the current plugin