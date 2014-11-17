
local WindowManager = {}

function WindowManager:init()
	self._window = {}
	self._layer = {}
	self._layer["ui"] = uiLayer
	self._layer["pop"] = popupLayer
	self._layer["game"] = gameLayer
	self._lastPriority = 0
end

function WindowManager:initWindow(name, window)
	assert(not self._window[name], "name has already been taken: "..name)
	self._window[name] = window
end

function WindowManager:open(name, layerName)
	assert(self._window[name], "window name is not exist: "..name)
	layerName = layerName or "ui"
	assert(self._layer[layerName], "layer is not exist:"..layerName)
	self._layer[layerName]:add(self._window[name]._root)
	
	if layerName == "pop" then
		self._window[name]._root:setPriority(self._lastPriority + 1)
		local priority = self:getPriority(self._window[name]._root)
		if priority > self._lastPriority then
			self._lastPriority = priority
		end		
	end
	if self._window[name].open then
		self._window[name]:open()
	end
end

function WindowManager:close(name)
	assert(self._window[name], "window name is not exist: "..name)
	self._window[name]._root:remove()
	if self._window[name].close then
		self._window[name]:close()
	end
end

function WindowManager:getPriority(node, priority)
	priority = priority or node:getPriority()
	if self._children ~= nil then
		for k, v in pairs(self._children) do
			local setPriority = v:getPriority()
			if setPriority > priority then
				priority = setPriority
			end
			self:getPriority(v, priority)
		end
	end
	return priority
end

return WindowManager