
local ui = require "ui"
local Image = require "gfx.Image"
local device = require "device"
local eventhub = require "eventhub"
local TextBox = require "gfx.TextBox"
local eventhub = require "eventhub"
local node = require "node"
local UserData = require "UserData"
local Buy = require "settings.Buy"
local WindowOpenStyle = require "windows.WindowOpenStyle"
local Task = require "logic.Task"

local ActivityPanel = {}

local backGround = "panel/panel_1.atlas.png#panel_1.png"
local activityPic1 = "activitypanel.atlas.png#xc_1.png"
local activityPic2 = "activitypanel.atlas.png#xc_2.png"
local titlePic = "ui.atlas.png#sc_4.png"
local shopBtnPic = "ui.atlas.png#qwsc.png"
local closePic = "ui.atlas.png#close_1.png"

-- local charge30Title = "ui.atlas.png#hd_xc_2.png"
-- local charge30Pic = "panel/cz_30.atlas.png#cz_30.png"


function ActivityPanel:init()
	eventhub.bind("UI_EVENT", "OPEN_ACTIVITY_PANEL", function()
		self._step = 1
		self:open()
	end)
	
	self._root = ui.PickBox.new(device.ui_width, device.ui_height)
	self._root:setPriorityOffset(100)
	self._bgRoot = self._root:add(Image.new(backGround))
	self._root:setLayoutSize(Image.getSize(self._bgRoot))
	
	local closeButton = self._bgRoot:add(ui.Button.new(closePic))
	closeButton:setAnchor("RT", -50, -90)
	closeButton.onClick = function()
		self:close()
	end
	
	local shopBtn = self._bgRoot:add(ui.Button.new(shopBtnPic, 1.2))
	shopBtn:setAnchor("MB", 0, 80)
	shopBtn:setPriorityOffset(10)
	shopBtn.onClick = function()
		eventhub.fire("UI_EVENT", "OPEN_SHOP_PANEL")
		self:close()
	end
	
	self._nodeOneYuan = self._bgRoot:add(node.new())
	
	local title = self._nodeOneYuan:add(Image.new(titlePic))
	title:setAnchor("MT", 0, -90)
	
	local pic1 = self._nodeOneYuan:add(ui.wrap(Image.new(activityPic1)))
	pic1:setLoc(0, 140)
	pic1.handleTouch = ui.handleTouch
	pic1.onClick = function()
		if not Task:isFinish(2003) then
			Buy:RMBPay(9)
		else
			eventhub.fire("UI_EVENT", "OPEN_BUY_PANEL", "rmbtomoney")
		end
	end
	
	local pic2 = self._nodeOneYuan:add(ui.wrap(Image.new(activityPic2)))
	pic2:setLoc(0, -140)
	pic2.handleTouch = ui.handleTouch
	pic2.onClick = function()
		if not Task:isFinish(2004) then
			Buy:RMBPay(10)
		else
			eventhub.fire("UI_EVENT", "OPEN_BUY_PANEL", "rmbtomoney")
		end
	end
	
	-- self._nodeThirtyYuan = self._bgRoot:add(node.new())
	
	-- local titleThirty = self._nodeThirtyYuan:add(Image.new(charge30Title))
	-- titleThirty:setAnchor("MT", 0, -90)
	
	-- local pic = self._nodeThirtyYuan:add(ui.new(Image.new(charge30Pic)))
	-- pic:setLoc(0, -5)
	-- pic.handleTouch = ui.handleTouch
	-- pic.onClick = function()
		-- if not Task:isFinish(2002) then
			-- Buy:RMBPay(4)
		-- else
			-- eventhub.fire("UI_EVENT", "OPEN_BUY_PANEL", "rmbtomoney")
		-- end
	-- end
end

function ActivityPanel:preOpen()
	-- if self._step == 1 then
		self._bgRoot:add(self._nodeOneYuan)
		-- self._nodeThirtyYuan:remove()
	-- elseif self._step == 2 then
		-- self._bgRoot:add(self._nodeThirtyYuan)
		-- self._nodeOneYuan:remove()
	-- end
end

function ActivityPanel:open()
	self:preOpen()
	WindowOpenStyle:openWindowScl(self._bgRoot)
	WindowOpenStyle:openWindowAlpha(self._bgRoot)
	popupLayer:add(self._root)
end

function ActivityPanel:close()
	popupLayer:remove(self._root)
	-- if self._step == 1 then
		-- self._step = 2
		-- self:open()
	-- end
end

return ActivityPanel