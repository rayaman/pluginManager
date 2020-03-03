plugin.OnLoaded(function()
	print(PLUGIN_NAME.." has been loaded!")
	local epic = plugin.getPluginRef("testPlugin1")
	epic.newPerson("Ryan",22,"male")
	print(epic.getName())
	local list = plugin.getPluginList()
	for i,v in pairs(list) do
		print(i,v)
	end
	if plugin.fileExists("test.dat") then
		print("File contents Start:")
		local file = plugin.openFile("test.dat")
		io.write(file:getData())
		io.write("File contents End\n")
	else
		print("no has")
		local file = plugin.openFreshFile("test.dat")
		file:tackE("Test1\n")
		file:tackE("Test2\n")
		file:tackE("Test3\n")
		file:tofile()
	end
end)
