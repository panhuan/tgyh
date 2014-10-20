
local ui = require "ui"
local Image = require "gfx.Image"
local device = require "device"
local eventhub = require "eventhub"
local Pet = require "settings.Pet"
local UserData = require "UserData"
local Buy = require "settings.Buy"
local WindowOpenStyle = require "windows.WindowOpenStyle"


local FailedTip = {}


local backGround = "panel/step_bg.atlas.png#step_bg.png"
local btnPic = "ui.atlas.png#ts_qd_liang.png"
local btnUnlockPic = "ui.atlas.png#jcx_an_1.png"
local rolePic = "ui.atlas.png#sb_ts_role.png"
local textPanel = "ui.atlas.png#sb_ts_panel.png"
local bgPic = "panel/sbts_bj.atlas.png#sbts_bj.png"
local itemPic = "panel/sb_4.atlas.png#sb_4.png"

local tbTipPic = 
{
	[1] = "ui.atlas.png#sb_ts_1.png",
	[2] = "ui.atlas.png#sb_ts_3.png",
	[3] = "ui.atlas.png#sb_ts_2.png",
	[4] = "ui.atlas.png#sb_ts_4.png",
}

local pet2BuyIdx = 
{
	[3] = 11,
	[4] = 12,
	[5] = 13,
}

local robot2BuyIdx = 
{
	[2] = 14,
	[3] = 15,
	[4] = 16,
	[5] = 17,
}

function FailedTip:init()
	eventhub.bind("UI_EVENT", "OPEN_FAILEDTIP_PANEL", function()
		self:open()
	end)
	
	self._root = ui.PickBox.new(device.ui_width, device.ui_height)
	self._root:setPriorityOffset(50)
	self._bgRoot = self._root:add(Image.new(backGround))
	self._root:setLayoutSize(self._bgRoot:getSize())
	
	self._btn = self._bgRoot:add(ui.Button.new(btnPic))
	self._btn:setLoc(0, -278)
	
	self._bgImg = self._bgRoot:add(Image.new())
	self._bgImg:setLoc(10, 50)
	
	self._Img = self._bgImg:add(Image.new())
	
	self._roleImg = self._bgImg:add(Image.new(rolePic))
	self._roleImg:setLoc(125, -180)
	self._roleImg:setPriorityOffset(3)
	
	self._textPanel = self._bgImg:add(Image.new(textPanel))
	self._textPanel:setLoc(-65, -205)
	self._textPanel:setPriorityOffset(3)
	
	self._textImg = self._textPanel:add(Image.new())
	self._textImg:setLoc(-5, -13)
end

function FailedTip:checkPet()
	for key, var in ipairs(UserData.petInfo) do
		if var.unlocked == false then
			return false, key
		end
	end
	return true
end

function FailedTip:checkRobot()
	for key, var in ipairs(UserData.robotInfo) do
		if var == false then
			return false, key
		end
	end
	return true
end

function FailedTip:checkPetLevel()
	for key, var in ipairs(UserData.petInfo) do
		if var.level < PET_MAX_LEVEL then
			return false, key
		end
	end
	return true
end

function FailedTip:initFailedTip()
	local szImg = itemPic
	local bgImg = nil
	local index = 4
	self._btn:setUpPage(btnPic)
	self._btn.onClick = function()
		self:close()
	end
	local result, key = self:checkPet()
	if not result then
		index = 1
		szImg = Pet.tbPetPic[key].pet
		bgImg = bgPic
		self._btn:setUpPage(btnUnlockPic)
		self._btn.onClick = function()
			self:close()
			if pet2BuyIdx[key] then
				Buy:RMBPay(pet2BuyIdx[key])
			end
		end
	else
		result, key = self:checkRobot()
		if not result then
			index = 2
			szImg = Pet.tbPetPic[key].robot
			bgImg = bgPic
			self._btn:setUpPage(btnUnlockPic)
			self._btn.onClick = function()
				self:close()
				if robot2BuyIdx[key] then
					Buy:RMBPay(robot2BuyIdx[key])
				end
			end
		else
			result, key = self:checkPetLevel()
			if not result then
				index = 3
				szImg = Pet.tbPetPic[key].pet
				bgImg = bgPic
				self._btn.onClick = function()
					self:close()
					eventhub.fire("UI_EVENT", "OPEN_ROLE_PANEL")
				end
			end
		end
	end
	
	self._bgImg:load(bgImg)
	self._Img:load(szImg)
	self._textImg:load(tbTipPic[index])
end

function FailedTip:open()
	self:initFailedTip()
	WindowOpenStyle:openWindowScl(self._bgRoot)
	WindowOpenStyle:openWindowAlpha(self._bgRoot)
	popupLayer:add(self._root)
end

function FailedTip:close()
	popupLayer:remove(self._root)
end

return FailedTip