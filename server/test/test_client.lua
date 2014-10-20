
local socket = require "socket"
local network = require "network"
local stream = require "stream"
local span = 0.001

local dummy = function()
end
local set = {}
local connect = function(p, n)
	-- client
	local network = require "network"
	for i = 1, n do
		network.connect("127.0.0.1", p, function(c, e)
			if not c then
				print("connect failed", e)
				return
			end
			table.insert(set, c)
			
			local function say_hi()
				local h = c.remote.cmd.hi("say hi")
				h.onAck = say_hi
			end
			local function say_hello()
				local h = c.remote.cmd.hi("say hello")
				h.onAck = say_hello
			end
			local function sub_a()
				local h = c.remote.cmd.hi("sub.a")
				h.onAck = sub_a
				-- c:send(string.rep("x", 1024))
			end
			say_hi()
			say_hello()
			sub_a()
		end)
	end
end

local now = os.clock()
local c = {
	_privilege = {
		cmd = {
			hello = function(...)
			end,
		}
	}
}

local s = stream.new()
s:write({"cmd","hello"}, {"dummy say hello"})
for i = 1, 10000 do
	s:seek(0)
	network._connection._dorpc(c, s, 2)
end
print("dorpc", os.clock() - now)

print "init ..."
connect(10001, 2000)
print "inited"

local now = os.clock()
local idx, fps, maxm = 0, 0, 0
while true do
	fps = fps + 1
    -- for k, c in pairs(set) do
		-- local h = c.remote.cmd.hi("say hi")
		-- h.onAck = dummy
		-- local h = c.remote.cmd.hello("say hello")
		-- h.onAck = dummy
		-- local h = c.remote.cmd.sub.a("sub.a")
		-- h.onAck = dummy
		-- c:send(string.rep("x", 1024))
    -- end
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
