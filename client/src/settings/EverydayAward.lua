
local EverydayAward =
{
	--  领奖刷新时间
	updateTime = "03:30",

	-- awardType 奖励的类型 gold金币 item道具 暂只支持这两种奖励模式
	-- param 参数 当type为gold时 param为金币数量 当type为item时 param为道具id 对应Item.lua中的table param2为道具数量
	[1] =
	{
		awardType = "item",
		param = 6,
		param2 = 1,
	},
	[2] =
	{
		awardType = "gold",
		param = 2500,
	},
	[3] =
	{
		awardType = "item",
		param = 1,
		param2 = 1,
	},
	[4] =
	{
		awardType = "gold",
		param = 4000,
	},
	[5] =
	{
		awardType = "item",
		param = 4,
		param2 = 1,
	},
	[6] =
	{
		awardType = "gold",
		param = 6000,
	},
	[7] =
	{
		awardType = "money",
		param = 50,
	},
}

function EverydayAward:getAward(idx)
	assert(idx >= 1 and idx <= 7, "EverydayAward wrong idx is: "..idx)
	if not self[idx] then
		return nil
	end
	return self[idx]
end

function EverydayAward:getUpdateTime()
	local hour, minute = string.split(self.updateTime, ":")
	local second = hour * 60 * 60 + minute * 60
	return second
end

return EverydayAward
