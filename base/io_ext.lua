
function io.writefile(filename, str)
	local f, err = io.open(filename, "wb")
	if not f then
		return nil, string.format("Unable to open file for writing: %s: %s", filename, err)
	end
	f:write(tostring(str))
	f:close()
	return true
end

function io.appendfile(filename, str)
	local f, err = io.open(filename, "ab")
	if not f then
		return nil, string.format("Unable to open file for writing: %s: %s", filename, err)
	end
	f:write(tostring(str))
	f:close()
	return true
end

function io.readfile(filename)
	local f, err = io.open(filename, "rb")
	if not f then
		return nil, string.format("Unable to open file for reading: %s: %s", filename, err)
	end
	local result = f:read("*all")
	f:close()
	return result
end