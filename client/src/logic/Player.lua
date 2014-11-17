
local UserData = require "UserData"
local qlog = require "qlog"
local network = require "network"
local json = require "json"
local eventhub = require "eventhub"
local socket = require "socket"
local timer = require "timer"
local device = require "device"
local PlatformSDK = require "logic.PlatformSDK"
local OrderMgr = require "logic.OrderMgr"
local Buy = require "settings.Buy"
local ActLog = require "ActLog"

local wsHost = WS_LIST
local wsPort = 16801

Player = {}
GSCommand = {}

function GSCommand.verifyOrderAck(c, successOrders)
	Player:verifyOrderAck(c, successOrders)
end

function Player:enterGame()
	self:savaPlayerDataReq()
	
	-- 开始游戏后,每60s请求验证一次订单,同时当作心跳包
	self:verifyOrderReq()
	timer.new(60, function()
		self:verifyOrderReq()
	end)
end

function Player:getServerAddress(cbFunc)
	if self:checkServerAddress(self._serverIp, self._serverPort) then
		pcall(cbFunc, true)
		return
	end

	self:connectWS(function(c)
		if not c then
			pcall(cbFunc, false)
			return
		end
		
		local guid = UserData:getGuid()
		local h = c.remote.CLCommand.redirect(guid)
		h.onAck = function(ip, port, payUrl)
			if not ip then
				self.onGSClosed()
			end
			qlog.debug("getServerAddress", ip, port, payUrl)
			self._serverIp = ip
			self._serverPort = port
			PlatformSDK:setPayUrl(payUrl)
			c:close()
			if self:checkServerAddress(self._serverIp, self._serverPort) then
				pcall(cbFunc, true)
			else
				pcall(cbFunc, false)
			end
		end
	end)
end

function Player:checkServerAddress(ip, port)
	if ip and port then
		return true
	end
	
	return false
end

function Player:savaPlayerDataReq()
	self:connectAndLoginGS(function(c)
		if not c then
			return
		end
		
		self:incConnectGSCount()
		
		local guid = UserData:getGuid()
		local info = UserData:getSavaInfo()
		local h = c.remote.CLCommand.savaPlayerData(guid, info)
		h.onAck = function(result)
			qlog.debug("Player:savaPlayerDataReq ", result)
			self:decConnectGSCount()
		end
	end)
end

function Player:showMessageBox(strIndex, cbFunc)
	if strIndex == 7 then
		eventhub.fire("UI_EVENT", "PLAYER_PAY_CANCEL")
	elseif strIndex == 8 then
		eventhub.fire("UI_EVENT", "PLAYER_PAY_FAILED")
	end
	local tb = {}
	tb.strIndex = strIndex
	tb.fun = cbFunc
	eventhub.fire("UI_EVENT", "OPEN_MESSAGEBOX", tb)
end

function Player:sendOrderStatusToServer(guid, orderId, state)
	self:connectAndLoginGS(function(c)
		if not c then
			return
		end
		
		self:incConnectGSCount()
		local h = c.remote.CLCommand.updateOrderStateReq(guid, orderId, state)
		h.onAck = function(orderId)
			qlog.debug("Player:sendOrderStatusToServer finish")
			self:decConnectGSCount()
		end
	end)
end

function Player:verifyOrderReq()
	self:connectAndLoginGS(function(c)
		if not c then
			return
		end
		
		self:incConnectGSCount()
		local orderList = OrderMgr:getClientFinishOrders()
		qlog.debug("Player:verifyOrderReq client finish order list", toprettystring(orderList))
		
		local guid = UserData:getGuid()
		c.remote.CLCommand.verifyOrderReq(guid, orderList)
	end)
end

function Player:verifyOrderAck(c, serverFinishOrders)
	qlog.debug("Player:verifyOrderAck ", toprettystring(serverFinishOrders))
	
	if serverFinishOrders and #serverFinishOrders > 0 then
		OrderMgr:serverFinishOrders(serverFinishOrders)
	end
	
	self:decConnectGSCount()
end

function Player:getWSIp()
	if _TEST then
		return _TEST.wsIp, _TEST.wsPort
	end
	local ip, err = socket.dns.toip(wsHost[math.random(#wsHost)])
	if ip then
		return ip, wsPort
	end
	self.onResolveAddressFailed(err)
end

function Player:connectWS(cb)
	local ip, port = self:getWSIp()
	if not ip then
		cb(nil)
		return
	end
	
	network.connect(ip, port, function(c)
		if not c then
			self.onConnectWSFailed(ip, port)
		end
		
		cb(c)
	end)
end

function Player:connectGS(cb)
	if self._c then
		cb(self._c)
		return
	end
	
	if not self._connectingCbList then
		self._connectingCbList = {}
	end
	
	table.insert(self._connectingCbList, cb)
	if #self._connectingCbList > 1 then
		return
	end
	
	local connectCb = function(c)
		if not c then
			self.onConnectGSFailed(self._serverIp, self._serverPort)
			self._serverIp = nil
			self._serverPort = nil
		else
			c:addPrivilege("GSCommand", GSCommand)
			c.onClosed = function()
				self._c  = nil
			end
		end
		self._c = c
		
		for _, cb in ipairs (self._connectingCbList) do
			cb(c)
		end
		self._connectingCbList = nil
	end
	
	if not self:checkServerAddress(self._serverIp, self._serverPort) then
		self:getServerAddress(function(ok)
			if not ok then
				pcall(connectCb, nil)
				return
			end
			network.connect(self._serverIp, self._serverPort, connectCb)
		end)
		return
	end
	
	network.connect(self._serverIp, self._serverPort, connectCb)
end

function Player:connectAndLoginGS(cb)
	self:connectGS(function(c)
		if not c then
			cb(c)
			return
		end
		
		local guid = UserData:getGuid()
		local h = c.remote.CLCommand.login(guid, CLIENT_VERSION)
		h.onAck = function(result)
			qlog.debug("Player login", result)
			if not result or result == ERR_FAILED then
				self.onPlayerLoginFailed(result)
				return
			end
			
			if result == ERR_VERSION_UNMATCH then
				self.onPlayerLoginFailed("ERR_VERSION_UNMATCH")
				self:showMessageBox(5, function() platformSDK:exit() end)
				return
			end
			cb(c)
		end
	end)
end

function Player:incConnectGSCount()
	if not self._gsRefCount then
		self._gsRefCount = 0
	end
	
	self._gsRefCount = self._gsRefCount + 1
	qlog.debug("Player:incConnectGSCount ", self._gsRefCount)
end

function Player:decConnectGSCount()
	if not self._gsRefCount or self._gsRefCount < 1 then
		return
	end
	
	self._gsRefCount = self._gsRefCount - 1
	qlog.debug("Player:decConnectGSCount ", self._gsRefCount)
	if self._gsRefCount <=0 then
		self:disConnectGS()
	end
end

function Player:disConnectGS()
	if self._c then
		self._c:close()
		self._c = nil
	end
	
	self._gsRefCount = 0
end

function Player:getServerTime(cb)
	self:connectGS(function(c)
		if not c then
			cb(nil)
			return
		end
		local h = c.remote.CLCommand.getServerTime()
		h.onAck = cb
	end)
end

function Player:getLS()
	if not self._LSList or #self._LSList == 0 then
		return
	end
	local addr = self._LSList[math.random(#self._LSList)]
	if not addr then
		return
	end
	local ip, port = string.split(addr, ":")
	return {ip = ip, port = tonumber(port)}
end

function Player:connectLS(cb)
	if not self:getLS() then
		self:connectWS(function(c)
			if not c then
				cb()
				return
			end
			
			local h = c.remote.CLCommand.getLSList()
			h.onAck = function(LSList)
				--qlog.info("getLSList", todetailstring(LSList))
				self._LSList = LSList
				c:close()
				local addr = self:getLS()
				if not addr then
					cb()
					return
				end
				network.connect(addr.ip, addr.port, cb)
			end
		end)
		return
	end
	
	local addr = self:getLS()
	network.connect(addr.ip, addr.port, cb)
end

function Player:cmccPay(productId)
	local guid = UserData:getGuid()
	local orderId = OrderMgr:newOrder(guid, productId, "CMCC")
	PlatformSDK:cmccPay(productId, 1, orderId)
end

function Player:onGotMMOrderFromSDK(result)
	qlog.debug("Player:onGotMMOrderFromSDK ", result)
	
	local tradeId, orderId = string.split(result, ",")
	if not self._cmccTradeList then
		self._cmccTradeList = {}
	end
	
	self._cmccTradeList[tradeId] = orderId
end

function Player:onGotMMIAPFromSDK(resultJson)
	qlog.debug("Player:onGotMMIAPFromSDK ", resultJson)
	local result = json.decode(resultJson)
	print(toprettystring(result))
	
	if not self._cmccTradeList or not self._cmccTradeList[result.TradeID] then
		qlog.warn("Player:onGotMMIAPFromSDK lost order", resultJson, toprettystring(self._cmccTradeList))
		return
	end
	
	local orderId = self._cmccTradeList[result.TradeID]
	if result.code == "1" then
		if OrderMgr:getOrderState(orderId) < ORDER_STATE_CLIENT_PAYED then
			self:showMessageBox(10)
			OrderMgr:clientFinishOrder(orderId)
			self:sendOrderStatusToServer(UserData:getGuid(), orderId, ORDER_STATE_CLIENT_PAYED)
		end
	else
		self:showMessageBox(8)
		OrderMgr:delOrder(orderId)
	end
end

function Player:smsPay(productId)
	PlatformSDK:smsPay(productId)
end

function Player:onGotCmccSmsIapFromSDK(result)
	qlog.debug("Player:onGotCmccSmsIapFromSDK", result)
	local ok, reason, paycode, tradeid, orderId = result:split(",")
	local productId = Buy:getProductIdByCmccSmsPayCode(paycode)
		
	if ok == "1" then
		if OrderMgr:smsOrderFinish(orderId) then
			self:showMessageBox(10)
			ActLog:smsPaySucceed(productId, paycode, tradeid)
		end
	else
		OrderMgr:delSmsOrder(orderId)
		self:showMessageBox(8)
		ActLog:smsPayFailed(paycode, reason)
	end
end

function Player:onGotCuccSmsIapFromSDK(result)
	qlog.debug("Player:onGotCuccSmsIapFromSDK", result)
	local ok, paycode, orderId = result:split(",")
	local productId = Buy:getProductIdByCuccSmsPayCode(paycode)
		
	if ok == "1" then
		if OrderMgr:smsOrderFinish(orderId) then
			self:showMessageBox(10)
			ActLog:smsPaySucceed(productId, paycode, orderId)
		end
	else
		OrderMgr:delSmsOrder(orderId)
		self:showMessageBox(8)
		ActLog:smsPayFailed(paycode, "failed")
	end
end

function Player:onGotCtccSmsIapFromSDK(result)
	qlog.debug("Player:onGotCtccSmsIapFromSDK", result)
	local ok, paycode, orderId = result:split(",")
	local productId = Buy:getProductIdByCtccSmsPayCode(paycode)
		
	if ok == "1" then
		if OrderMgr:smsOrderFinish(orderId) then
			self:showMessageBox(10)
			ActLog:smsPaySucceed(productId, paycode, orderId)
		end
	else
		OrderMgr:delSmsOrder(orderId)
		self:showMessageBox(8)
		ActLog:smsPayFailed(paycode, "failed")
	end
end

function Player:platformQuitReq()
	PlatformSDK:quit()
end

--不同平台Player逻辑扩展
if VERSION_OPTION:find("Qihoo") then
	require "logic.Player_Qihoo"
end

return Player