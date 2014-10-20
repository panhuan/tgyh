
require "GlobalConstants"
local network = require "network"
local timer = require "timer"
local lfs = require "lfs"
local qlog = require "qlog"
local GSCommand = require "GSCommand"
local GSMgr = require "GSMgr"
local SdkGateMsgHandle = require "SdkGateMsgHandle"
local SdkBillingMsgHandle = require "SdkBillingMsgHandle"
local WebServerMsgHandle = require "WebServerMsgHandle"
local DBMgr = require "DBMgr"
local LogDB = require "LogDB"
local PayMgr = require "PayMgr"
local redis = require "redis"

local run = true

-- server
SDK_GATE = nil
SDK_BILLING = nil

local function _log(...)
	qlog.info("GC", string.format(...))
end

-- local gm = require "gm"
-- gm.listen("192.168.10.113", 9998)

-- DB
DBMgr:init()
LogDB:init()
PayMgr:init()

network.listen(GCConfig.ip, GCConfig.port, function(c)
	_log("gs connected", c)
	c:addPrivilege("GSCommand", GSCommand)

	c.onClosed = function()
		_log("gs disconnected", c)
		
		GSMgr:gsLogout(c)
	end
end)

network.listen(SdkGateConfig.ip, SdkGateConfig.port, function(c)
	_log("sdk gate server connected")
	
	if SDK_GATE then
		_log("sdk gate server already connected!!!!")
		return
	end
	
	c:setMode("string")
	c:setReceiver(function(c, msg)
		SdkGateMsgHandle:receive(msg)
	end)
	
	c.onClosed = function()
		_log("sdk gate server disconnected")
		SDK_GATE = nil
	end
	
	SDK_GATE = c
end)

network.listen(SdkBillingConfig.ip, SdkBillingConfig.port, function(c)
	_log("sdk billing server connected")
	
	if SDK_BILLING then
		_log("sdk billing server already connected!!!!")
		return
	end
	
	c:setMode("string")
	c:setReceiver(function(c, msg)
		SdkBillingMsgHandle:receive(msg)
	end)
	
	c.onClosed = function()
		_log("sdk billing server disconnected")
		SDK_BILLING = nil
	end
		
	SDK_BILLING = c
end)

network.listen(WebServerConfig.ip, WebServerConfig.port, function(c)
	_log("web server connected")
	
	c:setMode("string")
	c:setReceiver(function(c, msg)
		WebServerMsgHandle:receive(msg)
	end)
	
	c.onClosed = function()
		_log("web server disconnected")
	end
end)

_log("launch GC succeed")
	
local lastdate
function dotest()
	local file = "gamecenter/test.lua"
	local tb = lfs.attributes(file)
	if tb and lastdate ~= tb.modification then
		lastdate = tb.modification
		local ok, err = pcall(dofile, file)
		print(string.format("[TEST]", cmd), err and err or "ok")
	end
end

local now = os.clock()
local idx, fps, maxm = 0, 0, 0, 0
local monitor
if GCConfig.perfLog then
	local f = io.open(GCConfig.perfLog, "w")
	monitor = function(...)
		f:write(...)
		f:write("\n")
		f:flush()
	end
else
	monitor = function()
	end
end

local function step()
	fps = fps + 1
	network.step(GCConfig.span)
	timer.step()
	if os.clock() - now > 1 then
		idx = idx + 1
		local m = collectgarbage("count") / 1024
		maxm = math.max(m, maxm)
		local stats = network.stats()
		local info = string.format(
			"%d	fps = %d	m = %.2f/%.2f	rs/ss/rd/wt/re/se/rc/st = %d/%d/%d/%d/%d/%d/%.2f/%.2f backlogs = %.2f",
			idx, fps, m, maxm,
			stats.receives, stats.sends,
			stats.reads, stats.writtens,
			stats.receive_errors, stats.send_errors,
			stats.received / 1024, stats.sent / 1024,
			network._stats.backlogs / 1024)
		monitor(info, "\t")
		now = os.clock()
		fps = 0
		
		dotest()
	end
end

while run do
	local ok, err = pcall(step)
	if not ok then
		print(err)
	end
end

REDIS:srem("GameServerList", 0, GS_ADDR)
REDIS:del("GSPlayerList"..GS_ADDR)