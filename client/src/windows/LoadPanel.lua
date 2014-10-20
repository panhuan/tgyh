
local ui = require "ui"
local Image = require "gfx.Image"
local device = require "device"
local resource = require "resource"
local eventhub = require "eventhub"
local FlashSprite = require "gfx.FlashSprite"
local WindowOpenStyle = require "windows.WindowOpenStyle"

local LoadPanel = {}


local backGround = "star_panel.jpg"
local logoPic = "panel/logo.atlas.png#logo.png"
local flash = "loading.fla.png"

local w = 580

function LoadPanel:init()
	eventhub.bind("UI_EVENT", "OPEN_LOAD_PANEL", function()
		self:open()
	end)
	eventhub.bind("UI_EVENT", "CLOSE_LOAD_PANEL", function()
		self:close()
	end)
	
	self._root = Image.new(backGround)
	self._root:setPriority(1)
	self._root:setLayoutSize(device.ui_width, device.ui_height)
	
	self._logo = self._root:add(Image.new(logoPic))
	self._logo:setAnchor("MT", 0, -150)
	
	self._flash = self._root:add(FlashSprite.new(flash))
	self._flash:setAnchor("MB", -w / 2, 200)
end

function LoadPanel:updateProgress(progress)
	if progress >= 100 then
		self:resLoadComplete()
	end
end

function LoadPanel:resLoadStart()
	resource.onAsyncLoad = function(progress)
		self:updateProgress(progress)
	end
end

function LoadPanel:resLoadComplete()
	resource.onAsyncLoad = nil
	eventhub.fire("UI_EVENT", "RESOURCE_LOAD_COMPLETE")
end

function LoadPanel:open()
	uiLayer:add(self._root)
	self._flash:playFlash(true)
end

function LoadPanel:close()
	self._flash:stopFlash()
	self._flash:destroy()
	WindowOpenStyle:closeWindowAlpha(self._root)
end

return LoadPanel