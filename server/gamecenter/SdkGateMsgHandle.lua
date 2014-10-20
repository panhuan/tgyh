
local qlog = require "qlog"
local GCPlayer = require "GCPlayer"

local SdkGateMsgHandle = {}

function SdkGateMsgHandle:receive(msg)
	qlog.debug("SdkGateMsgHandle:receive ", msg)
	
	local tb = {string.split(msg, ",")}
	if tb[1] == "login" then
		if #tb ~= 6 then
			qlog.warn("SdkGateMsgHandle:receive login error param")
			return
		end
		
		local guid 			= tb[2]
		local accessToken	= tb[3]
		local userId 		= tb[4]
		local userName 		= tb[5]
		local gsId	 		= tonumber(tb[6])
		
		GCPlayer:platformLoginAck(guid, accessToken, userId, userName, gsId)
	end
end

return SdkGateMsgHandle