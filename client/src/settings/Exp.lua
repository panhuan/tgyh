
local Exp =
{
	[1] = 100,
	[2] = 160,
	[3] = 260,
	[4] = 380,
	[5] = 540,
	[6] = 720,
	[7] = 940,
	[8] = 1180,
	[9] = 1460,
	[10] = 1760,
	[11] = 2100,
	[12] = 2460,
	[13] = 2860,
	[14] = 3280,
	[15] = 3740,
	[16] = 4220,
	[17] = 4740,
	[18] = 5280,
	[19] = 5860,
	[20] = 6460,
	[21] = 7100,
	[22] = 7760,
	[23] = 8460,
	[24] = 9180,
	[25] = 9940,
	[26] = 10720,
	[27] = 11540,
	[28] = 12380,
	[29] = 13260,


	maxLevel = 29
}

function Exp:getMaxLevel()
	return Exp.maxLevel
end

function Exp:getExp(level)
	if level < 1 or level > self:getMaxLevel() then
		return
	end
	return Exp[level]
end

return Exp
