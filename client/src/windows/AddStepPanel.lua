
local ui = require "ui"
local node = require "node"
local Image = require "gfx.Image"
local device = require "device"
local eventhub = require "eventhub"
local TextBox = require "gfx.TextBox"
local GamePlay = require "GamePlay"
local UserData = require "UserData"
local Buy = require "settings.Buy"
local GameConfig = require "settings.GameConfig"
local WindowOpenStyle = require "windows.WindowOpenStyle"

local AddStepPanel = {}

local backGround = "panel/step_bg.atlas.png#step_bg.png"
local btnPic = "ui.atlas.png#stepbtn.png"
local btnClosePic = "ui.atlas.png#stepbtn_jieshu.png"
local btnUsePic = "ui.atlas.png#stepbtn_queding.png"
local role = "ui.atlas.png#tianxin_3.png?loc=70, -80"

local tbText = 
{
	[1] = "ui.atlas.png#yongjin.png?loc=-70, 155",
	[2] = "ui.atlas.png#shiyong.png?loc=-145, 75",
	[3] = "ui.atlas.png#money_small.png?loc=-50, 75",
	[4] = "ui.atlas.png#ewai.png?loc=40, 75",
	[5] = "ui.atlas.png#bu.png?loc=160, 75",
	-- [6] = "ui.atlas.png#benjv.png?loc=-117, 50",
	-- [7] = "ui.atlas.png#jihui.png?loc=55, 50",
}


function AddStepPanel:init()
	eventhub.bind("UI_EVENT", "OPEN_ADDSTEP_PANEL", function()
		self:open()
	end)
	self._root = ui.PickBox.new(device.ui_width, device.ui_height)
	self._root:setPriority(1)
	self._bgRoot = Image.new(backGround)
	self._root:add(self._bgRoot)
	self._root:setLayoutSize(Image.getSize(self._bgRoot))
	
	self._bgRoot:add(Image.new(role))
	
	local up1 = Image.new(btnPic)
	up1:add(Image.new(btnUsePic))
	
	local addBtn = self._bgRoot:add(ui.Button.new(up1))
	addBtn:setLoc(-110, -40)
	addBtn.onClick = function()
		if UserData:costMoney(GameConfig.buyStepPrice) then
			self:close()
			eventhub.fire("UI_EVENT", "USE_ADD_STEP")
		else
			local successKey, failedKey, cancelKey = nil, nil, nil
			successKey = eventhub.bind("UI_EVENT", "PLAYER_PAY_SUCCESS", function()
				eventhub.unbind("UI_EVENT", "PLAYER_PAY_SUCCESS", successKey)
				eventhub.unbind("UI_EVENT", "PLAYER_PAY_FAILED", failedKey)
				eventhub.unbind("UI_EVENT", "PLAYER_PAY_CANCEL", cancelKey)
				self:close()
				if UserData:costMoney(GameConfig.buyStepPrice) then
					eventhub.fire("UI_EVENT", "USE_ADD_STEP")
				else
					eventhub.fire("UI_EVENT", "NOUSE_ADD_STEP")
				end
			end)
			failedKey = eventhub.bind("UI_EVENT", "PLAYER_PAY_FAILED", function()
				eventhub.unbind("UI_EVENT", "PLAYER_PAY_SUCCESS", successKey)
				eventhub.unbind("UI_EVENT", "PLAYER_PAY_FAILED", failedKey)
				eventhub.unbind("UI_EVENT", "PLAYER_PAY_CANCEL", cancelKey)
				self:close()
				eventhub.fire("UI_EVENT", "NOUSE_ADD_STEP")
			end)
			cancelKey = eventhub.bind("UI_EVENT", "PLAYER_PAY_CANCEL", function()
				eventhub.unbind("UI_EVENT", "PLAYER_PAY_SUCCESS", successKey)
				eventhub.unbind("UI_EVENT", "PLAYER_PAY_FAILED", failedKey)
				eventhub.unbind("UI_EVENT", "PLAYER_PAY_CANCEL", cancelKey)
				self:close()
				eventhub.fire("UI_EVENT", "NOUSE_ADD_STEP")
			end)
			Buy:RMBPay(18)
		end
	end
	
	local up2 = Image.new(btnPic)
	up2:add(Image.new(btnClosePic))
	
	local closeButton = self._bgRoot:add(ui.Button.new(up2))
	closeButton:setLoc(-110, -140)
	closeButton.onClick = function()
		self:close()
		eventhub.fire("UI_EVENT", "NOUSE_ADD_STEP")
	end
	
	self._tbText = {}
	local textNode = self._bgRoot:add(node.new())
	for key, var in ipairs(tbText) do
		self._tbText[key] = textNode:add(Image.new(var))
	end
	
	self._txtPrice = self._bgRoot:add(TextBox.new("1", "buynumber", nil, nil, 50))
	self._txtSteps = self._bgRoot:add(TextBox.new("2", "buynumber", nil, nil, 50))
	-- self._buytimes = self._bgRoot:add(TextBox.new("3", "buynumber", nil, nil, 50))
	self._txtPrice:setLoc(-90, 75)
	self._txtSteps:setLoc(116, 75)
	-- self._buytimes:setLoc(-40, 48)
end

function AddStepPanel:setInfo()
	self._txtPrice:setString(tostring(GameConfig.buyStepPrice))
	self._txtSteps:setString(tostring(GameConfig.buySteps))
	-- self._buytimes:setString(tostring(GamePlay._buyStepTimes))
end

function AddStepPanel:open()
	popupLayer:add(self._root)
	WindowOpenStyle:openWindowAlpha(self._bgRoot)
	WindowOpenStyle:openWindowScl(self._bgRoot)
	self:setInfo()
end

function AddStepPanel:close()
	popupLayer:remove(self._root)
end

return AddStepPanel