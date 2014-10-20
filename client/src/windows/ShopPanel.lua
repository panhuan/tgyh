
local ui = require "ui"
local node = require "node"
local Image = require "gfx.Image"
local device = require "device"
local eventhub = require "eventhub"
local TextBox = require "gfx.TextBox"
local UserData = require "UserData"
local WindowOpenStyle = require "windows.WindowOpenStyle"
local Buy = require "settings.Buy"


local ShopPanel = {}

local backGround = "panel/panel_1.atlas.png#panel_1.png"
local titlePic = "shoppanel.atlas.png#bsxd_1.png"
local closePic = "ui.atlas.png#close_1.png"
local moneyPic = "ui.atlas.png#money_small.png"

local dropListW, dropListH, dropListOffset = 480, 585, 140

local tbProductList = 
{
	{
		product = 8,
		icon = "shoppanel.atlas.png#bsxd_5.png",
	},
	{
		product = 11,
		icon = "shoppanel.atlas.png#4.png",
	},
	{
		product = 12,
		icon = "shoppanel.atlas.png#5.png",
	},
	{
		product = 13,
		icon = "shoppanel.atlas.png#3.png",
	},
	{
		product = 14,
		icon = "shoppanel.atlas.png#6.png",
	},
	{
		product = 15,
		icon = "shoppanel.atlas.png#12.png",
	},
	{
		product = 16,
		icon = "shoppanel.atlas.png#22.png",
	},
	{
		product = 17,
		icon = "shoppanel.atlas.png#28.png",
	},
	{
		product = 7,
		icon = "shoppanel.atlas.png#bsxd_2.png",
	},
	{
		product = "unlock_all_pet",
		icon = "shoppanel.atlas.png#bsxd_7.png",
	},
	{
		product = "unlock_all_robot",
		icon = "shoppanel.atlas.png#bsxd_9.png",
	},
	
}

function ShopPanel:init()
	eventhub.bind("UI_EVENT", "OPEN_SHOP_PANEL", function()
		self:open()
	end)
	
	eventhub.bind("UI_EVENT", "REFRESH_SHOP_PANEL", function()
		self:initProductList()
	end)
	
	self._root = ui.PickBox.new(device.ui_width, device.ui_height)
	self._root:setPriorityOffset(1)
	self._bgRoot = self._root:add(Image.new(backGround))
	self._root:setLayoutSize(Image.getSize(self._bgRoot))
	
	local title = self._bgRoot:add(Image.new(titlePic))
	title:setAnchor("MT", 0, -90)
	
	local closeButton = self._bgRoot:add(ui.Button.new(closePic))
	closeButton:setAnchor("RT", -50, -90)
	closeButton.onClick = function()
		self:close()
	end
	
end

function ShopPanel:initProductList()
	if self._productList then
		self._productList:destroy()
	end
	
	self._productList = self._bgRoot:add(ui.DropList.new(dropListW, dropListH, dropListOffset, "vertical"))
	self._productList:setLoc(0, -4)
	for _, p in ipairs (tbProductList) do
		local productOnSale = true
		
		if type(p.product) == "number" then
			local productInfo = Buy:getRMBProductInfo(p.product)
			if (productInfo.dest_type == "unlock_pet" and UserData:isPetUnlock(productInfo.dest)) or
				(productInfo.dest_type == "unlock_robot" and UserData:isRobotUnlock(productInfo.dest)) then
					productOnSale = false
			end
		end
		
		if productOnSale then
			local imgBg = Image.new(p.icon)
			self._productList:addItem(imgBg)
			if p.product == "unlock_all_pet" then
				self.unlockAllPetDescNode = imgBg:add(node.new())
				self.unlockAllPetDescNode:setScl(0.8)
				self.unlockAllPetDescNode:setLoc(170, 23)
				local imgMoney = self.unlockAllPetDescNode:add(Image.new(moneyPic))
				imgMoney:setLoc(-60, 0)
				self.unlockAllPetMoneyText = self.unlockAllPetDescNode:add(TextBox.new("x", "rw_sz", nil, "LM", 150, 80))
				self.unlockAllPetMoneyText:setLoc(30, 0)
				
				
				imgBg.onClick = function()
					local needMoney = UserData:calcUnlockAllPetMoney()
					if needMoney == 0 then
						return
					end
					if UserData:costMoneyTest(needMoney) then
						UserData:unlockAllPet()
						eventhub.fire("UI_EVENT", "REFRESH_SHOP_PANEL")
					else
						eventhub.fire("UI_EVENT", "OPEN_BUY_PANEL", "rmbtomoney")
					end
				end
			elseif p.product == "unlock_all_robot" then
				self.unlockAllRobotDescNode = imgBg:add(node.new())
				self.unlockAllRobotDescNode:setScl(0.8)
				self.unlockAllRobotDescNode:setLoc(170, 23)
				local imgMoney = self.unlockAllRobotDescNode:add(Image.new(moneyPic))
				imgMoney:setLoc(-60, 0)
				self.unlockAllRobotMoneyText = self.unlockAllRobotDescNode:add(TextBox.new("x", "rw_sz", nil, "LM", 150, 80))
				self.unlockAllRobotMoneyText:setLoc(30, 0)
			
				imgBg.onClick = function()
					local needMoney = UserData:calcUnlockAllRobotMoney()
					if needMoney == 0 then
						return
					end
					if UserData:costMoneyTest(needMoney) then
						UserData:unlockAllRobot()
						eventhub.fire("UI_EVENT", "REFRESH_SHOP_PANEL")
					else
						eventhub.fire("UI_EVENT", "OPEN_BUY_PANEL", "rmbtomoney")
					end
				end
			elseif type(p.product) == "number" then
				imgBg.onClick = function()
					Buy:RMBPay(p.product)
				end
			else
				assert(false, "wrong product"..p.product)
			end
		end
	end
	
	self:updatePanel()
end

function ShopPanel:open()
	self:initProductList()
	WindowOpenStyle:openWindowScl(self._bgRoot)
	WindowOpenStyle:openWindowAlpha(self._bgRoot)
	popupLayer:add(self._root)
end

function ShopPanel:close()
	popupLayer:remove(self._root)
end

function ShopPanel:updatePanel()
	if self.unlockAllPetDescNode then
		local needMoney = UserData:calcUnlockAllPetMoney()
		if needMoney > 0 then
			self.unlockAllPetDescNode:setVisible(true)
			self.unlockAllPetMoneyText:setString("x"..needMoney)
		else
			self.unlockAllPetDescNode:setVisible(false)
		end
	end
	
	if self.unlockAllRobotDescNode then
		local needMoney = UserData:calcUnlockAllRobotMoney()
		if needMoney > 0 then
			self.unlockAllRobotDescNode:setVisible(true)
			self.unlockAllRobotMoneyText:setString("x"..needMoney)
		else
			self.unlockAllRobotDescNode:setVisible(false)
		end
	end
end

return ShopPanel