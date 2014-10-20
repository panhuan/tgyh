
require "base_ext"
local socket = require "socket"
local stream = require "stream"
local mime = require "mime"

local function _newset()
    local reverse = {}
    local set = {}
    return setmetatable(set, {__index = {
        insert = function(set, value)
			assert(value)
            if not reverse[value] then
                table.insert(set, value)
                reverse[value] = #set
            end
        end,
        remove = function(set, value)
            local index = reverse[value]
            if index then
                reverse[value] = nil
                local top = table.remove(set)
                if top ~= value then
                    reverse[top] = index
                    set[index] = top
                end
            end
        end
    }})
end

local function _log(...)
	print("[NETWORK]", ...)
end

local _readings = _newset()
local _writings = _newset()
local _listenings = {}
local _connectings = {}
local _pending_connections = {}
local _pending_listens = {}

local _connection = {
	__string = "network.connection",
}
local _listener = {
	__string = "network.listener",
}
function _listener.close(self, mode)
	if self._socket then
		_connection._stopReceive(self)
		_listenings[self._socket] = nil
		self._socket:shutdown(mode or "both")
		self._socket:close()
		self._socket = nil
	end
end


local _waitings = {
	index = 0
}
local _stats = {
	writtens = 0,
	reads = 0,
	backlogs = 0,
	sends = 0,
	receives = 0,
	send_errors = 0,
	receive_errors = 0,
	sent = 0,
	received = 0,
}
local network = {
	FLAG_RPC	= "#RPC",
	FLAG_ACK	= "#ACK",
}

_connection.__index = _connection
function _connection.addPrivilege(self, key, privilege)
	self._privilege[key] = privilege
end

function _connection.removePrivilege(self, key)
	self._privilege[key] = nil
end

function _connection.clearPrivilege(self)
	self._privilege = {}
end

function _connection.setReceiver(self, cb)
	self._receiver = cb
end

function _connection.send(self, text)
	return self:_send(text)
end

function _connection.setReceivable(self, on)
	self._receivable = on
end

function _connection.close(self, mode)
	if self._closed then
		return
	end
	self._closed = true
	
	if self.onClosed then
		self:onClosed()
	end
	
	if self._socket then
		self:_stopSend()
		self:_stopReceive()
		_connectings[self._socket] = nil
		
		self._socket:shutdown(mode or "both")
		self._socket:setoption("linger", {on = true, timeout = 0})
		self._socket:close()
		self._socket = nil
	end
end

local function checkTable(o, visited)
	local t = type(o)
	if t == "boolean" or t == "number" or t == "string" then
		return
	end
	visited = visited or {}
	for k, v in pairs(o) do
		local t = type(k)
		assert(t == "boolean" or t == "number" or t == "string", "unsaveable key type:"..toprettystring(o))
		t = type(v)
		assert(t == "boolean" or t == "number" or t == "string" or t == "table", "unsaveable value type:"..toprettystring(o))
		if type(v) == "table" then
			checkTable(v, visited)
			visited[v] = v
		end
	end
end

-- private
function _connection._send(self, ...)
	if _DEBUG then
		for k, v in pairs{...} do
			checkTable(v)
		end
	end
	assert(not self._closed, "connection closed")
	if not self._packet.first then
		self:_startSend()
		self._packet.first = {
			data = {...},
		}
		self._packet.last = self._packet.first
	else
		self._packet.last.next = {
			data = {...},
		}
		self._packet.last = self._packet.last.next
	end
	_stats.writtens = _stats.writtens + 1
	return self._packet.last
end

function _connection._startSend(self)
	_writings:insert(self._socket)
end

function _connection._startReceive(self)
	_readings:insert(self._socket)
end

function _connection._stopSend(self)
	_writings:remove(self._socket)
end

function _connection._stopReceive(self)
	_readings:remove(self._socket)
end

function _connection._noprivilege(self, rpc)
	_log("RPC error: noprivilege '"..rpc.."'")
end

function _connection._respond(self, ack, result)
	if self._closed then
		_log("_connection._respond connect is closed")
		return
	end
	
	self:_send(network.FLAG_ACK, ack, result)
end

function _connection._dorpc(self, field, args, ack)
	local rpc = self._privilege
	for i, v in ipairs(field) do
		if type(rpc) ~= "table" then
			break
		end
		rpc = rpc[v]
		if not rpc then
			break
		end
	end
	if type(rpc) ~= "function" then
		if self._noprivilege then
			self:_noprivilege(table.concat(field, "."))
		end
		return
	end
	local result = {pcall(rpc, self, unpack(args))}
	if result[1] then
		if ack and self._respond then
			self:_respond(ack, {unpack(result, 2)})
		end
		return
	end
	
	_log("RPC error when call: \n",
		"	field = "..toprettystring(field), "\n",
		"	args = "..toprettystring(args), "\n",
		"	result = "..result[2])
end

function _connection._doack(self, ack, result)
	_waitings[ack](unpack(result))
	_waitings[ack] = nil
end

function _connection._dispatch(self, reader, nb)
	local flag = reader:read()
	local cb = self._dispatchers[flag]
	if cb then
		cb(self, reader:read(nb - 1))
	elseif self._receiver then
		self:_receiver(flag, reader:read(nb - 1))
	end
end

function _connection._dispatchByTable(self, args)
	local flag = args[1]
	local cb = self._dispatchers[flag]
	if cb then
		cb(self, unpack(args, 2))
	elseif self._receiver then
		self:_receiver(flag, unpack(args, 2))
	end
end

function _connection.new(s)
	local self = {
		_socket = s,
		_privilege = {},
		_packet = {},
		_receivable = true,
		_closed = nil,
		_clients = nil,
		_receiver = nil,
		_evreader = nil,
		onClosed = nil,
		remote = {},
	}
	self._dispatchers = {
		[network.FLAG_RPC] = _connection._dorpc,
		[network.FLAG_ACK] = _connection._doack,
	}
	setmetatable(self, _connection)
	self:setMode("rpc")
	
	local _remote_call = function(_, key)
		local rpc = {}
		local field = {key}
		setmetatable(rpc, {
			__index = function(rpc, key)
				table.insert(field, key)
				return rpc
			end,
			__call = function(rpc, ...)
				return self:_send(network.FLAG_RPC, field, {...})
			end
		})
		return rpc
	end
	setmetatable(self.remote, {__index = _remote_call, __newindex = _remote_call})
	if s then
		s:settimeout(0)
		s:setoption("tcp-nodelay", true)
		s:setoption("keepalive", true)
		self._reader = stream.new()
		self._writer = stream.new()
		self._aliveTime = os.clock()
		
		self:_startReceive()
		_connectings[s] = self
	end
	return self
end

local function _receive_str(self, socket)
	socket = socket or self._socket
	while true do
		local s, e = socket:receive("*l")
		if not s then
			if e == "timeout" then
				break
			end
			if e == "closed" then
				self:close()
				break
			end
			_log("receive failed:"..e)
			self:close()
			break
		end
		_stats.receives = _stats.receives + 1
		_stats.received = _stats.received + #s
		if self._receiver then
			self:_receiver(s)
		end
	end
end

local function _send_str(self, socket)
	socket = socket or self._socket
	while self._packet.first do
		local this = self._packet.first
		local ok, e = socket:send(this.data[1].."\n")
		if not ok then
			if e == "timeout" then
				_stats.send_errors = _stats.send_errors + 1
				break
			end
			if e == "closed" then
				self:close()
				break
			end
			_log("send failed:"..e)
			break
		end
		_stats.sends = _stats.sends + 1
		_stats.sent = _stats.sent + ok
		
		self._packet.first = this.next
	end
	
	return not self._packet.first
end

local function _receive_rpc(self, socket)
	socket = socket or self._socket
	local reader = self._reader
	local ok, e = socket:receive(reader)
	if not ok then
		if e == "timeout" then
			_stats.receive_errors = _stats.receive_errors + 1
			return
		end
		if e == "closed" then
			self:close()
			return
		end
		_log("receive failed:"..e)
		self:close()
		return
	end
	_stats.receives = _stats.receives + 1
	_stats.received = _stats.received + ok
	
	while true do
		if not self._packet.need then
			if reader:unread() < 4 then
				break
			end
			self._packet.need = reader:readf("D")
		end
		
		if reader:unread() < self._packet.need then
			break
		end
		
		local nb = reader:readf("B")
		if self._receivable then
			self._dispatch(self, reader, nb)
		else
			reader:read(nb)
		end
		self._packet.need = nil
		_stats.reads = _stats.reads + 1
	end
	reader:remove(0, reader:tell())
end

local function _send_rpc(self, socket)
	socket = socket or self._socket
	local writer = self._writer
	while self._packet.first do
		local this = self._packet.first
		if this.onAck then
			_waitings.index = _waitings.index + 1
			_waitings[_waitings.index] = this.onAck
			table.insert(this.data, _waitings.index)
		end
		local pos = writer:size()
		writer:writef("B", #this.data)
		writer:write(unpack(this.data))
		writer:insertf(pos, "D", writer:size() - pos)
		self._packet.first = this.next
	end
	
	if writer:size() > 0 then
		local ok, e = socket:send(writer)
		if not ok then
			if e == "timeout" then
				_stats.send_errors = _stats.send_errors + 1
				return
			end
			if e == "closed" then
				self:close()
				return
			end
			_log("send failed:"..e)
			return
		end
		
		_stats.sends = _stats.sends + 1
		_stats.sent = _stats.sent + ok
	end
	
	return writer:empty()
end

local function _base64_stream(t)
	local writer = stream.new()
	writer:writef("B", #t)
	writer:write(unpack(t))
	return mime.b64(writer:tostring(), nil)
end

local function _unbase64_stream(self, s)
	local reader = stream.new(mime.unb64(s, nil))
	local nb = reader:readf("B")
	if self._receivable then
		self._dispatch(self, reader, nb)
	end
end

local _base64, _unbase64 = _base64_stream, _unbase64_stream
local function _receive_base64(self, socket)
	socket = socket or self._socket
	while true do
		local s, e = socket:receive("*l")
		if not s then
			if e == "timeout" then
				break
			end
			if e == "closed" then
				self:close()
				break
			end
			_log("receive failed:"..e)
			self:close()
			break
		end
		_unbase64(self, s)
		_stats.receives = _stats.receives + 1
		_stats.received = _stats.received + #s
		_stats.reads = _stats.reads + 1
	end
end

local function _send_base64(self, socket)
	socket = socket or self._socket
	while self._packet.first do
		local this = self._packet.first
		
		if this.onAck then
			_waitings.index = _waitings.index + 1
			_waitings[_waitings.index] = this.onAck
			table.insert(this.data, _waitings.index)
		end
		local s = _base64(this.data)
		local ok, e = socket:send(s.."\n")
		if not ok then
			if e == "timeout" then
				_stats.send_errors = _stats.send_errors + 1
				break
			end
			if e == "closed" then
				self:close()
				break
			end
			_log("send failed:"..e)
			break
		end
		_stats.sends = _stats.sends + 1
		_stats.sent = _stats.sent + ok
		
		self._packet.first = this.next
	end
	
	return not self._packet.first
end

function _connection:setMode(value)
	if value == "rpc" then
		self._doReceive = _receive_base64
		self._doSend = _send_base64
	elseif value == "string" then
		self._doReceive = _receive_str
		self._doSend = _send_str
	end
end

function _connection.flushReceive(self, socket)
	self._aliveTime = os.clock()
	local ok, res = pcall(self._doReceive, self, socket)
	if not ok then
		_log("flush receive failed:", res)
		self._reader:remove(0, #self._reader)
		return
	end
	return res
end

function _connection.flushSend(self, socket)
	self._aliveTime = os.clock()
	local ok, res = pcall(self._doSend, self, socket)
	if not ok then
		_log("flush send failed:", res)
		self._writer:remove(0, #self._writer)
		return
	end
	return res
end

-- socket interface
function _connection.getpeername(self)
	return self._socket:getpeername()
end

function _connection.getsockname(self)
	return self._socket:getsockname()
end

function _connection.setoption(self, option, value)
	return self._socket:setoption(option, value)
end

function _connection.settimeout(self, value, mode)
	return self._socket:settimeout(value, mode)
end

function network.listen(ip, port, cb)
	local s = assert(socket.bind(ip, port))
	local self = {
		_socket = s,
		close = _listener.close,
		setoption = _connection.setoption,
		settimeout = _connection.settimeout,
	}
	
	_listenings[s] = {
		ip = ip,
		port = port,
		incoming = cb,
	}
	
	_connection._startReceive(self)
	
	s:settimeout(0)
	return self
end

function network.connect(ip, port, cb, timeout)
	local s = socket.tcp()
	s:settimeout(0)
	s:connect(ip, port)
	local self = _connection.new(s)
	self._connectTimeout = os.clock() + (timeout or 3)
	self._connectCb = cb
	_pending_connections[s] = self
	self:_startSend()
	self:_startReceive()
end

function network.flushPendingConnections()
	local now = os.clock()
	for k, c in pairs(_pending_connections) do
		if c._connectTimeout < now then
			pcall(c._connectCb, nil)
			c:close()
			_pending_connections[k] = nil
		end
	end
end

function network.flushDeadConnections(long, proc)
	local now = os.clock()
	local set = table.copy(_readings)
	for i, v in ipairs(set) do
		local c = _connectings[v]
		if c and c.aliveCheck and c._aliveTime + (long or c.aliveCheck) < now then
			if proc then
				proc(c)
			else
				c:close()
			end
		end
	end
end

function network.step(timeout)
	local readable, writable = socket.select(_readings, _writings, timeout)
	socket.sleep(timeout)
	local errors = {}
	for k, v in ipairs(readable) do
		repeat
			local listener = _listenings[v]
			if listener then
				local s, e = v:accept()
				if not s then
					if e == "closed" then
						break
					end
					_log("accept failed:"..e)
					break
				end
				listener.incoming(_connection.new(s))
				break
			end
			local e = _pending_connections[v]
			if e then
				errors[v] = e
				break
			end
			local c = _connectings[v]
			if c then
				c:flushReceive(v)
			end
		until true
	end
	for k, v in ipairs(writable) do
		repeat
			local c = _pending_connections[v]
			if c then
				_pending_connections[v] = nil
				local ok, err
				if errors[v] then
					ok, err = pcall(c._connectCb, nil)
					c:close()
				else
					ok, err = pcall(c._connectCb, c)
				end
				if not ok then
					_log("connect failed", err)
				end
				break
			end
			local c = _connectings[v]
			if c then
				local empty = c:flushSend(v)
				if empty then
					c:_stopSend()
				end
			end
		until true
	end
	network.flushPendingConnections()
end

function network.block(h)
	local ack
	h.onAck = function(...)
		ack = {...}
	end
	while not ack do
		coroutine.yield()
	end
	return unpack(ack)
end

local rs, ss, rd, wt, re, se, rc, st = 0, 0, 0, 0, 0, 0, 0, 0
function network.stats()
	local tb = {
		receives = network._stats.receives - rs,
		sends = network._stats.sends - ss,
		reads = network._stats.reads - rd,
		writtens = network._stats.writtens - wt,
		receive_errors = network._stats.receive_errors - re,
		send_errors = network._stats.send_errors - se,
		received = network._stats.received - rc,
		sent = network._stats.sent - st,
		backlogs = network._stats.backlogs,
	}
	rs, ss = network._stats.receives, network._stats.sends
	rd, wt = network._stats.reads, network._stats.writtens
	re, se = network._stats.receive_errors, network._stats.send_errors
	rc, st = network._stats.received, network._stats.sent
	return tb
end

network._listener = _connection
network._connection = _connection
network._stats = _stats

return network
