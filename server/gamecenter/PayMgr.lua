
local qlog = require "qlog"
local Buy = require "Buy"
local DBMgr = require "DBMgr"
local LogDB = require "LogDB"
local GUID = require "guid"

local PayMgr = {}
PayMgr._playerOrderList = {}

function PayMgr:init()
	if not DBMgr:initOrderList(self._playerOrderList) then
		qlog.warn("PayMgr init fail")
		return
	end
	
	-- qlog.debug("PayMgr init success!", toprettystring(self._playerOrderList))
end

-- function PayMgr:encodeOrder(guid, idx, timeStamp)
	-- return guid.."#"..idx.."#"..timeStamp
-- end

function PayMgr:decodeOrder(orderId)
	local guid, idx, timeStamp, channel = string.split(orderId, "#")
	return guid, tonumber(idx), tonumber(timeStamp), channel
end

function PayMgr:newOrder(guid, orderId)
	if not guid or not orderId then
		qlog.warn("PayMgr:newOrder error order", guid, orderId)
		return
	end

	if not self._playerOrderList[guid] then
		self._playerOrderList[guid] = {}
	end
	
	if self._playerOrderList[guid][orderId] then
		qlog.warn("PayMgr:newOrder already has this order", guid, orderId, self._playerOrderList[guid][orderId])
		return
	end
	self._playerOrderList[guid][orderId] = ORDER_STATE_UNPAY;
	DBMgr:updateOrder(orderId, guid, self._playerOrderList[guid][orderId])
	
	qlog.info("PayMgr:newOrder ", guid, orderId)
	LogDB:writeActLog(guid, GUID.generate(), 1, os.date("%Y-%m-%d %H:%M:%S"), "newOrder_gc", "guid:"..guid.." ".."order:"..orderId.." ".."state:"..self._playerOrderList[guid][orderId])
end

-- function PayMgr:generateOrder(guid, idx)
	-- if not guid or not idx then
		-- qlog.warn("PayMgr:generateOrder fail", guid, idx)
		-- return ""
	-- end

	-- if not self._playerOrderList[guid] then
		-- self._playerOrderList[guid] = {}
	-- end
	
	-- local curTime = os.time()
	-- local orderId = self:encodeOrder(guid, idx, curTime)
	-- self._playerOrderList[guid][orderId] = ORDER_STATE_UNPAY;
	
	-- qlog.info("PayMgr:generateOrder success", guid, orderId, os.date("%c", curTime))
	
	-- DBMgr:updateOrder(orderId, guid, self._playerOrderList[guid][orderId])
	
	-- return orderId
-- end

function PayMgr:clientPayedOrder(guid, orderId)
	if not guid or not orderId then
		qlog.warn("PayMgr:clientPayedOrder fail", guid, orderId)
		return false
	end

	if not self._playerOrderList[guid] then
		self._playerOrderList[guid] = {}
	end
	
	if not self._playerOrderList[guid][orderId] then
		self._playerOrderList[guid][orderId] = ORDER_STATE_UNPAY
	end
	
	if self._playerOrderList[guid][orderId] >= ORDER_STATE_CLIENT_PAYED then
		-- qlog.warn("PayMgr:clientPayedOrder error order state", guid, orderId, self._playerOrderList[guid][orderId])
		return false
	end
	
	self._playerOrderList[guid][orderId] = ORDER_STATE_CLIENT_PAYED
	
	
	DBMgr:updateOrder(orderId, guid, self._playerOrderList[guid][orderId])
	
	qlog.info("PayMgr:clientPayedOrder success", guid, orderId, os.date("%c", curTime))
	LogDB:writeActLog(guid, GUID.generate(), 1, os.date("%Y-%m-%d %H:%M:%S"), "clientPayedOrder_gc", "guid:"..guid.." ".."order:"..orderId.." ".."state:"..self._playerOrderList[guid][orderId])
	return true
end

function PayMgr:cancelOrder(guid, orderId)
	if not guid or not orderId then
		qlog.warn("PayMgr:cancelOrder fail", guid, orderId)
		return
	end

	if not self._playerOrderList[guid] or not self._playerOrderList[guid][orderId] then
		qlog.warn("PayMgr:cancelOrder error orderId", guid, orderId)
		return
	end
	
	self._playerOrderList[guid][orderId] = nil
	DBMgr:deleteOrder(orderId)
	
	qlog.info("PayMgr:cancelOrder success", guid, orderId)
	LogDB:writeActLog(guid, GUID.generate(), 1, os.date("%Y-%m-%d %H:%M:%S"), "cancelOrder_gc", "guid:"..guid.." ".."order:"..orderId)
end

function PayMgr:recvOrder(guid, amount, orderId, platformId)
	if PLATFORM_ID ~= platformId then
		qlog.warn("PayMgr:recvOrder error platform", guid, orderId, PLATFORM_ID, platformId)
		return false
	end
	
	local order_guid, productId = self:decodeOrder(orderId)
	if guid ~= order_guid then
		qlog.warn("PayMgr:recvOrder error guid", guid, order_guid, orderId)
		return false
	end
	
	local productInfo = Buy:getRMBProductInfo(productId)
	if productInfo.src*EXCHANGE_RATE ~= amount then
		qlog.warn("PayMgr:recvOrder error price", guid, productInfo.src, amount, orderId)
		return false
	end
	
	-- 客户端未把订单提交到gs
	if not self._playerOrderList[guid] then
		self._playerOrderList[guid] = {}
	end
	
	-- 客户端未把订单提交到gs
	if not self._playerOrderList[guid][orderId] then
		qlog.info("PayMgr:recvOrder client has not send this order to server", guid, orderId)
		self._playerOrderList[guid][orderId] = ORDER_STATE_UNPAY
	end
	
	-- 此时订单状态可能为
	-- ORDER_STATE_UNPAY 		
	-- ORDER_STATE_CLIENT_PAYED
	-- 因为CLIENT可能没把客户端已支付的状态同步到SERVER
	
	if self._playerOrderList[guid][orderId] == ORDER_STATE_FINISHED then
		qlog.warn("PayMgr:recvOrder order already finished", guid, orderId, self._playerOrderList[guid][orderId])
		return false
	end
	
	-- 订单状态已经是ORDER_STATE_SERVER_PAYED
	if self._playerOrderList[guid][orderId] == ORDER_STATE_SERVER_PAYED then
		return false
	end
	
	self._playerOrderList[guid][orderId] = ORDER_STATE_SERVER_PAYED
	DBMgr:updateOrder(orderId, guid, self._playerOrderList[guid][orderId])
	
	qlog.debug("PayMgr:recvOrder orderId set ORDER_STATE_SERVER_PAYED", guid, orderId)
	LogDB:writeActLog(guid, GUID.generate(), 1, os.date("%Y-%m-%d %H:%M:%S"), "recvOrder_gc", "guid:"..guid.." ".."order:"..orderId.." ".."state:"..self._playerOrderList[guid][orderId])
	return true
end

function PayMgr:recvCMCCOrder(orderId)
	local guid, idx = self:decodeOrder(orderId)
	if not guid or not idx then
		qlog.warn("PayMgr:recvCMCCOrder error order", guid, idx, orderId)
		return false
	end
	
	-- 客户端未把订单提交到gs
	if not self._playerOrderList[guid] then
		self._playerOrderList[guid] = {}
	end
	
	-- 客户端未把订单提交到gs
	if not self._playerOrderList[guid][orderId] then
		qlog.info("PayMgr:recvCMCCOrder client has not send this order to server", guid, orderId)
		self._playerOrderList[guid][orderId] = ORDER_STATE_UNPAY
	end
	
	-- 此时订单状态可能为
	-- ORDER_STATE_UNPAY 		
	-- ORDER_STATE_CLIENT_PAYED
	-- 因为CLIENT可能没把客户端已支付的状态同步到SERVER
	
	if self._playerOrderList[guid][orderId] == ORDER_STATE_FINISHED then
		qlog.warn("PayMgr:recvCMCCOrder order already finished", guid, orderId, self._playerOrderList[guid][orderId])
		return false
	end
	
	-- 订单状态已经是ORDER_STATE_SERVER_PAYED
	if self._playerOrderList[guid][orderId] == ORDER_STATE_SERVER_PAYED then
		return false
	end
	
	self._playerOrderList[guid][orderId] = ORDER_STATE_SERVER_PAYED
	DBMgr:updateOrder(orderId, guid, self._playerOrderList[guid][orderId])
	
	qlog.debug("PayMgr:recvCMCCOrder orderId set ORDER_STATE_SERVER_PAYED", guid, orderId)
	LogDB:writeActLog(guid, GUID.generate(), 1, os.date("%Y-%m-%d %H:%M:%S"), "recvCMCCOrder_gc", "guid:"..guid.." ".."order:"..orderId.." ".."state:"..self._playerOrderList[guid][orderId])
	return true
end

function PayMgr:verifyOrderList(guid, clientOrderList)
	if not clientOrderList then
		clientOrderList = {}
	end
	
	qlog.debug("PayMgr:verifyOrderList client", guid, toprettystring(clientOrderList))
	
	local successOrders = {}
	local serverOrderList = self._playerOrderList[guid]
	if not serverOrderList then
		qlog.warn("PayMgr:verifyOrderList player don't have order", guid)
		return successOrders
	end
	
	qlog.debug("PayMgr:verifyOrderList server", guid, toprettystring(serverOrderList))
	
	for orderId, state in pairs (serverOrderList) do
		if state == ORDER_STATE_SERVER_PAYED then
			qlog.info("PayMgr:verifyOrderList orderId set FINISHED", guid, orderId)
			
			serverOrderList[orderId] = ORDER_STATE_FINISHED
			clientOrderList[orderId] = nil
			table.insert(successOrders, orderId)
			
			DBMgr:updateOrder(orderId, guid, serverOrderList[orderId])
		elseif state == ORDER_STATE_FINISHED then
			if clientOrderList[orderId] and clientOrderList[orderId] ~= ORDER_STATE_FINISHED then
				clientOrderList[orderId] = nil
				table.insert(successOrders, orderId)
			end
		end
	end
	
	if #clientOrderList > 0 then 
		for orderId, state in pairs (clientOrderList) do
			if state == ORDER_STATE_CLIENT_PAYED and serverOrderList[orderId] and serverOrderList[orderId] < ORDER_STATE_CLIENT_PAYED then
				qlog.info("PayMgr:verifyOrderList client payed, but not server", guid, orderId)
				
				serverOrderList[orderId] = ORDER_STATE_CLIENT_PAYED
				DBMgr:updateOrder(orderId, guid, serverOrderList[orderId])
			end
		end
	end
	
	if #successOrders > 0 then
		LogDB:writeActLog(guid, GUID.generate(), 1, os.date("%Y-%m-%d %H:%M:%S"), "verifyOrderList_gc", "guid:"..guid.." ".."successOrders:"..toprettystring(successOrders))
	end
	return successOrders
end

function PayMgr:setOrderState(guid, orderId, state)
	if not self._playerOrderList or not self._playerOrderList[guid] or not self._playerOrderList[guid][orderId] then
		qlog.warn("PayMgr:setOrderState orderId not exist", guid, orderId, state)
		return false
	end
	
	if self._playerOrderList[guid][orderId] == state or self._playerOrderList[guid][orderId] == ORDER_STATE_FINISHED then
		qlog.warn("PayMgr:setOrderState order state warning", guid, orderId, state, self._playerOrderList[guid][orderId])
		return false
	end
	
	self._playerOrderList[guid][orderId] = state
	DBMgr:updateOrder(orderId, guid, self._playerOrderList[guid][orderId])
	
	qlog.debug("PayMgr:setOrderState orderId", guid, orderId, state)
	LogDB:writeActLog(guid, GUID.generate(), 1, os.date("%Y-%m-%d %H:%M:%S"), "setOrderState_gc", "guid:"..guid.." ".."order:"..orderId.." ".."state:"..self._playerOrderList[guid][orderId])
	return true
end

return PayMgr