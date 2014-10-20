
local AvatarConfig =
{
	avatarlist =
	{
		["default_hero"] =
		{
			image = "pet/zhaiboshi.atlas.png#zhaiboshi_idle",
			attackImage = "zhaiboshi_attack",
			attackType = "shoot",
			bulletImage = {
				"pet/zhaiboshi.atlas.png#laohuoqian.png",
				"pet/zhaiboshi.atlas.png#banshou.png",
				"pet/zhaiboshi.atlas.png#luosidao.png",
				"pet/zhaiboshi.atlas.png#langtou.png",
			},
			bulletRot = 360,
			shootDelay = 0.2,
			impactFX = "pet/zhaiboshi.atlas.png#muzzle",
			muzzleDelay = 8/30,
			x = -180,
			y = -120,
			hpX = 0,
			hpY = 110,
		},
		["kaixin_man"] =
		{
			image = "pet/kaixin_man.atlas.png#kaixin_idle",
			attackImage = "kaixin_attack",
			attackType = "rush",
			impactFX = "pet/kaixin_man.atlas.png#impact_02",
			muzzleFX = "pet/kaixin_man.atlas.png#muzzle_01?loc=20,-20&loop=true",
			muzzleX = 30,
			muzzleY = -20,
			muzzleDelay = 10/30,
			x = -180,
			y = -120,
		},
		["cuxin_man"] =
		{
			image = "pet/cuxin_man.atlas.png#cuxin_idle",
			attackImage = "cuxin_attack",
			attackY = 20,
			attackType = "bezier",
			bulletImage = "pet/cuxin_man.atlas.png#bullet?loop=0.099",
			muzzleFX = "pet/cuxin_man.atlas.png#muzzle",
			impactFX = "pet/cuxin_man.atlas.png#impact_04",
			bulletX = 100,
			bulletY = 0,
			bulletSpeed = 1,
			shootDelay = 0.5,
			x = -180,
			y = -120,
		},
		["huaxin_man"] =
		{
			image = "pet/huaxin_man.atlas.png#huaxin_idle",
			attackImage = "huaxin_attack",
			attackType = "laser",
			bulletImage = "pet/huaxin_man.atlas.png#laser_01?loop=true&scl=1.5",
			bulletX = 325,
			bulletY = -15,
			shootCount = 8,
			shootDelay = 0.5,
			laserDuration = 1,
			muzzleFX = "pet/huaxin_man.atlas.png#muzzle",
			impactFX = "pet/huaxin_man.atlas.png#impact_01",
			x = -180,
			y = -120,
		},
		["tianxin_man"] =
		{
			image = "pet/tianxin_man.atlas.png#tianxin_idle",
			attackImage = "tianxin_attack",
			attackLoop = 6/30,
			attackType = "shoot",
			bulletImage = "pet/tianxin_man.atlas.png#bullet?loop=0.099",
			muzzleFX = "pet/tianxin_man.atlas.png#muzzle",
			impactFX = "pet/tianxin_man.atlas.png#impact",
			x = -180,
			y = -120,
		},
		["xiaoxin_man"] =
		{
			image = "pet/xiaoxin_man.atlas.png#xiaoxin_idle",
			attackImage = "xiaoxin_attack",
			attackType = "rush",
			muzzleFX = "pet/xiaoxin_man.atlas.png#muzzle?destroy=false",
			impactFX = "pet/xiaoxin_man.atlas.png#impact",
			muzzleDelay = 10/30,
			rushCount = 4,
			rushCountDelay = 0.18,
			rushAlpha = 1000,
			x = -180,
			y = -120,
		},
		["kaixin_robot"] =
		{
			image = "pet/kaixin_robot.atlas.png#kaixinrobot_idle",
			attackImage = "kaixinrobot_attack",
			attackType = "rush",
			shootCount = 8,
			muzzleFX = "pet/kaixin_robot.atlas.png#muzzle_01?loop=true&scl=2&loc=120,0",
			impactFX = "pet/kaixin_robot.atlas.png#impact?scl=2&loc=50",
			muzzleDelay = 15/30,
			rushDelay = 6/30,
			rushStay = 0.1,
			impactDelay = -0.2,
			x = -160,
			y = -70,
		},
		["cuxin_robot"] =
		{
			image = "pet/cuxin_robot.atlas.png#cuxinrobot_idle",
			attackImage = "cuxinrobot_attack",
			attackType = "bezier",
			shootCount = 16,
			bulletImage = "pet/cuxin_man.atlas.png#bullet?scl=1.5&loop=0.099",
			muzzleFX = "pet/cuxin_man.atlas.png#muzzle?scl=2",
			impactFX = "pet/cuxin_man.atlas.png#impact_04?scl=2",
			shootDelay = 0.5,
			bulletSpeed = 1,
			x = -160,
			y = -70,
		},
		["huaxin_robot"] =
		{
			image = "pet/huaxin_robot.atlas.png#huaxinrobot_idle",
			attackImage = "huaxinrobot_attack",
			attackX = -75,
			attackType = "laser",
			shootCount = 8,
			bulletImage = "pet/huaxin_robot.atlas.png#laser?scl=2",
			bulletX = 900,
			bulletY = 30,
			impactFX = "pet/huaxin_robot.atlas.png#impact_03",
			x = -160,
			y = -70,
		},
		["tianxin_robot"] =
		{
			image = "pet/tianxin_robot.atlas.png#tianxinrobot_idle",
			attackImage = "tianxinrobot_attack",
			attackType = "penetrate",
			shootCount = 16,
			bulletImage = "pet/tianxin_man.atlas.png#bullet?scl=1.5&loop=0.099",
			muzzleFX = "pet/tianxin_man.atlas.png#muzzle",
			impactFX = "pet/tianxin_robot.atlas.png#impact_03",
			shootDelay = 0.5,
			x = -160,
			y = -70,
		},
		["xiaoxin_robot"] =
		{
			image = "pet/xiaoxin_robot.atlas.png#xiaoxinrobot_idle",
			attackImage = "xiaoxinrobot_attack",
			attackType = "rush",
			shootCount = 6,
			rushStay = 0.2,
			muzzleDelay = 18/30,
			muzzleFX = "pet/xiaoxin_robot.atlas.png#muzzle_03",
			impactFX = "pet/xiaoxin_robot.atlas.png#impact_03",
			rushCount = 6,
			rushCountDelay = 0.1,
			rushAlpha = 10,
			x = -160,
			y = -10,
		},
		["hongwaixian"] =
		{
			idlImage = "monster/hongwaixianguai.fla.png#idl",
			hitImage = "monster/hongwaixianguai.fla.png#hit",
			x = 30,
			y = 30,
			w = 240,
			h = 220,
			skills =
			{
				["changeball"] = {percent=0, minNum=1, maxNum=3},
				["removeball"] = {percent=30, minNum=1, maxNum=3},
			},
		},
		["ciliguai"] =
		{
			idlImage = "monster/chiliguai.fla.png#idl",
			hitImage = "monster/chiliguai.fla.png#hit",
			x = 60,
			y = 30,
			w = 200,
			h = 220,
			skills =
			{
				["changeball"] = {percent=0, minNum=1, maxNum=3},
				["removeball"] = {percent=30, minNum=1, maxNum=3},
			},
		},
		["bianfuguai"] =
		{
			idlImage = "monster/bianfuguai.fla.png#idl",
			hitImage = "monster/bianfuguai.fla.png#hit",
			x = -40,
			y = 30,
			w = 360,
			h = 220,
			skills =
			{
				["changeball"] = {percent=0, minNum=1, maxNum=3},
				["removeball"] = {percent=30, minNum=1, maxNum=3},
			},
		},
		["bianju_da"] =
		{
			idlImage = "monster/bianjuguai_da.fla.png#idl",
			hitImage = "monster/bianjuguai_da.fla.png#hit",
			x = 60,
			y = 30,
			w = 200,
			h = 220,
			skills =
			{
				["changeball"] = {percent=30, minNum=1, maxNum=3},
				["removeball"] = {percent=0, minNum=1, maxNum=3},
			},
		},
		["zuantou_xiao"] =
		{
			idlImage = "monster/zuantouguai_xiao.fla.png#idl",
			hitImage = "monster/zuantouguai_xiao.fla.png#hit",
			x = 100,
			y = -55,
			w = 140,
			h = 160,
			skills =
			{
				["changeball"] = {percent=30, minNum=1, maxNum=3},
				["removeball"] = {percent=0, minNum=1, maxNum=3},
			},
		},
		["zoushenguai"] =
		{
			idlImage = "monster/zoushenguai.fla.png#idl",
			hitImage = "monster/zoushenguai.fla.png#hit",
			x = 100,
			y = -55,
			w = 170,
			h = 180,
			skills =
			{
				["changeball"] = {percent=30, minNum=1, maxNum=3},
				["removeball"] = {percent=0, minNum=1, maxNum=3},
			},
		},
		["lvguai"] =
		{
			idlImage = "monster/lvguai.fla.png#idl",
			hitImage = "monster/lvguai.fla.png#hit",
			x = 100,
			y = -55,
			w = 120,
			h = 160,
			skills =
			{
				["changeball"] = {percent=30, minNum=1, maxNum=3},
				["removeball"] = {percent=0, minNum=1, maxNum=3},
			},
		},
		["huiguai"] =
		{
			idlImage = "monster/huiguai.fla.png#idl",
			hitImage = "monster/huiguai.fla.png#hit",
			x = 100,
			y = -50,
			w = 150,
			h = 160,
			skills =
			{
				["changeball"] = {percent=30, minNum=1, maxNum=3},
				["removeball"] = {percent=0, minNum=1, maxNum=3},
			},
		},
		["hongguai"] =
		{
			idlImage = "monster/hongguai.fla.png#idl",
			hitImage = "monster/hongguai.fla.png#hit",
			x = 100,
			y = -55,
			w = 130,
			h = 160,
			skills =
			{
				["changeball"] = {percent=30, minNum=1, maxNum=3},
				["removeball"] = {percent=0, minNum=1, maxNum=3},
			},
		},
		["zhimahu"] =
		{
			idlImage = "monster/zhimahu.fla.png#idl",
			hitImage = "monster/zhimahu.fla.png#hit",
			x = 100,
			y = -55,
			w = 130,
			h = 160,
			skills =
			{
				["changeball"] = {percent=30, minNum=1, maxNum=3},
				["removeball"] = {percent=0, minNum=1, maxNum=3},
			},
		},
		["yuguai_xiao"] =
		{
			idlImage = "monster/yuguai_xiao.fla.png#idl",
			hitImage = "monster/yuguai_xiao.fla.png#hit",
			x = 100,
			y = -55,
			w = 140,
			h = 160,
			skills =
			{
				["changeball"] = {percent=30, minNum=1, maxNum=3},
				["removeball"] = {percent=0, minNum=1, maxNum=3},
			},
		},
		["fengguai"] =
		{
			idlImage = "monster/fengguai.fla.png#idl",
			hitImage = "monster/fengguai.fla.png#hit",
			x = 100,
			y = -50,
			w = 130,
			h = 165,
			skills =
			{
				["changeball"] = {percent=0, minNum=1, maxNum=3},
				["removeball"] = {percent=30, minNum=1, maxNum=3},
			},
		},
		["shazhang"] =
		{
			idlImage = "monster/tieshazhangguai.fla.png#idl",
			hitImage = "monster/tieshazhangguai.fla.png#hit",
			x = 100,
			y = -50,
			w = 130,
			h = 160,
			skills =
			{
				["changeball"] = {percent=0, minNum=1, maxNum=3},
				["removeball"] = {percent=30, minNum=1, maxNum=3},
			},
		},
		["shayu_xiao"] =
		{
			idlImage = "monster/shayuguai_xiao.fla.png#idl",
			hitImage = "monster/shayuguai_xiao.fla.png#hit",
			x = 80,
			y = -30,
			w = 180,
			h = 160,
			skills =
			{
				["changeball"] = {percent=0, minNum=1, maxNum=3},
				["removeball"] = {percent=30, minNum=1, maxNum=3},
			},
		},
		["qie"] =
		{
			idlImage = "monster/qieguai.fla.png#idl",
			hitImage = "monster/qieguai.fla.png#hit",
			x = 100,
			y = -58,
			w = 170,
			h = 160,
			skills =
			{
				["changeball"] = {percent=30, minNum=1, maxNum=3},
				["removeball"] = {percent=0, minNum=1, maxNum=3},
			},
		},
		["konglongmei"] =
		{
			idlImage = "monster/konglongmei.fla.png#idl",
			hitImage = "monster/konglongmei.fla.png#hit",
			x = 100,
			y = -50,
			w = 150,
			h = 160,
			skills =
			{
				["changeball"] = {percent=30, minNum=1, maxNum=3},
				["removeball"] = {percent=0, minNum=1, maxNum=3},
			},
		},
		["cuimian"] =
		{
			idlImage = "monster/cuimianguai.fla.png#idl",
			hitImage = "monster/cuimianguai.fla.png#hit",
			x = 100,
			y = -55,
			w = 150,
			h = 160,
			skills =
			{
				["changeball"] = {percent=30, minNum=1, maxNum=3},
				["removeball"] = {percent=0, minNum=1, maxNum=3},
			},
		},
		["bianju_xiao"] =
		{
			idlImage = "monster/bianjuguai_xiao.fla.png#idl",
			hitImage = "monster/bianjuguai_xiao.fla.png#hit",
			x = 100,
			y = -55,
			w = 130,
			h = 160,
			skills =
			{
				["changeball"] = {percent=30, minNum=1, maxNum=3},
				["removeball"] = {percent=0, minNum=1, maxNum=3},
			},
		},

		["bibilong_xiao"] =
		{
			idlImage = "monster/bibilong.fla.png#idl",
			hitImage = "monster/bibilong.fla.png#hit",
			x = 100,
			y = -60,
			w = 130,
			h = 160,
			skills =
			{
				["changeball"] = {percent=30, minNum=1, maxNum=3},
				["removeball"] = {percent=0, minNum=1, maxNum=3},
			},
		},
		["sanggou"] =
		{
			idlImage = "monster/sanggou.fla.png#idl",
			hitImage = "monster/sanggou.fla.png#hit",
			x = 20,
			y = 28,
			w = 270,
			h = 220,
			skills =
			{
				["changeball"] = {percent=0, minNum=1, maxNum=3},
				["removeball"] = {percent=30, minNum=1, maxNum=3},
			},
		},
		["bibilong_da"] =
		{
			idlImage = "monster/bibilong_da.fla.png#idl",
			hitImage = "monster/bibilong_da.fla.png#hit",
			x = 100,
			y = 30,
			w = 180,
			h = 220,
			skills =
			{
				["changeball"] = {percent=30, minNum=1, maxNum=3},
				["removeball"] = {percent=0, minNum=1, maxNum=3},
			},
		},

		["zuantou_da"] =
		{
			idlImage = "monster/zuantouguai_da.fla.png#idl",
			hitImage = "monster/zuantouguai_da.fla.png#hit",
			x = 0,
			y = 28,
			w = 280,
			h = 220,
			skills =
			{
				["changeball"] = {percent=0, minNum=1, maxNum=3},
				["removeball"] = {percent=30, minNum=1, maxNum=3},
			},
		},
		["zhezhiguai"] =
		{
			idlImage = "monster/zhezhiguai.fla.png#idl",
			hitImage = "monster/zhezhiguai.fla.png#hit",
			x = 100,
			y = 30,
			w = 180,
			h = 220,
			skills =
			{
				["changeball"] = {percent=0, minNum=1, maxNum=3},
				["removeball"] = {percent=30, minNum=1, maxNum=3},
			},
		},
		["paotai"] =
		{
			idlImage = "monster/zhazhapaotaijixieguai.fla.png#idl",
			hitImage = "monster/zhazhapaotaijixieguai.fla.png#hit",
			x = 40,
			y = 30,
			w = 180,
			h = 220,
			skills =
			{
				["changeball"] = {percent=0, minNum=1, maxNum=3},
				["removeball"] = {percent=30, minNum=1, maxNum=3},
			},
		},

		["yuguai_da"] =
		{
			idlImage = "monster/yuguai_da.fla.png#idl",
			hitImage = "monster/yuguai_da.fla.png#hit",
			x = 50,
			y = 30,
			w = 240,
			h = 220,
			skills =
			{
				["changeball"] = {percent=30, minNum=1, maxNum=3},
				["removeball"] = {percent=0, minNum=1, maxNum=3},
			},
		},
		["shayu_da"] =
		{
			idlImage = "monster/shayuguai_da.fla.png#idl",
			hitImage = "monster/shayuguai_da.fla.png#hit",
			x = 0,
			y = 30,
			w = 300,
			h = 220,
			skills =
			{
				["changeball"] = {percent=0, minNum=1, maxNum=3},
				["removeball"] = {percent=30, minNum=1, maxNum=3},
			},
		},
		["niuguai"] =
		{
			idlImage = "monster/niuguai.fla.png#idl",
			hitImage = "monster/niuguai.fla.png#hit",
			x = 30,
			y = 30,
			w = 250,
			h = 220,
			skills =
			{
				["changeball"] = {percent=0, minNum=1, maxNum=3},
				["removeball"] = {percent=30, minNum=1, maxNum=3},
			},
		},

		["niangniangguai"] =
		{
			idlImage = "monster/niangniangguai.fla.png#idl",
			hitImage = "monster/niangniangguai.fla.png#hit",
			x = 60,
			y = 30,
			w = 180,
			h = 220,
			skills =
			{
				["changeball"] = {percent=30, minNum=1, maxNum=3},
				["removeball"] = {percent=0, minNum=1, maxNum=3},
			},
		},
		["juxiguai"] =
		{
			idlImage = "monster/juxiguai.fla.png#idl",
			hitImage = "monster/juxiguai.fla.png#hit",
			x = 20,
			y = 30,
			w = 280,
			h = 220,
			skills =
			{
				["changeball"] = {percent=0, minNum=1, maxNum=3},
				["removeball"] = {percent=30, minNum=1, maxNum=3},
			},
		},
		["jianzhujixie"] =
		{
			idlImage = "monster/jianzhujixieguai.fla.png#idl",
			hitImage = "monster/jianzhujixieguai.fla.png#hit",
			x = 20,
			y = 30,
			w = 260,
			h = 220,
			skills =
			{
				["changeball"] = {percent=0, minNum=1, maxNum=3},
				["removeball"] = {percent=30, minNum=1, maxNum=3},
			},
		},
	}
}

function AvatarConfig:getAvatar(id)
	if not self.avatarlist[id] then
		print("[ERR] error avatar id", id)
		return
	end

	return self.avatarlist[id]
end

function AvatarConfig:getAvatarLoc(id)
	local avatar = self:getAvatar(id)
	return avatar.x, avatar.y
end

function AvatarConfig:getAttackType(id)
	local avatar = self:getAvatar(id)
	return avatar.attackType
end

function AvatarConfig:getAttackImage(id)
	local avatar = self:getAvatar(id)
	return avatar.attackImage
end

function AvatarConfig:getAvatarSize(id)
	local avatar = self:getAvatar(id)
	return avatar.w, avatar.h
end

function AvatarConfig:getSkills(id)
	local avatar = self:getAvatar(id)
	return avatar.skills
end

return AvatarConfig
