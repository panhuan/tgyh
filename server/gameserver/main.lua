
require "GlobalConstants"
local network = require "network"
local timer = require "timer"
local lfs = require "lfs"
local CLCommand = require "CLCommand"
local GCCommand = require "GCCommand"
local PlayerMgr = require "PlayerMgr"
local qlog = require "qlog"
local redis = require "redis"

local run = true
local cons = 0

local GSConfig = GSConfig[GSId]
GC = nil

GS_ADDR = GSConfig.ip..":"..GSConfig.port
REDIS = redis.connect(RedisConfig.ip, RedisConfig.port)
REDIS:sadd("GameServerList", GS_ADDR)
--TODO 暂时在开启时清空,正式的应该在关闭时清空
REDIS:del("GSPlayerList"..GS_ADDR)

local function _log(...)
	qlog.info("GS", string.format(...))
end

-- local gm = require "gm"
-- gm.listen("192.168.10.113", 9998)

PlayerMgr:init()

network.listen(GSConfig.ip, GSConfig.port, function(c)
	_log("player connected", c)
	c:addPrivilege("CLCommand", CLCommand)
	
	c.aliveCheck = GSConfig.aliveCheck or 60
	c.onClosed = function()
		_log("player disconnected", c)
		
		PlayerMgr:playerLogout(c)
	end
end)

network.connect(GCConfig.ip, GCConfig.port, function(c)
	if not c then
		_log("gamecenter connect faild")
		return
	end
	
	_log("gamecenter connected")
	
	c:addPrivilege("GCCommand", GCCommand)
	c.onClosed = function()
		_log("gamecenter disconnected")
		GC = nil
	end
	
	local h = c.remote.GSCommand.login(GSId)
	h.onAck = function(result)
		if result then
			_log("login gamecenter")
			GC = c
		end
	end
	
end)

_log("launch GS succeed")
	
local lastdate
function dotest()
	local file = "gameserver/test.lua"
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
if GSConfig.perfLog then
	local f = io.open(GSConfig.perfLog, "w")
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
	network.step(GSConfig.span)
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
		monitor(info, "\t", string.format("cons = %d", cons))
		now = os.clock()
		fps = 0
		network.flushDeadConnections()
		io.flush()
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