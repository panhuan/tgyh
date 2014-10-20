
local ui = require "ui"
local Image = require "gfx.Image"
local eventhub = require "eventhub"
local device = require "device"
local UserData = require "UserData"
local Buy = require "settings.Buy"
local Pet = require "settings.Pet"
local Robot = require "settings.Robot"
local TextBox = require "gfx.TextBox"
local timer = require "timer"
local Sprite = require "gfx.Sprite"
local WindowOpenStyle = require "windows.WindowOpenStyle"
local SoundManager = require "SoundManager"


local PetPanel = {}


local backGround = "panel/panel_1.atlas.png#panel_1.png?loc=0, -20"
local closePic1 = "ui.atlas.png#close_1.png"
local closePic2 = "ui.atlas.png#close_2.png?scl=1.2"
local leftBtnPic = "ui.atlas.png#jcx_fx.png?rot=180"
local rightBtnPic = "ui.atlas.png#jcx_fx.png"
local textBackPic = "panel/petinfo_panel.atlas.png#petinfo_panel.png"
local useBtn = "ui.atlas.png#stepbtn.png"
local unlockBtnPic = "ui.atlas.png#jiesuo.png"
local levelUpBtnPic = "ui.atlas.png#shengji.png"
local lockPic = "ui.atlas.png#weijiesuo.png"
local panelLine = "ui.atlas.png#role_line.png?loc=0, 20"
local lvupEffect = "effect.atlas.png"
local robotbgPic = "panel/cr_xx_di.atlas.png#cr_xx_di.png"
local unlockPic = "panel/pet_unlock.atlas.png#pet_unlock.png"
local robotBtnPic1 = "ui.atlas.png#jcx_an_1.png"
local robotBtnPic2 = "ui.atlas.png#jcx_an_2.png"
local goldPic = "ui.atlas.png#gold_small.png"
local moneyPic = "ui.atlas.png#money_small.png"
local autoUnlock = "ui.atlas.png#jcx_zi_19.png"

local leftBtnX, leftBtnY = 70, -280
local rightBtnX, rightBtnY = -70, -280
local textBackX, textBackY = 0, -140
local textW, textH = 340, 192


local testFun = 
{
	[1] = function()
		
	end,
	[2] = function()
		local tbParam = {}
		tbParam.strIndex = 1
		tbParam.fun = function()
			eventhub.fire("UI_EVENT", "OPEN_BUY_PANEL", "rmbtomoney")
		end
		eventhub.fire("UI_EVENT", "OPEN_MESSAGEBOX", tbParam)
	end,
	[3] = function()
		local tbParam = {}
		tbParam.strIndex = 2
		tbParam.fun = function()
			eventhub.fire("UI_EVENT", "OPEN_BUY_PANEL", "moneytogold")
		end
		eventhub.fire("UI_EVENT", "OPEN_MESSAGEBOX", tbParam)
	end,
	[4] = function()
		local tbParam = {}
		tbParam.strIndex = 4
		eventhub.fire("UI_EVENT", "OPEN_MESSAGEBOX", tbParam)
	end,
}

local useBtnTable =
{
	[true] = 
	{
		pic = levelUpBtnPic,
		fun = function()
			local result = UserData:petLevelUpTest(PetPanel._petIdx)
			if result == 0 then
				UserData:petLevelUp(PetPanel._petIdx)
			else
				if testFun[result] then
					testFun[result]()
				end
			end
		end
	},
	[false] = 
	{	
		pic = unlockBtnPic,
		fun = function()
			local result = UserData:petUnlockTest(PetPanel._petIdx)
			if result == 0 then
				UserData:petUnlock(PetPanel._petIdx)
			else
				if testFun[result] then
					testFun[result]()
				end
			end
		end
	},
}

local tbText = 
{
	[1] = 
	{
		[1] = "ui.atlas.png#dengji.png?loc=-160, 110",
		[2] = "ui.atlas.png#gongji.png?loc=-173, 75",
		[3] = "ui.atlas.png#crxx_zi_1.png?loc=-153, 5",
	},
	[2] =
	{
		[1] = "ui.atlas.png#jcx_zi_6.png?loc=-166, 110",
		[2] = "ui.atlas.png#jcx_zi_7.png?loc=-154, 75",
		[3] = "ui.atlas.png#jcx_zi_8.png?loc=-178, 5",
	},
}

local tbPic = 
{
	[1] = 
	{
		[true] = "ui.atlas.png#huafei_1.png",
		[false] = "ui.atlas.png#huafei_2.png",
	},
	[2] = 
	{
		[1] = "ui.atlas.png#pettext_lv.png?loc=-65, 110",
		[2] = "ui.atlas.png#gold_small.png?loc=45, 40",
	},
	[3] = 
	{
		[true] = "lock",
		[false] = "pet_red"
	},
}


local tbPos = 
{	
	{-30, 110, 40},
	{-45, 75, 60},
	{-25, 40},
}

local tbLvupEffect =
{
	{x = 0, y = 70, name = "lvup1", priority = 1},
	{x = 0, y = 120, name = "lvup2", priority = 100},
	{x = 0, y = 250, name = "lvup3", priority = 150},
}

local robotUnlock =
{
	[1] = "ui.atlas.png#kx_zd.png",
	[2] = "ui.atlas.png#hx_zd.png",
	[3] = "ui.atlas.png#tx_zd.png",
	[4] = "ui.atlas.png#cx_zd.png",
	[5] = "ui.atlas.png#xx_zd.png",
}

local petPos = 
{
	pet = 
	{
		{0, 155},
		{0, 155},
		{0, 155},
		{0, 150},
		{0, 175},
	},
	robot = 
	{
		{0, 200},
		{20, 175},
		{13, 175},
		{0, 180},
		{45, 200},
	},
}

local shadowPos = 
{
	pet = 
	{
		{120, 100},
		{140, 100},
		{140, 110},
		{140, 110},
		{170, 110},
	},
	robot = 
	{
		{-170, 110},
		{-170, 110},
		{-140, 110},
		{-180, 110},
		{-190, 130},
	},
}


function PetPanel:init()
	eventhub.bind("UI_EVENT", "OPEN_PET_PANEL", function(petIdx, key)
		self:open()
		if SoundManager.heroNormalVoice[petIdx] then
			SoundManager.heroNormalVoice[petIdx]:play()
		end
		self:initByPet(petIdx)
		if key == "robot" then
			self:initByRobot(petIdx)
		end
	end)	
	eventhub.bind("UI_EVENT", "PET_UNLOCK", function(petIdx)
		SoundManager.petUnlockSound:play()
		self:initByPet(petIdx, "unlock")
		eventhub.fire("ROOKIE_EVENT", "ROOKIE_COMPLETE", "petlock")
	end)
	eventhub.bind("UI_EVENT", "ROBOT_UNLOCK", function(pexIdx)
		self:initByRobot(pexIdx, "unlock")
		eventhub.fire("ROOKIE_EVENT", "ROOKIE_COMPLETE", "robotunlock")
	end)
	eventhub.bind("UI_EVENT", "PET_LEVEL_UP", function(petIdx)
		SoundManager.petLevelUpSound:play()
		self:initByPet(petIdx, "lvup")
	end)
	eventhub.bind("UI_EVENT", "WINDOW_SCL_OVER", function(node)
		if self._bgRoot == node then
			eventhub.fire("ROOKIE_EVENT", "ROOKIE_COMPLETE", "huaxin")
		end
	end)
	self._root = ui.PickBox.new(device.ui_width, device.ui_height)
	self._root:setPriorityOffset(520)
	self._bgRoot = Image.new(backGround)
	self._root:add(self._bgRoot)
	self._root:setLayoutSize(Image.getSize(self._bgRoot))
		
	self._closeButton = self._bgRoot:add(ui.Button.new(closePic1, closePic2))
	self._closeButton:setAnchor("RT", -50, -90)
	self._closeButton.onClick = function()
		self:close()
		eventhub.fire("ROOKIE_EVENT", "ROOKIE_COMPLETE", "closepetpanel")
	end
	
	self._leftButton = self._bgRoot:add(ui.Button.new(leftBtnPic, 1.2))
	self._leftButton:setAnchor("LT", leftBtnX, leftBtnY)
	self._leftButton:setPriorityOffset(20)
	self._leftButton.onClick = function()
		if SoundManager.heroNormalVoice[self._petIdx] then
			-- SoundManager.heroNormalVoice[self._petIdx]:play()
		end
		if self._page == "pet" then
			self:initByRobot(self._petIdx)
		else
			self:initByPet(self._petIdx)
		end
	end
	
	self._RightButton = self._bgRoot:add(ui.Button.new(rightBtnPic, 1.2))
	self._RightButton:setAnchor("RT", rightBtnX, rightBtnY)
	self._RightButton:setPriorityOffset(20)
	self._RightButton.onClick = function()
		if SoundManager.heroNormalVoice[self._petIdx] then
			-- SoundManager.heroNormalVoice[self._petIdx]:play()
		end
		if self._page == "pet" then
			self:initByRobot(self._petIdx)
		else
			self:initByPet(self._petIdx)
		end
		eventhub.fire("ROOKIE_EVENT", "ROOKIE_COMPLETE", "switchrobot")
	end
	
	self.useButton = self._bgRoot:add(ui.Button.new(useBtn, useBtn.."?scl=1.2", robotBtnPic2))
	self.useButton:setAnchor("MB", 0, 80)
	
	self._bgRoot:add(Image.new(panelLine))
	
	self._title = self._bgRoot:add(Image.new())
	self._title:setLoc(0, 350)
	
	self._robotbg = self._bgRoot:add(Image.new(robotbgPic))
	self._robotbg:setLoc(0, 156)
	
	self._unlockEffect = Image.new(unlockPic)
	self._unlockEffect.hitTest = function() return false end
	
	self._robot = self._bgRoot:add(Image.new())
	self._robot:setPriorityOffset(10)
	self._robot.hitTest = function()
		return false
	end
	
	self._robotShadow = self._bgRoot:add(Image.new())
	self._robotShadow:setPriorityOffset(9)
	self._robotShadow.hitTest = function()
		return false
	end
	
	self._lock = self._bgRoot:add(Image.new())
	self._lock:setLoc(0, 100)
	self._lock:setPriorityOffset(50)
	
	self._textBack = self._bgRoot:add(Image.new(textBackPic))
	self._textBack:setLoc(textBackX, textBackY)
	
	self._tbTextTitle = {}
	for key, var in ipairs(tbText[1]) do
		self._tbTextTitle[key] = self._textBack:add(Image.new(var))
	end
	
	self._petText = self._textBack:add(Image.new())
	
	self._petCost = self._textBack:add(Image.new())
	self._petCost:setLoc(-161, 40)
	
	self._robotUnlock = self._textBack:add(Image.new())
	self._robotUnlock:setLoc(0, 40)
	
	self._tbLvupEffect = {}
	for key, var in ipairs(tbLvupEffect) do
		self._tbLvupEffect[key] = Sprite.new(lvupEffect)
		self._tbLvupEffect[key]:setPriorityOffset(var.priority)
	end
	self._tbLvupEffect[2]:setBlendMode(MOAIProp.BLEND_ADD)
	
	self._tbPic = {}
	for key, var in ipairs(tbPic[2]) do
		self._tbPic[key] = self._textBack:add(Image.new(var))
	end
	self._tbText = {}
	for key, var in ipairs(tbPos) do
		self._tbText[key] = self._textBack:add(TextBox.new("1", "lock", nil, "LM", var[3]))
		self._tbText[key]:setLoc(var[1], var[2])
	end
	
	self._open = false
end

function PetPanel:open()
	self._open = true
	WindowOpenStyle:openWindowScl(self._bgRoot)
	WindowOpenStyle:openWindowAlpha(self._bgRoot)
	popupLayer:add(self._root)
end

function PetPanel:close()
	self._open = false
	popupLayer:remove(self._root)
	eventhub.fire("UI_EVENT", "OPEN_ROLE_PANEL")
end

function PetPanel:unlockEffect()
	self._robotbg:add(self._unlockEffect)
	self._unlockEffect:setScl(0.5, 0.5)
	self._unlockEffect:seekScl(2, 2, 1, MOAIEaseType.EASE_IN)
	self._unlockEffect:setRot(0)
	local c = self._unlockEffect:seekRot(270, 1.5, MOAIEaseType.LINEAR)
	c:setListener(MOAITimer.EVENT_STOP, function()
		self._unlockEffect:remove()
	end)
end

function PetPanel:setShadow(key, petIdx)	
	if key == "robot" then
		local pos = shadowPos.robot[petIdx]
		self._robotShadow:load(Pet.tbPetPic[petIdx].pet)
		self._robotShadow:setLoc(pos[1], pos[2])
	else
		local pos = shadowPos.pet[petIdx]
		self._robotShadow:load(Pet.tbPetPic[petIdx].robot)
		self._robotShadow:setLoc(pos[1], pos[2])
	end
	self._robotShadow:setScl(0.4)
	self._robotShadow:setColor(0.4, 0.4, 0.4, 0.8)
end

function PetPanel:initByPet(petIdx, flag)
	self._petIdx = petIdx
	
	local unlocked = UserData.petInfo[petIdx].unlocked
	
	local btnBgPic1 = Image.new(useBtn)
	btnBgPic1:add(Image.new(useBtnTable[unlocked].pic))
	local btnBgPic2 = Image.new(useBtn.."?scl=1.2")
	btnBgPic2:add(Image.new(useBtnTable[unlocked].pic))
	
	self.useButton:setUpPage(btnBgPic1)
	self.useButton:setDownPage(btnBgPic2)
	self.useButton:disable(false)
	self.useButton.onClick = useBtnTable[unlocked].fun
	
	local robotPic = Pet.tbPetPic[petIdx].pet
	self._robot:load(robotPic)
	self._robot:setLoc(petPos.pet[petIdx][1], petPos.pet[petIdx][2])
	self._robot:setScl(0.7)
	
	self:setShadow("pet", petIdx)
	
	local titlePic = Pet.tbPetPic[petIdx].pettitle
	self._title:load(titlePic)
	
	local textPic = Pet.tbPetPic[petIdx].pettext
	self._petText:load(textPic)
	self._petText:setLoc(0, -55)
	
	if unlocked then
		self._lock:load()
	else
		self._lock:load(lockPic)
	end
	
	for key, var in ipairs(tbText[1]) do
		self._tbTextTitle[key]:load(var)
	end
	
	if flag then
		if flag == "lvup" then
			for key, var in ipairs(tbLvupEffect) do
				self._bgRoot:add(self._tbLvupEffect[key])
				self._tbLvupEffect[key]:setLoc(var.x, var.y)
				local c = self._tbLvupEffect[key]:playAnim(var.name, false, false)
				self._tbLvupEffect[key]:throttle(1.2)
				c:setListener(MOAITimer.EVENT_STOP, function()
					self._tbLvupEffect[key]:stopAnim()
					self._tbLvupEffect[key]:remove()
				end)
			end
		else
			self:unlockEffect()
		end
	end
	
	local petLevel = UserData.petInfo[self._petIdx].level
	local attack_1 = Pet.PetAttack[self._petIdx][petLevel]
	local unlockCost = Pet:GetPetUnlock(self._petIdx)
	local updateCost = Pet:GetPetUpdate(self._petIdx, petLevel + 1)
	
	if unlocked then
		if updateCost then		
			local font = tbPic[3][UserData:costGoldTest(updateCost.gold)]
			self._tbText[3]:setFont(font)
		end
	else
		if unlockCost then
			local font = tbPic[3][UserData:costMoneyTest(unlockCost.money)]
			self._tbText[3]:setFont(font)
		end
	end
	
	local costPic = tbPic[1][unlocked]
	self._petCost:load(costPic)
	self._petCost:setLoc(-161, 40)
	
	self._tbPic[1]:load(tbPic[2][1])
	self._tbPic[1]:setLoc(-65, 110)
	self._textBack:add(self._tbText[2])
	self._tbText[1]:setLoc(-30, 110)
	self._robotUnlock:remove()
	
	if petLevel == PET_MAX_LEVEL then
		self._tbPic[2]:remove()
		self._tbText[3]:remove()
		self._petCost:remove()
		self.useButton:remove()
	else
		if unlocked then
			self._tbPic[2]:load(tbPic[2][2])
		else
			self._tbPic[2]:load(moneyPic)
		end
		self._tbPic[2]:setLoc(45, 40)
		self._textBack:add(self._tbPic[2])
		self._textBack:add(self._tbText[3])
		self._textBack:add(self._petCost)
		self._bgRoot:add(self.useButton)
	end
	
	if petLevel < PET_MAX_LEVEL then
		self._tbText[1]:setString(tostring(petLevel))
		self._tbText[2]:setString(tostring(attack_1))
		if unlocked then
			self._tbText[3]:setString(tostring(updateCost.gold), true)
		else
			self._tbText[3]:setString(tostring(unlockCost.money), true)
		end
		local w = self._tbText[3]:getSize()
		self._tbText[3]:setLoc(w / 2 - 76, 40)
		local x, y = self._tbText[3]:getLoc()
		self._tbPic[2]:setLoc(x + w / 2 + 20, y)
	else
		self._tbText[1]:setString(tostring(petLevel))
		self._tbText[2]:setString(tostring(attack_1))
	end
	
	self._page = "pet"
end

function PetPanel:initByRobot(petIdx, flag)
	self._petIdx = petIdx
	
	local unlocked = UserData:getRobot(petIdx)
	if unlocked then
		self.useButton:setUpPage(robotBtnPic2)
		self.useButton:disable(true)
	else
		self.useButton:setUpPage(robotBtnPic1)
		self.useButton:setDownPage(robotBtnPic1.."?scl=1.2")
		self.useButton:disable(false)
		self.useButton.onClick = function()
			UserData:robotUnlock(petIdx)
		end
	end
	self._bgRoot:add(self.useButton)
	
	local robotPic = Pet.tbPetPic[petIdx].robot
	self._robot:load(robotPic)
	self._robot:setLoc(petPos.robot[petIdx][1], petPos.robot[petIdx][2])
	self._robot:setScl(1)
	
	self:setShadow("robot", petIdx)
	
	local titlePic = Pet.tbPetPic[petIdx].robottitle
	self._title:load(titlePic)
	
	local textPic = Pet.tbPetPic[petIdx].robottext
	self._petText:load(textPic)
	self._petText:setLoc(0, -35)
	
	if unlocked then
		self._lock:load()
	else
		self._lock:load(lockPic)
	end
	
	for key, var in ipairs(tbText[2]) do
		self._tbTextTitle[key]:load(var)
	end
	
	self._textBack:add(self._petCost)
	self._petCost:load(autoUnlock)
	self._petCost:setLoc(-154, 40)
	self._tbText[2]:remove()
	
	local tbCost = Robot:getRobotCost(petIdx)
	local attack = Robot:getRobotAttack(petIdx)
	
	if tbCost.costType == "money" then
		self._tbPic[2]:load(moneyPic)
		local font = tbPic[3][UserData:costMoneyTest(tbCost.cost)]
		self._tbText[3]:setFont(font)
	else
		self._tbPic[2]:load(goldPic)
		local font = tbPic[3][UserData:costGoldTest(tbCost.cost)]
		self._tbText[3]:setFont(font)
	end
	self._tbPic[2]:setLoc(10, 75)
	self._textBack:add(self._tbPic[2])
	self._tbText[3]:setLoc(-26, 75)
	self._tbText[3]:setString(tostring(tbCost.cost), true)
	self._textBack:add(self._tbText[3])
	
	local w = self._tbText[3]:getSize()
	self._tbText[3]:setLoc(w / 2 - 78, 75)
	local x, y = self._tbText[3]:getLoc()
	self._tbPic[2]:setLoc(x + w / 2 + 20, y)
	
	self._tbPic[1]:load(Robot.robotAttackPic[petIdx])
	self._tbPic[1]:setLoc(0, 110)
	
	self._tbText[1]:setString(tostring(attack))
	self._tbText[1]:setLoc(135, 110)
	
	self._textBack:add(self._robotUnlock)
	self._robotUnlock:load(robotUnlock[petIdx])
	
	if flag and flag == "unlock" then
		self:unlockEffect()
	end
	
	self._page = "robot"
end

return PetPanel

