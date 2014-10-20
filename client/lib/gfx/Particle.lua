
local ParticleSystem = require "gfx.ParticleSystem"
local gfxutil = require "gfxutil"

local Particle = {}

function Particle.new(path, aset)
	local self = ParticleSystem.new(path)
	if self._duration == 0 then
		self._duration = 1e-5
	end
	self._duration = self._duration or -1
	self._aset = aset
	self.begin = Particle.begin
	self.cancel = Particle.cancel
	self.startAction = Particle.startAction
	self.update = Particle.update
	self.destroy = Particle.destroy
	self._preParticleRemoveSelf = self._removeSelf
	self._removeSelf = Particle._removeSelf
	self._addSelf = Particle._addSelf
	return self
end

function Particle._addSelf(self)
	if self._action then
		self._action:start(self._aset)
	end
end

function Particle:_removeSelf()
	if self._action then
		self._action:stop()
	end
	self:_preParticleRemoveSelf()
end

function Particle:startAction()
	local aset = self._aset
	if aset then
		aset:attach(self)
		for k, v in pairs(self.emitters) do
			aset:attach(v)
		end
	else
		self:startSystem()
	end
	if self._duration > 0 then
		self._action = aset:delaycall(self._duration, function()
			self:stopEmitters()
			self._action = aset:delaycall(self._lifespan, function()
				self:destroy()
			end)
		end)
	end
end

function Particle:begin(onDestroy)
	self.onDestroy = onDestroy
	if self._action then
		self._action:stop()
		self._action = nil
	end
	self:startAction()
end

function Particle:cancel()
	if self._action then
		self._action:stop()
		self._action = nil
	end
	self:stopSystem()
end

function Particle:update()
end

function Particle:destroy()
	if self.onDestroy then
		self.onDestroy()
	end
	self:cancel()
	self:remove()
end

function Particle:noop()
end

return Particle