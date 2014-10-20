
local ui = require "ui"
local Image = require "gfx.Image"
local device = require "device"
local eventhub = require "eventhub"
local UserData = require "UserData"
local SoundSystem = require "SoundSystem"
local WindowOpenStyle = require "windows.WindowOpenStyle"
local RookieGuide = require "logic.RookieGuide"


local SystemPanel = {}


local backGround = "panel/setting_panel.atlas.png#setting_panel.png"
local titlePic = "ui.atlas.png#system_title.png"
local closePic1 = "ui.atlas.png#close_1.png"
local closePic2 = "ui.atlas.png#close_2.png?scl=1.2"
local btntuichu = "ui.atlas.png#zt_tc_liang.png"
local btnjixu = "ui.atlas.png#zt_jx_liang.png"
local btnshequ = "ui.atlas.png#sz_sq_liang.png"

local musicPic1 = "ui.atlas.png#music.png"
local musicPic2 = "ui.atlas.png#music_click.png?scl=1.2"
local musicPic3 = "ui.atlas.png#music_off.png"
local musicPic4 = "ui.atlas.png#music_off.png?scl=1.2"

local soundPic1 = "ui.atlas.png#sound.png"
local soundPic2 = "ui.atlas.png#sound_click.png?scl=1.2"
local soundPic3 = "ui.atlas.png#sound_off.png"
local soundPic4 = "ui.atlas.png#sound_off.png?scl=1.2"

function SystemPanel:init()
	eventhub.bind("UI_EVENT", "OPEN_SYSTEM_PANEL", function()
		self:open()
	end)
	eventhub.bind("UI_EVENT", "SOUND_CHANGE", function()
		self._musicSwitch:turn(UserData.music)
		self._soundSwitch:turn(UserData.sound)
		SoundSystem.muteMusic(UserData.music == 2)
		SoundSystem.muteSound(UserData.sound == 2)
	end)
	
	self._root = ui.PickBox.new(device.ui_width, device.ui_height)
	self._root:setPriorityOffset(1000)
	self._bgRoot = Image.new(backGround)
	self._root:add(self._bgRoot)
	self._root:setLayoutSize(Image.getSize(self._bgRoot))
	
	local closeButton = self._bgRoot:add(ui.Button.new(closePic1, closePic2))
	closeButton:setAnchor("RT", -50, -120)
	closeButton.onClick = function()
		self:close()
	end
	
	local title = self._bgRoot:add(Image.new(titlePic))
	title:setAnchor("MT", 0, -120)
	
	local btnExit = self._bgRoot:add(ui.Button.new(btntuichu, btntuichu.."?scl=1.2"))
	btnExit:setAnchor("MB", 0, 90)
	btnExit.onClick = function()
		print("-----------btnExit onclick------------")
	end
	
	local btnGoon = self._bgRoot:add(ui.Button.new(btnjixu, btnjixu.."?scl=1.2"))
	btnGoon:setAnchor("MB", -120, 180)
	btnGoon.onClick = function()
		self:close()
	end
	
	local btnCommunity = self._bgRoot:add(ui.Button.new(btnshequ, btnshequ.."?scl=1.2"))
	btnCommunity:setAnchor("MB", 120, 180)
	btnCommunity.onClick = function()
		-- MOAIBrowser.openURL("http://kaixin.kalazhu.com/kaixin.php?device=android")
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
	
	self:initSound()
end

function SystemPanel:initSound()
	UserData:setMusic(UserData.music)
	UserData:setSound(UserData.sound)
end

function SystemPanel:open()
	WindowOpenStyle:openWindowScl(self._bgRoot)
	WindowOpenStyle:openWindowAlpha(self._bgRoot)
	popupLayer:add(self._root)
end

function SystemPanel:close()
	popupLayer:remove(self._root)
end


return SystemPanel