require 'scripts/common'

logWrite "Starting Lua initiate..."

gModuleNames = { 'example', 'privateer2' }
gModules = {}

function initModules()
	for i = 1, #gModuleNames do
		local modulePath = 'scripts/'..gModuleNames[i]..'/'
		local fileName = modulePath..'initmodule'
		require( fileName )
	end
end

initModules()
gCurrentModule = gModules['example']

function getCurrentModule()
	return gCurrentModule
end

function getExtensions()
	if gCurrentModule ~= nil then
		return gCurrentModule.getExtensions()
	end
end

function openFile( fileName )
	if gCurrentModule ~= nil then
		return gCurrentModule.openFile( fileName )
	end
end

function selectModule()
	local name = selectModuleDialog( gModuleNames )
	if not name or string.len(name) == 0 then
		return
	end
	logWrite (name..' module selected.')
	gCurrentModule = gModules[ name ]
end

if gCurrentModule == nil then
	selectModule()
end

logWrite "Scripts initiated. Press '~' to show Lua console. Call reboot() to restart scripts."