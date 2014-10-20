
local eventhub = require "eventhub"
local PersistentTable = require "PersistentTable"
local keys = require "keys"
local deviceevent = require "deviceevent"
local GamePlay = require "GamePlay"
local SoundSystem = require "SoundSystem"
local UserData = require "UserData"
local ActLog = require "ActLog"

local GameData = PersistentTable.new(UserData:getGuid().."/gameData.lua", true, keys.v0)
function GameData:init()
	deviceevent.onPauseCallback = function()
		self:onSaveData()
		local root = MOAIActionMgr.getRoot()
		root:pause(true)
		SoundSystem.muteSound(true)
		SoundSystem.muteMusic(true)
		ActLog:pauseGame()
		print("------------------ GAME PAUSED ------------------")
	end
	deviceevent.onResumeCallback = function()
		local root = MOAIActionMgr.getRoot()
		root:pause(false)
		SoundSystem.muteSound(UserData.sound == 2)
		SoundSystem.muteMusic(UserData.music == 2)
		ActLog:resumeGame()
		print("------------------ GAME RESUMED ------------------")
	end
	
	eventhub.bind("SYSTEM_EVENT", "CLEAR_GAME_DATA", function() self:onClearData() end)
	eventhub.bind("SYSTEM_EVENT", "GAME_DATA_TYPE", function(type) self:setType(type) end)
end

function GameData:onLoadData()
	if GameData._data then
		return GamePlay:loadData(GameData._data)
	end
	
	return false
end

function GameData:onSaveData()
	if not UserData:getRookieGuide("link") or not UserData:getRookieGuide("bomb") or not UserData:getRookieGuide("skill") then
		return
	end
	
	if GamePlay._gameMode == "timing" then
		return
	end

	if self:getType() == "GamePlay" then
		GameData._data = {}
		GamePlay:saveData(GameData._data)
		GameData:save()
	end
end

function GameData:onClearData()
	GameData._data = nil
	GameData:save()
end

function GameData:setType(type)
	GameData._type = type
end

function GameData:getType()
	return GameData._type
end

return GameData