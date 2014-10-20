
local ui = require "ui"
local node = require "node"
local Image = require "gfx.Image"
local timer = require "timer"
local device = require "device"

local typeList =
{
	["nomove"] = 
	{
		"gameplay.atlas.png#lx_ts_1.png",
		"gameplay.atlas.png#lx_ts_2.png"
	},
	["steptip"] = 
	{
		"gameplay.atlas.png#bs_ts_1.png",
		"gameplay.atlas.png#bs_ts_2.png"
	},
}

local TipPanel = {}
function TipPanel:init()	
	self._root = node.new()
	self._root:setLayoutSize(device.ui_width, device.ui_height)
	self._root:setPriority(1)
	
	self._tips = {}
	for type, images in pairs (typeList) do
		local tipBg = Image.new(typeList[type][1])
		
		local tipImage = tipBg:add(Image.new(typeList[type][2]))
		tipImage:setLoc(-55, -15)
		
		self._tips[type] = tipBg
	end
end

function TipPanel:open(type)
	if self._closeTimer then
		self._closeTimer:stop()
	end
	
	self:showTip(type)
	uiLayer:add(self._root)
end

function TipPanel:close()
	if self._closeTimer then
		self._closeTimer:stop()
	end
	
	self._root:removeAll()
	uiLayer:remove(self._root)
end

function TipPanel:showTip(type)
	self._root:removeAll()
	
	local tip = self._tips[type]
	self._root:add(tip)
	
	local bgX, bgY = tip:getSize()
	tip:setAnchor("RM", -bgX/2, 0)

	self._closeTimer = timer.new(2, function()
		self:close()
	end)
end

return TipPanel
