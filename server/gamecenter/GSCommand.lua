
local GCPlayer = require "GCPlayer"
local GSMgr = require "GSMgr"
local qlog = require "qlog"

local GSCommand = {}

function GSCommand.login(c, gsid)
	return GSMgr:gsLogin(c, gsid)
end

function GSCommand.logout(c, guid)
	return GSMgr:gsLogout(c)
end

function GSCommand.savaPlayerDataReq(c, guid, data)
	return GCPlayer:savaData(guid, data)
end

function GSCommand.platformLoginReq(c, guid, authcode)
	local gsId = GSMgr:getGsidByConnect(c)
	return GCPlayer:platformLogin(guid, authcode, gsId)
end

function GSCommand.updateOrderStateReq(c, guid, orderId, state)
	return GCPlayer:updateOrderState(guid, orderId, state)
end

function GSCommand.verifyOrderReq(c, guid, orderList)
	local gsId = GSMgr:getGsidByConnect(c)
	return GCPlayer:verifyOrder(guid, orderList, gsId)
end

function GSCommand.getServerTime(c)
	return os.time()
end

return GSCommand