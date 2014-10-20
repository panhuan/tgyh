

local network = require "network"
local redis = require "redis"

REDIS = redis.connect(RedisConfig.ip, RedisConfig.port)
local run = true
local WSConfig = WSConfig[WSId]

local function _log(...)
	if _TEST then
		return
	end
	print("[WS]", string.format(...))
end

local function getGSList()
	return REDIS:smembers("GameServerList")
end

local function getPlayerNum(addr)
	return REDIS:hlen("GSPlayerList"..addr)
end

local cons = 0
local CLCommand = {}
function CLCommand.redirect(c, guid)
	local least
	local gsAddr
	local GSList = getGSList()
	for _, addr in pairs(GSList) do
		local playerNum = getPlayerNum(addr)
		print(addr, playerNum)
		if not least or playerNum < least then
			least = playerNum
			gsAddr = addr
		end
	end
	
	if gsAddr then
		local ip, port = string.split(gsAddr, ":")
		return ip, tonumber(port), WSConfig.payUrl
	end
end

function CLCommand.getLSList(c)
	return REDIS:smembers("LogServerList")
end

local function onPlayerDisconnect(c)
	cons = cons - 1
	_log("player disconnected %s:%s", c:getpeername())
end

network.listen(WSConfig.ip, WSConfig.port, function(c)
	cons = cons + 1
	_log("player connected %s:%s", c:getpeername())
	assert(c:setoption("reuseaddr", true))
	c:addPrivilege("CLCommand", CLCommand)
	c.aliveCheck = WSConfig.aliveCheck or 60
	c.onClosed = onPlayerDisconnect
end)

_log("launch WS at %s:%d", WSConfig.ip, WSConfig.port)

local now = os.clock()
local idx, fps, maxm = 0, 0, 0, 0
local monitor
if _TEST then
	monitor = print
elseif WSConfig.perfLog then
	local f = io.open(WSConfig.perfLog, "w")
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
	network.step(WSConfig.span)
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
