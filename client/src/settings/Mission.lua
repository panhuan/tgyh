local ResDef = require "settings.ResDef"

local enemyTeams = 
{
	[1] = 
	{
		meteorolite = 5,
	},
	[2] = 
	{
		meteorolite = 3,
		splitmeteorolite = 2,
	},
	[3] = 
	{
		plane = 5,
	},
	[4] = 
	{
		plane = 3,
		battleplane = 2,
	},
	[5] = 
	{
		battleplane = 5,
	},
	[6] = 
	{
		meteorolite = 2,
		battleplane = 3,
	},
	[7] = 
	{
		splitmeteorolite = 2,
		battleplane = 3,
	},
}

local bornPos = 
{
	[1] = {anchor = "MT", x = 0, y = 0},
	[2] = {anchor = "MT", x = -100, y = 0},
	[3] = {anchor = "MT", x = 100, y = 0},
	[4] = {anchor = "MT", x = {-100, 100}, y = 0},
	[5] = {anchor = "LT", x = 0, y = -150},
	[6] = {anchor = "LT", x = 0, y = {0, -100}},
	[7] = {anchor = "RT", x = 0, y = -150},
	[8] = {anchor = "RT", x = 0, y = {0, -100}},
}

local Mission = 
{
	[1] = 
	{
		bg = ResDef.bg,		
		hero = 
		{
			pos = {anchor = "MB", x = 0, y = 0}
		},
		waveCount = 10,
	}
}

function Mission:getMission(index)
	assert(self[index], "mission index is not exist: "..index)
	return self[index]
end

function Mission:getEnemys(index, enemysIndex)
	assert(self[index], "mission index is not exist: "..index)
	assert(self[index].timeLen[enemysIndex], "enemysIndex is not exist: "..enemysIndex)
	local enemys = self[index].timeLen[enemysIndex].enemys
	local rand = math.random(1, #enemys)
	return enemyTeams[enemys[rand]]
end

function Mission:getEnemysBornPos(index, enemysIndex)
	assert(self[index], "mission index is not exist: "..index)
	assert(self[index].timeLen[enemysIndex], "enemysIndex is not exist: "..enemysIndex)
	local pos = bornPos[self[index].timeLen[enemysIndex].pos]
	return pos
end

return Mission