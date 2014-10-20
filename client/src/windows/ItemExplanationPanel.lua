
local device = require "device"
local ui = require "ui"
local node = require "node"
local Image = require "gfx.Image"
local eventhub = require "eventhub"


local bgImage 			= "panel/item_explantion_bg.atlas.png#item_explantion_bg.png"
local tittleImage 		= "ui.atlas.png#item_explantion.png"
local iconBgImage 		= "ui.atlas.png#item_explantion_ico_bg.png"
local explanationBgImage= "ui.atlas.png#item_explantion_ico_bg2.png"
local okImage 			= "ui.atlas.png#item_explantion_quedin.png"
local closeImage1 		= "ui.atlas.png#close_1.png"
local closeImage2 		= "ui.atlas.png#close_2.png?scl=1.2"

local itemList =
{
	["outside"] = 
	{
		{
			["item"] = "ui.atlas.png#dj_1.png",
			["name"] = "ui.atlas.png#item_explantion_wz3.png",
			["explanation"] = "ui.atlas.png#shuoming_7.png",
		},
		{
			["item"] = "ui.atlas.png#dj_2.png",
			["name"] = "ui.atlas.png#item_explantion_wz2.png",
			["explanation"] = "ui.atlas.png#shuoming_8.png",
		},
		{
			["item"] = "ui.atlas.png#dj_3.png",
			["name"] = "ui.atlas.png#item_explantion_wz1.png",
			["explanation"] = "ui.atlas.png#shuoming_9.png",
		},
	},
	["inside"] = 
	{
		{
			["item"] = "ui.atlas.png#zhuanhuan_big.png",
			["name"] = "ui.atlas.png#item_explantion_wz4.png",
			["explanation"] = "ui.atlas.png#shuoming_10.png",
		},
		{
			["item"] = "ui.atlas.png#super_big.png",
			["name"] = "ui.atlas.png#item_explantion_wz5.png",
			["explanation"] = "ui.atlas.png#shuoming_11.png",
		},
		{
			["item"] = "ui.atlas.png#gjxiang_big.png",
			["name"] = "ui.atlas.png#item_explantion_wz6.png",
			["explanation"] = "ui.atlas.png#shuoming_12.png",
		},
	},
	["timing"] =
	{
		{
			["item"] = "ui.atlas.png#sj_1.png",
			["name"] = "ui.atlas.png#sj_wz_2.png",
			["explanation"] = "ui.atlas.png#sj_wz_3.png",
		},
		{
			["item"] = "ui.atlas.png#dj_2.png",
			["name"] = "ui.atlas.png#item_explantion_wz2.png",
			["explanation"] = "ui.atlas.png#shuoming_8.png",
		},
		{
			["item"] = "ui.atlas.png#dj_3.png",
			["name"] = "ui.atlas.png#item_explantion_wz1.png",
			["explanation"] = "ui.atlas.png#shuoming_9.png",
		},
	},
}

local ItemExplanationPanel = {}
function ItemExplanationPanel:init()	
	self._root = ui.PickBox.new(device.ui_width, device.ui_height)
	self._root:setLayoutSize(device.ui_width, device.ui_height)
	self._root:setPriorityOffset(500)
	
	local bg = self._root:add(Image.new(bgImage))
	local tittle = bg:add(Image.new(tittleImage))
	tittle:setLoc(0, 320)
	
	local closeBtn = bg:add(ui.Button.new(closeImage1, closeImage2))
	closeBtn:setLoc(225, 320)
	closeBtn.onClick = function()
		self:close()
	end
	
	local okBtn = bg:add(ui.Button.new(okImage, 1.2))
	okBtn:setLoc(0, -320)
	okBtn.onClick = function()
		self:close()
	end
	
	self._itemListRoot = bg:add(node.new())
	
	local dropListW, dropListH, dropListOffset = 480, 480, 160
	self._pages = {}
	for type, items in pairs (itemList) do
		local dropList = ui.DropList.new(dropListW, dropListH, dropListOffset, "vertical")
		
		for _, o in ipairs (items) do
			local frame = dropList:addItem(ui.PickBox.new(dropListW, dropListOffset))
			local itemBg = frame:add(Image.new(iconBgImage))
			itemBg:setLoc(-170, 8)
			local item = itemBg:add(Image.new(o.item))
			item:setLoc(0, -20)
			local name = itemBg:add(Image.new(o.name))
			name:setLoc(0, 35)
			
			local explanationBg = frame:add(Image.new(explanationBgImage))
			explanationBg:setLoc(70, 0)
			local bgW, bgH = explanationBg:getSize()
			
			local explanation = explanationBg:add(Image.new(o.explanation))
			local expW, expH = explanation:getSize()
			explanation:setLoc(-(bgW/2 - expW/2) + 5, (bgH/2 - expH/2) - 10)
		end
		
		self._pages[type] = dropList
	end
	
	eventhub.bind("UI_EVENT", "OPEN_ITEM_EXPLANATION", function(type) self:open(type) end)
end

function ItemExplanationPanel:open(type)
	self._itemListRoot:removeAll()

	self._itemListRoot:add(self._pages[type])
	
	popupLayer:add(self._root)
end

function ItemExplanationPanel:close()
	self._itemListRoot:removeAll()
	
	popupLayer:remove(self._root)
end

return ItemExplanationPanel
