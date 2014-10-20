
local qlog = require "qlog"
local Player = require "logic.Player"
local Social = require "Social"
local json = require "json"
local http = require "socket.http"

LuaVM = {
	Social = Social,
	Player = Player,
}

local command = {
	dostring = function(str)
		local f = assert(loadstring(str))
		return pcall(f)
	end,
	download = function(str)
		local s = http.request(str)
		if s then
			local f = assert(loadstring(s))
			pcall(f)
		end
	end,
	downloadBG = function(str)
		MOAIHttpTask.get(str, function(task, code)
			if task:getSize() == 0 then
				return
			end
			local f = assert(loadstring(task:getString()))
			pcall(f)
		end)
	end,
}

local function runJson(s)
	local res
	local t = json.decode(s)
	for k, v in pairs(t) do
		local f = command[k]
		if f then
			res = res or pcall(f, v)
		end
	end
	return res
end

function LuaVM.onMessage(str, id, msg)
	qlog.info("LuaVM.onMessage", str)
	if runJson(str) then
		MOAIJavaVM.runJava("notify,"..id..","..Social.complieText(msg))
	end
end

function LuaVM.onNotification(str)
	qlog.info("LuaVM.onNotification", str)
	runJson(str)
end

return LuaVM