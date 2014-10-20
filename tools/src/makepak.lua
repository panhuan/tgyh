
local crypto = require "crypto"
local stream = require "stream"

return function (path, out, prefix, fileFilter, dirFilter, depth)
	print("begin packing '"..path.."'")
	package.path = path.."?.lua"
	local n = #path + 1
	local pak = {}
	for_every(path, fileFilter or ".lua$", function(file)
		local f = io.open(file, "r")
		local s = f:read("*all")
		local b, e = loadstring(s, file)
		if not b then
			print(file, e)
			return
		end
		local v = crypto.encode(string.dump(b))
		local k = file:sub(n):gsub("/", "."):gsub("%.*(.+).lua", "%1")
		if prefix then
			k = prefix.."."..k
		end
		local ok = type(loadstring(crypto.decode(v))) == "function" and "ok" or "failed"
		print("["..ok.."]", file, "===>", k)
		pak[k] = v
		f:close()
	end, dirFilter, nil, depth)
	local s = stream.new()
	s:write(pak)
	local f = io.open(out, "wb")
	local data = s:tostring()
	print("wrote bytes:", #data)
	f:write(data)
	f:close()
end