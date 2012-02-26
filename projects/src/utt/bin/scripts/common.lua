
ReadFunctions = { }


function logwrite(...)
	local arg = {...}
	if #arg == 0 then 
		io.write( '\n' )
		return 
	end
	local printResult = ''
	for i,v in ipairs(arg) do
		printResult = printResult..tostring(v).."\t"
	end
	error('SCRIPT: '..printResult .. '\n', 0)
end

function fileExist( name )
	local f = io.open(name,"r")
	if f~=nil then 
		io.close(f) 
		return true 
	end
	return false
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

function showTable( tab )
	for k, v in pairs( tab ) do
		logwrite(k, v)
	end
end

showTable( BMPFileHeader )
showTable( BMPInfoHeader )

function ReadFunctions.WORD( file )
	local block = 2
	local bytes = file:read( 2 )
	return bytes:byte(2) * 256 + bytes:byte(1)
end

function ReadFunctions.LONG( file )
	local block = 4
	local bytes = file:read( 4 )
	return bytes:byte(4) * 16777216 + bytes:byte(3) * 65536 + bytes:byte(2) * 256 + bytes:byte(1)
end

function ReadFunctions.DWORD( file )
	return ReadFunctions.LONG(file)
end

function readData( file, dataTable )
	result = {}
	for key, value in pairs( dataTable ) do
		result[key] = ReadFunctions[value]( file )
	end
	return result
end

function loadBMP( filename )
	local fh = assert(io.open(filename, "rb"))
	if not fh then
		return
	end
	data = readData( fh, BMPFileHeader )
	showTable( data )

	if(data.ID ~= 0x4D42) then
		logwrite("Not a bitmap file (Invalid BMP magic value) ", data.ID);
		return;
	end
	showTable( data )
	data2 = readData(fh, BMPInfoHeader )
	showTable( data2 )
	fh:close()
end
