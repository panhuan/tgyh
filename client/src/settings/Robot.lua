
local Robot =
{
	--1������   2������  3������   4������   5��С��

	-- �������ֶ���������
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

	-- ��������Ӧ���˵Ĺ�����ϵ��
	robotAttack =
	{
		[1] = 30,
		[2] = 30,
		[3] = 30,
		[4] = 30,
		[5] = 30,
	},

	-- ���������ݶ�Ӧ���˵ĵȼ��Զ�����
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
