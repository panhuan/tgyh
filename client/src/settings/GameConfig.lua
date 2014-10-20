
local GameConfig = {}


GameConfig.initialStep = 15

GameConfig.buyStepTimes = 999999

GameConfig.buySteps = 3

GameConfig.buyStepPrice = 10

GameConfig.stageMission = 5

GameConfig.linkNum2AttackAddition =
{
	[1] = 0,
	[4] = 0.5,
	[6] = 1,
	[8] = 1.5,
	[10] = 2,
}

GameConfig.testStage =
{
	columns =
	{
		[1] = {},
		[2] = {},
		[3] = {},
		[4] = {},
		[5] = {},
		[6] = {},
		[7] = {},
	},
	weights =
	{
		[1] = 0.2,
		[2] = 0.2,
		[3] = 0.2,
		[4] = 0.2,
		[5] = 0.2,
	},
}

local monsterBgList =
{
	[1] = "scene1.jpg",
	[2] = "scene2.jpg",
	[3] = "scene3.jpg",
	[4] = "scene4.jpg",
	[5] = "scene5.jpg",
	[6] = "scene6.jpg",
}
GameConfig.monsterBgList = monsterBgList

local monsterList =
{
	{
		avatarId = "huiguai",
		background = monsterBgList[1],
		hp = 120,
		hpX = 0,
		hpY = 130,
		rewardStep = 5,
		rewardExp = 50,
		rewardGold = 110,
		rewardScore = 50,
	},
	{
		avatarId = "konglongmei",
		background = monsterBgList[1],
		hp = 210,
		hpX = 0,
		hpY = 130,
		rewardStep = 5,
		rewardExp = 50,
		rewardGold = 120,
		rewardScore = 100,
	},
	{
		avatarId = "bibilong_xiao",
		background = monsterBgList[1],
		hp = 320,
		hpX = 0,
		hpY = 130,
		rewardStep = 5,
		rewardExp = 50,
		rewardGold = 130,
		rewardScore = 300,
	},
	{
		avatarId = "bibilong_da",
		background = monsterBgList[1],
		hp = 800,
		hpX = 0,
		hpY = 130,
		rewardStep = 5,
		rewardExp = 80,
		rewardGold = 230,
		rewardScore = 200,
	},
	{
		avatarId = "lvguai",
		background = monsterBgList[2],
		hp = 600,
		hpX = 0,
		hpY = 130,
		rewardStep = 5,
		rewardExp = 50,
		rewardGold = 150,
		rewardScore = 250,
	},
	{
		avatarId = "qie",
		background = monsterBgList[2],
		hp = 770,
		hpX = 0,
		hpY = 130,
		rewardStep = 5,
		rewardExp = 60,
		rewardGold = 160,
		rewardScore = 600,
	},
	{
		avatarId = "zhezhiguai",
		background = monsterBgList[2],
		hp = 1970,
		hpX = 0,
		hpY = 130,
		rewardStep = 5,
		rewardExp = 90,
		rewardGold = 290,
		rewardScore = 350,
	},
	{
		avatarId = "hongguai",
		background = monsterBgList[3],
		hp = 1170,
		hpX = 0,
		hpY = 130,
		rewardStep = 5,
		rewardExp = 60,
		rewardGold = 180,
		rewardScore = 400,
	},
	{
		avatarId = "yuguai_xiao",
		background = monsterBgList[3],
		hp = 1400,
		hpX = 0,
		hpY = 130,
		rewardStep = 5,
		rewardExp = 60,
		rewardGold = 190,
		rewardScore = 900,
	},
	{
		avatarId = "yuguai_da",
		background = monsterBgList[3],
		hp = 3680,
		hpX = 0,
		hpY = 130,
		rewardStep = 5,
		rewardExp = 100,
		rewardGold = 350,
		rewardScore = 500,
	},
	{
		avatarId = "zhimahu",
		background = monsterBgList[4],
		hp = 1920,
		hpX = 0,
		hpY = 130,
		rewardStep = 5,
		rewardExp = 70,
		rewardGold = 210,
		rewardScore = 550,
	},
	{
		avatarId = "bianju_xiao",
		background = monsterBgList[4],
		hp = 2210,
		hpX = 0,
		hpY = 130,
		rewardStep = 5,
		rewardExp = 70,
		rewardGold = 220,
		rewardScore = 1200,
	},
	{
		avatarId = "bianju_da",
		background = monsterBgList[4],
		hp = 5930,
		hpX = 0,
		hpY = 130,
		rewardStep = 5,
		rewardExp = 120,
		rewardGold = 410,
		rewardScore = 650,
	},
	{
		avatarId = "cuimian",
		background = monsterBgList[5],
		hp = 2850,
		hpX = 0,
		hpY = 130,
		rewardStep = 5,
		rewardExp = 70,
		rewardGold = 240,
		rewardScore = 700,
	},
	{
		avatarId = "zuantou_xiao",
		background = monsterBgList[5],
		hp = 3200,
		hpX = 0,
		hpY = 130,
		rewardStep = 5,
		rewardExp = 70,
		rewardGold = 250,
		rewardScore = 1500,
	},
	{
		avatarId = "zuantou_da",
		background = monsterBgList[5],
		hp = 8720,
		hpX = 0,
		hpY = 130,
		rewardStep = 5,
		rewardExp = 130,
		rewardGold = 470,
		rewardScore = 800,
	},
	{
		avatarId = "zoushenguai",
		background = monsterBgList[6],
		hp = 3960,
		hpX = 0,
		hpY = 130,
		rewardStep = 5,
		rewardExp = 80,
		rewardGold = 270,
		rewardScore = 850,
	},
	{
		avatarId = "bianfuguai",
		background = monsterBgList[6],
		hp = 10880,
		hpX = 0,
		hpY = 130,
		rewardStep = 5,
		rewardExp = 140,
		rewardGold = 510,
		rewardScore = 1800,
	},
	{
		avatarId = "shazhang",
		background = monsterBgList[1],
		hp = 4800,
		hpX = 0,
		hpY = 130,
		rewardStep = 5,
		rewardExp = 80,
		rewardGold = 290,
		rewardScore = 950,
	},
	{
		avatarId = "ciliguai",
		background = monsterBgList[1],
		hp = 13280,
		hpX = 0,
		hpY = 130,
		rewardStep = 5,
		rewardExp = 140,
		rewardGold = 550,
		rewardScore = 1000,
	},
	{
		avatarId = "fengguai",
		background = monsterBgList[2],
		hp = 5720,
		hpX = 0,
		hpY = 130,
		rewardStep = 5,
		rewardExp = 90,
		rewardGold = 310,
		rewardScore = 2100,
	},
	{
		avatarId = "niangniangguai",
		background = monsterBgList[2],
		hp = 15920,
		hpX = 0,
		hpY = 130,
		rewardStep = 5,
		rewardExp = 150,
		rewardGold = 590,
		rewardScore = 1100,
	},
	{
		avatarId = "shayu_xiao",
		background = monsterBgList[3],
		hp = 6720,
		hpX = 0,
		hpY = 130,
		rewardStep = 5,
		rewardExp = 90,
		rewardGold = 330,
		rewardScore = 1150,
	},
	{
		avatarId = "shayu_da",
		background = monsterBgList[3],
		hp = 18800,
		hpX = 0,
		hpY = 130,
		rewardStep = 5,
		rewardExp = 160,
		rewardGold = 630,
		rewardScore = 2400,
	},
	{
		avatarId = "niuguai",
		background = monsterBgList[4],
		hp = 20330,
		hpX = 0,
		hpY = 130,
		rewardStep = 5,
		rewardExp = 160,
		rewardGold = 650,
		rewardScore = 1250,
	},
	{
		avatarId = "jianzhujixie",
		background = monsterBgList[4],
		hp = 21920,
		hpX = 0,
		hpY = 130,
		rewardStep = 5,
		rewardExp = 170,
		rewardGold = 670,
		rewardScore = 1300,
	},
	{
		avatarId = "juxiguai",
		background = monsterBgList[4],
		hp = 32500,
		hpX = 0,
		hpY = 130,
		rewardStep = 5,
		rewardExp = 250,
		rewardGold = 880,
		rewardScore = 2700,
	},
	{
		avatarId = "hongwaixian",
		background = monsterBgList[5],
		hp = 34820,
		hpX = 0,
		hpY = 130,
		rewardStep = 5,
		rewardExp = 250,
		rewardGold = 900,
		rewardScore = 1400,
	},
	{
		avatarId = "sanggou",
		background = monsterBgList[5],
		hp = 37220,
		hpX = 0,
		hpY = 130,
		rewardStep = 5,
		rewardExp = 260,
		rewardGold = 930,
		rewardScore = 1450,
	},
	{
		avatarId = "paotai",
		background = monsterBgList[5],
		hp = 39700,
		hpX = 0,
		hpY = 130,
		rewardStep = 5,
		rewardExp = 260,
		rewardGold = 950,
		rewardScore = 3000,
	},
	{
		avatarId = "huiguai",
		background = monsterBgList[1],
		hp = 11520,
		hpX = 0,
		hpY = 130,
		rewardStep = 10,
		rewardExp = 110,
		rewardGold = 410,
		rewardScore = 1550,
	},
	{
		avatarId = "konglongmei",
		background = monsterBgList[1],
		hp = 12210,
		hpX = 0,
		hpY = 130,
		rewardStep = 10,
		rewardExp = 110,
		rewardGold = 420,
		rewardScore = 1600,
	},
	{
		avatarId = "bibilong_xiao",
		background = monsterBgList[1],
		hp = 12920,
		hpX = 0,
		hpY = 130,
		rewardStep = 10,
		rewardExp = 110,
		rewardGold = 430,
		rewardScore = 3300,
	},
	{
		avatarId = "bibilong_da",
		background = monsterBgList[1],
		hp = 36800,
		hpX = 0,
		hpY = 130,
		rewardStep = 10,
		rewardExp = 200,
		rewardGold = 830,
		rewardScore = 1700,
	},
	{
		avatarId = "lvguai",
		background = monsterBgList[2],
		hp = 14400,
		hpX = 0,
		hpY = 130,
		rewardStep = 10,
		rewardExp = 110,
		rewardGold = 450,
		rewardScore = 1750,
	},
	{
		avatarId = "qie",
		background = monsterBgList[2],
		hp = 15170,
		hpX = 0,
		hpY = 130,
		rewardStep = 10,
		rewardExp = 120,
		rewardGold = 460,
		rewardScore = 3600,
	},
	{
		avatarId = "zhezhiguai",
		background = monsterBgList[2],
		hp = 43370,
		hpX = 0,
		hpY = 130,
		rewardStep = 10,
		rewardExp = 210,
		rewardGold = 890,
		rewardScore = 1850,
	},
	{
		avatarId = "hongguai",
		background = monsterBgList[3],
		hp = 16770,
		hpX = 0,
		hpY = 130,
		rewardStep = 10,
		rewardExp = 120,
		rewardGold = 480,
		rewardScore = 1900,
	},
	{
		avatarId = "yuguai_xiao",
		background = monsterBgList[3],
		hp = 17600,
		hpX = 0,
		hpY = 130,
		rewardStep = 10,
		rewardExp = 120,
		rewardGold = 490,
		rewardScore = 3900,
	},
	{
		avatarId = "yuguai_da",
		background = monsterBgList[3],
		hp = 50480,
		hpX = 0,
		hpY = 130,
		rewardStep = 10,
		rewardExp = 220,
		rewardGold = 950,
		rewardScore = 2000,
	},
	{
		avatarId = "zhimahu",
		background = monsterBgList[4],
		hp = 19320,
		hpX = 0,
		hpY = 130,
		rewardStep = 10,
		rewardExp = 130,
		rewardGold = 510,
		rewardScore = 2050,
	},
	{
		avatarId = "bianju_xiao",
		background = monsterBgList[4],
		hp = 20210,
		hpX = 0,
		hpY = 130,
		rewardStep = 10,
		rewardExp = 130,
		rewardGold = 520,
		rewardScore = 4200,
	},
	{
		avatarId = "bianju_da",
		background = monsterBgList[4],
		hp = 58130,
		hpX = 0,
		hpY = 130,
		rewardStep = 10,
		rewardExp = 240,
		rewardGold = 1010,
		rewardScore = 2150,
	},
	{
		avatarId = "cuimian",
		background = monsterBgList[5],
		hp = 22050,
		hpX = 0,
		hpY = 130,
		rewardStep = 10,
		rewardExp = 130,
		rewardGold = 540,
		rewardScore = 2200,
	},
	{
		avatarId = "zuantou_xiao",
		background = monsterBgList[5],
		hp = 23000,
		hpX = 0,
		hpY = 130,
		rewardStep = 10,
		rewardExp = 130,
		rewardGold = 550,
		rewardScore = 4500,
	},
	{
		avatarId = "zuantou_da",
		background = monsterBgList[5],
		hp = 66320,
		hpX = 0,
		hpY = 130,
		rewardStep = 10,
		rewardExp = 250,
		rewardGold = 1070,
		rewardScore = 2300,
	},
	{
		avatarId = "zoushenguai",
		background = monsterBgList[6],
		hp = 24960,
		hpX = 0,
		hpY = 130,
		rewardStep = 10,
		rewardExp = 140,
		rewardGold = 570,
		rewardScore = 2350,
	},
	{
		avatarId = "bianfuguai",
		background = monsterBgList[6],
		hp = 72080,
		hpX = 0,
		hpY = 130,
		rewardStep = 10,
		rewardExp = 260,
		rewardGold = 1110,
		rewardScore = 4800,
	},
	{
		avatarId = "shazhang",
		background = monsterBgList[1],
		hp = 27000,
		hpX = 0,
		hpY = 130,
		rewardStep = 10,
		rewardExp = 140,
		rewardGold = 590,
		rewardScore = 2450,
	},
	{
		avatarId = "ciliguai",
		background = monsterBgList[1],
		hp = 78080,
		hpX = 0,
		hpY = 130,
		rewardStep = 10,
		rewardExp = 260,
		rewardGold = 1150,
		rewardScore = 2500,
	},
	{
		avatarId = "fengguai",
		background = monsterBgList[2],
		hp = 29120,
		hpX = 0,
		hpY = 130,
		rewardStep = 10,
		rewardExp = 150,
		rewardGold = 610,
		rewardScore = 5100,
	},
	{
		avatarId = "niangniangguai",
		background = monsterBgList[2],
		hp = 84320,
		hpX = 0,
		hpY = 130,
		rewardStep = 10,
		rewardExp = 270,
		rewardGold = 1190,
		rewardScore = 2600,
	},
	{
		avatarId = "shayu_xiao",
		background = monsterBgList[3],
		hp = 31320,
		hpX = 0,
		hpY = 130,
		rewardStep = 10,
		rewardExp = 150,
		rewardGold = 630,
		rewardScore = 2650,
	},
	{
		avatarId = "shayu_da",
		background = monsterBgList[3],
		hp = 90800,
		hpX = 0,
		hpY = 130,
		rewardStep = 10,
		rewardExp = 280,
		rewardGold = 1230,
		rewardScore = 5400,
	},
	{
		avatarId = "niuguai",
		background = monsterBgList[4],
		hp = 94130,
		hpX = 0,
		hpY = 130,
		rewardStep = 10,
		rewardExp = 280,
		rewardGold = 1250,
		rewardScore = 2750,
	},
	{
		avatarId = "jianzhujixie",
		background = monsterBgList[4],
		hp = 97520,
		hpX = 0,
		hpY = 130,
		rewardStep = 10,
		rewardExp = 290,
		rewardGold = 1270,
		rewardScore = 2800,
	},
	{
		avatarId = "juxiguai",
		background = monsterBgList[4],
		hp = 136900,
		hpX = 0,
		hpY = 130,
		rewardStep = 10,
		rewardExp = 430,
		rewardGold = 1630,
		rewardScore = 5700,
	},
	{
		avatarId = "hongwaixian",
		background = monsterBgList[5],
		hp = 141620,
		hpX = 0,
		hpY = 130,
		rewardStep = 10,
		rewardExp = 430,
		rewardGold = 1650,
		rewardScore = 2900,
	},
	{
		avatarId = "sanggou",
		background = monsterBgList[5],
		hp = 146420,
		hpX = 0,
		hpY = 130,
		rewardStep = 10,
		rewardExp = 440,
		rewardGold = 1680,
		rewardScore = 2950,
	},
	{
		avatarId = "paotai",
		background = monsterBgList[5],
		hp = 151300,
		hpX = 0,
		hpY = 130,
		rewardStep = 10,
		rewardExp = 440,
		rewardGold = 1700,
		rewardScore = 6000,
	},

}
GameConfig.monsterList = monsterList

GameConfig.singular =
{
	[1] = {0, 1},
	[2] = {1, 0},
	[3] = {1, -1},
	[4] = {0, -1},
	[5] = {-1, -1},
	[6] = {-1, 0},
}
GameConfig.even =
{
	[1] = {0, 1},
	[2] = {1, 1},
	[3] = {1, 0},
	[4] = {0, -1},
	[5] = {-1, 0},
	[6] = {-1, 1},
}
GameConfig.singularBombRoundOffs = {
	[1]	=	{
		["offR"]	=	-1,
		["offC"]	=	-2
	},
	[2]	=	{
		["offR"]	=	0,
		["offC"]	=	-2
	},
	[3]	=	{
		["offR"]	=	1,
		["offC"]	=	-2
	},
	[4]	=	{
		["offR"]	=	-2,
		["offC"]	=	-1
	},
	[5]	=	{
		["offR"]	=	-1,
		["offC"]	=	-1
	},
	[6]	=	{
		["offR"]	=	0,
		["offC"]	=	-1
	},
	[7]	=	{
		["offR"]	=	1,
		["offC"]	=	-1
	},
	[8]	=	{
		["offR"]	=	-2,
		["offC"]	=	0
	},
	[9]	=	{
		["offR"]	=	-1,
		["offC"]	=	0
	},
	[10]	=	{
		["offR"]	=	0,
		["offC"]	=	0
	},
	[11]	=	{
		["offR"]	=	1,
		["offC"]	=	0
	},
	[12]	=	{
		["offR"]	=	2,
		["offC"]	=	0
	},
	[13]	=	{
		["offR"]	=	-2,
		["offC"]	=	1
	},
	[14]	=	{
		["offR"]	=	-1,
		["offC"]	=	1
	},
	[15]	=	{
		["offR"]	=	0,
		["offC"]	=	1
	},
	[16]	=	{
		["offR"]	=	1,
		["offC"]	=	1
	},
	[17]	=	{
		["offR"]	=	-1,
		["offC"]	=	2
	},
	[18]	=	{
		["offR"]	=	0,
		["offC"]	=	2
	},
	[19]	=	{
		["offR"]	=	1,
		["offC"]	=	2
	}
}
GameConfig.evenBombRoundOffs = {
	[1]	=	{
		["offR"]	=	-1,
		["offC"]	=	-2
	},
	[2]	=	{
		["offR"]	=	0,
		["offC"]	=	-2
	},
	[3]	=	{
		["offR"]	=	1,
		["offC"]	=	-2
	},
	[4]	=	{
		["offR"]	=	-1,
		["offC"]	=	-1
	},
	[5]	=	{
		["offR"]	=	0,
		["offC"]	=	-1
	},
	[6]	=	{
		["offR"]	=	1,
		["offC"]	=	-1
	},
	[7]	=	{
		["offR"]	=	2,
		["offC"]	=	-1
	},
	[8]	=	{
		["offR"]	=	-2,
		["offC"]	=	0
	},
	[9]	=	{
		["offR"]	=	-1,
		["offC"]	=	0
	},
	[10]	=	{
		["offR"]	=	0,
		["offC"]	=	0
	},
	[11]	=	{
		["offR"]	=	1,
		["offC"]	=	0
	},
	[12]	=	{
		["offR"]	=	2,
		["offC"]	=	0
	},
	[13]	=	{
		["offR"]	=	-1,
		["offC"]	=	1
	},
	[14]	=	{
		["offR"]	=	0,
		["offC"]	=	1
	},
	[15]	=	{
		["offR"]	=	1,
		["offC"]	=	1
	},
	[16]	=	{
		["offR"]	=	2,
		["offC"]	=	1
	},
	[17]	=	{
		["offR"]	=	-1,
		["offC"]	=	2
	},
	[18]	=	{
		["offR"]	=	0,
		["offC"]	=	2
	},
	[19]	=	{
		["offR"]	=	1,
		["offC"]	=	2
	}
}

function GameConfig:getMonster(index)
	if not self.monsterList[index] then
		return nil
	end

	return self.monsterList[index]
end

function GameConfig:getRewardStep(index)
	if not self.monsterList[index] then
		return 0
	end

	return self.monsterList[index].rewardStep or 0
end

function GameConfig:getRewardScore(index)
	if not self.monsterList[index] then
		return 0
	end

	return self.monsterList[index].rewardScore or 0
end

function GameConfig:getRewardExp(index)
	if not self.monsterList[index] then
		return 0
	end

	return self.monsterList[index].rewardExp or 0
end

function GameConfig:getRewardGold(index)
	if not self.monsterList[index] then
		return 0
	end

	return self.monsterList[index].rewardGold or 0
end

function GameConfig:getAttackAdditionByLinkNum(num)
	local curAttackDamage = 0
	for i = 1, num do
		if self.linkNum2AttackAddition[i] then
			curAttackDamage = self.linkNum2AttackAddition[i]
		end
	end

	return curAttackDamage
end

return GameConfig

