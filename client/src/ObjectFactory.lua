local node = require "node"

-- hero
local Hero = require "settings.Hero"

-- enemy
local Meteorolite = require "settings.enemy.Meteorolite"
local SplitMeteorolite = require "settings.enemy.SplitMeteorolite"
local Plane = require "settings.enemy.Plane"
local BattlePlane = require "settings.enemy.BattlePlane"

-- spacestation
local LineBattery = require "settings.spacestation.LineBattery"
local Umbrella = require "settings.spacestation.Umbrella"


local ObjectFactory = {}

local name2Object =
{
	hero = Hero,
	meteorolite = Meteorolite,
	splitMeteorolite = SplitMeteorolite,
	plane = Plane,
	battlePlane = BattlePlane,
	lineBattery = LineBattery,
	umbrella = Umbrella,
}

function ObjectFactory:init()

end

function ObjectFactory:createObject(param)
	assert(name2Object[param.name], "object name is not exist: "..param.name)
	local object = name2Object[param.name]()
	object._root = node.new()
	
	if object.create then
		object:create()
	end
	return object
end

function ObjectFactory:destroyObject(param)
	if not param.object then
		return
	end
	if param.object.destroy then
		param.object:destroy()
	else
		param.object._root:destroy()
	end
	
end

return ObjectFactory