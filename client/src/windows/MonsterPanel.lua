
local ui = require "ui"
local node = require "node"
local Image = require "gfx.Image"
local device = require "device"
local eventhub = require "eventhub"
local FlashSprite = require "gfx.FlashSprite"
local AvatarConfig = require "settings.AvatarConfig"

local bgW, bgH = 800, 500

local MonsterPanel = {}

local dragEndAS = nil
local offset = -60

local tbTouch = {}

function MonsterPanel:init()
	eventhub.bind("UI_EVENT", "OPEN_MONSTER_PANEL", function(data)
		self:open(data)
	end)
	eventhub.bind("UI_EVENT", "CLOSE_MONSTER_PANEL", function()
		self:close()
	end)

	self._root = ui.wrap(Image.new())
	self._root.handleTouch = ui.handleTouch
	self._root.onDragBegin = self.onDragBegin
	self._root.onDragMove = self.onDragMove
	self._root.onDragEnd = self.onDragEnd
	self._pick = ui.wrap(node.new())
	self._pick:setPriorityOffset(10)
	self._pick.handleTouch = ui.handleTouch
	self._pick.onDragBegin = self.onDragBegin
	self._pick.onDragMove = self.onDragMove
	self._pick.onDragEnd = self.onDragEnd
	self._scissor = MOAIScissorRect.new()
	
	self._tbMonster = {}
end

function MonsterPanel:getMonsterFlashSprite(id)
	if self._tbMonster[id] then
		for key, var in ipairs(self._tbMonster[id]) do
			if var.used == false then
				var.used = true
				self._pick:add(var.monster)
				var.monster:playFlash(true)
				return var
			end
		end
	end
	
	local avatar = AvatarConfig:getAvatar(id)
	local monster = self._pick:add(FlashSprite.new(avatar.idlImage.."?loop=true", true))	
	local tb = {monster = monster, w = avatar.w, h = avatar.h, used = true}
	if not self._tbMonster[id] then
		self._tbMonster[id] = {}
	end
	table.insert(self._tbMonster[id], tb)
	return tb
end

function MonsterPanel:open(data)
	data.root:add(self._root)
	data.root:add(self._pick)
	self._root:load(data.image)
	self._root:setLoc(data.x, data.y)
	self._pick:setLoc(0, data.y - 100)
	local xScl, yScl = data.w / bgW, data.h / bgH
	self._root:setScl(xScl, yScl)
	self._scissor:setParent(data.root)
	self._scissor:setLoc(data.x, data.y)
	self._scissor:setRect(-data.w / 2, -data.h / 2, data.w / 2, data.h / 2)
	self._pick:setScissorRect(self._scissor)
	
	tbTouch.xMin = 0
	tbTouch.xMax = 0
	if #(data.monster) == 1 then
		local monsterData = self:getMonsterFlashSprite(data.monster[1])
		monsterData.monster:setLoc(offset, monsterData.h)
	elseif #(data.monster) == 2 then
		local x1 = -data.w / 2 + data.w / 3 + offset
		local x2 = -data.w / 2 + data.w / 3 * 2 + offset
		local monsterData1 = self:getMonsterFlashSprite(data.monster[1])
		local monsterData2 = self:getMonsterFlashSprite(data.monster[2])
		monsterData1.monster:setLoc(x1, monsterData1.h)
		monsterData2.monster:setLoc(x2, monsterData2.h)
	else
		local x = -data.w / 2 + 15
		tbTouch.xMax = -x
		for key, var in ipairs(data.monster) do
			local monsterData = self:getMonsterFlashSprite(var)
			monsterData.monster:setLoc(x, monsterData.h)
			x = x + monsterData.w
		end
		tbTouch.xMin = -x
	end
end

function MonsterPanel:close()
	self._root:remove()
	self._pick:remove()
	for key, var in pairs(self._tbMonster) do
		for i, tb in ipairs(var) do
			tb.monster:stopFlash()
			tb.monster:remove()
			tb.used = false
		end
	end
end

function MonsterPanel:onDragBegin(touchIdx, x, y, tapCount)
	tbTouch.lastX = x
	tbTouch.diffX = 0
	if dragEndAS then
		dragEndAS:stop()
		dragEndAS = nil
	end
	return true
end

function MonsterPanel:onDragMove(touchIdx, x, y, tapCount)
	tbTouch.diffX = (x - tbTouch.lastX) * 1.5
	tbTouch.lastX = x
	local nodeX, nodeY = MonsterPanel._pick:getLoc()
	nodeX = math.clamp(nodeX + tbTouch.diffX, tbTouch.xMin, tbTouch.xMax)
	MonsterPanel._pick:setLoc(nodeX, nodeY)
end

function MonsterPanel:onDragEnd(touchIdx, x, y, tapCount)
	local velocityX = tbTouch.diffX
	dragEndAS = mainAS:run(function(dt)
		local x, y = MonsterPanel._pick:getLoc()
		if x + velocityX >= tbTouch.xMin and x + velocityX <= tbTouch.xMax then
			x = x + velocityX
			velocityX = velocityX - velocityX * dt * 0.03 * device.dpi
		else
			velocityX = 0
		end
		MonsterPanel._pick:setLoc(x, y)
		
		if math.abs(velocityX) < 1 then
			dragEndAS:stop()
			dragEndAS = nil
		end
	end)
end

return MonsterPanel

