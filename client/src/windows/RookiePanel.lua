

local ui = require "ui"
local device = require "device"
local Image = require "gfx.Image"
local eventhub = require "eventhub"
local MainPanel = require "windows.MainPanel"
local RolePanel = require "windows.RolePanel"
local PetPanel = require "windows.PetPanel"
local FightTopPanel = require "windows.FightTopPanel"
local WindowOpenStyle = require "windows.WindowOpenStyle"
local MissionStartPanel = require "windows.MissionStartPanel"
local GamePlay = require "GamePlay"
local UserData = require "UserData"
local BallLevel = require "settings.BallLevel"
local interpolate = require "interpolate"


local handPic = "rookie.atlas.png#shouzhi.png"
local msgBox = "rookie.atlas.png#duihuakuang.png"
local role = "rookie.atlas.png#taozi_rookie.png"

local ballc1, ballr1 = 3, 4
local ballc2, ballr2 = 3, 5
local ballc3, ballr3 = 3, 6

local tbBallcr = 
{
	{1, 5},
	{2, 5},
	{3, 5},
	{4, 5},
	{5, 5},
	{6, 5},
	{7, 5},
}

local tbItem =
{
	[1] = "ui.atlas.png#dj_1.png",
	[2] = "ui.atlas.png#dj_2.png",
	[3] = "ui.atlas.png#dj_3.png",
	[4] = "gameplay.atlas.png#zhuanhuan_small.png",
	[5] = "gameplay.atlas.png#super_small.png",
	[6] = "gameplay.atlas.png#gjxiang_small.png",
}

local tbMsg =
{
	link = 
	{
		[1] = "rookie.atlas.png#link_wz_1.png",
		[2] = "rookie.atlas.png#link_wz_2.png",
		[3] = "rookie.atlas.png#link_wz_3.png",
		[4] = "rookie.atlas.png#link_wz_4.png",
	},
	pet = 
	{
		[1] = "rookie.atlas.png#pet_wz_1.png",
		[6] = "rookie.atlas.png#pet_wz_6.png",
		[7] = "rookie.atlas.png#pet_wz_7.png",
		[8] = "rookie.atlas.png#pet_wz_8.png",
		[9] = "rookie.atlas.png#pet_wz_9.png",
	},
	bomb = 
	{
		[3] = "rookie.atlas.png#bomb_wz_3.png",
		[4] = "rookie.atlas.png#bomb_wz_4.png",
		[5] = "rookie.atlas.png#bomb_wz_5.png",
		[6] = "rookie.atlas.png#bomb_wz_6.png",
	},
	robot = 
	{
		[1] = "rookie.atlas.png#robot_wz_1.png",
		[2] = "rookie.atlas.png#robot_wz_2.png",
		[5] = "rookie.atlas.png#robot_wz_5.png",
	},
	skill = 
	{
		[2] = "rookie.atlas.png#skill_wz_2.png",
		[3] = "rookie.atlas.png#skill_wz_3.png",
		[4] = "rookie.atlas.png#skill_wz_4.png",
		[5] = "rookie.atlas.png#skill_wz_5.png",
		[6] = "rookie.atlas.png#skill_wz_6.png",
		[7] = "rookie.atlas.png#skill_wz_7.png",
	},
	item1 = 
	{
		[1] = "rookie.atlas.png#item1_wz_1.png",
		[2] = "rookie.atlas.png#item1_wz_2.png",
	},
	item2 = 
	{
		[1] = "rookie.atlas.png#item2_wz_1.png",
		[2] = "rookie.atlas.png#item2_wz_2.png",
	},
	item3 = 
	{
		[1] = "rookie.atlas.png#item3_wz_1.png",
		[2] = "rookie.atlas.png#item3_wz_2.png",
	},
	item4 = 
	{
		[1] = "rookie.atlas.png#item4_wz_1.png",
		[2] = "rookie.atlas.png#item4_wz_2.png",
	},
	item5 = 
	{
		[1] = "rookie.atlas.png#item5_wz_1.png",
		[2] = "rookie.atlas.png#item5_wz_2.png",
	},
	item6 = 
	{
		[1] = "rookie.atlas.png#item6_wz_1.png",
		[2] = "rookie.atlas.png#item6_wz_2.png",
	},
	stage = 
	{
		[1] = "rookie.atlas.png#stage_wz_1.png",
		[2] = "rookie.atlas.png#stage_wz_2.png",
		[3] = "rookie.atlas.png#stage_wz_3.png",
	},
	timing =
	{
		[1] = "rookie.atlas.png#timing_wz_1.png",
		[2] = "rookie.atlas.png#timing_wz_2.png",
	},
}

local tbPosMode =
{
	[1] = 
	{
		msg = {Anchor = "LT", x = 220, y = -160},
		role = {Anchor = "RT", x = -100, y = -170},
	},
	[2] = 
	{
		msg = {Anchor = "LB", x = 220, y = 160},
		role = {Anchor = "RB", x = -100, y = 170},
	},
	[3] = 
	{
		msg = {Anchor = "RT", x = -220, y = -160},
		role = {Anchor = "LT", x = 100, y = -170},
	},
	[4] = 
	{
		msg = {Anchor = "RB", x = -220, y = 160},
		role = {Anchor = "LB", x = 100, y = 170},
	},
}

local tbPos = 
{
	link = 
	{
		[1] = tbPosMode[1],
		[2] = tbPosMode[1],
		[3] = tbPosMode[2],
		[4] = tbPosMode[2],
	},
	pet = 
	{
		[1] = tbPosMode[3],
		[6] = tbPosMode[4],
		[7] = tbPosMode[4],
		[8] = tbPosMode[4],
		[9] = tbPosMode[3],
	},
	bomb = 
	{
		[3] = tbPosMode[2],
		[4] = tbPosMode[2],
		[5] = tbPosMode[2],
		[6] = tbPosMode[2],
	},
	robot = 
	{
		[1] = tbPosMode[3],
		[2] = tbPosMode[3],
		[5] = tbPosMode[3],
	},
	skill = 
	{
		[2] = tbPosMode[1],
		[3] = tbPosMode[1],
		[4] = tbPosMode[1],
		[5] = tbPosMode[2],
		[6] = tbPosMode[2],
		[7] = tbPosMode[2],
	},
	item1 = 
	{
		[1] = tbPosMode[1],
		[2] = tbPosMode[1],
	},
	item2 = 
	{
		[1] = tbPosMode[1],
		[2] = tbPosMode[1],
	},
	item3 = 
	{
		[1] = tbPosMode[1],
		[2] = tbPosMode[1],
	},
	item4 = 
	{
		[1] = tbPosMode[1],
		[2] = tbPosMode[1],
	},
	item5 = 
	{
		[1] = tbPosMode[1],
		[2] = tbPosMode[1],
	},
	item6 = 
	{
		[1] = tbPosMode[1],
		[2] = tbPosMode[1],
	},
	stage = 
	{
		[1] = tbPosMode[1],
		[2] = tbPosMode[1],
		[3] = tbPosMode[1],
	},
	timing =
	{
		[1] = tbPosMode[1],
		[2] = tbPosMode[1],
	},
}


local RookiePanel = {}


function RookiePanel:init()
	self._root = ui.PickBox.new(device.ui_width, device.ui_height)
	self._root:setPriorityOffset(3000)
	self._root:setLayoutSize(device.ui_width, device.ui_height)
	
	self._hand = self._root:add(Image.new(handPic))
	self._hand:setPriorityOffset(6)
	local w, h = self._hand:getSize()
	self._offsetX = w / 2
	self._offsetY = -h / 2
	
	self._role = self._root:add(Image.new(role))
	self._role:setAnchor("RB", -120, 150)
	self._role:setPriorityOffset(5)
	
	self._msgBox = self._root:add(Image.new(msgBox))
	self._msgBox:setAnchor("LB", 250, 150)
	self._msg = self._msgBox:add(Image.new())
	self._msg:setLoc(0, -50)
	
	self._Img = Image.new()
	
	self._lock = false
	self._root.onClick = nil
	self._root.hitTest = function() return false end
	
	self._tbFun = {}
	self._tbFun["link"] = self.guideLink
	self._tbFun["pet"] = self.guidePet
	self._tbFun["bomb"] = self.guideBomb
	self._tbFun["robot"] = self.guideRobot
	self._tbFun["skill"] = self.guideSkill
	self._tbFun["item1"] = self.guideItem1
	self._tbFun["item2"] = self.guideItem2
	self._tbFun["item3"] = self.guideItem3
	self._tbFun["item4"] = self.guideItem4
	self._tbFun["item5"] = self.guideItem5
	self._tbFun["item6"] = self.guideItem6
	self._tbFun["stage"] = self.guideStage
	self._tbFun["timing"] = self.guideTiming
end

function RookiePanel:setMsgImg(name, idx, isFirst)
	self._msg:load(tbMsg[name][idx])
	self._root:add(self._msgBox)
	self._root:add(self._role)
	self._msgBox:setAnchor(tbPos[name][idx].msg.Anchor, tbPos[name][idx].msg.x, tbPos[name][idx].msg.y)
	self._role:setAnchor(tbPos[name][idx].role.Anchor, tbPos[name][idx].role.x, tbPos[name][idx].role.y)
	local x1, y1 = self._role:getLoc()
	local x2, y2 = self._msgBox:getLoc()
	WindowOpenStyle:openWindowSclMove(self._msgBox, x1, y1, x2, y2)
	if isFirst then
		self._role:setAnchor(tbPos[name][idx].role.Anchor, 0, tbPos[name][idx].role.y)
		self._role:seekLoc(x1, y1, 0.5)
	end
end

function RookiePanel:hiddenMsgImg()
	self._msgBox:remove()
	self._role:remove()
end

function RookiePanel:lockself(fun)
	if not self._lock then
		ui.lock(self._root)
		self._root.hitTest = function()
			return true
		end
		self._lock = true
	end
	self._root.onClick = fun
end

function RookiePanel:unlockself()
	if self._lock then
		ui.unlock(self._root)
		self._root.hitTest = function()
			return false
		end
		self._root.onClick = nil
		self._lock = false
	end
end

function RookiePanel:setNodeColor(node)
	node._attrParent = node:getAttrLink(MOAIColor.INHERIT_COLOR)
	node:clearAttrLink(MOAIColor.INHERIT_COLOR)
	node:setColor(1, 1, 1)
end

function RookiePanel:resetNodeColor(node)
	if node._attrParent then
		node:setAttrLink(MOAIColor.INHERIT_COLOR, node._attrParent, MOAIColor.COLOR_TRAIT)
	end
end

function RookiePanel:startHandAnim()
	self:stopHandAnim()
	self._action = MOAIThread.new()
	self._action:attach(mainAS, function()
		while true do
			MOAIThread.blockOnAction(self._hand:seekScl(0.8, 0.8, 0.5, MOAIEaseType.LINEAR))
			MOAIThread.blockOnAction(self._hand:seekScl(1, 1, 0.5, MOAIEaseType.LINEAR))
		end
	end)
end

function RookiePanel:stopHandAnim()
	if self._action then
		self._action:stop()
		self._action = nil
	end
end

function RookiePanel:setHandLoc(x, y, flag)
	if self._handAS then
		self._handAS:stop()
	end
	if flag == "set" then
		self._hand:setLoc(x + self._offsetX, y + self._offsetY)
		self:startHandAnim()
	else
		self._handAS = self._hand:seekLoc(x + self._offsetX, y + self._offsetY, 1)
		self._handAS:setListener(MOAIAction.EVENT_STOP, function()
			self:startHandAnim()
		end)
	end
end

function RookiePanel:guideLink()
	local function step_4(self)
		self:setMsgImg("link", 4)
		self:lockself(function()
			self:resetNodeColor(FightTopPanel._stepImg)
			self:unlockself()
			self:close()
		end)
	end
	local function step_3(self)
		self:setMsgImg("link", 3)
		local x, y = FightTopPanel._stepImg:getWorldLoc()
		self:setNodeColor(FightTopPanel._stepImg)
		self:setHandLoc(x, y, "seek")
		self:lockself(function()
			self:unlockself()
			step_4(self)
		end)
	end
	local function step_2(self)
		self._root:add(self._hand)
		self:setMsgImg("link", 2)
		
		if GamePlay._dropBallEnd then
			local ball1 = GamePlay:getBall(ballc1, ballr1)
			local ball2 = GamePlay:getBall(ballc2, ballr2)
			local ball3 = GamePlay:getBall(ballc3, ballr3)
			local x1, y1 = ball1:getWorldLoc()
			local x2, y2 = ball3:getWorldLoc()
		
			self:setNodeColor(ball1)
			self:setNodeColor(ball2)
			self:setNodeColor(ball3)
		
			GamePlay:lockBalls(ball1, ball2, ball3)
			GamePlay:lockBallsPanel()
			GamePlay:disableRemind()
			local loop = true
			local key = nil
			key = eventhub.bind("ROOKIE_EVENT", "ROOKIE_COMPLETE", function(name)
				if name == "linkball" then
					GamePlay:enableRemind()
					self:resetNodeColor(ball1)
					self:resetNodeColor(ball2)
					self:resetNodeColor(ball3)
					GamePlay:unlockBalls()
					GamePlay:unlockBallsPanel()
					eventhub.unbind("ROOKIE_EVENT", "ROOKIE_COMPLETE", key)
					loop = false
				end
			end)
			local function move(self)
			self._hand:setLoc(x2 + self._offsetX, y2 + self._offsetY)
			local c = self._hand:seekLoc(x1 + self._offsetX, y1 + self._offsetY, 1)
				c:setListener(MOAIAction.EVENT_STOP, function()
					if loop then
						move(self)
					else
						step_3(self)
					end
				end)
			end
			move(self)
		else
			local key = nil
			key = eventhub.bind("ROOKIE_EVENT", "ROOKIE_COMPLETE", function(name)
				if name == "dropballend" then
					eventhub.unbind("ROOKIE_EVENT", "ROOKIE_COMPLETE", key)
					step_2(self)
				end
			end)
		end
	end
	local function step_1(self)
		eventhub.fire("UI_EVENT", "OPEN_GAME_PANEL", "mission", 1)
		self._hand:remove()
		self:setMsgImg("link", 1, true)
		self:lockself(function()
			self:unlockself()
			step_2(self)
		end)
	end
	self:open()
	step_1(self)
end

function RookiePanel:guidePet()
	local function step_9(self)
		self:setMsgImg("pet", 9)
		self:setNodeColor(PetPanel.useButton)
		local x, y = PetPanel.useButton:getWorldLoc()
		self._root:add(self._hand)
		self._hand:setLoc(0, 0)
		self:setHandLoc(x, y, "seek")
		if not UserData.petInfo[2].unlocked then
			ui.lock(PetPanel.useButton)
			local key = nil
			key = eventhub.bind("ROOKIE_EVENT", "ROOKIE_COMPLETE", function(name)
				if name == "petlock" then
					self:resetNodeColor(PetPanel.useButton)
					ui.unlock(PetPanel.useButton)
					eventhub.unbind("ROOKIE_EVENT", "ROOKIE_COMPLETE", key)
					eventhub.fire("ROOKIE_EVENT", "ROOKIE_END", "pet")
					self:close()
				end
			end)
		else
			self:lockself(function()
				self:unlockself()
				self:resetNodeColor(PetPanel.useButton)
				eventhub.fire("ROOKIE_EVENT", "ROOKIE_END", "pet")
				self:close()
			end)
		end		
	end
	local function step_8(self)
		self:setMsgImg("pet", 8)
		self:lockself(function()
			self:unlockself()
			step_9(self)
		end)
	end
	local function step_7(self)
		self:setMsgImg("pet", 7)
		self:stopHandAnim()
		self._hand:remove()
		self:lockself(function()
			self:unlockself()
			step_8(self)
		end)
	end
	local function step_6(self)
		self:setMsgImg("pet", 6)
		ui.lock(RolePanel._tbPetImg[2][1])
		self:setNodeColor(RolePanel._tbPetImg[2][2])
		local x, y = RolePanel._tbPetImg[2][2]:getWorldLoc()
		self:setHandLoc(x, y, "seek")
		local key = nil
		key = eventhub.bind("ROOKIE_EVENT", "ROOKIE_COMPLETE", function(name)
			if name == "huaxin" then
				self:resetNodeColor(RolePanel._tbPetImg[2][2])
				ui.unlock(RolePanel._tbPetImg[2][1])
				eventhub.unbind("ROOKIE_EVENT", "ROOKIE_COMPLETE", key)
				step_7(self)
			end
		end)
	end
	local function step_1(self)
		self:setMsgImg("pet", 1, true)
		ui.lock(MainPanel._roleBtn)
		self:setNodeColor(MainPanel._roleBtn)
		local x, y = MainPanel._roleBtn:getWorldLoc()
		self._root:add(self._hand)
		self._hand:setLoc(0, 0)
		self:setHandLoc(x, y, "seek")
		local key = nil
		key = eventhub.bind("ROOKIE_EVENT", "ROOKIE_COMPLETE", function(name)
			if name == "openrolepanel" then
				self:resetNodeColor(MainPanel._roleBtn)
				ui.unlock(MainPanel._roleBtn)
				eventhub.unbind("ROOKIE_EVENT", "ROOKIE_COMPLETE", key)
				step_6(self)
			end
		end)
	end
	if UserData.petInfo[2].unlocked then
		eventhub.fire("ROOKIE_EVENT", "ROOKIE_END", "pet")
		return
	end
	self:open()
	self:unlockself()
	step_1(self)
end

function RookiePanel:guideBomb()
	local function step_6(self)
		self:setMsgImg("bomb", 6)
		self:stopHandAnim()
		self._hand:remove()
		self:lockself(function()
			self:unlockself()
			self:close()
		end)
	end
	local function step_5(self)
		self:setMsgImg("bomb", 5)
		local bomb = GamePlay:getBomb()
		local x, y = bomb:getWorldLoc()
		self._root:add(self._hand)
		self._hand:setLoc(0, 0)
		self:setHandLoc(x, y, "seek")
		self:setNodeColor(bomb)
		GamePlay:lockBalls(bomb)
		GamePlay:lockBallsPanel()
		GamePlay:disableRemind()
		local key = nil
		key = eventhub.bind("ROOKIE_EVENT", "ROOKIE_COMPLETE", function(name)
			if name == "bomb" then
				GamePlay:enableRemind()
				self:resetNodeColor(bomb)
				GamePlay:unlockBalls()
				GamePlay:unlockBallsPanel()
				eventhub.unbind("ROOKIE_EVENT", "ROOKIE_COMPLETE", key)
				step_6(self)
			end
		end)
	end
	local function step_4(self)
		self:setMsgImg("bomb", 4)
		self._hand:remove()
		self:lockself(function()
			self:resetNodeColor(GamePlay._upBg)
			self:unlockself()
			step_5(self)
		end)
	end	
	local function step_3(self)
		self:setMsgImg("bomb", 3, true)
		self:stopHandAnim()
		
		if GamePlay._dropBallEnd then
			local loop = true
			local tbBall = {}
			self._root:add(self._hand)
			for key, var in ipairs(tbBallcr) do
				tbBall[key] = GamePlay:getBall(var[1], var[2])
				self:setNodeColor(tbBall[key])
			end
		
			local tbBallPosX = {}
			local tbBallPosY = {}
			for key, var in ipairs(tbBall) do
				local x, y = var:getWorldLoc()
				local i = (key - 1) * 0.5 
				tbBallPosX[key] = {i, x + self._offsetX, MOAIEaseType.LINEAR}
				tbBallPosY[key] = {i, y + self._offsetY, MOAIEaseType.LINEAR}
			end
			
			local curveX = interpolate.makeCurveByTab(tbBallPosX)
			local curveY = interpolate.makeCurveByTab(tbBallPosY)
			local anim = MOAIAnim.new()
			anim:setMode(MOAITimer.LOOP)
			anim:reserveLinks(2)
			anim:setLink(1, curveX, self._hand, MOAITransform2D.ATTR_X_LOC)
			anim:setLink(2, curveY, self._hand, MOAITransform2D.ATTR_Y_LOC)
			anim:start()
			
			GamePlay:lockBalls(tbBall[1], tbBall[2], tbBall[3], tbBall[4], tbBall[5], tbBall[6], tbBall[7])
			GamePlay:lockBallsPanel()
			GamePlay:disableRemind()
			self:setNodeColor(GamePlay._upBg)
			local key = nil
			key = eventhub.bind("ROOKIE_EVENT", "ROOKIE_COMPLETE", function(name)
				if name == "newbomb" then
					GamePlay:enableRemind()
					for key, var in ipairs(tbBall) do
						self:resetNodeColor(var)
					end
					GamePlay:unlockBalls()
					GamePlay:unlockBallsPanel()
					if anim then
						anim:stop()
						anim = nil
					end
					eventhub.unbind("ROOKIE_EVENT", "ROOKIE_COMPLETE", key)
					step_4(self)
				end
			end)
		else
			local key = nil
			key = eventhub.bind("ROOKIE_EVENT", "ROOKIE_COMPLETE", function(name)
				if name == "dropballend" then
					eventhub.unbind("ROOKIE_EVENT", "ROOKIE_COMPLETE", key)
					step_3(self)
				end
			end)
		end
	end
	self:open()
	step_3(self)
end

function RookiePanel:guideRobot()
	local function step_5(self)
		self:setMsgImg("robot", 5)
		ui.lock(PetPanel.useButton)
		self:setNodeColor(PetPanel.useButton)
		local x, y = PetPanel.useButton:getWorldLoc()
		self:setHandLoc(x, y, "seek")
		local key = nil
		key = eventhub.bind("ROOKIE_EVENT", "ROOKIE_COMPLETE", function(name)
			if name == "robotunlock" then
				self:resetNodeColor(PetPanel.useButton)
				ui.unlock(PetPanel.useButton)
				eventhub.unbind("ROOKIE_EVENT", "ROOKIE_COMPLETE", key)
				eventhub.fire("ROOKIE_EVENT", "ROOKIE_END", "robot")
				self:close()
			end
		end)
	end
	local function step_4(self)
		ui.lock(PetPanel._RightButton)
		self:setNodeColor(PetPanel._RightButton)
		local x, y = PetPanel._RightButton:getWorldLoc()
		self:setHandLoc(x, y, "seek")
		local key = nil
		key = eventhub.bind("ROOKIE_EVENT", "ROOKIE_COMPLETE", function(name)
			if name == "switchrobot" then
				self:resetNodeColor(PetPanel._RightButton)
				ui.unlock(PetPanel._RightButton)
				eventhub.unbind("ROOKIE_EVENT", "ROOKIE_COMPLETE", key)
				step_5(self)
			end
		end)
	end	
	local function step_3(self)
		ui.lock(RolePanel._tbPetImg[1][1])
		self:setNodeColor(RolePanel._tbPetImg[1][3])
		local x, y = RolePanel._tbPetImg[1][3]:getWorldLoc()
		self:setHandLoc(x, y, "seek")
		local key = nil
		key = eventhub.bind("ROOKIE_EVENT", "ROOKIE_COMPLETE", function(name)
			if name == "openpetpanel" then
				self:resetNodeColor(RolePanel._tbPetImg[1][3])
				ui.unlock(RolePanel._tbPetImg[1][1])
				eventhub.unbind("ROOKIE_EVENT", "ROOKIE_COMPLETE", key)
				step_4(self)
			end
		end)
	end
	local function step_2(self)
		self:setMsgImg("robot", 2)
		ui.lock(MainPanel._roleBtn)
		self:setNodeColor(MainPanel._roleBtn)
		local x, y = MainPanel._roleBtn:getWorldLoc()
		self._root:add(self._hand)
		self._hand:setLoc(0, 0)
		self:setHandLoc(x, y, "seek")
		local key = nil
		key = eventhub.bind("ROOKIE_EVENT", "ROOKIE_COMPLETE", function(name)
			if name == "openrolepanel" then
				self:resetNodeColor(MainPanel._roleBtn)
				ui.unlock(MainPanel._roleBtn)
				eventhub.unbind("ROOKIE_EVENT", "ROOKIE_COMPLETE", key)
				step_3(self)
			end
		end)
	end
	local function step_1(self)
		self:setMsgImg("robot", 1, true)
		self._hand:remove()
		self:lockself(function()
			self:unlockself()
			step_2(self)
		end)
	end
	if UserData.robotInfo[1] then
		eventhub.fire("ROOKIE_EVENT", "ROOKIE_END", "robot")
		return
	end
	self:open()
	step_1(self)
end

function RookiePanel:guideSkill()
	local function step_7(self)
		self:setMsgImg("skill", 7)
		self:lockself(function()
			self:unlockself()
			self:close()
			eventhub.fire("ROOKIE_EVENT", "ROOKIE_END", "skill")
		end)
	end
	local function step_6(self)
		self:setMsgImg("skill", 6)
		self:lockself(function()
			self:unlockself()
			step_7(self)
		end)
	end
	local function step_5(self)
		self:setMsgImg("skill", 5)
		self:stopHandAnim()
		self._hand:remove()
		self:setNodeColor(GamePlay._upBg)
		self:lockself(function()
			self:resetNodeColor(GamePlay._upBg)
			self:unlockself()
			step_6(self)
		end)
	end
	local function step_4(self)
		self:setMsgImg("skill", 4)
		local x = (GamePlay._ballLevelClick[1].xMin + GamePlay._ballLevelClick[1].xMax) / 2
		local y = (GamePlay._ballLevelClick[1].yMin + GamePlay._ballLevelClick[1].yMax) / 2
		self:setHandLoc(x, y, "seek")
		self:setNodeColor(GamePlay._ballLevelBgList[1])
		GamePlay:lockSkill(1)
		GamePlay:disableRemind()
		local key = nil
		key = eventhub.bind("ROOKIE_EVENT", "ROOKIE_COMPLETE", function(name)
			if name == "doskill" then
				GamePlay:enableRemind()
				GamePlay:unlockSkill()
				self:resetNodeColor(GamePlay._ballLevelBgList[1])
				eventhub.unbind("ROOKIE_EVENT", "ROOKIE_COMPLETE", key)
				step_5(self)
			end
		end)
	end
	local function step_3(self)
		self._root:add(self._hand)
		self:setMsgImg("skill", 3)
		
		if GamePlay._dropBallEnd then
			local loop = true
			local ball1 = GamePlay:getBall(ballc1, ballr1)
			local ball2 = GamePlay:getBall(ballc2, ballr2)
			local ball3 = GamePlay:getBall(ballc3, ballr3)
			local x1, y1 = ball1:getWorldLoc()
			local x2, y2 = ball3:getWorldLoc()
			
			self:setNodeColor(ball1)
			self:setNodeColor(ball2)
			self:setNodeColor(ball3)
			
			
			GamePlay:lockBalls(ball1, ball2, ball3)
			GamePlay:lockBallsPanel()
			GamePlay:disableRemind()
			local key = nil
			key = eventhub.bind("ROOKIE_EVENT", "ROOKIE_COMPLETE", function(name)
				if name == "linkball" then
					GamePlay:enableRemind()
					self:resetNodeColor(ball1)
					self:resetNodeColor(ball2)
					self:resetNodeColor(ball3)
					GamePlay:unlockBalls()
					GamePlay:unlockBallsPanel()
					GamePlay:addClearBallNum(1, BallLevel.LevelUp[1])
					loop = false
					eventhub.unbind("ROOKIE_EVENT", "ROOKIE_COMPLETE", key)
				end
			end)
			local function move(self)
				self._hand:setLoc(x2 + self._offsetX, y2 + self._offsetY)
				local c = self._hand:seekLoc(x1 + self._offsetX, y1 + self._offsetY, 1)
				c:setListener(MOAIAction.EVENT_STOP, function()
					if loop then
						move(self)
					else
						step_4(self)
					end
				end)
			end
			move(self)
		else
			local key = nil
			key = eventhub.bind("ROOKIE_EVENT", "ROOKIE_COMPLETE", function(name)
				if name == "dropballend" then
					eventhub.unbind("ROOKIE_EVENT", "ROOKIE_COMPLETE", key)
					step_3(self)
				end
			end)
		end
	end
	local function step_2(self)
		self:setMsgImg("skill", 2, true)
		self:stopHandAnim()
		self:hiddenMsgImg()
		self._hand:remove()
		self:lockself(function()
			self:unlockself()
			step_3(self)
		end)
	end
	self:open()
	step_2(self)
end

function RookiePanel:guideItem1()
	local function step_2(self)
		self:setMsgImg("item1", 2)
		self._root:add(self._hand)
		self:setNodeColor(MissionStartPanel._tbFrame[6])
		local x, y = MissionStartPanel._tbFrame[6]:getWorldLoc()
		self:setHandLoc(x, y, "set")
		self._root:add(self._Img)
		self._Img:load(tbItem[1])
		
		local c = interpolate.makeCurve(0, 0, MOAIEaseType.LINEAR, 0.5, 0.5)
		local f1 = interpolate.newton2d({-device.ui_width / 2, -device.ui_width / 4, x}, {0, 200, y}, c)
		local action
		action = mainAS:run(function(dt, length)
			if length >= c:getLength() then
				action:stop()
				self._Img:remove()
				UserData:addItemCount(6, 1)
				MissionStartPanel:buyItem(6)
				eventhub.fire("ROOKIE_EVENT", "ROOKIE_END", "item1")
			else
				self._Img:setLoc(f1(length))
			end
		end)
		
		self:lockself(function()
			self:resetNodeColor(MissionStartPanel._tbFrame[6])
			self:unlockself()
			self:close()
		end)
	end
	local function step_1(self)
		self:setMsgImg("item1", 1, true)
		self._hand:remove()
		self:lockself(function()
			self:unlockself()
			step_2(self)
		end)
	end
	self:open()
	step_1(self)
end

function RookiePanel:guideItem2()
	local function step_2(self)
		self:setMsgImg("item2", 2)
		self._root:add(self._hand)
		self:setNodeColor(MissionStartPanel._tbFrame[5])
		local x, y = MissionStartPanel._tbFrame[5]:getWorldLoc()
		self:setHandLoc(x, y, "set")
		self._root:add(self._Img)
		self._Img:load(tbItem[2])
		
		local c = interpolate.makeCurve(0, 0, MOAIEaseType.LINEAR, 0.5, 0.5)
		local f1 = interpolate.newton2d({-device.ui_width / 2, -device.ui_width / 4, x}, {0, 200, y}, c)
		local action
		action = mainAS:run(function(dt, length)
			if length >= c:getLength() then
				action:stop()
				self._Img:remove()
				UserData:addItemCount(5, 1)
				MissionStartPanel:buyItem(5)
				eventhub.fire("ROOKIE_EVENT", "ROOKIE_END", "item2")
			else
				self._Img:setLoc(f1(length))
			end
		end)
		
		self:lockself(function()
			self:resetNodeColor(MissionStartPanel._tbFrame[5])
			self:unlockself()
			self:close()
		end)
	end
	local function step_1(self)
		self:setMsgImg("item2", 1, true)
		self._hand:remove()
		self:lockself(function()
			self:unlockself()
			step_2(self)
		end)
	end
	self:open()
	step_1(self)
end

function RookiePanel:guideItem3()
	local function step_2(self)
		self:setMsgImg("item3", 2)
		self._root:add(self._hand)
		self:setNodeColor(MissionStartPanel._tbFrame[4])
		local x, y = MissionStartPanel._tbFrame[4]:getWorldLoc()
		self:setHandLoc(x, y, "set")
		self._root:add(self._Img)
		self._Img:load(tbItem[3])
		
		local c = interpolate.makeCurve(0, 0, MOAIEaseType.LINEAR, 0.5, 0.5)
		local f1 = interpolate.newton2d({-device.ui_width / 2, -device.ui_width / 4, x}, {0, 200, y}, c)
		local action
		action = mainAS:run(function(dt, length)
			if length >= c:getLength() then
				action:stop()
				self._Img:remove()
				UserData:addItemCount(4, 1)
				MissionStartPanel:buyItem(4)
				eventhub.fire("ROOKIE_EVENT", "ROOKIE_END", "item3")
			else
				self._Img:setLoc(f1(length))
			end
		end)
		
		self:lockself(function()
			self:resetNodeColor(MissionStartPanel._tbFrame[4])
			self:unlockself()
			self:close()
		end)
	end
	local function step_1(self)
		self:setMsgImg("item3", 1, true)
		self._hand:remove()
		self:lockself(function()
			self:unlockself()
			step_2(self)
		end)
	end
	self:open()
	step_1(self)
end

function RookiePanel:guideItem4()
	local function step_2(self)
		self:setMsgImg("item4", 2)
		self._root:add(self._hand)
		self:setNodeColor(FightTopPanel._tbItem[1])
		local x, y = FightTopPanel._tbItem[1]:getWorldLoc()
		self:setHandLoc(x, y, "set")
		self._root:add(self._Img)
		self._Img:load(tbItem[4])
		
		local c = interpolate.makeCurve(0, 0, MOAIEaseType.LINEAR, 0.5, 0.5)
		local f1 = interpolate.newton2d({-device.ui_width / 2, -device.ui_width / 4, x}, {0, 200, y}, c)
		local action
		action = mainAS:run(function(dt, length)
			if length >= c:getLength() then
				action:stop()
				self._Img:remove()
				UserData:addItemCount(1, 1)
				eventhub.fire("ROOKIE_EVENT", "ROOKIE_END", "item4")
				FightTopPanel:showItemIco()
			else
				self._Img:setLoc(f1(length))
			end
		end)
		
		self:lockself(function()
			self:resetNodeColor(FightTopPanel._tbItem[1])
			self:unlockself()
			self:close()
		end)
	end
	local function step_1(self)
		self:setMsgImg("item4", 1, true)
		self._hand:remove()
		self:lockself(function()
			self:unlockself()
			step_2(self)
		end)
	end
	self:open()
	step_1(self)
end

function RookiePanel:guideItem5()
	local function step_2(self)
		self:setMsgImg("item5", 2)
		self._root:add(self._hand)
		self:setNodeColor(FightTopPanel._tbItem[2])
		local x, y = FightTopPanel._tbItem[2]:getWorldLoc()
		self:setHandLoc(x, y, "set")
		self._root:add(self._Img)
		self._Img:load(tbItem[5])
		
		local c = interpolate.makeCurve(0, 0, MOAIEaseType.LINEAR, 0.5, 0.5)
		local f1 = interpolate.newton2d({-device.ui_width / 2, -device.ui_width / 4, x}, {0, 200, y}, c)
		local action
		action = mainAS:run(function(dt, length)
			if length >= c:getLength() then
				action:stop()
				self._Img:remove()
				UserData:addItemCount(2, 1)
				eventhub.fire("ROOKIE_EVENT", "ROOKIE_END", "item5")
				FightTopPanel:showItemIco()
			else
				self._Img:setLoc(f1(length))
			end
		end)
		
		self:lockself(function()
			self:resetNodeColor(FightTopPanel._tbItem[2])
			self:unlockself()
			self:close()
		end)
	end
	local function step_1(self)
		self:setMsgImg("item5", 1, true)
		self._hand:remove()
		self:lockself(function()
			self:unlockself()
			step_2(self)
		end)
	end
	self:open()
	step_1(self)
end

function RookiePanel:guideItem6()
	local function step_2(self)
		self:setMsgImg("item6", 2)
		self._root:add(self._hand)
		self:setNodeColor(FightTopPanel._tbItem[3])
		local x, y = FightTopPanel._tbItem[3]:getWorldLoc()
		self:setHandLoc(x, y, "set")
		self._root:add(self._Img)
		self._Img:load(tbItem[6])
		
		local c = interpolate.makeCurve(0, 0, MOAIEaseType.LINEAR, 0.5, 0.5)
		local f1 = interpolate.newton2d({-device.ui_width / 2, -device.ui_width / 4, x}, {0, 200, y}, c)
		local action
		action = mainAS:run(function(dt, length)
			if length >= c:getLength() then
				action:stop()
				self._Img:remove()
				UserData:addItemCount(3, 1)
				eventhub.fire("ROOKIE_EVENT", "ROOKIE_END", "item6")
				FightTopPanel:showItemIco()
			else
				self._Img:setLoc(f1(length))
			end
		end)
		
		self:lockself(function()
			self:resetNodeColor(FightTopPanel._tbItem[3])
			self:unlockself()
			self:close()
		end)
	end
	local function step_1(self)
		self:setMsgImg("item6", 1, true)
		self._hand:remove()
		self:lockself(function()
			self:unlockself()
			step_2(self)
		end)
	end
	self:open()
	step_1(self)
end

function RookiePanel:guideStage()
	local function step_3(self)
		self:setMsgImg("stage", 3)
		self:lockself(function()
			self:unlockself()
			self:close()
			eventhub.fire("ROOKIE_EVENT", "ROOKIE_END", "stage")
		end)
	end
	local function step_2(self)
		self:setMsgImg("stage", 2)
		local c = MainPanel:addBeginBtn()
		if c then
			c:setListener(MOAIAction.EVENT_STOP, function()
				local x, y = MainPanel._beginBtn:getWorldLoc()
				self._root:add(self._hand)
				self._hand:setLoc(0, 0)
				self:setHandLoc(x, y, "seek")
			end)
		end		
		self:lockself(function()
			self:unlockself()
			step_3(self)
		end)
	end
	local function step_1(self)
		self:setMsgImg("stage", 1, true)
		self._hand:remove()
		self:lockself(function()
			self:unlockself()
			step_2(self)
		end)
	end
	self:open()
	step_1(self)
end

function RookiePanel:guideTiming()
	local function step_2(self)
		self:setMsgImg("timing", 2)
		self:lockself(function()
			self._hand:remove()
			self:unlockself()
			self:close()
			eventhub.fire("ROOKIE_EVENT", "ROOKIE_END", "timing")
		end)
	end
	local function step_1(self)
		self:setMsgImg("timing", 1, true)
		self._root:add(self._hand)
		self._hand:setLoc(0, 0)
		self:setNodeColor(MainPanel._timingBtn[1].btn)
		local x, y = MainPanel:getTimingBtnPos(1)
		self:setHandLoc(x, y, "seek")
		self:lockself(function()
			self:unlockself()
			step_2(self)
		end)
	end
	self:open()
	step_1(self)
end

function RookiePanel:open(tbParam)
	popupLayer:add(self._root)
end

function RookiePanel:close()
	self:stopHandAnim()
	popupLayer:remove(self._root)
end

return RookiePanel