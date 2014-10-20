
local ui = require "ui"
local timer = require "timer"
local device = require "device"
local Image = require "gfx.Image"
local UserData = require "UserData"
local eventhub = require "eventhub"
local Item = require "settings.Item"
local TextBox = require "gfx.TextBox"
local Timing = require "settings.Timing"
local WindowOpenStyle = require "windows.WindowOpenStyle"


local TimingHelp = {}


local backGround = "panel/js_di.atlas.png#js_di.png"

local kickMonsterItemIdx = 8

local tbMoneyPic = 
{
	gold = "ui.atlas.png#gold_small.png",
	money = "ui.atlas.png#money_small.png",
}

local tbBtnPic = 
{
	{
		"ui.atlas.png#js_1.png",
		-100,
		-145,
	},
	{	
		"ui.atlas.png#js_2.png",
		100,
		-145,
	},
	{
		"ui.atlas.png#js_3.png",
		100,
		-145,
	},
}

local tbImage = 
{
	["first"] = "ui.atlas.png#js_wz_2.png?loc=0, 20",
	["second"] = "ui.atlas.png#js_wz_1.png?loc=0, 10",
	["three"] = "ui.atlas.png#js_wz_3.png?loc=0, 10",
}

local tbBtnClick =
{
	["first"] = 
	{
		[1] = function()
			TimingHelp:close()
		end,
		[3] = function()
			eventhub.fire("UI_EVENT", "OPEN_TIMING_HELP", "second", TimingHelp._idx)
		end,	
	},
	["second"] = 
	{
		[1] = function()
			local cost = Timing:getTimOpenCost(TimingHelp._idx)
			if UserData:costMoney(cost) then
				TimingHelp:close()
				UserData:setTimingOpen(TimingHelp._idx, 0)
				eventhub.fire("UI_EVENT", "OPEN_TIMING_PANEL", TimingHelp._idx)
			else
				local tbParam = {}
				tbParam.strIndex = 1
				tbParam.fun = function()
					eventhub.fire("UI_EVENT", "OPEN_BUY_PANEL", "rmbtomoney")
				end
				eventhub.fire("UI_EVENT", "OPEN_MESSAGEBOX", tbParam)
			end
		end,
		[2] = function()
			TimingHelp:close()
		end,
	},
	["three"] = 
	{
		[1] = function()
			if UserData:useItem(kickMonsterItemIdx) then
				TimingHelp:close()
			end			
		end,
		[2] = function()
			TimingHelp:close()
			eventhub.fire("UI_EVENT", "NOUSE_KICK_MONSTER")
		end,
	},
}

local tbPos = 
{
	["second"] =
	{
		text = {18, 38},
		img = {80, 38},
	},
	["three"] = 
	{
		text = {28, 42},
		img = {90, 42},
	},
}


function TimingHelp:init()
	eventhub.bind("UI_EVENT", "OPEN_TIMING_HELP", function(flag, idx)
		self:open(flag, idx)
	end)
	
	self._root = ui.PickBox.new(device.ui_width, device.ui_height)
	self._root:setPriorityOffset(1)
	self._bgRoot = self._root:add(Image.new(backGround))
	self._root:setLayoutSize(self._bgRoot:getSize())
	
	self._tbBtn = {}
	for key, var in ipairs(tbBtnPic) do
		self._tbBtn[key] = ui.Button.new(var[1])
		self._tbBtn[key]:setLoc(var[2], var[3])
	end
	
	self._textImg = self._bgRoot:add(Image.new())
	self._imgCost = self._textImg:add(Image.new())
	self._textCost = self._textImg:add(TextBox.new("1", "kick", nil, "MM", 150))
	
	self._countDown = self._bgRoot:add(TextBox.new("1", "timing", nil, "MM", 400))
	self._countDown:setLoc(0, -35)
end

function TimingHelp:updateTimer()
	local val = UserData:getTimingOpen(self._idx)
	local offset = os.time() - val
	local refresh = Timing:getRefreshTime(self._idx)
	if refresh >= offset then
		offset = refresh - offset
		local hours = tostring(math.floor(offset / 3600))
		if string.len(hours) == 1 then
			hours = "0"..hours
		end
		offset = offset % 3600
		local minutes = tostring(math.floor(offset / 60))
		if string.len(minutes) == 1 then
			minutes = "0"..minutes
		end
		local seconds = tostring(offset % 60)
		if string.len(seconds) == 1 then
			seconds = "0"..seconds
		end
		self._countDown:setString(hours..":"..minutes..":"..seconds)
	else
		self:close()
		eventhub.fire("UI_EVENT", "OPEN_TIMING_PANEL", self._idx)
	end
end

function TimingHelp:preOpen(flag, idx)
	self._idx = idx
	if flag == "first" then
		self._imgCost:remove()
		self._textCost:remove()
		self._tbBtn[2]:remove()
		self._bgRoot:add(self._tbBtn[1])
		self._bgRoot:add(self._tbBtn[3])
		self._bgRoot:add(self._countDown)
		if self._timer then
			self._timer:stop()
			self._timer = nil
		end
		self:updateTimer()
		self._timer = timer.new(1, function() self:updateTimer() end)
	elseif flag == "second" then
		self._tbBtn[3]:remove()
		self._countDown:remove()
		self._bgRoot:add(self._tbBtn[1])
		self._bgRoot:add(self._tbBtn[2])
		self._bgRoot:add(self._imgCost)
		self._bgRoot:add(self._textCost)
		local cost = Timing:getTimOpenCost(self._idx)
		self._textCost:setString(tostring(cost))
		self._textCost:setLoc(tbPos[flag].text[1], tbPos[flag].text[2])
		self._imgCost:load(tbMoneyPic.money)
		self._imgCost:setLoc(tbPos[flag].img[1], tbPos[flag].img[2])
	elseif flag == "three" then
		self._tbBtn[3]:remove()
		self._countDown:remove()
		self._bgRoot:add(self._tbBtn[1])
		self._bgRoot:add(self._tbBtn[2])
		self._bgRoot:add(self._imgCost)
		self._bgRoot:add(self._textCost)
		local itemData = Item:getItemInfo(kickMonsterItemIdx)
		self._imgCost:load(tbMoneyPic[itemData.costtype])
		self._imgCost:setLoc(tbPos[flag].img[1], tbPos[flag].img[2])
		self._textCost:setString(tostring(itemData.cost))
		self._textCost:setLoc(tbPos[flag].text[1], tbPos[flag].text[2])
	end
	
	self._textImg:load(tbImage[flag])
	
	for key, var in ipairs(self._tbBtn) do
		var.onClick = tbBtnClick[flag][key]
	end
end

function TimingHelp:open(flag, idx)
	self:preOpen(flag, idx)
	WindowOpenStyle:openWindowScl(self._bgRoot)
	WindowOpenStyle:openWindowAlpha(self._bgRoot)
	popupLayer:add(self._root)
end

function TimingHelp:close()
	if self._timer then
		self._timer:stop()
		self._timer = nil
	end
	popupLayer:remove(self._root)
end

return TimingHelp