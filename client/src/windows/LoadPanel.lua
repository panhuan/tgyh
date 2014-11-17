
local ui = require "ui"
local Image = require "gfx.Image"
local device = require "device"
local resource = require "resource"
local eventhub = require "eventhub"
local ResDef = require "settings.ResDef"
local WindowManager = require "WindowManager"

local LoadPanel = {}


function LoadPanel:init()
	self._root = Image.new(ResDef.bg)
	WindowManager:initWindow("LoadPanel", self)
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
	eventhub.fire("SYSTEM_EVENT", "RESOURCE_LOAD_COMPLETE")
end

function LoadPanel:open()
end

function LoadPanel:close()
end

return LoadPanel