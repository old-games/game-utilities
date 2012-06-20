
local ModuleName = 'example'
local Example = {}

local ActionsOnExtension = 
{ 
	bmp = "loadBMP",
	txt = "loadTXT",
	dat = "loadDAT"
}

local Operations = {}

UTTModules[ModuleName] = Example

function Example.getExtensions()
	return 'BMP files (*.bmp)|*.bmp|TXT files (*.txt)|*.txt|BIGLETS.DAT (biglets.dat)|biglets.dat'
end

function Example.openFile( fileName )
	fileName = string.lower( fileName )
	vol, path, name, ext = parseFileName( fileName )
	key = ActionsOnExtension[ ext ]
	if key == nil then
		print( "Can't find function for '"..ext.."' extension" )
		return
	end
	Operations[ key ]( fileName )
end

function Operations.loadBMP( filename )
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

function Operations.loadTXT( filename )
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


function Operations.loadDAT( filename )
	local fh = assert(io.open(filename, "r"))
	if not fh then
		return
	end
	fh:close()
end


print 'Example module loaded'
