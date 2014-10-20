
local qlog = require "qlog"
local GCPlayer = require "GCPlayer"

local SdkBillingMsgHandle = {}

function SdkBillingMsgHandle:receive(msg)
	qlog.debug("SdkBillingMsgHandle:receive ", msg)
	
	local tb = {string.split(msg, ",")}
	if tb[1] == "pay" then
		if #tb ~= 7 then
			qlog.warn("SdkBillingMsgHandle:receive pay error param")
			return
		end
		
		local guid 		= tb[2]
		local amount 	= tonumber(tb[3])
		local orderId 	= tb[4]
		local payWay 	= tb[5] 	--暂时无用
		local platformId = tonumber(tb[6])
		local puid 		= tb[7]		--暂时无用
		
		GCPlayer:payAck(guid, amount, orderId, platformId)
	end
end

return SdkBillingMsgHandle