
local ui = require "ui"
local node = require "node"
local Image = require "gfx.Image"
local Sprite = require "gfx.Sprite"
local TextBox = require "gfx.TextBox"
local FillBar = require "gfx.FillBar"
local device = require "device"
local PausePanel = require "windows.PausePanel"
local gfxutil = require "gfxutil"
local eventhub = require "eventhub"
local Item = require "settings.Item"
local UserData = require "UserData"
local ItemExplanationPanel = require "windows.ItemExplanationPanel"
local Particle = require "gfx.Particle"
local actionset = require "actionset"


local battleTopImage 	= "gameplay.atlas.png#top_panel.png"
local scoreImage 		= "gameplay.atlas.png#game_score.png"
local stepImage			= "gameplay.atlas.png#remaining_steps.png"
local timeImage			= "gameplay.atlas.png#remaining_time.png"
local missionImage		= "gameplay.atlas.png#zi_1.png"
local monsterImage		= "gameplay.atlas.png#monster_title.png"
local energyBarBgImage 	= "gameplay.atlas.png#energy_bar.png"
local energyBarImage 	= "energy.png"
local pauseUpImage 		= "gameplay.atlas.png#pause_a.png"
local energySupterEffect= "gameplay.atlas.png#shanguang?loop=true"

local itemBgImage		= "gameplay.atlas.png#tuxing_di_1.png"
local itemMaskImage		= "gameplay.atlas.png#tuxing_di_2.png"
local itemExplainImage	= "gameplay.atlas.png#shuoming_1.png"

local incStepParticle 	= "upgrade.pex"
local flyParticle 		= "fly4.pex"

local FightTopPanel = {}


function FightTopPanel:init()	
	self._root = node.new()
	self._root:setLayoutSize(device.ui_width, device.ui_height)
	self._root:setPriority(1)
	
	self._topBar = self._root:add(Image.new(battleTopImage))
	local topBarW, topBarH = self._topBar:getSize()
	self._topBar:setAnchor("MT", 0, -topBarH/2+15)
	
	self._scoreImg = self._topBar:add(Image.new(scoreImage))	
	self._scoreImg:setLoc(-200, -2)
	self._scoreText = self._scoreImg:add(TextBox.new("0", "money", nil, "MM", 150, 60))
	self._scoreText:setLoc(40, 0)
	
	self._stepImg = self._topBar:add(Image.new(stepImage))	
	self._stepImg:setLoc(-20, -4)
	self._stepText = self._stepImg:add(TextBox.new("0", "monster", nil, "MM", 100, 60))
	self._stepText:setLoc(30, 0)
	self._timeText = self._stepImg:add(TextBox.new("0", "monster", nil, "MM", 100, 60))
	self._timeText:setLoc(30, 0)
	
	self._engryBarBg = self._topBar:add(Image.new(energyBarBgImage))
	self._engryBarBg:setLoc(140, -2)
	self._engryBar = self._engryBarBg:add(FillBar.new(energyBarImage))
	self._engryBar:setLoc(33, 1)
	self:setProgress(0, 0)
	
	self._energySuperEffect = Sprite.new(energySupterEffect)
	self._energySuperEffect:throttle(0.2)
	
	self.pauseBtn = self._topBar:add(ui.Button.new(pauseUpImage, 1.2))
	self.pauseBtn:setAnchor("RM", -50, -6)
	self.pauseBtn.onClick = function()
		eventhub.fire("UI_EVENT", "OPEN_PAUSE_PANEL")
	end
	
	self._missionImg = self._topBar:add(Image.new(missionImage))
	self._missionImg:setLoc(-topBarW/2 + 80, -80)
	
	self._missionText = self._topBar:add(TextBox.new("0", "mission_num", nil, "MM", 100, 60))
	self._missionText:setLoc(-topBarW/2 + 150, -80)
	
	self._monsterText = self._topBar:add(TextBox.new("0", "monster", nil, "MM", 100, 60))
	self._monsterText:setLoc(0, -80)
	
	self._flyRoot = self._root:add(node.new())
	self._flyRoot:setPriorityOffset(10)
	
	self._itemRoot = self._root:add(node.new())
	self._itemRoot:setAnchor("MB", 0, 63)
	local itemBg = self._itemRoot:add(Image.new(itemBgImage))
	itemBg:setLoc(-255,-15)
	local itemExplainBtn = itemBg:add(ui.Button.new(itemExplainImage, 1.2))
	itemExplainBtn.onClick = function()
		eventhub.fire("UI_EVENT", "OPEN_ITEM_EXPLANATION", "inside")
	end
	
	self:initItemBar()
	self:showItemIco()	
end

function FightTopPanel:initItemBar()
	local tbLoc = 
	{
		{-115, -15},
		{28, -15},
		{170, -15}
	}
	
	self._tbItem = {}
	self._tbItemBtn = {}
	self._tbItemNumList = {}
	for idx = 1, 3 do
		local itemBg = Image.new(itemBgImage)
		itemBg:setLoc(unpack(tbLoc[idx]))
		
		local itemInfo = Item:getItemInfo(idx)
		local itemBtn = itemBg:add(ui.Button.new(itemInfo.pic, 1.2))
		
		local itemMask = itemBg:add(Image.new(itemMaskImage))
		itemMask:setPriorityOffset(4)
		
		local itemNum = UserData:getItemCount(idx)
		local itemNumText = itemBg:add(TextBox.new(""..itemNum, "monster", nil, "MM", 60, 60))
		itemNumText:setLoc(30, -30)
		itemNumText:setPriorityOffset(5)
		
		self._itemRoot:add(itemBg)
		itemBg:setVisible(false)
		
		self._tbItem[idx] = itemBg
		self._tbItemBtn[idx] = itemBtn
		self._tbItemNumList[idx] = itemNumText
	end
	
	eventhub.bind("UI_EVENT", "ITEM_NUM_CHANGE", function(idx, count)
		if idx >= 1 and idx <= 3 then
			self:updateItemNum(idx, count)
		end
	end)
end

function FightTopPanel:showItemIco()
	if UserData:getRookieGuide("item4") then
		self._tbItem[1]:setVisible(true)
		self._tbItemBtn[1].onClick = function()
			eventhub.fire("SYSTEM_EVENT", "REQUEST_USE_ITEM_IN_GAME", 1)
		end
	end
	if UserData:getRookieGuide("item5") then
		self._tbItem[2]:setVisible(true)
		self._tbItemBtn[2].onClick = function()
			eventhub.fire("SYSTEM_EVENT", "REQUEST_USE_ITEM_IN_GAME", 2)
		end
	end
	if UserData:getRookieGuide("item6") then
		self._tbItem[3]:setVisible(true)
		self._tbItemBtn[3].onClick = function()
			eventhub.fire("SYSTEM_EVENT", "REQUEST_USE_ITEM_IN_GAME", 3)
		end
	end
end

function FightTopPanel:open(score, step, time, progress, missionNum, monsterNum)
	uiLayer:add(self._root)
	
	self._flyRoot:setLoc(0, 0)
	
	self._AS = actionset.new()
	
	self._curScore = score
	self:updatePanel(score, step, time, progress, missionNum, monsterNum)
end

function FightTopPanel:close()
	uiLayer:remove(self._root)
	self._AS:removeAll()
end

function FightTopPanel:getStepLoc()
	return self._stepText:modelToWorld()
end

function FightTopPanel:getTimeLoc()
	return self._timeText:modelToWorld()
end

function FightTopPanel:updatePanel(score, step, time, progress)
	self:updateScore(score)
	self:updateStep(step)
	self:updateTime(time)
	self:setProgress(0, progress)
end

function FightTopPanel:fillProgress(lastVal, curVal, time)
	self._engryBar:seekFill(0, lastVal, 0, curVal, time)
end

function FightTopPanel:setProgress(startVal, endVal)
	self._engryBar:setFill(startVal, endVal)
end

function FightTopPanel:updateScore(val)
	self._scoreText:rollNumber(self._curScore, val, 0.5)
	self._curScore = val
end

function FightTopPanel:updateStep(val)
	if not val then
		return
	end

	if self._stepRollAction then
		self._stepRollAction:stop()
		self._stepRollAction = nil
	end
	
	if self._curStep and val > self._curStep then
		self._stepRollAction = self._stepText:rollNumber(self._curStep, val, 0.5)
	else
		self._stepText:setString(""..val)
	end
	
	self._curStep = val
end

function FightTopPanel:updateTime(val)
	if not val then
		return
	end

	if self._timeRollAction then
		self._timeRollAction:stop()
		self._timeRollAction = nil
	end
	
	if self._curTime and val > self._curTime then
		self._timeRollAction = self._timeText:rollNumber(self._curTime, val, 0.5)
	else
		self._timeText:setString(""..val)
	end
	
	self._curTime = val
end

function FightTopPanel:showIncStepNum(step)
	if step < 1 then
		return
	end
	
	local rewardStepNum = self._topBar:add(TextBox.new("+"..step, "jsjc", nil, "MM", 100, 80)) 
	
	local x, y = 0, -100
	rewardStepNum:setLoc(x, y)
	local a = rewardStepNum:seekScl(2, 2, 0.1)
	a:setListener(MOAIAction.EVENT_STOP, function()
		a = rewardStepNum:seekScl(1.4, 1.4, 0.1)
		a:setListener(MOAIAction.EVENT_STOP, function()
			a = rewardStepNum:seekLoc(x, y+50, 2)
			a:setListener(MOAIAction.EVENT_STOP, function()
				rewardStepNum:destroy()
			end)
		end)
	end)
end

function FightTopPanel:showIncTimeNum(val)
	if val < 1 then
		return
	end
	
	local rewardTimeNum = self._topBar:add(TextBox.new("+"..val, "jsjc", nil, "MM", 100, 80)) 
	
	local x, y = 0, -100
	rewardTimeNum:setLoc(x, y)
	local a = rewardTimeNum:seekScl(2, 2, 0.1)
	a:setListener(MOAIAction.EVENT_STOP, function()
		a = rewardTimeNum:seekScl(1.4, 1.4, 0.1)
		a:setListener(MOAIAction.EVENT_STOP, function()
			a = rewardTimeNum:seekLoc(x, y+50, 2)
			a:setListener(MOAIAction.EVENT_STOP, function()
				rewardTimeNum:destroy()
			end)
		end)
	end)
end

function FightTopPanel:showIncStepFlyEffect(image)
	local fly = self._flyRoot:add(self:newFlyEffect())
	local img = self._flyRoot:add(Image.new(image))
	img:setPriorityOffset(5)
	
	local a = img:seekScl(2, 2, 0.1)
	a:setListener(MOAIAction.EVENT_STOP, function()
		img:seekScl(1, 1, 1)
		
		local destX, destY = self:getStepLoc()
		a = self._flyRoot:seekLoc(destX, destY, 1)
		a:setListener(MOAIAction.EVENT_STOP, function()
			img:destroy()
			fly:destroy()
			
			local explosion = self._root:add(self:newIncStepEffect())
			explosion:setLoc(destX, destY)
		end)
	end)
	
	return 1.3
end

function FightTopPanel:showIncTimeFlyEffect(image)
	local fly = self._flyRoot:add(self:newFlyEffect())
	local img = self._flyRoot:add(Image.new(image))
	img:setPriorityOffset(5)
	
	local a = img:seekScl(2, 2, 0.1)
	a:setListener(MOAIAction.EVENT_STOP, function()
		img:seekScl(1, 1, 1)
		
		local destX, destY = self:getTimeLoc()
		a = self._flyRoot:seekLoc(destX, destY, 1)
		a:setListener(MOAIAction.EVENT_STOP, function()
			img:destroy()
			fly:destroy()
			
			local explosion = self._root:add(self:newIncStepEffect())
			explosion:setLoc(destX, destY)
		end)
	end)
	
	return 1.3
end

function FightTopPanel:newIncStepEffect()
	local effect = Particle.new(incStepParticle, self._AS)
	effect:setPriorityOffset(20)
	effect:begin()
	effect:setScl(1.65)
	return effect
end

function FightTopPanel:newFlyEffect()
	local effect = Particle.new(flyParticle, self._AS)
	effect:begin()
	return effect
end

function FightTopPanel:setMissionType(type)
	if type == "normal" then
		self._topBar:add(self._monsterText)
		self._missionImg:load(missionImage)
		self._timeText:remove()
		self._stepImg:add(self._stepText)
		self._stepImg:load(stepImage)
	elseif type == "infinite" then
		self._topBar:remove(self._monsterText)
		self._missionImg:load(monsterImage)
		self._timeText:remove()
		self._stepImg:add(self._stepText)
		self._stepImg:load(stepImage)
	elseif type == "timing" then
		self._topBar:remove(self._monsterText)
		self._missionImg:load(monsterImage)
		self._stepText:remove()
		self._stepImg:add(self._timeText)
		self._stepImg:load(timeImage)
	end
end

function FightTopPanel:updateMissionNum(val)
	self._missionText:setString(""..val)
end

function FightTopPanel:updateMonsterNum(curNum, totalNum)
	self._monsterText:setString(curNum.."/"..totalNum)
end

function FightTopPanel:superModeBegin()
	self._engryBarBg:add(self._energySuperEffect)
end

function FightTopPanel:superModeEnd()
	self._engryBarBg:remove(self._energySuperEffect)
end

function FightTopPanel:updateItemNum(idx, val)
	self._tbItemNumList[idx]:setString(""..val)
end

return FightTopPanel
