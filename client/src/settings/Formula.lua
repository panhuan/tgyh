local ResDef = require "settings.ResDef"
local device = require "device"

local Formula = {}

local enemyName = 
{
	--"meteorolite",
	--"splitMeteorolite",
	"plane",
	"battlePlane",
}

local bornPos = 
{
	[1] = {anchor = "MT", x = 0, y = 0},
	[2] = {anchor = "MT", x = -100, y = 0},
	[3] = {anchor = "MT", x = 100, y = 0},
	[4] = {anchor = "MT", x = {-100, 100}, y = 0},
	-- [5] = {anchor = "LT", x = 0, y = -150},
	-- [6] = {anchor = "LT", x = 0, y = {0, -100}},
	-- [7] = {anchor = "RT", x = 0, y = -150},
	-- [8] = {anchor = "RT", x = 0, y = {0, -100}},
}

function Formula:calcEnemys(waveIndex)
	local enemys = {}
	local rand = math.random(1,2)
	if rand == 1 then
		enemys.type = "normal"
		for i = 1, math.random(5) do
			local enemyInfo = {}
			enemyInfo.pos = bornPos[math.random(1, #bornPos)]
			enemyInfo.name = enemyName[math.random(1, #enemyName)]
			table.insert(enemys, enemyInfo)
		end
	else
		enemys.type = "team"
		enemys.count = 5
		enemys.delay = 0.25
		enemys.name = "battlePlane"
		enemys.pos = {anchor = "MT", x = math.random(-device.ui_width / 2 + 100, device.ui_width / 2 - 100), y = 0}
		enemys.tbPosX = {enemys.pos.x, enemys.pos.x - 80, enemys.pos.x + 80, enemys.pos.x}
	end
	
	return enemys
end

function Formula:calcGameBG(waveIndex)
	return ResDef.bg
end

return Formula