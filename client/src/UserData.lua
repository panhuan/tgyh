
local Pet = require "settings.Pet"
local AP = require "settings.AP"
local Exp = require "settings.Exp"
local Item = require "settings.Item"
local Robot = require "settings.Robot"
local Mission = require "settings.Mission"
local EverydayAward = require "settings.EverydayAward"
local TaskConfig = require "settings.TaskConfig"
local eventhub = require "eventhub"
local timer = require "timer"
local PersistentTable = require "PersistentTable"
local keys = require "keys"
local crypto = require "crypto"
local versionutil = require "versionutil"

local enc_0 = crypto.encode(0)
local enc_1 = 1

local initData =
{
	APP_VERSION = APP_VERSION,
	
	lastLaunchTime = 0,
	
	WeChatAppID = nil,
	
	ShareURL = nil,
	
	hpFactor = 1,
	-- 人民币
	money = 0,

	-- 游戏货币
	gold = 0,

	-- 体力值
	ap = 30,

	-- 角色级别
	level = 1,

	-- 角色经验
	exp = 0,

	-- 无尽模式最好成绩
	stage = 0,
	
	-- 无尽模式最高分数
	score = 0,

	-- 关卡模式成绩
	mission = {},
	
	-- 时间模式最好成绩
	timing = {},

	-- 时间模式最好分数
	timingScore = {},
	
	-- 上次时间模式的开启时间
	timingOpen = {},
	
	-- 音乐
	music = 1,

	-- 音效
	sound = 1,

	-- 新手引导
	rookieguide = {},
	
	-- 每日奖励
	award = {},

	-- 玩家有用的道具列表
	item =
	{
		[1] =
		{
			count = enc_0,
		},
		[2] =
		{
			count = enc_0,
		},
		[3] =
		{
			count = enc_0,
		},
	},

	-- 宠物信息 初始时 unlocked = false 表示被锁住
	-- level 要求必须>=1
	petInfo =
	{
		[1] =
		{
			level = enc_1,
			unlocked = true,
		},
		[2] =
		{
			level = enc_1,
			unlocked = false,
		},
		[3] =
		{
			level = enc_1,
			unlocked = false,
		},
		[4] =
		{
			level = enc_1,
			unlocked = false,
		},
		[5] =
		{
			level = enc_1,
			unlocked = false,
		},
	},
	
	-- 机车侠
	robotInfo =
	{
		[1] = false,
		[2] = false,
		[3] = false,
		[4] = false,
		[5] = false,
	},
	
	taskList = {},
	
	orderList = {},
	
	smsOrderList = {},
	
	--简易支付渠道(30元以下直接走短信,以上走360支付,当前仅用于360版本)
	simplePayChannel = false, 
	--------------------------------------------------------
}

local cryptoF = {
	encode = crypto.encode,
	decode = crypto.decode,
}

local cryptoT = {
	["money"] = cryptoF,
	["gold"] = cryptoF,
	["ap"] = cryptoF,
	["exp"] = cryptoF,
	["stage"] = cryptoF,
	["score"] = cryptoF,
}

for k, v in pairs(initData) do
	local f = cryptoT[k]
	if f then
		initData[k] = f.encode(v)
	end
end

-- 读取帐号
local AccountData, adError = PersistentTable.new("accountData.lua", true, keys.v0)
if not AccountData._guid then
	AccountData._guid = MOAIEnvironment.generateGUID()
	AccountData:save()
end

-- 根据帐号,获取用户数据
local UserDataM, udError = PersistentTable.new(AccountData._guid.."/userData.lua", true, keys.v0, initData)

-- 生成玩家guid
if not UserDataM._guid then
	UserDataM._guid = AccountData._guid
	UserDataM:save()
else
	-- 帐号必须与用户数据一致
	assert(AccountData._guid == UserDataM._guid)
end

if versionutil.numeric(APP_VERSION) > versionutil.numeric(UserDataM.APP_VERSION) then
	UserDataM.APP_VERSION = APP_VERSION
end

local UserData = {
	adError = adError,
	udError = udError,
}

function UserData:save()
	UserDataM:save()
end

function UserData:getGuid()
	return self._guid
end

-- 给出操作玩家数据的接口 在其他模块严禁直接操作数据 方便记录log
function UserData:addMoney(money)
	self.money = self.money + money
	self:save()
	eventhub.fire("UI_EVENT", "MONEY_CHANGE")
	print("[#UserData:addMoney#] money :", self.money)
end

function UserData:costMoneyTest(money)
	if self.money < money then
		return false
	end
	return true
end

function UserData:costMoney(money)
	if self:costMoneyTest(money) then
		self.money = self.money - money
		self:save()
		eventhub.fire("UI_EVENT", "MONEY_CHANGE")
		print("[#UserData:costMoney#] money :", self.money)
		return true
	end
	return false
end

function UserData:addGold(gold)
	self.gold = self.gold + gold
	self:save()
	eventhub.fire("UI_EVENT", "GOLD_CHANGE")
	print("[#UserData:addGold#] gold :", self.gold)
end

function UserData:costGoldTest(gold)
	if self.gold < gold then
		return false
	end
	return true
end

function UserData:costGold(gold)
	if self:costGoldTest(gold) then
		self.gold = self.gold - gold
		self:save()
		eventhub.fire("UI_EVENT", "GOLD_CHANGE")
		print("[#UserData:costGold#] gold :", self.gold)
		return true
	end
	return false
end

function UserData:addAP(ap)
	self.ap = self.ap + ap
	self:save()
	eventhub.fire("UI_EVENT", "AP_CHANGE")
	print("[#UserData:addAP#] AP :", self.ap)
end

function UserData:costAPTest(ap)
	if self.ap < ap then
		return false
	end
	return true
end

function UserData:costAP(ap)
	if self:costAPTest(ap) then
		self.ap = self.ap - ap
		self:save()
		eventhub.fire("UI_EVENT", "AP_CHANGE")
		print("[#UserData:costAP#] AP :", self.ap)
		return true
	end
	return false
end

function UserData:addExp(exp)
	local thisLevelExp = Exp:getExp(self.level)
	if not thisLevelExp then
		return false
	end
	local newExp = self.exp + exp
	if newExp < thisLevelExp then
		self.exp = newExp
		eventhub.fire("UI_EVENT", "PLAYER_EXP_CHANGE")
		self:save()
		print("[#UserData:addExp#] exp:", exp)
	else
		self.level = self.level + 1
		eventhub.fire("UI_EVENT", "PLAYER_LEVEL_UP")
		if self.ap < AP.maxAP then
			self.ap = AP.maxAP
			eventhub.fire("UI_EVENT", "AP_CHANGE")
		end
		self:save()
		
		local ActLog = require "ActLog"
		ActLog:palyerLvup(self.level)
		
		print("[#UserData:addExp_levelup#] level:", self.level)
		self:checkPetUnlock()
		self.exp = 0
		self:addExp(newExp - thisLevelExp)
	end
	return true
end

function UserData:checkPetUnlock()
	for key, var in ipairs(Pet.PetUnLockByLevel) do
		if self.level >= var.level and not self.petInfo[key].unlocked then
			self.petInfo[key].unlocked = true
			self:save()
			eventhub.fire("UI_EVENT", "PET_UNLOCK", key)
			print("[#UserData:checkPetUnlock#] petIdx:", key)
		end
	end
end

function UserData:setStage(stage)
	if stage <= 0 or self.stage >= stage then
		return false
	end
	self.stage = stage
	self:save()
	eventhub.fire("UI_EVENT", "PLAYER_STAGE_CHANGE")
	print("[#UserData:setStage#] stage:", self.stage)
	return true
end

function UserData:setScore(score)
	if score <= 0 or self.score >= score then
		return false
	end
	self.score = score
	self:save()
	print("[#UserData:setScore#] score:", self.score)
	return true
end

function UserData:getCurMission()
	return #(self.mission)
end

function UserData:getTopMission()
	local topMission = Mission:GetMonsterUICount()
	if topMission <= #(self.mission) then
		return topMission
	else
		return #(self.mission) + 1
	end
end

function UserData:setMission(mission, star)
	if not mission or mission > #(self.mission) + 1 then
		return false
	end
	if mission <= #(self.mission) then
		if star > self.mission[mission].star then
			local addStar = star - self.mission[mission].star
			self.mission[mission].star = star
			self:save()
			eventhub.fire("UI_EVENT", "MISSION_UPDATE", mission)
			eventhub.fire("TASK_EVENT", "MISSION_STAR", addStar)
		end
	else
		table.insert(self.mission, {star = star})
		self:save()
		eventhub.fire("UI_EVENT", "MISSION_UPDATE", mission)
		eventhub.fire("TASK_EVENT", "MISSION_STAR", star)
	end
	print("[#UserData:setMission#] mission and star:", mission, star)
	return true
end

function UserData:getTotalStar()
	local totalStar = 0
	for key, var in pairs(UserData.mission) do
		totalStar = totalStar + var.star
	end
	return totalStar
end

function UserData:setTiming(idx, timing)
	if timing <= 0 then
		return false
	end
	if not self.timing[idx] then
		self.timing[idx] = 0
	end
	if self.timing[idx] >= timing then
		return false
	end
	self.timing[idx] = timing
	self:save()
	print("[#UserData:setTiming#] timing:", self.timing[idx])
	return true
end

function UserData:setTimingScore(idx, score)
	if score <= 0 then
		return false
	end
	if not self.timingScore[idx] then
		self.timingScore[idx] = 0
	end
	if self.timingScore[idx] >= score then
		return false
	end
	self.timingScore[idx] = score
	self:save()
	print("[#UserData:setTimingScore#] timingScore:", self.timingScore[idx])
	return true
end

function UserData:setTimingOpen(idx, val)
	self.timingOpen[idx] = val
	self:save()
end

function UserData:getTimingOpen(idx)
	return self.timingOpen[idx] or 0
end

function UserData:getRookieGuide(rookie)
	return self.rookieguide[rookie]
end

function UserData:setRookieGuide(rookie)
	if self.rookieguide[rookie] then
		return false
	end
	self.rookieguide[rookie] = true
	self:save()
	return true
end

function UserData:rookieGuideisOver()
	local result = true
	local tbName = 
	{
		"link", "pet", "bomb", "robot", "skill", "item1", "item2", "item3", "item4", "item5", "item6", "stage", "timing"
	}
	for key, var in pairs(tbName) do
		if not self:getRookieGuide(var) then
			result = false
		end
	end
	return result
end

function UserData:setAwardInfo(stamp)
	if not stamp then
		return nil
	end

	if not self.award.stamp or not self.award.days then
		self.award.stamp = 0
		self.award.days = 0
	end
	local updatetime = EverydayAward:getUpdateTime()
	
	stamp = stamp - updatetime
	local tbDateNow = os.date("*t", stamp)
	local tbDataLast = os.date("*t", self.award.stamp)
	
	
	local nowday = tbDateNow.year * 365 + tbDateNow.yday
	local lastday = tbDataLast.year * 365 + tbDataLast.yday
	
	local index = nil
	if nowday > lastday then
		if nowday == (lastday + 1) and self.award.days < 7 then
			self.award.days = self.award.days + 1
		else
			self.award.days = 1
		end
		self.award.stamp = stamp
		index = self.award.days
	end
	self:save()
	return index
end


-- 返回值
-- 0 成功
-- 1 人物级别低于要求
-- 2 money不足
-- 3 gold不足
function UserData:petUnlockTest(petIdx)
	if self.petInfo[petIdx].unlocked then
		return -1
	end
	local petUnlock = Pet:GetPetUnlock(petIdx)
	if self.level < petUnlock.level then
		return 1
	end
	if not self:costMoneyTest(petUnlock.money) then
		return 2
	end
	if not self:costGoldTest(petUnlock.gold) then
		return 3
	end
	return 0
end

function UserData:petUnlock(petIdx)
	if self:petUnlockTest(petIdx) ~= 0 then
		return false
	end
	local petUnlock = Pet:GetPetUnlock(petIdx)
	if not self:costMoney(petUnlock.money) then
		return false
	end
	if not self:costGold(petUnlock.gold) then
		return false
	end
	self:petUnlockExecute(petIdx)
	return true
end

function UserData:petUnlockExecute(petIdx)
	self.petInfo[petIdx].unlocked = true
	self:save()
	eventhub.fire("UI_EVENT", "PET_UNLOCK", petIdx)
	print("[#UserData:petUnlock#] petIdx:", petIdx)
	local ActLog = require "ActLog"
	ActLog:unlockPet(petIdx)
end

function UserData:calcUnlockAllPetMoney()
	local needMoney = 0
	for idx, pet in pairs (Pet.PetUnLock) do
		if not self.petInfo[idx].unlocked then
			needMoney = needMoney + pet.money
		end
	end
	
	return needMoney
end

function UserData:unlockAllPet()
	local needMoney = self:calcUnlockAllPetMoney()
	if not self:costMoney(needMoney) then
		return false
	end
	
	for idx, pet in pairs (Pet.PetUnLock) do
		if not self.petInfo[idx].unlocked then
			if idx ~= 1 and idx ~= 2 then
				self:petUnlockExecute(idx)
			end
		end
	end
	
	return true
end

-- 返回值
-- 0 成功
-- 1 人物级别低于要求
-- 2 money不足
-- 3 gold不足
-- 4 宠物已达最高级
function UserData:petLevelUpTest(petIdx)
	if not self.petInfo[petIdx].unlocked then
		return -1
	end
	if self.petInfo[petIdx].level >= PET_MAX_LEVEL then
		return 4
	end
	local petUpdate = Pet:GetPetUpdate(petIdx, self.petInfo[petIdx].level + 1)
	if not petUpdate then
		return 1
	end	
	if self.level < petUpdate.level then
		return 1
	end
	if not self:costMoneyTest(petUpdate.money) then
		return 2
	end
	if not self:costGoldTest(petUpdate.gold) then
		return 3
	end
	return 0
end

function UserData:petLevelUp(petIdx)
	if self:petLevelUpTest(petIdx) ~= 0 then
		return false
	end
	local petUpdate = Pet:GetPetUpdate(petIdx, self.petInfo[petIdx].level + 1)
	if not self:costMoney(petUpdate.money) then
		return false
	end
	if not self:costGold(petUpdate.gold) then
		return false
	end
	self.petInfo[petIdx].level = self.petInfo[petIdx].level + 1
	
	local level = Robot:getRobotUnlockByPetLevel(petIdx)
	if not self:getRobot(petIdx) and self.petInfo[petIdx].level >= level then
		self.robotInfo[petIdx] = true
		eventhub.fire("UI_EVENT", "ROBOT_UNLOCK", petIdx)
	end
	eventhub.fire("TASK_EVENT", "PET_LEVELUP", 1, self.petInfo[petIdx].level)
	self:save()
	eventhub.fire("UI_EVENT", "PET_LEVEL_UP", petIdx)
	print("[#UserData:petLevelUp#] petIdx:", petIdx, ", level:", self.petInfo[petIdx].level)
	
	local ActLog = require "ActLog"
	ActLog:updatePetLevel(petIdx, self.petInfo[petIdx].level)
	return true
end

function UserData:petAutoLevelUp()
	local petList = {}
	for idx, pet in ipairs (self.petInfo) do
		if pet.unlocked and pet.level < PET_MAX_LEVEL then
			local pos = #petList + 1
			for i, p in ipairs (petList) do
				if pet.level < p.level then
					pos = i
				end
			end
			table.insert(petList, pos, {petIdx = idx, level = pet.level})
		end
	end

	if #petList == 0 then
		return
	end
	
	for i, pet in ipairs (petList) do
		if petList[i+1] then
			petList[i].interval = petList[i+1].level - pet.level
		else
			petList[i].interval = 0
		end
	end
	
	local curTurn = 1
	local petIdx = petList[curTurn].petIdx
	local petUpdate = Pet:GetPetUpdate(petIdx, self.petInfo[petIdx].level + 1)
	if not self:costGoldTest(petUpdate.gold) then
		local tbParam = {}
		tbParam.strIndex = 2
		tbParam.fun = function()
			eventhub.fire("UI_EVENT", "OPEN_BUY_PANEL", "moneytogold")
		end
		eventhub.fire("UI_EVENT", "OPEN_MESSAGEBOX", tbParam)
	end

	while true do
		petIdx = petList[curTurn].petIdx
		if not self:petLevelUp(petIdx) then
			return
		else
			if petList[curTurn].interval > 0 then
				petList[curTurn].interval = petList[curTurn].interval - 1
			else
				if curTurn + 1 > #petList then
					curTurn = 1
				else
					curTurn = curTurn + 1
				end
			end
		end
	end
	
end

function UserData:isPetUnlock(petIdx)
	return self.petInfo[petIdx].unlocked
end

function UserData:getRobot(idx)
	return self.robotInfo[idx]
end

function UserData:robotUnlock(idx, noMsg)
	if self.robotInfo[idx] == nil then
		return false
	end
	if self.robotInfo[idx] == true then
		return false
	end
	local tbCost = Robot:getRobotCost(idx)
	if not tbCost then
		return false
	end
	if tbCost.costType == "money" then
		if not self:costMoney(tbCost.cost) then
			if not noMsg then
				local tbParam = {}
				tbParam.strIndex = 1
				tbParam.fun = function()
					eventhub.fire("UI_EVENT", "OPEN_BUY_PANEL", "rmbtomoney")
				end
				eventhub.fire("UI_EVENT", "OPEN_MESSAGEBOX", tbParam)
			end
			return false
		end
	else
		if not self:costGold(tbCost.cost) then
			if not noMsg then
				local tbParam = {}
				tbParam.strIndex = 2
				tbParam.fun = function()
					eventhub.fire("UI_EVENT", "OPEN_BUY_PANEL", "moneytogold")
				end
				eventhub.fire("UI_EVENT", "OPEN_MESSAGEBOX", tbParam)
			end
			return false
		end
	end
	self:robotUnlockExecute(idx)
	return true
end

function UserData:robotUnlockExecute(idx)
	self.robotInfo[idx] = true
	self:save()
	eventhub.fire("UI_EVENT", "ROBOT_UNLOCK", idx)	
	local ActLog = require "ActLog"
	ActLog:unlockRobot(idx)
end

function UserData:calcUnlockAllRobotMoney()
	local needMoney = 0
	for idx, robot in pairs (Robot.robotUnlock) do
		if not self.robotInfo[idx] then
			needMoney = needMoney + robot.cost
		end
	end
	
	return needMoney
end

function UserData:unlockAllRobot()
	local needMoney = self:calcUnlockAllRobotMoney()
	if not self:costMoney(needMoney) then
		return false
	end
	
	for idx, robot in pairs (Robot.robotUnlock) do
		if not self.robotInfo[idx] then
			if idx ~= 1 then
				self:robotUnlockExecute(idx)
			end
		end
	end
	
	return true
end

function UserData:isRobotUnlock(idx)
	return self.robotInfo[idx]
end

function UserData:getItemCount(Idx)
	if self.item[Idx] and self.item[Idx].count then
		return crypto.decode(self.item[Idx].count)
	end
	return 0
end

function UserData:setItemCount(Idx, count)
	if not self.item[Idx] then
		self.item[Idx] = {}
	end
	if not self.item[Idx].count then
		self.item[Idx].count = enc_0
	end
	self.item[Idx].count = crypto.encode(count)
	self:save()
	
	eventhub.fire("UI_EVENT", "ITEM_NUM_CHANGE", Idx, self:getItemCount(Idx))
	
	print("[#UserData:setItemCount#] Idx:", Idx, ", count:", count)
end

function UserData:addItemCount(Idx, count)
	if not self.item[Idx] then
		self.item[Idx] = {}
	end
	if not self.item[Idx].count then
		self.item[Idx].count = enc_0
	end
	local mycount = crypto.decode(self.item[Idx].count)
	self.item[Idx].count = crypto.encode(mycount + count)
	self:save()
	
	eventhub.fire("UI_EVENT", "ITEM_NUM_CHANGE", Idx, self:getItemCount(Idx))
	
	print("[#UserData:addItemCount#] Idx:", Idx, ", count:", count)
end

function UserData:useItem(Idx)
	if self:getItemCount(Idx) > 0 then
		self:setItemCount(Idx, self:getItemCount(Idx) - 1)
		self:save()
		eventhub.fire("UI_EVENT", "USE_ITEM", Idx)
		eventhub.fire("UI_EVENT", "ITEM_NUM_CHANGE", Idx, self:getItemCount(Idx))
	else
		if Idx >= 1 and Idx <= 3 then
			eventhub.fire("UI_EVENT", "OPEN_ITEM_PANEL", Idx)
		else
			local itemInfo = Item:getItemInfo(Idx)
			if itemInfo.costtype == "gold" then
				if self:costGoldTest(itemInfo.cost) then
					if self:costGold(itemInfo.cost) then
						eventhub.fire("UI_EVENT", "USE_ITEM", Idx)
					end
				else
					eventhub.fire("UI_EVENT", "OPEN_BUY_PANEL", "moneytogold")
					return false
				end
			else
				if self:costMoneyTest(itemInfo.cost) then
					if self:costMoney(itemInfo.cost) then
						eventhub.fire("UI_EVENT", "USE_ITEM", Idx)
					end
				else
					eventhub.fire("UI_EVENT", "OPEN_BUY_PANEL", "rmbtomoney")
					return false
				end
			end
		end
	end
	return true
end

function UserData:buyItemCount(Idx, count)
	if not self.item[Idx] then
		self.item[Idx] = {}
	end
	if not self.item[Idx].count then
		self.item[Idx].count = enc_0
	end
	count = count or 1
	local itemInfo = Item:getItemInfo(Idx)

	if itemInfo.costtype == "gold" then
		if self:costGoldTest(itemInfo.cost * count) then
			if self:costGold(itemInfo.cost * count) then
				self:setItemCount(Idx, self:getItemCount(Idx) + count)
				eventhub.fire("UI_EVENT", "ITEM_NUM_CHANGE", Idx, self:getItemCount(Idx))
				local ActLog = require "ActLog"
				ActLog:buyItemUseGold(Idx, count)
				self:save()
				return true
			end
		else
			eventhub.fire("UI_EVENT", "OPEN_BUY_PANEL", "moneytogold")
		end
	else
		if self:costMoneyTest(itemInfo.cost * count) then
			if self:costMoney(itemInfo.cost * count) then
				self:setItemCount(Idx, self:getItemCount(Idx) + count)
				eventhub.fire("UI_EVENT", "ITEM_NUM_CHANGE", Idx, self:getItemCount(Idx))
				local ActLog = require "ActLog"
				ActLog:buyItemUseMoney(Idx, count)
				self:save()
				return true
			end
		else
			if count ~= 1 then
				eventhub.fire("UI_EVENT", "OPEN_BUY_PANEL", "rmbtomoney")
			else
				local successKey, failedKey, cancelKey = nil, nil, nil
				successKey = eventhub.bind("UI_EVENT", "PLAYER_PAY_SUCCESS", function()
					eventhub.unbind("UI_EVENT", "PLAYER_PAY_SUCCESS", successKey)
					eventhub.unbind("UI_EVENT", "PLAYER_PAY_FAILED", failedKey)
					eventhub.unbind("UI_EVENT", "PLAYER_PAY_CANCEL", cancelKey)
					if self:costMoney(itemInfo.cost * count) then
						self:setItemCount(Idx, self:getItemCount(Idx) + count)
						eventhub.fire("UI_EVENT", "ITEM_NUM_CHANGE", Idx, self:getItemCount(Idx))
						local ActLog = require "ActLog"
						ActLog:buyItemUseMoney(Idx, count)
						self:save()
					end
				end)
				failedKey = eventhub.bind("UI_EVENT", "PLAYER_PAY_FAILED", function()
					eventhub.unbind("UI_EVENT", "PLAYER_PAY_SUCCESS", successKey)
					eventhub.unbind("UI_EVENT", "PLAYER_PAY_FAILED", failedKey)
					eventhub.unbind("UI_EVENT", "PLAYER_PAY_CANCEL", cancelKey)
				end)
				cancelKey = eventhub.bind("UI_EVENT", "PLAYER_PAY_CANCEL", function()
					eventhub.unbind("UI_EVENT", "PLAYER_PAY_SUCCESS", successKey)
					eventhub.unbind("UI_EVENT", "PLAYER_PAY_FAILED", failedKey)
					eventhub.unbind("UI_EVENT", "PLAYER_PAY_CANCEL", cancelKey)
				end)
				local Buy = require "settings.Buy"
				Buy:RMBPay(18)
			end
		end
	end
	return false
end

function UserData:setMusic(on)
	self.music = on
	self:save()
	eventhub.fire("UI_EVENT", "SOUND_CHANGE")
end

function UserData:setSound(on)
	self.sound = on
	self:save()
	eventhub.fire("UI_EVENT", "SOUND_CHANGE")
end

function UserData:CostAPByGame()
	return UserData:costAP(AP.cost)
end

function UserData:setLeaveTime()
	self.leave = os.time()
	self:save()
end

function UserData:getPetInfo(ballId)
	if not self.petInfo[ballId] then
		print("[ERR]no pet info by index", ballId)
		return
	end

	if not self.petInfo[ballId].unlocked then
		ballId = "default"
	end

	return Pet:getPet(ballId)
end

function UserData:getPetLevel(ballId)
	if not self.petInfo[ballId] then
		print("[ERR]no pet info by index", ballId)
		return
	end
	
	if not self.petInfo[ballId].unlocked then
		return 0
	end

	return self.petInfo[ballId].level
end

function UserData:checkTaskTime(stamp)
	if not stamp then
		return false
	end

	if not self.taskstamp then
		self.taskstamp = 0
	end
	local updatetime = TaskConfig:getUpdateTime()
	
	stamp = stamp - updatetime
	local tbDateNow = os.date("*t", stamp)
	local tbDataLast = os.date("*t", self.taskstamp)
	
	local nowday = tbDateNow.year * 365 + tbDateNow.yday
	local lastday = tbDataLast.year * 365 + tbDataLast.yday
	
	self.taskstamp = stamp
	self:save()
	
	return nowday > lastday
end

function UserData:getSavaInfo()
	local info = {}
	info.guid 	= self._guid
	info.money 	= self.money
	info.gold 	= self.gold
	info.ap 	= self.ap
	info.level 	= self.level
	info.exp 	= self.exp
	info.stage 	= self.stage
	info.score 	= self.score
	info.item  	= self.item
	info.petInfo= self.petInfo

	return UserData.takeTable(info)
end

function UserData:setDataBySavaInfo(info)
	self.money 	= info.money
	self.gold 	= info.gold
	self.ap 	= info.ap
	self.level 	= info.level
	self.exp 	= info.exp
	self.stage 	= info.stage
	self.score 	= info.score
	self.item  	= info.item
	self.petInfo= info.petInfo
end

function UserData:isSimplePayChannel()
	return self.simplePayChannel
end

function UserData:setSimplePayChannelStatus(status)
	self.simplePayChannel = status
	self:save()
end

setmetatable(UserData, {
	__index = function(self, key)
		local v = UserDataM[key]
		local f = cryptoT[key]
		if v and f then
			return f.decode(v)
		end
		return v
	end,
	__newindex = function(self, key, value)
		local f = cryptoT[key]
		if f then
			value = f.encode(value)
		end
		UserDataM[key] = value
	end,
})

return UserData
