local GameConfig = require "settings.GameConfig"

local Timing =
{
	-- x, y时间模式关卡出现在大地图上的位置
	-- mission时间模式关卡出现的关卡要求
	-- opencost手动重置冷却时间的花费
	-- timeLength时间模式游戏时间(单位:秒)
	-- refreshTime时间模式刷新时间(单位:秒)
	-- monsterList时间模式怪物列表
	-- rewardTime没杀死一个怪物加的时间
	[1] =
	{
		x = -100,
		y = -2600,
		mission = 10,
		opencost = 30,
		timeLength =30,
		refreshTime = 10800,
		titlePic = "ui.atlas.png#jlgk_zi_1.png",
		monsterLoc = {-75, 120},
		monsterList =
		{
			{
				avatarId = "huiguai",
				background = GameConfig.monsterBgList[1],
				hp = 163,
				hpX = 0,
				hpY = 130,
				rewardTime = 5,
				rewardExp = 0,
				rewardGold = 40,
				rewardScore = 1000,
			},
			{
				avatarId = "konglongmei",
				background = GameConfig.monsterBgList[1],
				hp = 252,
				hpX = 0,
				hpY = 130,
				rewardTime = 5,
				rewardExp = 0,
				rewardGold = 90,
				rewardScore = 2000,
			},
			{
				avatarId = "bibilong_xiao",
				background = GameConfig.monsterBgList[1],
				hp = 367,
				hpX = 0,
				hpY = 130,
				rewardTime = 5,
				rewardExp = 0,
				rewardGold = 150,
				rewardScore = 3000,
			},
			{
				avatarId = "lvguai",
				background = GameConfig.monsterBgList[1],
				hp = 508,
				hpX = 0,
				hpY = 130,
				rewardTime = 5,
				rewardExp = 0,
				rewardGold = 210,
				rewardScore = 4000,
			},
			{
				avatarId = "qie",
				background = GameConfig.monsterBgList[1],
				hp = 675,
				hpX = 0,
				hpY = 130,
				rewardTime = 5,
				rewardExp = 0,
				rewardGold = 280,
				rewardScore = 5000,
			},
			{
				avatarId = "hongguai",
				background = GameConfig.monsterBgList[1],
				hp = 868,
				hpX = 0,
				hpY = 130,
				rewardTime = 5,
				rewardExp = 0,
				rewardGold = 350,
				rewardScore = 6000,
			},
			{
				avatarId = "yuguai_xiao",
				background = GameConfig.monsterBgList[1],
				hp = 1087,
				hpX = 0,
				hpY = 130,
				rewardTime = 5,
				rewardExp = 0,
				rewardGold = 430,
				rewardScore = 7000,
			},
			{
				avatarId = "zhimahu",
				background = GameConfig.monsterBgList[1],
				hp = 1332,
				hpX = 0,
				hpY = 130,
				rewardTime = 5,
				rewardExp = 0,
				rewardGold = 510,
				rewardScore = 8000,
			},
			{
				avatarId = "bianju_xiao",
				background = GameConfig.monsterBgList[1],
				hp = 1603,
				hpX = 0,
				hpY = 130,
				rewardTime = 5,
				rewardExp = 0,
				rewardGold = 600,
				rewardScore = 9000,
			},
			{
				avatarId = "cuimian",
				background = GameConfig.monsterBgList[1],
				hp = 1900,
				hpX = 0,
				hpY = 130,
				rewardTime = 5,
				rewardExp = 0,
				rewardGold = 700,
				rewardScore = 10000,
			},
			{
				avatarId = "zuantou_xiao",
				background = GameConfig.monsterBgList[1],
				hp = 2223,
				hpX = 0,
				hpY = 130,
				rewardTime = 5,
				rewardExp = 0,
				rewardGold = 800,
				rewardScore = 11000,
			},
			{
				avatarId = "zoushenguai",
				background = GameConfig.monsterBgList[1],
				hp = 2572,
				hpX = 0,
				hpY = 130,
				rewardTime = 5,
				rewardExp = 0,
				rewardGold = 910,
				rewardScore = 12000,
			},
			{
				avatarId = "shazhang",
				background = GameConfig.monsterBgList[1],
				hp = 2947,
				hpX = 0,
				hpY = 130,
				rewardTime = 5,
				rewardExp = 0,
				rewardGold = 1030,
				rewardScore = 13000,
			},
			{
				avatarId = "fengguai",
				background = GameConfig.monsterBgList[1],
				hp = 3348,
				hpX = 0,
				hpY = 130,
				rewardTime = 5,
				rewardExp = 0,
				rewardGold = 1150,
				rewardScore = 14000,
			},
			{
				avatarId = "shayu_xiao",
				background = GameConfig.monsterBgList[1],
				hp = 3775,
				hpX = 0,
				hpY = 130,
				rewardTime = 5,
				rewardExp = 0,
				rewardGold = 1280,
				rewardScore = 15000,
			},
		},
	},
	[2] =
	{
		x = -200,
		y = -690,
		mission = 25,
		opencost = 60,
		timeLength =60,
		refreshTime = 21600,
		titlePic = "ui.atlas.png#jlgk_zi_2.png",
		monsterLoc = {-75, 210},
		monsterList =
		{
			{
				avatarId = "bibilong_da",
				background = GameConfig.monsterBgList[1],
				hp = 4452,
				hpX = 0,
				hpY = 130,
				rewardTime = 10,
				rewardExp = 0,
				rewardGold = 990,
				rewardScore = 2000,
			},
			{
				avatarId = "zhezhiguai",
				background = GameConfig.monsterBgList[1],
				hp = 4928,
				hpX = 0,
				hpY = 130,
				rewardTime = 10,
				rewardExp = 0,
				rewardGold = 1090,
				rewardScore = 4000,
			},
			{
				avatarId = "yuguai_da",
				background = GameConfig.monsterBgList[1],
				hp = 5428,
				hpX = 0,
				hpY = 130,
				rewardTime = 10,
				rewardExp = 0,
				rewardGold = 1190,
				rewardScore = 6000,
			},
			{
				avatarId = "bianju_da",
				background = GameConfig.monsterBgList[1],
				hp = 5952,
				hpX = 0,
				hpY = 130,
				rewardTime = 10,
				rewardExp = 0,
				rewardGold = 1290,
				rewardScore = 8000,
			},
			{
				avatarId = "zuantou_da",
				background = GameConfig.monsterBgList[1],
				hp = 6500,
				hpX = 0,
				hpY = 130,
				rewardTime = 10,
				rewardExp = 0,
				rewardGold = 1400,
				rewardScore = 10000,
			},
			{
				avatarId = "bianfuguai",
				background = GameConfig.monsterBgList[1],
				hp = 7072,
				hpX = 0,
				hpY = 130,
				rewardTime = 10,
				rewardExp = 0,
				rewardGold = 1510,
				rewardScore = 12000,
			},
			{
				avatarId = "ciliguai",
				background = GameConfig.monsterBgList[1],
				hp = 7668,
				hpX = 0,
				hpY = 130,
				rewardTime = 10,
				rewardExp = 0,
				rewardGold = 1630,
				rewardScore = 14000,
			},
			{
				avatarId = "niangniangguai",
				background = GameConfig.monsterBgList[1],
				hp = 8288,
				hpX = 0,
				hpY = 130,
				rewardTime = 10,
				rewardExp = 0,
				rewardGold = 1750,
				rewardScore = 16000,
			},
			{
				avatarId = "shayu_da",
				background = GameConfig.monsterBgList[1],
				hp = 8932,
				hpX = 0,
				hpY = 130,
				rewardTime = 10,
				rewardExp = 0,
				rewardGold = 1870,
				rewardScore = 18000,
			},
			{
				avatarId = "niuguai",
				background = GameConfig.monsterBgList[1],
				hp = 9600,
				hpX = 0,
				hpY = 130,
				rewardTime = 10,
				rewardExp = 0,
				rewardGold = 2000,
				rewardScore = 20000,
			},
		},
	},
	[3] =
	{
		x = 150,
		y = 2200,
		mission = 50,
		opencost = 99,
		timeLength =90,
		refreshTime = 43200,
		titlePic = "ui.atlas.png#jlgk_zi_3.png",
		monsterLoc = {-135, 210},
		monsterList =
		{
			{
				avatarId = "jianzhujixie",
				background = GameConfig.monsterBgList[1],
				hp = 15325,
				hpX = 0,
				hpY = 130,
				rewardTime = 15,
				rewardExp = 0,
				rewardGold = 5630,
				rewardScore = 5000,
			},
			{
				avatarId = "juxiguai",
				background = GameConfig.monsterBgList[1],
				hp = 16600,
				hpX = 0,
				hpY = 130,
				rewardTime = 15,
				rewardExp = 0,
				rewardGold = 6070,
				rewardScore = 10000,
			},
			{
				avatarId = "hongwaixian",
				background = GameConfig.monsterBgList[1],
				hp = 17925,
				hpX = 0,
				hpY = 130,
				rewardTime = 15,
				rewardExp = 0,
				rewardGold = 6530,
				rewardScore = 15000,
			},
			{
				avatarId = "sanggou",
				background = GameConfig.monsterBgList[1],
				hp = 19300,
				hpX = 0,
				hpY = 130,
				rewardTime = 15,
				rewardExp = 0,
				rewardGold = 7010,
				rewardScore = 20000,
			},
			{
				avatarId = "paotai",
				background = GameConfig.monsterBgList[1],
				hp = 20725,
				hpX = 0,
				hpY = 130,
				rewardTime = 15,
				rewardExp = 0,
				rewardGold = 7500,
				rewardScore = 25000,
			},
		},
	},

}

function Timing:getMissionReq(idx)
	if not self[idx] then
		return 0
	end
	return self[idx].mission
end

function Timing:getTimeLength(idx)
	if not self[idx] then
		return 0
	end
	return self[idx].timeLength
end

function Timing:getTimOpenCost(idx)
	if not self[idx] then
		return 0
	end
	return self[idx].opencost
end

function Timing:getRefreshTime(idx)
	if not self[idx] then
		return 0
	end
	return self[idx].refreshTime
end

function Timing:getMonsterCount(idx)
	if not self[idx] then
		return 0
	end
	return #(self[idx].monsterList)
end

function Timing:getMonsterList(idx)
	if not self[idx] then
		return nil
	end
	return self[idx].monsterList
end

function Timing:getMonster(idx, monsterIdx)
	if not self[idx] or not self[idx].monsterList[monsterIdx] then
		return nil
	end
	return self[idx].monsterList[monsterIdx]
end

function Timing:getMonsterBg(idx, monsterIdx)
	if not self[idx] or not self[idx].monsterList[monsterIdx] then
		return
	end
	return self[idx].monsterList[monsterIdx].background
end

function Timing:getRewardExp(idx, monsterIdx)
	if not self[idx] or not self[idx].monsterList[monsterIdx] then
		return 0
	end
	return self[idx].monsterList[monsterIdx].rewardExp
end

function Timing:getRewardGold(idx, monsterIdx)
	if not self[idx] or not self[idx].monsterList[monsterIdx] then
		return 0
	end
	return self[idx].monsterList[monsterIdx].rewardGold
end

function Timing:getRewardScore(idx, monsterIdx)
	if not self[idx] or not self[idx].monsterList[monsterIdx] then
		return 0
	end
	return self[idx].monsterList[monsterIdx].rewardScore
end

function Timing:getRewardTime(idx, monsterIdx)
	if not self[idx] or not self[idx].monsterList[monsterIdx] then
		return 0
	end
	return self[idx].monsterList[monsterIdx].rewardTime
end

return Timing
