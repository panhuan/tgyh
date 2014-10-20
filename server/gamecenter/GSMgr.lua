
local qlog = require "qlog"

local GSMgr = {}

GSMgr._gsidToConnectList = {}
GSMgr._connectToGsidList = {}

function GSMgr:gsLogin(connect, gsid)
	if not gsid or not connect then
		qlog.warn("GSMgr:gsLogin faild", connect, gsid)
		return false
	end
	
	qlog.debug("GSMgr:gsLogin success", connect, gsid)

	self._gsidToConnectList[gsid] = connect
	self._connectToGsidList[connect] = gsid
	
	return true
end

function GSMgr:gsLogout(connect)
	qlog.debug("GSMgr:gsLogout", connect)
	
	if not connect then
		return false
	end
	
	local gsid = self:getGsidByConnect(connect)
	if gsid then
		self._gsidToConnectList[gsid] = nil
	end
	
	self._connectToGsidList[connect] = nil
	
	return true
end

function GSMgr:getConnectByGsid(gsid)
	return self._gsidToConnectList[gsid]
end

function GSMgr:getGsidByConnect(connect)
	return self._connectToGsidList[connect]
end

return GSMgr