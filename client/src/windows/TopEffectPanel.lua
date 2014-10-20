

local ui = require "ui"
local node = require "node"
local device = require "device"
local Image = require "gfx.Image"
local Sprite = require "gfx.Sprite"
local Particle = require "gfx.Particle"
local eventhub = require "eventhub"
local interpolate = require "interpolate"
local TextBox = require "gfx.TextBox"
local SoundManager = require "SoundManager"


local levelUpPic = "ui.atlas.png#level_up.png"
local paperPic = "effect.atlas.png?loop=true"
local sonwPex = "explosion_snow.pex"

local tbPaparPic = 
{
	"zhipianred",
	"zhipianyellow",
	"zhipianblue",
}

local tbParam = 
{
	paper = 
	{
		movePoint = 3,
		count = 25,
		sclMin = 5,
		sclMax = 20,
		alphaMin = 10,
		alphaMax = 10,
		speed = 3,
	},
	snow = 
	{
		movePoint = 6,
		count = 1,
		sclMin = 5,
		sclMax = 20,
		alphaMin = 10,
		alphaMax = 10,
		speed = 6,
	},
}


local TopEffectPanel = {}


function TopEffectPanel:init()
	eventhub.bind("UI_EVENT", "OPEN_EFFECT_PANEL", function()
		self:open()
	end)
	eventhub.bind("UI_EVENT", "CLOSE_EFFECT_PANEL", function()
		self:close()
	end)
	eventhub.bind("UI_EVENT", "STAR_EFFECT_PAPER", function()
		self:starPaperEffect()
	end)
	eventhub.bind("UI_EVENT", "STOP_EFFECT_PAPER", function()
		self:stopPaperEffect()
	end)
	eventhub.bind("UI_EVENT", "STAR_EFFECT_SNOW", function()
		self:starSnowEffect()
	end)
	eventhub.bind("UI_EVENT", "STOP_EFFECT_SNOW", function()
		self:stopSnowEffect()
	end)
	eventhub.bind("UI_EVENT", "PLAYER_LEVEL_UP", function()
		mainAS:delaycall(1, function()
			self:startLvupEffect()
		end)
	end)
	
	self._root = node.new()
	self._root:setPriority(1)
	self._root:setLayoutSize(device.ui_width, device.ui_height)
	
	self._snowNode = Particle.new(sonwPex, mainAS)
	
	self:initPaper()
	self:initLvupEffect()
end

function TopEffectPanel:initPaper()
	self._paperNode = node.new()
	
	self._tbPaperFn = {}
	self._tbPaper = {}
	for i = 1, tbParam.paper.count do
		self._tbPaperFn[i] = self:createSuperCurve("paper")
		local scl = math.random(tbParam.paper.sclMin, tbParam.paper.sclMax) / 10
		local scrA = math.random(tbParam.paper.alphaMin, tbParam.paper.alphaMax) / 10
		local paper = self._paperNode:add(Sprite.new(paperPic))
		paper:setScl(scl)
		paper:setColor(scrA, scrA, scrA, scrA)
		self._tbPaper[i] = {paper, false}
	end
end

function TopEffectPanel:starPaperEffect()
	self._root:add(self._paperNode)

	for key, paper in ipairs(self._tbPaper) do
		paper[2] = true
		self:paperSuperMove(paper, self._tbPaperFn[key])
	end
end

function TopEffectPanel:stopPaperEffect()
	self._paperNode:remove()
	for key, var in ipairs(self._tbPaper) do
		var[1]:stopAnim()
		var[2] = false
	end
end

function TopEffectPanel:paperSuperMove(paper, fn)
	local idx = math.random(1, 3)
	paper[1]:playAnim(tbPaparPic[idx], true)
	local action = nil
	action = mainAS:run(function(dt, length)
		if length >= fn[2]:getLength() then
			action:stop()
			action = nil
			if paper[2] then
				self:paperSuperMove(paper, fn)
			end
		else
			local x, y = fn[1](length)
			paper[1]:setLoc(x, y)
		end
	end)
end

function TopEffectPanel:starSnowEffect()
	self._root:add(self._snowNode)
	self._snowNode:begin()
end

function TopEffectPanel:stopSnowEffect()
	self._snowNode:cancel()
	self._snowNode:remove()
end

function TopEffectPanel:initLvupEffect()
	self._lvupImg = Image.new(levelUpPic)
end

function TopEffectPanel:startLvupEffect()
	self._root:add(self._lvupImg)
	self._lvupImg:setLoc(0, 0)
	self._lvupImg:seekLoc(0, 300, 2, MOAIEaseType.LINEAR)
	self._lvupImg:setColor(1, 1, 1, 1)
	SoundManager.petLevelUpSound:play()
	local c = self._lvupImg:seekColor(1, 1, 1, 0.7, 3, MOAIEaseType.LINEAR)
	c:setListener(MOAIAction.EVENT_STOP, function()
		self._lvupImg:remove()
	end)
end

function TopEffectPanel:createSuperCurve(key)
	local tbPosX = {}
	local tbPosY = {}
	local srcX = math.random(-device.ui_width / 2, device.ui_width / 2)
	local srcY = math.random(device.ui_height / 2, device.ui_height * 2)
	local destX = math.random(-device.ui_width / 2, device.ui_width / 2)
	local destY = (-device.ui_height / 2 - 100)
	local length = (srcY - destY) / device.ui_height * tbParam[key].speed
	local times = math.random(1, tbParam[key].movePoint)
	table.insert(tbPosX, srcX)
	table.insert(tbPosY, srcY)
	for i = 1, times do
		table.insert(tbPosX, math.random(-device.ui_width / 2, device.ui_width / 2))
		table.insert(tbPosY, math.random(-device.ui_height / 2, device.ui_height / 2))
	end
	table.insert(tbPosX, destX)
	table.insert(tbPosY, destY)
	table.sort(tbPosY, function(a, b)
		return a > b
	end)
	local c = interpolate.makeCurve(0, 0, MOAIEaseType.LINEAR, length, length)
	local fn = interpolate.newton2d(tbPosX, tbPosY, c)
	return {fn, c}
end

function TopEffectPanel:open()
	topEffectLayer:add(self._root)
end

function TopEffectPanel:close()
	topEffectLayer:remove(self._root)
end

return TopEffectPanel