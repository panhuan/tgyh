
local ui = require "ui"
local node = require "node"
local Image = require "gfx.Image"
local TextBox = require "gfx.TextBox"
local device = require "device"
local eventhub = require "eventhub"
local UserData = require "UserData"
local gfxutil = require "gfxutil"
local FillBar = require "gfx.FillBar"
local Exp = require "settings.Exp"
local Sprite = require "gfx.Sprite"
local Timing = require "settings.Timing"
local SoundManager = require "SoundManager"
local WindowOpenStyle = require "windows.WindowOpenStyle"
local Mission = require "settings.Mission"
local GameConfig = require "settings.GameConfig"
local PlayerAttr = require "settings.PlayerAttr"
local Text = require "settings.Text"
local Social = require "Social"
local ActLog = require "ActLog"

local finishBgImage = "panel/panel_1.atlas.png#panel_1.png"
local titlePic = "ui.atlas.png#wj_tk.png"
local text1	= "ui.atlas.png#finish_text1.png?loc=-120, 0"
local text2	= "ui.atlas.png#finish_text2.png?loc=140, 0"
local text3	= "ui.atlas.png#finish_level.png?loc=-150, 25"
local goldPic = "ui.atlas.png#gold_small.png?loc=-55, -230"
local btnPic = "ui.atlas.png#stepbtn.png"
local okText = "ui.atlas.png#stepbtn_queding.png"
local shareText = "ui.atlas.png#fenxiang.png"
local hpBgPic = "ui.atlas.png#finish_expbg.png?loc=-48,0"
local hpPic = "finish_exp.png"
local addPic = "ui.atlas.png#finish_exp+.png?loc=132, -130"
local boxPic2 = "ui.atlas.png#stage_finish.png"
local leveljcPic = "ui.atlas.png#dj_jc_di.png"
local topScorePic = "ui.atlas.png#wj_js_wz.png"


local FinishPanel = {}


function FinishPanel:init()
	eventhub.bind("UI_EVENT", "GAME_OVER", function(monsterIdx, score, exp, gold, gameIdx, star, isWin, gameMode)
		if gameMode ~= "mission" then
			self:open(monsterIdx, score, exp, gold, gameIdx, star, isWin, gameMode)
		end
	end)
	
	self._root = ui.PickBox.new(device.ui_width, device.ui_height)
	self._root:setPriorityOffset(20)
	self._bgRoot = Image.new(finishBgImage)
	self._root:add(self._bgRoot)
	self._root:setLayoutSize(Image.getSize(self._bgRoot))

	local scorebg = self._bgRoot:add(Image.new(titlePic))
	scorebg:setAnchor("MT", 0, -150)
	self._scoreText = scorebg:add(TextBox.new("88888", "jswz_da", nil, "MM", 500))
	self._scoreText:setLoc(0, 30)
	self._topScoreText = scorebg:add(TextBox.new("88888", "jswz_xiao"))
	self._topScoreImg = scorebg:add(Image.new(topScorePic))
	
	self._bgRoot:add(Image.new(addPic))
	self._bgRoot:add(Image.new(text1))
	self._bgRoot:add(Image.new(text2))
	self._stageText = self._bgRoot:add(TextBox.new("88888", "ogre"))
	self._stageText:setLoc(25,0)
	
	local expRoot = self._bgRoot:add(Image.new(boxPic2))
	expRoot:setLoc(0, -110)
	expRoot:add(Image.new(text3))
	self._goldLevel = expRoot:add(TextBox.new("88888", "stage"))
	self._goldLevel:setLoc(-70, 25)
	
	self._addExp = expRoot:add(TextBox.new("88888", "exp", nil, "LM"))
	self._addExp:setLoc(185, -22)
	
	self._expBarBG = expRoot:add(Image.new(hpBgPic))
	self._expBarBG:setLoc(-40, -20)
	self._expBar = self._expBarBG:add(FillBar.new(hpPic))
	
	self._curExp = self._expBar:add(TextBox.new("88888", "exp", nil, nil, 300))
	
	self._bgRoot:add(Image.new(goldPic))
	self._goldText = self._bgRoot:add(TextBox.new("88888", "stage", nil, "LM", 300))
	self._goldText:setLoc(120, -230)
	
	self._levelAdd = Image.new(leveljcPic)
	self._levelAdd:setLoc(-230, -150)
	self._levelAdd:setPriorityOffset(5)
	self._levelAdd.hitTest = function() return false end
	
	self._levelText = TextBox.new("1", "jsjc", nil, "LM")
	self._levelText:setLoc(110, -230)
	
	local up1 = Image.new(btnPic)
	up1:add(Image.new(okText))
	
	local okBtn = self._bgRoot:add(ui.Button.new(up1))
	okBtn:setAnchor("MB", -100, 80)
	okBtn.onClick = function()
		self:close()
		eventhub.fire("UI_EVENT", "CLOSE_GAME_PANEL")
		eventhub.fire("UI_EVENT", "OPEN_MAIN_PANEL")
	end
	
	local up2 = Image.new(btnPic)
	up2:add(Image.new(shareText))
	
	local shareBtn = self._bgRoot:add(ui.Button.new(up2))
	shareBtn:setAnchor("MB", 100, 80)
	shareBtn.onClick = function()
		Social.shareUrl(UserData.ShareURL, Text.shareStageScore.title, Text.shareStageScore.desc, true, function(ok)
			ActLog:shareStageScore(tostring(ok))
		end)
	end
	
	self._box = self._bgRoot:add(node.new())
	self._box:setLoc(0, 130)
end

function FinishPanel:stageUpdata(monsterIdx, gameIdx)
	local data = {}
	data.root = self._box
	if self._gameMode == "stage" then
		data.image = Mission:getMonsterBg(1, 1)
	else
		data.image = Timing:getMonsterBg(gameIdx, 1)
	end
	data.x = 0
	data.y = 0
	data.w = 460
	data.h = 155
	data.monster = {}
	if monsterIdx > 1 then
		local count = monsterIdx - 1
		if self._isWin then
			count = monsterIdx
		end
		for i = 1, count do
			local avatar = nil
			if self._gameMode == "stage" then
				avatar = GameConfig:getMonster(i)
			else
				avatar = Timing:getMonster(gameIdx, i)
			end
			data.monster[i] = avatar.avatarId
		end
	end
	eventhub.fire("UI_EVENT", "OPEN_MONSTER_PANEL", data)
end

function FinishPanel:preOpen(monsterIdx, score, exp, gold, gameIdx, star, isWin, gameMode)
	self._isWin = isWin
	self._gameMode = gameMode
	self:stageUpdata(monsterIdx, gameIdx)
	self:setStageText(monsterIdx)
	self:setScoreText(score)
	self:setExpText(exp)
	self:setGoldText(gold)

	Social.setRegister("@STAGE_MONSTER_INDEX", monsterIdx)
	Social.setRegister("@STAGE_SCORE", score)
	
	local thisLevelExp = Exp:getExp(UserData.level)
	if thisLevelExp then
		self._expBar:setFill(0, UserData.exp / thisLevelExp)
		local strExp = UserData.exp.."/"..thisLevelExp
		self._curExp:setString(strExp)
	else
		self._expBar:setFill(0, 1)
		self._curExp:remove()
	end
	
	self._goldLevel:setString(tostring(UserData.level))
	
	self:addGoldByPlayerLevel(gold, score, gameIdx)
	
	self._levelAdd:remove()
	self._levelText:remove()
	
	mainAS:delaycall(1, function()
		self._bgRoot:add(self._levelAdd)
		self._levelAdd:setScl(12, 12)
		self._levelAdd:seekScl(1, 1, 1, MOAIEaseType.EASE_IN)
		self._levelAdd:seekRot(360, 1, MOAIEaseType.EASE_IN)
		local income = PlayerAttr:getIncome(UserData.level)
		if income.gold then
			self._bgRoot:add(self._levelText)
			self._levelText:setString("+"..income.gold.."%", true)
		end
	end)
	
	local score = 0
	if self._gameMode == "stage" then
		score = UserData.score
	elseif self._gameMode == "timing" then
		score = UserData.timingScore[gameIdx] or 0
	end
	self._topScoreText:setString(tostring(score), true)
	local textW = self._topScoreText:getSize()
	local picW = self._topScoreImg:getSize()
	self._topScoreText:setLoc(picW / 2, -10)
	self._topScoreImg:setLoc(-textW / 2, -10)
end

function FinishPanel:addGoldByPlayerLevel(gold, score, gameIdx)
	local income = PlayerAttr:getIncome(UserData.level)
	if income.gold then
		local val = math.floor(gold * income.gold / 100)
		UserData:addGold(val)
		mainAS:delaycall(1.1, function()
			self:setGoldText(val + gold, gold)
		end)
	end
	if income.score then
		local val = math.floor(score * income.score / 100)
		if self._gameMode == "stage" then
			UserData:setScore(val + score)
		elseif self._gameMode == "timing" then
			UserData:setTimingScore(gameIdx, val + score)
		end
		mainAS:delaycall(1.1, function()
			self:setScoreText(val + score, score)
		end)
	end
end

function FinishPanel:open(monsterIdx, score, exp, gold, gameIdx, star, isWin, gameMode)
	self:preOpen(monsterIdx, score, exp, gold, gameIdx, star, isWin, gameMode)
	WindowOpenStyle:openWindowScl(self._bgRoot)
	WindowOpenStyle:openWindowAlpha(self._bgRoot)
	popupLayer:add(self._root)
	SoundManager:switchBGM("win")
	eventhub.fire("UI_EVENT", "STAR_EFFECT_PAPER")
end

function FinishPanel:close()
	self._levelAdd:remove()
	self._levelText:remove()

	popupLayer:remove(self._root)
	eventhub.fire("UI_EVENT", "STOP_EFFECT_PAPER")
	eventhub.fire("UI_EVENT", "CLOSE_MONSTER_PANEL")
end

function FinishPanel:setScoreText(val, begin)
	local begin = begin or 0
	self._scoreText:rollNumber(begin, val, 1)
	
	local a = self._scoreText:seekScl(1.5, 1.5, 0.1)
	a:setListener(MOAIAction.EVENT_STOP, function()
		a = self._scoreText:seekScl(1, 1, 0.2)
	end)
end

function FinishPanel:setExpText(val)
	self._addExp:rollNumber(0, val, 1)
	
	local a = self._addExp:seekScl(1.5, 1.5, 0.1)
	a:setListener(MOAIAction.EVENT_STOP, function()
		a = self._addExp:seekScl(1, 1, 0.2)
	end)
end

function FinishPanel:setGoldText(val, begin)
	local begin = begin or 0
	self._goldText:rollNumber(begin, val, 1)
	
	local a = self._goldText:seekScl(1.5, 1.5, 0.1)
	a:setListener(MOAIAction.EVENT_STOP, function()
		a = self._goldText:seekScl(1, 1, 0.2)
	end)
end

function FinishPanel:setStageText(val)
	if self._isWin then
		self._stageText:setString(tostring(val))
	else
		self._stageText:setString(tostring(val - 1))
	end
end

return FinishPanel
