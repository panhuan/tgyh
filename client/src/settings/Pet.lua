
local Pet =
{
	-- 宠物根据玩家级别自动解锁要求
	PetUnLockByLevel =
	{
		[1] = {level = 1},
		[2] = {level = 3},
		[3] = {level = 7},
		[4] = {level = 13},
		[5] = {level = 20},
	},

	-- 宠物解锁要求
	PetUnLock =
	{
		[1] = {money = 0, gold = 0, level = 0},
		[2] = {money = 0, gold = 0, level = 0},
		[3] = {money = 100, gold = 0, level = 0},
		[4] = {money = 120, gold = 0, level = 0},
		[5] = {money = 360, gold = 0, level = 0},
	},

	-- 宠物升级要求
	PetUpdate =
	{
		[1] =
		{
          {money = 0,gold = 125,level = 1},
          {money = 0,gold = 220,level = 1},
          {money = 0,gold = 415,level = 1},
          {money = 0,gold = 740,level = 1},
          {money = 0,gold = 1225,level = 1},
          {money = 0,gold = 1900,level = 1},
          {money = 0,gold = 2795,level = 1},
          {money = 0,gold = 3940,level = 1},
          {money = 0,gold = 5365,level = 1},
          {money = 0,gold = 7100,level = 1},
          {money = 0,gold = 9175,level = 1},
          {money = 0,gold = 11620,level = 1},
          {money = 0,gold = 14465,level = 1},
          {money = 0,gold = 17740,level = 1},
          {money = 0,gold = 21475,level = 1},
          {money = 0,gold = 25700,level = 1},
          {money = 0,gold = 30445,level = 1},
          {money = 0,gold = 35740,level = 1},
          {money = 0,gold = 41615,level = 1},
          {money = 0,gold = 48100,level = 1},
          {money = 0,gold = 55225,level = 1},
          {money = 0,gold = 63020,level = 1},
          {money = 0,gold = 71515,level = 1},
          {money = 0,gold = 80740,level = 1},
          {money = 0,gold = 90725,level = 1},
          {money = 0,gold = 101500,level = 1},
          {money = 0,gold = 113095,level = 1},
          {money = 0,gold = 125540,level = 1},
          {money = 0,gold = 138865,level = 1},
          {money = 0,gold = 153100,level = 1},

		},
		[2] =
		{
          {money = 0,gold = 125,level = 1},
          {money = 0,gold = 220,level = 1},
          {money = 0,gold = 415,level = 1},
          {money = 0,gold = 740,level = 1},
          {money = 0,gold = 1225,level = 1},
          {money = 0,gold = 1900,level = 1},
          {money = 0,gold = 2795,level = 1},
          {money = 0,gold = 3940,level = 1},
          {money = 0,gold = 5365,level = 1},
          {money = 0,gold = 7100,level = 1},
          {money = 0,gold = 9175,level = 1},
          {money = 0,gold = 11620,level = 1},
          {money = 0,gold = 14465,level = 1},
          {money = 0,gold = 17740,level = 1},
          {money = 0,gold = 21475,level = 1},
          {money = 0,gold = 25700,level = 1},
          {money = 0,gold = 30445,level = 1},
          {money = 0,gold = 35740,level = 1},
          {money = 0,gold = 41615,level = 1},
          {money = 0,gold = 48100,level = 1},
          {money = 0,gold = 55225,level = 1},
          {money = 0,gold = 63020,level = 1},
          {money = 0,gold = 71515,level = 1},
          {money = 0,gold = 80740,level = 1},
          {money = 0,gold = 90725,level = 1},
          {money = 0,gold = 101500,level = 1},
          {money = 0,gold = 113095,level = 1},
          {money = 0,gold = 125540,level = 1},
          {money = 0,gold = 138865,level = 1},
          {money = 0,gold = 153100,level = 1},

		},
		[3] =
		{
          {money = 0,gold = 125,level = 1},
          {money = 0,gold = 220,level = 1},
          {money = 0,gold = 415,level = 1},
          {money = 0,gold = 740,level = 1},
          {money = 0,gold = 1225,level = 1},
          {money = 0,gold = 1900,level = 1},
          {money = 0,gold = 2795,level = 1},
          {money = 0,gold = 3940,level = 1},
          {money = 0,gold = 5365,level = 1},
          {money = 0,gold = 7100,level = 1},
          {money = 0,gold = 9175,level = 1},
          {money = 0,gold = 11620,level = 1},
          {money = 0,gold = 14465,level = 1},
          {money = 0,gold = 17740,level = 1},
          {money = 0,gold = 21475,level = 1},
          {money = 0,gold = 25700,level = 1},
          {money = 0,gold = 30445,level = 1},
          {money = 0,gold = 35740,level = 1},
          {money = 0,gold = 41615,level = 1},
          {money = 0,gold = 48100,level = 1},
          {money = 0,gold = 55225,level = 1},
          {money = 0,gold = 63020,level = 1},
          {money = 0,gold = 71515,level = 1},
          {money = 0,gold = 80740,level = 1},
          {money = 0,gold = 90725,level = 1},
          {money = 0,gold = 101500,level = 1},
          {money = 0,gold = 113095,level = 1},
          {money = 0,gold = 125540,level = 1},
          {money = 0,gold = 138865,level = 1},
          {money = 0,gold = 153100,level = 1},

		},
		[4] =
		{
		  {money = 0,gold = 125,level = 1},
          {money = 0,gold = 220,level = 1},
          {money = 0,gold = 415,level = 1},
          {money = 0,gold = 740,level = 1},
          {money = 0,gold = 1225,level = 1},
          {money = 0,gold = 1900,level = 1},
          {money = 0,gold = 2795,level = 1},
          {money = 0,gold = 3940,level = 1},
          {money = 0,gold = 5365,level = 1},
          {money = 0,gold = 7100,level = 1},
          {money = 0,gold = 9175,level = 1},
          {money = 0,gold = 11620,level = 1},
          {money = 0,gold = 14465,level = 1},
          {money = 0,gold = 17740,level = 1},
          {money = 0,gold = 21475,level = 1},
          {money = 0,gold = 25700,level = 1},
          {money = 0,gold = 30445,level = 1},
          {money = 0,gold = 35740,level = 1},
          {money = 0,gold = 41615,level = 1},
          {money = 0,gold = 48100,level = 1},
          {money = 0,gold = 55225,level = 1},
          {money = 0,gold = 63020,level = 1},
          {money = 0,gold = 71515,level = 1},
          {money = 0,gold = 80740,level = 1},
          {money = 0,gold = 90725,level = 1},
          {money = 0,gold = 101500,level = 1},
          {money = 0,gold = 113095,level = 1},
          {money = 0,gold = 125540,level = 1},
          {money = 0,gold = 138865,level = 1},
          {money = 0,gold = 153100,level = 1},

		},
		[5] =
		{
          {money = 0,gold = 125,level = 1},
          {money = 0,gold = 220,level = 1},
          {money = 0,gold = 415,level = 1},
          {money = 0,gold = 740,level = 1},
          {money = 0,gold = 1225,level = 1},
          {money = 0,gold = 1900,level = 1},
          {money = 0,gold = 2795,level = 1},
          {money = 0,gold = 3940,level = 1},
          {money = 0,gold = 5365,level = 1},
          {money = 0,gold = 7100,level = 1},
          {money = 0,gold = 9175,level = 1},
          {money = 0,gold = 11620,level = 1},
          {money = 0,gold = 14465,level = 1},
          {money = 0,gold = 17740,level = 1},
          {money = 0,gold = 21475,level = 1},
          {money = 0,gold = 25700,level = 1},
          {money = 0,gold = 30445,level = 1},
          {money = 0,gold = 35740,level = 1},
          {money = 0,gold = 41615,level = 1},
          {money = 0,gold = 48100,level = 1},
          {money = 0,gold = 55225,level = 1},
          {money = 0,gold = 63020,level = 1},
          {money = 0,gold = 71515,level = 1},
          {money = 0,gold = 80740,level = 1},
          {money = 0,gold = 90725,level = 1},
          {money = 0,gold = 101500,level = 1},
          {money = 0,gold = 113095,level = 1},
          {money = 0,gold = 125540,level = 1},
          {money = 0,gold = 138865,level = 1},
          {money = 0,gold = 153100,level = 1},

		},
	},

	-- 宠物攻击力
	PetAttack =
	{
		--1、开心   2、花心  3、甜心   4、粗心   5、小心
		[1] = {4,8,12,16,20,24,28,32,36,40,44,48,52,56,60,64,68,72,76,80,84,88,92,96,100,104,108,112,116,120},
		[2] = {3,6,10,13,16,19,22,26,29,32,35,38,42,45,48,51,54,58,61,64,67,70,74,77,80,83,86,90,93,96},
		[3] = {2,5,7,10,12,14,17,19,22,24,26,29,31,34,36,38,41,43,46,48,50,53,55,58,60,62,65,67,70,72},
		[4] = {3,6,9,12,15,18,21,24,27,30,33,36,39,42,45,48,51,54,57,60,63,66,69,72,75,78,81,84,87,90},
		[5] = {3,7,10,14,17,20,24,27,31,34,37,41,44,48,51,54,58,61,65,68,71,75,78,82,85,88,92,95,99,102},

	},

	-- 宠物显示配置
	-- pic		在角色界面显示的宠物头像
	-- x, y		角色界面宠物头像的位置(pic的位置)
	-- normal	在宠物界面显示的角色形象
	-- robot	在宠物界面显示的机甲形象
	tbPetPic =
	{
		[1] =
		{
			[true] =
			{
				pic = "ui.atlas.png#kx_c.png",
			},
			[false] =
			{
				pic = "ui.atlas.png#kaixin_2.png",
			},
			x = -160,
			y = 20,
			pet = "pet/ui/kx_a.png",
			robot = "pet/ui/kx_b.png",

			pettitle = "ui.atlas.png#kaixinchaoren_title.png",
			pettext = "ui.atlas.png#kaixin_text.png",
			robottitle = "ui.atlas.png#kaixinrobot_title.png",
			robottext = "ui.atlas.png#kaixinrobot_text.png",
		},
		[2] =
		{
			[true] =
			{
				pic = "ui.atlas.png#hx_c.png",
			},
			[false] =
			{
				pic = "ui.atlas.png#huaxin_2.png",
			},
			x = 0,
			y = 20,
			pet = "pet/ui/hx_a.png",
			robot = "pet/ui/hx_b.png",

			pettitle = "ui.atlas.png#huaxinchaoren_title.png",
			pettext = "ui.atlas.png#huaxin_text.png",
			robottitle = "ui.atlas.png#huaxinrobot_title.png",
			robottext = "ui.atlas.png#huaxinrobot_text.png",
		},
		[3] =
		{
			[true] =
			{
				pic = "ui.atlas.png#tx_c.png",
			},
			[false] =
			{
				pic = "ui.atlas.png#tianxin_2.png",
			},
			x = 160,
			y = 20,
			pet = "pet/ui/tx_a.png",
			robot = "pet/ui/tx_b.png",

			pettitle = "ui.atlas.png#tianxinchaoren_title.png",
			pettext = "ui.atlas.png#tianxin_text.png",
			robottitle = "ui.atlas.png#tianxinrobot_title.png",
			robottext = "ui.atlas.png#tianxinrobot_text.png",
		},
		[4] =
		{
			[true] =
			{
				pic = "ui.atlas.png#cx_c.png",
			},
			[false] =
			{
				pic = "ui.atlas.png#cuxin_2.png",
			},
			x = -90,
			y = -180,
			pet = "pet/ui/cx_a.png",
			robot = "pet/ui/cx_b.png",

			pettitle = "ui.atlas.png#cuxinchaoren_title.png",
			pettext = "ui.atlas.png#cuxin_text.png",
			robottitle = "ui.atlas.png#cuxinrobot_title.png",
			robottext = "ui.atlas.png#cuxinrobot_text.png",
		},
		[5] =
		{
			[true] =
			{
				pic = "ui.atlas.png#xx_c.png",
			},
			[false] =
			{
				pic = "ui.atlas.png#xiaoxin_2.png",
			},
			x = 90,
			y = -180,
			pet = "pet/ui/xx_a.png",
			robot = "pet/ui/xx_b.png",

			pettitle = "ui.atlas.png#xiaoxinchaoren_title.png",
			pettext = "ui.atlas.png#xiaoxin_text.png",
			robottitle = "ui.atlas.png#xiaoxinrobot_title.png",
			robottext = "ui.atlas.png#xiaoxinrobot_text.png",
		},
	},

	-- 宠物列表
	petList =
	{
		-- 超人supperPowerType不应该相同,如有相同需要,请联系18627968484
		["default"] =
		{
			supperPowerSteps = 5,
			avatars =
			{
				[3] = "default_hero",--default_hero
				--[6] = "kaixin_jijia",
			},
		},
		[1] =
		{
			supperPowerSteps = 5,
			avatars =
			{
				[3] = "kaixin_man",
				-- [6] = "kaixin_robot",
			},
		},
		[2] =
		{
			supperPowerSteps = 7,
			supperPowerType = "bombColor",
			supperPowerArgs = {},
			avatars =
			{
				[3] = "huaxin_man",
				-- [6] = "huaxin_robot",
			},
		},
		[3] =
		{
			supperPowerSteps = 4,
			supperPowerType = "rewardStep",
			supperPowerArgs = {5},
			avatars =
			{
				[3] = "tianxin_man",
				-- [6] = "tianxin_robot",
			},
		},
		[4] =
		{
			supperPowerSteps = 6,
			supperPowerType = "bombRound",
			supperPowerArgs = {2},
			avatars =
			{
				[3] = "cuxin_man",
				-- [6] = "cuxin_robot",
			},
		},
		[5] =
		{
			supperPowerSteps = 5,
			supperPowerType = "bombLine",
			supperPowerArgs = {{7,7,7,7,7,7}},
			avatars =
			{
				[3] = "xiaoxin_man",
				-- [6] = "xiaoxin_robot",
			},
		},
	},
}

function Pet:GetPetUnlock(petIdx)
	assert(petIdx >= 1 and petIdx <= PET_COUNT, "wrong petIdx: "..petIdx)
	return self.PetUnLock[petIdx]
end

function Pet:GetPetUpdate(petIdx, level)
	assert(petIdx >= 1 and petIdx <= PET_COUNT, "wrong petIdx: "..petIdx)
	if level > PET_MAX_LEVEL then
		return nil
	end
	return self.PetUpdate[petIdx][level]
end

function Pet:GetPetUnlockByLevel(petIdx)
	assert(petIdx >= 1 and petIdx <= PET_COUNT, "wrong petIdx: "..petIdx)
	return self.PetUnLockByLevel[petIdx].level
end

function Pet:getPet(ballId)
	if not self.petList[ballId] then
		print("[ERR] no such pet by ballId", ballId)
		return
	end

	return self.petList[ballId]
end

function Pet:getSupperPowerArgsByType(value)
	for key, var in ipairs(self.petList) do
		if value == var.supperPowerType then
			return var.supperPowerArgs
		end
	end
	return nil
end

return Pet

