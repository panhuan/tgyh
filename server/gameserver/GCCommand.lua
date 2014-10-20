
local GSPlayer = require "GSPlayer"
local qlog = require "qlog"

local GCCommand = {}

function GCCommand.platformLoginAck(c, guid, accessToken, userId, userName)
	GSPlayer:platformLoginAck(guid, accessToken, userId, userName)
end

function GCCommand.verifyOrderAck(c, guid, successOrders)
	GSPlayer:verifyOrderAck(guid, successOrders)
end

return GCCommand