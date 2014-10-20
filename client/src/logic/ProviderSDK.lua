
local ProviderSDK = {}

function ProviderSDK:cmccPay(paycode, num, orderId)
	if not MOAIJavaVM then
		return
	end
	
	local payToken = "cmcc_pay,"..paycode..","..num..","..orderId
	MOAIJavaVM.runJava(payToken)

end

function ProviderSDK:cmccSmsPay(paycode, orderId)
	if not MOAIJavaVM then
		return
	end
	
	local payToken = "cmcc_sms_pay,"..paycode..","..orderId
	MOAIJavaVM.runJava(payToken)
end

function ProviderSDK:cuccSmsPay(paycode, orderId)
	if not MOAIJavaVM then
		return
	end
	
	local payToken = "cucc_sms_pay,"..paycode..","..orderId
	MOAIJavaVM.runJava(payToken)
end

function ProviderSDK:ctccSmsPay(paycode, orderId)
	if not MOAIJavaVM then
		return
	end
	
	local payToken = "ctcc_sms_pay,"..paycode..","..orderId
	MOAIJavaVM.runJava(payToken)
end

return ProviderSDK