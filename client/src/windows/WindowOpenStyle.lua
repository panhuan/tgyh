
local interpolate = require "interpolate"
local device = require "device"
local actionset = require "actionset"
local eventhub = require "eventhub"


local WindowOpenStyle = {}

local action = {}

WindowOpenStyle._action = action

function WindowOpenStyle:openWindowScl(root)
	local curve = interpolate.makeCurve(0, 0.7, MOAIEaseType.LINEAR, 0.1, 1.1, MOAIEaseType.EASE_IN, 0.2, 1)
	local anim = MOAIAnim.new()
	anim:reserveLinks(2)
	anim:setLink(1, curve, root, MOAITransform2D.ATTR_X_SCL)
	anim:setLink(2, curve, root, MOAITransform2D.ATTR_Y_SCL)
	anim:start()
	anim:setListener(MOAIAction.EVENT_STOP, function()
		eventhub.fire("UI_EVENT", "WINDOW_SCL_OVER", root)
	end)
end

function WindowOpenStyle:openWindowAlpha(root)
	root:setColor(0, 0, 0, 0.5)
	root:seekColor(1, 1, 1, 1, 0.2, MOAIEaseType.EASE_IN)
end

function WindowOpenStyle:closeWindowMove(...)
	local n = argc(...)
	local t = {...}
	for i = 1, n do
		t[i]:setLoc(-device.ui_width, 0)
	end

	uiLayer.disableTouch = true
	stageLayer.disableTouch = true
	uiLayer:setCamera(normalCamera)
	local cameraX, cameraY = normalCamera:getLoc()
	normalCamera:setLoc(cameraX - device.ui_width, cameraY)
	cameraX, cameraY = normalCamera:getLoc()
	local curve = interpolate.makeCurve(0, cameraX, MOAIEaseType.LINEAR, 2.5, cameraX + device.ui_width)
	local anim = MOAIAnim.new()
	anim:reserveLinks(1)
	anim:setLink(1, curve, normalCamera, MOAITransform2D.ATTR_X_LOC)
	anim:start()
	anim:setListener(MOAIAction.EVENT_STOP, function()
		uiLayer:setCamera(nil)
		uiLayer.disableTouch = false
		stageLayer.disableTouch = false
		for i = 1, n do
			t[i]:remove()
		end
	end)
end

function WindowOpenStyle:closeWindowAlpha(...)
	uiLayer.disableTouch = true
	stageLayer.disableTouch = true
	
	local callback = nil
	local n = argc(...)
	local t = {...}
	for i = 1, n do
		callback = t[i]:seekColor(0, 0, 0, 0, 0.5, MOAIEaseType.EASE_IN)
	end
	
	callback:setListener(MOAIAction.EVENT_STOP, function()
		for i = 1, n do
			t[i]:remove()
		end
		uiLayer.disableTouch = false
		stageLayer.disableTouch = false
	end)
end

function WindowOpenStyle:openWindowSclMove(root, x1, y1, x2, y2)
	if self._action then
		for key, var in ipairs(self._action) do
			var:stop()
		end
	end
	root:setLoc(x1, y2)
	root:setScl(0.001, 0.001)
	
	self._action[1] = root:seekLoc(x2, y2, 0.5, MOAIEaseType.EASE_OUT)
	self._action[2] = root:seekScl(1, 1, 0.5, MOAIEaseType.EASE_OUT)
end

function WindowOpenStyle:nodeJellyEffect(node)
	local curve = interpolate.makeCurve(0, 0.6, MOAIEaseType.LINEAR, 0.1, 1.2, MOAIEaseType.LINEAR, 0.2, 0.9, MOAIEaseType.LINEAR, 0.3, 1.05, MOAIEaseType.LINEAR, 0.4, 1)
	local anim = MOAIAnim.new()
	anim:reserveLinks(2)
	anim:setLink(1, curve, node, MOAITransform2D.ATTR_X_SCL)
	anim:setLink(2, curve, node, MOAITransform2D.ATTR_Y_SCL)
	return anim:start()
end

return WindowOpenStyle