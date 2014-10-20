local BallLevel = require "settings.BallLevel"
local UserData = require "UserData"
local GameConfig = require "settings.GameConfig"
local Pet = require "settings.Pet"
local Mission = require "settings.Mission"
local Robot = require "settings.Robot"
local Timing = require "settings.Timing"

local Formula = {}

--计算连接伤害
--isAddDamage 是否使用了(此局游戏内超人伤害增强)的道具
function Formula:calcDamageByLinkNum(ballId, ballLevel, ballCount, isAddDamage)
	local petLevel = UserData:getPetLevel(ballId)
	local petattack = 0
	if petLevel > 0 then
		petattack = Pet.PetAttack[ballId][petLevel]
		--print("petattack:"..petattack)
	end
	local ballLevelDamage = BallLevel:getBallLevelDamage(ballLevel)
	local AttackAdditionByLinkNum = 0
	local curAttackDamage = 0
	local sum = 0
	for i = 1, ballCount do
		if 1 then
			AttackAdditionByLinkNum = GameConfig:getAttackAdditionByLinkNum(i)
			curAttackDamage = math.floor((ballLevelDamage+petattack)*(1+AttackAdditionByLinkNum))--1 * petLevel
		end
		sum = sum + curAttackDamage --+ ballLevelDamage
	end
	--sum = sum + petattack
	--print("ballCount: "..ballCount.." damage: "..sum.." ballevel: "..ballLevel)
	if isAddDamage then
		sum = math.floor(sum * 1.3)
	end
	return sum
end

--计算炸弹伤害
function Formula:calcDamageByBombNum(ballId, ballLevel, ballCount)
	local petLevel = UserData:getPetLevel(ballId)
	local ballLevelDamage = BallLevel:getBallLevelDamage(ballLevel)
	return ballLevelDamage*ballCount--(1 * petLevel + ballLevelDamage) * ballCount
end

--计算每步增加的能量值(1为满)
--isSupermodeStep 是否使用了(更容易开启超级模式)的道具
function Formula:calcEnergyPerStep(isSupermodeStep)
	if isSupermodeStep then
		return 0.15
	end
	return 0.1
end

--计算分数通过连接数
function Formula:calcScoreByLinkNum(ballCount)
	local addscore = 10
	local allscore = 0
	for i = 1 , ballCount do
		allscore = allscore + i * addscore
	end
	--print("allscore========"..allscore)
	return allscore
end

--计算分数通过爆炸数
function Formula:calcScoreByBombNum(ballCount)
	return ballCount*30
end

--计算奖励经验
function Formula:calcRewardExp(score, monsterNum, gameIdx, gameMode)
	local sum = 0

	if gameMode == "stage" then
		for i = 1, monsterNum - 1 do
			sum = sum + GameConfig:getRewardExp(i)
		end
	elseif gameMode == "mission" then
		for i = 1, monsterNum do
			sum = sum + Mission:getRewardExp(gameIdx, i)
		end
	elseif gameMode == "timing" then
		for i = 1, monsterNum - 1 do
			sum = sum + Timing:getRewardExp(gameIdx, i)
		end
	end

	return sum
end

--计算奖励金币
function Formula:calcRewardGold(score, monsterNum, gameIdx, gameMode)
	local sum = 0

	if gameMode == "stage" then
		for i = 1, monsterNum - 1 do
			sum = sum + GameConfig:getRewardGold(i)
		end
	elseif gameMode == "mission" then
		for i = 1, monsterNum do
			sum = sum + Mission:getRewardGold(gameIdx, i)
		end
	elseif gameMode == "timing" then
		for i = 1, monsterNum - 1 do
			sum = sum + Timing:getRewardGold(gameIdx, i)
		end
	end

	return sum
end

function Formula:calcRewardStep(baseCount, ballCount)
	local rewardStep = math.floor(ballCount/baseCount)
	if rewardStep < 0 then
		rewardStep = 0
	end

	return rewardStep
end

function Formula:calcRewardTime(baseCount, ballCount)
	local rewardTime = math.floor(ballCount / baseCount)
	if rewardTime < 0 then
		rewardTime = 0
	end
	
	return rewardTime * 3
end

function Formula:calcRewardStar(score, step, gameIdx)
	if not Mission.monsterList[gameIdx] then
		return 1
	end
	local totleStep = Mission.monsterList[gameIdx].step
	for key, var in ipairs(Mission.monsterList[gameIdx]) do
		if type(var) == "table" then
			totleStep = totleStep + var.rewardStep
		end
	end

	local starcal = step/totleStep
	if starcal < 0.75 then
		return 3
	elseif starcal < 0.9 then
		return 2
	end
	return 1
end

-- 计算超人大招的伤害
function Formula:calcRobotDamage(ballId)
	local RobotAttack = Robot:getRobotAttack(ballId)
	local petLevel = UserData:getPetLevel(ballId)
	if petLevel == 0 then
		petLevel = 1
	end
	return Pet.PetAttack[ballId][petLevel] * RobotAttack
end

return Formula
