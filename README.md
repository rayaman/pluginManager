# pluginManager version 1.0.0
The plugin manager was created to allow a simple way to add plugin suppoer to your lua code.
Each plugin runs in its own enviroment and suppotes limited communication between plugins.

A lua rock module is in the works!

For now you can install by copying the pluginManager folder to where you want and set your path up.
This library requires the multi and the bin library which can be installed using luarocks
```
luarocks install multi
lucrocks install bin
```

# Usage
Main.lua
```lua
package.path = "./?/init.lua;"..package.path
local plugin = require("pluginManager") -- load the plugin manager
local multi = require("multi") -- loads the multi tasking library
plugin.setPluginFolder("-Plugin-") -- Creates if does not exist and sets the plugin folder where plugins will be loaded
plugin.setProtection(true) -- Defaults to true, if true all plugins are loaded using pcall
plugin.expose("std") -- string or table, std allows all non dangerious features to work. "*" imports all and a table can also be used to select certain items. expose can be used more that once. The second argument allows for the golbal table to be used in read only mode
plugin.expose({ -- expose custom modules and other features to the global namespace of each plugin
	multi = multi,
})
-- "*" allows you to use _G as the enviroment
-- setting readonly, the second argument to true makes plugins able to read from global, but not write to it.
-- you can use a table instead of a string and put the name spaces directly that you want
--[[
	plugin.expose({
		io = {io.tmpfile,io.write},
		os = {os.clock,os.date,os.difftime,os.exit,os.getenv,os.remove,os.rename,os.setlocale,os.time,os.tmpname},
	},readonly) -- if readonly is true, each plugin is exposed a reference to the main _G table, but in readonly form. They will not be able to modify it!
]]
plugin.grant("testPlugin1.lua",{ -- expost certain modules or features to a specific plugin
	require = require
})
plugin.load() -- loads plugins
print("Done loading...")
multi:newTLoop(function()
--~ 	plugin.reloadPlugins() -- this is in the works, but right now I am having som issues with completely clean reloading of plugins. Should be done by the next update
end,1)
multi:mainloop()
```

testPlugin1.lua
```lua
plugin.init("PluginEpic") -- creates a folder that the plug in can use for saving data, and sets up certain data so some plug-in functions can work
plugin.OnPreload(function()
	canRun = plugin.request("require",true)
	if not canRun then return nil,"Missing features that are required for this plugin to work!" end
	local self = plugin.expose() -- exposes this plugins namespace that is public between all plugins
    -- below we will create an object that the next plugin will be able to use!
	self.name = ""
	self.age = 0
	self.gender = ""
	plugin.register("newPerson",function(name,age,gender) -- you can also create them directly on the 'self' variable that was exposed as well. I just like the module.method format.
		self.name = name
		self.age = age
		self.gender = gender
	end)
	plugin.register("getName",function()
		return self.name
	end)
	plugin.register("getAge",function()
		return self.age
	end)
	plugin.register("getGender",function()
		return self.gender
	end)
end)

plugin.OnLoaded(function() -- called when all plug-ins have been loaded
	print(PLUGIN_NAME.." has been loaded!") -- This connection is also the connection that you would use when trying to interact with other plugin's features
end)
```

testPlugin2.lua
```lua
-- plugin.init("superPlugin") -- if you do not init a plugin it gets auto inti with the filename as the plugins name
plugin.OnLoaded(function()
	print(PLUGIN_NAME.." has been loaded!")
	local epic = plugin.getPluginRef("PluginEpic") -- get the plugin's PluginEpic object that we created
	epic.newPerson("Ryan",22,"male")
	print(epic.getName()) -- and there we go it works!
	local list = plugin.getPluginList() -- you can also grab a list of plugins using this
end)
```
# TODO
- Add plugin reloading
- Add luarock install
- Add plugin signing so you can have trusted plugins
- Allow plugin.grant to use plugin names as well
- Add a special folder in which plugins can require from.
- Think of new features to add


# Reference
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