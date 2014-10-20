
local UserData = require "UserData"
local qlog = require "qlog"
local Buy = require "settings.Buy"
local ActLog = require "ActLog"
local eventhub = require "eventhub"

local OrderMgr = {}
function OrderMgr:init()
	if not UserData.orderList then
		UserData.orderList = {}
	end
	
	if not UserData.smsOrderList then
		UserData.smsOrderList = {}
	end
end

function OrderMgr:encodeOrder(guid, idx, timeStamp, channel)
	return guid.."#"..idx.."#"..timeStamp.."#"..channel
end

function OrderMgr:decodeOrder(order)
	local guid, idx, timeStamp, channel = string.split(order, "#")
	return guid, tonumber(idx), tonumber(timeStamp), channel
end

function OrderMgr:newOrder(guid, idx, channel)
	local order = self:encodeOrder(guid, idx, os.time(), channel)
	
	qlog.info("OrderMgr:newOrder", order)
	self:setOrderState(order, ORDER_STATE_UNPAY)
	
	return order
end

function OrderMgr:clientFinishOrder(order)
	qlog.info("OrderMgr:clientFinishOrder", order)
	if self:getOrderState(order) < ORDER_STATE_CLIENT_PAYED then
		self:setOrderState(order, ORDER_STATE_CLIENT_PAYED)
		self:_orderEffect(order)
	end
end

function OrderMgr:serverFinishOrder(order)
	qlog.info("OrderMgr:serverFinishOrder", order)
	
	if self:getOrderState(order) < ORDER_STATE_CLIENT_PAYED then
		self:setOrderState(order, ORDER_STATE_FINISHED)
		self:_orderEffect(order)
	end
end

function OrderMgr:delOrder(order)
	qlog.info("OrderMgr:delOrder", order)
	
	self:setOrderState(order, nil)
end

function OrderMgr:setOrderState(order, state)
	qlog.info("OrderMgr:setOrderState", order, state)

	if not order then
		qlog.info("OrderMgr:setOrderState error orderid", order, state)
		return
	end
	
	UserData.orderList[order] = state
	UserData:save()
end

function OrderMgr:getOrderState(order)
	qlog.info("OrderMgr:getOrderState", order)
	if not UserData.orderList[order] then
		return ORDER_STATE_NONE
	end
	
	return UserData.orderList[order]
end

function OrderMgr:getClientFinishOrders()
	local unfinishList = {}
	for order, state in pairs (UserData.orderList) do
		if state == ORDER_STATE_CLIENT_PAYED then
			unfinishList[order] = state
		end
	end
	
	return unfinishList
end

function OrderMgr:serverFinishOrders(orders)
	if not orders then
		qlog.debug("OrderMgr:serverFinishOrders empty orders")
		return
	end
	
	for _, order in pairs (orders) do
		self:serverFinishOrder(order)
	end
	
	self:removeFinishedOrders()
end

function OrderMgr:removeFinishedOrders()
	local finishList = {}
	for order, state in pairs (UserData.orderList) do
		if state == ORDER_STATE_FINISHED then
			table.insert(finishList, order)
		end
	end
	
	if #finishList > 0 then
		for _, order in pairs (finishList) do
			UserData.orderList[order] = nil
			qlog.info("OrderMgr:removeFinishedOrders", order)
		end
		
		UserData:save()
	end
end

function OrderMgr:_orderEffect(order)
	qlog.info("OrderMgr:_orderEffect", order)
	local guid, idx = self:decodeOrder(order)
	self:doOrder(idx)
end

function OrderMgr:doOrder(idx)
	assert(idx)
	
	local tb = Buy:getRMBProductInfo(idx)
	assert(tb, "wrong idx:"..tostring(idx))
	
	ActLog:RMBPayEnd(idx)
	
	if tb.dest_type == "money" then
		self:buyMoney(tb)
	elseif tb.dest_type == "gold" then
		self:buyGold(tb)
	elseif tb.dest_type == "randombox" then
		self:buyRandomBox(tb)
	elseif tb.dest_type == "gift_bag" then
		self:buyGiftBag(tb)
	elseif tb.dest_type == "unlock_pet" then
		self:buyPet(tb)
	elseif tb.dest_type == "unlock_robot" then
		self:buyRobot(tb)
	else
		assert(false, "wrong dest type:"..tb.dest_type )
	end
	
	eventhub.fire("TASK_EVENT", "ORDER_SUCCESS", 1, idx)
end

function OrderMgr:buyMoney(tb)
	UserData:addMoney(tb.dest)
	
	local tbParam = {}
	tbParam.type = "money"
	tbParam.way = "charge"
	tbParam.num = tb.dest
	eventhub.fire("UI_EVENT", "OPEN_REWARD_PANEL", tbParam)
	
	eventhub.fire("UI_EVENT", "REFRESH_BUY_PANEL", "rmbtomoney")
	
	eventhub.fire("UI_EVENT", "PLAYER_PAY_SUCCESS")
end

function OrderMgr:buyGold(tb)
	UserData:addGold(tb.dest)
	
	local tbParam = {}
	tbParam.type = "gold"
	tbParam.way = "charge"
	tbParam.num = tb.dest
	eventhub.fire("UI_EVENT", "OPEN_REWARD_PANEL", tbParam)
end

function OrderMgr:buyRandomBox(tb)
	eventhub.fire("SYSTEM_EVENT", "BUY_RANDOMBOX", tb.dest)
end

function OrderMgr:buyGiftBag(tb)
	eventhub.fire("SYSTEM_EVENT", "BUY_GIFT_BAG", tb.dest)
	eventhub.fire("UI_EVENT", "REFRESH_SHOP_PANEL")
end

function OrderMgr:buyPet(tb)
	UserData:petUnlockExecute(tb.dest)
	eventhub.fire("UI_EVENT", "REFRESH_SHOP_PANEL")
end

function OrderMgr:buyRobot(tb)
	UserData:robotUnlockExecute(tb.dest)
	eventhub.fire("UI_EVENT", "REFRESH_SHOP_PANEL")
	eventhub.fire("UI_EVENT", "SUPERSKILL_ROBOT", tb.dest)
end

function OrderMgr:getOrderByProductId(productId)
	for order, state in pairs (UserData.orderList) do
		local guid, idx = self:decodeOrder(order)
		if productId == idx then
			return order
		end
	end
end


-------------------------------sms order--------------------------------------

function OrderMgr:newSmsOrder(guid, idx, channel)
	local order = self:encodeOrder(guid, idx, os.time(), channel)
	qlog.info("OrderMgr:newSmsOrder", order)
	
	self:setSmsOrderState(order, ORDER_STATE_UNPAY)
	
	return order
end

function OrderMgr:delSmsOrder(order)
	qlog.info("OrderMgr:delSmsOrder", order)
	
	self:setSmsOrderState(order, nil)
end

function OrderMgr:getSmsOrderState(order)
	for o, state in pairs (UserData.smsOrderList) do
		if o == order then
			return state
		end
	end
end

function OrderMgr:setSmsOrderState(order, state)
	qlog.info("OrderMgr:setSmsOrderState", order, state)

	if not order then
		qlog.warn("OrderMgr:setSmsOrderState error orderid", order, state)
		return
	end
	
	UserData.smsOrderList[order] = state
	UserData:save()
end

function OrderMgr:smsOrderFinish(order)
	qlog.info("OrderMgr:smsOrderFinish", order)
	
	local state = self:getSmsOrderState(order)
	if not state or state == ORDER_STATE_FINISHED then
		qlog.warn("OrderMgr:smsOrderFinish error orderid", order, state)
		return false
	end
	
	self:setSmsOrderState(order, ORDER_STATE_FINISHED)
	self:_orderEffect(order)
	
	return true
end

return OrderMgr