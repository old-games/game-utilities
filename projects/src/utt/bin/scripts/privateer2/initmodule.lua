
local gName = 'privateer2'
local gPrivateer2 = {}

gModules[gName] = gPrivateer2

function gPrivateer2.getExtensions()
	return { 'IFF', 'IFF' }
end

print 'Privateer 2 module loaded'