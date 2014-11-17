local ResDef = require "settings.ResDef"
local Image = require "gfx.Image"
local Enemy = require "settings.enemy.Enemy"

local Meteorolite = class "Meteorolite" inherit "Enemy" define
{
	hp = 1,
	speed = 0.3,
	damage = 1,
	trajectory = "line",
	attackType = "nomarl",
	draw = 
	{
		pic = ResDef.enemy.meteorolite,
	},
}

return Meteorolite
