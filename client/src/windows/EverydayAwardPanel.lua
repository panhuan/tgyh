
local ui = require "ui"
local device = require "device"
local Image = require "gfx.Image"
local TextBox = require "gfx.TextBox"
local eventhub = require "eventhub"
local UserData = require "UserData"
local Particle = require "gfx.Particle"
local node = require "node"
local Item = require "settings.Item"
local EverydayAward = require "settings.EverydayAward"
local WindowOpenStyle = require "windows.WindowOpenStyle"
local MainPanel = require "windows.MainPanel"
local NetworkTipPanel = require "windows.NetworkTipPanel"
local Player = require "logic.Player"


local backGround = "$panel/step_bg.atlas.png#step_bg.png?scl=1.15, 1"
local titlePic = "ui.atlas.png#award_title.png"
local useBtn = "ui.atlas.png#stepbtn.png"
local btnText = "ui.atlas.png#award_btn_text.png"
local awardBoxPic1 = "ui.atlas.png#award_panel.png"
local awardBoxPic2 = "ui.atlas.png#award_panel_1.png"
local moneyPic = "ui.atlas.png#money_big.png"
local zzPic = "ui.atlas.png#zz.png"
local flagPic = "ui.atlas.png#award_zi1.png"
local pex = "absorption.pex"


local tbPos =
{
	[1] = {x = -150, y = 110},
	[2] = {x = 0, y = 110},
	[3] = {x = 150, y = 110},
	[4] = {x = -175, y = -110},
	[5] = {x = -58, y = -110},
	[6] = {x = 58, y = -110},
	[7] = {x = 175, y = -110},
}

local tbDayPic =
{
	[1] = "ui.atlas.png#awardzi_1.png",
	[2] = "ui.atlas.png#awardzi_2.png",
	[3] = "ui.atlas.png#awardzi_3.png",
	[4] = "ui.atlas.png#awardzi_4.png",
	[5] = "ui.atlas.png#awardzi_5.png",
	[6] = "ui.atlas.png#awardzi_6.png",
	[7] = "ui.atlas.png#awardzi_7.png",
}

local tbGoldPos = 
{
	[1] = 
	{	
		[1] = {"ui.atlas.png#gold_big.png", 1},
	},
	[2] =
	{
		[1] = {"ui.atlas.png#gold_small.png?rot=-75&loc=6, 1", 3},
		[2] = {"ui.atlas.png#gold_small.png?rot=-75&loc=8, -9", 2},
		[3] = {"ui.atlas.png#gold_small.png?rot=-75&loc=8, -16", 1},
	},
	[3] =
	{
		[1] = {"ui.atlas.png#gold_small.png?rot=-75&loc=6, 1", 5},
		[2] = {"ui.atlas.png#gold_small.png?rot=-75&loc=-10, -3", 1},
		[3] = {"ui.atlas.png#gold_small.png?rot=-75&loc=8, -9", 4},
		[4] = {"ui.atlas.png#gold_small.png?rot=-75&loc=-20, -11", 2},
		[5] = {"ui.atlas.png#gold_small.png?rot=-75&loc=8, -16", 3},
	},
	[4] =
	{
		[1] = {"ui.atlas.png#gold_small.png?rot=-75&loc=-10, 5", 2},
		[2] = {"ui.atlas.png#gold_small.png?rot=-75&loc=6, 1", 6},
		[3] = {"ui.atlas.png#gold_small.png?rot=-75&loc=-10, -3", 1},
		[4] = {"ui.atlas.png#gold_small.png?rot=-75&loc=8, -9", 5},
		[5] = {"ui.atlas.png#gold_small.png?rot=-75&loc=-20, -11", 3},
		[6] = {"ui.atlas.png#gold_small.png?rot=-75&loc=8, -16", 4},
	},
	[5] =
	{
		[1] = {"ui.atlas.png#gold_small.png?rot=-75&loc=-10, 5", 2},
		[2] = {"ui.atlas.png#gold_small.png?rot=-75&loc=6, 1", 7},
		[3] = {"ui.atlas.png#gold_small.png?rot=-75&loc=-10, -3", 1},
		[4] = {"ui.atlas.png#gold_small.png?rot=-75&loc=29, -4", 4},
		[5] = {"ui.atlas.png#gold_small.png?rot=-75&loc=8, -9", 6},
		[6] = {"ui.atlas.png#gold_small.png?rot=-75&loc=-20, -11", 3},
		[7] = {"ui.atlas.png#gold_small.png?rot=-75&loc=8, -16", 5},
	},
	[6] =
	{	
		[1] = {"ui.atlas.png#gold_small.png?rot=-75&loc=-10, 21", 4},
		[2] = {"ui.atlas.png#gold_small.png?rot=-75&loc=-10, 13", 3},
		[3] = {"ui.atlas.png#gold_small.png?rot=-75&loc=-10, 5", 2},
		[4] = {"ui.atlas.png#gold_small.png?rot=-75&loc=6, 1", 10},
		[5] = {"ui.atlas.png#gold_small.png?rot=-40&loc=-20, 0", 7},
		[6] = {"ui.atlas.png#gold_small.png?rot=-75&loc=-10, -3", 1},
		[7] = {"ui.atlas.png#gold_small.png?rot=-75&loc=29, -4", 6},
		[8] = {"ui.atlas.png#gold_small.png?rot=-75&loc=8, -9", 9},
		[9] = {"ui.atlas.png#gold_small.png?rot=-75&loc=-20, -11", 5},
		[10] = {"ui.atlas.png#gold_small.png?rot=-75&loc=8, -16", 8},
	},
	[7] =
	{
		[1] = {"ui.atlas.png#gold_small.png?rot=-75&loc=-10, 28", 5},
		[2] = {"ui.atlas.png#gold_small.png?rot=-75&loc=-10, 21", 4},
		[3] = {"ui.atlas.png#gold_small.png?rot=-75&loc=-10, 13", 3},
		[4] = {"ui.atlas.png#gold_small.png?rot=-75&loc=9, 10", 12},
		[5] = {"ui.atlas.png#gold_small.png?rot=-75&loc=-10, 5", 2},
		[6] = {"ui.atlas.png#gold_small.png?rot=-75&loc=6, 1", 11},
		[7] = {"ui.atlas.png#gold_small.png?rot=-40&loc=-20, 0", 8},
		[8] = {"ui.atlas.png#gold_small.png?rot=-75&loc=-10, -3", 1},
		[9] = {"ui.atlas.png#gold_small.png?rot=-75&loc=29, -4", 7},
		[10] = {"ui.atlas.png#gold_small.png?rot=-75&loc=8, -9", 10},
		[11] = {"ui.atlas.png#gold_small.png?rot=-75&loc=-20, -11", 6},
		[12] = {"ui.atlas.png#gold_small.png?rot=-75&loc=8, -16", 9},
	},
}


local EverydayAwardPanel = {}


function EverydayAwardPanel:init()
	eventhub.bind("UI_EVENT", "OPEN_EVERYDAY_PANEL", function(flag)
		self._flag = flag
		self:getNowTime()
	end)
	
	self._root = ui.PickBox.new(device.ui_width, device.ui_height)
	self._root:setPriority(1)
	self._bgRoot = self._root:add(Image.new(backGround))
	self._root:setLayoutSize(self._bgRoot:getSize())
	
	self._title = self._bgRoot:add(Image.new(titlePic))
	self._title:setAnchor("MT", 0, -80)
	
	local up = Image.new(useBtn)
	up:add(Image.new(btnText))
	self.useButton = self._bgRoot:add(ui.Button.new(up))
	self.useButton:setAnchor("MB", 0, 70)
	self.useButton.onClick = function()
		if not device.getConnectionType() then
			NetworkTipPanel:open("device")
		end
		self:playAwardAni()
		self:addAward()
	end
	
	self:createAward()
	self._showActivity = false
end

function EverydayAwardPanel:createAward()
	self._tbAward = {}
	for i = 1, 7 do
		local awardBox = self:createOneAward(i)
		self._bgRoot:add(awardBox._root)
		awardBox._root:setLoc(tbPos[i].x, tbPos[i].y)
		self._tbAward[i] = awardBox
	end
end

function EverydayAwardPanel:createOneAward(idx)
	local awardBox = {}
	awardBox._root = Image.new(awardBoxPic1)
	awardBox._text = awardBox._root:add(Image.new(tbDayPic[idx]))
	awardBox._text:setLoc(0, 56)
	local awardPic = nil
	local count = ""
	local award = EverydayAward:getAward(idx)
	if award.awardType == "gold" then	
		awardPic = node.new()
		awardBox._tbGold = {}
		for key, var in ipairs(tbGoldPos[idx]) do
			awardBox._tbGold[key] = {}
			awardBox._tbGold[key].img = awardPic:add(Image.new(var[1]))
			awardBox._tbGold[key].img:setScl(0.8, 0.95)
			awardBox._tbGold[key].img:setPriorityOffset(var[2])
			awardBox._tbGold[key].pex = awardBox._tbGold[key].img:add(Particle.new(pex, mainAS))
			awardBox._tbGold[key].pex.hitTest = function() return false end
			awardBox._tbGold[key].pex:setPriorityOffset(20)
		end
		count = tostring(award.param)
	elseif award.awardType == "money" then
		awardPic = Image.new(moneyPic)
		awardBox._moneyPex = awardPic:add(Particle.new(pex, mainAS))
		awardBox._moneyPex.hitTest = function() return false end
		awardBox._moneyPex:setPriorityOffset(20)
		awardPic:setLoc(0, 5)
		count = tostring(award.param)
	elseif award.awardType == "item" then
		local iteminfo = Item:getItemInfo(award.param)
		awardPic = Image.new(iteminfo.pic)
		awardPic:setLoc(0, 5)
		count = tostring(award.param2)
	else
		print("#[error]# award.awardType is :"..award.awardType)
	end
	awardBox._ico = awardBox._root:add(awardPic)
	
	awardBox._number = awardBox._root:add(TextBox.new(count, "pet", nil, "MM", 200))
	awardBox._number:setLoc(0, -52)
	
	awardBox._mask = awardBox._root:add(Image.new())
	awardBox._mask:setPriorityOffset(15)
	awardBox._flag = awardBox._mask:add(Image.new())
	
	return awardBox
end

function EverydayAwardPanel:serverTimeFun(now)
	self._index = UserData:setAwardInfo(now)
	
	if not self._index and not self._flag then
		eventhub.fire("UI_EVENT", "OPEN_ACTIVITY_PANEL")
		return
	end
	
	if self._index and not self._flag then
		self._showActivity = true
	end
	
	self:checkAward()
	
	self:open()
end

function EverydayAwardPanel:getNowTime()
	Player:getServerTime(function(now)
		self:serverTimeFun(now)
	end)
end

function EverydayAwardPanel:checkAward(now)
	if self._index then
		for key, var in ipairs(self._tbAward) do
			if key == self._index then
				var._root:load(awardBoxPic2)
				var._mask:load()
				var._flag:load()
			elseif key < self._index then
				var._root:load(awardBoxPic1)
				var._mask:load(zzPic)
				var._flag:load(flagPic)
			else
				var._root:load(awardBoxPic1)
				var._mask:load()
				var._flag:load()
			end
		end
	else
		local index = UserData.award.days or 0
		for key, var in ipairs(self._tbAward) do
			var._root:load(awardBoxPic1)
			if key <= index then
				var._mask:load(zzPic)
				var._flag:load(flagPic)
			else
				var._mask:load()
				var._flag:load()
			end
		end
	end
end

function EverydayAwardPanel:playAwardAni()
	if not self._index then
		self:close()
		return
	end
	local index = self._index
	local award = EverydayAward:getAward(index)
	
	local tbOldPos = {}
	if award.awardType == "gold" then
		local x, y = MainPanel._goldBtn:getWorldLoc()
		if #(self._tbAward[index]._tbGold) == 1 then
			tbOldPos[1] = {self._tbAward[index]._tbGold[1].img:getLoc()}
			self._tbAward[index]._tbGold[1].img:seekScl(0.5, 0.5, 0.2)
			local c = self._tbAward[index]._tbGold[1].img:seekLoc(x - tbPos[index].x - 85, y - tbPos[index].y, 0.2)
			c:setListener(MOAIAction.EVENT_STOP, function()
				self._tbAward[index]._tbGold[1].pex:begin()
			end)
		else	
			for key, var in ipairs(self._tbAward[index]._tbGold) do
				tbOldPos[key] = {var.img:getLoc()}
				tbOldPos[key][3] = var.img:getRot()
				mainAS:delaycall(0.1 * key, function()
					local c = var.img:seekLoc(x - tbPos[index].x - 85, y - tbPos[index].y, 0.2)
					c:setListener(MOAIAction.EVENT_STOP, function()
						var.pex:begin()
						var.img:setRot(0)
						var.img:setScl(1, 1)
					end)
				end)
			end
		end
		local closetime = (#(self._tbAward[index]._tbGold) + 10) * 0.1
		mainAS:delaycall(closetime, function()
			self:close()
			if #tbOldPos == 1 then
				self._tbAward[index]._tbGold[1].img:setScl(1, 1)
				self._tbAward[index]._tbGold[1].img:setLoc(tbOldPos[1][1], tbOldPos[1][2])
			else
				for key, var in ipairs(tbOldPos) do
					self._tbAward[index]._tbGold[key].img:setRot(var[3])
					self._tbAward[index]._tbGold[key].img:setScl(0.8, 0.95)
					self._tbAward[index]._tbGold[key].img:setLoc(var[1], var[2])
				end
			end
		end)
	elseif award.awardType == "money" then
		local x, y = MainPanel._moneyBtn:getWorldLoc()
		tbOldPos[1] = {self._tbAward[index]._ico:getLoc()}
		self._tbAward[index]._ico:seekScl(0.5, 0.5, 0.2)
		local c = self._tbAward[index]._ico:seekLoc(x - tbPos[index].x - 85, y - tbPos[index].y, 0.2)
		c:setListener(MOAIAction.EVENT_STOP, function()
			self._tbAward[index]._moneyPex:begin()
			mainAS:delaycall(1, function()
				self:close()
				self._tbAward[index]._ico:setScl(1, 1)
				self._tbAward[index]._ico:setLoc(tbOldPos[1][1], tbOldPos[1][2])
			end)
		end)
	elseif award.awardType == "item" then	
		WindowOpenStyle:nodeJellyEffect(self._tbAward[index]._ico)
		mainAS:delaycall(1, function()
			self:close()
		end)
	else
		self:close()
	end
end

function EverydayAwardPanel:addAward()
	if not self._index then
		return
	end

	local award = EverydayAward:getAward(self._index)
	
	if award.awardType == "gold" then
		UserData:addGold(award.param)
	elseif award.awardType == "money" then
		UserData:addMoney(award.param)
	elseif award.awardType == "item" then
		UserData:addItemCount(award.param, award.param2)
	else
		print("#[error]# award.awardType is :"..award.awardType)
	end
	
	self._index = nil
end

function EverydayAwardPanel:open()
	WindowOpenStyle:openWindowScl(self._bgRoot)
	WindowOpenStyle:openWindowAlpha(self._bgRoot)
	popupLayer:add(self._root)
end

function EverydayAwardPanel:close()
	popupLayer:remove(self._root)
	if self._showActivity then
		self._showActivity = false
		eventhub.fire("UI_EVENT", "OPEN_ACTIVITY_PANEL")
	end
end

return EverydayAwardPanel