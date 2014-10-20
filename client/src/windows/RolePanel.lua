
local ui = require "ui"
local Image = require "gfx.Image"
local Sprite = require "gfx.Sprite"
local eventhub = require "eventhub"
local device = require "device"
local UserData = require "UserData"
local Pet = require "settings.Pet"
local Exp = require "settings.Exp"
local TextBox = require "gfx.TextBox"
local FillBar = require "gfx.FillBar"
local node = require "node"
local PlayerAttr = require "settings.PlayerAttr"
local WindowOpenStyle = require "windows.WindowOpenStyle"


local RolePanel = {}


local backGround = "panel/panel_1.atlas.png#panel_1.png?loc=0, -20"
local closePic1 = "ui.atlas.png#close_1.png"
local closePic2 = "ui.atlas.png#close_2.png?scl=1.2"
local rolePic = "ui.atlas.png#zhaiboshi_ico.png?loc=-200, 15"
local hpBgPic = "ui.atlas.png#expfillbar_panel.png?loc=0, -15"
local hpPic = "expfillbar.png"
local titlePic = "ui.atlas.png#role_title.png?loc=0, 350"
local roleBG = "ui.atlas.png#role_panel.png?loc=20, 225"
local roleLvPic = "ui.atlas.png#role_lv.png?loc=-120, 30"
local autoLvUpPic = "ui.atlas.png#js.png"
local petBGPic = "ui.atlas.png#pet_panel.png"
local petLvPic = "ui.atlas.png#pet_lv.png?loc=-15, -90"
local petLockPic = "ui.atlas.png#pet_lock.png"
local petLockPanel = "ui.atlas.png#pet_lock_panel.png"
local panelLine = "ui.atlas.png#role_line.png?loc=0, 120"
local petShadowPic = "ui.atlas.png#pet_shadow.png"
local expImg = "ui.atlas.png#exp_-.png?loc=-26, 0"
local levelPic1 = "ui.atlas.png#cr_xx_zi_1.png"
local levelPic2 = "ui.atlas.png#cr_xx_zi_2.png"

local lvupEffect = "effect.atlas.png"
local tbLvupEffect =
{
	{x = 0, y = 0, name = "lvup1", priority = 1, scl = 0.5},
	{x = 0, y = 10, name = "lvup2", priority = 100, scl = 0.5},
	{x = 0, y = 150, name = "lvup3", priority = 150, scl = 0.5},
}

local levelW, levelH = 160, 50

local tbPos =
{
	{
		[true] = {1, 75},
		[false] = {4, 80},
	},
	{
		[true] = {0, 77},
		[false] = {12, 80},
	},
	{
		[true] = {0, 73},
		[false] = {-4, 85},
	},
	{
		[true] = {-2, 70},
		[false] = {-8, 65},
	},
	{
		[true] = {0, 83},
		[false] = {0, 80},
	},
}


function RolePanel:init()
	eventhub.bind("UI_EVENT", "OPEN_ROLE_PANEL", function()
		self:open()
	end)
	eventhub.bind("UI_EVENT", "PET_UNLOCK", function(petIdx)
		self:petUnlock(petIdx)
	end)
	eventhub.bind("UI_EVENT", "PLAYER_LEVEL_UP", function()
		self._level:setString(tostring(UserData.level))
		if UserData.level == Exp:getMaxLevel() + 1 then
			self._expBar:setFill(0, 1)
			self._curExp:remove()
		end
		local income = PlayerAttr:getIncome(UserData.level)
		local score = "+"..income.score.."%"
		local gold = "+"..income.gold.."%"
		self._levelText1:setString(score, true)
		self._levelText2:setString(gold, true)
	end)
	eventhub.bind("UI_EVENT", "PLAYER_EXP_CHANGE", function()
		self:initExpBar()
	end)
	eventhub.bind("UI_EVENT", "PET_LEVEL_UP", function(petIdx)
		self:petUndata(petIdx)
	end)
	eventhub.bind("UI_EVENT", "WINDOW_SCL_OVER", function(node)
		if self._bgRoot == node then
			eventhub.fire("ROOKIE_EVENT", "ROOKIE_COMPLETE", "openrolepanel")
		end
	end)
	self._root = ui.PickBox.new(device.ui_width, device.ui_height)
	self._root:setPriorityOffset(500)
	self._bgRoot = Image.new(backGround)
	self._root:add(self._bgRoot)
	self._root:setLayoutSize(Image.getSize(self._bgRoot))
	
	self._bgRoot:add(Image.new(titlePic))
	self._bgRoot:add(Image.new(panelLine))
	
	self.autoLvUpButton = self._bgRoot:add(ui.Button.new(autoLvUpPic, 1.2))
	self.autoLvUpButton:setLoc(0, -370)
	self.autoLvUpButton.onClick = function()
		UserData:petAutoLevelUp()
	end
	
	self.closeButton = self._bgRoot:add(ui.Button.new(closePic1, closePic2))
	self.closeButton:setAnchor("RT", -50, -90)
	self.closeButton.onClick = function()
		self:close()
	end
	
	local roleBGImg = self._bgRoot:add(Image.new(roleBG))
	
	local levelImg = roleBGImg:add(Image.new(roleLvPic))
	self._level = levelImg:add(TextBox.new(tostring(UserData.level), "role", nil, "LM", 50))
	self._level:setLoc(40, 0)
	
	self._levelTitle1 = self._bgRoot:add(Image.new(levelPic1))
	self._levelTitle1:setLoc(-120, 145)
	self._levelTitle2 = self._bgRoot:add(Image.new(levelPic2))
	self._levelTitle2:setLoc(30, 145)
	
	local income = PlayerAttr:getIncome(UserData.level)
	local score = "+"..income.score.."%"
	local gold = "+"..income.gold.."%"
	self._levelText1 = self._bgRoot:add(TextBox.new(score, "level1"))
	self._levelText1:setLoc(-50, 145)
	self._levelText2 = self._bgRoot:add(TextBox.new(gold, "level1"))
	self._levelText2:setLoc(100, 145)
	
	self._expBarBG = roleBGImg:add(Image.new(hpBgPic))
	self._expBar = self._expBarBG:add(FillBar.new(hpPic))
	self._expBar:add(Image.new(rolePic))
	
	self._curExp = self._expBar:add(TextBox.new("1", "exp", nil, nil, 300))
	self._curExp:setLoc(0, -2)
	
	self._tbPetImg = {}
	
	for i = 1, PET_COUNT do
		local petBG = self._bgRoot:add(Image.new(petBGPic))
		petBG:setLoc(Pet.tbPetPic[i].x, Pet.tbPetPic[i].y)
		local petShadow = petBG:add(Image.new(petShadowPic))
		petShadow:setLoc(0, -60)
		
		local petPicLock = Pet.tbPetPic[i][false].pic
		local petPicUnlock = Pet.tbPetPic[i][true].pic
		local petNode = petShadow:add(ui.wrap(node.new()))
		local pet_Lock = petNode:add(Image.new(petPicLock))
		pet_Lock:setLoc(tbPos[i][false][1], tbPos[i][false][2])
		local pet_Unlock = petNode:add(Image.new(petPicUnlock))
		pet_Unlock:setLoc(tbPos[i][true][1], tbPos[i][true][2])
		
		local lvUpSprite = {}
		for key, var in ipairs(tbLvupEffect) do
			lvUpSprite[key] = Sprite.new(lvupEffect)
			lvUpSprite[key]:setPriorityOffset(var.priority)
			lvUpSprite[key]:setScl(var.scl)
			
			if key == 2 then
				lvUpSprite[key]:setBlendMode(MOAIProp.BLEND_ADD)
			end
		end
		
		local petLockNode = nil
		if not UserData.petInfo[i].unlocked then
			petLockNode = petBG:add(Image.new(petLockPanel))
			petLockNode:setPriorityOffset(100)
			petLockNode.hitTest = function() return false end
			petLock = petLockNode:add(Image.new(petLockPic))
			petLock:setLoc(10, 0)
			petLock.hitTest = function() return false end
			local lockLevel = tostring(Pet.PetUnLockByLevel[i].level)
			local petLockText = petLockNode:add(TextBox.new(lockLevel, "pet"))
			petLockText:setLoc(-45, -1)
			petLockText.hitTest = function() return false end
			pet_Unlock:remove()
		else
			pet_Lock:remove()
		end
		
		petNode.handleTouch = ui.handleTouch
		petNode.onClick = function()
			self:close()
			eventhub.fire("UI_EVENT", "OPEN_PET_PANEL", i)
			if i == 1 then --开心超人
				eventhub.fire("ROOKIE_EVENT", "ROOKIE_COMPLETE", "openpetpanel")
			end
		end
		
		local petLvImg = petBG:add(Image.new(petLvPic))
		local petLvText = petLvImg:add(TextBox.new(tostring(UserData.petInfo[i].level), "pet", nil, "MM", 40))
		petLvText:setLoc(25, -1)
		
		self._tbPetImg[i] = {petNode, pet_Lock, pet_Unlock, petLockNode, petLvText, lvUpSprite}
	end
	
	self:initExpBar()
end

function RolePanel:petUnlock(petIdx)
	assert(self._tbPetImg[petIdx], "wrong petIdx: "..petIdx)
	local petPic = Pet.tbPetPic[petIdx][UserData.petInfo[petIdx].unlocked].pic
	self._tbPetImg[petIdx][2]:remove()
	self._tbPetImg[petIdx][1]:add(self._tbPetImg[petIdx][3])
	if self._tbPetImg[petIdx][4] then
		self._tbPetImg[petIdx][4]:remove()
	end
end

function RolePanel:petUndata(petIdx)
	assert(self._tbPetImg[petIdx], "wrong petIdx: "..petIdx)
	self._tbPetImg[petIdx][5]:setString(tostring(UserData.petInfo[petIdx].level))
	self:petLvUpEffect(petIdx)
end

function RolePanel:petLvUpEffect(petIdx)
	local petNode = self._tbPetImg[petIdx][1]
	local lvUpSprite = self._tbPetImg[petIdx][6]
	if lvUpSprite["playling"] then
		return
	end
	
	for key, var in ipairs(tbLvupEffect) do
		petNode:add(lvUpSprite[key])
		lvUpSprite[key]:setLoc(var.x, var.y)
		local c = lvUpSprite[key]:playAnim(var.name, false, false)
		lvUpSprite[key]:throttle(1.2)
		lvUpSprite["playling"] = true
		c:setListener(MOAITimer.EVENT_STOP, function()
			lvUpSprite[key]:stopAnim()
			lvUpSprite[key]:remove()
			lvUpSprite["playling"] = nil
		end)
	end
end

function RolePanel:initExpBar()
	local thisLevelExp = Exp:getExp(UserData.level)
	if thisLevelExp then
		self._expBar:setFill(0, UserData.exp / thisLevelExp)
		local strExp = UserData.exp.."/"..thisLevelExp
		self._curExp:setString(strExp)
	else
		self._curExp:remove()
	end
end

function RolePanel:switchAnim(isOpen)
	for key, var in ipairs(self._tbPetImg) do
		if var[3]._parent and isOpen then
			--var[3]:playAnim("custom_ani", true, false)
		else
			--var[3]:stopAnim()
		end
	end
end

function RolePanel:open()
	self:switchAnim(true)
	WindowOpenStyle:openWindowScl(self._bgRoot)
	WindowOpenStyle:openWindowAlpha(self._bgRoot)
	popupLayer:add(self._root)
end

function RolePanel:close()
	popupLayer:remove(self._root)
	self:switchAnim(false)
	eventhub.fire("ROOKIE_EVENT", "ROOKIE_COMPLETE", "closerolepanel")
end

return RolePanel