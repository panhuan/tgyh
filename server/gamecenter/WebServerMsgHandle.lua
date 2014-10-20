
local qlog = require "qlog"
local GCPlayer = require "GCPlayer"

local WebServerMsgHandle = {}

function WebServerMsgHandle:receive(msg)
	qlog.debug("WebServerMsgHandle:receive ", msg)
	GCPlayer:cmccPayAck(msg)
end

return WebServerMsgHandle