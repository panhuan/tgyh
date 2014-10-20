
local crypto = require "crypto"
local stream = require "stream"

return function (path, out, fileFilter, dirFilter, depth)
	print("begin packing '"..path.."'")
	suffix = suffix or ""
	local n = #path + 1
	local pak = {}
	for_every(path, fileFilter or ".lua$", function(file)
		-- os.execute ("luac "..file.." -o "..file.."c")
		local f = io.open(file, "rb")
		local s = f:read("*all")
		local b, e = loadstring(s, file)
		if not b then
			print(file, e)
			return
		end
		local v = crypto.encode(string.dump(b))
		local ok = type(loadstring(crypto.decode(v))) == "function" and "ok" or "failed"
		local filename = string.gsub(file, ".*/([^/]+)$", "%1")
		local luac = out.."/"..filename
		print("["..ok.."]", file, "===>", luac, "SHA:", crypto.hmac.digest("sha1", v, ""))
		f:close()
		local f = io.open(luac, "wb")
		f:write(v)
		f:close()
	end, dirFilter, nil, depth)
end