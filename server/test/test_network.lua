
require "base_ext"
local network = require "network_ext"

-- server
local cmd = {
	hello = function(self, ...)
		print("hello", ...)
	end,
	hi = function(self, ...)
		print("hi", ...)
		return "hi.ack", ...
	end,
	sub = {a = print, b = print},
}
network.listen("127.0.0.1", 90001, function(c)
	print("accept", c) 
	c:addPrivilege("cmd",cmd)
	c:setReceiver(function(...)
		print("receive", ...)
		c:close("receive")
	end)
end)

-- client
network.connect("127.0.0.1", 90001, function(c, e)
	print("connect", c, e)
	
	local h = c.remote.cmd.hi("say hi")
	h.onAck = print
	c.remote.cmd.hello("say hello", true, 1, 2, nil)
	c.remote.cmd.sub.a("sub.a")
	c:send("xxxxxxx")
	c.onClosed = function() print "closed" end
	-- coroutine.run(function()
		-- while true do
			-- local h = c.remote.cmd.hi("test wait")
			-- print(network.wait(h))
		-- end
	-- end)
end)

while true do
	network.step(0)
	-- coroutine.step()
end