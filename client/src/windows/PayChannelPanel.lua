
local ui = require "ui"
local node = require "node"
local Image = require "gfx.Image"
local timer = require "timer"
local device = require "device"
local eventhub = require "eventhub"
local Player = require "logic.Player"
local PlatformSDK = require "logic.PlatformSDK"
local Buy = require "settings.Buy"
local ActLog = require "ActLog"

local backGround = "panel/zf_di.atlas.png#zf_di.png"
local closePic = "ui.atlas.png#zf_3.png"

local PayChannelPanel = {}
local channelList = 
{
	{
		channel = "qihoo",
		pic = "ui.atlas.png#zf_1.png",
		offX = 0,
		offY = 50,
		cbClick = function(productId)
			PayChannelPanel:qihooPay(productId)
			PayChannelPanel:close()
			ActLog:clickQihooPayChannel("qihoo")
		end,
	},
	{
		channel = "provider",
		pic = "ui.atlas.png#zf_2.png",
		offX = 0,
		offY = -70,
		cbClick = function(productId)
			PayChannelPanel:providerPay(productId)
			PayChannelPanel:close()
			ActLog:clickQihooPayChannel("provider")
		end,
	},
}

function PayChannelPanel:init()
	self._root = ui.PickBox.new(device.ui_width, device.ui_height)
	self._root:setLayoutSize(device.ui_width, device.ui_height)
	self._root:setPriorityOffset(2000)
	
	self._bgRoot = self._root:add(Image.new(backGround))
	
	local closeButton = self._bgRoot:add(ui.Button.new(closePic, 1.2))
	closeButton:setLoc(0, -200)
	closeButton.onClick = function()
		self:close()
	end
	
	self._buttonList = {}
	for _, tb in ipairs (channelList) do
		local button = self._bgRoot:add(ui.Button.new(tb.pic, 1.2))
		button:setLoc(tb.offX, tb.offY)
		button.onClick = tb.cbClick
		self._buttonList[tb.channel] = button
	end
	
	-- 绑定支付事件
	eventhub.bind("SYSTEM_EVENT", "OPEN_PAY_CHANNEL_PANEL", function(productId) self:open(productId) end)
end

function PayChannelPanel:open(productId)
	self._productId = productId
	popupLayer:add(self._root)
	
	if self._buttonList["provider"] then
		self._buttonList["provider"]:setVisible(false)
		
		local tb = Buy:getRMBProductInfo(productId)
		local provider = PlatformSDK:getPhoneProvider()
		if tb.cmcc_paycode and provider == "CMCC" then
			self._buttonList["provider"]:setVisible(true)
		end
	end
	
end

function PayChannelPanel:close()
	popupLayer:remove(self._root)
end

function PayChannelPanel:qihooPay()
	Player:qihooPay(self._productId)
end

function PayChannelPanel:providerPay()
	local provider = PlatformSDK:getPhoneProvider()
	if provider ~= "CMCC" then
		return
	end
	
	Player:cmccPay(self._productId)
end

return PayChannelPanel
