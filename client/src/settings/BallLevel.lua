local BallLevel = {}

-- 升到该等级需要的球的数量
BallLevel.LevelUp =
{
	[1] = 30,
	[2] = 35,
	[3] = 40,
	[4] = 45,
	[5] = 50,
	[6] = 55,
	[7] = 60,
	[8] = 65,
	[9] = 70,
}

-- 该等级球的攻击力
BallLevel.LevelAttack =
{
	[0] = 5,
	[1] = 5,
	[2] = 8,
	[3] = 11,
	[4] = 15,
	[5] = 19,
	[6] = 24,
	[7] = 29,
	[8] = 35,
	[9] = 42,
}

BallLevel.Skills =
{
	[1] =
	{
		avatar = "kaixin_robot",
		image = "gameplay2.atlas.png#kx.png",
		name = "gameplay2.atlas.png#kx_z.png",
	},
	[2] =
	{
		avatar = "huaxin_robot",
		image = "gameplay2.atlas.png#hx.png",
		name = "gameplay2.atlas.png#hx_z.png",
	},
	[3] =
	{
		avatar = "tianxin_robot",
		image = "gameplay2.atlas.png#tx.png",
		name = "gameplay2.atlas.png#tx_z.png",
	},
	[4] =
	{
		avatar = "cuxin_robot",
		image = "gameplay2.atlas.png#cx.png",
		name = "gameplay2.atlas.png#cx_z.png",
	},
	[5] =
	{
		avatar = "xiaoxin_robot",
		image = "gameplay2.atlas.png#xx.png",
		name = "gameplay2.atlas.png#xx_z.png",
	},
}

BallLevel.maxLevel = 9

function BallLevel:calcLevelUp(curLevel, curCount)
	local level = 0
	for l = curLevel+1, self.maxLevel do
		local needCount = self.LevelUp[l]
		if curCount >= needCount then
			level = level + 1
			curCount = curCount - needCount
		end
	end

	return level, curCount
end

function BallLevel:getNeedCountByLevel(level)
	return self.LevelUp[level]
end

function BallLevel:getBallLevelDamage(level)
	if level > BallLevel.maxLevel then
		level = BallLevel.maxLevel
	end

	return self.LevelAttack[level] or 0
end

function BallLevel:calcLevelupNeedBallCount(curLevel)
	local nextCount = self.LevelUp[curLevel + 1]
	if not nextCount then
		return 0
	end
	return nextCount
end

function BallLevel:getBallSkill(ballId)
	return self.Skills[ballId]
end

return BallLevel
