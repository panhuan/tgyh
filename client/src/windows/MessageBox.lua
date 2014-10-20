
local ui = require "ui"
local Image = require "gfx.Image"
local device = require "device"
local eventhub = require "eventhub"
local TextBox = require "gfx.TextBox"
local WindowOpenStyle = require "windows.WindowOpenStyle"


local MessageBox = {}


local backGround = "panel/system_bg.atlas.png#system_bg.png"
local closePic1 = "ui.atlas.png#close_1.png"
local closePic2 = "ui.atlas.png#close_2.png?scl=1.2"
local titlePic = "ui.atlas.png#ts_title.png?loc=0, 120"
local btnPic = "ui.atlas.png#ts_qd_liang.png"

local tbMsgPic = 
{
	"ui.atlas.png#ts_zi_1.png",
	"ui.atlas.png#ts_zi_2.png",
	"ui.atlas.png#ts_zi_3.png",
	"ui.atlas.png#ts_zi_4.png",
	"ui.atlas.png#ts_zi_5.png",
	"ui.atlas.png#ts_zi_6.png",
	"ui.atlas.png#ts_zi_7.png",
	"ui.atlas.png#ts_zi_8.png",
	"ui.atlas.png#ts_zi_9.png",
	"ui.atlas.png#ts_zi_10.png",
	"ui.atlas.png#ts_zi_11.png",
}


function MessageBox:init()
	eventhub.bind("UI_EVENT", "OPEN_MESSAGEBOX", function(tbParam)
		self:open(tbParam)
	end)
	
	self._root = ui.PickBox.new(device.ui_width, device.ui_height)
	self._root:setPriorityOffset(4000)
	self._bgRoot = self._root:add(Image.new(backGround))
	self._root:setLayoutSize(Image.getSize(self._bgRoot))
	
	self._closeBtn = self._bgRoot:add(ui.Button.new(closePic1, closePic2))
	self._closeBtn:setAnchor("RT", -50, -120)
	self._closeBtn.onClick = function()
		self:close()
	end
	
	self._useBtn = self._bgRoot:add(ui.Button.new(btnPic, btnPic.."?scl=1.2"))
	self._useBtn:setAnchor("MB", 0, 90)
	self._useBtn.onClick = function()
		self:close()
	end
	
	self._title = self._bgRoot:add(Image.new(titlePic))
	
	self._Text = self._bgRoot:add(Image.new())
end

function MessageBox:create(tbParam)
	if not tbParam then
		self:close()
		return
	end
	if tbParam.strIndex then
		self._Text:load(tbMsgPic[tbParam.strIndex])
	end
	if tbParam.fun then
		self._useBtn.onClick = function()
			self:close()
			pcall(tbParam.fun)
		end
	end
	if tbParam.closefun then
		self._closeBtn.onClick = function()
			self:close()
			tbParam.closefun()
		end
	end
end

function MessageBox:destroy()
	self._useBtn.onClick = function()
		self:close()
	end
	self._closeBtn.onClick = function()
		self:close()
	end
end

function MessageBox:open(tbParam)
	WindowOpenStyle:openWindowScl(self._bgRoot)
	WindowOpenStyle:openWindowAlpha(self._bgRoot)
	popupLayer:add(self._root)
	self:create(tbParam)
end

function MessageBox:close()
	popupLayer:remove(self._root)
	self:destroy()
end

return MessageBox