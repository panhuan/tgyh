
local key = "54C319E9A6CDD5B78AD771FA595CB897"
local crypto = require "crypto"
local mime = require "mime"
local hmac = crypto.hmac.new("sha1", key)

return function(manifest, path, ...)
	local t = {}
	for i, v in ipairs {...} do
		local f = path.."/"..v
		local s = io.readfile(f)
		if not s then
			print("[ERROR] not found file:", f)
		else
			local sha = hmac:digest(s)
			table.insert(t, {v, sha})
			io.writefile(f, mime.b64(s, nil))
		end
	end
	local s = "local manifest = "..toprettystring(t).."\n".."local key = \""..key.."\"\n"..io.readfile(manifest)
	local f = path.."/manifest.lua"
	s = mime.b64(s, nil)
	io.writefile(f, s)
	print("[ok] wrote:", #s, f)
end