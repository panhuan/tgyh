
local UserData = require "UserData"
local eventhub = require "eventhub"
local ActLog = require "ActLog"

local Buy =
{
	-- money与gold兑换
	["moneytogold"] =
	{
		{src = 30, dest = 3000},
		{src = 60, dest = 6600},
		{src = 120, dest = 14400},
		{src = 240, dest = 33600},
		{src = 480, dest = 76800},
	},
	-- money与ap兑换
	["moneytoap"] =
	{
		{src = 6, dest = 6},
		{src = 18, dest = 20},
		{src = 30, dest = 36},
		{src = 60, dest = 80},
		{src = 128, dest = 180},
	},
}

Buy.tbRMBProductList = 
{
	[1] = 
	{
		src = 1, 
		dest = 50, 
		dest_type = "money", 
		name="50点券", 
		cmcc_paycode="30000838066504",
		cmcc_sms_paycode="30000841561001",
		cucc_sms_paycode="001",
		ctcc_sms_paycode="108462",
	},
	[2] = 
	{
		src = 6, 
		dest = 60, 
		dest_type = "money", 
		name="60点券", 
		cmcc_paycode="30000838066503",
		cmcc_sms_paycode="30000841561002",
		cucc_sms_paycode="002",
		ctcc_sms_paycode="108462",
	},
	[3] = 
	{
		src = 12, 
		dest = 130, 
		dest_type = "money", 
		name="130点券", 
		cmcc_paycode="30000838066502",
		cmcc_sms_paycode="30000841561003",
		cucc_sms_paycode="003",
		ctcc_sms_paycode="108462",
	},
	[4] = 
	{
		src = 30, 
		dest = 360, 
		dest_type = "money", 
		name="360点券", 
		cmcc_paycode="30000838066501",
		cmcc_sms_paycode="30000841561004",
		cucc_sms_paycode="004",
		ctcc_sms_paycode="108462",
	},
	[5] = 
	{
		src = 128, 
		dest = 1600, 
		dest_type = "money", 
		name="1600点券", 
	},
	[6] = 
	{
		src = 328, 
		dest = 4500, 
		dest_type = "money", 
		name="4500点券", 
	},
	[7] = 
	{
		src = 30, 
		dest = 76800, 
		dest_type = "gold", 
		name="76800金币", 
		cmcc_paycode="30000838066505",
		cmcc_sms_paycode="30000841561006",
		cucc_sms_paycode="005",
		ctcc_sms_paycode="108462",
	},
	[8] = 
	{
		src = 0.1, 
		dest = 1, 
		dest_type = "randombox", 
		name="随机宝箱", 
		cmcc_paycode="30000838066506",
		cmcc_sms_paycode="30000841561005",
		cucc_sms_paycode="006",
		ctcc_sms_paycode="108462",
	},
	[9] = 
	{
		src = 8, 
		dest = 1, 
		dest_type = "gift_bag",
		name="超人大礼包", 
		cmcc_paycode="30000838066514",
		cmcc_sms_paycode="30000841561014",
		cucc_sms_paycode="006",
		ctcc_sms_paycode="108462",
	},
	[10] = 
	{
		src = 28, 
		dest = 2, 
		dest_type = "gift_bag", 
		name="土豪大礼包", 
		cmcc_paycode="30000838066515",
		cmcc_sms_paycode="30000841561015",
		cucc_sms_paycode="006",
		ctcc_sms_paycode="108462",
	},
	[11] = 
	{
		src = 4, 
		dest = 3, 
		dest_type = "unlock_pet", 
		name="解锁甜心超人", 
		cmcc_paycode="30000838066507",
		cmcc_sms_paycode="30000841561007",
		cucc_sms_paycode="006",
		ctcc_sms_paycode="108462",
	},
	[12] = 
	{
		src = 6, 
		dest = 4, 
		dest_type = "unlock_pet", 
		name="解锁粗心超人", 
		cmcc_paycode="30000838066508",
		cmcc_sms_paycode="30000841561008",
		cucc_sms_paycode="006",
		ctcc_sms_paycode="108462",
	},
	[13] = 
	{
		src = 28, 
		dest = 5, 
		dest_type = "unlock_pet", 
		name="解锁小心超人", 
		cmcc_paycode="30000838066509",
		cmcc_sms_paycode="30000841561009",
		cucc_sms_paycode="006",
		ctcc_sms_paycode="108462",
	},
	[14] = 
	{
		src = 6, 
		dest = 2, 
		dest_type = "unlock_robot", 
		name="解锁花心机车侠", 
		cmcc_paycode="30000838066510",
		cmcc_sms_paycode="30000841561010",
		cucc_sms_paycode="006",
		ctcc_sms_paycode="108462",
	},
	[15] = 
	{
		src = 12, 
		dest = 3, 
		dest_type = "unlock_robot", 
		name="解锁甜心机车侠", 
		cmcc_paycode="30000838066511",
		cmcc_sms_paycode="30000841561011",
		cucc_sms_paycode="006",
		ctcc_sms_paycode="108462",
	},
	[16] = 
	{
		src = 22, 
		dest = 4, 
		dest_type = "unlock_robot", 
		name="解锁粗心机车侠", 
		cmcc_paycode="30000838066512",
		cmcc_sms_paycode="30000841561012",
		cucc_sms_paycode="006",
		ctcc_sms_paycode="108462",
	},
	[17] = 
	{
		src = 28, 
		dest = 5, 
		dest_type = "unlock_robot", 
		name="解锁小心机车侠", 
		cmcc_paycode="30000838066513",
		cmcc_sms_paycode="30000841561013",
		cucc_sms_paycode="006",
		ctcc_sms_paycode="108462",
	},
	[18] = 
	{
		src = 1, 
		dest = 10, 
		dest_type = "money", 
		name="10点券", 
		cmcc_paycode="30000838066516",
		cmcc_sms_paycode="30000841561016",
		cucc_sms_paycode="001",
		ctcc_sms_paycode="108462",
	},
}

-- 不同版本的充值列表,充值界面根据此做排序
-- 人民币与money兑换列表
Buy.tbRMBtoMoneyProductList =
{
	["SMSPay"] = {18, 2, 3, 4},
	["Qihoo"] = {18, 2, 3, 4, 5, 6},
}

function Buy:getRMBtoMoneyProductList(version)
	for k, v in pairs(Buy.tbRMBtoMoneyProductList) do
		if version:find(k) then
			return v
		end
	end
end

function Buy:getRMBProductInfo(idx)
	assert(Buy.tbRMBProductList[idx], "wrong idx: "..idx)
	return Buy.tbRMBProductList[idx]
end

function Buy:RMBPay(idx)
	ActLog:RMBPayBegin(idx)
	eventhub.fire("SYSTEM_EVENT", "PLAYER_PAY", idx)
end

function Buy:MoneytoGold(idx)
	assert(self["moneytogold"][idx], "wrong idx: "..idx)
	local tb = self["moneytogold"][idx]
	if UserData:costMoneyTest(tb.src) then
		eventhub.fire("SYSTEM_EVENT", "BUY_GOLD", idx)
		UserData:costMoney(tb.src)
		UserData:addGold(tb.dest)
		
		local tbParam = {}
		tbParam.type = "gold"
		tbParam.way = "exchange"
		tbParam.num = tb.dest
		eventhub.fire("UI_EVENT", "OPEN_REWARD_PANEL", tbParam)
	else
		local tbParam = {}
		tbParam.strIndex = 1
		tbParam.fun = function()
			eventhub.fire("UI_EVENT", "OPEN_BUY_PANEL", "rmbtomoney")
		end
		eventhub.fire("UI_EVENT", "OPEN_MESSAGEBOX", tbParam)
	end
end

function Buy:MoneytoAP(idx)
	assert(self["moneytoap"][idx], "wrong idx: "..idx)
	local tb = self["moneytoap"][idx]
	if UserData:costMoneyTest(tb.src) then
		eventhub.fire("SYSTEM_EVENT", "BUY_AP", idx)
		UserData:costMoney(tb.src)
		UserData:addAP(tb.dest)
		
		local tbParam = {}
		tbParam.type = "ap"
		tbParam.way = "exchange"
		tbParam.num = tb.dest
		eventhub.fire("UI_EVENT", "OPEN_REWARD_PANEL", tbParam)
	else
		local tbParam = {}
		tbParam.strIndex = 1
		tbParam.fun = function()
			eventhub.fire("UI_EVENT", "OPEN_BUY_PANEL", "rmbtomoney")
		end
		eventhub.fire("UI_EVENT", "OPEN_MESSAGEBOX", tbParam)
	end
end

function Buy:getProductIdByCmccSmsPayCode(paycode)
	for idx, product in pairs (Buy.tbRMBProductList) do
		if product.cmcc_sms_paycode == paycode then
			return idx
		end
	end
end

function Buy:getProductIdByCuccSmsPayCode(paycode)
	for idx, product in pairs (Buy.tbRMBProductList) do
		if product.cucc_sms_paycode == paycode then
			return idx
		end
	end
end

function Buy:getProductIdByCtccSmsPayCode(paycode)
	for idx, product in pairs (Buy.tbRMBProductList) do
		if product.ctcc_sms_paycode == paycode then
			return idx
		end
	end
end
return Buy
