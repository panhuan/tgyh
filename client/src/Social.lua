
local qlog = require "qlog"
local file = require "file"
local device = require "device"
local UserData = require "UserData"

local Social = {
	_regs = {},
}

local WeChatAppIDs = {
	["SMSPay"] = "wx7a89f7a60176f927",
	["Qihoo"] = "wx2a36415d8ca78e56",
}

local ShareURLs = {
	["SMSPay"] = "http://mm.10086.cn/android/info/300008415610.html",
	["Qihoo"] = "http://u.360.cn/detail.php?s=web&sid=1899224",
}

local function getWeChatAppID()
	for k, v in pairs(WeChatAppIDs) do
		if VERSION_OPTION:find(k) then
			return v
		end
	end
end

local function getShareURL()
	for k, v in pairs(ShareURLs) do
		if VERSION_OPTION:find(k) then
			return v
		end
	end
end

function Social.screenshot(filename, cb)
	local path = device.getCachePath("social/")..filename
	device.screenshot(path, cb)
end

function Social.shareImage(filename, timelined, cb)
	local WeChatAppID = UserData.WeChatAppID or getWeChatAppID()
	if not WeChatAppID then
		if cb then cb(false) end
		return
	end
	if not Social._inited then
		Social._inited = true
		MOAIJavaVM.runJava("WeChat.create,"..WeChatAppID)
	end
	local id = MOAIEnvironment.generateGUID()
	Social._cbs = Social._cbs or {}
	Social._cbs[id] = cb
	local path = device.getCachePath("social/")..filename
	local scene = timelined and "timeline" or "session"
	if file.exists(path) then
		MOAIJavaVM.runJava("WeChat.shareImage,"..id..","..path..","..scene)
	else
		qlog.warn("Social.shareImage not found", path)
	end
end

function Social.shareUrl(url, title, desc, timelined, cb)
	url = url or getShareURL()
	if not UserData.WeChatAppID then
		if cb then cb(false) end
		return
	end
	if not Social._inited then
		Social._inited = true
		MOAIJavaVM.runJava("WeChat.create,"..UserData.WeChatAppID)
	end
	local id = MOAIEnvironment.generateGUID()
	Social._cbs = Social._cbs or {}
	Social._cbs[id] = cb
	title = Social.complieText(title)
	desc = Social.complieText(desc)
	local scene = timelined and "timeline" or "session"
	if MOAIJavaVM then
		MOAIJavaVM.runJava("WeChat.shareUrl,"..id..","..url..","..title..","..desc..","..scene)
	end
end

function Social.onShareResult(id, ok)
	qlog.info("Social.onShareResult", id, ok)
	local cb = Social._cbs[id]
	if cb then cb(ok) end
	Social._cbs[id] = nil
end

function Social.setRegister(key, value)
	Social._regs[key] = value
end

function Social.complieText(s)
	if Social._regs then
		for k, v in pairs(Social._regs) do
			s = s:gsub(k, tostring(v))
		end
	end
	return s
end

return Social