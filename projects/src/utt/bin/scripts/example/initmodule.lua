
local gName = 'example'
local gExample = {}

gModules[gName] = gExample

function gExample.getExtensions()
	return 'BMP files (*.bmp)|*.bmp'
end

function gExample.openFile( fileName )
	loadBMP( fileName )
end



BMPFileHeader = 
{ 
	ID 			= "WORD",
	SIZE 		= "LONG",
	RESERVED1	= "WORD",
	RESERVED2	= "WORD",
	DATA_OFFSET = "DWORD"
}

BMPInfoHeader =
{
	SIZE			= "DWORD",
	WIDTH			= "LONG",
	HEIGHT			= "LONG",
	PLANES			= "WORD",
	BITCOUNT		= "WORD",
	COMPRESSION 	= "DWORD",
	SIZEIMAGE		= "DWORD",
	XPELSPERMETER	= "LONG",
	YPELSPERMETER	= "LONG",
	CLRUSED			= "DWORD",
	CLRIMPORTANT	= "DWORD"
}


print 'Example module loaded'
