local ResDef = require "settings.ResDef"
local Image = require "gfx.Image"
local Enemy = require "settings.enemy.Enemy"

local BattlePlane = class "BattlePlane" inherit "Enemy" define
{
	hp = 3,
	speed = 0.5,
	damage = 4,
	trajectory = "curve",
	attackType = "bullet",
	bullet = 
	{
		hp = 1,
		speed = 4,
		damage = 1,
		trajectory = "line",
		attackType = "nomarl",
	},
	draw = 
	{
		pic = ResDef.enemy.battleplane,
	},
}

return BattlePlane
