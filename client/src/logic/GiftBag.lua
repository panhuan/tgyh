
local eventhub = require "eventhub"
local UserData = require "UserData"

local GiftBag = {}

-- {type = "money", num = 10},
-- {type = "gold", num = 1000},
-- {type = "item", num = 1, itemId = 1},
-- {type = "unlock_pet", idx = 3},
-- {type = "unlock_robot", idx = 2},
		
GiftBag.tbBagList =
{
	[1] =
	{
		{type = "unlock_pet", idx = 3},
		{type = "unlock_pet", idx = 4},
	},
	[2] =
	{
		{type = "unlock_pet", idx = 3},
		{type = "unlock_pet", idx = 4},
		{type = "unlock_robot", idx = 3},
		{type = "unlock_robot", idx = 4},
	},

}


function GiftBag:init()
	eventhub.bind("SYSTEM_EVENT", "BUY_GIFT_BAG", function(id) self:buyGiftBag(id) end)
end

function GiftBag:buyGiftBag(id)
	local giftList = self.tbBagList[id]
	assert(giftList)
	
	for _, info in ipairs (giftList) do
		self:giveReawrd(info)
	end
end

function GiftBag:giveReawrd(info)
	if info.type == "unlock_pet" then
		UserData:petUnlockExecute(info.idx)
		return
	elseif info.type == "unlock_robot" then
		UserData:robotUnlockExecute(info.idx)
		return
	end

	if info.type == "money" then
		UserData:addMoney(info.num)
	elseif info.type == "gold" then
		UserData:addGold(info.num)
	elseif info.type == "item" then
		UserData:addItemCount(info.itemId, info.num)
	end

	local tbParam = {}
	tbParam.type = info.type
	tbParam.way = "giftbag"
	tbParam.num = info.num
	tbParam.itemId = info.itemId
	eventhub.fire("UI_EVENT", "OPEN_REWARD_PANEL", tbParam)
end

return GiftBag
