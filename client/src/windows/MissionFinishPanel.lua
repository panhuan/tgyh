

local ui = require "ui"
local Image = require "gfx.Image"
local Sprite = require "gfx.Sprite"
local TextBox = require "gfx.TextBox"
local Particle = require "gfx.Particle"
local device = require "device"
local eventhub = require "eventhub"
local FillBar = require "gfx.FillBar"
local UserData = require "UserData"
local Exp = require "settings.Exp"
local AP = require "settings.AP"
local Buy = require "settings.Buy"
local PlayerAttr = require "settings.PlayerAttr"
local WindowOpenStyle = require "windows.WindowOpenStyle"
local SoundManager = require "SoundManager"
local Mission = require "settings.Mission"


local text3	= "ui.atlas.png#finish_level.png?loc=-100, 30"
local hpBgPic = "ui.atlas.png#mission_win_expbg.png?loc=-48,0"
local hpPic = "mission_win_exp.png"
local goldPic = "ui.atlas.png#gold_small.png?loc=-50, -70"
local addPic = "ui.atlas.png#finish_exp+.png?loc=90, 4"
local returnBtnPic1 = "ui.atlas.png#return.png"
local returnBtnPic2 = "ui.atlas.png#return_down.png?scl=1.2"
local restartBtnPic1 = "ui.atlas.png#restart.png"
local restartBtnPic2 = "ui.atlas.png#restart_down.png?scl=1.2"
local nextBtnPic1 = "ui.atlas.png#next.png"
local nextBtnPic2 = "ui.atlas.png#next_down.png?scl=1.2"
local boxPic = "ui.atlas.png#mission_win_box.png?loc=0, 20"
local effectBG = "panel/mission_win_bg.atlas.png#mission_win_bg.png?loc=0, 300&scl=1.8"
local leveljcPic = "ui.atlas.png#dj_jc_di.png"

local tbPic = 
{
	[true] =
	{
		finishBgImage = "panel/mission_finish_1.atlas.png#mission_finish_1.png?loc=0, -50",
		text = "ui.atlas.png#mission_win.png?loc=0, 135",
		title = "panel/win_title.atlas.png#win_title.png"
	},
	[false] = 
	{
		finishBgImage = "panel/mission_finish_2.atlas.png#mission_finish_2.png",
		text = "ui.atlas.png#mission_lose.png?loc=0, 40",
		title = "panel/fail_title.atlas.png#fail_title.png"
	},
}

local tbStar =
{
	[1] = 
	{
		"ui.atlas.png#star2",
		"ui.atlas.png#star2_big.png?loc=-150, -120",
		"star2",
		"guanka_star.pex",
		"shengli_star.pex",
	},
	[2] = 
	{
		"ui.atlas.png#star1",
		"ui.atlas.png#star1_big.png?loc=0, -90",
		"star1",
		"guanka_star.pex",
		"shengli_star.pex",
	},
	[3] = 
	{
		"ui.atlas.png#star3",
		"ui.atlas.png#star3_big.png?loc=150, -120",
		"star3",
		"guanka_star.pex",
		"shengli_star.pex",
	},
}


local MissionFinishPanel = {}


function MissionFinishPanel:init()
	eventhub.bind("UI_EVENT", "GAME_OVER", function(monsterIdx, score, exp, gold, gameIdx, star, isWin, gameMode)
		if gameMode == "mission" then
			self:open(monsterIdx, score, exp, gold, gameIdx, star, isWin)
		end
	end)
	
	self._root = ui.PickBox.new(device.ui_width, device.ui_height)
	self._root:setPriorityOffset(20)
	self._bgRoot = Image.new()
	self._bgRoot:setPriorityOffset(5)
	self._root:add(self._bgRoot)
	
	self._title = self._bgRoot:add(Image.new())
	self._tbStar = {}
	for i = 1, 3 do
		self._tbStar[i] = 
		{
			bg = Image.new(tbStar[i][2]),
			star = Sprite.new(tbStar[i][1]),
			starPex1 = Particle.new(tbStar[i][4], mainAS),
			starPex2 = Particle.new(tbStar[i][5], mainAS),
		}
		self._tbStar[i].star:setPriorityOffset(5)
		self._tbStar[i].star.hitTest = function() return false end
		self._tbStar[i].starPex1.hitTest = function() return false end
		self._tbStar[i].starPex2.hitTest = function() return false end
	end
	self._tbStar[2].starPex2:setScl(0.7)
	self._tbStar[3].starPex2:setScl(0.7)
	
	self._text = self._bgRoot:add(Image.new())
	
	self._expRoot = self._bgRoot:add(Image.new(boxPic))
	self._expRoot:add(Image.new(text3))
	self._goldLevel = self._expRoot:add(TextBox.new("88888", "stage"))
	self._goldLevel:setLoc(-30, 30)
	
	self._addExp = self._expRoot:add(TextBox.new("88888", "exp", nil, "LM"))
	self._addExp:setLoc(142, -18)
	
	self._expBarBG = self._expRoot:add(Image.new(hpBgPic))
	self._expBarBG:setLoc(-45, -15)
	self._expBar = self._expBarBG:add(FillBar.new(hpPic))
	
	self._curExp = self._expBar:add(TextBox.new("88888", "exp", nil, nil, 300))
	
	self._goldIco = self._bgRoot:add(Image.new(goldPic))
	self._goldText = self._bgRoot:add(TextBox.new("88888", "stage", nil, "LM"))
	self._goldText:setLoc(35, -70)
	
	self._add = self._bgRoot:add(Image.new(addPic))
	
	self._effectbg = Image.new(effectBG)
	
	self._levelAdd = Image.new(leveljcPic)
	self._levelAdd:setLoc(-170, -20)
	self._levelAdd:setPriorityOffset(5)
	self._levelAdd.hitTest = function() return false end
	
	self._levelText = TextBox.new("1", "jsjc", nil, "LM")
	self._levelText:setLoc(110, -70)
	
	self._returnBtn = self._bgRoot:add(ui.Button.new(returnBtnPic1, returnBtnPic2))
	self._returnBtn.onClick = function()
		self:close()
		eventhub.fire("UI_EVENT", "CLOSE_GAME_PANEL")
		eventhub.fire("UI_EVENT", "OPEN_MAIN_PANEL")
		if not self._isWin then
			eventhub.fire("UI_EVENT", "OPEN_FAILEDTIP_PANEL")
		end
	end
	
	self._restartBtn = self._bgRoot:add(ui.Button.new(restartBtnPic1, restartBtnPic2))
	self._restartBtn.onClick = function()
		self:close()
		eventhub.fire("UI_EVENT", "CLOSE_GAME_PANEL")
		eventhub.fire("UI_EVENT", "OPEN_MAIN_PANEL", self._missionIdx)
	end
	
	self._nextBtn = self._bgRoot:add(ui.Button.new(nextBtnPic1, nextBtnPic2))
	self._nextBtn.onClick = function()
		self:close()
		eventhub.fire("UI_EVENT", "CLOSE_GAME_PANEL")
		if self._missionIdx < Mission:GetMonsterUICount() then
			eventhub.fire("UI_EVENT", "OPEN_MAIN_PANEL", self._missionIdx + 1)
		else
			eventhub.fire("UI_EVENT", "OPEN_MAIN_PANEL")
		end
	end
end

function MissionFinishPanel:initByResult(monsterIdx, score, exp, gold, gameIdx, star, isWin)
	self._missionIdx = gameIdx
	isWin = isWin or false
	self._isWin = isWin
	self._bgRoot:load(tbPic[isWin].finishBgImage)
	self._root:setLayoutSize(Image.getSize(self._bgRoot))
	self._text:load(tbPic[isWin].text)
	self._title:setAnchor("MT", 0, 50)
	self._title:load(tbPic[isWin].title)
	
	for i = 1, 3 do
		self._tbStar[i].starPex1:cancel()
		self._tbStar[i].starPex1:remove()
		self._tbStar[i].starPex2:cancel()
		self._tbStar[i].starPex2:remove()
		self._tbStar[i].star:stopAnim()
		self._tbStar[i].star:remove()
		self._tbStar[i].bg:remove()
	end
	
	self._effectbg:remove()
	self._levelAdd:remove()
	self._levelText:remove()
	
	if isWin then
		for i = 1, 3 do
			local bg = self._title:add(self._tbStar[i].bg)
			local o = self._tbStar[i].star
			local pex1 = self._tbStar[i].starPex1
			if i <= star then
				mainAS:delaycall(0.5 + (i - 1) * 0.3, function()
					bg:add(pex1)
					pex1:begin()
					bg:add(o)
					o:setScl(12, 12)
					o:seekScl(1, 1, 1, MOAIEaseType.EASE_IN)
					o:seekRot(360, 1, MOAIEaseType.EASE_IN)
					SoundManager.starAward:play()
				end)
			end
		end
		mainAS:delaycall(0.5 + (star - 1) * 0.3 + 1, function()
			for i = 1, 3 do
				self._tbStar[i].star:playAnim(tbStar[i][3], true, false)
				self._tbStar[i].star:add(self._tbStar[i].starPex2)
				self._tbStar[i].starPex2:begin()
			end
			self._root:add(self._effectbg)
			self._thread = MOAIThread.new()
			self._thread:attach(mainAS, function()
				while true do
					MOAIThread.blockOnAction(self._effectbg:moveRot(72, 1, MOAIEaseType.LINEAR))
				end
			end)				
		end)
		mainAS:delaycall(0.5 + star * 0.3, function()
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
		self._bgRoot:add(self._goldIco)
		self._bgRoot:add(self._goldText)
		self._bgRoot:add(self._expRoot)
		self._bgRoot:add(self._nextBtn)
		self._bgRoot:add(self._add)
		self._restartBtn:remove()
		--self._restartBtn:setAnchor("MB", 0, 120)
		self._returnBtn:setAnchor("MB", -80, 135)
		self._nextBtn:setAnchor("MB", 80, 135)
		self:setExpText(exp)
		self:setGoldText(gold)
		
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
		
		self:addGoldByPlayerLevel(gold)
	else
		self._goldIco:remove()
		self._goldText:remove()
		self._expRoot:remove()
		self._nextBtn:remove()
		self._add:remove()
		self._effectbg:remove()
		self._bgRoot:add(self._restartBtn)
		self._returnBtn:setAnchor("MB", -80, 140)
		self._restartBtn:setAnchor("MB", 80, 140)
	end
end

function MissionFinishPanel:addGoldByPlayerLevel(gold)
	local income = PlayerAttr:getIncome(UserData.level)
	if income.gold then
		local val = math.floor(gold * income.gold / 100)
		UserData:addGold(val)
		mainAS:delaycall(2, function()
			self:setGoldText(val + gold, gold)
		end)
	end
end

function MissionFinishPanel:setExpText(val)
	self._addExp:rollNumber(0, val, 1)
	
	local a = self._addExp:seekScl(1.5, 1.5, 0.1)
	a:setListener(MOAIAction.EVENT_STOP, function()
		a = self._addExp:seekScl(1, 1, 0.2)
	end)
end

function MissionFinishPanel:setGoldText(val, begin)
	local begin = begin or 0
	self._goldText:rollNumber(begin, val, 1)
	
	local a = self._goldText:seekScl(1.5, 1.5, 0.1)
	a:setListener(MOAIAction.EVENT_STOP, function()
		a = self._goldText:seekScl(1, 1, 0.2)
	end)
end

function MissionFinishPanel:open(monsterIdx, score, exp, gold, gameIdx, star, isWin)
	WindowOpenStyle:openWindowScl(self._bgRoot)
	WindowOpenStyle:openWindowAlpha(self._bgRoot)
	popupLayer:add(self._root)
	self:initByResult(monsterIdx, score, exp, gold, gameIdx, star, isWin)
	if self._isWin then
		SoundManager:switchBGM("win")
		eventhub.fire("UI_EVENT", "STAR_EFFECT_PAPER")
	else
		SoundManager:switchBGM("lost")
		eventhub.fire("UI_EVENT", "STAR_EFFECT_SNOW")
	end
end

function MissionFinishPanel:close()
	for i = 1, 3 do
		self._tbStar[i].starPex1:cancel()
		self._tbStar[i].starPex1:remove()
		self._tbStar[i].starPex2:cancel()
		self._tbStar[i].starPex2:remove()
		self._tbStar[i].star:stopAnim()
		self._tbStar[i].star:remove()
		self._tbStar[i].bg:remove()
	end
	
	self._effectbg:remove()
	self._levelAdd:remove()
	self._levelText:remove()
	
	if self._thread then
		self._thread:stop()
		self._thread = nil
	end
	
	popupLayer:remove(self._root)
	
	if self._isWin then
		eventhub.fire("UI_EVENT", "STOP_EFFECT_PAPER")
	else
		eventhub.fire("UI_EVENT", "STOP_EFFECT_SNOW")
	end
end

return MissionFinishPanel