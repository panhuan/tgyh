
local ui = require "ui"
local Image = require "gfx.Image"
local eventhub = require "eventhub"
local device = require "device"
local ResDef = require "settings.ResDef"
local WindowManager = require "WindowManager"

local StartPanel = {}

function StartPanel:init()
	self._root = Image.new(ResDef.bg)
	
	WindowManager:initWindow("StartPanel", self)
end

function StartPanel:open()

end

function StartPanel:close()

end

return StartPanel