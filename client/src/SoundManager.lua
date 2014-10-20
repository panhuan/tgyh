
local sound = require "sound"

local SoundManager = {}
function SoundManager:init()
	self.ballSelectSound = {}
	self.ballSelectSound[1] = sound.new ("select_1.ogg", false)
	self.ballSelectSound[2] = sound.new ("select_2.ogg", false)
	self.ballSelectSound[3] = sound.new ("select_3.ogg", false)
	self.ballSelectSound[4] = sound.new ("select_4.ogg", false)
	self.ballSelectSound[5] = sound.new ("select_5.ogg", false)
	self.ballSelectSound[6] = sound.new ("select_6.ogg", false)
	self.ballSelectSound[7] = sound.new ("select_7.ogg", false)
	self.ballSelectSound[8] = sound.new ("select_8.ogg", false)
	
	self.attackSound = 
	{
		["default_hero"] 	= sound.new ("zbs_attack.ogg", false),
		["kaixin_man"] 		= sound.new ("kx_attack.ogg", false),
		["huaxin_man"] 		= sound.new ("hx_attack.ogg", false),
		["tianxin_man"] 	= sound.new ("tx_attack.ogg", false),
		["cuxin_man"] 		= sound.new ("cx_attack.ogg", false),
		["xiaoxin_man"] 	= sound.new ("xx_attack.ogg", false),
		["kaixin_robot"] 	= sound.new ("kx_robot_attack.ogg", false),
		["huaxin_robot"] 	= sound.new ("hx_robot_attack.ogg", false),
		["tianxin_robot"] 	= sound.new ("tx_robot_attack.ogg", false),
		["cuxin_robot"] 	= sound.new ("cx_robot_attack.ogg", false),
		["xiaoxin_robot"] 	= sound.new ("xx_robot_attack.ogg", false),
	}
	
	self.impactSound = 
	{
		["default_hero"] 	= sound.new ("zbs_impact.ogg", false),
		["kaixin_man"] 		= sound.new ("kx_impact.ogg", false),
		["huaxin_man"] 		= sound.new ("hx_impact.ogg", false),
		["tianxin_man"] 	= sound.new ("tx_impact.ogg", false),
		["cuxin_man"] 		= sound.new ("cx_impact.ogg", false),
		["xiaoxin_man"] 	= sound.new ("xx_impact.ogg", false),
		["kaixin_robot"] 	= sound.new ("kx_robot_impact.ogg", false),
		["huaxin_robot"] 	= sound.new ("hx_robot_impact.ogg", false),
		["tianxin_robot"] 	= sound.new ("tx_robot_impact.ogg", false),
		["cuxin_robot"] 	= sound.new ("cx_robot_impact.ogg", false),
		["xiaoxin_robot"] 	= sound.new ("xx_robot_impact.ogg", false),
	}
	
	
	self.robotAttackVoice = 
	{
		["kaixin_robot"] 	= sound.new ("fight_kaixin.ogg", false),
		["huaxin_robot"] 	= sound.new ("fight_huaxin.ogg", false),
		["tianxin_robot"] 	= sound.new ("fight_tianxin.ogg", false),
		["cuxin_robot"] 	= sound.new ("fight_cuxin.ogg", false),
		["xiaoxin_robot"] 	= sound.new ("fight_xiaoxin.ogg", false),
	}
	
	self.heroNormalVoice = 
	{
		[1] = sound.new ("normal_kaixin.ogg", false),
		[2] = sound.new ("normal_huaxin.ogg", false),
		[3] = sound.new ("normal_tianxin.ogg", false),
		[4] = sound.new ("normal_cuxin.ogg", false),
		[5] = sound.new ("normal_xiaoxin.ogg", false),
	}
	
	self.ballBlastSound 		= sound.new("blast.ogg", false)
	self.monsterKickoutSound 	= sound.new("kickout.ogg", false)
	self.petHitSound 			= sound.new("hit_pet.ogg", false)
	self.weaponFlySound 		= sound.new("weapon_fly.ogg", false)
	self.weaponHitSound 		= sound.new("weapon_hit.ogg", false)
	self.btnClick				= sound.new("click.ogg", false)
	self.starAward				= sound.new("star_award.ogg", false)
	self.randomItemSound		= sound.new("random_item.ogg", false)
	self.randomItemFinishSound	= sound.new("random_item_finish.ogg", false)
	self.superSkillSound		= sound.new("super_skill.ogg", false)
	self.absorbSound			= sound.new("absorb.ogg", false)
	self.bombColorSound			= sound.new("bomb_color.ogg", false)
	self.bombLineSound			= sound.new("bomb_line.ogg", false)
	self.bombRoundSound			= sound.new("bomb_round.ogg", false)
	self.petLevelUpSound		= sound.new("pet_levelup.ogg", false)
	self.petUnlockSound			= sound.new("pet_unlock.ogg", false)
	
	self.BGMs = {
		["win"]					= {sound = sound.new("win.ogg", true), loop = false},
		["lost"]				= {sound = sound.new("lost.ogg", true), loop = false},
		["world"]				= {sound = sound.new("world_back_music.ogg", true), loop = true},
		["battle"]				= {sound = sound.new("battle_back_music.ogg", true), loop = true},
		["battle_super"]		= {sound = sound.new("super_mode_music.ogg", true), loop = true},
	}
	self._BGMing				= nil
end

function SoundManager.onButtonClickSfx()
	SoundManager.btnClick:play()
end

function SoundManager:switchBGM(name)
	if self._BGMing then
		self._BGMing:stop()
		self._BGMing = nil
	end
	
	if not self.BGMs[name] or not self.BGMs[name].sound then
		print("[WARN] No such BGM", name)
		return
	end
	
	self._BGMing = self.BGMs[name].sound
	local loop = self.BGMs[name].loop
	self._BGMing:play(loop)
end

return SoundManager