
local qlog = require "qlog"
local timer = require "timer"

local PlayerMgr = {}

PlayerMgr._guidToConnectList = {}
PlayerMgr._connectToGuidList = {}

function PlayerMgr:init()
	self:updatePlayerNum()
	timer.new(300, function()
		self:updatePlayerNum()
	end)
end

function PlayerMgr:updatePlayerNum()
	local infoList = REDIS:hgetall("GSPlayerList"..GS_ADDR)
	
	local timeoutPlayer = {}
	local curTime = os.time()
	for guid, time in pairs (infoList) do
		if curTime - time > 300 then
			table.insert(timeoutPlayer, guid)
		end
	end
	
	if #timeoutPlayer > 0 then
		REDIS:hdel("GSPlayerList"..GS_ADDR, unpack(timeoutPlayer))
	end
end

function PlayerMgr:playerLogin(connect, guid, clientVersion)
	qlog.debug("PlayerMgr:playerLogin", connect, guid, clientVersion)
	
	if not guid or not connect then
		return ERR_FAILED
	end

	if clientVersion < CLIENT_VERSION then
		return ERR_VERSION_UNMATCH
	end
	
	self._guidToConnectList[guid] = connect
	self._connectToGuidList[connect] = guid
	
	REDIS:hset("GSPlayerList"..GS_ADDR, guid, os.time())
	return ERR_SUCCEED
end

function PlayerMgr:playerLogout(connect)
	qlog.debug("PlayerMgr:playerLogout", connect)
	
	if not connect then
		return false
	end
	
	local guid = self:getGuidByConnect(connect)
	if guid then
		self._guidToConnectList[guid] = nil
	end
	
	self._connectToGuidList[connect] = nil
	
	return true
end

function PlayerMgr:getConnectByGuid(guid)
	return self._guidToConnectList[guid]
end

function PlayerMgr:getGuidByConnect(connect)
	return self._connectToGuidList[connect]
end

return PlayerMgr