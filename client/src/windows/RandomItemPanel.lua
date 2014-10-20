
local ui = require "ui"
local node = require "node"
local Image = require "gfx.Image"
local timer = require "timer"
local device = require "device"
local eventhub = require "eventhub"
local SoundManager = require "SoundManager"
local actionset = require "actionset"
local Particle = require "gfx.Particle"

local whiteMaskImage	= "white_mask.jpg?scl="..device.ui_width..","..device.ui_height
local bgImage			= "gameplay.atlas.png#sj_di_1.png"
local maskImage			= "gameplay.atlas.png#sj_di_2.png"
local explosionParticle = "upgrade.pex"
local flyParticle 		= "fly4.pex"

local RandomItemPanel = {}
function RandomItemPanel:init()	
	self._root = ui.PickBox.new(device.ui_width, device.ui_height)
	self._root:setLayoutSize(device.ui_width, device.ui_height)
	self._root:setPriority(1)
	
	local whiteBg = self._root:add(Image.new(whiteMaskImage))
	whiteBg:setPriority(1)
	whiteBg:setColor(0,0,0,0.4)

	self._bg = self._root:add(Image.new(bgImage))
	self._bg:setPriorityOffset(20)
	
	self._flyRoot = self._root:add(node.new())
	self._flyRoot:setPriorityOffset(30)
	self._randomImage = self._flyRoot:add(Image.new())
	
	self._mask = self._root:add(Image.new(maskImage))
	self._mask:setPriorityOffset(40)
	self._mask:setLoc(0, -42)
end

function RandomItemPanel:open(tbRandomItemEffect)
	if self._randomItemTimer then
		self._randomItemTimer:stop()
	end
	
	SoundManager.randomItemSound:play()
	
	self:showPanel()
	
	self._randomImage:setVisible(true)
	self._randomImage:setPriorityOffset(5)
	
	self._flyRoot:setLoc(0, -40)
			
	self._resetRandomCount = 10
	self._tbRandomItems = tbRandomItemEffect
	self._totalRandomItemCount = #tbRandomItemEffect
	self._randomItemTimer = timer.new(0.1, function() self:doRandom() end)
	
	self._AS = actionset.new()
	
	popupLayer:add(self._root)
end

function RandomItemPanel:close()
	if self._randomItemTimer then
		self._randomItemTimer:stop()
	end
	
	self._AS:removeAll()
	
	popupLayer:remove(self._root)
end

function RandomItemPanel:doRandom()
	local num = math.random(1, self._totalRandomItemCount)
	local item = self._tbRandomItems[num]
	self._randomImage:load(item[2])
	
	self._resetRandomCount = self._resetRandomCount - 1
	
	if self._resetRandomCount > 0 then
		return
	end
	
	if self._randomItemTimer then
		self._randomItemTimer:stop()
	end
	
	SoundManager.randomItemFinishSound:play()
	eventhub.fire("SYSTEM_EVENT", "RANDOM_ITEM_FINISH", num)
end

function RandomItemPanel:itemFly(destX, destY)
	local fly = self._flyRoot:add(self:newFlyEffect())
	self._randomImage:setPriorityOffset(10)
	local a = self._randomImage:seekScl(2, 2, 0.1)
	a:setListener(MOAIAction.EVENT_STOP, function()
		self:hidePanel()
		self._randomImage:seekScl(1, 1, 1)
		a = self._flyRoot:seekLoc(destX, destY, 1)
		a:setListener(MOAIAction.EVENT_STOP, function()
			fly:destroy()
			self._randomImage:setVisible(false)
			
			local explosion = self._root:add(self:newExplosionEffect())
			explosion:setLoc(destX, destY)
		end)
	end)
	
	return 1.3
end

function RandomItemPanel:newExplosionEffect()
	local effect = Particle.new(explosionParticle, self._AS)
	effect:setPriorityOffset(20)
	effect:begin()
	effect:setScl(1.65)
	return effect
end

function RandomItemPanel:hidePanel()
	self._bg:setVisible(false)
	self._mask:setVisible(false)
end

function RandomItemPanel:showPanel()
	self._bg:setVisible(true)
	self._mask:setVisible(true)
end

function RandomItemPanel:newFlyEffect()
	local effect = Particle.new(flyParticle, self._AS)
	effect:begin()
	return effect
end

return RandomItemPanel
