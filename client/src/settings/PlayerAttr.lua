

local PlayerAttr =
{
	-- 根据角色级别 金币和分数的收益系数
	income =
	{
		[1] = {gold = 3, score = 3},
		[2] = {gold = 6, score = 6},
		[3] = {gold = 9, score = 9},
		[4] = {gold = 12, score = 12},
		[5] = {gold = 15, score = 15},
		[6] = {gold = 18, score = 18},
		[7] = {gold = 21, score = 21},
		[8] = {gold = 24, score = 24},
		[9] = {gold = 27, score = 27},
		[10] = {gold = 30, score = 30},
		[11] = {gold = 33, score = 33},
		[12] = {gold = 36, score = 36},
		[13] = {gold = 39, score = 39},
		[14] = {gold = 42, score = 42},
		[15] = {gold = 45, score = 45},
		[16] = {gold = 48, score = 48},
		[17] = {gold = 51, score = 51},
		[18] = {gold = 54, score = 54},
		[19] = {gold = 57, score = 57},
		[20] = {gold = 60, score = 60},
		[21] = {gold = 63, score = 63},
		[22] = {gold = 66, score = 66},
		[23] = {gold = 69, score = 69},
		[24] = {gold = 72, score = 72},
		[25] = {gold = 75, score = 75},
		[26] = {gold = 78, score = 78},
		[27] = {gold = 81, score = 81},
		[28] = {gold = 84, score = 84},
		[29] = {gold = 87, score = 87},
		[30] = {gold = 90, score = 90},

	}
}

function PlayerAttr:getIncome(level)
	return self.income[level]
end

return PlayerAttr
