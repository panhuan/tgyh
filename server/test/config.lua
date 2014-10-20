
dofile "../config.lua"
pcall(dofile, "../config.local")

local function shell (c)
	local h = io.popen (c)
	local o
	if h then
		o = h:read ("*a")
		h:close ()
	end
	return o
end

local ostype = os.getenv("OS") or shell("echo $OSTYPE")
if ostype:find("Windows") then
	package.cpath = "../clibs/win/?.dll;"
elseif ostype:find("linux") then
	package.cpath = "../clibs/linux/?.so;"
end
package.path = "../libs/?.lua;../shared/?.lua;../../base/?.lua;"
