
ReadFunctions = { }


function logWrite(...)
	local arg = {...}
	if #arg == 0 then 
		writeToLog( '\n' )
		return 
	end
	local printResult = ''
	for i,v in ipairs(arg) do
		printResult = printResult..tostring(v).."\t"
	end
	writeToLog('SCRIPT: '..printResult)
end

function fileExist( name )
	local f = io.open(name,"r")
	if f~=nil then 
		io.close(f) 
		return true 
	end
	return false
end

function showTable( tab )
	for k, v in pairs( tab ) do
		logWrite(k, v)
	end
end

function ReadFunctions.WORD( file )
	local block = 2
	local bytes = file:read( 2 )
	logWrite ('reading word ', bytes)
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
	local result = {}
	for key, value in pairs( dataTable ) do
		result[key] = ReadFunctions[value]( file )
	end
	return result
end

