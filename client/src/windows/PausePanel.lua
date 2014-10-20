
local ui = require "ui"
local node = require "node"
local Image = require "gfx.Image"
local device = require "device"
local eventhub = require "eventhub"
local gfxutil = require "gfxutil"
local UserData = require "UserData"
local SoundSystem = require "SoundSystem"
local WindowOpenStyle = require "windows.WindowOpenStyle"


local backGround = "panel/setting_panel.atlas.png#setting_panel.png"
local closePic1 = "ui.atlas.png#close_1.png"
local closePic2 = "ui.atlas.png#close_2.png?scl=1.2"
local titlePic = "ui.atlas.png#zt_title.png"

local musicPic1 = "ui.atlas.png#music.png"
local musicPic2 = "ui.atlas.png#music_click.png?scl=1.2"
local musicPic3 = "ui.atlas.png#music_off.png"
local musicPic4 = "ui.atlas.png#music_off.png?scl=1.2"

local soundPic1 = "ui.atlas.png#sound.png"
local soundPic2 = "ui.atlas.png#sound_click.png?scl=1.2"
local soundPic3 = "ui.atlas.png#sound_off.png"
local soundPic4 = "ui.atlas.png#sound_off.png?scl=1.2"

local btntuichu = "ui.atlas.png#sz_tc_liang.png"
local btnjixu = "ui.atlas.png#zt_jx_liang.png"

local PausePanel = {}

function PausePanel:init()
	eventhub.bind("UI_EVENT", "OPEN_PAUSE_PANEL", function()
		self:open()
	end)
	eventhub.bind("UI_EVENT", "SWITCH_PAUSE_PANEL", function()
		self:switch()
	end)
	eventhub.bind("UI_EVENT", "SOUND_CHANGE", function()
		self._musicSwitch:turn(UserData.music)
		self._soundSwitch:turn(UserData.sound)
		SoundSystem.muteMusic(UserData.music == 2)
		SoundSystem.muteSound(UserData.sound == 2)
	end)
	
	self._root = ui.PickBox.new(device.ui_width, device.ui_height)
	self._root:setPriority(1)
	self._bgRoot = Image.new(backGround)
	self._root:add(self._bgRoot)
	self._root:setLayoutSize(Image.getSize(self._bgRoot))
	
	self._title = self._bgRoot:add(Image.new(titlePic))
	self._title:setAnchor("MT", 0, -120)
	
	local closeButton = self._bgRoot:add(ui.Button.new(closePic1, closePic2))
	closeButton:setAnchor("RT", -50, -120)
	closeButton.onClick = function()
		self:close()
	end
	
	local btnGOON = self._bgRoot:add(ui.Button.new(btnjixu, btnjixu.."?scl=1.2"))
	btnGOON:setAnchor("MB", -120, 150)
	btnGOON.onClick = function()
		self:close()
	end
	
	local btnExit = self._bgRoot:add(ui.Button.new(btntuichu, btntuichu.."?scl=1.2"))
	btnExit:setAnchor("MB", 120, 150)
	btnExit.onClick = function()
		self:close()
		eventhub.fire("UI_EVENT", "QUIT_GAME")
	end
	
	self._musicSwitch = self._bgRoot:add(ui.Switch.new(2, musicPic1, musicPic2, musicPic3, musicPic4))
	self._musicSwitch:setLoc(-115, 30)
	self._musicSwitch.onTurn = function(o, status)
		UserData:setMusic(status)
	end
	
	self._soundSwitch = self._bgRoot:add(ui.Switch.new(2, soundPic1, soundPic2, soundPic3, soundPic4))
	self._soundSwitch:setLoc(115, 30)
	self._soundSwitch.onTurn = function(o, status)
		UserData:setSound(status)
	end
end

function PausePanel:open()
	if self._isOpen then
		return
	end
	
	self._isOpen = true
	WindowOpenStyle:openWindowScl(self._bgRoot)
	WindowOpenStyle:openWindowAlpha(self._bgRoot)
	popupLayer:add(self._root)
	eventhub.fire("UI_EVENT", "PAUSE_GAME", true)
end

function PausePanel:close()
	self._isOpen = false
	popupLayer:remove(self._root)
	eventhub.fire("UI_EVENT", "PAUSE_GAME", false)
end

function PausePanel:switch()
	if self._isOpen then
		self:close()
	else
		self:open()
	end
end

return PausePanel
