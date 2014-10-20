-- 360相关Player逻辑

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
local NetworkTipPanel = require "windows.NetworkTipPanel"
local Buy = require "settings.Buy"

function Player:qihooInit()
	-- 绑定支付事件
	eventhub.bind("SYSTEM_EVENT", "PLAYER_PAY", function(productId) self:pay(productId) end)
end

function GSCommand.platformLoginAck(c, accessToken, userId, userName)
	Player:platformLoginAck(c, accessToken, userId, userName)
end

function Player:platformLogin()
	self:getAuthCodeFromSDK()
end

function Player:getAuthCodeFromSDK()
	PlatformSDK:login()
end

function Player:onGotAuthCodeFromSDK(authCode)
	qlog.debug("Player:onGotAuthCodeFromSDK ", authCode)
	self:connectAndLoginGS(function(c)
		if not c then
			-- 服务器未开
			NetworkTipPanel:open("server")
			return
		end
		
		self:incConnectGSCount()
		local guid = UserData:getGuid()
		c.remote.CLCommand.platformLoginReq(guid, authCode)
	end)
end

function Player:platformLoginAck(c, accessToken, userId, userName)
	qlog.debug("Player:platformLoginAck", c, accessToken, userId, self._platformLoginCBFunc)

	self:decConnectGSCount()
	
	if not accessToken or not userId or not userName or accessToken == "" or userId == "" then
		self:platformLogin()
		return
	end
		
	PlatformSDK:loginSuccess(accessToken, userId, userName)
end

function Player:onLoginSuccessFromSDK(result)
	qlog.debug("Player:onLoginSuccessFromSDK", result, self._platformLoginCBFunc)
	if result then
		Player._platformLogin = true
		
		if self._platformLoginCBFunc then
			pcall(self._platformLoginCBFunc)
			self._platformLoginCBFunc = nil
		end
	else
		Player._platformLogin = false
		
		self:showMessageBox(6)
	end
end

function Player:platformSwitchAccountReq()
	PlatformSDK:switchAccount()
end

function Player:pay(idx)
	if UserData:isSimplePayChannel() then
		local tb = Buy:getRMBProductInfo(idx)
		local provider = PlatformSDK:getPhoneProvider()
		if tb.cmcc_paycode and provider == "CMCC" then
			Player:cmccPay(idx)
		else
			Player:qihooPay(idx)
		end
	else
		eventhub.fire("SYSTEM_EVENT", "OPEN_PAY_CHANNEL_PANEL", idx)
	end
end

function Player:qihooPay(idx)
	if self._payingOrder then
		qlog.debug("Player:pay is paying")
		return
	end
	
	-- 手机未开网络
	if not device.getConnectionType() then
		NetworkTipPanel:open("device")
		return
	end
	
	local guid = UserData:getGuid()
	local orderId = OrderMgr:newOrder(guid, idx, "qihoo")
	if orderId then
		self:platformPayReq(idx, orderId)
	end
end

function Player:platformPayReq(productId, orderId)
	qlog.debug("Player:platformPayReq", productId, orderId)
	
	if Player._platformLogin then
		self._payingOrder = orderId
		PlatformSDK:pay(UserData:getGuid(), productId, orderId)
	else
		self._platformLoginCBFunc = function()
			self:platformPayReq(productId, orderId)
		end
		
		self:platformLogin()
	end
end

function Player:platformPayAck(resultJson)
	qlog.debug("Player:platformPayAck", resultJson, self._payingOrder)
	local result = json.decode(resultJson)
	print(toprettystring(result))
	
	if not self._payingOrder then
		qlog.warn("Player:OnPlatformPay no paying order", self._payingOrder)
		return
	end
	
	-- 0 支付成功， -1 支付取消， 1 支付失败， -2 支付进行中
	if result.error_code == "0" then
		if OrderMgr:getOrderState(self._payingOrder) < ORDER_STATE_CLIENT_PAYED then
			self:showMessageBox(10)
			OrderMgr:clientFinishOrder(self._payingOrder)
			self:sendOrderStatusToServer(UserData:getGuid(), self._payingOrder, ORDER_STATE_CLIENT_PAYED)
		end
		
	elseif result.error_code == "-1" then
		self:showMessageBox(7)
		OrderMgr:delOrder(self._payingOrder)
		
	elseif result.error_code == "1" then
		self:showMessageBox(8)
		OrderMgr:delOrder(self._payingOrder)
		
	elseif result.error_code == "2" then
		self:showMessageBox(9)
		self:sendOrderStatusToServer(UserData:getGuid(), self._payingOrder, ORDER_STATE_UNPAY)
		
	end

	self._payingOrder = nil
end