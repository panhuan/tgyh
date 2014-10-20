
local Item =
{
	-- costtype为购买道具所需要货币的类型
	[1] =
	{
		costtype = "gold",
		cost = 3000,
		pic = "gameplay.atlas.png#zhuanhuan_small.png",
		pic1 = "ui.atlas.png#zhuanhuan_big.png",
		effect = "changeareacolor",
	},
	[2] =
	{
		costtype = "gold",
		cost = 1500,
		pic = "gameplay.atlas.png#super_small.png",
		pic1 = "ui.atlas.png#super_big.png",
		effect = "supermode",
	},
	[3] =
	{
		costtype = "money",
		cost = 10,
		pic = "gameplay.atlas.png#gjxiang_small.png",
		pic1 = "ui.atlas.png#gjxiang_big.png",
		effect = "toolbox",
	},
	[4] =
	{
		costtype = "money",
		cost = 10,
		pic = "ui.atlas.png#dj_3.png",
		effect = "adddamage",
	},
	[5] =
	{
		costtype = "gold",
		cost = 1500,
		pic = "ui.atlas.png#dj_2.png",
		effect = "supermodeStep",
	},
	[6] =
	{
		costtype = "gold",
		cost = 2000,
		pic = "ui.atlas.png#dj_1.png",
		effect = "addStep",
		effectparam = 5,
	},
	[7] =
	{
		costtype = "gold",
		cost = 2000,
		pic = "ui.atlas.png#sj_1.png",
		effect = "addTime",
		effectparam = 10,
	},
	[8] =
	{
		costtype = "money",
		cost = 50,
		pic = "",
		effect = "kickMonster",
		effectparam = 1,
	},
	maxCount = 8,
}

--ballId=nil:表示随机,从第一个nil开始,之后的就是都是这个nil所随机出的颜色了
--ballId非0:根据填的id生成球
Item.tbChangeColorFormations =
{
	{--心形
		{c=4,r=4,ballId=nil},
		{c=5,r=5,ballId=nil},
		{c=6,r=4,ballId=nil},
		{c=6,r=3,ballId=nil},
		{c=6,r=2,ballId=nil},
		{c=5,r=2,ballId=nil},
		{c=4,r=1,ballId=nil},
		{c=3,r=2,ballId=nil},
		{c=2,r=2,ballId=nil},
		{c=2,r=3,ballId=nil},
		{c=2,r=4,ballId=nil},
		{c=3,r=5,ballId=nil},

	},
	{--S形
		{c=6,r=4,ballId=nil},
		{c=5,r=5,ballId=nil},
		{c=4,r=5,ballId=nil},
		{c=3,r=5,ballId=nil},
		{c=2,r=4,ballId=nil},
		{c=3,r=4,ballId=nil},
		{c=4,r=3,ballId=nil},
		{c=5,r=3,ballId=nil},
		{c=6,r=2,ballId=nil},
		{c=5,r=2,ballId=nil},
		{c=4,r=1,ballId=nil},
		{c=3,r=2,ballId=nil},
		{c=2,r=2,ballId=nil},
	},
	{--U形
		{c=2,r=5,ballId=nil},
		{c=2,r=4,ballId=nil},
		{c=2,r=3,ballId=nil},
		{c=2,r=2,ballId=nil},
		{c=3,r=2,ballId=nil},
		{c=4,r=1,ballId=nil},
		{c=5,r=2,ballId=nil},
		{c=6,r=2,ballId=nil},
		{c=6,r=3,ballId=nil},
		{c=6,r=4,ballId=nil},
		{c=6,r=5,ballId=nil},
	},
	{--M形
		{c=2,r=2,ballId=nil},
		{c=2,r=3,ballId=nil},
		{c=2,r=4,ballId=nil},
		{c=2,r=5,ballId=nil},
		{c=3,r=5,ballId=nil},
		{c=4,r=4,ballId=nil},
		{c=5,r=5,ballId=nil},
		{c=6,r=5,ballId=nil},
		{c=6,r=4,ballId=nil},
		{c=6,r=3,ballId=nil},
		{c=6,r=2,ballId=nil},
	},
}

function Item:getChangeColorFormation()
	local index = math.random(#self.tbChangeColorFormations)
	return self.tbChangeColorFormations[index]
end

function Item:getItemInfo(Idx)
	assert(Idx > 0 and Idx <= self.maxCount, "wrong Idx: "..Idx)
	return self[Idx]
end

return Item
