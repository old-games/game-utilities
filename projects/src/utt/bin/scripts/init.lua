print "Main Lua init"
require 'scripts/common'

gModuleNames = { 'example' } --, 'privateer2' }
gModules = {}

function initModules()
	for i = 1, #gModuleNames do
		local modulePath = 'scripts/'..gModuleNames[i]..'/'
		--local modulePath = gModuleNames[i]..'/'
		local fileName = modulePath..'initmodule'
		require( fileName )
		--[[
		if fileExist( fileName..'.lua' ) then
			require( fileName )
		else
			print ('initModules error: '..fileName..' not found!')
		end]]
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
