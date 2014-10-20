

local PersistentTable = require "PersistentTable"
local keys = require "keys"
local UserData = require "UserData"
local device = require "device"
local json = require "json"
local eventhub = require "eventhub"
local qlog = require "qlog"

local Player
local acts = PersistentTable.new("acts.lua", false)

local LV_FATAL = 1
local LV_WARN = 2
local LV_GAME = 3
local LV_UI = 4

local function makeValue(...)
	local t = {...}
	for i = 1, argc(...) do
		t[i] = tostring(t[i])
	end
	return table.concat(t, ",")
end

local ActLog = {}
local counter = 0
local function makeId()
	return MOAIEnvironment.generateGUID()
end

function ActLog:addLog(level, key, value, ud)
	if _DEBUG then
		return
	end
	value = value and tostring(value) or ""
	local id = makeId()
	local timestamp = os.date("%Y-%m-%d %H:%M:%S")
	qlog.debug("ActLog", level, key, value)
	local userdata = ud and json.encode(UserData:takeTable()) or ""
	if not acts[level] then
		acts[level] = {}
	end
	table.insert(acts[level], {UserData._guid, id, level, timestamp, key, value, userdata})
	counter = counter + 1
	if level == LV_FATAL or math.fmod(counter, 10) == 0 then
		acts:save()
	end
end

function ActLog:smsPayBegin(idx)
	self:addLog(LV_FATAL, "smsPayBegin", idx)
end

function ActLog:smsPaySucceed(productId, paycode, tradeid)
	self:addLog(LV_FATAL, "smsPaySucceed", makeValue(productId, paycode, tradeid))
end

function ActLog:smsPayFailed(code, reason)
	self:addLog(LV_FATAL, "smsPayFailed", makeValue(code, reason))
end

function ActLog:catchError(msg)
	if not self._errorCache[msg] then
		self._errorCache[msg] = true
		self:addLog(LV_FATAL, "catchError", makeValue(debug.logfile, msg))
	end
end

function ActLog:playerLoginFailed(reason)
	self:addLog(LV_WARN, "playerLoginFailed", reason)
end

function ActLog:clickQihooPayChannel(channel)
	self:addLog(LV_FATAL, "clickQihooPay", channel)
end

function ActLog:RMBPayBegin(idx)
	self:addLog(LV_FATAL, "RMBPayBegin", idx)
end

function ActLog:RMBPayEnd(idx)
	self:addLog(LV_FATAL, "RMBPayEnd", idx)
end

function ActLog:buyGold(idx)
	self:addLog(LV_FATAL, "buyGold", idx)
end

function ActLog:buyAP(idx)
	self:addLog(LV_FATAL, "buyAP", idx)
end

function ActLog:buyItemUseMoney(item, count)
	self:addLog(LV_FATAL, "buyItemUseMoney", makeValue(item, count))
end

function ActLog:shareStageScore(ok)
	self:addLog(LV_GAME, "shareStageScore", ok)
end

function ActLog:buyItemUseGold(item, count)
	self:addLog(LV_GAME, "buyItemUseGold", makeValue(item, count))
end

function ActLog:useItem(item)
	self:addLog(LV_GAME, "useItem", item)
end

function ActLog:startMission(id)
	self:addLog(LV_GAME, "startMission", id)
end

function ActLog:endMission(id, result, star)
	self:addLog(LV_GAME, "endMission", makeValue(id, result, star))
end

function ActLog:startStage()
	self:addLog(LV_GAME, "startStage")
end

function ActLog:endStage(count, score)
	self:addLog(LV_GAME, "endStage", makeValue(count, score))
end

function ActLog:endStageManual(count, score)
	self:addLog(LV_GAME, "endStageManual", makeValue(count, score))
end

function ActLog:startTiming(id)
	self:addLog(LV_GAME, "startTiming", id)
end

function ActLog:endTiming(count, score)
	self:addLog(LV_GAME, "endTiming", makeValue(count, score))
end

function ActLog:buyStep(times)
	self:addLog(LV_FATAL, "buyStep", times)
end

function ActLog:recoverGame(mission, gameMode)
	self:addLog(LV_GAME, "recoverGame", makeValue(mission, gameMode))
end

function ActLog:palyerLvup(lv)
	self:addLog(LV_GAME, "palyerLvup", lv)
end

function ActLog:unlockPet(id)
	self:addLog(LV_FATAL, "unlockPet", id)
end

function ActLog:updatePetLevel(id, lv)
	self:addLog(LV_GAME, "updatePetLevel", makeValue(id, lv))
end

function ActLog:unlockRobot(id)
	self:addLog(LV_FATAL, "unlockRobot", id)
end

function ActLog:useSuperSkill(id)
	self:addLog(LV_GAME, "useSuperSkill", id)
end

function ActLog:launchGame()
	UserData.lastLaunchTime = os.time()
	self:addLog(LV_FATAL, "launchGame", makeValue(device.getConnectionType(), VERSION_OPTION))
end

function ActLog:exitGame()
	self:addLog(LV_GAME, "exitGame", device.getConnectionType())
	acts:save()
end

function ActLog:pauseGame()
	self:addLog(LV_GAME, "pauseGame")
	acts:save()
end

function ActLog:resumeGame()
	self:addLog(LV_GAME, "resumeGame")
end

function ActLog:shareTask(taskId)
	self:addLog(LV_FATAL, "shareTask", taskId)
end

function ActLog:taskRewardsMoney(taskId)
	self:addLog(LV_FATAL, "taskRewardsMoney", taskId)
end


function ActLog:init(player)
	Player = player
	
	self._errorCache = {}
	
	debug.errorhandle = function(msg)
		ActLog:catchError(msg)
	end
	
	if UserData.adError then
		ActLog:addLog(LV_FATAL, "adError", UserData.adError)
	end
	
	if UserData.udError then
		ActLog:addLog(LV_FATAL, "udError", UserData.udError)
	end
	
	MOAISim.setTraceback(function(err)
		ActLog:catchError(debug.traceback(err or "", 2))
	end)
	
	Player.onResolveAddressFailed = function(err)
		qlog.info("onResolveAddressFailed")
	end
	
	Player.onGSClosed = function()
		qlog.info("onGSClosed")
	end
	
	Player.onConnectWSFailed = function()
		-- qlog.info("onConnectWSFailed")
	end
	
	Player.onConnectGSFailed = function(ip, port)
		qlog.info("onConnectGSFailed")
	end
	
	Player.onPlayerLoginFailed = function(reason)
		ActLog:playerLoginFailed(reason)
	end

	eventhub.bind("SYSTEM_EVENT", "BUY_MONEY", function(idx)
		ActLog:RMBPayBegin(idx)
	end)

	eventhub.bind("SYSTEM_EVENT", "BUY_GOLD", function(idx)
		ActLog:buyGold(idx)
	end)

	eventhub.bind("SYSTEM_EVENT", "BUY_AP", function(idx)
		ActLog:buyAP(idx)
	end)
	
	ActLog:launchGame()
end

local function getLog(tb)
	for k, v in ipairs(tb) do
		local tb = acts[v]
		if tb and tb[1] then
			return tb
		end
	end
end

function ActLog:step()
	if device.getConnectionType() then
		local tb = getLog {LV_FATAL, LV_GAME, LV_WARN, LV_UI}
		if not self._sending and tb then
			self._sending = true
			Player:connectLS(function(c)
				if not c then
					self._sending = nil
					return
				end
				
				local h = c.remote.CLCommand.writeActLog(unpack(tb[1]))
				h.onAck = function()
					self._sending = nil
					table.remove(tb, 1)
					acts:save()
					c:close()
				end
			end)
		end
	end
end

return ActLog