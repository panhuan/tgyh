
local ui = require "ui"
local Image = require "gfx.Image"
local eventhub = require "eventhub"
local device = require "device"
local WindowOpenStyle = require "windows.WindowOpenStyle"
local Player = require "logic.Player"
local SoundManager = require "SoundManager"
local timer = require "timer"
local StoryPanel = require "windows.StoryPanel"
local UserData = require "UserData"
local resource = require "resource"
local bucket = resource.bucket


local StartPanel = {}

local backGround = "star_panel.jpg"
local logoPic = "panel/logo.atlas.png#logo.png"
local btnBGPic = "ui.atlas.png#ks_1.png"
local startPic = "ui.atlas.png#ks_2.png"
local loginPic = "ui.atlas.png#login.png"


local loginBtnX, loginBtnY = 0, -370


function StartPanel:init()
	eventhub.bind("UI_EVENT", "OPEN_START_PANEL", function()
		self:open()
	end)
	
	bucket.push("StartPanel")
	self._root = Image.new(backGround)
	self._root:setPriority(1)
	self._root:setLayoutSize(device.ui_width, device.ui_height)
	
	self._logo = self._root:add(Image.new(logoPic))
	self._logo:setAnchor("MT", 0, -150)
	
	local up1 = Image.new(btnBGPic)
	up1:add(Image.new(startPic))
	local startButton = self._root:add(ui.Button.new(up1))
	startButton:setAnchor("MB", 0, 100)
	startButton.onClick = function()
		StartPanel:close()
		
		if not UserData.openingStoryPlayed then
			StoryPanel:open("opening", function()
				UserData.openingStoryPlayed = true
				if UserData:getRookieGuide("link") then
					eventhub.fire("UI_EVENT", "OPEN_MAIN_PANEL")
				else
					eventhub.fire("ROOKIE_EVENT", "ROOKIE_TRIGGER", "link")
				end
			end)
		else
			if UserData:getRookieGuide("link") then
				eventhub.fire("UI_EVENT", "OPEN_MAIN_PANEL")
			else
				eventhub.fire("ROOKIE_EVENT", "ROOKIE_TRIGGER", "link")
			end
		end
		
		Player:enterGame()
	end
	startGame = startButton.onClick
	
	-- local up2 = Image.new(btnBGPic)
	-- up2:add(Image.new(loginPic))
	-- local loginButton = self._root:add(ui.Button.new(up2))
	-- loginButton:setLoc(loginBtnX, loginBtnY)
	-- loginButton.onClick = function()
		-- print("--------LoginBtn OnClick")
	-- end
	bucket.pop()
end

function StartPanel:open()
	uiLayer:add(self._root)
	SoundManager:switchBGM("world")
end

function StartPanel:close()
	self._root:remove()
	bucket.release("StartPanel")
	if UserData:getRookieGuide("link") and UserData:getRookieGuide("pet") and UserData:getRookieGuide("bomb") and UserData:getRookieGuide("robot") and UserData:getRookieGuide("skill") then
		eventhub.fire("UI_EVENT", "OPEN_EVERYDAY_PANEL")
	end
end

return StartPanel