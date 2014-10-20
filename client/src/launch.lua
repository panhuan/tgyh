local launcher = function()
	require "GlobalConstants"
	local gettext = require("gettext.gettext")
	if os.getenv("I18N_TEST") then
		gettext.setlang("*")
	else
		gettext.setlang(PREFERRED_LANGUAGES, "mo/?.mo")
	end
	local device = require "device"
	local util = require "util"
	local ui = require "ui"
	local node = require "node"
	local layer = require "layer"
	local actionset = require "actionset"
	local resource = require "resource"
	local memory = require "memory"
	local timerutil = require "timerutil"
	local appcache = require "appcache"
	local qlog = require "qlog"
	local random = require "random"
	local camera = require "camera"
	local timer = require "timer"
	local eventhub = require "eventhub"
	local TextBox = require "gfx.TextBox"
	local SoundSystem = require "SoundSystem"
	local SoundManager = require "SoundManager"
	local deviceevent = require "deviceevent"
	local network = require "network"
	local gfxutil = require "gfxutil"
	local math2d = require "math2d"
	local sound = require "sound"

	MOAISim.openWindow(_("Happy Hero"), device.width, device.height)

	viewport = MOAIViewport.new()
	viewport:setScale(device.ui_width, device.ui_height)
	viewport:setSize(0, 0, device.width, device.height)

	normalCamera = camera.new()

	deviceevent:init()
	SoundSystem:init()
	SoundManager:init()
	
	ui.Button.onClickSfx = SoundManager.onButtonClickSfx

	gameLayer = layer.new(viewport)
	gameLayer:setSortMode(MOAILayer2D.SORT_PRIORITY_ASCENDING)
	gameLayer:setLayoutSize(device.ui_width, device.ui_height)
	gameLayer._uiname = "gameLayer"
	local _gameLayer = gameLayer
	gameLayer = gameLayer:add(node.new())
	gameLayer.wndToWorld = function(self, ...)
		return _gameLayer:wndToWorld(...)
	end
	
	uiLayer = layer.new(viewport)
	uiLayer:setSortMode(MOAILayer2D.SORT_PRIORITY_ASCENDING)
	uiLayer:setLayoutSize(device.ui_width, device.ui_height)
	uiLayer._uiname = "uiLayer"
	local _uiLayer = uiLayer
	
	function gfxutil.createTilingBG(texname)
		local tex = resource.texture(texname)
		local w, h = tex:getSize()
		local tileDeck = MOAITileDeck2D.new()
		tileDeck:setTexture(tex)
		tileDeck:setSize(1, 1)
		local grid = MOAIGrid.new()
		grid:setSize(1, 1, w, h)
		grid:setRow(1, 1)
		grid:setRepeat(true)
		local prop = MOAIProp2D.new()
		prop:setDeck(tileDeck)
		prop:setGrid(grid)
		prop._size = {w, h}
		return prop
	end
	
	local bg = gfxutil.createTilingBG("starfield.jpg")
	uiLayer = uiLayer:add(node.new(bg))
	uiLayer.wndToWorld = function(self, ...)
		return _uiLayer:wndToWorld(...)
	end

	ui.init()
	ui.insertLayer(_uiLayer)
	
	local Image = require "gfx.Image"
	
	local SPACE_W, SPACE_H = 96, 96
	local SPACE_X_CELLS, SPACE_Y_CELLS = 7, 2
	local SPACE_X, SPACE_Y = 0, -(device.ui_height - SPACE_H) / 2
	
	local SpaceCells = {
		_list = {},
	}
	local GamePlay = {}
	SpaceShip = {}
	
	local function index(x, y)
		return (y - 1) * SPACE_X_CELLS + x
	end
	
	local function coord(x, y)
		return SPACE_X + (x - 3) * SPACE_W, SPACE_Y + (1 - y) * SPACE_H
	end
	
	function SpaceCells:add(x, y, o)
		local i = index(x, y)
		self[i] = o
		o:setLoc(coord(x, y))
		ui.wrap(o)
		o.handleTouch = ui.handleTouch
		o.onClick = SpaceShip.onClickInSpace
		o._index = {x, y}
		table.insert(SpaceCells._list, o)
		return uiLayer:add(o)
	end
	
	function SpaceCells:at(x, y)
		local i = index(x, y)
		return self[i]
	end
	
	function SpaceShip.new(base, weapon, bullet)
		local self = Image.new(base)
		if weapon then
			self._weapon = self:add(Image.new(weapon))
		end
		self._bullet = bullet
		return self
	end
	
	function SpaceShip.newItem(base, weapon, bullet)
		local self = Image.new("6_5.png")
		self:add(SpaceShip.new(base, weapon))
		self.onClick = SpaceShip.onClickInShipList
		self._ship = {base, weapon, bullet}
		return self
	end
	
	function SpaceShip.shoot(self, angle)
		self:setRot(angle)
	end
	
	local shipList = ui.DropList.new(SPACE_W * 4, SPACE_H * 2, SPACE_W, "horizontal")
	local cellRoot = uiLayer:add(node.new())
	local cellSelected = Image.new("5_5.png")
	local thread = MOAIThread.new()
	thread:run(function()
		while true do
			MOAIThread.blockOnAction(cellSelected:seekScl(0.8, 0.8, 1, MOAIEaseType.LINEAR))
			MOAIThread.blockOnAction(cellSelected:seekScl(1, 1, 1, MOAIEaseType.LINEAR))
		end
	end)
	
	function SpaceShip.onClickInShipList(self)
		local o = SpaceShip.new(unpack(self._ship))
		SpaceCells:add(cellSelected._index[1], cellSelected._index[2], o)
		uiLayer:remove(shipList)
		uiLayer:remove(cellSelected)
	end
	
	shipList:addItem(SpaceShip.newItem("1_2.png", "1_5.png", "b_7.png"))
	shipList:addItem(SpaceShip.newItem("1_2.png", "1_6.png", "b_6.png"))
	shipList:addItem(SpaceShip.newItem("1_2.png", "2_5.png?loc=0,25", "enemyBullet.png"))
	shipList:addItem(SpaceShip.newItem("1_2.png", "2_6.png?loc=0,25", "enemyBullet2.png"))
	
	function SpaceShip.onClickInSpace(self)
		local t = {
			{ 1, 0},
			{-1, 0},
			{0,  1},
			{0, -1},
		}
		cellRoot:removeAll()
		
		local x, y = unpack(self._index)
		for i, v in ipairs(t) do
			local ix, iy = x + v[1], y + v[2]
			if not SpaceCells:at(ix, iy) then
				local o = cellRoot:add(Image.new("6_5.png"))
				ui.wrap(o)
				o:setLoc(coord(ix, iy))
				o.handleTouch = ui.handleTouch
				o.onClick = function()
					cellSelected._index = {ix, iy}
					cellSelected:setLoc(o:getLoc())
					uiLayer:add(cellSelected)
					uiLayer:add(shipList)
					cellRoot:removeAll()
				end
			end
		end
	end
	
	local motherShip = SpaceShip.new("1_1.png")
	SpaceCells:add(3, 1, motherShip)
	
	function GamePlay:onTouchMove(eventType, touchIdx, x, y, tapCount)
		if self._isTouchDown then
			local wx, wy = uiLayer:wndToWorld(x, y)
			local cx, cy = motherShip:getLoc()
			self._isTouchDown = math2d.theta(wx - cx, wy - cy)
		end
	end

	function GamePlay:onTouchDown(eventType, touchIdx, x, y, tapCount)
		if not self._isTouchDown then
			local wx, wy = uiLayer:wndToWorld(x, y)
			local cx, cy = motherShip:getLoc()
			self._isTouchDown = math2d.theta(wx - cx, wy - cy)
		end
	end

	function GamePlay:onTouchUp(eventType, touchIdx, x, y, tapCount)
		if self._isTouchDown then
			self._isTouchDown = nil
		end
	end
	
	ui.setDefaultTouchHandler(GamePlay)
	
	local function shoot(theta, interval)
		local x, y = math2d.cartesian(theta, 2000)
		for i, v in ipairs(SpaceCells._list) do
			if v._bullet then
				local tick = v._shootTick or 0
				if tick < MOAISim.getElapsedTime() then
					sound.new("bullet1.ogg", false):play()
					v._shootTick = MOAISim.getElapsedTime() + interval
					local angle = math.deg(theta) - 90
					v:setRot(angle)
					local o = uiLayer:add(Image.new(v._bullet))
					o:setRot(angle)
					o:setLoc(v:getLoc())
					o:moveLoc(x, y, 1, MOAIEaseType.LINEAR)
				end
			end
		end
	end
	
	sound.new("bgm_boss.ogg", true):play()
	local thread = MOAIThread.new()
	thread:run(function()
		while true do
			if GamePlay._isTouchDown then
				shoot(GamePlay._isTouchDown, 0.05)
			end
			coroutine.yield()
		end
	end)
	
	local LagrangeCurve = {}
	function LagrangeCurve.new(aset, master, x, y, timeCurve)
		local f = interpolate.lagrange2d(x, y, timeCurve)
		local self
		self = aset:run(function(dt, length)
			if length > timeCurve:getLength() then
				self:stop()
				return
			end
		end)
	end

	timer.new(0.1, function()
		if dotest then
			dotest()
		end
	end)
end

local ok, err = pcall(launcher)
if not ok then
	print(err)
end