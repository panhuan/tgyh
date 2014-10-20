
local ui = require "ui"
local node = require "node"
local Image = require "gfx.Image"
local device = require "device"
local Buy = require "settings.Buy"
local Item = require "settings.Item"
local UserData = require "UserData"
local TextBox = require "gfx.TextBox"
local eventhub = require "eventhub"
local WindowOpenStyle = require "windows.WindowOpenStyle"
local ActLog = require "ActLog"


local ItemPanel = {}


local backGround = "panel/step_bg.atlas.png#step_bg.png?scl=1.1, 0.82"
local closePic1 = "ui.atlas.png#close_1.png"
local closePic2 = "ui.atlas.png#close_2.png?scl=1.2"
local titlePic = "ui.atlas.png#item_title.png"
local itemBackPic = "ui.atlas.png#s_window.png"
local itemCountText = "ui.atlas.png#item_count.png"
local itemCount = "ui.atlas.png#item_count_pic.png"
local itemAddBtn1 = "ui.atlas.png#item_add_1.png"
local itemAddBtn2 = "ui.atlas.png#item_add_2.png?scl=1.1"
local itemMinusBtn1 = "ui.atlas.png#item_minus_1.png"
local itemMinusBtn2 = "ui.atlas.png#item_minus_2.png?scl=1.1"
local buyPic = "ui.atlas.png#buy_panel.png"
local buttonPic1 = "ui.atlas.png#buy_btn_1.png"
local buttonPic2 = "ui.atlas.png#buy_btn_2.png?scl=1.2"
local btnText = "ui.atlas.png#btn_text.png"
local itemText = "ui.atlas.png#item_text.png"
local costPic = "ui.atlas.png#item_num.png"

local tbCostImg = 
{
	["money"] = "ui.atlas.png#money_small.png",
	["gold"] = "ui.atlas.png#gold_small.png",
}

local tbItemName =
{
	[1] = "ui.atlas.png#itemzi_4.png",
	[2] = "ui.atlas.png#itemzi_5.png",
	[3] = "ui.atlas.png#itemzi_6.png",
}

function ItemPanel:init()
	eventhub.bind("UI_EVENT", "OPEN_ITEM_PANEL", function(Idx)
		self:open(Idx)
	end)
	
	self._buyCount = 1
	
	self._root = ui.PickBox.new(device.ui_width, device.ui_height)
	self._root:setPriority(1)
	self._bg = self._root:add(Image.new(backGround))
	self._root:setLayoutSize(self._bg:getSize())
	
	self._bgRoot = self._root:add(node.new())
	self._bgRoot:setPriorityOffset(2)
	
	self._title = self._bgRoot:add(Image.new(titlePic))
	self._title:setAnchor("MT", 0, -65)
	
	local closeButton = self._bgRoot:add(ui.Button.new(closePic1, closePic2))
	closeButton:setAnchor("RT", -50, -65)
	closeButton.onClick = function()
		self:close()
	end
	
	self._itemPanel = self._bgRoot:add(Image.new(itemBackPic))
	self._itemPanel:setLoc(-140, 0)
	
	self._item = self._itemPanel:add(Image.new())
	
	self._itemName = self._itemPanel:add(Image.new())
	self._itemName:setLoc(0, 75)
	
	local costImg = self._itemPanel:add(Image.new(costPic))
	costImg:setLoc(0, -70)
	self._itemPrice = costImg:add(TextBox.new("1", "buyprice"))
	
	self._text = self._bgRoot:add(Image.new(itemCountText))
	self._text:setLoc(60, 120)
	
	self._count = self._bgRoot:add(Image.new(itemCount))
	self._count:setLoc(90, 40)
	
	self._countText = self._count:add(TextBox.new(tostring(self._buyCount), "item", nil, "MM", 110))
	
	self._addBtn = self._count:add(ui.Button.new(itemAddBtn1, itemAddBtn2))
	self._addBtn:setLoc(80, 0)
	self._addBtn.onClick = function()
		self:addItemCount()
	end
	self._minusBtn = self._count:add(ui.Button.new(itemMinusBtn1, itemMinusBtn2))
	self._minusBtn:setLoc(-76, 0)
	self._minusBtn.onClick = function()
		self:minusItemCount()
	end
	
	self._buyImg = self._bgRoot:add(Image.new(buyPic))
	self._buyImg:setLoc(50, -50)
	
	self._ico = self._buyImg:add(Image.new())
	self._ico:setLoc(-50, 0)
	
	self._price = self._buyImg:add(TextBox.new(tostring(self._buyCount), "buyprice", nil, "MM", 88))
	self._price:setLoc(10, 0)
	
	local up = Image.new(buttonPic1)
	up:add(Image.new(btnText))
	self._btn = self._buyImg:add((ui.Button.new(up)))
	self._btn:setLoc(110, 0)
	self._btn.onClick = function()
		self:buyItem()
		self:close()
	end
	
	self._goldImg = self._bgRoot:add(Image.new(itemText))
	self._goldImg:setLoc(-5, -115)
	
	self._goldText = self._bgRoot:add(TextBox.new(tostring(UserData.gold), "money", nil, "LM"))
	self._goldText:setLoc(100, -115)
	
	self._goldIco = self._bgRoot:add(Image.new())
end

function ItemPanel:addItemCount()
	local itemInfo = Item:getItemInfo(self._idx)
	self._buyCount = self._buyCount + 1
	self._countText:setString(tostring(self._buyCount))
	self._price:setString(tostring(self._buyCount * itemInfo.cost))
end

function ItemPanel:minusItemCount()
	local itemInfo = Item:getItemInfo(self._idx)
	if self._buyCount > 1 then
		self._buyCount = self._buyCount - 1
		self._countText:setString(tostring(self._buyCount))
		self._price:setString(tostring(self._buyCount * itemInfo.cost))
	end
end

function ItemPanel:buyItem()
	UserData:buyItemCount(self._idx, self._buyCount)
end

function ItemPanel:initPanel(Idx)
	self._idx = Idx
	self._buyCount = 1
	self._countText:setString(tostring(self._buyCount))
	local itemInfo = Item:getItemInfo(self._idx)
	self._price:setString(tostring(self._buyCount * itemInfo.cost))
	self._ico:load(tbCostImg[itemInfo.costtype])
	self._goldIco:load(tbCostImg[itemInfo.costtype])
	self._item:load(itemInfo.pic)
	self._itemName:load(tbItemName[Idx])
	self._itemPrice:setString(tostring(itemInfo.cost), true)
	if itemInfo.costtype == "gold" then
		self._goldText:setString(tostring(UserData.gold), true)
	else
		self._goldText:setString(tostring(UserData.money), true)
	end
	local w = self._goldText:getSize()
	local x, y = self._goldText:getLoc()
	self._goldIco:setLoc(x + w / 2 + 20, y)
end

function ItemPanel:open(Idx)
	self:initPanel(Idx)
	WindowOpenStyle:openWindowAlpha(self._bgRoot)
	popupLayer:add(self._root)
end

function ItemPanel:close()
	popupLayer:remove(self._root)
end

return ItemPanel
