
local crypto = require "crypto"
local stream = require "stream"

local pakutil = {}
local _PAK = {}

local function _loader(modname)
	if _PAK[modname] then
		print("[PAK] load module '"..modname.."'")
		return _PAK[modname]
	end
	return string.format("\n\tno module '%s' in PAK", modname)
end
table.insert(package.loaders, _loader)

local function _load(file)
	local f = io.open(file, "rb")
	if not f then
		return
	end
	local data = f:read("*all")
	local s = stream.new(data)
	local t = s:read()
	for k, v in pairs(t) do
		_PAK[k] = loadstring(crypto.decode(v), k)
	end
	f:close()
	return true
end

pakutil.path = "?"
function pakutil.load(pakname)
	local stack = {}
	for v in string.gmatch(pakutil.path, "[^;]+") do
		local path = v:gsub("?", pakname)
		table.insert(stack, path)
		if _load(path) then
			return true
		end
	end
	return nil, "not found PAK:"..pakname.."\n\t"..table.concat(stack, "\n\t")
end

return pakutil
