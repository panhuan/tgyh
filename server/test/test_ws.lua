
local network = require "network"

local span = 0.01
local run = true
local ping = true
local now = os.clock()
local idx, fps, maxm = 0, 0, 0
local cons, c = 0, 0
while run do
	fps = fps + 1
	if ping then
		ping = false
		network.connect(WSConfig.outerIp, WSConfig.outerPort, function(c, e)
			assert(c:setoption("reuseaddr", true))
			cons = cons + 1
			local h = c.remote.CLCommand.redirect("xxxx")
			h.onAck = function()
				c:close("send")
				ping = true
			end
		end)
	end
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
		print(info, string.format("cons = %d", cons - c))
		c = cons
		now = os.clock()
		fps = 0
	end
end
