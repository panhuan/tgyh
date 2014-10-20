
local Image = require "gfx.Image"
local Sprite = require "gfx.Sprite"
local ParticleSystem = require "gfx.ParticleSystem"
local resource = require "resource"
local actionset = require "actionset"

local gfxutil = {
	AS = actionset.new()
}

local typemap = {
	["img"] = Image.new,
	["ani"] = Sprite.new,
	["ps"] = ParticleSystem.new,
}

function gfxutil.preLoadAssets(filename, transform)
	if filename[1] == "$" then
		filename = filename:sub(2)
	end
	local urlStr, queryStr = string.split(filename, "?")
	local deckName, layerName = string.split(urlStr, "#")
	
	if type(deckName) == "string" then
		resource.texture(deckName, transform)
	end
end

function gfxutil.loadAssets(o)
	if type(o) == "string" then
		local typ, res = string.split(o, ":")
		if not res then
			return Image.new(o)
		end
		return typemap[typ](res)
	elseif type(o) == "userdata" then
		return o
	end
	return o
end

function gfxutil.createTilingBG(texname)
	local tex = resource.texture(texname)
	local w, h = tex:getSize()
	local tileDeck = MOAITileDeck2D.new()
	tileDeck:setTexture(tex)
	tileDeck:setSize(1, 1)
	local grid = MOAIGrid.new()
	grid:setSize(1, 1, w, h)
	grid:setRow(1, 1)
	grid:setRepeat(true)
	local prop = MOAIProp2D.new()
	prop:setDeck(tileDeck)
	prop:setGrid(grid)
	prop:setLoc(-device.width / 2 - w / 2, 0)
	prop.height = h
	prop.width = w
	return prop
end

return gfxutil