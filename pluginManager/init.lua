local version = "1.0.0"
local bin = require("bin")
local multi = require("multi")
local function merge(t1, t2)
    for k,v in pairs(t2) do
    	if type(v) == 'table' then
    		if type(t1[k] or false) == 'table' then
    			merge(t1[k] or {}, t2[k] or {})
    		else
    			t1[k] = v
    		end
    	else
    		t1[k] = v
    	end
    end
    return t1
end
local function getOS()
	if package.config:sub(1,1)=='\\' then
		return 'windows'
	else
		return 'unix'
	end
end
local function mkDir(dirname)
	os.execute('mkdir "' .. dirname..'"')
end
local function capture(cmd, raw)
	local f = assert(io.popen(cmd, 'r'))
	local s = assert(f:read('*a'))
	f:close()
	if raw then return s end
	s = string.gsub(s, '^%s+', '')
	s = string.gsub(s, '%s+$', '')
	s = string.gsub(s, '[\n\r]+', ' ')
	return s
end
local function getWorkingDir()
	return io.popen'cd':read'*l'
end
function getDir(dir)
	if not dir then return getWorkingDir() end
	if getOS()=='unix' then
		return capture('cd '..dir..' ; cd')
	else
		return capture('cd '..dir..' & cd')
	end
end
function dirExists(strFolderName)
	strFolderName = strFolderName or getDir()
	local fileHandle, strError = io.open(strFolderName..'\\*.*','r')
	if fileHandle ~= nil then
		io.close(fileHandle)
		return true
	else
		if string.match(strError,'No such file or directory') then
			return false
		else
			return true
		end
	end
end
function scandir(directory)
	if not dirExists(directory) then error("Must enter a valid location for scanning a directory!") end
    local i, t, popen = 0, {}, io.popen
	if getOS()=='unix' then
		for filename in popen('ls -a "'..directory..'"'):lines() do
			i = i + 1
			t[i] = filename
		end
	else
		for filename in popen('dir "'..directory..'" /b'):lines() do
			i = i + 1
			t[i] = filename
		end
	end
    return t
end
local function split(str)
	local tab = {}
	for word in string.gmatch(str, '([^,]+)') do
		table.insert(tab,word)
	end
	return tab
end
local pluginLocation
local protection = true
local exposed = {}
local function _setPluginFolder(path)
	if not dirExists(path) then
		mkDir(path)
	end
	pluginLocation = path
end
local function _setProtection(bool)
	protection = bool
end
local function _expose(tab,readonly)
	if type(tab)=="string" then
		if tab=="*" or tab:match("*") then
			merge(exposed,_G)
			return
		elseif tab=="std" then
			tab = [[_VERSION,assert,collectgarbage,error,getfenv,getmetatable,ipairs,loadstring,module,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,xpcall,math,coroutine,string,table]]
			_expose({
				io = {io.tmpfile,io.write},
				os = {os.clock,os.date,os.difftime,os.exit,os.getenv,os.remove,os.rename,os.setlocale,os.time,os.tmpname},
				_G = exposed
			},readonly)
		end
		local tab = split(tab)
		for i = 1,#tab do
			exposed[tab[i]] = _G[tab[i]]
		end
	elseif type(tab)=="table" then
		merge(exposed,tab)
		if readonly then
			setmetatable(exposed,{
				__index = _G
			})
		end
	else
		if readonly then
			setmetatable(exposed,{
				__index = _G
			})
		end
	end
end
local function file_exists(name)
	local f=io.open(name,"r")
	if f~=nil then io.close(f) return true else return false end
end
local GLOBAL = {__PluginList={},vars = {}}
local conn = multi:newConnection(true)
local conn2 = multi:newConnection(true)
local conn3 = multi:newConnection(true)
local conn4 = multi:newConnection(true) -- Cleanup
local conn5 = multi:newConnection(true) -- Cleanup
-- And yes these names are really bad, doesn't matter
local plugs = {}
local function cleanTab(tab)
	for i,v in pairs(tab) do
		tab[i]=nil
	end
end
local function load_(path)
	if not file_exists(pluginLocation..package.config:sub(1,1)..path) then return end 
	local chunk = loadfile(pluginLocation..package.config:sub(1,1)..path)
	if not chunk then error("Could not load plugin: "..path) end
	local temp = {}
	merge(temp,exposed)
	merge(temp,{
		plugin = {
			version = version,
			OnLoaded = conn,
			OnPreload = conn3,
			OnReboot = conn4,
			init = function(name,version)
				temp["PLUGIN_NAME"]=name
				GLOBAL[name] = {version = version}
				table.insert(GLOBAL.__PluginList,name) 
				if not dirExists(pluginLocation..package.config:sub(1,1)..name) then
					mkDir(pluginLocation..package.config:sub(1,1)..name)
				end
			end,
			request = function(method,err)
				local met
				if type(method) == "string" then
					met = split(method)
				elseif type(method) == "table" then
					met = method
				end
				local count = 0
				local max = #met
				local missing = {}
				for ii = 1,#met do
					if temp[met[ii]] then
						count = count + 1
					else
						table.insert(missing,met[ii])
					end
				end
				if err and count ~= max then
					print((temp["PLUGIN_NAME"] or "Unnamed Plugin").." is missing some resources to be able to function properly! Try granting these features to the plugin if you trust it: ")
					for i = 1,#missing do
						print("> "..missing[i])
					end
				elseif count ~= max then
					return false
				else
					return true
				end
				return false
			end,
			openFreshFile = function(path)
				local t = package.config:sub(1,1)
				return bin.freshStream(pluginLocation..t..temp["PLUGIN_NAME"]..t..path)
			end,
			openFile = function(path)
				local t = package.config:sub(1,1)
				return bin.stream(pluginLocation..t..temp["PLUGIN_NAME"]..t..path,false)
			end,
			deleteFile = function(path)
				local t = package.config:sub(1,1)
				os.remove(pluginLocation..t..temp["PLUGIN_NAME"]..t..path,false)
			end,
			setGlobal = function(var,val)
				GLOBAL.vars[var]=val
			end,
			getGlobal = function(var)
				return GLOBAL.vars[var]
			end,
			getPluginList = function()
				return GLOBAL.__PluginList
			end,
			getPluginRef = function(name)
				local meh = {}
				local link = GLOBAL[name]
				setmetatable(meh,{
					__index = link -- Cannot alter a plugin's created domain but can read from it
				})
				return meh
			end,
			register = function(name,value)
				GLOBAL[temp["PLUGIN_NAME"]][name] = value
			end,
			expose = function()
				return GLOBAL[temp["PLUGIN_NAME"]]
			end,
			getName = function()
				return temp["PLUGIN_NAME"]
			end,
		}
	})
	conn2:Fire(temp,path)
	setfenv(chunk, temp)
	chunk()
	table.insert(plugs,{chunk,temp,GLOBAL,path})
	conn5(function()
		cleanTab(GLOBAL)
		GLOBAL.__PluginList={}
		GLOBAL.vars = {}
	end)
	if not temp["PLUGIN_NAME"] then
		temp.plugin.init(path:sub(1,-5))
	end
end
local granted = {}
conn2(function(tab,path)
	if granted[path] then
		merge(tab,granted[path])
	end
end)
local function _grant(path,tab)
	granted[path] = tab
end
local function _load()
	local files = scandir(pluginLocation)
	for i = 1,#files do
		if protection then
			a,b = pcall(load_,files[i])
			if not a then print(b) end
		else
			load_(files[i])
		end
	end
	conn3:Fire()
	conn:Fire(#files)
end
local function _reload()
	conn:Bind({}) -- bind to a new connection space
	conn3:Bind({}) -- this in turn removes all references that are connected to the connection obj
	conn4:Fire() -- allow the plugin to clean up some stuff
	conn5:Fire() -- resets all the GLOBAL namespace that is exposed to all plugins
	collectgarbage()
	for i=1,#plugs do
		plugs[i][1]() -- reload the plugins
	end
	conn3:Fire()
end
local plugin = {}
plugin.version = version
plugin.setPluginFolder = _setPluginFolder
plugin.setProtection =_setProtection
plugin.expose =_expose
plugin.load =_load
plugin.grant = _grant
-- plugin.reloadPlugins = _reload
return plugin
