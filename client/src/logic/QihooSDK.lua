local ActLog = require "ActLog"

local QihooSDK = {}

function QihooSDK:login()
	if not MOAIJavaVM then
		return
	end
	MOAIJavaVM.runJava("qihoo_login")
end

function QihooSDK:setPayUrl(value)
	if not MOAIJavaVM then
		return
	end
	
	MOAIJavaVM.runJava("qihoo_setpayurl,"..value)
end

function QihooSDK:loginSuccess(accessToken, qihooUserId, qihooUserName)
	if not MOAIJavaVM then
		return
	end
	MOAIJavaVM.runJava("qihoo_loginsuccess,"..accessToken..","..qihooUserId..","..qihooUserName)
end

function QihooSDK:switchAccount()
	if not MOAIJavaVM then
		return
	end
	MOAIJavaVM.runJava("qihoo_switchaccount")
end

function QihooSDK:quit()
	if not MOAIJavaVM then
		return
	end
	ActLog:exitGame()
	MOAIJavaVM.runJava("qihoo_quit")
end

function QihooSDK:pay(playerId, productId, productName, price, orderId)
	if not MOAIJavaVM then
		return
	end
	
	price = price * EXCHANGE_RATE
	local payToken = "qihoo_pay,"..playerId..","..productId..","..productName..","..price..","..orderId
	MOAIJavaVM.runJava(payToken)
end

return QihooSDK