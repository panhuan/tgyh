
local TaskConfig = {}


--填写奖励的时候,如果有解锁超人或者机甲需最好填最后一个,为了保证一次只弹一个奖励
--任务分段
--主线 1~999
--日常 1000~1999
--活动 2000~2999
TaskConfig.taskList =
{
	["main"] =
	{
		[1] =
		{
			target = "mission_finish",
			needCount = 1,
			param = 10,
			operation = ">=",
			autoReward = false,
			event = "MISSION_FINISH",
			rewards =
			{
				money = 10,
			},
		},
		[2] =
		{
			target = "mission_finish",
			needCount = 1,
			param = 20,
			operation = ">=",
			autoReward = false,
			event = "MISSION_FINISH",
			rewards =
			{
				money = 20,
			},
		},
		[3] =
		{
			target = "mission_finish",
			needCount = 1,
			param = 30,
			operation = ">=",
			autoReward = false,
			event = "MISSION_FINISH",
			rewards =
			{
				money = 30,
			},
		},
		[4] =
		{
			target = "mission_finish",
			needCount = 1,
			param = 40,
			operation = ">=",
			autoReward = false,
			event = "MISSION_FINISH",
			rewards =
			{
				money = 40,
			},
		},
		[5] =
		{
			target = "mission_finish",
			needCount = 1,
			param = 50,
			operation = ">=",
			autoReward = false,
			event = "MISSION_FINISH",
			rewards =
			{
				money = 50,
			},
		},
		[6] =
		{
			target = "mission_finish",
			needCount = 1,
			param = 60,
			operation = ">=",
			autoReward = false,
			event = "MISSION_FINISH",
			rewards =
			{
				money = 60,
			},
		},
		[7] =
		{
			target = "stage_monster",
			needCount = 1,
			param = 10,
			operation = ">=",
			autoReward = false,
			event = "STAGE_MONSTER",
			rewards =
			{
				money = 20,
			},
		},
		[8] =
		{
			target = "stage_monster",
			needCount = 1,
			param = 20,
			operation = ">=",
			autoReward = false,
			event = "STAGE_MONSTER",
			rewards =
			{
				money = 40,
			},
		},
		[9] =
		{
			target = "stage_monster",
			needCount = 1,
			param = 30,
			operation = ">=",
			autoReward = false,
			event = "STAGE_MONSTER",
			rewards =
			{
				money = 60,
			},
		},
		[10] =
		{
			target = "pet_level",
			needCount = 1,
			param = 10,
			operation = ">=",
			autoReward = false,
			event = "PET_LEVELUP",
			rewards =
			{
				money = 20,
			},
		},
		[11] =
		{
			target = "pet_level",
			needCount = 1,
			param = 20,
			operation = ">=",
			autoReward = false,
			event = "PET_LEVELUP",
			rewards =
			{
				money = 40,
			},
		},
		[12] =
		{
			target = "pet_level",
			needCount = 1,
			param = 30,
			operation = ">=",
			autoReward = false,
			event = "PET_LEVELUP",
			rewards =
			{
				money = 60,
			},
		},
		[13] =
		{
			target = "mission_star",
			needCount = 30,
			autoReward = false,
			event = "MISSION_STAR",
			rewards =
			{
				money = 10,
			},
		},
		[14] =
		{
			target = "mission_star",
			needCount = 60,
			autoReward = false,
			event = "MISSION_STAR",
			rewards =
			{
				money = 20,
			},
		},
		[15] =
		{
			target = "mission_star",
			needCount = 90,
			autoReward = false,
			event = "MISSION_STAR",
			rewards =
			{
				money = 30,
			},
		},
		[16] =
		{
			target = "mission_star",
			needCount = 120,
			autoReward = false,
			event = "MISSION_STAR",
			rewards =
			{
				money = 40,
			},
		},
		[17] =
		{
			target = "mission_star",
			needCount = 150,
			autoReward = false,
			event = "MISSION_STAR",
			rewards =
			{
				money = 50,
			},
		},
		[18] =
		{
			target = "mission_star",
			needCount = 180,
			autoReward = false,
			event = "MISSION_STAR",
			rewards =
			{
				money = 60,
			},
		},
	},
	["daily"] =
	{
		[1000] =
		{
			target = "mossion",
			needCount = 1,
			autoReward = false,
			event = "MISSION_START",
			title = "ui.atlas.png#rw_zi_2.png",
			rewards =
			{
				item =
				{
					{itemId=2, num=1},
				},
			},
		},
		[1001] =
		{
			target = "mossion",
			needCount = 3,
			autoReward = false,
			event = "MISSION_START",
			title = "ui.atlas.png#rw_zi_2.png",

			rewards =
			{
				gold = 2000,
			},
		},
		[1002] =
		{
			target = "stage",
			needCount = 1,
			autoReward = false,
			event = "STAGE_START",
			rewards =
			{
				gold = 2000,
			},
		},
		[1003] =
		{
			target = "stage",
			needCount = 3,
			autoReward = false,
			event = "STAGE_START",
			rewards =
			{
				item =
				{
					{itemId=4, num=1},
				},
			},
		},
		[1004] =
		{
			target = "timing",
			needCount = 1,
			autoReward = false,
			event = "TIMING_START",
			rewards =
			{
				gold = 2000,
			},
		},
		[1005] =
		{
			target = "timing",
			needCount = 3,
			autoReward = false,
			event = "TIMING_START",
			rewards =
			{
				item =
				{
					{itemId=3, num=1},
				},
			},
		},
		[1006] =
		{
			target = "dailypet_level",
			needCount = 1,
			autoReward = false,
			event = "PET_LEVELUP",
			rewards =
			{
				gold = 1000,
			},
		},
		[1007] =
		{
			target = "dailypet_level",
			needCount = 3,
			autoReward = false,
			event = "PET_LEVELUP",
			rewards =
			{
				gold = 2000,
			},
		},
		[1008] =
		{
			target = "dailypet_level",
			needCount = 5,
			autoReward = false,
			event = "PET_LEVELUP",
			rewards =
			{
				money = 20,
			},
		},
	},
	["activity"] =
	{
		[2000] =
		{
			delete = true,
		},
		[2001] =
		{
			delete = true,
		},
		[2002] =
		{
			delete = true,
		},
		[2003] =
		{
			target = "order_target",
			param = 9,
			operation = "==",
			needCount = 1,
			autoReward = true,
			event = "ORDER_SUCCESS",
			rewards =
			{
				item =
				{
					{itemId=1, num=1},
					{itemId=6, num=1},
				},
			},
		},
		[2004] =
		{
			target = "order_target",
			param = 10,
			operation = "==",
			needCount = 1,
			autoReward = true,
			event = "ORDER_SUCCESS",
			rewards =
			{
				item =
				{
					{itemId=1, num=1},
					{itemId=2, num=1},
					{itemId=3, num=1},
					{itemId=4, num=1},
					{itemId=5, num=1},
					{itemId=6, num=1},
				},
			},
		},
	},
}

TaskConfig.updateTime = "03:30"

function TaskConfig:getUpdateTime()
	local hour, minute = string.split(self.updateTime, ":")
	local second = hour * 60 * 60 + minute * 60
	return second
end

function TaskConfig:getAllTasks()
	return self.taskList
end

function TaskConfig:getTaskListByType(type)
	return self.taskList[type]
end

function TaskConfig:getTaskType(taskId)
	if taskId >= 1 and taskId < 1000 then
		return "main"
	elseif taskId >= 1000 and taskId < 2000 then
		return "daily"
	elseif taskId >= 2000 then
		return "activity"
	else
		print("[WARN] unkonw tesk type, taskId = ", taskId)
		return "unkonw"
	end
end

function TaskConfig:getTarget(taskId)
	local type = self:getTaskType(taskId)
	local taskList = self:getTaskListByType(type)
	if not taskList or not taskList[taskId] then
		print("[WARN] no such task, taskId = ", taskId)
		return nil
	end

	return taskList[taskId].target
end

function TaskConfig:getNeedCount(taskId)
	local type = self:getTaskType(taskId)
	local taskList = self:getTaskListByType(type)
	if not taskList or not taskList[taskId] then
		print("[WARN] no such task, taskId = ", taskId)
		return nil
	end

	return taskList[taskId].needCount
end

function TaskConfig:getRewards(taskId)
	local type = self:getTaskType(taskId)
	local taskList = self:getTaskListByType(type)
	if not taskList or not taskList[taskId] then
		print("[WARN] no such task, taskId = ", taskId)
		return nil
	end

	return taskList[taskId].rewards
end

function TaskConfig:getEvent(taskId)
	local type = self:getTaskType(taskId)
	local taskList = self:getTaskListByType(type)
	if not taskList or not taskList[taskId] then
		print("[WARN] no such task, taskId = ", taskId)
		return nil
	end

	return taskList[taskId].event
end

function TaskConfig:getTaskParam(taskId)
	local type = self:getTaskType(taskId)
	local taskList = self:getTaskListByType(type)
	if not taskList or not taskList[taskId] then
		print("[WARN] no such task, taskId = ", taskId)
		return nil
	end

	return taskList[taskId].param
end

return TaskConfig
