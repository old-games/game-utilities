require 'scripts/common'

logWrite "Main Lua init"


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

function getCurrentTable()
	return gCurrentTable
end

function getExtensions()
	return gCurrentModule.getExtensions()
end

function openFile( fileName )
	return gCurrentModule.openFile( fileName )
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