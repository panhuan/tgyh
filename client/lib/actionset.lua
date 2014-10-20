require("moai.compat")
local timerutil = require("timerutil")
local yield = coroutine.yield
local actionset = {}

local function run_in_child_thread(action, ...)
	local oldroot = MOAIActionMgr.getRoot()
	MOAIActionMgr.setRoot(action)
	local t = MOAIThread.new()
	t:run(...)
	MOAIActionMgr.setRoot(oldroot)
	return t
end

local function actionset_runfunc(timer, f)
	local startT = timer:getTime()
	local lastT = startT
	while true do
		do
			local t = timer:getTime()
			local dt = t - lastT
			lastT = t
			local ok, result, stack = pcall(f, dt, t - startT)
			if not ok then
				print("ERROR: " .. tostring(result), stack)
			end
			yield()
		end
	end
end

local function actionset_run(self, f, onStop)
	if type(f) ~= "function" then
		error("invalid actionset runnable: " .. tostring(f))
	end
	local action = run_in_child_thread(self, actionset_runfunc, self, f)
	if onStop ~= nil then
		action:setListener(MOAITimer.EVENT_STOP, onStop)
	end
	return action
end

local function actionset_attach(self, action, onStop)
	if action ~= nil then
		if type(action) == "function" then
			action = run_in_child_thread(self, actionset_runfunc, self, action)
		else
			table.insert(self._children, action)
			self:addChild(action)
		end
		if onStop ~= nil then
			action:setListener(MOAITimer.EVENT_STOP, onStop)
		end
	end
	return action
end

local function actionset_delaycall(self, ...)
	return actionset_attach(self, timerutil.delaycall(...))
end

local function actionset_repeatcall(self, ...)
	return actionset_attach(self, timerutil.repeatcall(...))
end

local function actionset_repeatcalln(self, ...)
	return actionset_attach(self, timerutil.repeatcalln(...))
end

local function actionset_removeall(self)
	self:stop()
	
	for _, action in pairs (self._children) do
		if action.destroy then
			action:destroy()
		end
	end
end

function actionset.new()
	local self = MOAITimer.new()
	self:setSpan(0, 1.0E37)
	self:start()
	self.pause = timerutil.pause
	self.resume = timerutil.resume
	self.isPaused = timerutil.isPaused
	self.throttle = timerutil.throttle
	self.run = actionset_run
	self.attach = actionset_attach
	self.delaycall = actionset_delaycall
	self.repeatcall = actionset_repeatcall
	self.repeatcalln = actionset_repeatcalln
	self.removeAll = actionset_removeall
	self._children = {}
	return self
end

return actionset
