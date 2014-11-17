local ResDef = require "settings.ResDef"
local Image = require "gfx.Image"
local Enemy = require "settings.enemy.Enemy"

local Plane = class "Plane" inherit "Enemy" define
{
	hp = 3,
	speed = 0.5,
	damage = 3,
	trajectory = "line",
	attackType = "nomarl",
	draw = 
	{
		pic = ResDef.enemy.plane,
	},
}

return Plane
