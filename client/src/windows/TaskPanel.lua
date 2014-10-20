
local ui = require "ui"
local Image = require "gfx.Image"
local device = require "device"
local eventhub = require "eventhub"
local Item = require "settings.Item"
local TextBox = require "gfx.TextBox"
local TaskConfig = require "settings.TaskConfig"
local Task = require "logic.Task"
local WindowOpenStyle = require "windows.WindowOpenStyle"


local TaskPanel = {}


local backGround = "panel/panel_1.atlas.png#panel_1.png"
local titlePic = "ui.atlas.png#rw_zi_7.png"
local closePic = "ui.atlas.png#close_1.png"
local dailyPic1 = "ui.atlas.png#rw_tkan_1.png"
local dailyPic2 = "ui.atlas.png#rw_tkan_2.png"
local mainPic1 = "ui.atlas.png#rw_tkan_3.png"
local mainPic2 = "ui.atlas.png#rw_tkan_4.png"
local panelPic1 = "ui.atlas.png#rw_dk_1.png"
local panelPic2 = "ui.atlas.png#rw_dk_2.png"
local acceptPic = "ui.atlas.png#rw_lq_1.png"
local acceptedPic = "ui.atlas.png#rw_wc.png"
local rewardPic = "ui.atlas.png#rw_zi_2.png"
local taskNumPic = "ui.atlas.png#rw_ts_di.png"

local tbPos = 
{
	[Task.NO_REWARD] = {x = 140, y = -20},
	[Task.CAN_ACCEPT_REWARD] = {x = 160, y = -20},
	[Task.ACCEPTED_REWARD] = {x = 160, y = 0},
}

local tbAwardType = 
{
	["gold"] = "ui.atlas.png#gold_small.png",
	["exp"] = "",
	["ap"] = "ui.atlas.png#ap_big.png",
	["money"] = "ui.atlas.png#money_small.png",
}

local tbTitle = 
{
	["mission_finish"] = 
	{
		"ui.atlas.png#rw_xz_1.png",
		"ui.atlas.png#rw_xz_2.png",
	},
	["stage_monster"] = 
	{
		"ui.atlas.png#rw_xz_3.png",
		"ui.atlas.png#rw_xz_4.png",
	},
	["pet_level"] = 
	{
		"ui.atlas.png#rw_xz_5.png",
		"ui.atlas.png#rw_xz_6.png",
	},
	["mission_star"] = 
	{
		"ui.atlas.png#rw_xz_7.png",
		"ui.atlas.png#rw_xz_8.png",
	},
	["mossion"] = 
	{
		"ui.atlas.png#rw_xz_9.png",
		"ui.atlas.png#rw_xz_12.png",
	},
	["stage"] = 
	{
		"ui.atlas.png#rw_xz_9.png",
		"ui.atlas.png#rw_xz_10.png",
	},
	["timing"] = 
	{
		"ui.atlas.png#rw_xz_9.png",
		"ui.atlas.png#rw_xz_11.png",
	},
	["dailypet_level"] = 
	{
		"ui.atlas.png#rw_xz_14.png",
		"ui.atlas.png#rw_xz_13.png",
	},
}


function TaskPanel:init()
	eventhub.bind("UI_EVENT", "OPEN_TASK_PANEL", function()
		self:open()
	end)
	eventhub.bind("TASK_EVENT", "TASK_INIT_FINISH", function()
		self:InitTaskPanel()
	end)
	eventhub.bind("TASK_EVENT", "TASK_UPDATE", function(taskId)
		self:taskUpdate(taskId)
	end)
	eventhub.bind("TASK_EVENT", "TASK_FINISH", function(taskId)
		self:taskUpdate(taskId)
	end)
	
	self._root = ui.PickBox.new(device.ui_width, device.ui_height)
	self._root:setPriorityOffset(1)
	self._bgRoot = self._root:add(Image.new(backGround))
	self._root:setLayoutSize(self._bgRoot:getSize())
	
	self._title = self._bgRoot:add(Image.new(titlePic))
	self._title:setAnchor("MT", 0, -90)
	
	self._closeBtn = self._bgRoot:add(ui.Button.new(closePic))
	self._closeBtn:setAnchor("RT", -50, -90)
	self._closeBtn.onClick = function()
		self:close()
	end
	
	self._daily1 = Image.new(dailyPic1)
	self._dailyNumBg1 = self._daily1:add(Image.new(taskNumPic))
	self._dailyNumBg1:setLoc(75, 28)
	self._dailyNumText1 = self._dailyNumBg1:add(TextBox.new("10", "lock"))
	self._dailyNumText1:setLoc(-3, 3)
	
	self._daily2 = Image.new(dailyPic2)
	self._dailyNumBg2 = self._daily2:add(Image.new(taskNumPic))
	self._dailyNumBg2:setLoc(75, 28)
	self._dailyNumText2 = self._dailyNumBg2:add(TextBox.new("10", "lock"))
	self._dailyNumText2:setLoc(-3, 3)
	
	self._dailySwitch = self._bgRoot:add(ui.Switch.new(2, self._daily1, self._daily1, self._daily2, self._daily2))
	self._dailySwitch:setLoc(-160, 240)
	self._dailySwitch.onTurn = function(o, status)
		if status == 2 then
			self._taskList["main"]:remove()
			self._bgRoot:add(self._taskList["daily"])
			self._mainSwitch:turn(1)
			self._curPage = "daily"
		else
			if self._curPage == "daily" then
				self._dailySwitch:turn(2)
			end
		end
	end
	
	self._main1 = Image.new(mainPic1)
	self._mainNumBg1 = self._main1:add(Image.new(taskNumPic))
	self._mainNumBg1:setLoc(75, 28)
	self._mainNumText1 = self._mainNumBg1:add(TextBox.new("10", "lock"))
	self._mainNumText1:setLoc(-3, 3)
	
	self._main2 = Image.new(mainPic2)
	self._mainNumBg2 = self._main2:add(Image.new(taskNumPic))
	self._mainNumBg2:setLoc(75, 28)
	self._mainNumText2 = self._mainNumBg2:add(TextBox.new("10", "lock"))
	self._mainNumText2:setLoc(-3, 3)
	
	self._mainSwitch = self._bgRoot:add(ui.Switch.new(2, self._main1, self._main1, self._main2, self._main2))
	self._mainSwitch:setLoc(10, 240)
	self._mainSwitch.onTurn = function(o, status)
		if status == 2 then
			self._taskList["daily"]:remove()
			self._bgRoot:add(self._taskList["main"])
			self._dailySwitch:turn(1)
			self._curPage = "main"
		else
			if self._curPage == "main" then
				self._mainSwitch:turn(2)
			end
		end
	end
end

function TaskPanel:InitTaskPanel()
	self._task = {}
	self._taskList = {}
	self._canAccept = {}
	self._taskList["main"] = self:createTaskList("main")
	self._taskList["daily"] = self:createTaskList("daily")
	
	self._dailySwitch:turn(2)
	self._mainSwitch:turn(1)
	self._taskList["main"]:remove()
	self._bgRoot:add(self._taskList["daily"])
	self._curPage = "daily"
	
	self:updateTaskCanAcceptCount()
end

function TaskPanel:createTaskList(key)
	local taskList = ui.DropList.new(477, 470, 160, "vertical")
	taskList:setLoc(0, -50)
	
	self._task[key] = {}
	self._canAccept[key] = 0
	
	local keyList = table.keys(TaskConfig.taskList[key])
	table.sort(keyList, function(n1, n2)
		local task1 = Task:getTask(n1)
		local task2 = Task:getTask(n2)
		if task1.rewardState ~= task2.rewardState then
			return task1.rewardState > task2.rewardState
		else
			return n2 > n1
		end
	end)
	
	for _, taskId in ipairs(keyList) do
		self._task[key][taskId] = {}
		local frame = taskList:addItem(ui.PickBox.new(477, 160))
		self._task[key][taskId].frame = frame
		local panel = self:createTaskListItem(taskId, key)
		frame:add(panel)
	end
	
	return taskList
end

function TaskPanel:createTaskListItem(taskId, key)
	local panelPic = panelPic2
	local task = Task:getTask(taskId)

	if task.rewardState == Task.CAN_ACCEPT_REWARD then
		panelPic = panelPic1
		self._canAccept[key] = self._canAccept[key] + 1
	end
	
	local panel = Image.new(panelPic)
	self._task[key][taskId].panel = panel
	
	local target = TaskConfig:getTarget(taskId)
	local param = TaskConfig:getTaskParam(taskId) or TaskConfig:getNeedCount(taskId)
	local title1 = panel:add(Image.new(tbTitle[target][1]))
	local title2 = panel:add(Image.new(tbTitle[target][2]))
	local text = panel:add(TextBox.new(tostring(param), "rw_sz"))
	local title1_w = title1:getSize()
	local title2_w = title2:getSize()
	local text_w = text:getSize()
	local x = - 450 / 2 + title1_w / 2
	title1:setLoc(x, 36)
	text:setLoc(x + title1_w / 2 + text_w / 2, 36)
	title2:setLoc(x + title1_w / 2 + text_w + title2_w / 2, 36)
	
	if task.rewardState == Task.NO_REWARD and task.curCount > 0 then
		local needCount = TaskConfig:getNeedCount(taskId)
		local count = panel:add(TextBox.new("("..task.curCount.."/"..needCount..")", "rw_sz"))
		count:setLoc(tbPos[task.rewardState].x, tbPos[task.rewardState].y)
		self._task[key][taskId].child = count
	elseif task.rewardState == Task.CAN_ACCEPT_REWARD then
		local btn = panel:add(ui.Button.new(acceptPic))
		btn:setLoc(tbPos[task.rewardState].x, tbPos[task.rewardState].y)
		btn.onClick = function()
			Task:acceptReward(taskId)
		end
		self._task[key][taskId].child = btn
	elseif task.rewardState == Task.ACCEPTED_REWARD then
		local acceptedImg = panel:add(Image.new(acceptedPic))
		acceptedImg:setLoc(tbPos[task.rewardState].x, tbPos[task.rewardState].y)
		acceptedImg:setPriorityOffset(5)
		self._task[key][taskId].child = acceptedImg
	end
	
	local rewardImgX, rewardImgY = -200, -20
	local offset = 10
	local rewardImg = panel:add(Image.new(rewardPic))
	rewardImg:setLoc(rewardImgX, rewardImgY)
	local rewardImgW = rewardImg:getSize()
	local x = rewardImgX + rewardImgW / 2 + offset
	
	local rewards = TaskConfig:getRewards(taskId)
	for type, reward in pairs(rewards) do
		if type == "unlock_pet" then
			local petImg = panel:add(Image.new(tbPetUnlock[reward]))
			local petImgW = petImg:getSize()
			petImg:setLoc(x + petImgW / 2, rewardImgY)
			x = x + petImgW + offset
		elseif type == "unlock_robot" then
			local robotImg = panel:add(Image.new(tbRobotUnlock[reward]))
			local robotImgW = robotImg:getSize()
			robotImg:setLoc(x + robotImgW / 2, rewardImgY)
			x = x + robotImgW + offset
		elseif type == "item" then
			for _, item in ipairs(reward) do
				local pic = Item:getItemInfo(item.itemId).pic1 or Item:getItemInfo(item.itemId).pic
				local itemIco = panel:add(Image.new(pic))
				itemIco:setScl(0.6, 0.6)
				local icoW = itemIco:getSize()
				itemIco:setLoc(x + icoW / 2, rewardImgY)
				local number = panel:add(TextBox.new("x"..item.num, "rw_sz"))
				local w = number:getSize()
				number:setLoc(x + icoW + w / 2, rewardImgY)
				x = x + icoW + w + offset
			end
		else
			local rewardType = panel:add(Image.new(tbAwardType[type]))
			local typeW = rewardType:getSize()
			rewardType:setLoc(x + typeW / 2, rewardImgY)
			local number = panel:add(TextBox.new("x"..reward, "rw_sz", nil, "LM"))
			local w = number:getSize()
			number:setLoc(x + typeW + w / 2, rewardImgY)
			x = x + w + typeW + offset
		end
	end
	
	return panel
end

function TaskPanel:taskUpdate(taskId)
	local key = TaskConfig:getTaskType(taskId)
	if not self._task or not self._task[key] or not self._task[key][taskId] then
		return
	end
	local panelPic = panelPic2
	local task = Task:getTask(taskId)
	if self._task[key][taskId].child then
		self._task[key][taskId].child:remove()
		self._task[key][taskId].child:destroy()
	end
	local panel = self._task[key][taskId].panel
	if task.rewardState == Task.NO_REWARD and task.curCount > 0 then
		local needCount = TaskConfig:getNeedCount(taskId)
		local count = panel:add(TextBox.new("("..task.curCount.."/"..needCount..")", "rw_sz"))
		count:setLoc(tbPos[task.rewardState].x, tbPos[task.rewardState].y)
		self._task[key][taskId].child = count
	elseif task.rewardState == Task.CAN_ACCEPT_REWARD then
		local btn = panel:add(ui.Button.new(acceptPic))
		btn:setLoc(tbPos[task.rewardState].x, tbPos[task.rewardState].y)
		btn.onClick = function()
			Task:acceptReward(taskId)
		end
		self._task[key][taskId].child = btn
		panelPic = panelPic1
		self._canAccept[key] = self._canAccept[key] + 1
	elseif task.rewardState == Task.ACCEPTED_REWARD then
		local acceptedImg = panel:add(Image.new(acceptedPic))
		acceptedImg:setLoc(tbPos[task.rewardState].x, tbPos[task.rewardState].y)
		acceptedImg:setPriorityOffset(5)
		self._task[key][taskId].child = acceptedImg
		self._canAccept[key] = self._canAccept[key] - 1
	end
	self._task[key][taskId].panel:load(panelPic)
	
	self._taskList[key]:clearItems()
	local keyList = table.keys(TaskConfig.taskList[key])
	table.sort(keyList, function(n1, n2)
		local task1 = Task:getTask(n1)
		local task2 = Task:getTask(n2)
		if task1.rewardState ~= task2.rewardState then
			return task1.rewardState > task2.rewardState
		else
			return n2 > n1
		end
	end)
	for _, taskId in ipairs(keyList) do
		self._taskList[key]:addItem(self._task[key][taskId].frame)
		self._task[key][taskId].frame:add(self._task[key][taskId].panel)
	end
	
	self:updateTaskCanAcceptCount()
end

function TaskPanel:updateTaskCanAcceptCount()
	self._dailyNumText1:setString(tostring(self._canAccept["daily"]))
	self._dailyNumText2:setString(tostring(self._canAccept["daily"]))
	self._mainNumText1:setString(tostring(self._canAccept["main"]))
	self._mainNumText2:setString(tostring(self._canAccept["main"]))
	eventhub.fire("UI_EVENT", "TASK_NOACCEPT_COUNT", self._canAccept["daily"] + self._canAccept["main"])
end

function TaskPanel:open()
	WindowOpenStyle:openWindowScl(self._bgRoot)
	WindowOpenStyle:openWindowAlpha(self._bgRoot)
	popupLayer:add(self._root)
end

function TaskPanel:close()
	popupLayer:remove(self._root)
end

return TaskPanel