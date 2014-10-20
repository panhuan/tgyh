require("moai.compat")
require("base_ext")

local resource = require("resource")
local util = require("util")
local device = require("device")
local memory = require("memory")
local color = require("color")
local url = require("url")
local actionset = require("actionset")
local interpolate = require("interpolate")
local node = require("node")
local gfxutil = require("gfxutil")

local clock = os.clock

local ui = {
	TOUCH_DOWN = MOAITouchSensor.TOUCH_DOWN,
	TOUCH_MOVE = MOAITouchSensor.TOUCH_MOVE,
	TOUCH_UP = MOAITouchSensor.TOUCH_UP,
	TOUCH_CANCEL = MOAITouchSensor.TOUCH_CANCEL,
	TOUCH_ONE = 0,
	DRAG_THRESHOLD = 5,
	KEY_BACKSPACE = 8,
	KEY_RETURN = 13,
	AS = actionset.new(),
}

local layers = {}
local captures = {}
local locks = {}
local captureElement
local lockedElement
local focusElement
local touchFilterCallback
local defaultTouchCallback
local defaultKeyCallback
local disableTouch
local buttonDown

local function ui_new(o)
	local self = node.new(o)
	self._touch = {}
	return self
end

local function ui_log(...)
	if _DEBUG_UI then
		print("[UI]", string.format(...))
	end
end

local function ui_tostring(o)
	if type(o) == "userdata" or type(o) == "table" then
		return string.format("%s %s at %s", tostring(o._uitype), tostring(o), tostring(o._uiname))
	elseif type(o) == "function" then
		return debug.getfuncinfo(o)
	end
	return tostring(o)
end

local TOUCH_NAME_MAPPING = {
	[ui.TOUCH_DOWN] = "TOUCH_DOWN",
	[ui.TOUCH_MOVE] = "TOUCH_MOVE",
	[ui.TOUCH_UP] = "TOUCH_UP",
	[ui.TOUCH_CANCEL] = "TOUCH_CANCEL"
}
local TOUCH_EVENT_MAPPING = {
	[ui.TOUCH_DOWN] = "onTouchDown",
	[ui.TOUCH_MOVE] = "onTouchMove",
	[ui.TOUCH_UP] = "onTouchUp"
}

local function dispatchTouch(fn, elem, eventType, touchIdx, x, y, tapCount)
	local fntype = type(fn)
	if fntype == "boolean" or fntype == "nil" then
		return fn
	elseif fntype == "table" then
		fn = fn[TOUCH_EVENT_MAPPING[eventType]]
		if fn ~= nil then
			return fn(elem, touchIdx, x, y, tapCount)
		end
		return nil
	elseif fntype == "function" then
		return fn(elem, eventType, touchIdx, x, y, tapCount)
	else
		error("invalid touch handler: " .. tostring(fn))
	end
end

local touchLastX, touchLastY
local function touchHandler(eventType, touchIdx, x, y, tapCount)
	ui_log("-------------------------------------------")
	ui_log("touch event %s, idx %d, pos %d %d, tap %d", TOUCH_NAME_MAPPING[eventType], touchIdx, x, y, tapCount)
	local handled = false
	if touchFilterCallback ~= nil then
		local result = touchFilterCallback(eventType, touchIdx, x, y, tapCount)
		if result then
			return
		end
	end
	if eventType == ui.TOUCH_CANCEL then
	else
		if eventType == ui.TOUCH_MOVE then
			if touchLastX == x and touchLastY == y then
				return handled
			end
			touchLastX = x
			touchLastY = y
		elseif eventType == ui.TOUCH_UP then
			touchLastX = nil
			touchLastY = nil
		end
		local elem = captureElement
		ui_log("capture element %s", ui_tostring(elem))
		if elem ~= nil then
			if type(elem) == "function" then
				handled = elem(eventType, touchIdx, x, y, tapCount)
				ui_log("\t handle capture function:%s", tostring(handled))
			elseif elem._layer ~= nil then
				while elem ~= nil do
					local fn = elem.handleTouch
					if fn ~= nil then
						local wx, wy = elem._layer:wndToWorld(x, y)
						local result = dispatchTouch(fn, elem, eventType, touchIdx, wx, wy, tapCount)
						if result then
							handled = true
							break
						end
					end
					elem = elem._parent
				end
				ui_log("\t handle capture element:%s", tostring(handled))
			else
				elem._touch = {}
				ui.release(elem)
				return
			end
		else
			for i, layer in rpairs(layers) do
				ui_log("pick layer %q", tostring(layer._uiname))
				if (not lockedElement or lockedElement._layer == layer) and not layer.disableTouch then
					local wx, wy = layer:wndToWorld(x, y)
					local partition = layer:getPartition()
					if partition then
						local elemList = {partition:propListForPoint(wx, wy)}
						if elemList ~= nil then
							while not handled and #elemList > 0 do
								local lastPriority, fn, fnElemIdx, fnElem
								for i = #elemList, 1, -1 do
									local elem = elemList[i]
									local priority = elem:getPriority()
									ui_log("\t test ui elem : %s", ui_tostring(elem))
									if (lastPriority == nil or lastPriority <= priority) and ui.hitTest(elem, wx, wy) then
										while elem ~= nil do
											local touch = elem.handleTouch
											if touch ~= nil then
												lastPriority = priority
												fn = touch
												fnElemIdx = i
												fnElem = elem
												ui_log("\t\t hitted ui elem : %s", ui_tostring(elem))
												break
											end
											elem = elem._parent
										end
									end
								end
								if fn == nil then
									break
								end
								if lockedElement and not ui.treeEqual(elemList[fnElemIdx], lockedElement) then
									return false
								end
								ui_log("pick ui elem : %s", ui_tostring(fnElem))
								local result = dispatchTouch(fn, fnElem, eventType, touchIdx, wx, wy, tapCount)
								if result then
									handled = true
								else
									table.remove(elemList, fnElemIdx)
								end
							end
						end
					end
					if handled or layer.popuped then
						return true
					end
				end
			end
		end
		if not handled and defaultTouchCallback ~= nil then
			if type(defaultTouchCallback) == "table" then
				fn = defaultTouchCallback[TOUCH_EVENT_MAPPING[eventType]]
				if fn then
					handled = fn(touchIdx, x, y, tapCount)
				end
			else
				handled = defaultTouchCallback(eventType, touchIdx, x, y, tapCount)
			end
		end
	end
	return handled
end

local function onTouchHandle(eventType, touchIdx, x, y, tapCount)
	if disableTouch then
		return
	end
	local success, result = pcall(touchHandler, eventType, touchIdx, x, y, tapCount)
	if success then
		return result
	end
	print("[UI] error in onTouchHandle", result)
end

local function dragHappen(x1, y1, x2, y2)
	return math.abs(x1 - x2) > ui.DRAG_THRESHOLD or math.abs(y1 - y2) > ui.DRAG_THRESHOLD
end

local function dragHappen1D(v1, v2)
	return math.abs(v1 - v2) > ui.DRAG_THRESHOLD
end

function ui.wrap(o)
	o._uitype = "wrap"
	o._uiname = debug.getlocinfo(2)
	o._touch = {}
	return o
end

function ui.lock(e)
	assert(e)
	printf("UI lock %s", ui_tostring(e))
	lockedElement = e
	table.insert(locks, e)
end

function ui.unlock(e)
	assert(lockedElement == e, string.format("%s ~= %s", ui_tostring(lockedElement), ui_tostring(e)))
	printf("UI unlock %s", ui_tostring(e))
	local i = #locks
	lockedElement = locks[i - 1]
	table.remove(locks, i)
end

function ui.capture(e)
	assert(e)
	printf("UI capture %d, %s", #captures + 1, ui_tostring(e))
	captureElement = e
	table.insert(captures, e)
end

function ui.release(e)
	assert(captureElement == e, string.format("%s ~= %s", ui_tostring(captureElement), ui_tostring(e)))
	local i = #captures
	printf("UI release %d, %s", i, ui_tostring(e))
	captureElement = captures[i - 1]
	table.remove(captures, i)
end

function ui.disableTouch(on)
	disableTouch = on
end

function ui.hitTest(elem, wx, wy)
	if elem.hitTest then
		return elem.hitTest(wx, wy)
	else
		if elem._parent then
			return ui.hitTest(elem._parent, wx, wy)
		else
			return true
		end
	end
end

function ui.handleTouch(self, eventType, touchIdx, x, y, tapCount)
	self._touch = self._touch or {}
	
	if self._touch.curTouchIdx and self._touch.curTouchIdx ~= touchIdx then
		ui_log("ui.handleTouch touch idx unmatch %d, %d", self._touch.curtouchIdx, touchIdx)
		return
	end
	
	--没按下,且当前也不是按下事件,直接过滤
	if not self._touch.isDown and eventType ~= ui.TOUCH_DOWN then
		return
	end
	
	if eventType == ui.TOUCH_DOWN then
		if not self._touch.isDown then
			if self.onTouchDown then
				self:onTouchDown()
			end
			if self.onClickSfx then
				self:onClickSfx()
			end
			self._touch.isDown = true
			self._touch.curTouchIdx = touchIdx
			self._touch.isInside = true
			self._touch.downX = x
			self._touch.downY = y
			ui.capture(self)
		end
	elseif eventType == ui.TOUCH_UP then
		if self._touch.isDown then
			ui.release(self)
			if self.onClick then
				self:onClick(touchIdx, x, y, tapCount)
			end
			self._touch.isDown = nil
			self._touch.curTouchIdx = nil
		end
		if self._touch.isDragging then
			if self.onDragEnd then
				self:onDragEnd(touchIdx, x, y, tapCount)
			end
			self._touch.isDragging = nil
		end
		if self.onTouchUp then
			self:onTouchUp()
		end
		self._touch.isInside = nil
	elseif eventType == ui.TOUCH_MOVE then
		if self._touch.isDown and not self._touch.isDragging and dragHappen(self._touch.downX, self._touch.downY, x, y) then
			if self.onDragBegin then
				self._touch.isDragging = self:onDragBegin(touchIdx, x, y, tapCount)
			end
		end
		if self._touch.isDragging then
			if self.onDragMove then
				self:onDragMove(touchIdx, x, y, tapCount)
			end
		end
		if self._touch.isInside then
			if not ui.treeCheck(x, y, self) then
				if self.onTouchLeave then
					self:onTouchLeave()
				end
				self._touch.isInside = nil
			end
		end
	end
	return true
end

function ui.setDefaultTouchHandler(defaultTouchHandler)
	if ui._defaultTouchHandler then
		ui._defaultTouchHandler._touch = nil
	end
	ui._defaultTouchHandler = defaultTouchHandler
end

function ui.handleDefaultTouch(eventType, touchIdx, x, y, tapCount)
	local self = ui._defaultTouchHandler
	if not self then
		return false
	end
	
	self._touch = self._touch or {}
	
	if self._touch.curTouchIdx and self._touch.curTouchIdx ~= touchIdx then
		ui_log("ui.handleDefaultTouch touch idx unmatch %d, %d", self._touch.curtouchIdx, touchIdx)
		return
	end
	
	--没按下,且当前也不是按下事件,直接过滤
	if not self._touch.isDown and eventType ~= ui.TOUCH_DOWN then
		return
	end
	
	if eventType == ui.TOUCH_DOWN then
		if not self._touch.isDown then
			self._touch.isDown = true
			self._touch.curTouchIdx = touchIdx
			self._touch.downX = x
			self._touch.downY = y
			
			if self.onTouchDown then
				self:onTouchDown(eventType, touchIdx, x, y, tapCount)
			end
		end
	elseif eventType == ui.TOUCH_UP then
		if self._touch.isDragging then
			if self.onDragEnd then
				self:onDragEnd(touchIdx, x, y, tapCount)
			end
		elseif self._touch.isDown then
			if self.onClick then
				self:onClick(touchIdx, x, y, tapCount)
			end
		end
		self._touch.isDragging = nil
		self._touch.isDown = nil
		self._touch.curTouchIdx = nil
		if self.onTouchUp then
			self:onTouchUp(eventType, touchIdx, x, y, tapCount)
		end
	elseif eventType == ui.TOUCH_MOVE then
		if self.onTouchMove then
			if self:onTouchMove(eventType, touchIdx, x, y, tapCount) then
				return true
			end
		end
		if self._touch.isDown and not self._touch.isDragging and dragHappen(self._touch.downX, self._touch.downY, x, y) then
			if self.onDragBegin then
				self._touch.isDragging = self:onDragBegin(touchIdx, x, y, tapCount)
			end
		end
		if self._touch.isDragging then
			if self.onDragMove then
				self:onDragMove(touchIdx, x, y, tapCount)
			end
		end
	end
	return true
end

local mouseX = 0
local mouseY = 0
local mouseIsDown = false
local mouseTapCount = 0
local mouseDownTime
local curMouseTouchIdx = nil	--鼠标模拟多点触摸
local function onMouseMove(x, y)
	mouseX = x
	mouseY = y
	if mouseIsDown then
		onTouchHandle(ui.TOUCH_MOVE, curMouseTouchIdx or ui.TOUCH_ONE, mouseX, mouseY, 1)
	end
end

local function onMouseKey(down, touchIdx)
	mouseIsDown = down
	if down then
		curMouseTouchIdx = touchIdx
		do
			local t = clock()
			local dt = t - (mouseDownTime or t)
			if mouseDownTime == nil or dt > 0.285 then
				mouseTapCount = 1
			else
				mouseTapCount = mouseTapCount + 1
			end
			mouseDownTime = t
			onTouchHandle(ui.TOUCH_DOWN, touchIdx, mouseX, mouseY, mouseTapCount)
		end
	else
		curMouseTouchIdx = nil
		onTouchHandle(ui.TOUCH_UP, touchIdx, mouseX, mouseY, mouseTapCount)
	end
end

local function keyboardHandler(key, down)
	local handled = false
	if focusElement ~= nil then
		local fn = focusElement.handleKey
		if fn ~= nil then
			handled = fn(key, down)
		end
	end
	if not handled and defaultKeyCallback ~= nil then
		handled = defaultKeyCallback(key, down)
	end
	return handled
end

local function onKeyboardHandle(key, down)
	local success, result = pcall(keyboardHandler, key, down)
	if success then
		return result
	end
	print("[UI] error in onKeyboardHandle", result)
end

function ui.init(defaultTouchHandler, defaultKeyHandler)
	defaultTouchCallback = defaultTouchHandler or ui.handleDefaultTouch
	defaultKeyCallback = defaultKeyHandler
	if MOAIInputMgr.device.pointer ~= nil then
		MOAIInputMgr.device.pointer:setCallback(onMouseMove)
	end
	if MOAIInputMgr.device.mouseLeft ~= nil then
		MOAIInputMgr.device.mouseLeft:setCallback(function(down)
			onMouseKey(down, ui.TOUCH_ONE)
		end)
	end
	if MOAIInputMgr.device.mouseRight ~= nil then
		MOAIInputMgr.device.mouseRight:setCallback(function(down)
			onMouseKey(down, ui.TOUCH_ONE + 1)
		end)
	end
	if MOAIInputMgr.device.touch ~= nil then
		MOAIInputMgr.device.touch:setCallback(onTouchHandle)
	end
	if MOAIInputMgr.device.keyboard ~= nil then
		MOAIInputMgr.device.keyboard:setCallback(onKeyboardHandle)
	end
	layers = {}
	captureElement = nil
end

function ui.shutdown()
	defaultTouchCallback = nil
	defaultKeyCallback = nil
	if MOAIInputMgr.device.pointer ~= nil then
		MOAIInputMgr.device.pointer:setCallback(nil)
	end
	if MOAIInputMgr.device.mouseLeft ~= nil then
		MOAIInputMgr.device.mouseLeft:setCallback(nil)
	end
	if MOAIInputMgr.device.touch ~= nil then
		MOAIInputMgr.device.touch:setCallback(nil)
	end
	if MOAIInputMgr.device.keyboard ~= nil then
		MOAIInputMgr.device.keyboard:setCallback(nil)
	end
	
	for i = 1, #layers do
		layers[i]:clear()
	end
	layers = {}
end

function ui.injectTouch(eventType, touchIdx, x, y, tapCount)
	return onTouchHandle(eventType, touchIdx, x, y, tapCount)
end

function ui.setTouchFilter(touchFilter)
	touchFilterCallback = touchFilter
end

function ui.setDefaultTouchCallback(defaultInputHandler)
	defaultTouchCallback = defaultInputHandler
end

function ui.setDefaultKeyCallback(defaultKeyHandler)
	defaultKeyCallback = defaultKeyHandler
end

function ui.hierarchystring(elem)
	local t = {}
	local e = elem
	while e do
		table.insert(t, ui_tostring(e))
		e = e._parent
	end
	return table.concat(t, "\n")
end

function ui.getCaptureElement()
	return captureElement
end

function ui.focus(e)
	focusElement = e
end

function ui.treeEqual(elem, dest)
	if elem == dest then
		return true
	end
	if not elem._parent then
		return false
	end
	return ui.treeEqual(elem._parent, dest)
end

function ui.treeCheck(x, y, elem)
	local layer = elem._layer
	if layer == nil then
		return false
	end
	local elemList = {layer:getPartition():propListForPoint(x, y)}
	if elemList then
		for i, e in ipairs(elemList) do
			local temp = e
			while temp ~= nil do
				if temp == elem then
					return true
				end
				temp = temp._parent
			end
		end
	end
	return false
end

function ui.removeLayer(o)
	local i = table.find(layers, o)
	if i then
		table.remove(layers, i)
	end
end

function ui.insertLayer(o, pos)
	ui.removeLayer(o)
	pos = pos or #layers + 1
	table.insert(layers, pos, o)
end

local Group = {}
function Group.new()
	local self = ui_new(MOAIProp2D.new())
	self._uitype = "Group"
	self._uiname = debug.getlocinfo(2)
	return self
end

local PageView = {}
function PageView.showPage(self, page)
	if self.currPage == page then
		return
	end
	if self._pagemap[self.currPage] then
		self:remove(self._pagemap[self.currPage])
	end
	if self.currPage then
		local onShowPage = self.onShowPage[self.currPage]
		if onShowPage then
			onShowPage(self, false)
		end
	end
	self.currPage = page
	if page ~= nil and self._pagemap then
		local elem = self._pagemap[page]
		if elem ~= nil then
			self:_add(elem)
		end
		local onShowPage = self.onShowPage[page]
		if onShowPage then
			onShowPage(self, true)
		end
	end
end

function PageView.setPage(self, page, child)
	assert(page ~= nil, "page must not be nil")
	if self.currPage == page then
		self:showPage(nil)
	end
	self._pagemap[page] = child
	if self.currPage == nil then
		self:showPage(page)
	end
end

function PageView.getPage(self, page)
	return self._pagemap[page]
end

function PageView.setPriority(self, value, noRecursion)
	self:_prePageViewSetPriority(value, noRecursion)
	for k, v in pairs(self._pagemap) do
		v:setPriority(value, noRecursion)
	end
end

function PageView.new(pages)
	assert(pages == nil or type(pages) == "table", "pages must be a table or nil")
	local self = ui_new(MOAIProp2D.new())
	self._pagemap = {}
	self.currPage = nil
	self.showPage = PageView.showPage
	self.setPage = PageView.setPage
	self.getPage = PageView.getPage
	self._prePageViewSetPriority = self.setPriority
	self.setPriority = PageView.setPriority
	self._add = self.add
	self._uitype = "PageView"
	self._uiname = debug.getlocinfo(2)
	
	if pages ~= nil then
		for k, v in pairs(pages) do
			self:setPage(k, v)
		end
	end
	self.onShowPage = {}
	return self
end

local Button = {}
function Button.handleTouch(self, eventType, touchIdx, x, y, tapCount)
	if self._isDisable then
		return true
	end
	
	self._touch = self._touch or {}
	
	if self._touch.curTouchIdx and self._touch.curTouchIdx ~= touchIdx then
		ui_log("ui.handleTouch touch idx unmatch %d, %d", self._touch.curtouchIdx, touchIdx)
		return true
	end
	
	--没按下,且当前也不是按下事件,直接过滤
	if not self._touch.isDown and eventType ~= ui.TOUCH_DOWN then
		return true
	end
	
	if eventType == ui.TOUCH_DOWN and buttonDown then
		return true
	end
	
	if eventType == ui.TOUCH_DOWN then
		if not self._touch.isDown then
			if self.onTouchDown then
				self:onTouchDown()
			end
			if self.onClickSfx then
				self:onClickSfx()
			end
			self._touch.isDown = true
			self._touch.curTouchIdx = touchIdx
			self._touch.isInside = true
			self._touch.downX = x
			self._touch.downY = y
			ui.capture(self)
			buttonDown = true
		end
	elseif eventType == ui.TOUCH_UP then
		if self._touch.isDragging then
			if self.onDragEnd then
				self:onDragEnd(touchIdx, x, y, tapCount)
			end
			self._touch.isDragging = nil
		end
		
		local down = self._touch.isDown
		if self._touch.isDown then
			ui.release(self)
			self._touch.isDown = nil
			self._touch.curTouchIdx = nil
		end
		
		self:onTouchUp(function()
			if down then
				if self.onClick then
					self:onClick()
				end
			end
			buttonDown = false
		end)
		self._touch.isInside = nil
	elseif eventType == ui.TOUCH_MOVE then
		if self._touch.isDown and not self._touch.isDragging and dragHappen(self._touch.downX, self._touch.downY, x, y) then
			if self.onDragBegin then
				self._touch.isDragging = self:onDragBegin(touchIdx, x, y, tapCount)
			end
		end
		if self._touch.isDragging then
			if self.onDragMove then
				self:onDragMove(touchIdx, x, y, tapCount)
			end
		end
		if self._touch.isInside then
			if not ui.treeCheck(x, y, self) then
				if self.onTouchLeave then
					self:onTouchLeave()
				end
				self._touch.isInside = nil
			end
		end
	end
	return true
end

function _MakePage(o)
	if type(o) == "string" then
		return gfxutil.loadAssets(o)
	else
		return o
	end
end

function Button.showPageUp(self, fun)
	-- if self._downScl then
		-- self:setScl(1, 1)
	-- else
		-- self:showPage("up")
	-- end
	self:setScl(1, 1)
	
	if not self._anim:isActive() then
		self._anim:start()
	end
	
	self._anim:setListener(MOAIAction.EVENT_STOP, fun)
end

function Button.showPageDown(self)
	-- if self._downScl then
		-- self:setScl(self._downScl, self._downScl)
	-- else
		-- self:showPage("down")
	-- end
	self:setScl(0.9, 0.9)
end

function Button.getSize(self)
	return self:getPage("up"):getSize()
end

function Button.new(up, down, disable)
	local self = PageView.new()
	self._uitype = "Button"
	self._uiname = debug.getlocinfo(2)
	self._up = _MakePage(up)
	self:setPage("up", self._up)
	
	if type(down) == "number" then
		self._downScl = down
		down = up
	end
	self._down = _MakePage(down or up)
	self:setPage("down", self._down)
	
	if type(disable) == "number" then
		self._disableAlpha = disable
		disable = up
	end
	self._disable = _MakePage(disable or up)
	self:setPage("disable", self._disable)
	
	self.handleTouch = Button.handleTouch
	self.onTouchDown = Button.showPageDown
	self.onTouchUp = Button.showPageUp
	self.disable = Button.disable
	self.setUpPage = Button.setUpPage
	self.setDownPage = Button.setDownPage
	self.setDisablePage = Button.setDisablePage
	self.getSize = Button.getSize
	self.onClickSfx = Button.onClickSfx
	self.add = nil
	
	self._curve = interpolate.makeCurve(0, 0.9, MOAIEaseType.LINEAR, 0.1, 1.2, MOAIEaseType.LINEAR, 0.2, 0.9, MOAIEaseType.LINEAR, 0.3, 1.05, MOAIEaseType.LINEAR, 0.4, 1)
	self._anim = MOAIAnim.new()
	self._anim:reserveLinks(2)
	self._anim:setLink(1, self._curve, self, MOAITransform2D.ATTR_X_SCL)
	self._anim:setLink(2, self._curve, self, MOAITransform2D.ATTR_Y_SCL)
	
	return self
end

function Button:disable(on)
	if on then
		if self._disableAlpha then
			self:setColor(1, 1, 1, self._disableAlpha)
		else
			self:showPage("disable")
		end
	else
		if self._disableAlpha then
			self:setColor(1, 1, 1, 1)
		else
			self:showPage("up")
		end
	end
	self._isDisable = on
end

function Button:setUpPage(up)
	self:setPage("up", _MakePage(up))
end

function Button:setDownPage(down)
	self:setPage("down", _MakePage(down))
end

function Button:setDisablePage(disable)
	self:setPage("disable", _MakePage(disable))
end

local Switch = {}
function Switch.handleClick(self)
	self._status = self._status + 1
	if self._status > self._num then
		self._status = 1
	end
	self:turn(self._status)
	if self.onTurn then
		self:onTurn(self._status)
	end
end

function Switch.handleTouchDown(self)
	self:showPage(self._status * 2)
end

function Switch.handleTouchUp(self)
	self:showPage(self._status * 2 - 1)
end

function Switch.new(num, ...)
	local args = {...}
	local self = PageView.new()
	self._uitype = "Switch"
	self._uiname = debug.getlocinfo(2)
	for k, v in pairs(args) do
		if type(v) == "number" then
			self.onShowPage = function(self, on)
				if on then
					self:setScl(v, v)
				else
					self:setScl(1, 1)
				end
			end
		else
			self:setPage(k, _MakePage(v))
		end
	end
	self._num = num
	self.handleTouch = ui.handleTouch
	self.onTouchDown = Switch.handleTouchDown
	self.onTouchUp = Switch.handleTouchUp
	self.onClick = Switch.handleClick
	self.turn = Switch.turn
	self:turn(1)
	return self
end

function Switch:turn(status)
	self._status = status
	self:showPage(status * 2 - 1)
end


local DropList = {}
DropList.VERTICAL = "vertical"
DropList.HORIZONTAL = "horizontal"

local function DropList_ScrollEnd(self, x, y)
	local pos = 0
	local rollback = 0
	
	if not x or not y then
		x, y = self._root:getLoc()
	end

	if self._style == DropList.VERTICAL then
		pos = y
	else
		pos = x
	end

	if pos < 0 then
		rollback = -pos
	elseif pos > self._maxSize then
		rollback = self._maxSize - pos
	end

	if rollback ~= 0 then
		if self.moveAS then
			self.moveAS:stop()
			self.moveAS = nil
		end
		if self._style == DropList.VERTICAL then
			self.moveAS = self._root:moveLoc(0, rollback, 0.4, MOAIEaseType.EASE_OUT)
		else
			self.moveAS = self._root:moveLoc(rollback, 0, 0.4, MOAIEaseType.EASE_OUT)
		end
	end
end

local function DropList_ScrollAction(self)
	if self._maxSize <= 0 then
		return
	end

	local x, y = self._root:getLoc()
	if os.clock() - self.lastTime > 0.1 then
		self.samplings = {}
		DropList_ScrollEnd(self, x, y)
		return
	end
	
	if self._style == DropList.VERTICAL then
		if y < 0 or y > self._maxSize then
			self.samplings = {}
			DropList_ScrollEnd(self, x, y)
			return
		end
	else
		if x < 0 or x > self._maxSize then
			self.samplings = {}
			DropList_ScrollEnd(self, x, y)
			return
		end
	end
	
	local sampleTime = 0
	local totalOffset = 0
	for i = #self.samplings, 2, -1 do
		local tempTime = sampleTime + self.samplings[i].interval
		if tempTime > 0.1 then
			break
		end
		
		sampleTime = tempTime
		totalOffset = totalOffset + self.samplings[i].offset
	end
	self.samplings = {}
	
	if sampleTime == 0 or totalOffset == 0 then
		return
	end
	
	local v = totalOffset / sampleTime
	
	local c = 0.05
	
	if self.scrollEndAS then
		self.scrollEndAS:stop()
		self.scrollEndAS = nil
	end
	self.scrollEndAS = nil
	self.scrollEndAS = ui.AS:run(function(dt)
		if dt > 0 then
			local x, y = self._root:getLoc()
			
			local offset = 0
			
			local dis = v * dt
			
			if self._style == DropList.VERTICAL then
				if y + dis < 0 then
					offset = 0 - (y + dis)
				elseif y + dis > self._maxSize then
					offset = y + dis - self._maxSize
				end
				offset = offset / self._maxSize
				if offset > 1 then
					offset = 1
				end
				v = (v - v * c) * (1 - offset)
				y = y + dis
			else
				if x + dis < 0 then
					offset = 0 - (x + dis)
				elseif x + dis > self._maxSize then
					offset = x + dis - self._maxSize
				end
				offset = offset / self._maxSize
				if offset > 1 then
					offset = 1
				end
				v = (v - v * c) * (1 - offset)
				x = x + dis
			end			
			self._root:setLoc(x, y)
			
			if math.abs(dis) < 0.5 then
				self.scrollEndAS:stop()
				self.scrollEndAS = nil
				
				DropList_ScrollEnd(self, x, y)
			end
		end
	end)
end

local function DropList_scroll(self)
	if self._maxSize <= 0 then
		return
	end
	local move, pos = 0, 0
	local x, y = self._root:getLoc()
	if self._style == DropList.VERTICAL then
		pos = y + self._diffV
	else
		pos = x + self._diffV
	end
	
	if pos >= 0 and pos <= self._maxSize then
		move = self._diffV
	elseif pos < 0 then
		if self._diffV < 0 then
			move = self._diffV * (1 + pos / self._maxSize)
		else
			move = self._diffV
		end
	elseif self._maxSize < pos then
		if self._diffV < 0 then
			move = self._diffV
		else
			move = self._diffV * (1 - (pos - self._maxSize) / self._maxSize)
		end
	end
	if self._style == DropList.VERTICAL then
		self._root:moveLoc(0, move)
	else
		self._root:moveLoc(move, 0)
	end
	
	local curTime = os.clock()
	local intervalTime = curTime - self.lastTime
	self.lastTime = curTime
	table.insert(self.samplings, {offset = self._diffV, interval = intervalTime})
end

function DropList.handleTouchV(self, eventType, touchIdx, x, y, tapCount)
	local this = self._parent._parent
	
	if this._touch.curTouchIdx and this._touch.curTouchIdx ~= touchIdx then
		ui_log("DropList.handleTouchV touch idx unmatch %d, %d", this._touch.curtouchIdx, touchIdx)
		return true
	end
	
	--没按下,且当前也不是按下事件,直接过滤
	if not this._touch.isDown and eventType ~= ui.TOUCH_DOWN then
		return true
	end
	
	if eventType == ui.TOUCH_DOWN then
		if not this._touch.isDown then
			this._touch.isDown = true
			this._touch.curTouchIdx = touchIdx
			ui.capture(self)
			if this.moveAS then
				this.moveAS:stop()
				this.moveAS = nil
			end
			if this.scrollEndAS then
				this.scrollEndAS:stop()
				this.scrollEndAS = nil
			end
		end
		this._lastV = y
		this._diffV = 0
	elseif eventType == ui.TOUCH_UP then
		if this._touch.isDown then
			this._touch.isDown = nil
			this._touch.curTouchIdx = nli
			ui.release(self)
		end
		if not this._scrolling then
			if self.onClick then
				self:onClick(touchIdx, x, y, tapCount)
			end
			DropList_ScrollEnd(this)
		else
			DropList_ScrollAction(this)
		end
		this._scrolling = nil
	elseif eventType == ui.TOUCH_MOVE then
		if dragHappen1D(this._lastV, y) then
			if not this._scrolling then
				this.samplings = {}
				this.lastTime = os.clock()
			end
			this._scrolling = true
			this._diffV = y - this._lastV
			this._lastV = y
			DropList_scroll(this)
		end
	end
	return true
end

function DropList.handleTouchH(self, eventType, touchIdx, x, y, tapCount)
	local this = self._parent._parent
	
	if this._touch.curTouchIdx and this._touch.curTouchIdx ~= touchIdx then
		ui_log("DropList.handleTouchH touch idx unmatch %d, %d", this._touch.curtouchIdx, touchIdx)
		return true
	end
	
	--没按下,且当前也不是按下事件,直接过滤
	if not this._touch.isDown and eventType ~= ui.TOUCH_DOWN then
		return true
	end
	
	if eventType == ui.TOUCH_DOWN then
		if not this._touch.isDown then
			this._touch.isDown = true
			this._touch.curTouchIdx = touchIdx
			ui.capture(self)
			if this.moveAS then
				this.moveAS:stop()
				this.moveAS = nil
			end
			if this.scrollEndAS then
				this.scrollEndAS:stop()
				this.scrollEndAS = nil
			end
		end
		this._lastV = x
		this._diffV = 0
	elseif eventType == ui.TOUCH_UP then
		if this._touch.isDown then
			this._touch.isDown = nil
			this._touch.curTouchIdx = nil
			ui.release(self)
		end
		if not this._scrolling then
			if self.onClick then
				self:onClick(touchIdx, x, y, tapCount)
			end
			DropList_ScrollEnd(this)
		else
			DropList_ScrollAction(this)
		end
		this._scrolling = nil
	elseif eventType == ui.TOUCH_MOVE then
		if dragHappen1D(this._lastV, x) then
			if not this._scrolling then
				this.samplings = {}
				this.lastTime = os.clock()
			end
			this._scrolling = true
			this._diffV = x - this._lastV
			this._lastV = x
			DropList_scroll(this)
		end
	end
	return true
end

function DropList.new(w, h, space, direction)
	local self = ui_new(MOAIProp2D.new())
	self._uitype = "DropList"
	self._uiname = debug.getlocinfo(2)
	self._scissor = MOAIScissorRect.new()
	self._scissor:setParent(self)
	self._root = self:add(ui_new(MOAIProp2D.new()))
	if direction == DropList.VERTICAL then
		self.handleItemTouch = DropList.handleTouchV
		self.addItem = DropList.addItemV
		self.removeItem = DropList.removeItemV
		self._style = DropList.VERTICAL
	else
		self.handleItemTouch = DropList.handleTouchH
		self.addItem = DropList.addItemH
		self.removeItem = DropList.removeItemH
		self._style = DropList.HORIZONTAL
	end
	self._space = space
	self.getSize = DropList.getSize
	self.setSize = DropList.setSize
	self.getItemCount = DropList.getItemCount
	self.clearItems = DropList.clearItems
	self.add = nil
	self:setSize(w, h)
	return self
end

function DropList:getSize()
	return unpack(self._size)
end

function DropList:setSize(w, h)
	self._size = {w, h}
	self._scissor:setRect(-w / 2, -h / 2, w / 2, h / 2)
end

function DropList:clearItems()
	self._root:removeAll()
end

function DropList:addItemV(o)
	local y = self._size[2] / 2 - self._space / 2 + self:getItemCount() * -self._space
	self._root:add(o)
	o:setLoc(0, y)
	o:setScissorRect(self._scissor)
	o.handleTouch = self.handleItemTouch
	o.hitTest = function(wx, wy)
		local x, y = self:getWorldLoc()
		if wx > x - self._size[1] / 2 and wx < x + self._size[1] / 2 and wy > y - self._size[2] / 2 and wy < y + self._size[2] / 2 then
			return true
		end
		return false
	end
	
	self._maxSize = self:getItemCount() * self._space - self._size[2]
	return o
end

function DropList:removeItemV(o, span, mode)
	local index = self._root:remove(o)
	if index then
		o:setScissorRect(nil)
		for i = index, self:getItemCount() do
			v:moveLoc(0, self._space, span, mode)
		end
		self:getItemCount()
		
		self._maxSize = self:getItemCount() * self._space - self._size[2]
		return index
	end
end

function DropList:addItemH(o)
	local x = self._size[1] / 2 - self._space / 2 + self:getItemCount() * -self._space
	self._root:add(o)
	o:setLoc(x, 0)
	o:setScissorRect(self._scissor)
	o.handleTouch = self.handleItemTouch
	o.hitTest = function(wx, wy)
		local x, y = self:getWorldLoc()
		if wx > x - self._size[1] / 2 and wx < x + self._size[1] / 2 and wy > y - self._size[2] / 2 and wy < y + self._size[2] / 2 then
			return true
		end
		return false
	end
	
	self._maxSize = self:getItemCount() * self._space - self._size[1]
	return o
end

function DropList:removeItemH(o, span, mode)
	local index = self._root:remove(o)
	if index then
		o:setScissorRect(nil)
		for i = index, self:getItemCount() do
			v:moveLoc(-self._space, 0, span, mode)
		end
		self:getItemCount()
		
		self._maxSize = self:getItemCount() * self._space - self._size[1]
		return index
	end
end

function DropList:getItemCount()
	return self._root:getChildrenCount()
end

local PickBox = {}
function PickBox.handleTouch(self, eventType, touchIdx, x, y, tapCount)
	if self._touch.curTouchIdx and self._touch.curTouchIdx ~= touchIdx then
		ui_log("PickBox.handleTouch touch idx unmatch %d, %d", self._touch.curtouchIdx, touchIdx)
		return true
	end
	
	--没按下,且当前也不是按下事件,直接过滤
	if not self._touch.isDown and eventType ~= ui.TOUCH_DOWN then
		return true
	end
	
	if eventType == ui.TOUCH_DOWN then
		if not self._touch.isDown then
			self._touch.isDown = true
			self._touch.curTouchIdx = touchIdx
			ui.capture(self)
		end
		self._touch.isInside = true
	elseif eventType == ui.TOUCH_UP then
		if self._touch.isDown then
			self._touch.isDown = nil
			self._touch.curTouchIdx = nil
			ui.release(self)
			if self._touch.isInside then
				self._touch.isInside = nil
				if self.onClick then
					self:onClick(touchIdx, x, y, tapCount)
				end
			end
		end
	elseif eventType == ui.TOUCH_MOVE and self._touch.isDown then
		self._touch.isInside = ui.treeCheck(x, y, self)
	end
	return true
end

function PickBox.new(width, height)
	local self = ui_new(MOAIProp2D.new())
	self._uitype = "PickBox"
	self._uiname = debug.getlocinfo(2)
	local fmt = MOAIVertexFormat.new()
	fmt:declareCoord(1, MOAIVertexFormat.GL_FLOAT, 2)
	local vbo = MOAIVertexBuffer.new()
	vbo:setFormat(fmt)
	vbo:reserveVerts(4)
	vbo:writeFloat(-width/2, -height/2)
	vbo:writeFloat(-width/2, height/2)
	vbo:writeFloat(width/2, -height/2)
	vbo:writeFloat(width/2, height/2)
	vbo:bless()
	local mesh = MOAIMesh.new()
	mesh:setPrimType(MOAIMesh.GL_TRIANGLE_STRIP)
	mesh:setVertexBuffer(vbo)
	self:setDeck(mesh)
	self.handleTouch = PickBox.handleTouch
	self._prePickBoxAddSelf = self._addSelf
	self._addSelf = PickBox._addSelf
	return self
end

function PickBox._addSelf(self)
	if self._prePickBoxAddSelf then
		self:_prePickBoxAddSelf()
	end
end

ui.Group = Group
ui.PageView = PageView
ui.Button = Button
ui.Switch = Switch
ui.DropList = DropList
ui.PickBox = PickBox

return ui