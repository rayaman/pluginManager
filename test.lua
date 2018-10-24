package.path = "./?/init.lua;"..package.path
local plugin = require("pluginManager")
local multi = require("multi")
plugin.setPluginFolder("-Plugin-") -- Creates if does not exist and sets the plugin folder where plugins will be loaded
plugin.setProtection(true) -- Defaults to true
plugin.expose("std") -- string or table, std allows all non dangerious features to work. "*" imports all and a table can also be used to select certain items. expose can be used more that once. The second argument allows for the golbal table to be used in read only mode
plugin.expose({
	multi = multi,
})
plugin.grant("testPlugin1.lua",{
	require = require
})
-- "*" allows you to use _G as the enviroment
-- setting readonly, the second argument to true makes plugins able to read from global, but not write to it.
-- you can use a table instead of a string and put the name spaces directly that you want
--[[
	plugin.expose({
		io = {io.tmpfile,io.write},
		os = {os.clock,os.date,os.difftime,os.exit,os.getenv,os.remove,os.rename,os.setlocale,os.time,os.tmpname},
	},readonly)
]]
plugin.load() -- loads plugins
print("Done loading...")
multi:newTLoop(function()
--~ 	plugin.reloadPlugins()
end,1)
multi:mainloop()
