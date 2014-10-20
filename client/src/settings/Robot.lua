
local Robot =
{
	--1、开心   2、花心  3、甜心   4、粗心   5、小心

	-- 机车侠手动解锁花费
	robotUnlock =
	{
		[1] =
		{
			costType = "money",
			cost = 0,
		},
		[2] =
		{
			costType = "money",
			cost = 150,
		},
		[3] =
		{
			costType = "money",
			cost = 240,
		},
		[4] =
		{
			costType = "money",
			cost = 360,
		},
		[5] =
		{
			costType = "money",
			cost = 360,
		},
	},

	-- 机车侠对应超人的攻击力系数
	robotAttack =
	{
		[1] = 30,
		[2] = 30,
		[3] = 30,
		[4] = 30,
		[5] = 30,
	},

	-- 机车侠根据对应超人的等级自动解锁
	robotUnlockByPetLevel =
	{
		[1] = 30,
		[2] = 30,
		[3] = 30,
		[4] = 30,
		[5] = 30,
	},

	robotAttackPic =
	{
		[1] = "ui.atlas.png#kaixin_x.png",
		[2] = "ui.atlas.png#huaxin_x.png",
		[3] = "ui.atlas.png#tianxin_x.png",
		[4] = "ui.atlas.png#cuxin_x.png",
		[5] = "ui.atlas.png#xiaoxin_x.png",
	},
}

function Robot:getRobotCost(idx)
	return self.robotUnlock[idx]
end

function Robot:getRobotAttack(idx)
	return self.robotAttack[idx]
end

function Robot:getRobotUnlockByPetLevel(idx)
	return self.robotUnlockByPetLevel[idx]
end
return Robot
