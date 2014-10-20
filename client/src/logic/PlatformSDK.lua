local ActLog = require "ActLog"
local UserData = require "UserData"
local QihooSDK = require "logic.QihooSDK"
local ProviderSDK = require "logic.ProviderSDK"
local Buy = require "settings.Buy"
local OrderMgr = require "logic.OrderMgr"
local qlog = require "qlog"

local PlatformSDK = {}

function PlatformSDK:getPhoneNumber()
	if not MOAIJavaVM then
		return
	end
	
	return MOAIJavaVM.runJava("getphonenumber")
end

function PlatformSDK:getPhoneProvider()
	if not MOAIJavaVM then
		return
	end
	
	return MOAIJavaVM.runJava("getphoneprovider")
end

function PlatformSDK:login()
	QihooSDK:login()
end

function PlatformSDK:setPayUrl(value)
	if VERSION_OPTION:find("Qihoo") then
		QihooSDK:setPayUrl(value)
	end
end

function PlatformSDK:loginSuccess(accessToken, qihooUserId, qihooUserName)
	QihooSDK:loginSuccess(accessToken, qihooUserId, qihooUserName)
end

function PlatformSDK:switchAccount()
	QihooSDK:switchAccount()
end

function PlatformSDK:quit()
	if not VERSION_OPTION:find("Qihoo") then
		self:exit()
	else
		QihooSDK:quit()
	end
end

function PlatformSDK:exit()
	if not MOAIJavaVM then
		return
	end
	MOAIJavaVM.runJava("exit")
end

function PlatformSDK:pay(playerId, productId, orderId)
	local tb = Buy:getRMBProductInfo(productId)
	QihooSDK:pay(playerId, productId, tb.name, tb.src, orderId)
end

function PlatformSDK:cmccPay(productId, num, orderId)
	local tb = Buy:getRMBProductInfo(productId)
	if not tb.cmcc_paycode then
		qlog.warn("product do not hava cmcc_paycode", productId)
		return
	end
	
	ProviderSDK:cmccPay(tb.cmcc_paycode, num, orderId)
end

function PlatformSDK:smsPay(productId)
	local guid = UserData:getGuid()
	
	local tb = Buy:getRMBProductInfo(productId)
	local provider = self:getPhoneProvider()
	
	if provider == "CMCC" then
		if tb.cmcc_sms_paycode then
			local orderId = OrderMgr:newSmsOrder(guid, productId, "CMCC")
			ProviderSDK:cmccSmsPay(tb.cmcc_sms_paycode, orderId)
		else
			qlog.warn("product do not hava cmcc_sms_paycode", productId)
		end
		
		return
	elseif provider == "CUCC" then
		if tb.cucc_sms_paycode then
			local orderId = OrderMgr:newSmsOrder(guid, productId, "CUCC")
			ProviderSDK:cuccSmsPay(tb.cucc_sms_paycode, orderId)
		else
			qlog.warn("product do not hava cucc_sms_paycode", productId)
		end
		
		return
	elseif provider == "CTCC" then
		if tb.ctcc_sms_paycode then
			local orderId = OrderMgr:newSmsOrder(guid, productId, "CTCC")
			ProviderSDK:ctccSmsPay(tb.ctcc_sms_paycode, orderId)
		else
			qlog.warn("product do not hava ctcc_sms_paycode", productId)
		end
		
		return
	else
		qlog.warn("provider unsupport", provider)
	end
	
end

return PlatformSDK