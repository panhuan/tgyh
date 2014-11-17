local ui = require "ui"
local node = require "node"
local device = require "device"
local Image = require "gfx.Image"
local actionset = require "actionset"
local Formula = require "settings.Formula"
local ObjectFactory = require "ObjectFactory"
local WindowManager = require "WindowManager"


local GamePlay = {}

function GamePlay:init()
	self._root = node.new()
	self._root:setLayoutSize(device.ui_width, device.ui_height)
	self._bgNode = self._root:add(node.new())
	self._gameNode = self._root:add(node.new())
	self._gameNode:setPriorityOffset(2)
	WindowManager:initWindow("GamePlay", self)
end

function GamePlay:initData()
	-- logic
	self._enemys = {}
	self._waveIndex = 1

	-- as
	self._AS = actionset.new()
	
	-- hero
	self._hero = ObjectFactory:createObject({name = "hero", root = self._gameNode})
	
	-- other
	self._bg = self._bgNode:add(Image.new(Formula:calcGameBG(self._waveIndex)))
	
	-- update
	self._AS:run(function(dt)
		self:update(dt)
	end)
	
	ui.setDefaultTouchHandler(self)
end

function GamePlay:cleanData()
	self._AS:removeAll()
	ObjectFactory:destroyObject(self._hero)
	ui.setDefaultTouchHandler(nil)
end

function GamePlay:start()
	self:initData()
	WindowManager:open("GamePlay", "game")
end

function GamePlay:stop()
	self:cleanData()
end

function GamePlay:onClick(touchIdx, x, y, tapCount)

end

function GamePlay:shoot(theta, interval)
	local x, y = math2d.cartesian(theta, 2000)
	
end

function GamePlay:onTouchDown(eventType, touchIdx, x, y, tapCount)
	if not self._isTouchDown then
		local wx, wy = gameLayer:wndToWorld(x, y)
		local cx, cy = self._hero._root:getLoc()
		self._isTouchDown = math2d.theta(wx - cx, wy - cy)
	end
end

function GamePlay:onTouchUp(eventType, touchIdx, x, y, tapCount)
	if self._isTouchDown then
		self._isTouchDown = nil
	end
end

function GamePlay:onTouchMove(eventType, touchIdx, x, y, tapCount)
	if not self._isTouchDown then
		local wx, wy = gameLayer:wndToWorld(x, y)
		local cx, cy = self._hero._root:getLoc()
		self._isTouchDown = math2d.theta(wx - cx, wy - cy)
	end
end

function GamePlay:update(dt)
	-- check destroy
	self:checkEnemysDestroy()
	
	-- check create
	local enemys = self:checkEnemysCreate()
	if enemys then
		self:createEnemys(enemys)
	end
end

function GamePlay:checkEnemysDestroy()
	for key, enemy in pairs(self._enemys) do
		if self:checkEnemySmash(enemy) then
			ObjectFactory:destroyObject({object = enemy})
			table.remove(self._enemys, key)
		end
		if self:checkEnemyLeave(enemy) then
			ObjectFactory:destroyObject({object = enemy})
			table.remove(self._enemys, key)
		end
	end
end

function GamePlay:checkEnemySmash(enemy)
	return false
end

function GamePlay:checkEnemyLeave(enemy)
	local x, y = enemy._root:getLoc()
	if x > device.ui_width / 2 or x < -device.ui_width / 2 or y < -device.ui_height / 2 then
		return true
	end
	return false
end

function GamePlay:checkEnemysCreate()
	local enemyCount = table.size(self._enemys)
	if enemyCount <= 1 then
		local enemys = Formula:calcEnemys(self._waveIndex)
		return enemys
	end
end

function GamePlay:createEnemys(enemys)
	for _, enemyInfo in ipairs(enemys) do
		local enemy = ObjectFactory:createObject({name = enemyInfo.name})
		self._gameNode:add(enemy._root)
		enemy:setBornPos(enemyInfo.pos)
		enemy:beginAttack(self._hero, self._AS)
		table.insert(self._enemys, enemy)
	end
end


return GamePlay