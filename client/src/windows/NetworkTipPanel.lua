
local ui = require "ui"
local node = require "node"
local Image = require "gfx.Image"
local timer = require "timer"
local device = require "device"
local WindowOpenStyle = require "windows.WindowOpenStyle"

local tipPics =
{
	["device"] = "ui.atlas.png#wl_ts.png",
	["server"] = "panel/wh_ts_1.atlas.png#wh_ts_1.png",
}

local NetworkTipPanel = {}
function NetworkTipPanel:init()	
	self._root = node.new()
	self._root:setLayoutSize(device.ui_width, device.ui_height)
	self._root:setPriorityOffset(3000)
	
	self._tips = {}
	for index, pic in pairs (tipPics) do
		self._tips[index] = Image.new(pic)
	end
end

function NetworkTipPanel:open(index)
	if self._closeTimer then
		self._closeTimer:stop()
	end
	WindowOpenStyle:openWindowScl(self._tips[index])
	self._root:add(self._tips[index])
	popupLayer:add(self._root)
	
	self._closeTimer = timer.new(2, function()
		self:close()
	end)
end

function NetworkTipPanel:close()
	if self._closeTimer then
		self._closeTimer:stop()
	end
	self._root:removeAll()
	popupLayer:remove(self._root)
end

return NetworkTipPanel
