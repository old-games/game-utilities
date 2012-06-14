
local gName = 'example'
local gExample = {}

local gFuncsForExt = 
{ 
	bmp = "loadBMP",
	txt = "loadTXT"
}

local gOnDo = {}

gModules[gName] = gExample

function gExample.getExtensions()
	return 'BMP files (*.bmp)|*.bmp|TXT files (*.txt)|*.txt'
end

function gExample.openFile( fileName )
	vol, path, name, ext = parseFileName( fileName )
	key = gFuncsForExt[ ext ]
	if key == nil then
		print( "Can't find function for '"..ext.."' extension" )
		return
	end
	gOnDo[ key ]( fileName )
end

function gOnDo.loadBMP( filename )
	local fh = assert(io.open(filename, "rb"))
	if not fh then
		return
	end
	data = readData( fh, BMPFileHeader )
	showTable( data )
	if(data.ID ~= 0x4D42) then
		print("Not a bitmap file (Invalid BMP id) ", data.ID);
		return;
	end
	data2 = readData(fh, BMPInfoHeader )
	showTable( data2 )
	fh:close()
end

function gOnDo.loadTXT( filename )
	local fh = assert(io.open(filename, "r"))
	if not fh then
		return
	end
	for line in fh:lines() do logWrite(line) end
	fh:close()
end


BMPFileHeader = {}
BMPFileHeader[1] = { ID 			= "WORD" 	}
BMPFileHeader[2] = { FILESIZE 		= "LONG" 	}
BMPFileHeader[3] = { RESERVED1 		= "WORD" 	}
BMPFileHeader[4] = { RESERVED2 		= "WORD" 	}
BMPFileHeader[5] = { DATA_OFFSET 	= "DWORD" 	}


BMPInfoHeader = {}
BMPInfoHeader[1] 	= { DATASIZE		= "DWORD" 	}
BMPInfoHeader[2] 	= { WIDTH			= "LONG" 	}
BMPInfoHeader[3] 	= { HEIGHT			= "LONG" 	}
BMPInfoHeader[4] 	= { PLANES			= "WORD" 	}
BMPInfoHeader[5] 	= { BITCOUNT		= "WORD" 	}
BMPInfoHeader[6] 	= { COMPRESSION 	= "DWORD" 	}
BMPInfoHeader[7] 	= { SIZEIMAGE		= "DWORD" 	}
BMPInfoHeader[8] 	= { XPELSPERMETER	= "LONG" 	}
BMPInfoHeader[9] 	= { YPELSPERMETER	= "LONG" 	}
BMPInfoHeader[10] 	= { CLRUSED			= "DWORD" 	}
BMPInfoHeader[11] 	= { CLRIMPORTANT	= "DWORD" 	}



print 'Example module loaded'
