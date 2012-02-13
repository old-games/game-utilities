
ReadFunctions = { }

function fileExist( name )
	local f = io.open(name,"r")
	if f~=nil then 
		io.close(f) 
		return true 
	end
	return false
end

BMPHeader = 
{ 
	ID = "WORD",
	SIZE = "LONG"
}

function showTable( tab )
	for k, v in pairs( tab ) do
		print (k, v)
	end
end

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
	data = readData( fh, BMPHeader )
 
	if(data.ID ~= 0x4D42) then
		print("Not a bitmap file (Invalid BMP magic value)");
		return;
	end
 
	for k, v in pairs( data ) do
		print( k, v )
	end
	fh:close()
end
