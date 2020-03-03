plugin.OnPreload(function()
	local self = plugin.expose() -- exposes this plugins namespace that is public between all plugins
	self.name = ""
	self.age = 0
	self.gender = ""
	plugin.register("newPerson",function(name,age,gender)
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
	print(PLUGIN_NAME.." has been loaded!")
end)