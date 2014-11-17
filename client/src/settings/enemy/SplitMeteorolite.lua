local ResDef = require "settings.ResDef"
local Image = require "gfx.Image"
local Enemy = require "settings.enemy.Enemy"

local SplitMeteorolite = class "SplitMeteorolite" inherit "Enemy" define
{
	hp = 2,
	speed = 0.3,
	damage = 2,
	trajectory = "line",
	attackType = "nomarl",
	split = 
	{
		count = 3,
		object = "meteorolite",
	},
	draw = 
	{
		pic = ResDef.enemy.splitmeteorolite,
	},
}

return SplitMeteorolite
