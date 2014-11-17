local Image = require "gfx.Image"
local Sprite = require "gfx.Sprite"
local device = require "device"
local math2d = require "math2d"
local interpolate = require "interpolate"


local bombRoundEffect = "gameplay.atlas.png#bomb_round?scl=0.5"

local Enemy = class "Enemy" define {}

function Enemy:create()
	local pic = nil
	if type(self.draw.pic) == "string" then
		pic = self.draw.pic
	elseif type(self.draw.pic) == "table" then
		pic = self.draw.pic[math.random(1, #self.draw.pic)]
	end
	self._pic = self._root:add(Image.new(pic))
	self._alive = true
end

function Enemy:destroy()
	local explosion = self._root:add(Sprite.new(bombRoundEffect))
	explosion:setBlendMode(MOAIProp.BLEND_ADD)
	explosion.onDestroyed = function()
		self._root:destroy()
		self._alive = false
	end
end

function Enemy:setBornPos(pos)
	local picW, picH = self._pic:getSize()
	local anchor, x, y = pos.anchor, pos.x, pos.y
	if type(x) == "table" then
		x = x[math.random(1, #x)]
	end
	if type(y) == "table" then
		y = y[math.random(1, #y)]
	end
	if anchor == "MB" then
		y = y - picH / 2
	elseif anchor == "MT" then
		y = y + picH / 2
	elseif anchor == "LT" then
		x = x - picW / 2
	elseif anchor == "RT" then
		x = x + picW / 2
	end
	self._root:setAnchor(anchor, x, y)
end

function Enemy:beginAttack(hero, as, param)
	local x, y = self._root:getLoc()
	local w, h = self._pic:getLoc()
	local heroX, heroY = hero._root:getLoc()
	local heroW, heroH = hero._pic:getSize()
	heroY = heroY - heroH - h / 2
	local timeLen = 2 / self.speed
	if self.trajectory == "line" then
		local offsetY = heroY - y
		local moveas = self._root:moveLoc(0, offsetY, timeLen, MOAIEaseType.LINEAR)
		moveas:attach(as)
		moveas:setListener(MOAIAction.EVENT_STOP, function()
			self._root:destroy()
			self._alive = false
		end)
	elseif self.trajectory == "curve" then
		local delay = 0
		local tbPosX = {}
		if param and param.randX then
			tbPosX = param.randX
			delay = param.delay
			timeLen = timeLen * 0.4
		else
			table.insert(tbPosX, x)
			local times = math.random(2, 3)
			for i = 1, times do
				local randX = math.random(-device.ui_width / 2 + 100, device.ui_width / 2 - 100)
				table.insert(tbPosX, randX)
			end
		end
		local cy = interpolate.makeCurve(0, y, MOAIEaseType.LINEAR, timeLen, heroY)
		local c = interpolate.makeCurve(0, 0, MOAIEaseType.LINEAR, timeLen, timeLen)
		local fn = interpolate.newton2d(tbPosX, tbPosX, c)
		
		local oldX, oldY = 0, 0
		local action = nil
		action = as:run(function(dt, length)
			local now = length - delay
			if now > 0 then
				if now >= c:getLength() then
					action:stop()
					action = nil
					self._root:destroy()
					self._alive = false
				else
					local curX, curY = fn(now)
					curY = cy:getValueAtTime(now)
					self._root:setLoc(curX, curY)
					local x = curX - oldX
					local y = curY - oldY
					local angle = math2d.angle(x, y)
					self._root:setRot(angle + 90)
					oldX = curX
					oldY = curY
				end
			end
		end)
	end
	if self.attackType == "normal" then
	
	elseif self.attackType == "bullet" then
	
	end	
end

return Enemy