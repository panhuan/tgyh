
local ui = require "ui"
local device = require "device"
local Image = require "gfx.Image"
local TextBox = require "gfx.TextBox"
local eventhub = require "eventhub"
local UserData = require "UserData"
local Item = require "settings.Item"
local Mission = require "settings.Mission"
local WindowOpenStyle = require "windows.WindowOpenStyle"
local Buy = require "settings.Buy"
local AvatarConfig = require "settings.AvatarConfig"
local node = require "node"
local AP = require "settings.AP"
local GameConfig = require "settings.GameConfig"


local backGround = "panel/panel_1.atlas.png#panel_1.png"
local titlePic = "ui.atlas.png#mission_title.png"
local closePic1 = "ui.atlas.png#close_1.png"
local closePic2 = "ui.atlas.png#close_2.png?scl=1.2"
local useBtn = "ui.atlas.png#gk_btn.png"
local choosePic = "ui.atlas.png#choose_ico.png"
local textPic1 = "ui.atlas.png#target_monster.png?loc=-120, 260"
local textPic2 = "ui.atlas.png#choose_item.png?loc=-120, -20"
local btnText = "ui.atlas.png#game_begin_text.png"
local costPic = "ui.atlas.png#item_num.png"
local freePic = "ui.atlas.png#mf.png"
local item_explanation = "ui.atlas.png#item_sm.png"
local btn_ap1 = "ui.atlas.png#gk_ap.png"
local btn_ap2 = "ui.atlas.png#gk_ap_-.png"

local tbText = 
{
	[4] = "ui.atlas.png#zi_3.png?loc=0, 75",
	[5] = "ui.atlas.png#zi_2.png?loc=0, 75",
	[6] = "ui.atlas.png#item_zi_1.png?loc=0, 75",
}

local countPic = "ui.atlas.png#numbers.png"
local itemBackPic = "ui.atlas.png#s_window.png"
local tbCostImg = 
{
	["money"] = "ui.atlas.png#money_small.png",
	["gold"] = "ui.atlas.png#gold_small.png",
}

local MissionStartPanel = {}

function MissionStartPanel:init()
	eventhub.bind("UI_EVENT", "OPEN_MISSION_PANEL", function(missionIdx)
		if UserData:getRookieGuide("bomb") and UserData:getRookieGuide("skill") then
			self:open(missionIdx)
			if not UserData:getRookieGuide("item1") then
				eventhub.fire("ROOKIE_EVENT", "ROOKIE_TRIGGER", "item1")
			elseif not UserData:getRookieGuide("item2") then
				eventhub.fire("ROOKIE_EVENT", "ROOKIE_TRIGGER", "item2")
			elseif not UserData:getRookieGuide("item3") then
				eventhub.fire("ROOKIE_EVENT", "ROOKIE_TRIGGER", "item3")
			end
		else
			self._missionIdx = missionIdx
			self:OpenMission()
		end
	end)
	
	eventhub.bind("UI_EVENT", "ITEM_NUM_CHANGE", function(itemIdx, itemCount)
		if itemIdx >= 4 and itemIdx <= 6 then
			self:itemUpdate(itemIdx)
		end
	end)
	
	self._root = ui.PickBox.new(device.ui_width, device.ui_height)
	self._root:setPriorityOffset(100)
	self._bgRoot = self._root:add(Image.new(backGround))
	self._root:setLayoutSize(Image.getSize(self._bgRoot))
	
	local closeButton = self._bgRoot:add(ui.Button.new(closePic1, closePic2))
	closeButton:setAnchor("RT", -50, -90)
	closeButton.onClick = function()
		self:close()
	end
	
	self._btnNode = Image.new(useBtn)
	local text1 = self._btnNode:add(Image.new(btnText))
	text1:setLoc(-52, 0)
	local text2 = self._btnNode:add(Image.new(btn_ap1))
	text2:setLoc(45, 0)
	local text3 = self._btnNode:add(Image.new(btn_ap2))
	text3:setLoc(78, 0)
	self._apcost = self._btnNode:add(TextBox.new(tostring(AP.cost), "monster"))
	self._apcost:setLoc(115, 0)
	
	self.useButton = self._bgRoot:add(ui.Button.new(self._btnNode, 1.1))
	self.useButton:setAnchor("MB", 0, 80)
	self.useButton.onClick = function()
		self:OpenMission()
	end
	
	self._item_explanation = self._bgRoot:add(ui.Button.new(item_explanation, item_explanation.."?scl=1.2"))
	self._item_explanation:setLoc(115, -20)
	self._item_explanation.onClick = function()
		eventhub.fire("UI_EVENT", "OPEN_ITEM_EXPLANATION", "outside")
	end
	
	self._title = self._bgRoot:add(Image.new(titlePic))
	self._title:setAnchor("MT", -35, -90)
	self._number = self._title:add(TextBox.new("99", "mission_start", nil, "LM"))
	self._number:setLoc(120, 0)
	
	local textImg1 = self._bgRoot:add(Image.new(textPic1))
	self._textImg2 = self._bgRoot:add(Image.new(textPic2))
	
	self._box = self._bgRoot:add(node.new())
	
	self:createItems()
end

function MissionStartPanel:useItem()
	for key, var in pairs(self._tbUsedItem) do
		if var and UserData:getItemCount(key) > 0 then
			UserData:useItem(key)
		end
		self._tbUsedItem[key] = false
	end
end

function MissionStartPanel:OpenMission()
	if self._missionIdx <= UserData:getTopMission() then
		if UserData:CostAPByGame() then
			self:close()
			eventhub.fire("UI_EVENT", "CLOSE_MAIN_PANEL")
			eventhub.fire("UI_EVENT", "OPEN_GAME_PANEL", "mission", self._missionIdx)
			self:useItem()
		else
			local tbParam = {}
			tbParam.strIndex = 3
			tbParam.fun = function()
				eventhub.fire("UI_EVENT", "OPEN_BUY_PANEL", "moneytoap")
			end
			eventhub.fire("UI_EVENT", "OPEN_MESSAGEBOX", tbParam)
		end
	end
end

function MissionStartPanel:createItems()
	self._tbCount = {}
	self._tbCostTxt = {}
	self._tbChooseImg = {}
	self._tbUsedItem = {}
	self._tbFrame = {}
	self._tbCountImg = {}
	self._tbCostImg = {}

	self._dropList = ui.DropList.new(465, 209, 155, "horizontal")
	self._bgRoot:add(self._dropList)
	self._dropList:setAnchor("MB", 0, 270)	
	
	for i = 4, 6 do
		self:creatOneItem(self._dropList, i)
		self._tbUsedItem[i] = false
	end
end

function MissionStartPanel:creatOneItem(root, Idx)
	local itemData = Item:getItemInfo(Idx)
	local itemCount = UserData:getItemCount(Idx)
	
	local frame = root:addItem(Image.new(itemBackPic))
	local itemImg = frame:add(Image.new(itemData.pic))
	local costImg = frame:add(Image.new(costPic))
	costImg:setLoc(0, -70)
	local costtype = costImg:add(Image.new(tbCostImg[itemData.costtype]))
	costtype:setLoc(-35, 0)
	frame:add(Image.new(tbText[Idx]))
	
	self._tbCostTxt[Idx] = {}
	self._tbCostTxt[Idx][1] = Image.new(freePic)
	self._tbCostTxt[Idx][2] = TextBox.new(tostring(itemData.cost), "buyprice")
	self._tbCostTxt[Idx][1]:setLoc(15, 0)
	self._tbCostTxt[Idx][2]:setLoc(15, 0)
	
	self._tbCountImg[Idx] = frame:add(Image.new(countPic))
	self._tbCountImg[Idx]:setLoc(35, 50)
	self._tbCount[Idx] = self._tbCountImg[Idx]:add(TextBox.new(tostring(itemCount), "item"))
	if itemCount <= 0 then
		self._tbCountImg[Idx]:remove()
		costImg:add(self._tbCostTxt[Idx][2])
	else
		costImg:add(self._tbCostTxt[Idx][1])
	end
	
	self._tbChooseImg[Idx] = frame:add(Image.new())
	self._tbChooseImg[Idx]:setLoc(-50, 80)
	
	for k, v in pairs(frame._children) do
		frame._children[k].hitTest = function()
			return false
		end
	end
	
	self._tbFrame[Idx] = frame
	self._tbCostImg[Idx] = costImg
	
	frame.onClick = function()
		self._tbUsedItem[Idx] = not self._tbUsedItem[Idx]
		if UserData:getItemCount(Idx) > 0 or UserData:buyItemCount(Idx) then
			self:itemUpdate(Idx)
		end	
	end
end

function MissionStartPanel:itemUpdate(Idx)
	if self._tbUsedItem[Idx] then
		self._tbChooseImg[Idx]:load(choosePic)
	else
		self._tbChooseImg[Idx]:load()
	end
	local itemCount = UserData:getItemCount(Idx)
	self._tbCount[Idx]:setString(tostring(itemCount))
	if itemCount > 0 then
		self._tbFrame[Idx]:add(self._tbCountImg[Idx])
		self._tbCostImg[Idx]:add(self._tbCostTxt[Idx][1])
		self._tbCostTxt[Idx][2]:remove()
	else
		self._tbCountImg[Idx]:remove()
		self._tbCostImg[Idx]:add(self._tbCostTxt[Idx][2])
		self._tbCostTxt[Idx][1]:remove()
	end
end

function MissionStartPanel:buyItem(Idx)
	local itemCount = UserData:getItemCount(Idx)
	self._tbCount[Idx]:setString(tostring(itemCount), true)
	if itemCount > 0 then
		self._tbFrame[Idx]:add(self._tbCountImg[Idx])
		self._tbCostImg[Idx]:add(self._tbCostTxt[Idx][1])
		self._tbCostTxt[Idx][2]:remove()
	else
		self._tbCountImg[Idx]:remove()
		self._tbCostImg[Idx]:add(self._tbCostTxt[Idx][2])
		self._tbCostTxt[Idx][1]:remove()
	end
end

function MissionStartPanel:initByMissionIdx()
	self._number:setString(tostring(self._missionIdx))
	
	for i = 4, 6 do
		local itemData = Item:getItemInfo(i)
		local itemCount = UserData:getItemCount(i)
		local textCount = tostring(itemCount)
		
		if itemCount > 0 then
			self._tbFrame[i]:add(self._tbCountImg[i])
			self._tbCostImg[i]:add(self._tbCostTxt[i][1])
			self._tbCostTxt[i][2]:remove()
		else
			self._tbCountImg[i]:remove()
			self._tbCostImg[i]:add(self._tbCostTxt[i][2])
			self._tbCostTxt[i][1]:remove()
		end
		self._tbCount[i]:setString(textCount, true)
		self._tbChooseImg[i]:load()
		self._tbUsedItem[i] = false
	end
	
	self:openMonsterPanel()
end

function MissionStartPanel:openMonsterPanel()
	local data = {}
	data.root = self._box
	data.image = Mission:getMonsterBg(self._missionIdx, 1)
	data.x = 0
	data.y = 115
	data.w = 460
	data.h = 190
	data.monster = {}
	local monsterList = Mission:getMonsterList(self._missionIdx)
	for key, var in ipairs(monsterList) do
		data.monster[key] = var.avatarId
	end
	eventhub.fire("UI_EVENT", "OPEN_MONSTER_PANEL", data)
end

function MissionStartPanel:open(missionIdx)
	self._missionIdx = missionIdx
	self:initByMissionIdx()
	WindowOpenStyle:openWindowScl(self._bgRoot)
	WindowOpenStyle:openWindowAlpha(self._bgRoot)
	popupLayer:add(self._root)
end

function MissionStartPanel:close()
	popupLayer:remove(self._root)
	eventhub.fire("UI_EVENT", "CLOSE_MONSTER_PANEL")
end

return MissionStartPanel