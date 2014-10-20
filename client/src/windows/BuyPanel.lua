
local ui = require "ui"
local Image = require "gfx.Image"
local device = require "device"
local UserData = require "UserData"
local interpolate = require "interpolate"
local eventhub = require "eventhub"
local Buy = require "settings.Buy"
local TextBox = require "gfx.TextBox"
local node = require "node"
local WindowOpenStyle = require "windows.WindowOpenStyle"
local Task = require "logic.Task"


local BuyPanel = {}


local backGround = "panel/panel_1.atlas.png#panel_1.png?loc=0, -20"
local titlePic = "ui.atlas.png#buy_title.png?loc=30, 350"
local closePic1 = "ui.atlas.png#close_1.png"
local closePic2 = "ui.atlas.png#close_2.png?scl=1.2"
local buttonPic1 = "ui.atlas.png#buy_btn_1.png"
local buttonPic2 = "ui.atlas.png#buy_btn_2.png?scl=1.2"
local btnText = "ui.atlas.png#btn_text.png"
local buy_xPic = "ui.atlas.png#x.png"
local chargeRewardTip = "ui.atlas.png#scl_bj.png"


local dropListX, dropListY = 0, -5
local dropListW, dropListH, dropListOffset = 550, 550, 110
local textDestX, textDestY = -33, 1
local buy_xX, buy_xY = -152, -5
local destPicX, destPicY = -200, 8
local textSrcX, textSrcY = -10, 0
local boxImgX, boxImgY = 80, 0
local btnX, btnY = 90, 0

local tbBuy = 
{
	["rmbtomoney"] = 
	{
		ico = "ui.atlas.png#money_big.png",
		box = "ui.atlas.png#buy_panel.png",
		src = "ui.atlas.png#jq_fh.png",
		fun = Buy.RMBPay,
	},
	["moneytogold"] = 
	{
		ico = "ui.atlas.png#gold_big.png",
		box = "ui.atlas.png#buy_panel.png",
		src = "ui.atlas.png#money_small.png",
		fun = Buy.MoneytoGold,
	},
	["moneytoap"] = 
	{
		ico = "ui.atlas.png#ap_big.png",
		box = "ui.atlas.png#buy_panel.png",
		src = "ui.atlas.png#money_small.png",
		fun = Buy.MoneytoAP,
	},
}


function BuyPanel:init()
	eventhub.bind("UI_EVENT", "OPEN_BUY_PANEL", function(mode)
		self:open(mode)
	end)
	eventhub.bind("UI_EVENT", "REFRESH_BUY_PANEL", function(mode)
		self:setMode(mode)
	end)
	
	self._root = ui.PickBox.new(device.ui_width, device.ui_height)
	self._root:setPriorityOffset(1000)
	self._bgRoot = Image.new(backGround)
	self._root:add(self._bgRoot)
	self._root:setLayoutSize(Image.getSize(self._bgRoot))
	
	self._bgRoot:add(Image.new(titlePic))
	self._titleIco = self._bgRoot:add(Image.new(tbBuy["rmbtomoney"].ico))
	self._titleIco:setLoc(-70, 350)
	
	local closeButton = self._bgRoot:add(ui.Button.new(closePic1, closePic2))
	closeButton:setAnchor("RT", -50, -90)
	closeButton.onClick = function()
		self:close()
	end
	
	self._tbBuyList = {}
	self._tbBuyList["rmbtomoney"] = self:createRmbBuyList()
	self._tbBuyList["moneytogold"] = self:createBuyList("moneytogold")
	self._tbBuyList["moneytoap"] = self:createBuyList("moneytoap")
end

function BuyPanel:createRmbBuyList()
	local buyList = ui.DropList.new(dropListW, dropListH, dropListOffset, "vertical")
	buyList:setLoc(dropListX, dropListY)
	
	local mode = "rmbtomoney"
	local productList = Buy:getRMBtoMoneyProductList(VERSION_OPTION)
	for _, productId in ipairs (productList) do
		local var = Buy:getRMBProductInfo(productId)
		-- if productId ~= 1 or not Task:isFinish(2000) then
			local frame = buyList:addItem(ui.PickBox.new(dropListW, dropListOffset))
			local DestImg = frame:add(Image.new(tbBuy[mode].ico))
			DestImg:setLoc(destPicX, destPicY)
			local textDest = frame:add(TextBox.new(tostring(var.dest), "buynumber", nil, "LM", 200))
			textDest:setLoc(textDestX, textDestY)
			local buy_xImg = frame:add(Image.new(buy_xPic))
			buy_xImg:setLoc(buy_xX, buy_xY)
			local boxImg = frame:add(Image.new(tbBuy[mode].box))
			boxImg:setLoc(boxImgX, boxImgY)
			local buyIco = boxImg:add(Image.new(tbBuy[mode].src))
			buyIco:setLoc(-50, 0)
			local textSrc = boxImg:add(TextBox.new(tostring(var.src), "buyprice", nil, "RM", 100))
			textSrc:setLoc(textSrcX, textSrcY)
			local up = Image.new(buttonPic1)
			up:add(Image.new(btnText))			
			local buyBtn = boxImg:add(ui.Button.new(up))
			buyBtn:setLoc(btnX, btnY)
			buyBtn.onClick = function()
				tbBuy[mode].fun(Buy, productId)
			end
			
			-- local showActivityTip = false
			-- if productId == 1 then
				-- showActivityTip = true
			-- end
			
			-- if showActivityTip then
				-- local activityTip = boxImg:add(Image.new(chargeRewardTip))
				-- activityTip:setLoc(-260, -45)
			-- end
		-- end
		
	end
	return buyList
end

function BuyPanel:createBuyList(mode)
	local buyList = ui.DropList.new(dropListW, dropListH, dropListOffset, "vertical")
	buyList:setLoc(dropListX, dropListY)
	
	for key, var in ipairs(Buy[mode]) do
		local frame = buyList:addItem(ui.PickBox.new(dropListW, dropListOffset))
		local DestImg = frame:add(Image.new(tbBuy[mode].ico))
		DestImg:setLoc(destPicX, destPicY)
		local textDest = frame:add(TextBox.new(tostring(var.dest), "buynumber", nil, "LM", 200))
		textDest:setLoc(textDestX, textDestY)
		local buy_xImg = frame:add(Image.new(buy_xPic))
		buy_xImg:setLoc(buy_xX, buy_xY)
		local boxImg = frame:add(Image.new(tbBuy[mode].box))
		boxImg:setLoc(boxImgX, boxImgY)
		local buyIco = boxImg:add(Image.new(tbBuy[mode].src))
		buyIco:setLoc(-50, 0)
		local textSrc = boxImg:add(TextBox.new(tostring(var.src), "buyprice", nil, "RM", 100))
		textSrc:setLoc(textSrcX, textSrcY)
		local up = Image.new(buttonPic1)
		up:add(Image.new(btnText))	
		local buyBtn = boxImg:add(ui.Button.new(up))
		buyBtn:setLoc(btnX, btnY)
		buyBtn.onClick = function()
			tbBuy[mode].fun(Buy, key)
		end
	end
	return buyList
end

function BuyPanel:setMode(mode)
	if mode == "rmbtomoney" then
		self._tbBuyList["rmbtomoney"]:destroy()
		self._tbBuyList["rmbtomoney"] = self:createRmbBuyList()
	end

	if not self._mode then
		self._mode = mode
		self._bgRoot:add(self._tbBuyList[self._mode])
		self._titleIco:load(tbBuy[mode].ico)
	else
		self._bgRoot:remove(self._tbBuyList[self._mode])
		self._mode = mode
		self._bgRoot:add(self._tbBuyList[self._mode])
		self._titleIco:load(tbBuy[mode].ico)
	end
end

function BuyPanel:open(mode)
	self:setMode(mode)
	WindowOpenStyle:openWindowScl(self._bgRoot)
	WindowOpenStyle:openWindowAlpha(self._bgRoot)
	popupLayer:add(self._root)
end

function BuyPanel:close()
	popupLayer:remove(self._root)
end


return BuyPanel
