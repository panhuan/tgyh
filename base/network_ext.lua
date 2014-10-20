
local network = require "network"
local evcore = require "event.core"
local evbase = evcore.newbase()

local _listener = network._listener
local _connection = network._connection
-- private
function _connection._startSend(self)
	if not self._evwriter then
		self._evwriter = evbase:newevent(self._socket, evcore.EV_WRITE + evcore.EV_PERSIST, function(e, w)
			self:flushSend()
		end)
		self._evwriter:add()
	end
end

function _connection._startReceive(self)
	if not self._evreader then
		self._evreader = evbase:newevent(self._socket, evcore.EV_READ + evcore.EV_PERSIST, function(e, w)
			self:flushReceive()
		end)
		self._evreader:add()
	end
end

function _connection._stopSend(self)
	if self._evwriter then
		self._evwriter:del()
		self._evwriter = nil
	end
end

function _connection._stopReceive(self)
	if self._evreader then
		self._evreader:del()
		self._evreader = nil
	end
end

local _network_listen = network.listen
function network.listen(ip, port, cb)
	local s = assert(socket.bind(ip, port))
	local self = {
		_socket = s,
		close = _listener.close,
		setoption = _connection.setoption,
		settimeout = _connection.settimeout,
	}
	self._socket:settimeout(0)
	self._evreader = evbase:newevent(self._socket, evcore.EV_READ + evcore.EV_PERSIST, function(e, w)
		local s, e = self._socket:accept()
		if not s then
			if e == "closed" then
				return
			end
			_log("accept failed:"..e)
			return
		end
		cb(_connection.new(s))
	end)
	self._evreader:add()
	return self
end

function network.connect(ip, port, cb)
	local s = socket.tcp()
	s:settimeout(0)
	s:connect(ip, port)
	local self = _connection.new(s)
	self._evwriter = evbase:newevent(s, evcore.EV_WRITE, function(e, w)
		self:_stopSend()
		cb(self)
	end)
	self._evwriter:add()
end

function network.step(timeout)
	if timeout then
		evbase:loop(evcore.EVLOOP_NONBLOCK)
		if timeout > 0 then
			socket.sleep(timeout)
		end
	else
		evbase:loop(evcore.EVLOOP_ONCE)
	end
	network.flushPendingConnections()
end

return network
