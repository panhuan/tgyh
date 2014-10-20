
local network = require "proxy"
-- local profiler = require "ProFi"
local span = 0.001
local run = true

-- server
local cmd = {
	hello = function(...)
		-- print("hello", ...)
	end,
	hi = function(...)
		-- print("hi", ...)
		return "hi.ack"
	end,
	sub = {a = function() end},
}

-- network.addGateway(20001)
network.listen("127.0.0.1",20001, function(c)
	if c._clients then
		return
	end
	c:addPrivilege("cmd", cmd)
	c:setReceiver(function(s, ...)
	end)
end)
network.listen("127.0.0.1",20002, function(c)
	c:send("PONG")
	local ok, e = c._socket:send()
	if not ok then
		print(e)
	end
	c:close("receive")
end)

local now = os.clock()
local idx, fps, maxm = 0, 0, 0
while run do
	fps = fps + 1
	network.step(span)
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
		print(info)
		now = os.clock()
		fps = 0
	end
end
