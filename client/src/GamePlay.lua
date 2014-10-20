
local ui = require "ui"
local node = require "node"
local Image = require "gfx.Image"
local Sprite = require "gfx.Sprite"
local FlashSprite = require "gfx.FlashSprite"
local TextBox = require "gfx.TextBox"
local actionset = require "actionset"
local math2d = require "math2d"
local interpolate = require "interpolate"
local UserData = require "UserData"
local device = require "device"
local shake = require "shake"
local FillBar = require "gfx.FillBar"
local FinishPanel = require "windows.FinishPanel"
local FightTopPanel = require "windows.FightTopPanel"
local eventhub = require "eventhub"
local Formula = require "settings.Formula"
local BallLevel = require "settings.BallLevel"
local GameConfig = require "settings.GameConfig"
local AvatarConfig = require "settings.AvatarConfig"
local timer = require "timer"
local gfxutil = require "gfxutil"
local Pet = require "settings.Pet"
local sound = require "sound"
local SoundManager = require "SoundManager"
local qlog = require "qlog"
local Item = require "settings.Item"
local Mission = require "settings.Mission"
local deviceevent = require "deviceevent"
local Player = require "logic.Player"
local resource = require "resource"
local Particle = require "gfx.Particle"
local PetFX = require "settings.PetFX"
local Timing = require "settings.Timing"
local TipPanel = require "windows.TipPanel"
local RandomItemPanel = require "windows.RandomItemPanel"
local ActLog = require "ActLog"
local resource = require "resource"
local TaskConfig = require "settings.TaskConfig"
local Buy = require "settings.Buy"
local bucket = resource.bucket

local columns, rows = 7, 6
local ballW, ballH = 110*0.87, 96*0.87
local ballV, ballA, ballR = 1000, 2000, 0.2
local absorbV, absorbR = 500, 10
local reboundCount = 3
local minLinkingCount = 3
local superModeTime = 10
local toleranceDis = ballH * 0.75

local ballFormationOffX = 3
local ballFormationOffY = -3
local preMonsterX, preMonsterY = device.ui_width / 2 + 200, 360
local preHeroX, preHeroY = -device.ui_width / 2 - 150, -40
local midHeroY = 90
local rushDistance = device.ui_width / 3
local maxDamage = 9999999

local gameBg			= "panel/loadbg.atlas.png#loadbg.png"
local downBgImage 		= "gameplay.atlas.png#control_panel.png"
local ballBgImage 		= "gameplay.atlas.png#tuxing_1.png"
local hpBgImage 		= "gameplay.atlas.png#xt_di_1.png"
local hpImage 			= "xt_di_2.png"
local selectEffectImage = "gameplay.atlas.png#select_effect?loop=true"
local selectArrowImage 	= "gameplay.atlas.png#select_arrow?loop=true"
local remindEffectImage = "gameplay.atlas.png#ui_tishi_guangquan?loop=true"
local remindArrowImage 	= "gameplay.atlas.png#remind_arrow?loop=true"
local explosionEffect 	= "gameplay.atlas.png#ui_xiaochu"
local fly3_explosionEffect	= "gameplay.atlas.png#explosion_fly3"
local monsterHitEffect  = "gameplay.atlas.png#hit?scl=2"
local bombRoundEffect 	= "gameplay.atlas.png#bomb_round?scl=2.5"
local bombColorEffect 	= "gameplay.atlas.png#bomb_color_effect?loop=true"
local bombColorLine 	= "gameplay.atlas.png#bomb_color_line?size=32,128&loop=true"
local bombColorThunder 	= "gameplay.atlas.png#bomb_color_thunder?size=92,93&loop=true"
local bombLineEffect 	= "gameplay.atlas.png#bomb_line_effect"
local bombLineRay		= "gameplay.atlas.png#bomb_line_ray?size=100,800"
local superLightRight 	= "gameplay.atlas.png#light_blue.png"
local superLightLeft 	= "gameplay.atlas.png#light_yellow.png"
local whiteMaskImage	= "white_mask.jpg?scl="..device.ui_width..","..device.ui_height
local superSkillBg	 	= "gameplay2.atlas.png#super_skill_bg?loop=true&scl="..tostring(800/302)..","..tostring(500/224)
local superSkillEffect 	= "gameplay2.atlas.png#super_skill_effect"

-- red green pink blue black
local ballLevelBgImage = "gameplay.atlas.png#ball_level_bg.png"
local ballLevelMaskImage = "gameplay.atlas.png#ball_level_mask.png"
local ballLevelImages = 
{
	[1] = 
	{
		"gameplay.atlas.png#lv_4.png",
		"red_dj_1.png",
		"gameplay.atlas.png#red_dj_2.png",
	},
	[2] = 
	{
		"gameplay.atlas.png#lv_2.png",
		"green_dj_1.png",
		"gameplay.atlas.png#green_dj_2.png",
	},
	[3] = 
	{
		"gameplay.atlas.png#lv_3.png",
		"pink_dj_1.png",
		"gameplay.atlas.png#pink_dj_2.png",
	},
	[4] = 
	{
		"gameplay.atlas.png#lv_1.png",
		"blue_dj_1.png",
		"gameplay.atlas.png#blue_dj_2.png",
	},
	[5] = 
	{
		"gameplay.atlas.png#lv_5.png",
		"black_dj_1.png",
		"gameplay.atlas.png#black_dj_2.png",
	},
}

local ballImages = {}

local bombIndex = 
{
	[1] = "bombLine",
	[2] = "bombRound",
	[3] = "bombColor",
}

local superPowerImages = 
{
	["bombLine"] = "gameplay.atlas.png#bomb_line.png",
	["bombRound"] = "gameplay.atlas.png#bomb_round.png",
}

local bombColorImages = 
{
	[1] = "gameplay.atlas.png#bomb_red.png",
	[2] = "gameplay.atlas.png#bomb_green.png",
	[3] = "gameplay.atlas.png#bomb_pink.png",
	[4] = "gameplay.atlas.png#bomb_blue.png",
	[5] = "gameplay.atlas.png#bomb_black.png",
}

local tbRandomItemEffect =
{
	["mission"] = 
	{
		[1] = {"bombLine", "gameplay.atlas.png#bomb_line.png"},
		[2] = {"bombRound", "gameplay.atlas.png#bomb_round.png"},
		[3] = {"bombColor", "gameplay.atlas.png#bomb_red.png"},
		[4] = {"rewardStep", "gameplay.atlas.png#dj_1.png", 5},
		[5] = {"rewardLevel", "gameplay.atlas.png#lv_4.png", 1},
		[6] = {"rewardLevel", "gameplay.atlas.png#lv_2.png", 2},
		[7] = {"rewardLevel", "gameplay.atlas.png#lv_3.png", 3},
		[8] = {"rewardLevel", "gameplay.atlas.png#lv_1.png", 4},
		[9] = {"rewardLevel", "gameplay.atlas.png#lv_5.png", 5},
	},
	["stage"] = 
	{
		[1] = {"bombLine", "gameplay.atlas.png#bomb_line.png"},
		[2] = {"bombRound", "gameplay.atlas.png#bomb_round.png"},
		[3] = {"bombColor", "gameplay.atlas.png#bomb_red.png"},
		[4] = {"rewardStep", "gameplay.atlas.png#dj_1.png", 5},
		[5] = {"rewardLevel", "gameplay.atlas.png#lv_4.png", 1},
		[6] = {"rewardLevel", "gameplay.atlas.png#lv_2.png", 2},
		[7] = {"rewardLevel", "gameplay.atlas.png#lv_3.png", 3},
		[8] = {"rewardLevel", "gameplay.atlas.png#lv_1.png", 4},
		[9] = {"rewardLevel", "gameplay.atlas.png#lv_5.png", 5},
	},
	["timing"] = 
	{
		[1] = {"bombLine", "gameplay.atlas.png#bomb_line.png"},
		[2] = {"bombRound", "gameplay.atlas.png#bomb_round.png"},
		[3] = {"bombColor", "gameplay.atlas.png#bomb_red.png"},
		[4] = {"rewardTime", "gameplay.atlas.png#sj_1.png", 10},
		[5] = {"rewardLevel", "gameplay.atlas.png#lv_4.png", 1},
		[6] = {"rewardLevel", "gameplay.atlas.png#lv_2.png", 2},
		[7] = {"rewardLevel", "gameplay.atlas.png#lv_3.png", 3},
		[8] = {"rewardLevel", "gameplay.atlas.png#lv_1.png", 4},
		[9] = {"rewardLevel", "gameplay.atlas.png#lv_5.png", 5},
	},
}

local ballExplosionEffect = 
{
	[1] = "explosion.atlas.png#explosion_red",
	[2] = "explosion.atlas.png#explosion_green",
	[3] = "explosion.atlas.png#explosion_pink",
	[4] = "explosion.atlas.png#explosion_blue",
	[5] = "explosion.atlas.png#explosion_black",
}

local superModeParticle = "super_mode.pex"
local flyParticle = "fly.pex"
local flyParticle2 = "fly2.pex"
local flyParticle3 = "fly3.pex"
local absorbParticle = "absorption.pex"
local bubbleParticle = "bubble.pex"
local levelUpParticle = "upgrade.pex"
local skillReadyParticle = "skill_ready.pex?loop=true"
local ballExplosionParticle = 
{
	[1] = "explosion_red.pex",
	[2] = "explosion_green.pex",
	[3] = "explosion_pink.pex",
	[4] = "explosion_blue.pex",
	[5] = "explosion_black.pex",
}

local tbDec = 
{
	["stage"] = 
	{
		decTime = 0,
		decStep = 1,
	},
	["mission"] = 
	{
		decTime = 0,
		decStep = 1,
	},
	["timing"] = 
	{
		decTime = 1,
		decStep = 0,
	},
}

local countDownPic = 
{
	[1] = "gameplay.atlas.png#ks_sz_go.png",
	[2] = "gameplay.atlas.png#ks_sz_1.png",
	[3] = "gameplay.atlas.png#ks_sz_2.png",
	[4] = "gameplay.atlas.png#ks_sz_3.png",
}

local robotId2BuyIdx = 
{
	[2] = 14,
	[3] = 15,
	[4] = 16,
	[5] = 17,
}

local GamePlay = {}

GamePlay.supperPowerCbs = 
{
	["bombLine"] = function(o, dirs)
		GamePlay:bombLine(o._column, o._row, dirs)
	end,
	["bombRound"] = function(o, radius)
		GamePlay:bombRound(o._column, o._row, radius)
	end,
	["bombColor"] = function(o)
		GamePlay:bombColor(o._column, o._row, o.colorIndex)
	end,
}

function GamePlay:preLoad()
	if device.ram == device.RAM_LO then
		return
	end
	bucket.push("GamePlay")
	
	gfxutil.preLoadAssets(gameBg)
	gfxutil.preLoadAssets(hpImage)
	gfxutil.preLoadAssets(whiteMaskImage)
	gfxutil.preLoadAssets("explosion.atlas.png")
	gfxutil.preLoadAssets("gameplay.atlas.png")
	gfxutil.preLoadAssets("gameplay2.atlas.png")
	
	local transform = MOAIImage.PREMULTIPLY_ALPHA + MOAIImage.QUANTIZE
	for petId, pet in pairs (Pet.petList) do
		for _, avatar in pairs (pet.avatars) do
			local a = AvatarConfig:getAvatar(avatar)
			gfxutil.preLoadAssets(a.image, transform)
		end
	end
	
	for _, monster in pairs (GameConfig.monsterList) do
		local a = AvatarConfig:getAvatar(monster.avatarId)
		if a.image then
			gfxutil.preLoadAssets(a.image, transform)
		end
		if a.idlImage then
			gfxutil.preLoadAssets(a.idlImage, transform)
		end
		if a.hitImage then
			gfxutil.preLoadAssets(a.hitImage, transform)
		end
		gfxutil.preLoadAssets(monster.background, transform)
	end
	
	for _, var in ipairs(ballLevelImages) do
		gfxutil.preLoadAssets(var[2], transform)
	end
	
	for _, var in pairs(PetFX.tbSpinPatchPic) do
		for _, pet in ipairs(var) do
			gfxutil.preLoadAssets(pet, transform)
		end
	end
	bucket.pop()
end

function GamePlay:init()
	self._root = Image.new(gameBg)
	self._root:setLayoutSize(device.ui_width, device.ui_height)
	
	self._cameraShake = shake.new(self._root)
	self._cameraShake:setSource(self._root)
	
	self._flyParticleRoot = self._root:add(node.new())
	self._flyParticleRoot:setPriorityOffset(2000)
	
	self._upBg = self._root:add(Image.new(GameConfig.monsterList[1].background))
	self._upBg:setPriorityOffset(1)
	
	self._upCellRoot = self._upBg:add(node.new())
	self._upCellRoot:setPriorityOffset(10)
	
	self._monsterRoot = self._upCellRoot:add(node.new())
	
	self._heroRoot = self._upCellRoot:add(node.new())
	self._heroRoot:setPriorityOffset(10)
	
	self._downBg = self._root:add(Image.new(downBgImage))
	self._downBg:setPriorityOffset(3)
	local downW, downH = self._downBg:getSize()
	local downY = downH / 2
	self._downBg:setAnchor("MB", 0, downY)
	
	local upW, upH = self._upBg:getSize()
	self._upBg:setAnchor("MB", 0, downY + downH/2 + upH/2 - 50)
	
	self._ballBgRoot = self._downBg:add(node.new())
	self._ballBgRoot:setPriorityOffset(100)
	
	self._arrowRoot = self._ballBgRoot:add(node.new())
	self._arrowRoot:setPriorityOffset(10)
	
	self._ballFormationRoot = self._ballBgRoot:add(node.new())
	self._ballFormationRoot:setPriorityOffset(20)
	
	self._explosionRoot = self._ballBgRoot:add(node.new())
	self._explosionRoot:setPriorityOffset(30)
	
	self._bombEffectRoot = self._ballBgRoot:add(node.new())
	self._bombEffectRoot:setPriorityOffset(40)
	
	--先计算球位置
	self:calcBallLoc()
	
	--再初始化球的背景
	self:initBallBg()
	
	self._ballLevelRoot = self._downBg:add(Image.new())
	self._ballLevelRoot:setPriorityOffset(300)
	self._ballLevelRoot:setAnchor("LM", 38, 0)
	self:initBallLevelBar()
	
	self._countDownRoot = self._root:add(node.new())
	self._countDownRoot:setPriorityOffset(310)
	
	-- bind event
	eventhub.bind("UI_EVENT", "OPEN_GAME_PANEL", function(flag, idx)
		self:start(flag, idx)
	end)
	
	eventhub.bind("UI_EVENT", "GAME_REPLAY", function(mission)
		self:reStart(mission)
	end)
	
	eventhub.bind("UI_EVENT", "CLOSE_GAME_PANEL", function()
		self:stop()
	end)
	
	eventhub.bind("UI_EVENT", "USE_ITEM", function(Idx)
		self:useItem(Idx)
	end)
	
	eventhub.bind("UI_EVENT", "USE_ADD_STEP", function()
		self:useAddStep()
	end)
	
	eventhub.bind("UI_EVENT", "NOUSE_ADD_STEP", function()
		self:gameOver(false, true)
	end)
	
	eventhub.bind("UI_EVENT", "NOUSE_KICK_MONSTER", function()
		self:gameOver(false, true)
	end)
	
	eventhub.bind("UI_EVENT", "QUIT_GAME", function()
		if self._gameMode == "stage" then
			ActLog:endStageManual(self._curMonsterIndex, self._curScore)
		end
		self:gameOver(false, true)
	end)
	
	eventhub.bind("SYSTEM_EVENT", "RANDOM_ITEM_FINISH", function(result)
		self:randomItemFinish(result)
	end)
	
	eventhub.bind("SYSTEM_EVENT", "REQUEST_USE_ITEM_IN_GAME", function(index)
		if not self._disableTouch then 
			UserData:useItem(index)
		end
	end)
	
	eventhub.bind("UI_EVENT", "PAUSE_GAME", function(flag)
		if flag then
			self._timingUpdata = false
		else
			self._timingUpdata = true
		end
	end)
end

function GamePlay:initBallLevelBar()
	local temp = 202
	local delta = -80
	self._ballLevelBgList = {}
	self._ballLevelList = {}
	self._ballLevelTextList = {}
	self._ballLevelClick = {}
	for ballId, tbImage in pairs (ballLevelImages) do
		local ballLevelBg = self._ballLevelRoot:add(Image.new(ballLevelBgImage))
		ballLevelBg:setLoc(0, temp)
		
		local ballLevelImage = ballLevelBg:add(Image.new(tbImage[1]))
		ballLevelImage:setPriorityOffset(10)
		
		local bubble = ballLevelBg:add(self:newBubbleEffect())
		bubble:setPriorityOffset(20)
		bubble:setLoc(0, -28)
		
		local ballLevelFillBar = ballLevelBg:add(FillBar.new(tbImage[2]))
		ballLevelFillBar:setPriorityOffset(30)
		ballLevelFillBar:setRot(90)
		ballLevelFillBar:setFill(0, 0)
		
		local ballLevelMask = ballLevelBg:add(Image.new(ballLevelMaskImage))
		ballLevelMask:setPriorityOffset(40)
		
		local ballLevelText = ballLevelBg:add(TextBox.new("1", "monster", nil, "MM", 60, 60))
		ballLevelText:setLoc(30, -30)
		ballLevelText:setPriorityOffset(50)
		
		local x, y = ballLevelBg:getWorldLoc()
		local w, h = ballLevelBg:getSize()
		
		self._ballLevelClick[ballId] = 
		{
			xMin = x - w / 2,
			yMin = y - h / 2,
			xMax = x + w / 2,
			yMax = y + h / 2,
			hitTest = function(self, p1, p2)
				p1, p2 = gameLayer:wndToWorld(p1, p2)
				if math2d.rectIntersect(p1, p2, p1, p2, self.xMin, self.yMin, self.xMax, self.yMax) then
					GamePlay:ballLevelOnClick(ballId)
				end
			end,
		}
	
		self._ballLevelBgList[ballId] = ballLevelBg
		self._ballLevelList[ballId] = ballLevelFillBar
		self._ballLevelTextList[ballId] = ballLevelText
		
		temp = temp + delta
	end
end

function GamePlay:initBallLevel()
	self._ballLevel = 
	{
		[1] = 
		{
			curCount = 0,
			curLevel = 0,
		},
		[2] = 
		{
			curCount = 0,
			curLevel = 0,
		},
		[3] = 
		{
			curCount = 0,
			curLevel = 0,
		},
		[4] = 
		{
			curCount = 0,
			curLevel = 0,
		},
		[5] = 
		{
			curCount = 0,
			curLevel = 0,
		},
	}
	
	self:updateAllBallLevel()
end

function GamePlay:initData()
	self._gameOver = false
	self._gameStopped = false
	self._disableTouch = false
	self._stepReminded = false
	self._isAttacking = false
	self._isMonsterSkilling = false
	self._isUsingItem = false
	self._dropBallEnd = false
	self._killMode = nil
	deviceevent.onBackBtnPressedCallback = function()
		if not self._gameOver and UserData:rookieGuideisOver() then
			eventhub.fire("UI_EVENT", "SWITCH_PAUSE_PANEL")
		end
	end
	
	self._curStep = 100
	self._curTime = 100
	if self._gameMode == "stage" then
		self._curStep = GameConfig.initialStep
	elseif self._gameMode == "mission" then
		self._curStep = Mission:getMissionStep(self._gameIdx)
	elseif self._gameMode == "timing" then
		self._curTime = Timing:getTimeLength(self._gameIdx)
	end
	
	self._curScore = 0
	self._curEnergy = 0
	self._curMonsterIndex = 1
	self:setSuperModeTime(0)
	self._buyStepTimes = GameConfig.buyStepTimes
	self._useStep = 0
	
	self:initBallLevel()
	self:setAttackDamage(0)
end

function GamePlay:nextBall(column, row, dir)
	local t
	if math.fmod(column, 2) == 0 then
		t = GameConfig.even
	else
		t = GameConfig.singular
	end
	local c = column + t[dir][1]
	local r = row + t[dir][2]
	if c >= 1 and c <= columns and r >= 1 and r <= rows then
		return c, r
	end
end

function GamePlay:isBall(o)
	return type(o._ballId) == "number"
end

function GamePlay:isNeighbor(x1, y1, x2, y2)
	if math.abs(x1 - x2) <= 1 then
		if x1 == x2 then
			return math.abs(y1 - y2) == 1
		elseif math.fmod(x1, 2) == 0 then
			return y1 == y2 or y1 + 1 == y2
		else
			return y1 == y2 or y1 - 1 == y2
		end
	end
end

function GamePlay:calcBallLoc()
	self._ballLoc = {}
	local evenColumns = math.floor(columns/2)
	local singularColumns = columns - evenColumns
	
	local w = ballW * singularColumns + ballW * (evenColumns/2)
	local h = ballH * rows + ballH / 2
	local baseX, baseY = -w / 2 + ballW / 2, -h / 2 + ballH / 2
	
	--奇数列
	local tempX = baseX
	local tempY = baseY
	for i = 1, singularColumns do
		self._ballLoc[i * 2 - 1] = {}
		for j = 1, rows do
			self._ballLoc[i * 2 - 1][j] = 
			{
				x = tempX + 26,
				y = tempY + 50,
			}
			tempY = tempY + ballH
		end
		
		tempX = tempX + ballW * 1.5
		tempY = baseY
	end
	
	--偶数列
	baseX = -w / 2 + ballW / 2 + ballW * 0.75
	baseY = baseY+ ballH / 2
	tempX = baseX
	tempY = baseY
	for i = 1, evenColumns do
		self._ballLoc[i * 2] = {}
		for j = 1, rows do
			self._ballLoc[i * 2][j] = 
			{
				x = tempX + 26,
				y = tempY + 50,
			}
			tempY = tempY + ballH
		end
		
		tempX = tempX + ballW * 1.5
		tempY = baseY
	end
end

function GamePlay:initBallBg()
	for i = 1, columns do
		for j = 1, rows do
			local x = self._ballLoc[i][j].x
			local y = self._ballLoc[i][j].y
			local back = self._ballBgRoot:add(Image.new(ballBgImage))
			back:setLoc(x, y)
		end
	end
end

function GamePlay:clearLinkData()
	self._curSelectBall = nil
	self._linkingBalls = nil
	
	if self._linkingArrows then
		for k, v in pairs(self._linkingArrows) do
			v:destroy()
		end
	end
	self._linkingArrows = {}
	
	if self._linkingEffects then
		for k, v in pairs(self._linkingEffects) do
			v:destroy()
		end
	end
	self._linkingEffects = {}
end

function GamePlay:initBallFormation()
	self:clearLinkData()

	self._balls = 
	{
		[1] = {},
		[2] = {},
		[3] = {},
		[4] = {},
		[5] = {},
		[6] = {},
		[7] = {},
	}
	
	self._bombs = 
	{
		[1] = {},
		[2] = {},
		[3] = {},
		[4] = {},
		[5] = {},
		[6] = {},
		[7] = {},
	}
	
	self._ballFormationRoot:removeAll()
	self:dropBalls()
end

function GamePlay:restoreBallFormation(ballFormation)
	self:clearLinkData()
	
	self._balls = 
	{
		[1] = {},
		[2] = {},
		[3] = {},
		[4] = {},
		[5] = {},
		[6] = {},
		[7] = {},
	}
	
	self._bombs = 
	{
		[1] = {},
		[2] = {},
		[3] = {},
		[4] = {},
		[5] = {},
		[6] = {},
		[7] = {},
	}
	
	self._ballFormationRoot:removeAll()
	
	for c, rows in pairs (ballFormation) do
		for r, ballId in pairs (rows) do
			if ballId then
				local x = self._ballLoc[c][r].x
				local y = self._ballLoc[c][r].y
				local ball = self:newBall(ballId)
				ball:setLoc(x, y)
				ball._destY = self._ballLoc[c][r].y
				ball._v = ballV
				ball._column = c
				ball._row = r
				self:setBall(ball)
				self._ballFormationRoot:add(ball)
			end
		end
	end
	self:dropBalls()
	eventhub.fire("SYSTEM_EVENT", "GAME_DATA_TYPE", "GamePlay")
end

function GamePlay:noMove()
	self:initBallFormation()
	
	TipPanel:open("nomove")
end

function GamePlay:initMonster(index)

	self._curMonsterIndex = index
	
	local m, a = self:getCurMonsterAvatar()
	
	self._monster = {}
	self._monster.hp = math.floor(m.hp * UserData.hpFactor)
	self._monster.hpMax = math.floor(m.hp * UserData.hpFactor)
	self._monster.avatarId = m.avatarId
	
	self:createMonsterAvatar(a)
	
	self._monster.avatar:setLoc(preMonsterX , preMonsterY)
	self._monster.avatar:seekLoc(a.x, a.y, 0.5, MOAIEaseType.EASE_OUT)
	
	self._monster.hpBG = self._monster.avatar:add(Image.new(hpBgImage))
	self._monster.hpBG:setPriorityOffset(10)
	self._monster.hpBG:setLoc(a.hpX or 43, a.hpY or 60)
	
	self._monster.hpBar = self._monster.hpBG:add(FillBar.new(hpImage))
	self._monster.hpBar:setLoc(0, 0)
	
	local strhp = self._monster.hp.."/"..self._monster.hpMax
	self._monster.curhp = self._monster.hpBar:add(TextBox.new(strhp, "enemy"))
	self._monster.curhp:setLoc(0, 7)
	
	self._monster.shake = shake.new(self._monster.avatar)
	self._monster.shake:setSource(self._monster.avatar)
	
	self._upBg:load(m.background)
	
	if self._gameMode == "stage" then
		FightTopPanel:updateMissionNum(self._curMonsterIndex)
	elseif self._gameMode == "mission" then
		FightTopPanel:updateMissionNum(self._gameIdx)
		local monsterCount = Mission:getMonsterCount(self._gameIdx)
		FightTopPanel:updateMonsterNum(self._curMonsterIndex, monsterCount)
	elseif self._gameMode == "timing" then
		FightTopPanel:updateMissionNum(self._gameIdx)
		local monsterCount = Timing:getMonsterCount(self._gameIdx)
		FightTopPanel:updateMonsterNum(self._curMonsterIndex, monsterCount)
	end
end

function GamePlay:createHero(avatarId)
	local a = AvatarConfig:getAvatar(avatarId)
	local avatar = Sprite.new(a.image.."?loop=true")
	avatar:setPriorityOffset(10)
	local hero = 
	{
		avatarId = avatarId,
		avatar = self._heroRoot:add(avatar),
	}
	
	return hero
end

function GamePlay:newHero(avatarId)
	if self._hero and self._hero.avatar then
		self._hero.avatar:destroy()
	end
	if self._garnerFX then
		self._garnerFX:destroy()
	end
	self._petFXLv = nil
	self._petFX = nil
	
	local hero = self:createHero(avatarId)
	hero.avatar:setLoc(preHeroX, preHeroY)
	
	local heroX, heroY = AvatarConfig:getAvatarLoc(avatarId)
	local midHeroX = (heroX + preHeroX) / 2
	
	local c = interpolate.makeCurve(0, 0, MOAIEaseType.LINEAR, 0.3, 0.3)
	local f1 = interpolate.newton2d({preHeroX, midHeroX, heroX}, {preHeroY, midHeroY, heroY}, c)
	local action
	action = self._AS:run(function(dt, length)
		if length >= c:getLength() then
			action:stop()
			hero.avatar:setLoc(heroX, heroY)
		else
			hero.avatar:setLoc(f1(length))
		end
	end)
	
	self._hero = hero
	self:addSwitchHeroAction(action, nil)
end

function GamePlay:addGarnerFX(hero)
	if self._garnerFX then
		self._garnerFX:destroy()
	end
	if self._petFX then
		local p = hero.avatar:getPriority()
		local fx = self._petFX.garner[self._petFXLv]
		if fx then
			self._garnerFX = self._heroRoot:add(fx())
			self._garnerFX:setLoc(hero.avatar:getLoc())
		end
	end
end

function GamePlay:switchHero(avatarId)
	local pre = self._hero
	self._hero = self:createHero(avatarId)
	self._hero.avatar:setLoc(preHeroX, preHeroY)

	local curX, curY = pre.avatar:getLoc()
	local heroX, heroY = AvatarConfig:getAvatarLoc(avatarId)
	local midHeroX = (heroX + preHeroX) / 2
	
	local c = interpolate.makeCurve(0, 0, MOAIEaseType.LINEAR, 0.2, 0.2)
	local f1 = interpolate.newton2d({preHeroX, midHeroX, heroX}, {preHeroY, midHeroY, heroY}, c)
	local f2 = interpolate.newton2d({curX, midHeroX, preHeroX}, {curY, midHeroY, preHeroY}, c)
	
	if self._garnerFX then
		self._garnerFX:destroy()
	end
	
	if avatarId == "default_hero" then
		self._petFXLv = nil
		self._petFX = nil
	end
	
	local action
	action = self._AS:run(function(dt, length)
		if length >= c:getLength() then
			action:stop()
			pre.avatar:destroy()
			self._hero.avatar:setLoc(heroX, heroY)
			self:addGarnerFX(self._hero)
		else
			self._hero.avatar:setLoc(f1(length))
			pre.avatar:setLoc(f2(length))
		end
	end)
	self:addSwitchHeroAction(action, pre.avatar)
end

function GamePlay:addSwitchHeroAction(action, hero)
	if not self._switchActionList then
		self._switchActionList = {}
	end
	
	self._switchActionList[#self._switchActionList+1] = 
	{
		["action"] = action,
		["hero"] = hero,
	}
end

function GamePlay:removeSwitchHeroAction()
	if not self._switchActionList then
		return
	end
	
	for _, tb in pairs (self._switchActionList) do
		tb.action:stop()
		
		if tb.hero then
			tb.hero:destroy()
		end
	end
	
	self._switchActionList = nil
	
	local heroX, heroY = AvatarConfig:getAvatarLoc(self._hero.avatarId)
	self._hero.avatar:setLoc(heroX, heroY)
end

function GamePlay:LocToBall(x, y, ballId)
	local maxC = 1
	local maxR = 1
	local wx, wy = gameLayer:wndToWorld(x, y)
	local _, downBgY = self._downBg:getLoc()
	wy = wy - downBgY
	for column, rows in ipairs (self._ballLoc) do
		if wx > rows[1].x then
			maxC = column
		else
			break
		end
	end
	
	for row, loc in ipairs (self._ballLoc[maxC]) do
		if wy > loc.y then
			maxR = row
		else
			break
		end
	end
	
	local minDis = math.maxnum
	local nearestBall = nil
	for c = maxC, maxC+1 do
		for r = maxR, maxR+1 do
			local ball = self:getBall(c, r)
			if ball then
				local ballX, ballY = ball:getLoc()
				local dis = math2d.distance(wx, wy, ballX, ballY)
				if (dis < minDis) and (dis < toleranceDis) then
					if ballId then
						if ballId == ball._ballId then
							nearestBall = ball
							minDis = dis
						end
					else
						nearestBall = ball
						minDis = dis
					end
				end
			end
		end
	end
	
	return nearestBall
end

function GamePlay:lockBallsPanel()
	ui.capture(ui.handleDefaultTouch)
end

function GamePlay:unlockBallsPanel()
	ui.release(ui.handleDefaultTouch)
end

function GamePlay:onTouchMove(eventType, touchIdx, x, y, tapCount)
	if self._linkingBalls then
		local v = self:LocToBall(x, y, self._curSelectBall._ballId)
		if v and v ~= self._curSelectBall and self:isBall(v) and (not self._lockedBalls or self._lockedBalls[v]) then
			local ball = self._curSelectBall
			self._curSelectBall = v
			for i = 1, self._linkingBalls.n do
				if self._linkingBalls[i] == v then
					--不是回到第一个,或者现在只有两个时,自动回退到该点
					if i == self._linkingBalls.n - 1 then
						self._linkingBalls.n = i
						for j = i, #self._linkingArrows do
							self._linkingArrows[j]:destroy()
							self._linkingArrows[j] = nil
						end
						for j = i + 1, #self._linkingEffects do
							self._linkingEffects[j]:destroy()
							self._linkingEffects[j] = nil
						end
						self:heroReady(v._ballId, self._linkingBalls.n)
						self:sclBall(ball)
					end
					return
				end
			end
			local ball = self._linkingBalls[self._linkingBalls.n]
			if v._ballId == ball._ballId then
				if self:isNeighbor(ball._column, ball._row, v._column, v._row) then
					local x, y = ball:getLoc()
					local tx, ty = v:getLoc()
					local mx, my = (x + tx) / 2, (y + ty) / 2
					local ang = math2d.angle(tx - x, ty - y) + 45
					local arrow = self._arrowRoot:add(Sprite.new(selectArrowImage))
					arrow:setLoc(mx, my)
					arrow:setRot(ang)
					self._linkingArrows[self._linkingBalls.n] = arrow
					self._linkingBalls.n = self._linkingBalls.n + 1
					self._linkingBalls[self._linkingBalls.n] = v
					self._linkingEffects[self._linkingBalls.n] = v:add(self:newSelectEffect())
					self:sclBall(v)
					self:heroReady(v._ballId, self._linkingBalls.n)
					
					if SoundManager.ballSelectSound[self._linkingBalls.n] then
						SoundManager.ballSelectSound[self._linkingBalls.n]:play()
					else
						SoundManager.ballSelectSound[#SoundManager.ballSelectSound]:play()
					end
				end
			end
		end
	end
end

function GamePlay:onTouchDown(eventType, touchIdx, x, y, tapCount)
	if self._gameOver then
		return
	end
	
	if not self:canDecStep() then
		return
	end
	
	if not self._isTouchDown then
		self._isTouchDown = true
		self:lockBallsPanel()
		if not self._disableTouch and self._countDown <= 0 then
			local o = self:LocToBall(x, y)
			if o and (not self._lockedBalls or self._lockedBalls[o]) and not self._lockedSkills then
				if self:isBall(o) then
					self:clearLinkData()
					self._curSelectBall = o
					self._linkingBalls = 
					{
						n = 1,
						[1] = o,
					}
					self._linkingEffects[self._linkingBalls.n] = o:add(self:newSelectEffect())
					self:sclBall(o)
					SoundManager.ballSelectSound[self._linkingBalls.n]:play()
				elseif o._supperPowerCb then
					self._disableTouch = true
					o._supperPowerCb(o, unpack(o._supperPowerArgs))
					eventhub.fire("ROOKIE_EVENT", "ROOKIE_COMPLETE", "bomb")
				end
				
				self:stopRemind()
			end			
			if self._lockedSkills then
				for k, v in pairs(self._lockedSkills) do
					self._ballLevelClick[k]:hitTest(x, y)
				end
			else
				for i = 1, 5 do
					self._ballLevelClick[i]:hitTest(x, y)
				end
			end
		end
	end
end

function GamePlay:onTouchUp(eventType, touchIdx, x, y, tapCount)
	if self._isTouchDown then
		self._isTouchDown = nil
		self:unlockBallsPanel()
		if self._linkingBalls then
			local ok = self._linkingBalls.n >= minLinkingCount
			if self._lockedBalls and self._lockedBalls.count ~= self._linkingBalls.n then
				ok = false
			end
			if ok then
				self._disableTouch = true
				self._isAttacking = true
				qlog.debug("link number:", self._linkingBalls.n)
				self:linkSuccess()
				self:heroAttack()
				self:decStep()
				eventhub.fire("ROOKIE_EVENT", "ROOKIE_COMPLETE", "linkball")
			else
				if self._hero.avatarId ~= "default_hero" then
					self:switchHero("default_hero")
				end
				
				self:startRemind()
			end
			
			self:clearLinkData()
			
			return true
		end
	end
end

function GamePlay:linkSuccess()
	if self:isInSuperMode() then
		self:superLink()
	else
		self:normalLink()
	end
end

function GamePlay:superLink()
	local id = self._linkingBalls[1]._ballId
	local pet = UserData:getPetInfo(id)
	local n = self._linkingBalls.n
	local clearNum = 0
	local totalNum = 0
	local clearBallList = 
	{
		[1] = 0,
		[2] = 0,
		[3] = 0,
		[4] = 0,
		[5] = 0,
	}
	clearBallList[id] = n
	for i = 1, n do
		local tbClearBall = {}
		local linkBall = self._linkingBalls[i]
		self:popBall(linkBall._column, linkBall._row)
		tbClearBall[#tbClearBall+1] = linkBall
		totalNum = totalNum + 1
		
		--周围的球
		for d = 1, 6 do
			local c, r = self:nextBall(linkBall._column, linkBall._row, d)
			if c and r and not self:isInLinkingBall(c, r) then
				local o = self:getBall(c, r)
				if o and self:isBall(o) then
					self:popBall(c, r)
					tbClearBall[#tbClearBall+1] = o
					totalNum = totalNum + 1
					clearBallList[o._ballId] = clearBallList[o._ballId] + 1
				end
			end
		end
		
		local sp = nil
		if i >= n and n >= pet.supperPowerSteps then
			sp = self:newSuperPower(pet, linkBall, n)
		end
		
		for _, o in ipairs(tbClearBall) do
			self._AS:delaycall((i - 1) * 0.1, function()
				o:seekColor(0, 0, 0, 0, 0.2)
				local explosion, particle = self:newExplosion(id, o:getLoc())
				explosion.onDestroy = function()
					self:destroyBall(o, true)
					clearNum = clearNum + 1
					if clearNum >= totalNum then
						if sp then
							self._ballFormationRoot:add(sp)
						end
						self:dropBalls()
					end
				end
			end)
		end
	end
	
	self:addScore(Formula:calcScoreByLinkNum(n) + Formula:calcScoreByBombNum(totalNum-n))
	
	self:addAttackDamage(Formula:calcDamageByLinkNum(id, self:getCurBallLevel(id), n, self._adddamage))
	for ballId, num in ipairs(clearBallList) do
		if ballId == id then
			num = num - n
		end
		self:addAttackDamage(Formula:calcDamageByBombNum(ballId, self:getCurBallLevel(ballId), num))
	end
end

function GamePlay:normalLink()
	local id = self._linkingBalls[1]._ballId
	local pet = UserData:getPetInfo(id)
	local n = self._linkingBalls.n
	
	for i = 1, n do
		local linkBall = self._linkingBalls[i]
		self:popBall(linkBall._column, linkBall._row)
		local sp = nil
		if i >= n and n >= pet.supperPowerSteps then
			sp = self:newSuperPower(pet, linkBall, i)
		end
		self._AS:delaycall((i - 1) * 0.1, function()
			linkBall:seekColor(0, 0, 0, 0, 0.2)
			local explosion, particle = self:newExplosion(id, linkBall:getLoc())
			explosion.onDestroy = function()
				self:destroyBall(linkBall, true)
				if i >= n then
					if sp then
						self._ballFormationRoot:add(sp)
					end
					self:dropBalls()
				end
			end
		end)
	end
	
	--非超级模式下才加能量
	if not self:isInSuperMode() then
		self:addEnergy(Formula:calcEnergyPerStep(self._supermodeStep))
	end
	
	self:addScore(Formula:calcScoreByLinkNum(n))
	self:addAttackDamage(Formula:calcDamageByLinkNum(id, self:getCurBallLevel(id), n, self._adddamage))
end

function GamePlay:isInLinkingBall(c, r)
	for i = 1, self._linkingBalls.n do
		if self._linkingBalls[i]._column == c and self._linkingBalls[i]._row == r then
			return true
		end
	end
	
	return false
end

function GamePlay:dropColumn(index)
	local n = 0
	for i = 1, rows do
		if not self:getBall(index, i) then
			n = n + 1
		elseif n > 0 then
			local ball = self:popBall(index, i)
			ball._destY = self._ballLoc[index][i - n].y
			ball._v = ballV
			ball._column = index
			ball._row = i - n
			self:setBall(ball)
		end
	end
	
	for i = 1, n do
		local x = self._ballLoc[index][rows].x
		local y = self._ballLoc[index][rows].y + i * ballH
		local ball = self:newBall()
		ball:setLoc(x, y)
		ball._destY = self._ballLoc[index][rows + i - n].y
		ball._v = ballV
		ball._column = index
		ball._row = rows + i - n
		self:setBall(ball)
		self._ballFormationRoot:add(ball)
	end
end

function GamePlay:setBall(o)
	assert(not self._balls[o._column][o._row])
	self._balls[o._column][o._row] = o
	
	if not self:isBall(o) then
		self._bombs[o._column][o._row] = o
		eventhub.fire("ROOKIE_EVENT", "ROOKIE_COMPLETE", "newbomb")
	end
end

function GamePlay:popBall(column, row)
	local o = nil
	if column and row and self._balls[column] and self._balls[column][row] then
		o = self._balls[column][row]
		self._balls[column][row] = nil
		
		if self._bombs[column] and self._bombs[column][row] then
			self._bombs[o._column][o._row] = nil
		end
	end
	
	return o
end

function GamePlay:getBall(column, row)
	if column and row and self._balls[column] and self._balls[column][row] then
		return self._balls[column][row]
	end
	
	return nil
end

function GamePlay:lockBalls(...)
	self._lockedBalls = {}
	setmetatable(self._lockedBalls, {__mode = "kv"})
	local count = 0
	for k, v in pairs{...} do
		self._lockedBalls[v] = true
		count = count + 1
	end
	self._lockedBalls.count = count
end

function GamePlay:unlockBalls()
	self._lockedBalls = nil
end

function GamePlay:lockSkill(...)
	self._lockedSkills = {}
	setmetatable(self._lockedSkills, {__mode = "kv"})
	for k, v in pairs{...} do
		self._lockedSkills[v] = true
	end
end

function GamePlay:unlockSkill()
	self._lockedSkills = nil
end

function GamePlay:getBomb(bombType)
	for column, rows in pairs (self._bombs) do
		for row, bomb in pairs (rows) do
			if not bombType or bombType == bomb._ballId then
				return bomb
			end
		end
	end
	
	return nil
end

function GamePlay:switchMonster(defeat)
	if defeat then
		if self._monster and self._monster.avatar then
			SoundManager.monsterKickoutSound:play()
			self._cameraShake:add(0, 100, 1)
			
			local whiteMask = Image.new(whiteMaskImage)
			whiteMask:setColor(1, 1, 1, 0.8)
			topEffectLayer:add(whiteMask)
			local a = whiteMask:seekColor(0, 0, 0, 0, 0.5, MOAIEaseType.LINEAR)
			a:setListener(MOAIAction.EVENT_STOP, function()
				topEffectLayer:remove(whiteMask)
				whiteMask:destroy()
			end)
			
			self._monster.hpBG:destroy()
			local monster = self._monster
			monster.avatar:moveRot(3600, 2, MOAIEaseType.LINEAR)
			monster.avatar:seekScl(0.4, 0.4, 0.2)
			local a = monster.avatar:seekLoc(preMonsterX, preMonsterY, 4, MOAIEaseType.EASE_IN)
			a:setListener(MOAIAction.EVENT_STOP, function()
				monster.shake:stop()
				monster.avatar:destroy()
			end)
		end
		
		local monsterCount = 0
		if self._gameMode == "stage" then
			monsterCount = #(GameConfig.monsterList)
		elseif self._gameMode == "mission" then
			monsterCount = Mission:getMonsterCount(self._gameIdx)
		elseif self._gameMode == "timing" then
			monsterCount = Timing:getMonsterCount(self._gameIdx)
		end
		
		if (self._curMonsterIndex + 1) <= monsterCount then
			self:initMonster(self._curMonsterIndex + 1)

			if self._gameMode == "stage" then
				FightTopPanel:updateMissionNum(self._curMonsterIndex)
			elseif self._gameMode == "mission" then
				FightTopPanel:updateMissionNum(self._gameIdx)
				FightTopPanel:updateMonsterNum(self._curMonsterIndex, monsterCount)
			elseif self._gameMode == "timing" then
				FightTopPanel:updateMissionNum(self._curMonsterIndex)
			end
		else
			self:gameOver(true)
		end
	else
		if self._monster and self._monster.avatar then
			self._monster.avatar:destroy()
		end
		
		self:initMonster(self._curMonsterIndex)
	end
end

function GamePlay:heroReady(ballId, n)
	local avatarId = nil
	local pet = UserData:getPetInfo(ballId)
	
	for i = n, 1, -1 do
		if pet.avatars[i] then
			avatarId = pet.avatars[i]
			break
		end
	end

	self._linkCount = n
	local lv = self._petFXLv
	self._petFXLv = nil
	self._petFX = nil
	if avatarId then
		self._petFX = PetFX[avatarId]
		if self._petFX then
			for i, v in rpairs(self._petFX.garner) do
				if n >= i + self._petFX.baseCount then
					if lv ~= i then
						self._petFXLv = i
						self:addGarnerFX(self._hero)
					end
					break
				end
			end
		end
	else
		avatarId = "default_hero"
	end
	
	if self._hero.avatarId ~= avatarId then
		self:switchHero(avatarId)
	end
end

function GamePlay:heroAttack()
	self:removeSwitchHeroAction()
	
	local hero = self._hero
	local prev = self._attackThread
	local ac = AvatarConfig:getAvatar(hero.avatarId)
	if not ac then
		print("[ERROR] error avatarId", hero.avatarId)
		self:attackFinish()
		return
	end
	
	self._linkCount = self._linkCount or 1
	
	local thread = MOAIThread.new()
	thread._prev = prev
	thread:attach(self._AS, function()
		if prev then
			MOAIThread.blockOnAction(prev)
		end
		local _, monsterAvatar = self:getCurMonsterAvatar()
		if not monsterAvatar then
			self:attackFinish()
			return
		end
		
		if self._garnerFX then
			self._garnerFX:destroy()
		end
			
		local action
		if ac.attackImage then
			action = hero.avatar:playAnim(ac.attackImage, ac.attackLoop, false)
			local x, y = hero.avatar:getLoc()
			hero.avatar:setLoc(x + (ac.attackX or 0), y + (ac.attackY or 0))
		end
		
		local damage = self:getAttackDamage()
		if self._killMode then
			damage = maxDamage
		end
		local heroX, heroY = hero.avatar:getLoc()
		if ac.attackType == "shoot" then
			local shoots = ac.shootCount or self._linkCount * 2
			local damage = math.floor(damage / shoots)
			local delay = ac.shootDelay or 0
			local x = heroX + (ac.bulletX or 0)
			local y = heroY + (ac.bulletY or 0)
			local bs = ac.bulletSpeed or 0.5
			local mx = ac.muzzleX or 0
			local my = ac.muzzleY or 0
			local a = self:doShoot(hero, delay, ac.bulletImage, ac.bulletRot, bs, ac.muzzleFX, mx, my, ac.impactFX, damage, shoots, x, y, monsterAvatar.x, heroY)
			a:attach(action)
		elseif ac.attackType == "bezier" then
			local shoots = ac.shootCount or self._linkCount * 2
			local damage = math.floor(damage / shoots)
			local delay = ac.shootDelay or 0
			local x = heroX + (ac.bulletX or 0)
			local y = heroY + (ac.bulletY or 0)
			local bs = ac.bulletSpeed or 0.5
			local mx = ac.muzzleX or 0
			local my = ac.muzzleY or 0
			local a = self:doBezier(hero, delay, ac.bulletImage, bs, ac.muzzleFX, mx, my, ac.impactFX, damage, shoots, x, y, monsterAvatar.x, heroY)
			a:attach(action)
		elseif ac.attackType == "penetrate" then
			local shoots = ac.shootCount or self._linkCount * 2
			local damage = math.floor(damage / shoots)
			local delay = ac.shootDelay or 0
			local x = heroX + (ac.bulletX or 0)
			local y = heroY + (ac.bulletY or 0)
			local bs = ac.bulletSpeed or 0.5
			local mx = ac.muzzleX or 0
			local my = ac.muzzleY or 0
			local a = self:doPenetrate(hero, delay, ac.bulletImage, bs, ac.muzzleFX, mx, my, ac.impactFX, damage, shoots, x, y, monsterAvatar.x, heroY)
			a:attach(action)
		elseif ac.attackType == "rush" then
			local shoots = ac.shootCount or 5
			local damage = math.floor(damage / shoots)
			local mx = ac.muzzleX or 0
			local my = ac.muzzleY or 0
			local rushStay = ac.rushStay or 0.1
			local rushDelay = ac.rushDelay or 0
			local muzzleDelay = ac.muzzleDelay or 0
			local impactDelay = ac.impactDelay or 0
			local rushCount = ac.rushCount or 0
			local rushCountDelay = ac.rushCountDelay or 0
			local rushAlpha = ac.rushAlpha or 0
			local a = self:doRush(hero, rushDelay, rushStay, muzzleDelay, ac.muzzleFX, mx, my, impactDelay, ac.impactFX, damage, shoots, monsterAvatar.x, heroY, rushCount, rushCountDelay, rushAlpha)
			a:attach(action)
		elseif ac.attackType == "laser" then
			local shoots = ac.shootCount or self._linkCount * 2
			local damage = math.floor(damage / shoots)
			local delay = ac.shootDelay or 0
			local x = heroX + (ac.bulletX or 0)
			local y = heroY + (ac.bulletY or 0)
			local a = self:doLaser(hero, delay, ac.bulletImage, ac.laserDuration, ac.impactFX, damage, shoots, x, y, monsterAvatar.x, heroY)
			a:attach(action)
		end
		MOAIThread.blockOnAction(action)
	end)
	self._attackThread = thread
end

function GamePlay:doRush(hero, delay, stay, muzzleDelay, muzzleFX, muzzleX, muzzleY, impactDelay, impactFX, damage, count, destX, destY, rushCount, rushCountDelay, rushAlpha)
	local action = MOAIAction.new()
	action:attach(self._AS)
	
	local monster = self._monster
	if rushCount and rushCountDelay and rushCount > 0 and rushCountDelay > 0 then		
		local tbHero = {}
		for i = 1, rushCount do
			if i == 1 then
				tbHero[i] = hero.avatar
			else
				local a = AvatarConfig:getAvatar(hero.avatarId)
				local avatar = Sprite.new(a.image.."?loop=true")
				if a.attackImage then
					avatar:playAnim(a.attackImage, a.attackLoop, false)
				end
				avatar:setPriorityOffset(10 - i)
				self._heroRoot:add(avatar)
				avatar:setLoc(hero.avatar:getLoc())
				local alpha = 1 - i / rushAlpha
				avatar:setColor(0.8, 0.8, 0.8, alpha)
				tbHero[i] = avatar
			end
			
			self._AS:delaycall(muzzleDelay + (i - 1) * rushCountDelay, function()
				local muzzle = tbHero[i]:add(Sprite.new(muzzleFX))
				muzzle:setLoc(muzzleX, muzzleY)
				muzzle:setPriorityOffset(10)
			end)
			
			self._AS:delaycall(delay + (i - 1) * rushCountDelay, function()
				SoundManager.attackSound[hero.avatarId]:play()
				local a = tbHero[i]:seekLoc(destX, destY, 0.6)
				a:setListener(MOAIAction.EVENT_STOP, function()
					if i == 1 then
						self._AS:delaycall(stay + (i - 1) * rushCountDelay, function()
							a = tbHero[i]:seekLoc(destX + rushDistance, destY, 0.4)
							a:setListener(MOAIAction.EVENT_STOP, function()
								tbHero[i]:destroy()
							end)
						end)
					else
						tbHero[i]:destroy()
					end
				end)
			end)
		end
	else
		self._AS:delaycall(muzzleDelay, function()
			local muzzle = hero.avatar:add(Sprite.new(muzzleFX))
			muzzle:setLoc(muzzleX, muzzleY)
			muzzle:setPriorityOffset(10)
		end)
		
		self._AS:delaycall(delay, function()
			SoundManager.attackSound[hero.avatarId]:play()
			local a = hero.avatar:seekLoc(destX, destY, 0.6)
			a:setListener(MOAIAction.EVENT_STOP, function()
				self._AS:delaycall(stay, function()
					a = hero.avatar:seekLoc(destX + rushDistance, destY, 0.4)
					a:setListener(MOAIAction.EVENT_STOP, function()
						hero.avatar:destroy()
					end)
				end)
			end)
		end)
	end
	
	for i = 1, count do
		self._AS:delaycall(delay + 0.6 + impactDelay + (i - 1) * 0.1, function()
			SoundManager.impactSound[hero.avatarId]:play()
			
			local x = destX + 25 - math.random(50)
			local y = destY + 25 - math.random(50)
			self:doDamage(monster, impactFX, damage, x, y)
			if i == count then
				action:stop()
				self:attackFinish(monster)
			end
			
			self:newDamageNum(damage)
		end)
	end

	local newHeroTime = 0
	if rushCount and rushCountDelay and rushCount > 0 and rushCountDelay > 0 then
		newHeroTime = delay + 0.6 + impactDelay + stay + count * 0.1 + rushCountDelay
	else
		newHeroTime = delay + 0.6 + impactDelay + stay + count * 0.1
	end
	
	self._AS:delaycall(newHeroTime, function()
		self:newHero("default_hero")
	end)
	return action
end

function GamePlay:doShoot(hero, delay, bulletImage, bulletRot, bulletSpeed, muzzleFX, muzzleX, muzzleY, impactFX, damage, count, sourceX, sourceY, destX, destY)
	local action = MOAIAction.new()
	action:attach(self._AS)
	
	local monster = self._monster
	for i = 1, count do
		self._AS:delaycall(delay + (i - 1) * 0.05, function()
			local y = 40 - math.random(80)
			local bullet
			if type(bulletImage) == "table" then
				local image = bulletImage[math.random(#bulletImage)]
				print('=====', image)
				bullet = self:newBulletImage(image)
			else
				bullet = self:newBullet(bulletImage)
			end
			local muzzle = self._upCellRoot:add(Sprite.new(muzzleFX))
			muzzle:setLoc(sourceX + muzzleX, sourceY + y + muzzleY)
			muzzle:setPriorityOffset(170)
			bullet:setLoc(sourceX, sourceY + y)
			if bulletRot then
				bullet:seekRot(bulletRot, bulletSpeed, MOAIEaseType.LINEAR)
			end
			SoundManager.attackSound[hero.avatarId]:play()
			local a = bullet:seekLoc(destX, destY + y, bulletSpeed, MOAIEaseType.LINEAR)
			a:setListener(MOAIAction.EVENT_STOP, function()
				SoundManager.impactSound[hero.avatarId]:play()
				bullet:destroy()
				
				self:doDamage(monster, impactFX, damage, destX + 30, destY + y)
				if i == count then
					if hero.avatarId ~= "default_hero" then
						self:switchHero("default_hero")
					else
						local a = AvatarConfig:getAvatar(hero.avatarId)
						local deckName, layerName = string.split(a.image, "#")
						hero.avatar:playAnim(layerName, true)
					end
					
					action:stop()
					self:attackFinish(monster)
				end
			
				if math.fmod(i - 1, 2) == 0 then
					self:newDamageNum(damage * 2)
				end
			end)
		end)
	end
	return action
end

function GamePlay:doBezier(hero, delay, bulletImage, bulletSpeed, muzzleFX, muzzleX, muzzleY, impactFX, damage, count, sourceX, sourceY, destX, destY)
	local action = MOAIAction.new()
	action:attach(self._AS)
	
	local monster = self._monster
	for i = 1, count do
		self._AS:delaycall(delay + (i - 1) * 0.05, function()
			local l, m, n = 40, 400, 1000
			local x = m - math.random(m * 2)
			local y = m - math.random(m * 2)
			local x2 = n - math.random(n * 2)
			local y2 = m - math.random(m * 2)
			local x3 = l - math.random(l * 2)
			local y3 = l - math.random(l * 2)
			local bullet = self:newBullet(bulletImage)
			local muzzle = self._upCellRoot:add(Sprite.new(muzzleFX))
			muzzle:setLoc(sourceX + x3 + muzzleX, sourceY + y3 + muzzleY)
			muzzle:setPriorityOffset(170)
			local x0, y0 = sourceX, sourceY + y
			bullet:setLoc(x0, y0)
			SoundManager.attackSound[hero.avatarId]:play()
			local a
			a = self._AS:run(function(dt, length)
				if length >= bulletSpeed then
					a:stop()
					SoundManager.impactSound[hero.avatarId]:play()
					bullet:destroy()
					
					self:doDamage(monster, impactFX, damage, destX + 30 + x3, destY + y3)
					if i == count then
						if hero.avatarId ~= "default_hero" then
							self:switchHero("default_hero")
						else
							local a = AvatarConfig:getAvatar(hero.avatarId)
							local deckName, layerName = string.split(a.image, "#")
							hero.avatar:playAnim(layerName, true)
						end
						
						action:stop()
						self:attackFinish(monster)
					end
				
					if math.fmod(i - 1, 2) == 0 then
						self:newDamageNum(damage * 2)
					end
					return
				end
				local x, y = interpolate.bezier(
					sourceX, sourceY,
					sourceX + x, sourceY + y,
					destX - x2, destY + y2,
					destX, destY,
					length)
				bullet:setLoc(x, y)
				bullet:setRot(math2d.angle(x - x0, y - y0))
				x0, y0 = x, y
			end)
		end)
	end
	return action
end

function GamePlay:doPenetrate(hero, delay, bulletImage, bulletSpeed, muzzleFX, muzzleX, muzzleY, impactFX, damage, count, sourceX, sourceY, destX, destY)
	local action = MOAIAction.new()
	action:attach(self._AS)
	
	local monster = self._monster
	for i = 1, count do
		self._AS:delaycall(delay + (i - 1) * 0.05, function()
			local y = 150 - math.random(300)
			local bullet = self:newBullet(bulletImage)
			local muzzle = self._upCellRoot:add(Sprite.new(muzzleFX))
			muzzle:setLoc(sourceX + muzzleX, sourceY + muzzleY)
			muzzle:setPriorityOffset(170)
			bullet:setLoc(sourceX, sourceY)
			SoundManager.attackSound[hero.avatarId]:play()
			local a = bullet:seekLoc(destX + rushDistance, destY + y, bulletSpeed, MOAIEaseType.LINEAR)
			a:setListener(MOAIAction.EVENT_STOP, function()
				SoundManager.impactSound[hero.avatarId]:play()
				bullet:destroy()
			end)
		end)
	end
	
	count = math.floor(count * 0.7)
	for i = 1, count do
		self._AS:delaycall(delay + 0.5 + (i - 1) * 0.1, function()
			SoundManager.impactSound[hero.avatarId]:play()
			
			local x = destX + 25 - math.random(50)
			local y = destY + 25 - math.random(50)
			self:doDamage(monster, impactFX, damage, x, y)
			if i == count then
				if hero.avatarId ~= "default_hero" then
					self:switchHero("default_hero")
				else
					local a = AvatarConfig:getAvatar(hero.avatarId)
					local deckName, layerName = string.split(a.image, "#")
					hero.avatar:playAnim(layerName, true)
				end
				action:stop()
				self:attackFinish(monster)
			end
			
			if math.fmod(i - 1, 2) == 0 then
				self:newDamageNum(damage * 2)
			end
		end)
	end
	return action
end

function GamePlay:doLaser(hero, delay, bulletImage, duration, impactFX, damage, count, sourceX, sourceY, destX, destY)
	local action = MOAIAction.new()
	action:attach(self._AS)
	
	local monster = self._monster
	local n = 1
	local done = function()
		if n == 2 then
			if hero.avatarId ~= "default_hero" then
				self:switchHero("default_hero")
			else
				local a = AvatarConfig:getAvatar(hero.avatarId)
				local deckName, layerName = string.split(a.image, "#")
				hero.avatar:playAnim(layerName, true)
			end
			SoundManager.attackSound[hero.avatarId]:stop()
			action:stop()
			self:attackFinish(monster)
		end
		n = n + 1
	end
	
	self._AS:delaycall(delay, function()
		local bullet = self:newBullet(bulletImage)
		bullet:setLoc(sourceX, sourceY)
		SoundManager.attackSound[hero.avatarId]:play(true)
		bullet.onDestroy = done
		if duration then
			self._AS:delaycall(duration, function()
				bullet:destroy()
			end)
		end
	end)
	
	for i = 1, count do
		self._AS:delaycall(0.5 + (i - 1) * 0.1, function()
			SoundManager.impactSound[hero.avatarId]:play()
			
			local x = destX + 25 - math.random(50)
			local y = destY + 25 - math.random(50)
			self:doDamage(monster, impactFX, damage, x, y)
			if i == count then
				done()
			end
			
			self:newDamageNum(damage)
		end)
	end
	return action
end

function GamePlay:attackFinish(monster, isAlive)
	local isAlive = self:checkMonsterAlive()
	
	self._isAttacking = false
	if self._superSkillBg then
		self._superSkillBg:remove()
	end
	
	if not monster then
		return
	end
	
	eventhub.fire("UI_EVENT", "ATTACK_FINISH")
	self._timingUpdata = true
	
	if isAlive then
		if self:triggerMonsterSkill(monster) then
			self._isMonsterSkilling = true
		end
	end
end

function GamePlay:triggerMonsterSkill(monster)
	local skills = AvatarConfig:getSkills(monster.avatarId)
	if not skills then
		return false
	end
	 
	local num = math.random(1, 100)
	for skill, info in pairs (skills) do
		if info.percent >= num then
			local count = math.random(info.minNum, info.maxNum)
			for i = 1, count do 
				self:doMonsterSkill(monster, skill)
			end
			return true
		else
			num = num - info.percent
		end
	end
	
	return false
end

function GamePlay:doMonsterSkill(monster, skill)
	if skill == "changeball" then
		local c = math.random(1, columns)
		local r = math.random(1, rows)
		local randBall = self:getBall(c, r)
		while not randBall do
			c = math.random(1, columns)
			r = math.random(1, rows)
			randBall = self:getBall(c, r)
		end
		
		self:popBall(c, r)
		
		local newBallId = math.random(1, 5)
		if newBallId == randBall._ballId then
			newBallId = newBallId % 5 + 1
		end
		
		local ball = self:newBall(newBallId)
		ball._column = c
		ball._row = r
		self:setBall(ball)
		
		local fly = self:newFlyEffect3()
		fly:setLoc(monster.avatar:modelToWorld())
		local targetX, targetY = randBall:modelToWorld()
		local a = fly:seekLoc(targetX, targetY, 0.5, MOAIEaseType.LINEAR)
		a:setListener(MOAIAction.EVENT_STOP, function()
			fly:destroy()
			
			randBall:seekColor(0, 0, 0, 0, 0.2)
			local explosion = self:newMonsterSkillExplosion()
			explosion:setLoc(randBall:getLoc())
			explosion.onDestroy = function()
				self:destroyBall(randBall, false)
				
				self:monsterSkillFinish()
				
				--从上往下遍历找该球的位置
				for i = r, 1, -1 do
					if ball == self:getBall(c, i) then
						self._ballFormationRoot:add(ball)
						local x = self._ballLoc[c][i].x
						local y = self._ballLoc[c][i].y
						ball:setLoc(x, y)
						return
					end
				end
				
				-- 找不到位置,直接销毁
				ball:destroy()
			end
		end)
	elseif skill == "removeball" then
		local c = math.random(1, columns)
		local r = math.random(1, rows)
		local randBall = self:getBall(c, r)
		while not randBall do
			c = math.random(1, columns)
			r = math.random(1, rows)
			randBall = self:getBall(c, r)
		end
		self:popBall(c, r)
		
		local targetX, targetY = randBall:modelToWorld()
				
		local fly = self:newFlyEffect3()
		fly:setLoc(monster.avatar:modelToWorld())
		local a = fly:seekLoc(targetX, targetY, 0.5, MOAIEaseType.LINEAR)
		a:setListener(MOAIAction.EVENT_STOP, function()
			fly:destroy()
			
			randBall:seekColor(0, 0, 0, 0, 0.2)
			local explosion = self:newMonsterSkillExplosion()
			explosion:setLoc(randBall:getLoc())
			explosion.onDestroy = function()
				self:destroyBall(randBall, false)
				self:dropBalls()
				
				self:monsterSkillFinish()
			end
		end)
	else
		qlog.debug("No such monster skill", skill)
	end
end

function GamePlay:monsterSkillFinish()
	self._isMonsterSkilling = false
end

function GamePlay:checkMonsterAlive()
	if self._monster.hp > 0 then
		return true
	end
	
	local monsterScore, monsterStep, monsterTime = 0, 0, 0
	if self._gameMode == "stage" then
		monsterScore = GameConfig:getRewardScore(self._curMonsterIndex)
		monsterStep = GameConfig:getRewardStep(self._curMonsterIndex)
	elseif self._gameMode == "mission" then
		monsterScore = Mission:getRewardScore(self._gameIdx, self._curMonsterIndex)
		monsterStep = Mission:getRewardStep(self._gameIdx, self._curMonsterIndex)
	elseif self._gameMode == "timing" then
		monsterScore = Timing:getRewardScore(self._gameIdx, self._curMonsterIndex)
		monsterTime = Timing:getRewardTime(self._gameIdx, self._curMonsterIndex)
	end
	
	self:newExtraScore(monsterScore)
	self:addScore(monsterScore)
	self:incStep(monsterStep)
	if not self._killMode then
		if self._curTime > 0 then
			self:incTime(monsterTime)
		end
	end
	self:switchMonster(true)
	return false
end

function GamePlay:doDamage(monster, impactFX, damage, x, y)
	if monster ~= self._monster then
		return false
	end
	
	local oldHp = self._monster.hp
	self._monster.hp = self._monster.hp - damage
	
	if self._monster.hp < 0 then
		self._monster.hp = 0
	end
	
	--攻击后,伤害清0
	self:setAttackDamage(0)
	
	self:newHitEffect(impactFX, x, y)
	self:monsterHit()	
	
	self:setHp(oldHp, self._monster.hp, 0.5)
	self._monster.shake:add(10, 10)
	
	return true
end

function GamePlay:setHp(oldHp, curHp, time)
	self._monster.hpBar:seekFill(0, oldHp / self._monster.hpMax, 0, curHp / self._monster.hpMax, time)
	local strhp = curHp.."/"..self._monster.hpMax
	self._monster.curhp:setString(strhp)
end

function GamePlay:bombLine(column, row, dirs)
	local bomb = self:getBall(column, row)
	if not bomb then
		return
	end
	
	SoundManager.bombLineSound:play()
	
	self._isAttacking = true
	
	local bombX, bombY = bomb:getLoc()
	self:popBall(column, row)
	bomb:seekColor(0, 0, 0, 0, 0.2)
	local explosion = self:newBombLineEffect()
	explosion:setLoc(bombX, bombY)
	explosion.onDestroy = function()
		self:destroyBall(bomb, false)
	end
	
	local totalNum = 0
	local clearNum = 0
	local clearBallList = 
	{
		[1] = 0,
		[2] = 0,
		[3] = 0,
		[4] = 0,
		[5] = 0,
	}
	for d = 1, 6 do
		local n = dirs[d]
		if n then
			local ray = self:newBombLineRay()
			local w, h = ray:getSize()
			ray:setPiv(0, -h/2)
			ray:setLoc(bombX, bombY)
			ray:setRot((d-1)*60)
			
			local c, r = column, row
			local bombNum = 0
			for i = 1, n do
				c, r = self:nextBall(c, r, d)
				if not c then
					break
				end
				local o = self:getBall(c, r)
				if o and self:isBall(o) then
					totalNum = totalNum + 1
					bombNum = bombNum + 1
					clearBallList[o._ballId] = clearBallList[o._ballId] + 1
					
					self:popBall(c, r)
					self._AS:delaycall(bombNum * 0.1, function()
						o:seekColor(0, 0, 0, 0, 0.2)
						local explosion = self:newExplosion(nil, o:getLoc())
						explosion.onDestroy = function()
							self:destroyBall(o, true)
							clearNum = clearNum + 1
							if clearNum >= totalNum then
								self:dropBalls()
							end
						end
					end)
				end
			end
		end
	end
	
	self:addScore(Formula:calcScoreByBombNum(totalNum))
	
	for ballId, num in ipairs(clearBallList) do
		self:addAttackDamage(Formula:calcDamageByBombNum(ballId, self:getCurBallLevel(ballId), num))
	end
	
	self:heroAttack()
end

function GamePlay:bombRound(column, row, radius)
	local bomb = self:getBall(column, row)
	if not bomb then
		return
	end
	
	SoundManager.bombRoundSound:play()
	
	self._isAttacking = true
	
	local bombX, bombY = bomb:getLoc()
	self:popBall(column, row)
	bomb:seekColor(0, 0, 0, 0, 0.1)
	local explosion = self:newBombRoundEffect()
	explosion:setLoc(bomb:getLoc())
	explosion.onDestroy = function()
		self:destroyBall(bomb, false)
	end
	
	local totalNum = 0
	local clearNum = 0
	local clearBallList = 
	{
		[1] = 0,
		[2] = 0,
		[3] = 0,
		[4] = 0,
		[5] = 0,
	}
	
	local tbOffs
	if math.fmod(column, 2) == 0 then
		tbOffs = GameConfig.evenBombRoundOffs
	else
		tbOffs = GameConfig.singularBombRoundOffs
	end
	
	for _, loc in ipairs (tbOffs) do
		local o = self:getBall(loc.offC + column, loc.offR + row)
		if o and self:isBall(o) then
			totalNum = totalNum + 1
			clearBallList[o._ballId] = clearBallList[o._ballId] + 1
			
			self:popBall(o._column, o._row)
			local a = o:seekLoc(bombX, bombY, 0.5)
			a:setListener(MOAIAction.EVENT_STOP, function()
				self:destroyBall(o, true)
				
				clearNum = clearNum + 1
				if clearNum >= totalNum then
					self:dropBalls()
				end
			end)
		end
	end
	
	self:addScore(Formula:calcScoreByBombNum(totalNum))
	
	for ballId, num in ipairs(clearBallList) do
		self:addAttackDamage(Formula:calcDamageByBombNum(ballId, self:getCurBallLevel(ballId), num))
	end
	
	self:heroAttack()
end

function GamePlay:bombColor(c, r, ballId)
	local bomb = self:getBall(c, r)
	if not bomb then
		return
	end
	
	SoundManager.bombColorSound:play()

	self._isAttacking = true
	
	self:popBall(c, r)
	local bombX, bombY = bomb:getLoc()
	local effect = self:newBombColorEffect()
	effect:setLoc(bombX, bombY)
	
	local destroyBalls = {}
	table.insert(destroyBalls, bomb)
	
	local effects = {}
	table.insert(effects, effect)
	
	for i = 1, columns do
		for j = 1, rows do
			local o = self:getBall(i, j)
			if o and o._ballId == ballId then
				self:popBall(o._column, o._row)
				local x, y = o:getLoc()
				table.insert(destroyBalls, o)
				
				local effect = self:newBombColorEffect()
				effect:setLoc(x, y)
				table.insert(effects, effect)
				
				local line = self:showBombColorLine(bombX, bombY, x, y)
				local a = line:seekColor(0, 0, 0, 0, 1.2)
				a:setListener(MOAIAction.EVENT_STOP, function()
					line:destroy()
				end)
			end
		end
	end
	
	self._AS:delaycall(0.5, function()
		for i, o in pairs (destroyBalls) do
			local explosion = self:newExplosion(nil, o:getLoc())
			explosion.onDestroy = function()
				self:destroyBall(o, true)
				
				effects[i]:destroy()
				effects[i] = nil
				
				if #effects == 0 then
					self:dropBalls()
				end
			end
		end
	end)
	
	--减去炸弹数量
	local totalNum = #destroyBalls - 1
	self._AS:delaycall(0.8, function()
		self:addScore(Formula:calcScoreByBombNum(totalNum))
		self:addAttackDamage(Formula:calcDamageByBombNum(ballId, self:getCurBallLevel(ballId), totalNum))
		self:heroAttack()
	end)
end

function GamePlay:showBombColorLine(sourceX, sourceY, targetX, targetY)
	local lineRoot = self._bombEffectRoot:add(node.new())
	lineRoot:setLoc(sourceX, sourceY)
	
	local line = self:newBombColorLine()
	local lineW, lineH = line:getSize()
	line:setPiv(0, -lineH/2)
	lineRoot:add(line)
	
	-- 长度不足,继续拼
	local dis = math2d.distance(sourceX, sourceY, targetX, targetY)
	local lineCount = math.ceil(dis/lineH)
	for i = 2, lineCount do
		line = self:newBombColorLine()
		line:setPiv(0, -lineH/2)
		line:setLoc(0, lineH*(i-1))
		lineRoot:add(line)
	end
	
	-- 最后一条缩放
	line:setScl(1, (dis%lineH)/lineH)
	
	-- 旋转
	local angle = math2d.angle(targetX - sourceX, targetY - sourceY)
	lineRoot:setRot(angle - 90)
	
	return lineRoot
end

function GamePlay:destroyBall(ball, absorb)
	if not ball then
		return
	end
	
	if absorb and self:isBall(ball) then
		local offX, offY = self._downBg:getLoc()
		local x, y = ball:getLoc()
		local fly = self:newFlyEffect()
		fly:setLoc(x+offX, y+offY)
		
		local targetX, targetY = self._ballLevelList[ball._ballId]:modelToWorld()
		local a = fly:seekLoc(targetX, targetY, 0.5, MOAIEaseType.LINEAR)
		a:setListener(MOAIAction.EVENT_STOP, function()
			SoundManager.absorbSound:play()
			fly:destroy()
			self:addClearBallNum(ball._ballId, 1)
		end)
	end
	
	if ball.discolorTimer then
		ball.discolorTimer:stop()
	end
	
	ball:destroy()
end

function GamePlay:newBall(ballId)
	if not ballId then
		local sum = 100
		for i = 1, 5 do
			local w = self._stage.weights[i] * 100
			local r = math.random(sum)
			if r <= w then
				ballId = i
				break
			end
			sum = sum - w
		end
	end
	
	local ball
	if type(ballId) == "string" then
		ball = self:newBomb(ballId)
	elseif type(ballId) == "number" then
		ball = Image.new(ballImages[ballId])
	else
		ballId = tonumber(ballId)
		if not ballId then
			ballId = math.random(1, 5)
		end
		ball = Image.new(ballImages[ballId])
	end
	
	if not ball then
		qlog.warn("new ball faild", ballId)
		return
	end
	
	ball._ballId = ballId
	return ball
end

function GamePlay:newBomb(bombType)
	local sp
	if bombType == "bombColor" then
		local randomColor = math.random(1, 5)
		sp = Image.new(bombColorImages[randomColor])
		sp.colorIndex = randomColor
		
		sp.discolorTimer = timer.new(2, function()
			sp.colorIndex = sp.colorIndex%(#bombColorImages) + 1
			sp:load(bombColorImages[sp.colorIndex])
		end)
	elseif bombType == "bombLine" or bombType == "bombRound" then
		sp = Image.new(superPowerImages[bombType])
	end
	if not sp then
		qlog.error("unknow bombType", bombType)
		return
	end
	
	sp._supperPowerCb = self.supperPowerCbs[bombType]
	sp._supperPowerArgs = Pet:getSupperPowerArgsByType(bombType)
	return sp
end

function GamePlay:newSuperPower(pet, ball, ballCount)
	if not pet.supperPowerType then
		return
	end
	
	if pet.supperPowerType == "rewardStep" then
		if self._gameMode == "timing" then
			self:incTime(Formula:calcRewardTime(pet.supperPowerSteps, ballCount))
		else
			self:incStep(Formula:calcRewardStep(pet.supperPowerSteps, ballCount))
		end
		return
	end
	
	local sp = self:newBomb(pet.supperPowerType)
	
	sp:setLoc(ball:getLoc())
	sp._ballId = pet.supperPowerType
	sp._column = ball._column
	sp._row = ball._row
	self:setBall(sp)
	return sp
end

function GamePlay:newSelectEffect()
	local selectEffect = Sprite.new(selectEffectImage)
	selectEffect:setBlendMode(MOAIProp.BLEND_ADD)
	return selectEffect
end

function GamePlay:newRemindEffect()
	local remindEffect = Sprite.new(remindEffectImage)
	remindEffect:throttle(0.5)
	-- remindEffect:setBlendMode(MOAIProp.BLEND_ADD)
	return remindEffect
end

function GamePlay:newExplosion(ballId, x, y)
	SoundManager.ballBlastSound:play()
	
	local explosion = nil
	if ballId and ballExplosionEffect[ballId] then
		explosion = self._explosionRoot:add(Sprite.new(ballExplosionEffect[ballId]))
		-- explosion:setBlendMode(MOAIProp.BLEND_ADD)
	else
		explosion = self._explosionRoot:add(Sprite.new(explosionEffect))
		explosion:setBlendMode(MOAIProp.BLEND_ADD)
	end
	explosion:setPriorityOffset(10)
	explosion:setLoc(x, y)
	
	if ballId and ballExplosionParticle[ballId] then
		local particle = self._explosionRoot:add(Particle.new(ballExplosionParticle[ballId], self._AS))
		particle:begin()
		particle:setLoc(x, y)
	end

	return explosion
end

function GamePlay:newSupperExplosion()
	SoundManager.ballBlastSound:play()
	local explosion = self._explosionRoot:add(Sprite.new(explosionEffect))
	explosion:setBlendMode(MOAIProp.BLEND_ADD)
	return explosion
end

function GamePlay:newMonsterSkillExplosion()
	SoundManager.ballBlastSound:play()
	local explosion = self._explosionRoot:add(Sprite.new(fly3_explosionEffect))
	explosion:setBlendMode(MOAIProp.BLEND_ADD)
	return explosion
end

function GamePlay:newBombLineEffect()
	SoundManager.ballBlastSound:play()
	local explosion = self._bombEffectRoot:add(Sprite.new(bombLineEffect))
	explosion:setBlendMode(MOAIProp.BLEND_ADD)
	return explosion
end

function GamePlay:newBombLineRay()
	local ray = self._bombEffectRoot:add(Sprite.new(bombLineRay))
	ray:setBlendMode(MOAIProp.BLEND_ADD)
	return ray
end

function GamePlay:newBombRoundEffect()
	SoundManager.ballBlastSound:play()
	local explosion = self._bombEffectRoot:add(Sprite.new(bombRoundEffect))
	explosion:setBlendMode(MOAIProp.BLEND_ADD)
	return explosion
end

function GamePlay:newBombColorEffect()
	SoundManager.ballBlastSound:play()
	local explosion = self._bombEffectRoot:add(Sprite.new(bombColorEffect))
	explosion:setBlendMode(MOAIProp.BLEND_ADD)
	return explosion
end

function GamePlay:newBombColorLine()
	local line = Sprite.new(bombColorThunder)
	line:setBlendMode(MOAIProp.BLEND_ADD)
	return line
end

function GamePlay:newFlyEffect()
	local effect = self._flyParticleRoot:add(Particle.new(flyParticle, self._AS))
	effect:begin()
	return effect
end

function GamePlay:newFlyEffect2()
	local effect = self._flyParticleRoot:add(Particle.new(flyParticle2, self._AS))
	effect:begin()
	return effect
end

function GamePlay:newFlyEffect3()
	local effect = self._flyParticleRoot:add(Particle.new(flyParticle3, self._AS))
	effect:begin()
	return effect
end

function GamePlay:newBubbleEffect()
	local effect = Particle.new(bubbleParticle, self._AS)
	effect:begin()
	return effect
end

function GamePlay:newAbsorbEffect()
	local effect = Particle.new(absorbParticle, self._AS)
	effect:setPriorityOffset(60)
	effect:begin()
	effect:setScl(1.3)
	return effect
end

function GamePlay:newBallLevelUpEffect()
	local effect = Particle.new(levelUpParticle, self._AS)
	effect:setPriorityOffset(70)
	effect:begin()
	effect:setScl(1.65)
	return effect
end

function GamePlay:newSkillReadyEffect()
	local effect = Particle.new(skillReadyParticle, self._AS)
	-- effect:setPriorityOffset(80)
	effect:begin()
	-- effect:setScl(1.65)
	return effect
end

function GamePlay:newSuperModeEffect()
	local effect = Particle.new(superModeParticle, self._AS)
	effect:begin()
	return effect
end

function GamePlay:newBullet(bulletImage)
	local bullet = self._upCellRoot:add(Sprite.new(bulletImage))
	bullet:setPriorityOffset(150)
	-- bullet:setBlendMode(MOAIProp.BLEND_ADD)
	return bullet
end

function GamePlay:newBulletImage(bulletImage)
	local bullet = self._upCellRoot:add(Image.new(bulletImage))
	bullet:setPriorityOffset(150)
	-- bullet:setBlendMode(MOAIProp.BLEND_ADD)
	return bullet
end

function GamePlay:newHitEffect(impactFX, x, y)
	if not self._monster or not self._monster.avatar then
		return
	end
	local hitEffect = Sprite.new(impactFX)
	hitEffect:setLoc(x, y)
	hitEffect:setPriorityOffset(160)
	self._upCellRoot:add(hitEffect)
	-- hitEffect:setBlendMode(MOAIProp.BLEND_ADD)
	return hitEffect
end

function GamePlay:newDamageNum(damage)
	local font = "sh"
	if self._adddamage then
		font = "sh1"
	end
	
	local damageNum = self._monsterRoot:add(TextBox.new("-"..damage, font, nil, "MM", 300, 60))
	
	local monster, avatar = self:getCurMonsterAvatar()
	
	local randomOff = math.random(-30,30)
	damageNum:setLoc(randomOff+avatar.x, avatar.y)
	local a = damageNum:seekScl(2, 2, 0.1)
	a:setListener(MOAIAction.EVENT_STOP, function()
		a = damageNum:seekScl(1, 1, 0.1)
		a:setListener(MOAIAction.EVENT_STOP, function()
			a = damageNum:seekLoc(randomOff+avatar.x, 100+avatar.y, 0.5)
			a:setListener(MOAIAction.EVENT_STOP, function()
				damageNum:destroy()
			end)
		end)
	end)
end

function GamePlay:newExtraScore(score)
	local monster, avatar = self:getCurMonsterAvatar()
	
	local extraScoreNum = self._monsterRoot:add(TextBox.new("+"..score, "jsjc", nil, "MM", 100, 80))
	local randomOff = math.random(-60,-30)
	extraScoreNum:setLoc(randomOff+avatar.x, avatar.y)
	local a = extraScoreNum:seekScl(5, 5, 0.1)
	a:setListener(MOAIAction.EVENT_STOP, function()
		a = extraScoreNum:seekScl(2, 2, 0.1)
		a:setListener(MOAIAction.EVENT_STOP, function()
			a = extraScoreNum:seekLoc(randomOff+avatar.x, 100+avatar.y, 1)
			a:setListener(MOAIAction.EVENT_STOP, function()
				extraScoreNum:destroy()
			end)
		end)
	end)
end

function GamePlay:dropBalls()
	self._needDrop = true
end

function GamePlay:isDeadEnd()
	local bomb = self:getBomb()
	local remindBallList = self:DFSTraverse(true)
	if #remindBallList < minLinkingCount and not bomb then

		self:noMove()
		return true
	end
	
	return false
end

function GamePlay:update(dt)
	if self._needDrop then
		self._needDrop = nil
		
		for i = 1, columns do
			self:dropColumn(i)
		end
	end
	
	local dropping = false
	for i = 1, columns do
		for j = 1, rows do
			local ball = self:getBall(i, j)
			if ball and ball._destY then
				dropping = true
				ball._v = ball._v + ballA * dt
				local x, y = ball:getLoc()
				y = y - ball._v * dt
				if y < ball._destY then
					y = ball._destY
					ball._v = - ball._v * ballR
					
					if not ball._reboundCount then
						ball._reboundCount = 0
					end
					ball._reboundCount = ball._reboundCount + 1
					if ball._reboundCount >= reboundCount then
						ball._destY = nil
						ball._reboundCount = nil
					end
				end
				ball:setLoc(x, y)
			end
		end
	end
	
	if not dropping and not self._dropBallEnd then
		self._dropBallEnd = true
		eventhub.fire("ROOKIE_EVENT", "ROOKIE_COMPLETE", "dropballend")
	end
	
	if not dropping and not self._isAttacking and not self._isMonsterSkilling and not self._isUsingItem then
		if self._disableTouch then
			self._disableTouch = false
			
			-- 可操作之后,立即提示
			self:startRemind()
		end
	end
end

function GamePlay:countDownEffect()
	local pic = Image.new(countDownPic[self._countDown])
	local countDown = self._countDownRoot:add(pic)
	countDown:setScl(1, 1)
	local c = countDown:seekScl(2, 2, 0.1)
	c:setListener(MOAIAction.EVENT_STOP, function()
		countDown:seekColor(0, 0, 0, 0, 0.8)
		c = countDown:seekScl(0.2, 0.2, 0.8)
		c:setListener(MOAIAction.EVENT_STOP, function()
			countDown:destroy()
		end)
	end)
end

function GamePlay:timeUpdate()
	if self._countDown > 0 then
		self:countDownEffect()
		self._countDown = self._countDown - 1
	else
		if self._timingUpdata then
			self:decTime()
		end
	end
end

function GamePlay:reStart(mission)
	self:stop()
	self:start(mission)
end

function GamePlay:onStart()
	bucket.push("GamePlay")
	self._AS = actionset.new()
	if device.ram < device.RAM_X_HI then
		self._AS:delaycall(0.5, function()
			bucket.softRelease("UI", 10, MOAITexture.CPU_SIDE + MOAITexture.GPU_SIDE)
		end)
	end
	if device.ram == device.RAM_LO then
		local rc = MOAIRenderMgr.getRenderCounter()
		self._AS:repeatcall(120, function()
			local span = math.floor((MOAIRenderMgr.getRenderCounter() - rc) / 2)
			bucket.softRelease("GamePlay", span, MOAITexture.CPU_SIDE + MOAITexture.GPU_SIDE)
			rc = MOAIRenderMgr.getRenderCounter()
		end)
	end
	SoundManager:switchBGM("battle")
end

function GamePlay:start(flag, idx)
	self:onStart()
	
	self:randomBallImage()
	
	self._gameMode = flag
	if flag == "stage" then
		self._countDown = 0
		self._stage =  GameConfig.testStage
		ActLog:startStage()
	elseif flag == "mission" then
		self._countDown = 0
		assert(idx >= 1 and idx <= UserData:getTopMission())
		self._gameIdx = idx
		self._stage =  Mission:getMissionMap(self._gameIdx) or GameConfig.testStage
		ActLog:startMission(self._gameIdx)
	elseif flag == "timing" then
		local mission = Timing:getMissionReq(idx)
		assert(mission)
		assert(idx >= 1 and mission <= UserData:getCurMission())
		self._gameIdx = idx
		self._stage =  GameConfig.testStage
		self._countDown = 4
		self._timingUpdata = true
		self._timer = timer.new(1, function() self:timeUpdate() end)
		UserData:setTimingOpen(self._gameIdx, os.time())
		ActLog:startTiming(self._gameIdx)
	else
		assert(false)
	end
	
	self:initData()
	
	gameLayer:add(self._root)
	
	--再初始化球的阵型
	if self._stage.usedefaultformation then
		self:restoreBallFormation(self._stage.columns)
	else
		self:initBallFormation()
	end
	
	self:newHero("default_hero")
	
	self:switchMonster(false)
	
	ui.setDefaultTouchHandler(self)
	
	self._AS:run(function(dt)
		self:update(dt)
	end)
	
	-- for test
	ui.setDefaultKeyCallback(function(key, down)
		if down then
			self:stopRemind()
			local ballId = key - 48
			if ballId >= 1 and ballId <=5 then
				self:bombColor(4, 3, key - 48)
			elseif ballId == 8 then
				self:bombRound(3, 4, 2)
			end
			
			if key == 32 then
				self:switchMonster(true)
			end
			if key == 27 then
				popupLayer:removeAll()
			end
		end
	end)
	
	FightTopPanel:open(self._curScore, self._curStep, self._curTime, self._curEnergy)
	
	if self._gameMode == "mission" then
		FightTopPanel:setMissionType("normal")
	elseif self._gameMode == "stage" then
		FightTopPanel:setMissionType("infinite")
	elseif self._gameMode == "timing" then
		FightTopPanel:setMissionType("timing")
	end
	
	eventhub.fire("SYSTEM_EVENT", "GAME_DATA_TYPE", "GamePlay")
	
	if not UserData:getRookieGuide("bomb") and self._gameIdx == 2 then
		eventhub.fire("ROOKIE_EVENT", "ROOKIE_TRIGGER", "bomb")
	elseif not UserData:getRookieGuide("skill") and self._gameIdx == 3 then
		eventhub.fire("ROOKIE_EVENT", "ROOKIE_TRIGGER", "skill")
	end
	
	local rookieItem = true
	if not UserData:getRookieGuide("item1") or not UserData:getRookieGuide("item2") or not UserData:getRookieGuide("item3") then
		rookieItem = false
	end
	
	if not UserData:getRookieGuide("item4") and rookieItem then
		eventhub.fire("ROOKIE_EVENT", "ROOKIE_TRIGGER", "item4")
	elseif not UserData:getRookieGuide("item5") and rookieItem then
		eventhub.fire("ROOKIE_EVENT", "ROOKIE_TRIGGER", "item5")
	elseif not UserData:getRookieGuide("item6") and rookieItem then
		eventhub.fire("ROOKIE_EVENT", "ROOKIE_TRIGGER", "item6")
	end
end

function GamePlay:stop()
	if self._gameStopped then
		return
	end
	self._gameStopped = true
	
	ui.setDefaultTouchHandler(nil)
	
	gameLayer:remove(self._root)
	self._AS:removeAll()
	
	FightTopPanel:close()
	
	eventhub.fire("SYSTEM_EVENT", "CLEAR_GAME_DATA")
	eventhub.fire("SYSTEM_EVENT", "GAME_DATA_TYPE", "Null")
	
	SoundManager:switchBGM("world")
	
	self._adddamage = nil
	self._supermodeStep = nil
	
	deviceevent.onBackBtnPressedCallback = function()
		Player:platformQuitReq()
	end
	
	if self._timer then
		self._timer:stop()
		self._timer = nil
	end
end

function GamePlay:gameOver(isWin, isImmediately)
	if self._gameOver then
		return
	end
	
	bucket.pop("GamePlay")
	self._gameOver = true
	self._timingUpdata = false
	
	eventhub.fire("SYSTEM_EVENT", "CLEAR_GAME_DATA")
	eventhub.fire("SYSTEM_EVENT", "GAME_DATA_TYPE", "Null")
	
	while self._attackThread do
		self._attackThread:stop()
		self._attackThread = self._attackThread._prev
	end
	
	local rewardExp = Formula:calcRewardExp(self._curScore, self._curMonsterIndex, self._gameIdx, self._gameMode)
	local rewardGold = Formula:calcRewardGold(self._curScore, self._curMonsterIndex, self._gameIdx, self._gameMode)
	local star = Formula:calcRewardStar(self._curScore, self._useStep, self._gameIdx)

	if isImmediately then
		eventhub.fire("UI_EVENT", "GAME_OVER", self._curMonsterIndex, self._curScore, rewardExp, rewardGold, self._gameIdx, star, isWin, self._gameMode)	
	else
		self:lockBallsPanel()
		self._AS:delaycall(0.75, function()
			self:unlockBallsPanel()
			eventhub.fire("UI_EVENT", "GAME_OVER", self._curMonsterIndex, self._curScore, rewardExp, rewardGold, self._gameIdx, star, isWin, self._gameMode)	
		end)
	end
	
	if isWin then
		eventhub.fire("ROOKIE_EVENT", "ROOKIE_END", "link")
		if self._gameMode == "mission" and self._gameIdx and self._gameIdx == 2 then
			eventhub.fire("ROOKIE_EVENT", "ROOKIE_END", "bomb")
		end
	end
	
	if self._gameMode == "mission" then
		eventhub.fire("TASK_EVENT", "MISSION_START")
		if isWin then
			eventhub.fire("TASK_EVENT", "MISSION_FINISH", 1, self._gameIdx)
		end
		if isWin then
			ActLog:endMission(self._gameIdx, "win", star)
		else
			ActLog:endMission(self._gameIdx, "lose", star)
		end
	elseif self._gameMode == "stage" then
		eventhub.fire("TASK_EVENT", "STAGE_START")
		if isWin then
			eventhub.fire("TASK_EVENT", "STAGE_MONSTER", 1, self._curMonsterIndex)
		else
			eventhub.fire("TASK_EVENT", "STAGE_MONSTER", 1, self._curMonsterIndex - 1)
		end
		ActLog:endStage(self._curMonsterIndex, self._curScore)
	elseif self._gameMode == "timing" then
		eventhub.fire("TASK_EVENT", "TIMING_START")
		ActLog:endTiming(self._curMonsterIndex, self._curScore)
	end	
end

function GamePlay:addAttackDamage(damage)
	self._attackDamage = self._attackDamage + damage
end

function GamePlay:setAttackDamage(damage)
	self._attackDamage = damage
end

function GamePlay:getAttackDamage(damage)
	return self._attackDamage or 0
end

function GamePlay:addEnergy(val)
	local lastVal = self._curEnergy
	self._curEnergy = self._curEnergy + val
	if ((self._curEnergy + math.minnum) >= 1) then
		self._curEnergy = 1
		
		self:setSuperModeTime(superModeTime)
	end
	
	FightTopPanel:fillProgress(lastVal, self._curEnergy, 0.5)
end

function GamePlay:decEnergy(val)
	local lastVal = self._curEnergy
	self._curEnergy = self._curEnergy - val
	if (self._curEnergy < math.minnum) then
		self._curEnergy = 0
	end
	
	FightTopPanel:fillProgress(lastVal, self._curEnergy, 1)
end

function GamePlay:addScore(val)
	self._curScore = self._curScore + val
	FightTopPanel:updateScore(self._curScore)
end

function GamePlay:incStep(val)
	self._curStep = self._curStep + val
	FightTopPanel:updateStep(self._curStep)
	FightTopPanel:showIncStepNum(val)
end

function GamePlay:canDecStep(val)
	if not val then
		val = tbDec[self._gameMode].decStep
	end

	return self._curStep >= val
end

function GamePlay:decStep(val)
	if not val then
		val = tbDec[self._gameMode].decStep
	end

	if not self._stepReminded and self._curStep > 5 and self._curStep - val <= 5 then
		TipPanel:open("steptip")
		self._stepReminded = true
	end

	self._curStep = self._curStep - val
	self._useStep = self._useStep + val
	
	local monsterDead = false
	local monsterRewardStep = 0
	if self._monster.hp <= self:getAttackDamage() then
		monsterDead = true
		
		if self._gameMode == "stage" then
			monsterRewardStep = GameConfig:getRewardStep(self._curMonsterIndex)
		elseif self._gameMode == "mission" then
			monsterRewardStep = Mission:getRewardStep(self._gameIdx, self._curMonsterIndex)
		end
	end
	
	local monsterCount = 0
	if self._gameMode == "stage" then
		monsterCount = #(GameConfig.monsterList)
	elseif self._gameMode == "mission" then
		monsterCount = Mission:getMonsterCount(self._gameIdx)
	elseif self._gameMode == "timing" then
		monsterCount = Timing:getMonsterCount(self._gameIdx)
	end
	
	--步数用尽, boss死的时候加步数为0
	if self._curStep <= 0 and monsterRewardStep == 0 then
		self._curStep = 0
		
		-- 最后一个怪,而且死了的,则走胜利流程
		if self._curMonsterIndex ~= monsterCount or not monsterDead then
			if self._buyStepTimes > 0 then
				self._AS:delaycall(1.5, function()
					eventhub.fire("UI_EVENT", "OPEN_ADDSTEP_PANEL")
				end)
			else
				self:gameOver()
			end
		end
	end
	FightTopPanel:updateStep(self._curStep)
end

function GamePlay:incTime(val)
	self._curTime = self._curTime + val
	FightTopPanel:updateTime(self._curTime)
	FightTopPanel:showIncTimeNum(val)
end

function GamePlay:decTime(val)
	if not val then
		val = tbDec[self._gameMode].decTime
	end

	self._curTime = math.max(self._curTime - val, 0)
	
	if self._curTime <= 0 then
		eventhub.fire("UI_EVENT", "OPEN_TIMING_HELP", "three")
		if self._timer then
			self._timer:stop()
			self._timer = nil
		end
	end
	
	FightTopPanel:updateTime(self._curTime)
end

function GamePlay:addClearBallNum(ballId, count)
	local levelInfo = self._ballLevel[ballId]
	if not levelInfo then
		print("[ERR]GamePlay:addClearBallNum no ball level info", ballId)
		return
	end
	
	levelInfo.curCount = levelInfo.curCount + count
	
	local level, curCount = nil, nil
	if self._gameMode == "stage" then
		level, curCount = BallLevel:calcLevelUp(levelInfo.curLevel, levelInfo.curCount)
	elseif self._gameMode == "mission" then
		level, curCount = Mission:calcBallLevelUp(self._gameIdx, ballId, levelInfo.curLevel, levelInfo.curCount)
	elseif self._gameMode == "timing" then
		level, curCount = BallLevel:calcLevelUp(levelInfo.curLevel, levelInfo.curCount)
	end
	if not level then
		level, curCount = BallLevel:calcLevelUp(levelInfo.curLevel, levelInfo.curCount)
	end
	levelInfo.curCount = curCount
	
	if level > 0 then
		self:addBallLevel(ballId, level)
		self:updateBallLevel(ballId, levelInfo.curLevel, true)
	end
	
	local lastPercent, curPercent = self:calcBallLevelPercent(levelInfo, count, ballId)
	if lastPercent and curPercent then
		self:updateBallLevelBar(ballId, lastPercent, curPercent, 0.5, true)
	end
end

function GamePlay:calcBallLevelPercent(levelInfo, count, ballId)
	local total = BallLevel:getNeedCountByLevel(levelInfo.curLevel+1)
	if self._gameMode == "mission" and Mission.missionMap[self._gameIdx] and Mission.missionMap[self._gameIdx].skillLevelUpCosts then
		total = Mission.missionMap[self._gameIdx].skillLevelUpCosts[ballId][levelInfo.curLevel+1]
	end
	if total then
		local last = levelInfo.curCount - count
		local cur = levelInfo.curCount
		if last < 0 then
			last = 0
		end
		
		return last/total, cur/total
	end
	
	return
end

function GamePlay:addBallLevel(ballId, level)
	local levelInfo = self._ballLevel[ballId]
	if not levelInfo then
		print("[ERR]GamePlay:setBallLevel no ball level info", ballId, debug.traceback())
		return false
	end
	
	local cur = levelInfo.curLevel + level
	if cur > BallLevel.maxLevel then
		return false
	end
	
	levelInfo.curLevel = cur
	return true
end

function GamePlay:subBallLevel(ballId, level)
	local levelInfo = self._ballLevel[ballId]
	if not levelInfo then
		print("[ERR]GamePlay:setBallLevel no ball level info", ballId, debug.traceback())
		return false
	end
	
	local cur = levelInfo.curLevel - level
	if cur < 0 then
		return false
	end
	
	levelInfo.curLevel = cur
	return true
end

function GamePlay:getCurBallLevel(ballId)
	local levelInfo = self._ballLevel[ballId]
	if not levelInfo then
		print("[ERR]GamePlay:getCurBallLevel no ball level info", ballId, debug.traceback())
		return
	end
	
	return levelInfo.curLevel
end

function GamePlay:updateAllBallLevel()
	for ballId, levelInfo in pairs (self._ballLevel) do
		self:updateBallLevel(ballId, levelInfo.curLevel)
		
		local lastPercent, curPercent = self:calcBallLevelPercent(levelInfo, 0, ballId)
		if lastPercent and curPercent then
			self:updateBallLevelBar(ballId, lastPercent, curPercent, 0.5)
		end
	end
end

function GamePlay:updateBallLevel(ballId, val, showEffect)
	if not self._ballLevelTextList[ballId]  then
		return
	end
	
	self._ballLevelTextList[ballId]:setString(""..val)
	
	if showEffect then
		self._ballLevelBgList[ballId]:add(self:newBallLevelUpEffect())
	end
	
	if not self._ballSkillReadyEffect then
		self._ballSkillReadyEffect = {}
	end
	
	if val > 0 and not self._ballSkillReadyEffect[ballId] then
		local effect = self:newSkillReadyEffect()
		self._ballLevelBgList[ballId]:add(effect)
		self._ballSkillReadyEffect[ballId] = effect
	end
	
	if val <= 0 and self._ballSkillReadyEffect[ballId] then
		self._ballSkillReadyEffect[ballId]:destroy()
		self._ballSkillReadyEffect[ballId] = nil
	end
end

function GamePlay:updateBallLevelBar(ballId, startVal, endVal, time, showEffect)
	if not self._ballLevelList[ballId]  then
		return
	end
	
	self._ballLevelList[ballId]:seekFill(0, startVal, 0 , endVal, time)
	
	if showEffect then
		self._ballLevelBgList[ballId]:add(self:newAbsorbEffect())
	end
end

function GamePlay:doSuperSkill(ballId)
	local skill = BallLevel:getBallSkill(ballId)
	if not skill then
		return
	end
	
	ActLog:useSuperSkill(ballId)
	self._disableTouch = true
	self._isAttacking = true
	self._timingUpdata = false
	
	SoundManager.superSkillSound:play()
	
	if not self._superSkillBg then
		self._superSkillBg = Sprite.new(superSkillBg)
		self._superSkillBg:throttle(0.5)
	end
	self._upBg:add(self._superSkillBg)
	
	local effect = self._hero.avatar:add(Sprite.new(superSkillEffect))
	effect:setBlendMode(MOAIProp.BLEND_ADD)
	
	if SoundManager.robotAttackVoice[skill.avatar] then
		SoundManager.robotAttackVoice[skill.avatar]:play()
	end
	
	if skill.image then
		self._AS:delaycall(0.5, function()
			local image = Image.new(skill.image)
			image:setPriorityOffset(50)
			image:setLoc(-device.ui_width/2, -80)
			self._upBg:add(image)
			
			-- local name = Image.new(skill.name)
			-- name:setPriorityOffset(50)
			-- name:setLoc(30, -160)
			-- self._upBg:add(name)
			
			local a = image:seekLoc(-150, -80, 0.5, MOAIEaseType.EASE_IN)
			a:setListener(MOAIAction.EVENT_STOP, function()
				a = image:seekColor(0, 0, 0, 0, 0.3)
				a:setListener(MOAIAction.EVENT_STOP, function()
					image:destroy()
					-- name:destroy()
				end)
			end)
		end)
	end
	
	self._AS:delaycall(1.3, function()
		if skill.avatar then
			self:switchHero(skill.avatar)
		end
	end)
	
	local damage = Formula:calcRobotDamage(ballId)
	
	self._AS:delaycall(1.6, function()
		if true then
			self:addAttackDamage(damage)
		end
		
		self:heroAttack()
	end)
end

function GamePlay:isInRemindList(t, c ,r)
	for _, pos in ipairs (t) do
		if pos[1] == c and pos[2] == r then
			return true
		end
	end
	
	return false
end

function GamePlay:DFS(ballId, centerC, centerR, remindBallList, minTraverse)
	for d = 1, 6 do
		local c, r = self:nextBall(centerC, centerR, d)
		if c and r then
			local ball = self:getBall(c, r)
			if ball and ball._ballId == ballId and not self:isInRemindList(remindBallList, c ,r) then
				table.insert(remindBallList, {c, r})
				if (minTraverse) and (#remindBallList > minLinkingCount) then
					return
				end
				
				self:DFS(ballId, c, r, remindBallList, minTraverse)
			end
		end
	end
	
	return
end

function GamePlay:DFSTraverse(minTraverse)
	if not self._remindCenterC or not self._remindCenterR then
		self._remindCenterC = 4
		self._remindCenterR = 3
	end
	
	local remindBallList = {}
	for c = 1, columns do
		for r = 1, rows do
			remindBallList = {}
			local centerC = (self._remindCenterC + c)%columns
			local centerR = (self._remindCenterR + r)%rows
			local ball = self:getBall(centerC, centerR)
			if ball and self:isBall(ball) then
				table.insert(remindBallList, {centerC, centerR})
				self:DFS(ball._ballId, centerC, centerR, remindBallList, minTraverse)
				
				if #remindBallList >= minLinkingCount then
					return remindBallList
				end
			end
		end
	end
	
	return remindBallList
end

function GamePlay:disableRemind()
	self._remindDisabled = true
	
	self:stopRemind()
end

function GamePlay:enableRemind()
	self._remindDisabled = false
	
	self:startRemind()
end

function GamePlay:startRemind()
	self:stopRemind()
	
	if self._remindDisabled then
		return
	end
	
	if self:isDeadEnd() then
		return
	end
	
	if not self._remindTimer then
		self._remindTimer = timer.new(3, function()
			self:remind()
		end)
	else
		self._remindTimer:start()
	end
end

function GamePlay:stopRemind()
	if self._remindTimer then
		self._remindTimer:stop()
	end
	
	if self._remindEffects and #self._remindEffects > 0 then
		for _, effect in pairs (self._remindEffects) do
			effect:destroy()
		end
	end
	
	self._remindEffects = {}
end

function GamePlay:remind()
	self:stopRemind()
	
	local remindBallList = self:DFSTraverse(false)
	if #remindBallList >= minLinkingCount then
		self:showRemindBalls(remindBallList)
		return
	end
	
	local bomb = self:getBomb()
	if bomb then
		self:showRemindBalls({{bomb._column, bomb._row}})
		return
	end
end

function GamePlay:showRemindBalls(remindBallList)
	for _, pos in ipairs (remindBallList) do
		local ball = self:getBall(unpack(pos))
		local remindEffect = ball:add(self:newRemindEffect())
		table.insert(self._remindEffects, remindEffect)
	end
end

function GamePlay:useItem(index)
	local itemInfo = Item:getItemInfo(index)
	if not itemInfo or not itemInfo.effect then
		return
	end
	
	if itemInfo.effect == "supermode" then
		ActLog:useItem("supermode")
		self:addEnergy(1)
	elseif itemInfo.effect == "resetgame" then
		ActLog:useItem("resetgame")
		self:initBallFormation()
	elseif itemInfo.effect == "fixeddamage" then
		if not itemInfo.effectparam then
			return
		end
		ActLog:useItem("fixeddamage")
		self:addAttackDamage(itemInfo.effectparam)
		self._isAttacking = true
		self:heroAttack()
	elseif itemInfo.effect == "percentdamage" then
		if not itemInfo.effectparam then
			return
		end
		ActLog:useItem("percentdamage")
		self:addAttackDamage(math.floor(self._monster.hpMax * itemInfo.effectparam))
		self._isAttacking = true
		self:heroAttack()
	elseif itemInfo.effect == "addStep" then
		if not itemInfo.effectparam then
			return
		end
		ActLog:useItem("addStep")
		self:useIncStepItem(itemInfo.effectparam, itemInfo.pic)
	elseif itemInfo.effect == "adddamage" then
		ActLog:useItem("adddamage")
		self._adddamage = true
	elseif itemInfo.effect == "supermodeStep" then
		ActLog:useItem("supermodeStep")
		self._supermodeStep = true
	elseif itemInfo.effect == "toolbox" then
		ActLog:useItem("toolbox")
		self._timingUpdata = false
		RandomItemPanel:open(tbRandomItemEffect[self._gameMode])
	elseif itemInfo.effect == "changeareacolor" then
		ActLog:useItem("changeareacolor")
		self:changeAreaColor()
	elseif itemInfo.effect == "addTime" then
		ActLog:useItem("addTime")
		self:useIncTimeItem(itemInfo.effectparam, itemInfo.pic)
	elseif itemInfo.effect == "kickMonster" then
		ActLog:useItem("kickMonster")
		self:useKickMonsterItem(itemInfo.effectparam)
	end
end

function GamePlay:changeAreaColor()
	local formation = Item:getChangeColorFormation()
	if not formation then
		return
	end
	
	self._disableTouch = true
	self._isUsingItem = true
	
	local count = 0
	local changedCount = 0
	local randomBallId = nil
	for _, pos in ipairs (formation) do
		if pos.c and pos.r then
			local c,r = pos.c, pos.r
			local ballId = pos.ballId
			
			count = count + 1
			local old = self:popBall(c, r)
			self._AS:delaycall(count * 0.1, function()
				if old then
					old:seekColor(0, 0, 0, 0, 0.2)
				end
				
				local x = self._ballLoc[c][r].x
				local y = self._ballLoc[c][r].y
				local explosion = self:newExplosion(nil, x, y)
				explosion.onDestroy = function()
					if old then
						self:destroyBall(old, false)
					end
					
					if not ballId then
						if not randomBallId then
							randomBallId = math.random(1, 5)
						end
						
						ballId = randomBallId
					end
					
					local ball = self:newBall(ballId)
					ball:setLoc(x, y)
					ball._column = c
					ball._row = r
					self:setBall(ball)
					self._ballFormationRoot:add(ball)
					
					changedCount = changedCount + 1
					if changedCount == count then
						self._isUsingItem = false
					end
				end
			end)
		end
	end
end

function GamePlay:useIncStepItem(step, image)
	local delayTime = FightTopPanel:showIncStepFlyEffect(image)
	
	self._AS:delaycall(delayTime, function()
		self:incStep(step)
	end)
end

function GamePlay:useIncTimeItem(time, image)
	local delayTime = FightTopPanel:showIncTimeFlyEffect(image)
	
	self._AS:delaycall(delayTime, function()
		self:incTime(time)
	end)
end

function GamePlay:useKickMonsterItem(count)
	if not self._gameMode == "timing" or count < 1 then
		return
	end
	
	self._killMode = true
	
	local monsterCount = Timing:getMonsterCount(self._gameIdx) - self._curMonsterIndex + 1
	if count > monsterCount then
		count = monsterCount
	end
	
	local function doKill()
		count = count - 1
		self:doSuperSkill(math.random(1, 5))		
		local key = nil
		key = eventhub.bind("UI_EVENT", "ATTACK_FINISH", function()
			eventhub.unbind("UI_EVENT", "ATTACK_FINISH", key)
			if count > 0 then
				self._AS:delaycall(1, function()
					doKill()
				end)
			else
				self._AS:delaycall(1, function()
					self:gameOver()
				end)
			end
		end)
	end
	doKill()
end

function GamePlay:randomItemFinish(index)
	local item = tbRandomItemEffect[self._gameMode][index]
	if item[1] == "bombLine" or item[1] == "bombRound" or item[1] == "bombColor" then
		local c = math.random(1, columns)
		local r = math.random(1, rows)
		local randBall = self:getBall(c, r)
		
		--最多随机5次,如果每次都是炸弹,那就替换掉炸弹
		local restRandomNum = 5
		while restRandomNum > 0 and not self:isBall(randBall) do
			c = math.random(1, columns)
			r = math.random(1, rows)
			randBall = self:getBall(c, r)
		
			restRandomNum = restRandomNum - 1	
		end
		
		self:popBall(randBall._column, randBall._row)
		
		local sp = self:newBomb(item[1])
		sp:setLoc(randBall:getLoc())
		sp._ballId = item[1]
		sp._column = randBall._column
		sp._row = randBall._row
		self:setBall(sp)
		
		local targetX, targetY = randBall:modelToWorld()
		local delayTime = RandomItemPanel:itemFly(targetX, targetY)
		self._AS:delaycall(delayTime, function()
			RandomItemPanel:close()
			self:destroyBall(randBall, false)
			self._ballFormationRoot:add(sp)
			self._timingUpdata = true
		end)
	elseif item[1] == "rewardStep" then
		local targetX, targetY = FightTopPanel:getStepLoc()
		local delayTime = RandomItemPanel:itemFly(targetX, targetY)
		self._AS:delaycall(delayTime, function()
			RandomItemPanel:close()
			self:incStep(item[3])
			self._timingUpdata = true
		end)
	elseif item[1] == "rewardTime" then
		local targetX, targetY = FightTopPanel:getTimeLoc()
		local delayTime = RandomItemPanel:itemFly(targetX, targetY)
		self._AS:delaycall(delayTime, function()
			RandomItemPanel:close()
			self:incTime(item[3])
			self._timingUpdata = true
		end)
	elseif item[1] == "rewardLevel" then
		local levelInfo = self._ballLevel[item[3]]
		local count = BallLevel:calcLevelupNeedBallCount(levelInfo.curLevel) - levelInfo.curCount
		if count < 0 then
			count = 0
		end
		
		local targetX, targetY = self._ballLevelList[item[3]]:modelToWorld()
		local delayTime = RandomItemPanel:itemFly(targetX, targetY)
		self._AS:delaycall(delayTime , function()
			RandomItemPanel:close()
			self:addClearBallNum(item[3], count)
			self._timingUpdata = true
		end)
	end
end

function GamePlay:loadData(data)
	if not data then
		return false
	end
	
	self:randomBallImage()
	
	self:onStart()
	deviceevent.onBackBtnPressedCallback = function()
		if not self._gameOver and UserData:rookieGuideisOver() then
			eventhub.fire("UI_EVENT", "SWITCH_PAUSE_PANEL")
		end
	end
	
	self._gameOver = false
	self._gameStopped = false
	self._disableTouch = false
	self._isAttacking = false
	self._isMonsterSkilling = false
	self._isUsingItem = false
	self._dropBallEnd = false
	self._curScore = data._curScore or 0
	self._curStep = data._curStep or GameConfig.initialStep
	self._curEnergy = data._curEnergy or 0
	self._curMonsterIndex = data._curMonsterIndex or 1
	self:setSuperModeTime(data._curSuperModeTime or 0)
	self._buyStepTimes = data._buyStepTimes or GameConfig.buyStepTimes
	self._gameIdx = data._gameIdx
	self._useStep = data._useStep or 0
	self._adddamage = data._adddamage
	self._supermodeStep = data._supermodeStep
	self._gameMode = data._gameMode
	self._curTime = data._curTime
	
	if self._gameMode == "stage" then
		self._countDown = 0
		self._stage =  GameConfig.testStage
	elseif self._gameMode == "mission" then
		self._countDown = 0
		self._stage =  Mission:getMissionMap(self._gameIdx) or GameConfig.testStage
	elseif self._gameMode == "timing" then
		self._stage =  GameConfig.testStage
		self._countDown = 4
		self._timingUpdata = true
		self._timer = timer.new(1, function() self:timeUpdate() end)
		UserData:setTimingOpen(self._gameIdx, os.time())
	end
	
	if data._ballLevel then
		self._ballLevel = data._ballLevel
		self:updateAllBallLevel()
	else
		self:initBallLevel()
	end
	
	self:setAttackDamage(0)

	gameLayer:add(self._root)
	
	if data._ballFormation and not table.empty(data._ballFormation) then
		self:restoreBallFormation(data._ballFormation)
	else
		self:initBallFormation()
	end
	
	self:newHero("default_hero")
	
	self:switchMonster(false)
	if data._hp then
		self._monster.hp = data._hp
		self:setHp(self._monster.hp, self._monster.hp, 0.1)
	end
	
	ui.setDefaultTouchHandler(self)
	
	self._AS:run(function(dt)
		self:update(dt)
	end)
	
	FightTopPanel:open(self._curScore, self._curStep, self._curTime, self._curEnergy)
	
	if self._gameMode == "mission" then
		FightTopPanel:setMissionType("normal")
	elseif self._gameMode == "stage" then
		FightTopPanel:setMissionType("infinite")
	elseif self._gameMode == "timing" then
		FightTopPanel:setMissionType("timing")
	end
	
	eventhub.fire("UI_EVENT", "OPEN_PAUSE_PANEL")
	
	ActLog:recoverGame(self._gameIdx, self._gameMode)
	return true
end

function GamePlay:saveData(data)
	if self._gameOver then
		return
	end
	
	data._curScore = self._curScore
	data._curStep = self._curStep
	data._curEnergy = self._curEnergy
	data._curMonsterIndex = self._curMonsterIndex
	data._curSuperModeTime = self._curSuperModeTime
	data._ballLevel = self._ballLevel
	data._buyStepTimes = self._buyStepTimes
	data._gameIdx = self._gameIdx
	data._gameMode = self._gameMode
	data._useStep = self._useStep
	data._adddamage = self._adddamage
	data._supermodeStep = self._supermodeStep
	data._curTime = self._curTime
	
	data._ballFormation = {}
	if self._balls then
		for c, rows in pairs (self._balls) do
			data._ballFormation[c] = {}
			for r, ball in pairs (rows) do
				if ball then
					data._ballFormation[c][r] = ball._ballId
				end
			end
		end
	end
	
	if self._monster and self._monster.hp then
		data._hp = self._monster.hp
	end
end

function GamePlay:useAddStep()
	if self._buyStepTimes > 0 then
		self._buyStepTimes = self._buyStepTimes - 1
		self:incStep(GameConfig.buySteps)
		ActLog:buyStep(self._buyStepTimes)
	end
end

function GamePlay:getCurMonsterAvatar()
	local m = nil
	
	if self._gameMode == "mission" then
		m = Mission:getMonster(self._gameIdx, self._curMonsterIndex)
	elseif self._gameMode == "stage" then
		m = GameConfig.monsterList[self._curMonsterIndex]
	elseif self._gameMode == "timing" then
		m = Timing:getMonster(self._gameIdx, self._curMonsterIndex)
	end
	
	if not m then
		print("[ERR] error monster index", self._curMonsterIndex)
		return
	end
	local a = AvatarConfig:getAvatar(m.avatarId)
	if not a then
		return
	end
	return m, a
end

function GamePlay:monsterHit()
	local m, a = self:getCurMonsterAvatar()
	if a and a.hitImage then
		self._monster.avatar.idl:remove()
		self._monster.avatar:add(self._monster.avatar.hit)
		self._monster.avatar.hit:playFlash(false, false, function()
			self._monster.avatar.hit:remove()
			self._monster.avatar:add(self._monster.avatar.idl)
			self._monster.avatar.idl:playFlash(true)
		end)
	end
end

function GamePlay:createMonsterAvatar(a)
	self._monster.avatar = self._monsterRoot:add(node.new())
	self._monster.avatar.hit = FlashSprite.new(a.hitImage)
	self._monster.avatar.idl = self._monster.avatar:add(FlashSprite.new(a.idlImage.."?loop=true", true))
end

function GamePlay:setSuperModeTime(second)
	if not self._curSuperModeTime then
		self._curSuperModeTime = 0
	end

	if self._curSuperModeTime == 0 and second > 0 then
		self:superModeBegin()
		
		if self._superModeTimer then
			self._superModeTimer:stop()
		end
		
		self:decEnergy(1/superModeTime)
		self._superModeTimer = timer.new(1, function()
			self:setSuperModeTime(self._curSuperModeTime - 1)
			self:decEnergy(1/superModeTime)
		end)
	end

	if self._curSuperModeTime > 0 and second == 0 then
		if self._superModeTimer then
			self._superModeTimer:stop()
		end
		
		self:superModeEnd()
	end
		
	self._curSuperModeTime = second
end

function GamePlay:isInSuperMode()
	return self._superModing
end

function GamePlay:superModeBegin()
	SoundManager:switchBGM("battle_super")
	FightTopPanel:superModeBegin()
	
	if not self._superModeBg then
		self._superModeBg = node.new()
		self._superModeBg:setLayoutSize(device.ui_width, device.ui_height)
		self._superModeImage = self._superModeBg:add(Image.new(whiteMaskImage))
		
		self:newSuperLightEffect(self._superModeBg)
	end
	
	self._root:add(self._superModeBg)
	self._superModeBg:setPriorityOffset(3)
	
	if not self._superModing then
		if not self._tbSuperAction then
			self._tbSuperAction = {}
		end
		
		table.insert(self._tbSuperAction, self:superModeChangeColor())
		-- self:superModeFlyStar(self._tbEffects, self._tbCurves)
		table.insert(self._tbSuperAction, self:rotateSuperLight(self._leftLightEffect, 50, -50))
		table.insert(self._tbSuperAction, self:rotateSuperLight(self._rightLightEffect, -50, 50))
		
		self._superModeEffect = self._superModeBg:add(self:newSuperModeEffect())
		self._superModeEffect:setLoc(0, -device.ui_height/2+250)
		self._superModeEffect:setPriorityOffset(2)
	end
	
	self._superModing = true
end

function GamePlay:superModeEnd()
	for i, action in pairs (self._tbSuperAction) do
		action:stop()
		self._tbSuperAction[i] = nil
	end
	self._tbSuperAction = nil
	self._superModing = false
	
	self._superModeEffect:destroy()
	self._superModeEffect = nil
	
	SoundManager:switchBGM("battle")
	FightTopPanel:superModeEnd()
	self._root:remove(self._superModeBg)
end

function GamePlay:superModeChangeColor()
	self._superModeImage:setColor(234/255,40/255,15/255,1)
	local action = MOAIThread.new()
	action:attach(self._AS, function()
		while true do
			MOAIThread.blockOnAction(self._superModeImage:seekColor(234/255,133/255,19/255,1,1,MOAIEaseType.LINEAR))
			MOAIThread.blockOnAction(self._superModeImage:seekColor(237/255,175/255,92/255,1,1,MOAIEaseType.LINEAR))
			MOAIThread.blockOnAction(self._superModeImage:seekColor(235/255,160/255,154/255,1,1,MOAIEaseType.LINEAR))
			MOAIThread.blockOnAction(self._superModeImage:seekColor(236/255,67/255,192/255,1,1,MOAIEaseType.LINEAR))
			MOAIThread.blockOnAction(self._superModeImage:seekColor(234/255,32/255,90/255,1,1,MOAIEaseType.LINEAR))
			MOAIThread.blockOnAction(self._superModeImage:seekColor(234/255,40/255,15/255,1,1,MOAIEaseType.LINEAR))
		end
	end)
	
	return action
end

function GamePlay:superModeFlyStar(tbEffects, tbCurves)
	for i, effect in pairs (tbEffects) do
		table.insert(self._tbSuperAction, self:effectMove(effect, tbCurves[i]))
		table.insert(self._tbSuperAction, self:effectRot(effect))
	end
end

function GamePlay:effectRot(effect)
	local action = MOAIThread.new()
	action:attach(self._AS, function()
		while true do
			MOAIThread.blockOnAction(effect:moveRot(360, 2, MOAIEaseType.LINEAR))
		end
	end)
	
	return action
end
		
function GamePlay:effectMove(effect, tbCurve)
	local action = MOAIThread.new()
	action:attach(self._AS, function()
		while true do
			effect:setLoc(tbCurve[1], tbCurve[2])
			MOAIThread.blockOnAction(effect:seekLoc(tbCurve[3], tbCurve[4], tbCurve[5], MOAIEaseType.LINEAR))
		end
	end)
	
	return action
end

function GamePlay:createCurve()
	local srcX = math.random(-device.ui_width / 2, device.ui_width / 2)
	local srcY = math.random(-device.ui_height, 0)
	local destX = math.random(-device.ui_width / 2, device.ui_width / 2)
	local destY = device.ui_height
	local length = (destY - srcY) / device.ui_height
	return {srcX, srcY, destX, destY, length/0.2}
end

function GamePlay:newSuperLightEffect(parent)
	self._leftLightEffect = parent:add(Image.new(superLightLeft))
	self._leftLightEffect:setPriorityOffset(2)
	local w, h = self._leftLightEffect:getSize()
	self._leftLightEffect:setPiv(0, h/2)
	self._leftLightEffect:setAnchor("LT", 0, -50)
	
	self._rightLightEffect = parent:add(Image.new(superLightRight))
	self._rightLightEffect:setPriorityOffset(2)
	local w, h = self._rightLightEffect:getSize()
	self._rightLightEffect:setPiv(0, h/2)
	self._rightLightEffect:setAnchor("RT", 0, -50)
end

function GamePlay:rotateSuperLight(lightEffect, angleDown, angleUp)
	lightEffect:setRot(0)
	local action = MOAIThread.new()
	action:attach(self._AS, function()
		while true do
			MOAIThread.blockOnAction(lightEffect:moveRot(angleDown, 2, MOAIEaseType.LINEAR))
			MOAIThread.blockOnAction(lightEffect:moveRot(angleUp, 2, MOAIEaseType.LINEAR))
		end
	end)
	
	return action
end

function GamePlay:sclBall(ball)
	local curve = interpolate.makeCurve(0, 0.6, MOAIEaseType.LINEAR, 0.1, 1.2, MOAIEaseType.LINEAR, 0.2, 0.9, MOAIEaseType.LINEAR, 0.3, 1.05, MOAIEaseType.LINEAR, 0.4, 1)
	local anim = MOAIAnim.new()
	anim:reserveLinks(2)
	anim:setLink(1, curve, ball, MOAITransform2D.ATTR_X_SCL)
	anim:setLink(2, curve, ball, MOAITransform2D.ATTR_Y_SCL)
	anim:start()
end

function GamePlay:ballLevelOnClick(ballId)
	if self._disableTouch then
		return
	end
	
	if self:getCurBallLevel(ballId) < 1 then
		return
	end
	
	if not UserData:getRobot(ballId) then
		if robotId2BuyIdx[ballId] then
			self._timingUpdata = false
			local tbParam = {}
			tbParam.strIndex = 11
			tbParam.fun = function()
				if UserData:robotUnlock(ballId, true) then
					self._timingUpdata = true
					self:ballLevelOnClick(ballId)
				else
					local successKey, failedKey, cancelKey = nil, nil, nil
					successKey = eventhub.bind("UI_EVENT", "SUPERSKILL_ROBOT", function(idx)
						self._timingUpdata = true
						self:ballLevelOnClick(idx)
						eventhub.unbind("UI_EVENT", "SUPERSKILL_ROBOT", successKey)
						eventhub.unbind("UI_EVENT", "PLAYER_PAY_FAILED", failedKey)
						eventhub.unbind("UI_EVENT", "PLAYER_PAY_CANCEL", cancelKey)
					end)
					failedKey = eventhub.bind("UI_EVENT", "PLAYER_PAY_FAILED", function()
						self._timingUpdata = true
						eventhub.unbind("UI_EVENT", "SUPERSKILL_ROBOT", successKey)
						eventhub.unbind("UI_EVENT", "PLAYER_PAY_FAILED", failedKey)
						eventhub.unbind("UI_EVENT", "PLAYER_PAY_CANCEL", cancelKey)
					end)
					cancelKey = eventhub.bind("UI_EVENT", "PLAYER_PAY_CANCEL", function()
						self._timingUpdata = true
						eventhub.unbind("UI_EVENT", "SUPERSKILL_ROBOT", successKey)
						eventhub.unbind("UI_EVENT", "PLAYER_PAY_FAILED", failedKey)
						eventhub.unbind("UI_EVENT", "PLAYER_PAY_CANCEL", cancelKey)
					end)
					Buy:RMBPay(robotId2BuyIdx[ballId])
				end
			end
			tbParam.closefun = function()
				self._timingUpdata = true
			end
			eventhub.fire("UI_EVENT", "OPEN_MESSAGEBOX", tbParam)
		end
		return
	end
	
	if self:subBallLevel(ballId, 1) then
		self:updateBallLevel(ballId, self:getCurBallLevel(ballId), true)
		self:doSuperSkill(ballId)
		eventhub.fire("ROOKIE_EVENT", "ROOKIE_COMPLETE", "doskill")
	end
end

function GamePlay:randomBallImage()	
	local rand = math.random(3)
	if rand == 2 then
		rand = 4
	elseif rand == 3 then
		rand = 7
	end
	ballImages[1] = "gameplay.atlas.png#"..rand.."_rd.png"
	ballImages[2] = "gameplay.atlas.png#"..rand.."_gn.png"
	ballImages[3] = "gameplay.atlas.png#"..rand.."_pk.png"
	ballImages[4] = "gameplay.atlas.png#"..rand.."_be.png"
	ballImages[5] = "gameplay.atlas.png#"..rand.."_pe.png"
end

function GamePlay:printCurFormation()
	local tbFormation = {}
	for c = 1, columns do
		local isSingle = (c%2 ~= 0)
		local list = {}
		for r = 1, rows do
			local index
			if isSingle then
				index = r * 2
			else
				index = r * 2 - 1
			end
			
			if (index-1) > 0 then
				list[index-1] = ""
			end
			
			local ball = self:getBall(c, r)
			if ball then
				list[index] = ball._ballId
			else
				list[index] = ""
			end
		end
		tbFormation[c] = list
	end
	
	for row = 1, rows*2 do
		local str = ""
		for c, column in ipairs (tbFormation) do
			if column[row] then
				str = str .."\t".. column[row]
			else
				str = str .."\t"
			end
		end
		
		print(str) 
	end
end

return GamePlay
