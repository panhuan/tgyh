
function os.shell (c)
	local h = io.popen (c)
	local o
	if h then
		o = h:read ("*a")
		h:close ()
	end
	return o
end

function os.exists(filename)
	local f = io.open(filename)
	if f then
		f:close()
	end
	return f ~= nil
end