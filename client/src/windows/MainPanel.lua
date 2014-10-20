
local ui = require "ui"
local Image = require "gfx.Image"
local TextBox = require "gfx.TextBox"
local eventhub = require "eventhub"
local device = require "device"
local node = require "node"
local Sprite = require "gfx.Sprite"
local FlashSprite = require "gfx.FlashSprite"
local Particle = require "gfx.Particle"
local UserData = require "UserData"
local AP = require "settings.AP"
local Buy = require "settings.Buy"
local math2d = require "math2d"
local Mission = require "settings.Mission"
local interpolate = require "interpolate"
local GameConfig = require "settings.GameConfig"
local WindowOpenStyle = require "windows.WindowOpenStyle"
local timer = require "timer"
local Timing = require "settings.Timing"
local AvatarConfig = require "settings.AvatarConfig"


local MainPanel = {}

local backGround1 = "background-01.jpg"
local moneyPic = "ui.atlas.png#money.png"
local goldPic = "ui.atlas.png#gold.png"
local apPic = "ui.atlas.png#engry.png"

local settingPic = "ui.atlas.png#setbtn.png"
local beginBtnBgPic1 = "ui.atlas.png#wj_zhengchang.png"
local beginBtnBgPic2 = "ui.atlas.png#wj_anxia.png"
local stageNumBG1 = "ui.atlas.png#gk_dk_1.png"
local stageNumBG2 = "ui.atlas.png#gk_dk_3.png"
local stageNumBG3 = "ui.atlas.png#gk_dk_2.png"
local star_1 = "ui.atlas.png#gk_xing.png"
local star_2 = nil
local playerPic = "ui.atlas.png#zhaiboshi_ico.png?loc=0, 27"
local rolePic = "ui.atlas.png#role_btn.png"
local jiantouPic = "ui.atlas.png#jiantou.png"
local topbottom = "panel/mask_panel.atlas.png#mask_panel.png"
local activityPic = "ui.atlas.png#hd_tb.png"
local activityNewPic = "ui.atlas.png#hd_tb_1.png"
local awardPic = "ui.atlas.png#lxdl_zs.png"
local shopPic = "ui.atlas.png#bsxd_11.png"
local shopSalePic = "ui.atlas.png#dz_1.png"
local apBGPic = "ui.atlas.png#ap_ban.png"
local timingStageOpen = "ui.atlas.png#xzgk_1.png"
local timingStageClose = "ui.atlas.png#xzgk_2.png"
local timingStageReady = "ui.atlas.png#xzgk_3.png"
local timingStageCloseTip = "ui.atlas.png#xzgk_4.png"
local taskBtn = "ui.atlas.png#rw_tb.png"
local taskNumPic = "ui.atlas.png#rw_ts_di.png"
local timingBtn = "ui.atlas.png#level_icon.png"


local starPex = "guanka_star_xiao.pex"

local moneyX, moneyY = 100, -40
local goldX, goldY = 0, -40
local apX, apY = -100, -40
local socialX, socialY = 60, 180
local mailX, mailY = -60, 320
local messageX, messageY = -60, 220
local beginX, beginY = 0, 80
local textW, textH = 150, 75
local textX, textY = 30, 1
local stageTextX, stageTextY = -70, -120
local enemyH = 80

local xMin, xMax, yMin, yMax = 0, 0, 0, 0

local playerMoveAction = nil
local dragEndAS = nil
local lastX, lastY = 0, 0
local lastTime = 0
local tbDragSamplings = {}

local tbEffect =
{
	{0, 1, MOAIEaseType.LINEAR},
	{0.25, 0, MOAIEaseType.LINEAR},
	{0.5, 1, MOAIEaseType.LINEAR},
	{0.75, 0, MOAIEaseType.LINEAR},
	{1, 1, MOAIEaseType.LINEAR},
	{1.25, 0, MOAIEaseType.LINEAR},
	{1.5, 1, MOAIEaseType.LINEAR},
	{1.75, 0, MOAIEaseType.LINEAR},
	{2, 1, MOAIEaseType.LINEAR},
}

local tbCameraPos =
{
	{0, 1, MOAIEaseType.LINEAR},
	{0, 1, MOAIEaseType.LINEAR},
	{0, 1, MOAIEaseType.LINEAR},
}

local effectTime = 0.3
local miniDistance = 8

local tbPos =
{
	[1] = {0, 0},
	[2] = {10, 5},
	[3] = {20, -5},
	[4] = {10, 5},
	[5] = {0, 0},
	[6] = {-10, -5},
	[7] = {-20, 5},
	[8] = {-10, -5},
	[9] = {0, 0},
}

local tbMapImg = 
{
	"background_6.jpg?loc=0, 3200",
	"background_5.jpg?loc=0, 1920",
	"background_4.jpg?loc=0, 640",
	"background_3.jpg?loc=0, -640",
	"background_2.jpg?loc=0, -1920",
	"background_1.jpg?loc=0, -3200",
}

local tbTimingImg =
{
	[true] = 
	{
		img = timingStageOpen,
		
		[true] = 
		{
			tip = timingStageReady,
		},
		[false] = {},
	},
	[false] = 
	{
		img = timingStageClose,
		tip = timingStageCloseTip,
	},
}


function MainPanel:init()
	eventhub.bind("UI_EVENT", "OPEN_MAIN_PANEL", function(Idx)
		self:open(Idx)
	end)
	eventhub.bind("UI_EVENT", "CLOSE_MAIN_PANEL", function()
		self:close()
	end)
	eventhub.bind("UI_EVENT", "GAME_OVER", function(monsterIdx, score, exp, gold, gameIdx, star, isWin, gameMode)		
		self:gameOver(monsterIdx, score, exp, gold, gameIdx, star, isWin, gameMode)
	end)
	eventhub.bind("UI_EVENT", "MONEY_CHANGE", function()
		self._moneyText:rollNumber(self._money, UserData.money, 1)
		self._money = UserData.money
	end)
	eventhub.bind("UI_EVENT", "GOLD_CHANGE", function()
		self._goldText:rollNumber(self._gold, UserData.gold, 1)
		self._gold = UserData.gold
	end)
	eventhub.bind("UI_EVENT", "AP_CHANGE", function()
		self._apText:rollNumber(self._ap, UserData.ap, 1)
		self._ap = UserData.ap
	end)
	eventhub.bind("UI_EVENT", "MISSION_UPDATE", function(mission)
		self._new = mission

		local starText = UserData:getTotalStar().."/"..Mission:GetMonsterUICount() * 3
		self._totalStarText:setString(starText, true)
		local totalStarTextW = self._totalStarPic:getSize()
		local totalStarTextX, totalStarTextY = self._totalStarPic:getLoc()
		local totalStarPicW = self._totalStarText:getSize()
		self._totalStarText:setLoc(totalStarTextX + totalStarTextW / 2 + totalStarPicW / 2, totalStarTextY)
	end)
	eventhub.bind("ROOKIE_EVENT", "ROOKIE_END", function(name)
		if name == "skill" then
			self._openAwardPanel = true
		end
	end)
	eventhub.bind("UI_EVENT", "TASK_NOACCEPT_COUNT", function(count)
		if count == 0 then
			self._taskCountBg:remove()
		else
			self._taskBtnUp:add(self._taskCountBg)
			self._taskCountText:setString(tostring(count), true)
		end
	end)
	
	self._tbMap = {}
	self._bgRoot = ui.wrap(node.new())
	local w, h = 0, 0
	for i = 1, 6 do
		self._tbMap[i] = self._bgRoot:add(Image.new(tbMapImg[i]))
		local wi, hi = self._tbMap[i]:getSize()
		h = h + hi
		w = wi
	end	
	self._bgRoot:setPriority(1)
	xMin = (device.ui_width - w) / 2
	xMax = (w - device.ui_width) / 2
	yMin = (device.ui_height - h) / 2
	yMax = (h - device.ui_height) / 2
	self._bgRoot.handleTouch = ui.handleTouch
	self._bgRoot.onDragBegin = self.onDragBegin
	self._bgRoot.onDragMove = self.onDragMove
	self._bgRoot.onDragEnd = self.onDragEnd
	self._bgRoot.onTouchDown = self.onTouchDown
	
	self._root = node.new()
	self._root:setPriority(1)
	self._root:setLayoutSize(device.ui_width, device.ui_height)
	
	self._top = self._root:add(Image.new(topbottom))
	self._top:setRot(180)
	self._top:setAnchor("MT", 0, -172)
	self._bottom = self._root:add(Image.new(topbottom))
	self._bottom:setAnchor("MB", 0, 172)
	
	self._money = UserData.money
	self._gold = UserData.gold
	self._ap = UserData.ap
	
	local upMoney = Image.new(moneyPic)
	self._moneyText = upMoney:add(TextBox.new(tostring(UserData.money), "money", nil, "RM", textW, textH))
	self._moneyText:setLoc(textX, textY)
	
	local upGold = Image.new(goldPic)
	self._goldText = upGold:add(TextBox.new(tostring(UserData.gold), "money", nil, "RM", textW, textH))
	self._goldText:setLoc(textX, textY)
	
	local upAP = Image.new(apPic)
	self._apText = upAP:add(TextBox.new(tostring(UserData.ap), "money", nil, "RM", 95, textH))
	self._apText:setLoc(15, textY)
	
	self._moneyBtn = self._root:add(ui.Button.new(upMoney))
	self._moneyBtn:setAnchor("LT", 120, -40)
	self._moneyBtn:setPriorityOffset(2)
	self._moneyBtn.onClick = function()
		eventhub.fire("UI_EVENT", "OPEN_BUY_PANEL", "rmbtomoney")
	end
	
	self._goldBtn = self._root:add(ui.Button.new(upGold))
	self._goldBtn:setAnchor("MT", 40, -40)
	self._goldBtn:setPriorityOffset(2)
	self._goldBtn.onClick = function()
		eventhub.fire("UI_EVENT", "OPEN_BUY_PANEL", "moneytogold")
	end
	
	self._apBtn = self._root:add(ui.Button.new(upAP))
	self._apBtn:setAnchor("RT", -80, -40)
	self._apBtn:setPriorityOffset(2)
	self._apBtn.onClick = function()
		eventhub.fire("UI_EVENT", "OPEN_BUY_PANEL", "moneytoap")
	end
	
	self._roleBtn = self._root:add(ui.Button.new(rolePic))
	self._roleBtn:setAnchor("LB", 75, 70)
	self._roleBtn:setPriorityOffset(2)
	self._roleBtn.onClick = function()
		eventhub.fire("UI_EVENT", "OPEN_ROLE_PANEL")
	end
	
	local settingBtn = self._root:add(ui.Button.new(settingPic, settingPic.."?scl=1.2"))
	settingBtn:setAnchor("RB", -75, 70)
	settingBtn:setPriorityOffset(2)
	settingBtn.onClick = function()
		eventhub.fire("UI_EVENT", "OPEN_SYSTEM_PANEL")
	end
	
	self._beginBtn = ui.Button.new(beginBtnBgPic1)
	self._beginBtn:setPriorityOffset(2)
	self._beginBtn.onClick = function()
		if UserData:getCurMission() >= GameConfig.stageMission then
			eventhub.fire("UI_EVENT", "OPEN_STAGE_PANEL")
		end
	end
	
	local actBtnUp = Image.new(activityPic)
	local actNewUp = actBtnUp:add(Image.new(activityNewPic))
	actNewUp:setLoc(40, 30)
	
	local actBtnDown = Image.new(activityPic.."?scl=1.2")
	local actNewDown = actBtnDown:add(Image.new(activityNewPic))
	actNewDown:setLoc(40, 30)
	
	self._activityBtn = self._root:add(ui.Button.new(actBtnUp, actBtnDown))
	self._activityBtn:setAnchor("RT", -80, -160)
	self._activityBtn:setPriorityOffset(2)
	self._activityBtn.onClick = function()
		eventhub.fire("UI_EVENT", "OPEN_ACTIVITY_PANEL")
	end
	
	self._awardBtn = self._root:add(ui.Button.new(awardPic, 1.2))
	self._awardBtn:setAnchor("RT", -70, -290)
	self._awardBtn:setPriorityOffset(2)
	self._awardBtn.onClick = function()
		eventhub.fire("UI_EVENT", "OPEN_EVERYDAY_PANEL", true)
	end
	
	self._taskBtnUp = Image.new(taskBtn)
	self._taskCountBg = self._taskBtnUp:add(Image.new(taskNumPic))
	self._taskCountBg:setLoc(34, 34)
	self._taskCountText = self._taskCountBg:add(TextBox.new("10", "lock"))
	self._taskCountText:setLoc(-3, 3)
	
	self._taskBtn = self._root:add(ui.Button.new(self._taskBtnUp))
	self._taskBtn:setAnchor("LT", 72, -340)
	self._taskBtn:setPriorityOffset(2)
	self._taskBtn.onClick = function()
		eventhub.fire("UI_EVENT", "OPEN_TASK_PANEL")
	end
	
	local shopBtnUp = Image.new(shopPic)
	local shopSaleUp = shopBtnUp:add(Image.new(shopSalePic))
	shopSaleUp:setLoc(40, 30)
	
	local shopBtnDown = Image.new(shopPic.."?scl=1.2")
	local shopSaleDown = shopBtnDown:add(Image.new(shopSalePic))
	shopSaleDown:setLoc(40, 30)
	
	local shopBtn = self._root:add(ui.Button.new(shopBtnUp, shopBtnDown))
	shopBtn:setAnchor("LT", 70, -200)
	shopBtn:setPriorityOffset(2)
	shopBtn.onClick = function()
		eventhub.fire("UI_EVENT", "OPEN_SHOP_PANEL")
	end
	
	self._totalStarPic = self._root:add(Image.new(star_1))
	self._totalStarPic:setAnchor("LT", 40, -100)
	self._totalStarPic:setPriorityOffset(2)
	local totalStarTextW = self._totalStarPic:getSize()
	local totalStarTextX, totalStarTextY = self._totalStarPic:getLoc()
	
	local starText = UserData:getTotalStar().."/"..Mission:GetMonsterUICount() * 3
	self._totalStarText = self._root:add(TextBox.new(starText, "rw_sz"))
	self._totalStarText:setPriorityOffset(2)
	local totalStarPicW = self._totalStarText:getSize()
	self._totalStarText:setLoc(totalStarTextX + totalStarTextW / 2 + totalStarPicW / 2, totalStarTextY)
	
	
	self._tbStarPex = {}
	for i = 1, 3 do
		self._tbStarPex[i] = Particle.new(starPex, mainAS)
		self._tbStarPex[i]:setScl(0.02)
		self._tbStarPex[i].hitTest = function() return false end
	end
	
	self._apBG = self._root:add(Image.new(apBGPic))
	self._apBG:setAnchor("RT", -50, -80)
	self._apTimeText = self._apBG:add(TextBox.new("1", "timing", nil, "MM", 81))
	self._apTimeText:setScl(0.7, 0.7)
	
	self:CreateStage()
	
	self:CreateTimingStage()
	
	self._open = false
	self._apVisible = true
end

function MainPanel:CreateStage()
	self._stageNode = self._bgRoot:add(node.new())
	self._stageNode:setPriorityOffset(10)
	self._starImg = {}
	self._textBGImg = {}
	for i = 1, Mission:GetMonsterUICount() do
		local monsterInfo = Mission:GetMonsterUIInfo(i)
		
		local btnPic = stageNumBG3
		if UserData:getCurMission() >= i then
			btnPic = stageNumBG1
		end
		
		local up = Image.new(btnPic)
		local text = up:add(TextBox.new(monsterInfo.name, "gk"))
		text:setLoc(0, -22)
		
		self._textBGImg[i] = self._stageNode:add(ui.Button.new(up))
		self._textBGImg[i]:setLoc(monsterInfo.x, monsterInfo.y)
		
		if UserData:getCurMission() >= i then
			self:createStar(i, up, true)
		end
		
		self._textBGImg[i].onClick = function()
			if i <= UserData:getTopMission() then
				eventhub.fire("UI_EVENT", "OPEN_MISSION_PANEL", i)
			end
		end
		self._textBGImg[i].onDragBegin = self.onDragBegin
		self._textBGImg[i].onDragMove = self.onDragMove
		self._textBGImg[i].onDragEnd = self.onDragEnd
		self._textBGImg[i].onTouchDown = self.onTouchDown
	end
	
	local monsterInfo = Mission:GetMonsterUIInfo(UserData:getTopMission())
	local x = math.clamp(monsterInfo.x, xMin, xMax)
	local y = math.clamp(monsterInfo.y, yMin, yMax)
	self._player = self._bgRoot:add(ui.wrap(Image.new(jiantouPic)))
	self._player:add(Image.new(playerPic))
	self._player:setPriorityOffset(50)
	self._player:setLoc(monsterInfo.x, monsterInfo.y + 160)
	self._player.handleTouch = ui.handleTouch
	self._player.onClick = function()
		eventhub.fire("UI_EVENT", "OPEN_MISSION_PANEL", UserData:getTopMission())
	end
end

function MainPanel:createStar(idx, starNode, flag)
	local tbMission = UserData.mission[idx]
	local starPic = {star_2, star_2, star_2}
	if tbMission and flag then
		for i = 1, tbMission.star do
			starPic[i] = star_1
		end
	end
	local star1 = starNode:add(Image.new(starPic[1]))
	star1:setLoc(-37, 25)
	star1:setRot(35)
	star1:setPriorityOffset(2)
	local star2 = starNode:add(Image.new(starPic[2]))
	star2:setLoc(0, 39)
	star2:setPriorityOffset(2)
	local star3 = starNode:add(Image.new(starPic[3]))
	star3:setLoc(37, 26)
	star3:setRot(-35)
	star3:setPriorityOffset(2)
	self._starImg[idx] = {star1, star2, star3}
end

function MainPanel:updateStar(mission)
	local monsterInfo = Mission:GetMonsterUIInfo(mission)
	
	self._textBGImg[mission]:destroy()
	local ani = Sprite.new("ui.atlas.png")
	self._textBGImg[mission] = self._stageNode:add(ui.Button.new(ani, 1.2))
	self._textBGImg[mission]:setLoc(monsterInfo.x - 1, monsterInfo.y + 25)
	ani:playAnim("gk", false, true, function()
		self._textBGImg[mission]:destroy()
		
		local up = Image.new(stageNumBG1)
		local text = up:add(TextBox.new(monsterInfo.name, "gk"))
		text:setLoc(0, -22)
		
		self._textBGImg[mission] = self._stageNode:add(ui.Button.new(up))
		self._textBGImg[mission]:setLoc(monsterInfo.x, monsterInfo.y)
		self._textBGImg[mission].onClick = function()
			if mission <= UserData:getTopMission() then
				eventhub.fire("UI_EVENT", "OPEN_MISSION_PANEL", mission)
			end
		end
		self._textBGImg[mission].onDragBegin = self.onDragBegin
		self._textBGImg[mission].onDragMove = self.onDragMove
		self._textBGImg[mission].onDragEnd = self.onDragEnd
		self._textBGImg[mission].onTouchDown = self.onTouchDown
		
		self:createStar(mission, up, false)
		
		local tbMission = UserData.mission[mission]
		local starPic = {star_2, star_2, star_2}
		if tbMission then
			for i = 1, tbMission.star do
				starPic[i] = star_1
			end
		end
		self._starImg[mission][1]:load(starPic[1])
		if starPic[1] == star_1 then
			self._starImg[mission][1]:add(self._tbStarPex[1])
			self._tbStarPex[1]:begin()
			local c = WindowOpenStyle:nodeJellyEffect(self._starImg[mission][1])
			c:setListener(MOAIAction.EVENT_STOP, function()
				mainAS:delaycall(0.05, function()
					self._starImg[mission][2]:load(starPic[2])
					if starPic[2] == star_1 then
						self._starImg[mission][2]:add(self._tbStarPex[2])
						self._tbStarPex[2]:begin()
						c = WindowOpenStyle:nodeJellyEffect(self._starImg[mission][2])
						c:setListener(MOAIAction.EVENT_STOP, function()
							mainAS:delaycall(0.05, function()
								self._starImg[mission][3]:load(starPic[3])
								if starPic[3] == star_1 then
									self._starImg[mission][3]:add(self._tbStarPex[3])
									self._tbStarPex[3]:begin()
									WindowOpenStyle:nodeJellyEffect(self._starImg[mission][3])
								end
							end)
						end)
					end
				end)
			end)
		end
	end)
	ani:throttle(1.25)
	self._new = nil
end

function MainPanel:CreateTimingStage()
	self._timingBtn = {}
	for key, var in ipairs(Timing) do
		self._timingBtn[key] = {}
		self._timingBtn[key].up = node.new()
		self._timingBtn[key].img = self._timingBtn[key].up:add(Image.new())
		self._timingBtn[key].text = self._timingBtn[key].up:add(TextBox.new("1", "timing", nil, "MM", 200))
		self._timingBtn[key].text:setLoc(-4, -50)
		self._timingBtn[key].btn = self._stageNode:add(ui.Button.new(self._timingBtn[key].up))
		self._timingBtn[key].btn:setLoc(var.x, var.y)
		
		local ac = AvatarConfig:getAvatar(var.monsterList[1].avatarId)
		local monster = FlashSprite.new(ac.idlImage)
		monster:playFlash(true)
		monster:setLoc(unpack(var.monsterLoc))
		local icon = Image.new(timingBtn)
		icon:add(monster)
		
		self._timingBtn[key].monster = monster
		self._timingBtn[key].up:add(icon)
	end
	self:initTimingStage()
end

function MainPanel:initTimingStage(preopen)
	self._tbCountDown = {}
	local topMission = UserData:getCurMission()
	for key, var in ipairs(Timing) do
		local canPlay = topMission >= var.mission
		local ready = self:timingStageIsOpen(key) and canPlay
		local img = tbTimingImg[canPlay].img
		local tip = tbTimingImg[canPlay].tip or tbTimingImg[canPlay][ready].tip
		
		if tip then
			self._timingBtn[key].up:add(self._timingBtn[key].img)
			self._timingBtn[key].img:load(tip)
			self._timingBtn[key].text:remove()
			self._timingBtn[key].img:setLoc(-4, -50)
		else
			self._timingBtn[key].up:add(self._timingBtn[key].text)
			self._timingBtn[key].text:setString(self:getTimingOpenTime(key))
			self._timingBtn[key].img:remove()
			self._tbCountDown[key] = true
		end
		if canPlay then
			self._timingBtn[key].btn.onClick = function()
				self:OpenTimingGame(key)
			end
			
			if preopen and not UserData:getRookieGuide("timing") then 
				eventhub.fire("ROOKIE_EVENT", "ROOKIE_TRIGGER", "timing")
			end
		end
	end
end

function MainPanel:updateTiming()
	for key, var in pairs(self._tbCountDown) do
		local offset = self:getTimingOpenTime(key)
		if offset then
			self._timingBtn[key].text:setString(offset)
		else
			self._timingBtn[key].up:add(self._timingBtn[key].img)
			self._timingBtn[key].img:load(timingStageReady)
			self._timingBtn[key].img:setLoc(-4, -50)
			self._timingBtn[key].text:remove()
			self._tbCountDown[key] = nil
		end
	end
end

function MainPanel:getTimingOpenTime(idx)
	local val = UserData:getTimingOpen(idx)
	local offset = os.time() - val
	local refresh = Timing:getRefreshTime(idx)
	if offset > refresh then
		return
	end
	offset = refresh - offset
	local hours = tostring(math.floor(offset / 3600))
	if string.len(hours) == 1 then
		hours = "0"..hours
	end
	offset = offset % 3600
	local minutes = tostring(math.floor(offset / 60))
	if string.len(minutes) == 1 then
		minutes = "0"..minutes
	end
	local seconds = tostring(offset % 60)
	if string.len(seconds) == 1 then
		seconds = "0"..seconds
	end
	if hours == "00" then
		return minutes..":"..seconds
	end
	return hours..":"..minutes..":"..seconds
end

function MainPanel:timingStageIsOpen(idx)
	local val = UserData:getTimingOpen(idx)
	local now = os.time()
	local offset = now - val
	local refresh = Timing:getRefreshTime(idx)
	return offset > refresh
end

function MainPanel:OpenTimingGame(idx)
	if self:timingStageIsOpen(idx) then
		eventhub.fire("UI_EVENT", "OPEN_TIMING_PANEL", idx)
	else
		eventhub.fire("UI_EVENT", "OPEN_TIMING_HELP", "first", idx)
	end
end

function MainPanel:createCurve()
	local tbPosX = {}
	local tbPosY = {}
	local x, y = self._player:getLoc()
	for key, var in ipairs(tbPos) do
		tbPosX[key] = x + var[1]
		tbPosY[key] = y + var[2]
	end
	local c = interpolate.makeCurve(0, 0, MOAIEaseType.LINEAR, 20, 20)
	local fn = interpolate.newton2d(tbPosX, tbPosY, c)
	return c, fn
end

function MainPanel:playerMove()
	if playerMoveAction then
		playerMoveAction:stop()
		playerMoveAction = nil
	end
	playerMoveAction = mainAS:run(function(dt, length)
		if length >= self._c:getLength() then
			playerMoveAction:stop()
			playerMoveAction = nil
			self:playerMove()
		else
			local x, y = self._fn(length)
			self._player:setLoc(x, y)
		end
	end)
end

function MainPanel:getMissionBtnPos(mission)
	local x, y = self._textBGImg[mission]:getWorldLoc()
	local cX, cY = normalCamera:getLoc()
	return x - cX, y - cY
end

function MainPanel:getTimingBtnPos(idx)
	local x, y = self._timingBtn[idx].btn:getWorldLoc()
	local cX, cY = normalCamera:getLoc()
	return x - cX, y - cY
end

function MainPanel:openUnlockPanel()
	eventhub.fire("UI_EVENT", "OPEN_UNLOCK_PANEL")
end

function MainPanel:openAwardPanel()
	if self._openAwardPanel then
		eventhub.fire("UI_EVENT", "OPEN_EVERYDAY_PANEL")
		self._openAwardPanel = nil
	end
end

function MainPanel:addBeginBtn()
	if UserData:getCurMission() >= GameConfig.stageMission then
		self._root:add(self._beginBtn)
		self._beginBtn:setAnchor("MB", beginX, beginY)
		local x, y = self._beginBtn:getLoc()
		self._beginBtn:setScl(0.3)
		self._beginBtn:seekScl(1, 1, 0.5)
		self._beginBtn:setLoc(0, 0)
		local callback = self._beginBtn:seekLoc(x, y, 0.5)
		return callback
	end
end

function MainPanel:calcAP()
	self._timeInterval = 0
	if UserData.leave then
		local length = os.time() - UserData.leave
		local offLineAP = AP.step * math.floor(length / AP.interval)
		
		if offLineAP > 0 then
			local gapAP = AP.maxAP - UserData.ap
			if gapAP > 0 then
				if gapAP >= offLineAP then
					UserData:addAP(offLineAP)
				elseif gapAP < offLineAP then
					UserData:addAP(gapAP)
				end
			end
		end
		self._timeInterval = length % AP.interval
	end
	UserData:setLeaveTime()	
end

function MainPanel:updateAPTimer()
	self._timeInterval = self._timeInterval + 1
	local now = AP.interval - self._timeInterval
	local minutes = tostring(math.floor(now / 60))
	if string.len(minutes) == 1 then
		minutes = "0"..minutes
	end
	local seconds = tostring(now % 60)
	if string.len(seconds) == 1 then
		seconds = "0"..seconds
	end
	self._apTimeText:setString(minutes..":"..seconds)
	
	if UserData.ap >= AP.maxAP and self._apVisible == true then
		self._apBG:setVisible(false)
		self._apVisible = false
	end
	
	if UserData.ap < AP.maxAP and self._apVisible == false then
		self._apBG:setVisible(true)
		self._apVisible = true
	end
	
	if self._timeInterval == AP.interval then	
		local gapAP = AP.maxAP - UserData.ap
		if gapAP > 0 then
			if gapAP >= AP.step then
				UserData:addAP(AP.step)
			elseif gapAP < AP.step then
				UserData:addAP(gapAP)
			end
		end
		self._timeInterval = 0
		UserData:setLeaveTime()
	end
end

function MainPanel:updateTimer()
	self:updateAPTimer()
	self:updateTiming()
end

function MainPanel:createTimer()
	if self._timer then
		return
	end
	self:calcAP()
	self._timer = timer.new(1, function() self:updateTimer() end)
end

function MainPanel:preOpen(Idx)
	if UserData:getCurMission() >= GameConfig.stageMission and not self._beginBtn._parent and UserData:getRookieGuide("stage") then
		self._root:add(self._beginBtn)
		self._beginBtn:setAnchor("MB", beginX, beginY)
	end
	local monsterInfo = Mission:GetMonsterUIInfo(UserData:getTopMission())
	local x = 0 --math.clamp(monsterInfo.x, xMin, xMax)
	local y = math.clamp(monsterInfo.y, yMin, yMax)
	normalCamera:setLoc(x, y)
	local c = self._player:seekLoc(monsterInfo.x, monsterInfo.y + 160, 1, MOAIEaseType.LINEAR)
	c:setListener(MOAIAction.EVENT_STOP, function()
		self._c, self._fn = self:createCurve()
		self:playerMove()
	end)
	if self._new then
		mainAS:delaycall(0.5, function()
			self:updateStar(self._new)
		end)
	end
	
	self:openUnlockPanel()
	self:openAwardPanel()
	self:initTimingStage(true)
	
	if not UserData:getRookieGuide("pet") then
		eventhub.fire("ROOKIE_EVENT", "ROOKIE_TRIGGER", "pet")
	elseif not UserData:getRookieGuide("robot") then
		eventhub.fire("ROOKIE_EVENT", "ROOKIE_TRIGGER", "robot")
	end
	if UserData:getCurMission() >= GameConfig.stageMission then
		eventhub.fire("ROOKIE_EVENT", "ROOKIE_TRIGGER", "stage")
	end
end

function MainPanel:open(Idx)
	self._open = true
	WindowOpenStyle:openWindowAlpha(self._root)
	WindowOpenStyle:openWindowAlpha(self._bgRoot)
	uiLayer:add(self._root)
	stageLayer:add(self._bgRoot)
	self:preOpen(Idx)
	self:createTimer()
end

function MainPanel:close()
	self._open = false
	uiLayer:remove(self._root)
	stageLayer:remove(self._bgRoot)	
	if playerMoveAction then
		playerMoveAction:stop()
		playerMoveAction = nil
	end
	self._tbCountDown = {}
end

function MainPanel:gameOver(monsterIdx, score, exp, gold, gameIdx, star, isWin, gameMode)
	if gameMode == "stage" then
		UserData:setScore(score)
		UserData:addExp(exp)
		UserData:addGold(gold)
		if isWin then
			UserData:setStage(monsterIdx)
		else
			UserData:setStage(monsterIdx - 1)
		end
	elseif gameMode == "mission" then
		if isWin then
			UserData:addExp(exp)
			UserData:addGold(gold)
			UserData:setMission(gameIdx, star)
		end
	elseif gameMode == "timing" then
		UserData:addExp(exp)
		UserData:addGold(gold)
		UserData:setTimingScore(gameIdx, score)
		if isWin then
			UserData:setTiming(gameIdx, monsterIdx)
		else
			UserData:setTiming(gameIdx, monsterIdx - 1)
		end
	end
end

function MainPanel:onTouchDown()
	if dragEndAS then
		dragEndAS:stop()
		dragEndAS = nil
	end
end

function MainPanel:onDragBegin(touchIdx, x, y, tapCount)
	tbDragSamplings = {}
	lastTime = os.clock()
	lastX, lastY = normalCamera:worldToModel(x, y)
	if dragEndAS then
		dragEndAS:stop()
		dragEndAS = nil
	end
	return true
end

function MainPanel:onDragMove(touchIdx, x, y, tapCount)
	local x, y = normalCamera:worldToModel(x, y)
	local diffY = (y - lastY)
	if math.abs(diffY) < 0.001 then
		return
	end
	
	local curTime = os.clock()
	local intervalTime = curTime - lastTime
	lastTime = curTime
	
	table.insert(tbDragSamplings, {offset = diffY, interval = intervalTime})

	lastX = x
	lastY = y
	
	local cX, cY = normalCamera:getLoc()
	cY = math.clamp(cY - diffY, yMin, yMax)
	normalCamera:setLoc(cX, cY)
end

function MainPanel:onDragEnd(touchIdx, x, y, tapCount)
	if os.clock() - lastTime > 0.1 then
		tbDragSamplings = {}
		return
	end
	
	local sampleTime = 0
	local totalOffset = 0
	for i = #tbDragSamplings, 1, -1 do
		local tempTime = sampleTime + tbDragSamplings[i].interval
		if tempTime > 0.1 then
			break
		end
		
		sampleTime = tempTime
		totalOffset = totalOffset + tbDragSamplings[i].offset
	end
	tbDragSamplings = {}
	
	if sampleTime == 0 or totalOffset == 0 then
		return
	end
	
	local vY = -totalOffset / sampleTime
	
	local c = 0.05
	dragEndAS = mainAS:run(function(dt)
		if dt > 0 then
			local x, y = normalCamera:getLoc()
			
			local dis = vY * dt
			if y + dis >= yMin and y + dis <= yMax then
				vY = vY - vY * c
				
				y = y + dis
				
			else
				vY = 0
			end
			normalCamera:setLoc(x, y)
			
			if math.abs(dis) < 0.5 then
				dragEndAS:stop()
				dragEndAS = nil
			end
		end
	end)
end

--------------------------------------以下为摄像头曲线移动功能--------------------------------------------
-- function MainPanel:stageUpdata(stage)
	-- local tbPos = {}
	-- tbPos[1] = {}
	-- tbPos[2] = {}
	-- for i = 1, stage do
		-- local stageInfo = Stage:GetStageInfo(i)
		-- tbPos[1][i] = math.clamp(stageInfo.x, xMin, xMax)
		-- tbPos[2][i] = math.clamp(stageInfo.y, yMin, yMax)
	-- end
	-- local curveTime = #tbPos[1] * effectTime
	-- local c = interpolate.makeCurve(0, 0, MOAIEaseType.LINEAR, curveTime, curveTime)
	-- local fn = interpolate.lagrange2d(tbPos[1], tbPos[2], c)
	-- local action = nil
	-- action = mainAS:run(function(dt, length)
		-- if length >= c:getLength() then
			-- action:stop()
		-- else
			-- local x, y = fn(length)
			-- local corssIdx = self:corssStage(x, y, stage)
			-- if corssIdx > 0 then
				-- self:stageEffect(corssIdx)
			-- end
			-- normalCamera:setLoc(x, y)
		-- end
	-- end)
-- end

-- function MainPanel:corssStage(x, y, stage)
	-- for i = 1, stage do
		-- local stageInfo = Stage:GetStageInfo(i)
		-- local dis =	math2d.distance(x, y, stageInfo.x, stageInfo.y)
		-- if dis < miniDistance then
			-- return i
		-- end
	-- end
	-- return 0
-- end

-- function MainPanel:stageEffect(Idx)
	-- local curveStage = interpolate.makeCurveByTab(tbEffect)
	-- local anim = MOAIAnim.new()
	-- anim:reserveLinks(1)
	-- anim:setLink(1, curveStage, self._stageImg[Idx], MOAIProp2D.ATTR_A_COL)
	-- anim:start()
-- end

return MainPanel

