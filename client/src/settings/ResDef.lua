local gfxutil = require "gfxutil"

local ResDef = {}

ResDef.bg = "starfield.jpg"
ResDef.hero = 
{
	lv1 = "1_1.png",
	lv2 = "1_1.png",
	lv3 = "1_1.png",
	lv4 = "1_1.png",
	lv5 = "1_1.png",
	lv6 = "1_1.png",
	lv7 = "1_1.png",
	lv8 = "1_1.png",
	lv9 = "1_1.png",
	lv10 = "1_1.png",
}

ResDef.enemy = 
{
	meteorolite = 
	{
		"5_3.png",
		"5_4.png",
		"6_3.png",
		"6_4.png",
	},
	splitmeteorolite = 
	{
		"7_4.png",
		"8_3.png",
		"8_4.png",
	},
	plane = 
	{
		"enemy_01.png",
		"enemy_02.png",
	},
	battleplane = 
	{
		"enemy_03.png",
		"enemy_04.png",
	},
}

ResDef.bullet = 
{
	
}


function ResDef:resLoad(tb)
	tb = tb or self
	for key, var in pairs(tb) do
		if type(var) == "string" then
			gfxutil.preLoadAssets(var)
		elseif type(var) == "table" then
			self:resLoad(var)
		end
	end
end

return ResDef