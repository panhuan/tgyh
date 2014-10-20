
local node = require "node"
local url = require "url"
local color = require "color"
local resource = require "resource"

local Image = {}

local function dummy_getSize(self)
	return self._canary:getSize()
end

local function dummy_setImage(self, name)
	self._canary:setImage(name)
end

function Image.setColor(self, r, g, b, a)
	if type(r) == "string" then
		r, g, b, a = color.parse(r)
	end
	self:_preImageSetColor(r, g, b, a)
end

function Image.getSize(self)
	if not self or not self._deck or not self._deck.getSize then
		return nil
	end
	local w, h = self._deck:getSize(self.deckLayer)
	local x, y = self:getScl()
	return w * x, h * y
end

function Image.load(self, urlStr)
	if not urlStr then
		self:setDeck(nil)
		return
	end
	if self._canary then
		self._canary:destroy()
	end
	if urlStr[1] == "$" then
		self:setDeck(nil)
		self.getSize = dummy_getSize
		self.setImage = dummy_setImage
		self._canary = self:add(Image.new(urlStr:sub(2)))
		return self
	end
	self.getSize = Image.getSize
	self.setImage = Image.setImage
	
	local urlStr, queryStr = string.split(urlStr, "?")
	local deckName, layerName = string.split(urlStr, "#")
	local deck = resource.deck(deckName)
	self:setDeck(deck)
	if layerName ~= nil then
		self:setIndex(deck:indexOf(layerName))
		self.deckLayer = layerName
		self.deckIndex = deck:indexOf(layerName)
	end
	if queryStr ~= nil then
		local q = url.parse_query(queryStr)
		if q.scl ~= nil then
			local x, y = string.split(q.scl, ",")
			self:setScl(tonumber(x), tonumber(y or x))
		end
		if q.rot ~= nil then
			local rot = tonumber(q.rot)
			self:setRot(rot)
		end
		if q.loc ~= nil then
			local x, y = string.split(q.loc, ",")
			self:setLoc(tonumber(x), tonumber(y))
		end
		if q.pri ~= nil then
			local pri = tonumber(q.pri)
			self:setPriority(pri)
		end
		if q.alpha ~= nil then
			self:setColor(1, 1, 1, tonumber(q.alpha))
		end
	end
end

function Image.setDeck(self, deck)
	self._deck = deck
	self._preSpriteSetDeck(self, deck)
end

function Image.setImage(self, name)
	local index = self._deck:indexOf(name)
	self:setIndex(index)
end

function Image.setPriority(self, value, noRecursion)
	self:_preImageSetPriority(value, noRecursion)
	if self._canary then
		self._canary:setPriority(value, noRecursion)
	end
end

function Image.new(data)
	local o = node.new(MOAIProp2D.new())
	o.getSize = Image.getSize
	o.setImage = Image.setImage
	o._preSpriteSetDeck = o.setDeck
	o.setDeck = Image.setDeck
	o.load = Image.load
	o._preImageSetColor = o.setColor
	o.setColor = Image.setColor
	o._preImageSetPriority = o.setPriority
	o.setPriority = Image.setPriority
	
	local tname = type(data)
	if tname == "userdata" then
		local tex = data
		local deck = MOAIGfxQuad2D.new()
		deck:setTexture(tex)
		local w, h = tex:getSize()
		deck:setRect(-w / 2, -h / 2, w / 2, h / 2)
		o:setDeck(deck)
	elseif tname == "string" then
		o:load(data)
	end
	return o
end

return Image