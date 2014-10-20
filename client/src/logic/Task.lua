
local TaskConfig = require "settings.TaskConfig"
local eventhub = require "eventhub"
local qlog = require "qlog"
local UserData = require "UserData"
local Social = require "Social"
local Text = require "settings.Text"
local ActLog = require "ActLog"
local compare = require "compare"

local Task ={}

Task.NO_REWARD = 1
Task.ACCEPTED_REWARD = 0
Task.CAN_ACCEPT_REWARD = 2

function Task:init()
	Player:getServerTime(function(now)
		self:serverTimeFun(now)
	end)
end

function Task:serverTimeFun(now)
	local result = UserData:checkTaskTime(now)
	self:initTaskByConfig(result)
	self:bindTaskEvent()
	self:checkTask()
	eventhub.fire("TASK_EVENT", "TASK_INIT_FINISH")
end

-- 从配置中更新未在玩家任务数据内的任务
function Task:initTaskByConfig(update)
	local allTasks = TaskConfig:getAllTasks()
	for type, tasks in pairs (allTasks) do
		if not UserData.taskList[type] then
			UserData.taskList[type] = {}
		end
		local taskList = UserData.taskList[type]
		
		for taskId, info in pairs (tasks) do
			if not info or info.delete then
				--空任务,或已删任务
				if taskList[taskId] then
					taskList[taskId] = nil
				end
			else
				local task = taskList[taskId]
				if not task or update and type == "daily" then
					task = {}
					task.curCount = 0
					task.rewardState = Task.NO_REWARD
					taskList[taskId] = task
				end
				
				task.onEvent = function(count, param)
					qlog.debug("Task onEvent", info.target, info.needCount, task.rewardState, count, info.param, param)
					if task.rewardState == Task.NO_REWARD then
						if info.param and not compare:doCompare(param, info.param, info.operation) then
							return
						end
						task.curCount = task.curCount + (count or 1)
						if task.curCount >= info.needCount then
							qlog.debug("Task finish", taskId)
							task.curCount = info.needCount
							task.rewardState = Task.CAN_ACCEPT_REWARD
							self:unbindTaskEvent(taskId)
							eventhub.fire("TASK_EVENT", "TASK_FINISH", taskId)
							
							if info.autoReward then
								self:acceptReward(taskId)
							end
						else
							eventhub.fire("TASK_EVENT", "TASK_UPDATE", taskId)
						end
						UserData:save()
					end
				end
			end
		end
	end
end

function Task:getTask(taskId)
	local type = TaskConfig:getTaskType(taskId)
	if UserData.taskList and UserData.taskList[type] then
		return UserData.taskList[type][taskId]
	end
end

function Task:bindTaskEvent()
	self._tbBindedEvent = {}
	for type, tasks in pairs (UserData.taskList) do
		for taskId, task in pairs (tasks) do
			local event = TaskConfig:getEvent(taskId)
			-- 未领奖的才需要注册事件
			if task.rewardState == Task.NO_REWARD and event then			
				local key = eventhub.bind("TASK_EVENT", event, task.onEvent)
				self._tbBindedEvent[taskId] = {key = key, event = event}
			end
		end
	end
end

function Task:unbindTaskEvent(taskId)
	local info = self._tbBindedEvent[taskId]
	if info then
		eventhub.unbind("TASK_EVENT", info.event, info.key)
		self._tbBindedEvent[taskId] = nil
	end
end

function Task:checkTask()
	for type, tasks in pairs (UserData.taskList) do
		if type == "main" then
			for taskId, task in pairs (tasks) do
				local param = TaskConfig:getTaskParam(taskId)
				if TaskConfig:getTarget(taskId) == "mission_finish" then
					if UserData:getCurMission() >= param then
						task.onEvent(1, param)
					end
				elseif TaskConfig:getTarget(taskId) == "stage_monster" then
					if UserData.stage >= param then
						task.onEvent(1, param)
					end
				elseif TaskConfig:getTarget(taskId) == "pet_level" then
					for key, var in ipairs(UserData.petInfo) do
						if var.level >= param then
							task.onEvent(1, param)
						end
					end
				elseif TaskConfig:getTarget(taskId) == "mission_star" then
					local totalStar = UserData:getTotalStar()
					if totalStar ~= task.curCount then
						task.curCount = 0
						task.onEvent(totalStar)
					end
				end
			end
		end
	end
end

function Task:acceptReward(taskId)
	local task = self:getTask(taskId)
	if task and task.rewardState == Task.CAN_ACCEPT_REWARD then
		task.rewardState = Task.ACCEPTED_REWARD
		local rewards = TaskConfig:getRewards(taskId)
		self:giveReward(rewards, taskId)
		eventhub.fire("TASK_EVENT", "TASK_UPDATE", taskId)
	end
end

function Task:giveReward(rewards, taskId)
	for type, param in pairs (rewards) do
		if type == "gold" then
			UserData:addGold(param)
			Task:openRewardPanel(taskId, type, param)
		elseif type == "exp" then
			UserData:addExp(param)
			Task:openRewardPanel(taskId, type, param)
		elseif type == "ap" then
			UserData:addAP(param)
			Task:openRewardPanel(taskId, type, param)
		elseif type == "money" then
			UserData:addMoney(param)
			ActLog:taskRewardsMoney(taskId)
			Task:openRewardPanel(taskId, type, param)
		elseif type == "unlock_pet" then
			UserData:petUnlockExecute(param)
		elseif type == "unlock_robot" then
			UserData:robotUnlockExecute(param)
		elseif type == "item" then
			for _, itemInfo in pairs (param) do
				UserData:addItemCount(itemInfo.itemId, itemInfo.num)
				Task:openRewardPanel(taskId, type, itemInfo.num, itemInfo.itemId)
			end
		else
			qlog.warn("No such reward type", type, toprettystring(param))
		end
	end
end

function Task:openRewardPanel(taskId, type, param1, param2)
	local useFun = nil
	local taskShare = false
	local taskType = TaskConfig:getTaskType(taskId)
	if taskType == "main" then
		useFun = function()
			Social.shareUrl(UserData.ShareURL, Text.shareTaskMoney[taskId].title, Text.shareTaskMoney[taskId].desc, true, function(ok)
				if ok then
					UserData:addMoney(20)
					ActLog:shareTask(taskId)
				end
			end)
		end
		taskShare = true
	end
	local tbParam = {}
	tbParam.type = type
	tbParam.way = "reward"
	tbParam.num = param1
	tbParam.itemId = param2
	tbParam.sharefun = useFun
	tbParam.share = taskShare
	eventhub.fire("UI_EVENT", "OPEN_REWARD_PANEL", tbParam)
end

function Task:isFinish(taskId)
	local task = self:getTask(taskId)
	if not task then
		return false
	end
	
	if not task.rewardState then
		task.rewardState = Task.NO_REWARD
	end
	
	return task.rewardState ~= Task.NO_REWARD
end

return Task