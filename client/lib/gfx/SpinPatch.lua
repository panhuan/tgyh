
local Patch = require "gfx.Patch"
local gfxutil = require "gfxutil"
local interpolate = require "interpolate"
local resource = require "resource"

local SpinPatch = {}

function SpinPatch.new(image, color)
	local self = Patch.new(image, color)
	self.setSpin = SpinPatch.setSpin
	self.seekSpin = SpinPatch.seekSpin
	self.setColor = SpinPatch.setColor
	self.stopSpin = SpinPatch.stopSpin
	self._preSpinPatchRemoveSelf = self._removeSelf
	self._removeSelf = SpinPatch._removeSelf
	self:setSpin(0)
	return self
end

function SpinPatch:_removeSelf()
	self:stopSpin()
	self:_preSpinPatchRemoveSelf()
end

function SpinPatch:setColor(...)
	self._color = {...}
	self:setSpin(self._spinVal)
end

function SpinPatch:setSpin(val)
	val = math.rad(val)
	self._spinVal = val
	local w = self._width
	local h = self._height
	local vbo = self.vbo
	vbo:reserveVerts(4)
	vbo:reset()
	local cosv = math.cos(val)
	local sinv = math.sin(val)
	local x = -w / 2
	local y = -h / 2
	vbo:writeFloat(x * cosv - y * sinv, y * cosv + x * sinv)
	vbo:writeFloat(0, 1)
	vbo:writeColor32(unpack(self._color))
	local x = -w / 2
	local y = h / 2
	vbo:writeFloat(x * cosv - y * sinv, y * cosv + x * sinv)
	vbo:writeFloat(0, 0)
	vbo:writeColor32(unpack(self._color))
	local x = w / 2
	local y = -h / 2
	vbo:writeFloat(x * cosv - y * sinv, y * cosv + x * sinv)
	vbo:writeFloat(1, 1)
	vbo:writeColor32(unpack(self._color))
	local x = w / 2
	local y = h / 2
	vbo:writeFloat(x * cosv - y * sinv, y * cosv + x * sinv)
	vbo:writeFloat(1, 0)
	vbo:writeColor32(unpack(self._color))
	vbo:bless()
	self:forceUpdate()
end

function SpinPatch:seekSpin(startVal, endVal, length, looping)
	local runtime = 0
	local val
	self._action = gfxutil.AS:run(function(dt)
		runtime = runtime + dt
		if runtime > length then
			if looping then
				runtime = runtime - length
			else
				action:stop()
				return
			end
		end
		val = interpolate.lerp(startVal, endVal, runtime / length)
		self:setSpin(val)
	end)
	return self._action
end

function SpinPatch:stopSpin()
	if self._action then
		self._action:stop()
		self._action = nil
	end
end
return SpinPatch