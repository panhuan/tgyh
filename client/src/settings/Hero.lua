local ResDef = require "settings.ResDef"
local UserData = require "UserData"
local Image = require "gfx.Image"

local HeroSetting = 
{
	[1] = 
	{
		exp = 0,
		connectCount = 2,
		draw = 
		{
			pic = ResDef.hero.lv1
		},
	},
	[2] = 
	{
		exp = 10,
		connectCount = 4,
		draw = 
		{
			pic = ResDef.hero.lv2
		},
	},
	[3] = 
	{
		exp = 10,
		connectCount = 6,
		draw = 
		{
			pic = ResDef.hero.lv3
		},
	},
	[4] = 
	{
		exp = 10,
		connectCount = 8,
		draw = 
		{
			pic = ResDef.hero.lv4
		},
	},
	[5] = 
	{
		exp = 10,
		connectCount = 10,
		draw = 
		{
			pic = ResDef.hero.lv5
		},
	},
	[6] = 
	{
		exp = 10,
		connectCount = 12,
		draw = 
		{
			pic = ResDef.hero.lv6
		},
	},
	[7] = 
	{
		exp = 10,
		connectCount = 14,
		draw = 
		{
			pic = ResDef.hero.lv7
		},
	},
	[8] = 
	{
		exp = 10,
		connectCount = 16,
		draw = 
		{
			pic = ResDef.hero.lv8
		},
	},
	[9] = 
	{
		exp = 10,
		connectCount = 18,
		draw = 
		{
			pic = ResDef.hero.lv9
		},
	},
	[10] = 
	{
		exp = 10,
		connectCount = 20,
		draw = 
		{
			pic = ResDef.hero.lv10
		},
	},
}

local Hero = class "Hero" define {}

function Hero:getLevelInfo(level)
	assert(HeroSetting[level], "hero level is not exist: "..level)
	return HeroSetting[level]
end

function Hero:create(param)
	local level = UserData:getLevel()
	local heroLvSetting = self:getLevelInfo(level)
	self._pic = self._root:add(Image.new(heroLvSetting.draw.pic))
	param.root:add(self._root)
	self:initPos()
end

function Hero:initPos()
	local picW, picH = self._pic:getSize()
	local anchor, x, y = "MB", 0, 0
	y = y + picH / 2
	self._root:setAnchor(anchor, x, y)
end

return Hero