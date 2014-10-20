
local url = require "url"
local node = require "node"
local color = require "color"
local resource = require "resource"

local Sprite = {}

local function dummy_getSize(self)
	return self._canary:getSize()
end

local function dummy_setImage(self, name)
	self._canary:setImage(name)
end

function Sprite.setColor(self, r, g, b, a)
	if type(r) == "string" then
		r, g, b, a = color.parse(r)
	end
	self:_preSpriteSetColor(r, g, b, a)
end

function Sprite.setSize(self, w, h)
	self._width = w
	self._height = h
end

function Sprite.getSize(self)
	if self._width and self._height then
		return self._width, self._height
	end

	if not self._deck or not self._deck.getSize then
		return nil
	end
	return self._deck:getSize(self.deckLayer)
end

function Sprite.loadImage(self, urlStr)
	self:stopAnim()
	
	if self._canary then
		self._canary:destroy()
	end
	if urlStr[1] == "$" then
		self:setDeck(nil)
		self.getSize = dummy_getSize
		self.setImage = dummy_setImage
		self._canary = self:add(Sprite.new(urlStr:sub(2)))
		return self
	end
	self.setSize = Sprite.setSize
	self.getSize = Sprite.getSize
	self.setImage = Sprite.setImage
	
	local imageName, queryStr = string.split(urlStr, "?")
	local deckName, layerName = string.split(imageName, "#")
	local deck = resource.deck(deckName)
	self:setDeck(deck)
	if layerName then
		self:setIndex(deck:indexOf(layerName))
		self.deckLayer = layerName
		self.deckIndex = deck:indexOf(layerName)
	end
	if queryStr then
		local q = url.parse_query(queryStr)
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
		if q.size then
			local w, h = string.split(q.size, ",")
			self:setSize(tonumber(w), tonumber(h))
		end
	end
end

function Sprite.loadAnim(self, urlStr)
	self:stopAnim()
	
	if self._canary then
		self._canary:destroy()
	end
	if urlStr[1] == "$" then
		self:setDeck(nil)
		self.getSize = dummy_getSize
		self.setImage = dummy_setImage
		self._canary = self:add(Sprite.new(urlStr:sub(2)))
		return self
	end
	self.setSize = Sprite.setSize
	self.getSize = Sprite.getSize
	self.setImage = Sprite.setImage
	
	local animName, queryStr = string.split(urlStr, "?")
	local deckName, layerName = string.split(animName, "#")
	local deck = resource.deck(deckName)
	self:setDeck(deck, deck.type == "tweendeck")
	
	if layerName then
		self:setIndex(deck:indexOf(layerName))
		self.deckLayer = layerName
		self.deckIndex = deck:indexOf(layerName)
	end
	
	local loop = false
	local destroy = true
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
		if q.loop == "true" then
			loop = true
		else
			loop = tonumber(q.loop)
		end
		if q.destroy == "false" then
			destroy = false
		end
		if q.size then
			local w, h = string.split(q.size, ",")
			self:setSize(tonumber(w), tonumber(h))
		end
	end
	
	if deck.type == "tweendeck" then
		self:playFlash(loop)
	else
		if layerName then
			self:playAnim(layerName, loop, destroy)
		end
	end
end

function Sprite.setImage(self, name)
	self:stopAnim()
	
	local index = self._deck:indexOf(name)
	self:setIndex(index)
end

function Sprite.setPriority(self, value, noRecursion)
	self:_preSpriteSetPriority(value, noRecursion)
	if self._canary then
		self._canary:setPriority(value, noRecursion)
	end
end

function Sprite.destroy(self)
	self:stopAnim()
	
	if self.onDestroy then
		self:onDestroy()
	end
	
	if self._preSpriteDestroy then
		self._preSpriteDestroy(self)
	end
end

function Sprite.stopAnim(self)
	if self._anim then
		self._anim:stop()
		self._anim = nil
	end
	if self._animProp then
		self:remove(self._animProp)
		self._animProp:destroy()
		self._animProp = nil
	end
end

function Sprite.playFlash(self, looping, autoDestroy, callback)
	self:stopAnim()
	
	local anim = MOAIAnim.new()
	anim:reserveLinks(#(self._deck._animCurves) * 6)
	
	local tbNode = {}
	local parent = self
	for key, var in ipairs(self._deck._animCurves) do
		tbNode[key] = parent:add(node.new())
		parent = tbNode[key]
	end
	
	for i, curves in ipairs(self._deck._animCurves) do
	
		local animProp = node.new(MOAIProp2D.new())
		animProp:setDeck(self._deck)
		tbNode[i]:add(animProp)
		
		local c = ( i - 1 ) * 6
		
		anim:setLink ( c + 1, curves.id, animProp, MOAIProp2D.ATTR_INDEX )
		anim:setLink ( c + 2, curves.x, animProp, MOAITransform.ATTR_X_LOC )
		anim:setLink ( c + 3, curves.y, animProp, MOAITransform.ATTR_Y_LOC )
		anim:setLink ( c + 4, curves.r, animProp, MOAITransform.ATTR_Z_ROT )
		anim:setLink ( c + 5, curves.xs, animProp, MOAITransform.ATTR_X_SCL )
		anim:setLink ( c + 6, curves.ys, animProp, MOAITransform.ATTR_Y_SCL )
	end
	
	if looping == true then
		anim:setMode(MOAITimer.LOOP)
	else
		anim:setListener(MOAITimer.EVENT_STOP, function()
			if callback then
				callback(self)
			end
			if autoDestroy then
				Sprite.destroy(self)
			end
		end)
	end
	self:setScl(1, -1)
	self._anim = anim
	return anim:start()
end

function Sprite.playAnim(self, animName, looping, autoDestroy, callback)
	self:stopAnim()
	
	if not animName or not self._deck or not self._deck._animCurves then
		return nil
	end
	
	local curve = self._deck._animCurves[animName]
	if not curve then
		return nil
	end
	local anim = MOAIAnim.new()
	if self._deck.type == "tweendeck" then
		do
			local consts = self._deck._animConsts[animName]
			local curLink = 1
			self._animProp = node.new(MOAIProp2D.new())
			self._animProp:setDeck(self._deck)
			self:add(self._animProp)
			anim:reserveLinks(self._deck._numCurves[animName])
			for animType, entry in pairs(curve) do
				anim:setLink(curLink, entry, self._animProp, animType)
				if animType == MOAIColor.ATTR_A_COL then
					anim:setLink(curLink + 1, entry, self._animProp, MOAIColor.ATTR_R_COL)
					anim:setLink(curLink + 2, entry, self._animProp, MOAIColor.ATTR_G_COL)
					anim:setLink(curLink + 3, entry, self._animProp, MOAIColor.ATTR_B_COL)
					curLink = curLink + 3
				end
				curLink = curLink + 1
			end
			for animType, entry in pairs(consts) do
				if animType == "id" then
					self._animProp:setIndex(entry)
				elseif animType == "x" then
					do
						local x, y = self:getLoc()
						self._animProp:setLoc(entry, y)
					end
				elseif animType == "y" then
					do
						local x = self:getLoc()
						self._animProp:setLoc(x, entry)
					end
				elseif animType == "r" then
					self._animProp:setRot(entry)
				elseif animType == "xs" then
					do
						local x, y = self:getScl()
						self._animProp:setScl(entry, y)
					end
				elseif animType == "ys" then
					do
						local x = self:getScl()
						self._animProp:setScl(x, entry)
					end
				elseif animType == "a" then
					self._animProp:setColor(entry, entry, entry, entry)
				end
			end
		end
	else
		anim:reserveLinks(1)
		anim:setLink(1, curve, self, MOAIProp2D.ATTR_INDEX)
	end
	if looping then
		anim:setMode(MOAITimer.LOOP)
		if type(looping) == "number" then
			anim:setListener(MOAITimer.EVENT_TIMER_LOOP, function()
				anim:setSpan(looping, anim:getLength())
				anim:setListener(MOAITimer.EVENT_TIMER_LOOP, nil)
			end)
		end
	else
		anim:setListener(MOAITimer.EVENT_STOP, function()
			if callback then
				callback(self)
			end
			
			if autoDestroy then
				Sprite.destroy(self)
			end
		end)
	end
	self._anim = anim
	return anim:start()
end

function Sprite.setDeck(self, deck, isFlash)
	self._deck = deck
	if not isFlash then
		self._preSpriteSetDeck(self, deck)
	end
end

function Sprite.throttle(self, num)
	self._anim:throttle(num)
end

local function sequencedeck_getSize(self)
	return unpack(self._size)
end

function Sprite.loadSequence(self, textureName, numFrames, animName, fps)
	self:stopAnim()
	
	local tex = resource.texture(textureName)
	local w, h = tex:getSize()
	local deck = MOAIGfxQuadDeck2D.new()
	deck:reserve(numFrames)
	deck._map = {}
	deck._sizes = {}
	local hw = w / numFrames / 2
	for i = 1, numFrames do
		deck:setUVRect(i, (i - 1) / numFrames, 0, i / numFrames, 1)
		deck:setRect(i, -hw, 0, hw, h)
	end
	if animName then
		local curve = MOAIAnimCurve.new()
		curve:reserveKeys (numFrames)
		for i = 1, numFrames do
			curve:setKey(i, (i - 1) / fps, i, MOAIEaseType.FLAT)
		end
		if not deck._animCurves then
			deck._animCurves = {}
		end
		deck._animCurves[animName] = curve
	end
	deck:setTexture(tex)
	deck.type = "sequencedeck"
	deck.numFrames = numFrames
	deck.getSize = sequencedeck_getSize
	deck._size = {hw * 2, h}
	self:setDeck(deck)
	self._sourceName = tostring(deck)
end

function Sprite._addSelf(self)
	if self._anim then
		self._anim:start()
	end
end

function Sprite._removeSelf(self)
	if self._anim then
		self._anim:stop()
	end
	self:_preSpriteRemoveSelf()
end

function Sprite.new(data)
	local o = node.new(MOAIProp2D.new())
	o._preSpriteSetDeck = o.setDeck
	o.setDeck = Sprite.setDeck
	o._preSpriteDestroy = o.destroy
	o.destroy = Sprite.destroy
	o.setSize = Sprite.setSize
	o.getSize = Sprite.getSize
	o.setImage = Sprite.setImage
	o.playAnim = Sprite.playAnim
	o.stopAnim = Sprite.stopAnim
	o.loadImage = Sprite.loadImage
	o.loadAnim = Sprite.loadAnim
	o.loadSequence = Sprite.loadSequence
	o.throttle = Sprite.throttle
	o._preSpriteSetColor = o.setColor
	o.setColor = Sprite.setColor
	o._preSpriteSetPriority = o.setPriority
	o.setPriority = Sprite.setPriority
	o.playFlash = Sprite.playFlash
	o._preSpriteRemoveSelf = o._removeSelf
	o._removeSelf = Sprite._removeSelf
	o._addSelf = Sprite._addSelf
	
	local tname = type(data)
	if tname == "userdata" then
		local deck = MOAIGfxQuad2D.new()
		do
			local tex = data
			deck:setTexture(tex)
			local w, h = tex:getSize()
			deck:setRect(-w / 2, -h / 2, w / 2, h / 2)
			o:setDeck(deck)
		end
		o._sourceName = tostring(data)
	elseif tname == "string" then
		Sprite.loadAnim(o, data)
		o._sourceName = data
	end
	return o
end

return Sprite