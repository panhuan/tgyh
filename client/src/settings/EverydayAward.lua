
local EverydayAward =
{
	--  �콱ˢ��ʱ��
	updateTime = "03:30",

	-- awardType ���������� gold��� item���� ��ֻ֧�������ֽ���ģʽ
	-- param ���� ��typeΪgoldʱ paramΪ������� ��typeΪitemʱ paramΪ����id ��ӦItem.lua�е�table param2Ϊ��������
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
