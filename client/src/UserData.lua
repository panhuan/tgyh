
local eventhub = require "eventhub"
local timer = require "timer"
local PersistentTable = require "PersistentTable"
local keys = require "keys"
local crypto = require "crypto"
local versionutil = require "versionutil"

local enc_0 = crypto.encode(0)
local enc_1 = 1

local initData =
{
	APP_VERSION = APP_VERSION,
	
	lastLaunchTime = 0,
	
	WeChatAppID = nil,
	
	ShareURL = nil,
	
	hpFactor = 1,
	
	taskList = {},
	
	orderList = {},
	
	smsOrderList = {},
	
	--简易支付渠道(30元以下直接走短信,以上走360支付,当前仅用于360版本)
	simplePayChannel = false, 
	--------------------------------------------------------
	
	level = 1,
}

local cryptoF = {
	encode = crypto.encode,
	decode = crypto.decode,
}

local cryptoT = {
	["level"] = cryptoF,
}

for k, v in pairs(initData) do
	local f = cryptoT[k]
	if f then
		initData[k] = f.encode(v)
	end
end

-- 读取帐号
local AccountData, adError = PersistentTable.new("accountData.lua", true, keys.v0)
if not AccountData._guid then
	AccountData._guid = MOAIEnvironment.generateGUID()
	AccountData:save()
end

-- 根据帐号,获取用户数据
local UserDataM, udError = PersistentTable.new(AccountData._guid.."/userData.lua", true, keys.v0, initData)

-- 生成玩家guid
if not UserDataM._guid then
	UserDataM._guid = AccountData._guid
	UserDataM:save()
else
	-- 帐号必须与用户数据一致
	assert(AccountData._guid == UserDataM._guid)
end

if versionutil.numeric(APP_VERSION) > versionutil.numeric(UserDataM.APP_VERSION) then
	UserDataM.APP_VERSION = APP_VERSION
end

local UserData = {
	adError = adError,
	udError = udError,
}

function UserData:save()
	UserDataM:save()
end

function UserData:getGuid()
	return self._guid
end

function UserData:getLevel()
	return crypto.decode(self.level)
end

function UserData:getSavaInfo()
	local info = {}
	info.guid 	= self._guid
	info.money 	= self.money
	info.gold 	= self.gold
	info.ap 	= self.ap
	info.level 	= self.level
	info.exp 	= self.exp
	info.stage 	= self.stage
	info.score 	= self.score
	info.item  	= self.item
	info.petInfo= self.petInfo

	return UserData.takeTable(info)
end

function UserData:setDataBySavaInfo(info)
	self.money 	= info.money
	self.gold 	= info.gold
	self.ap 	= info.ap
	self.level 	= info.level
	self.exp 	= info.exp
	self.stage 	= info.stage
	self.score 	= info.score
	self.item  	= info.item
	self.petInfo= info.petInfo
end

function UserData:isSimplePayChannel()
	return self.simplePayChannel
end

function UserData:setSimplePayChannelStatus(status)
	self.simplePayChannel = status
	self:save()
end

setmetatable(UserData, {
	__index = function(self, key)
		local v = UserDataM[key]
		local f = cryptoT[key]
		if v and f then
			return f.decode(v)
		end
		return v
	end,
	__newindex = function(self, key, value)
		local f = cryptoT[key]
		if f then
			value = f.encode(value)
		end
		UserDataM[key] = value
	end,
})

return UserData
