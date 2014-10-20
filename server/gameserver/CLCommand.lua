
local PlayerMgr = require "PlayerMgr"
local GSPlayer = require "GSPlayer"
local qlog = require "qlog"
local CLCommand = {}

function CLCommand.login(c, guid, clientVersion)
	return PlayerMgr:playerLogin(c, guid, clientVersion)
end

function CLCommand.logout(c, guid)
	return PlayerMgr:playerLogout(c)
end

function CLCommand.savaPlayerData(c, guid, data)
	return GSPlayer:savaData(guid, data)
end

function CLCommand.platformLoginReq(c, guid, authcode)
	return GSPlayer:platformLogin(guid, authcode)
end

function CLCommand.updateOrderStateReq(c, guid, orderId, state)
	return GSPlayer:updateOrderState(guid, orderId, state)
end

function CLCommand.verifyOrderReq(c, guid, orderList)
	return GSPlayer:verifyOrder(guid, orderList)
end

function CLCommand.getServerTime(c)
	return os.time()
end

return CLCommand