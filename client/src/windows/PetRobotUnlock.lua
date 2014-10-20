
local ui = require "ui"
local Image = require "gfx.Image"
local device = require "device"
local eventhub = require "eventhub"
local Pet = require "settings.Pet"
local Robot = require "settings.Robot"
local MainPanel = require "windows.MainPanel"
local PetPanel = require "windows.PetPanel"
local WindowOpenStyle = require "windows.WindowOpenStyle"


local backGround = "panel/step_bg.atlas.png#step_bg.png"
local useBtn = "ui.atlas.png#ck_liang.png"
local petTitle = "ui.atlas.png#hd_zi_2.png"
local robotTitle = "ui.atlas.png#hd_zi_1.png"


local PetRobotUnlock = {}

function PetRobotUnlock:init()
	eventhub.bind("UI_EVENT", "OPEN_UNLOCK_PANEL", function(key, idx)
		self:tryOpen()
	end)
	eventhub.bind("UI_EVENT", "PET_UNLOCK", function(idx)
		self:push("pet", idx)
		self:tryOpen()
	end)
	eventhub.bind("UI_EVENT", "ROBOT_UNLOCK", function(idx)
		self:push("robot", idx)
		self:tryOpen()
	end)
	self._root = ui.PickBox.new(device.ui_width, device.ui_height)
	self._root:setPriorityOffset(200)
	self._bgRoot = self._root:add(Image.new(backGround))
	self._root:setLayoutSize(self._bgRoot:getSize())
	
	self._useBtn = self._bgRoot:add(ui.Button.new(useBtn, 1.2))
	self._useBtn:setAnchor("MB", 0, 70)
	
	self._title = self._bgRoot:add(Image.new())
	self._title:setAnchor("MT", 0, -80)
	self._Img = self._bgRoot:add(Image.new())	
end

function PetRobotUnlock:preOpen(key, idx)
	local img = nil
	local title = nil
	if key == "robot" then
		img = Pet.tbPetPic[idx].robot
		title = robotTitle
	else
		img = Pet.tbPetPic[idx].pet
		title = petTitle
	end
	self._Img:load(img)
	if idx == 5 and key == "robot" then
		self._Img:setLoc(50, 0)
	else
		self._Img:setLoc(0, 0)
	end
	self._title:load(title)
	
	WindowOpenStyle:nodeJellyEffect(self._Img)
	
	self._useBtn.onClick = function()
		if not self._tbParamList or #self._tbParamList == 0 then
			eventhub.fire("UI_EVENT", "OPEN_PET_PANEL", idx, key)		
		end
		self:close()
	end
end

function PetRobotUnlock:open(key, idx)
	if self._isOpen then
		self:push(key, idx)
		return
	end
	self._isOpen = true
	self:preOpen(key, idx)
	popupLayer:add(self._root)
	WindowOpenStyle:openWindowAlpha(self._bgRoot)
end

function PetRobotUnlock:close()
	popupLayer:remove(self._root)
	self._isOpen = nil
	self:tryOpen()
end

function PetRobotUnlock:push(key, idx)
	if not self._tbParamList then
		self._tbParamList = {}
	end
	table.insert(self._tbParamList, {key, idx})
end

function PetRobotUnlock:pop()
	if not self._tbParamList then
		return
	end
	
	local tbParam = self._tbParamList[1]
	if tbParam then
		table.remove(self._tbParamList, 1)
	end
	
	return tbParam
end

function PetRobotUnlock:tryOpen()
	if self._isOpen then
		return
	end
	
	if not MainPanel._open then
		return
	end

	local tbParam = self:pop()
	
	if tbParam and not PetPanel._open then	
		self:open(tbParam[1], tbParam[2])
	end
end

return PetRobotUnlock