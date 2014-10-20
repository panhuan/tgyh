
local ui = require "ui"
local node = require "node"
local Image = require "gfx.Image"
local timer = require "timer"
local device = require "device"
local eventhub = require "eventhub"
local SoundManager = require "SoundManager"
local resource = require "resource"
local bucket = resource.bucket

local whiteMaskImage	= "white_mask.jpg?scl="..device.ui_width..","..device.ui_height
local storyList =
{
	["opening"] = 
	{
		{
			{
				image = "story.atlas.png#a1.png",
				scl = 1,
				x = 0,
				y = 196,
				enter_mode = "down",
				delay_time = 0,
				move_time = 0.5,
			},
			{
				image = "story.atlas.png#a2.png",
				scl = 1,
				x = -130,
				y = -260,
				enter_mode = "left",
				delay_time = 1.5,
				move_time = 0.5,
			},
			{
				image = "story.atlas.png#a3.png",
				scl = 1,
				x = 150,
				y = -260,
				enter_mode = "right",
				delay_time = 3,
				move_time = 0.5,
			},
		},
		{
			{
				image = "story.atlas.png#b1.png",
				scl = 1,
				x = 0,
				y = 260,
				enter_mode = "right",
				delay_time = 0,
				move_time = 0.5,
			},
			{
				image = "story.atlas.png#b2.png",
				scl = 1,
				x = 0,
				y = 38,
				enter_mode = "left",
				delay_time = 1.5,
				move_time = 0.5,
			},
			{
				image = "story.atlas.png#b3.png",
				scl = 1,
				x = 0,
				y = -266,
				enter_mode = "right",
				delay_time = 3,
				move_time = 0.5,
			},
		}
	}
}

local StoryPanel = {}
function StoryPanel:init()	
	self._root = ui.PickBox.new(device.ui_width, device.ui_height)
	self._root:setLayoutSize(device.ui_width, device.ui_height)
	self._root:setPriorityOffset(2000)
	
	local whiteBg = self._root:add(Image.new(whiteMaskImage))
	whiteBg:setPriority(1)
	whiteBg:setColor(245/255, 245/255, 220/255)

	self._imageRoot = self._root:add(node.new())
	self._imageRoot:setPriorityOffset(2)
end

function StoryPanel:open(storyName, callBack)
	local story = storyList[storyName]
	if not story and #story > 0 then
		print("[WARN] No such stroy!", storyName)
		return
	end
	
	ui.capture(self.handleTouch)
	popupLayer:add(self._root)
	
	self._story = story
	self._curStage = 1
	bucket.push("StoryPanel")
	self:playStage()
	bucket.pop()
	self._callBack = callBack
	return
end

function StoryPanel:close()
	ui.release(self.handleTouch)
	self._imageRoot:removeAll()
	popupLayer:remove(self._root)
	bucket.release("StoryPanel")
end

function StoryPanel:playStage()
	local stage = self._story[self._curStage]
	if not stage then
		if self._callBack then
			pcall(self._callBack)
			self:close()
		end
		
		return
	end
	
	for i, pic in ipairs (stage) do
		local img = Image.new(pic.image)
		if pic.scl then
			img:setScl(pic.scl)
		end
		
		local sourceX, sourceY = self:calcSourcePos(img, pic)
		img:setLoc(sourceX, sourceY)
		self._imageRoot:add(img)
		
		mainAS:delaycall(pic.delay_time, function()
			local a = img:seekLoc(pic.x, pic.y, pic.move_time, MOAIEaseType.LINEAR)
			a:setListener(MOAIAction.EVENT_STOP, function()
				if i == #stage then
					self._playFinished = true
				end
			end)
		end)
	end
end

function StoryPanel:calcSourcePos(img, pic)
	local sourceX = 0
	local sourceY = 0
	local w, h = img:getSize()
	if pic.enter_mode == "up" then
		sourceX = pic.x
		sourceY = device.ui_height/2 + h/2
	elseif pic.enter_mode == "down" then
		sourceX = pic.x
		sourceY = -device.ui_height/2 - h/2
	elseif pic.enter_mode == "left" then
		sourceX = -device.ui_width/2 - w/2
		sourceY = pic.y
	elseif pic.enter_mode == "right" then
		sourceX = device.ui_width/2 + w/2
		sourceY = pic.y
	else
		print("[WARN] No such enter mode", pic.enter_mode)
	end
	
	return sourceX, sourceY
end

function StoryPanel.handleTouch(eventType, touchIdx, x, y, tapCount)
	local self = StoryPanel
	
	if eventType == ui.TOUCH_DOWN then
		self:nextStage()
	end
end

function StoryPanel:nextStage()
	if self._playFinished then
		self._playFinished = false
		self._imageRoot:removeAll()
		self._curStage = self._curStage + 1
		self:playStage()
	end
end

return StoryPanel
