
local url = require "url"
local node = require "node"
local resource = require "resource"

local FlashSprite = {}

function FlashSprite.playFlash(self, loop, autoDestroy, callback)
	if not self._anim then
		return
	end
	
	if loop == true then
		self._anim:setMode(MOAITimer.LOOP)
	else
		self._anim:setListener(MOAITimer.EVENT_STOP, function()
			if callback then
				callback(self)
			end
			if autoDestroy then
				self:destroy(self)
			end
		end)
	end
	
	return self._anim:start()
end

function FlashSprite.stopFlash(self)
	if self._anim then
		self._anim:stop()
	end
end

function FlashSprite.loadFlash(self, urlStr, play)
	self:stopFlash()
	
	local imageName, queryStr = string.split(urlStr, "?")
	local deckName, aniName = string.split(imageName, "#")
	local deck = resource.deck(deckName)
	if not deck or deck.type ~= "tweendeck" then
		return false
	end
	
	if not self:createAnim(deck, aniName) then
		return false
	end
	
	local loop = false
	local dur
	if queryStr then
		local q = url.parse_query(queryStr)
		if q.dur then
			dur = tonumber(q.dur)
		end
		if q.scl then
			local x, y = string.split(q.scl, ",")
			self:setScl(tonumber(x), tonumber(x or y))
		end
		if q.rot then
			local rot = tonumber(q.rot)
			self:setRot(rot)
		end
		if q.loc then
			local x, y = string.split(q.loc, ",")
			self:setLoc(tonumber(x), tonumber(y))
		end
		if q.pri then
			local pri = tonumber(q.pri)
			self:setPriority(pri)
		end
		if q.alpha then
			self:setColor(1, 1, 1, tonumber(q.alpha))
		end
		if q.loop and q.loop == "true" then
			loop = true
		end
	end	
	
	if play then
		self:playFlash(loop)
	end
	
	return true
end

function FlashSprite.createAnim(self, deck, aniName)
	local curves = deck._animCurves
	if aniName then
		curves = deck._animCurves[aniName]
	end
	
	if not curves then
		return false
	end

	self._anim = MOAIAnim.new()
	self._anim:reserveLinks(#curves * 6)
	
	local priority = 0
	for i, curve in ipairs(curves) do
	
		local animProp = node.new(MOAIProp2D.new())
		animProp:setDeck(deck)
		self:_preAdd(animProp)
		
		priority = i
		animProp:setPriorityOffset(priority)
		
		local c = ( i - 1 ) * 6
		
		self._anim:setLink ( c + 1, curve.id, animProp, MOAIProp2D.ATTR_INDEX )
		self._anim:setLink ( c + 2, curve.x, animProp, MOAITransform.ATTR_X_LOC )
		self._anim:setLink ( c + 3, curve.y, animProp, MOAITransform.ATTR_Y_LOC )
		self._anim:setLink ( c + 4, curve.r, animProp, MOAITransform.ATTR_Z_ROT )
		self._anim:setLink ( c + 5, curve.xs, animProp, MOAITransform.ATTR_X_SCL )
		self._anim:setLink ( c + 6, curve.ys, animProp, MOAITransform.ATTR_Y_SCL )
	end
	self:setScl(1, -1)
	
	self._lastNode:setPriorityOffset(priority + 1)
	
	return true
end

function FlashSprite.destroy(self)
	self:stopFlash()
	
	if self._anim then
		self._anim:clear()
		self._anim = nil
	end
	
	if self.onDestroy then
		self:onDestroy()
	end
	if self._preSpriteDestroy then
		self:_preSpriteDestroy()
	end
end

function FlashSprite.add(self, child)
	child:setScl(1, 1)
	return self._lastNode:add(child)
end

function FlashSprite.new(data, play)
	local o = node.new(MOAIProp2D.new())
	o._preSpriteDestroy = o.destroy
	o.destroy = FlashSprite.destroy
	o.loadFlash = FlashSprite.loadFlash
	o.playFlash = FlashSprite.playFlash
	o.stopFlash = FlashSprite.stopFlash
	o.createAnim = FlashSprite.createAnim
	o._preAdd = o.add
	o.add = FlashSprite.add
	
	o._sourceName = data
	o._lastNode = o:_preAdd(node.new())

	if type(data) == "string" then
		FlashSprite.loadFlash(o, data, play)
	end
	return o
end

return FlashSprite