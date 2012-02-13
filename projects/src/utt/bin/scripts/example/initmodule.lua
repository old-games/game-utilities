
local gName = 'example'
local gExample = {}

gModules[gName] = gExample

function gExample.getExtensions()
	return 'BMP files (*.bmp)|*.bmp'
end

function gExample.openFile( fileName )
	loadBMP( fileName )
end

print 'Example module loaded'
