
local eventhub = require "eventhub"
local PersistentTable = require "PersistentTable"
local keys = require "keys"
local deviceevent = require "deviceevent"
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
end

return GameData