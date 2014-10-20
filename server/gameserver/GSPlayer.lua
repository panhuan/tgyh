
local qlog = require "qlog"
local PlayerMgr = require "PlayerMgr"
local json = require "json"

local GSPlayer = {}

function GSPlayer:savaData(guid, data)
	if not GC then
		qlog.warn("GSPlayer:savaData GC is disconnect")
		return false
	end
	
	qlog.debug("GSPlayer:savaData ", guid , data)
	GC.remote.GSCommand.savaPlayerDataReq(guid, data)
	return true
end

function GSPlayer:loadData(guid)
end

function GSPlayer:platformLogin(guid, authcode)
	if not GC then
		qlog.warn("GSPlayer:platformLogin GC is disconnect")
		self:platformLoginAck(guid)
		return false
	end
	
	qlog.debug("GSPlayer:platformLogin ", guid , authcode)
	
	GC.remote.GSCommand.platformLoginReq(guid, authcode)
	return true
end

function GSPlayer:platformLoginAck(guid, accessToken, userId, userName)
	qlog.debug("GSPlayer:platformLoginAck", guid, accessToken, userId, userName)
	local c = PlayerMgr:getConnectByGuid(guid)
	if c then
		c.remote.GSCommand.platformLoginAck(accessToken, userId, userName)
	else
		qlog.debug("GSPlayer:platformLoginAck player disconnet", guid)
	end
end

function GSPlayer:updateOrderState(guid, orderId, state)
	if not GC then
		qlog.warn("GSPlayer:updateOrderState GC is disconnect")
		return false
	end
	
	qlog.debug("GSPlayer:updateOrderState ", guid, orderId, state)
	
	GC.remote.GSCommand.updateOrderStateReq(guid, orderId, state)
	return true
end

function GSPlayer:verifyOrder(guid, orderList)
	if not GC then
		qlog.warn("GSPlayer:verifyOrder GC is disconnect")
		self:verifyOrderAck(guid)
		return false
	end
	
	qlog.debug("GSPlayer:verifyOrder ", guid , toprettystring(orderList))
	
	GC.remote.GSCommand.verifyOrderReq(guid, orderList)
	return true
end

function GSPlayer:verifyOrderAck(guid, successOrders)
	qlog.debug("GSPlayer:verifyOrderAck", guid, toprettystring(successOrders))
	local c = PlayerMgr:getConnectByGuid(guid)
	if c then
		c.remote.GSCommand.verifyOrderAck(successOrders)
	else
		qlog.debug("GSPlayer:verifyOrderAck player disconnet", guid)
	end
end

return GSPlayer