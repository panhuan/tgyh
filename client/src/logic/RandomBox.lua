
local eventhub = require "eventhub"
local UserData = require "UserData"

local RandomBox = {}
RandomBox.tbBoxList =
{
	--总概率和为100
	[1] =
	{
		{type = "gold", num = 50, percent = 30},
		{type = "gold", num = 1000, percent = 30},
		{type = "money", num = 10, percent = 5},
		{type = "item", num = 1, itemId = 1, percent = 5},
		{type = "item", num = 1, itemId = 2, percent = 5},
		{type = "item", num = 1, itemId = 3, percent = 5},
		{type = "item", num = 1, itemId = 4, percent = 5},
		{type = "item", num = 1, itemId = 5, percent = 5},
		{type = "item", num = 1, itemId = 6, percent = 5},
		{type = "item", num = 1, itemId = 7, percent = 5},
	},

}


function RandomBox:init()
	eventhub.bind("SYSTEM_EVENT", "BUY_RANDOMBOX", function(id) self:buyRandomBox(id) end)
end

function RandomBox:getRandomList(id)
	assert(self.tbBoxList[id], "error random box id" .. id)
	return self.tbBoxList[id]
end

function RandomBox:buyRandomBox(id)
	local randomList = self:getRandomList(id)
	local num = math.random(1, 100)
	for _, info in pairs (randomList) do
		if info.percent >= num then
			self:giveReawrd(info)
			return
		else
			num = num - info.percent
		end
	end
end

function RandomBox:giveReawrd(info)
	if info.type == "money" then
		UserData:addMoney(info.num)
	elseif info.type == "gold" then
		UserData:addGold(info.num)
	elseif info.type == "item" then
		UserData:addItemCount(info.itemId, info.num)
	end

	local tbParam = {}
	tbParam.type = info.type
	tbParam.way = "randombox"
	tbParam.num = info.num
	tbParam.itemId = info.itemId
	eventhub.fire("UI_EVENT", "OPEN_REWARD_PANEL", tbParam)
end

return RandomBox
