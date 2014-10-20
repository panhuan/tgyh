
local qlog = require "qlog"
local GSMgr = require "GSMgr"
local PayMgr = require "PayMgr"
local DBMgr = require "DBMgr"
local json = require "json"

local GCPlayer = {}

function GCPlayer:savaData(guid, data)
	local jsonStr = json.encode(data)
	qlog.debug("GCPlayer:saveData ", guid, jsonStr)
	
	DBMgr:savePlayerData(guid, jsonStr)
	return true
end

function GCPlayer:loadData(guid)
	local jsonStr = DBMgr:loadPlayerData(guid)
	qlog.debug("GCPlayer:loadData ", guid, jsonStr)
	
	if not jsonStr then
		return
	end
	
	local data = json.decode(jsonStr) 
	qlog.debug("GCPlayer:loadData ", toprettystring(data))
end

function GCPlayer:platformLogin(guid, authcode, gsId)
	if not SDK_GATE then
		qlog.warn("GCPlayer:platformLogin SDK_GATE is disconnect")
		self:platformLoginAck(guid)
		return
	end
	
	qlog.debug("GCPlayer:platformLogin ", guid , authcode)
	
	local str = "login,"..PLATFORM_ID..","..authcode..","..guid..","..gsId.."\n"
	SDK_GATE:send(str)
end

function GCPlayer:platformLoginAck(guid, accessToken, userId, userName, gsid)
	qlog.debug("GCPlayer:platformLoginAck", guid, accessToken, userId, userName, gsid)
	local gs = GSMgr:getConnectByGsid(gsid)
	if gs then
		gs.remote.GCCommand.platformLoginAck(guid, accessToken, userId, userName)
	else
		qlog.debug("GCPlayer:platformLoginAck gs disconnet", gsid)
	end
end

function GCPlayer:updateOrderState(guid, orderId, state)
	if not guid or not orderId or not state then
		qlog.warn("GCPlayer:updateOrderState error order state", guid, orderId, state)
		return false
	end
	
	if state == ORDER_STATE_CLIENT_PAYED then
		return PayMgr:clientPayedOrder(guid, orderId)
	elseif state == ORDER_STATE_NONE then
		return PayMgr:cancelOrder(guid, orderId)
	elseif state == ORDER_STATE_UNPAY then
		return PayMgr:newOrder(guid, orderId)
	else
		qlog.warn("GCPlayer:updateOrderState error order state", guid, orderId, state)
		return false
	end
end

function GCPlayer:payAck(guid, amount, orderId, platformId)
	PayMgr:recvOrder(guid, amount, orderId, platformId)
end

function GCPlayer:cmccPayAck(orderId)
	PayMgr:recvCMCCOrder(orderId)
end

function GCPlayer:verifyOrder(guid, orderList, gsid)
	local successOrders = PayMgr:verifyOrderList(guid, orderList)
	self:verifyOrderAck(guid, successOrders, gsid)
end

function GCPlayer:verifyOrderAck(guid, successOrders, gsid)
	local gs = GSMgr:getConnectByGsid(gsid)
	if gs then
		gs.remote.GCCommand.verifyOrderAck(guid, successOrders)
	else
		qlog.debug("GCPlayer:verifyOrderAck gs disconnet", gsid)
	end
end

return GCPlayer