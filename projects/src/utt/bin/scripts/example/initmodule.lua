
local gName = 'example'
local gExample = {}
local gAssociations = 
{ 
	bmp = "loadBMP",
	txt = "loadTXT"
}

gModules[gName] = gExample

function gExample.getExtensions()
	return 'BMP files (*.bmp)|*.bmp|TXT files (*.txt)|*.txt'
end

function gExample.openFile( fileName )
	parseFileName( fileName )
	--loadBMP( fileName )
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



logWrite 'Example module loaded'
