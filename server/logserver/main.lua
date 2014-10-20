
local network = require "network"
local timer = require "timer"
local lfs = require "lfs"
local CLCommand = require "CLCommand"
local qlog = require "qlog"
local LogDB = require "LogDB"
local redis = require "redis"

local run = true
local cons = 0

local function _log(...)
	qlog.debug("LS", string.format(...))
end

LogDB:init()

local LSConfig = LSConfig[LSId]
local LS = network.listen(LSConfig.ip, LSConfig.port, function(c)
	_log("player connected", c)
	c:addPrivilege("CLCommand", CLCommand)
	
	c.aliveCheck = LSConfig.aliveCheck or 60
	c.onClosed = function()
		_log("player disconnected", c)
	end
end)
_log("launch LS succeed")
local addr = LSConfig.ip..":"..LSConfig.port
local REDIS = redis.connect(RedisConfig.ip, RedisConfig.port)
REDIS:sadd("LogServerList", addr)

local now = os.clock()
local idx, fps, maxm = 0, 0, 0, 0
local monitor
if LSConfig.perfLog then
	local f = io.open(LSConfig.perfLog, "w")
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
	network.step(LSConfig.span)
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
	end
end

while run do
	local ok, err = pcall(step)
	if not ok then
		print(err)
	end
end
REDIS:srem("LogServerList", addr)