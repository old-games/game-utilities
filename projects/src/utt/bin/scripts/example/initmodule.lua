
local gName = 'example'
local gExample = {}

gModules[gName] = gExample

function gExample.getExtensions()
	return 'BMP files (*.bmp)|*.bmp'
end

function gExample.openFile( fileName )
	loadBMP( fileName )
end

function loadBMP( filename )
	local fh = assert(io.open(filename, "rb"))
	if not fh then
		return
	end
	data = readData( fh, BMPFileHeader )
	showTable( data )
	if(data.ID ~= 0x4D42) then
		logWrite("Not a bitmap file (Invalid BMP id) ", data.ID);
		return;
	end
	data2 = readData(fh, BMPInfoHeader )
	showTable( data2 )
	fh:close()
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


logWrite 'Example module loaded'
