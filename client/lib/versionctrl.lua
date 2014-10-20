
local crypto = require "crypto"
local mime = require "mime"
local qlog = require "qlog"

local versionctrl = {}

function versionctrl.update(url, ver, opt, onFinish)
	MOAIHttpTask.get(string.format("%s/version/update.php?ver=%s&opt=%s", url, ver, opt), function(task, responseCode)
		local s = task:getString()
		if not s then
			qlog.info("Nothing to upate")
			onFinish(nil)
			return
		end
		local f, err = loadstring(s)
		if not f then
			qlog.warn("Load falied:", res)
			onFinish(nil)
			return
		end
		local ok, res = pcall(f)
		if not ok then
			qlog.warn("Update falied:", res)
			onFinish(nil)
			return
		end
		onFinish(res)
	end)
end

return versionctrl