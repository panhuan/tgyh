
local ui = require "ui"
local Image = require "gfx.Image"
local device = require "device"
local eventhub = require "eventhub"
local TextBox = require "gfx.TextBox"
local Item = require "settings.Item"
local WindowOpenStyle = require "windows.WindowOpenStyle"


local RewardPanel = {}


local backGround = "panel/reward_bg.atlas.png#reward_bg.png"
local closePic1 = "ui.atlas.png#close_1.png"
local closePic2 = "ui.atlas.png#close_2.png?scl=1.2"
local btnPic = "ui.atlas.png#ts_qd_liang.png"
local xPic = "ui.atlas.png#X.png"
local shareBtn = "ui.atlas.png#kuang_fx_1.png"
local okBtn = "ui.atlas.png#kuang_fx_2.png"
local moneyIco = "ui.atlas.png#money_small.png"

local tbTittlePic = 
{
	["reward"] = "ui.atlas.png#jl_ti_zi.png?loc=0, 120",
	["charge"] = "ui.atlas.png#czcg.png?loc=0, 120",
	["exchange"] = "ui.atlas.png#dhcg.png?loc=0, 120",
}

local tbRewardIcon = 
{
	["exp"] 	= "ui.atlas.png#gold_big.png",
	["gold"] 	= "ui.atlas.png#gold_big.png",
	["money"] 	= "ui.atlas.png#money_big.png",
	["ap"] 		= "ui.atlas.png#ap_big.png",
}


function RewardPanel:init()
	eventhub.bind("UI_EVENT", "OPEN_REWARD_PANEL", function(tbParam)
		self:open(tbParam)
	end)
	
	self._root = ui.PickBox.new(device.ui_width, device.ui_height)
	self._root:setPriorityOffset(2000)
	self._bgRoot = self._root:add(Image.new(backGround))
	self._root:setLayoutSize(Image.getSize(self._bgRoot))
	
	self._closeBtn = self._bgRoot:add(ui.Button.new(closePic1, closePic2))
	self._closeBtn:setAnchor("RT", -50, -120)
	self._closeBtn.onClick = function()
		self:close()
	end
	
	self._useBtn = self._bgRoot:add(ui.Button.new(btnPic, btnPic.."?scl=1.2"))
	self._useBtn:setAnchor("MB", 0, 90)
	self._useBtn.onClick = function()
		self:close()
	end
	
	local up = Image.new(shareBtn)
	local up_ico = up:add(Image.new(moneyIco))
	up_ico:setLoc(65, 0)
	
	self._shareBtn = self._bgRoot:add(ui.Button.new(up))
	self._shareBtn:setAnchor("MB", 0, 90)
	self._shareBtn.onClick = function()
		self:close()
	end
	
	self._title = self._bgRoot:add(Image.new())
	
	self._icon = self._bgRoot:add(Image.new())
	self._icon:setLoc(-80, -20)
	
	local xImg = self._bgRoot:add(Image.new(xPic))
	xImg:setLoc(0, -20)
	
	self._numText = self._bgRoot:add(TextBox.new("0", "buynumber", nil, "MM", 150, 60))
	self._numText:setLoc(80, -20)
end

function RewardPanel:create(tbParam)
	if tbParam.type == "item" then
		local itemInfo = Item:getItemInfo(tbParam.itemId)
		self._icon:load(itemInfo.pic)
	else
		self._icon:load(tbRewardIcon[tbParam.type])
	end
	
	if tbParam.way then
		self._title:load(tbTittlePic[tbParam.way])
	else
		self._title:load(tbTittlePic["reward"])
	end
	
	if tbParam.num then
		self._numText:setString(tostring(tbParam.num))
	end
	
	if tbParam.share then
		self._useBtn:remove()
		self._bgRoot:add(self._shareBtn)
	else
		self._shareBtn:remove()
		self._bgRoot:add(self._useBtn)
	end
	
	if tbParam.fun then
		self._useBtn.onClick = function()
			self:close()
			pcall(tbParam.fun)
		end
	end
	
	if tbParam.closefun then
		self._closeBtn.onClick = function()
			self:close()
			pcall(tbParam.closefun)
		end
	end
	
	if tbParam.sharefun then
		self._shareBtn.onClick = function()
			self:close()
			pcall(tbParam.sharefun)
		end
	end
end

function RewardPanel:destroy()
	self._useBtn.onClick = function()
		self:close()
	end
	self._closeBtn.onClick = function()
		self:close()
	end
	self._shareBtn.onClick = function()
		self:close()
	end
end

function RewardPanel:open(tbParam)
	if not tbParam then
		return
	end
	
	if self._opening then
		self:pushReward(tbParam)
		return
	end
	
	self._opening = true

	WindowOpenStyle:openWindowScl(self._bgRoot)
	WindowOpenStyle:openWindowAlpha(self._bgRoot)
	popupLayer:add(self._root)
	self:create(tbParam)
end

function RewardPanel:close()
	popupLayer:remove(self._root)
	self:destroy()
	self._opening = false
	
	self:tryOpenNext()
end

function RewardPanel:tryOpenNext()
	local tbParam = self:popReward()
	if tbParam then
		self:open(tbParam)
	end
end

function RewardPanel:pushReward(tbParam)
	if not self._tbRewardList then
		self._tbRewardList = {}
	end
	
	table.insert(self._tbRewardList, tbParam)
end

function RewardPanel:popReward()
	if not self._tbRewardList then
		return
	end
	
	local tbParam = self._tbRewardList[1]
	if tbParam then
		table.remove(self._tbRewardList, 1)
	end
	
	return tbParam
end

return RewardPanel