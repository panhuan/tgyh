
local math2d = require "math2d"

local node = {}

local function node_setLayer(self, layer)
	if self._layer == layer then
		return
	end
	if layer ~= nil then
		self._setLayer(self, layer)
		if self._children ~= nil then
			for k, v in pairs(self._children) do
				node_setLayer(v, layer)
			end
		end
	elseif self._layer ~= nil then
		self._setLayer(self, nil)
		if self._children ~= nil then
			for k, v in pairs(self._children) do
				node_setLayer(v, nil)
			end
		end
	end
end

function node._removeSelf(self)
	self._parent = nil
	self:setParent(nil)
	self:setScissorRect(nil)
	node_setLayer(self, nil)
end

function node._setLayer(self, layer)
	if layer then
		layer:insertProp(self)
	else
		self._layer:removeProp(self)
	end
	self._layer = layer
end

function node.setScissorRect(self, rect)
	local scissor = nil
	self._scissorRect = rect
	
	if self._scissorRect and self._inheritScissorRect then
		self._scissorRect:setScissorRect(self._inheritScissorRect)
		scissor = self._scissorRect
	elseif self._scissorRect and not self._inheritScissorRect then
		scissor = self._scissorRect
	elseif not self._scissorRect and self._inheritScissorRect then
		scissor = self._inheritScissorRect
	end
	
	if self._preNodeSetScissorRect then
		self._myScissor = scissor
		self:_preNodeSetScissorRect(scissor)
	end
	
	if self._children ~= nil then
		for k, v in pairs(self._children) do
			v:inheritScissorRect(scissor)
		end
	end
end

function node.inheritScissorRect(self, rect)
	local scissor = nil
	self._inheritScissorRect = rect
	
	if self._scissorRect then
		self._scissorRect:setScissorRect(self._inheritScissorRect)
		scissor = self._scissorRect
	else
		scissor = self._inheritScissorRect
	end
	
	if self._preNodeSetScissorRect then
		self._myScissor = scissor
		self:_preNodeSetScissorRect(scissor)
	end
	
	if self._children ~= nil then
		for k, v in pairs(self._children) do
			v:inheritScissorRect(scissor)
		end
	end
end

function node.getScissorRect(self)
	return self._myScissor
end

function node.add(self, child)
	assert(child ~= nil, "Child must not be null")
	assert(child._layer == nil or child._layer ~= child, "Nested viewports not supported")
	
	if child._parent ~= nil then
		if child._parent == self then
			return child
		end
		child._parent:remove(child)
	end
	child._parent = self
	
	local p = self:getPriority()
	if p then
		child:setPriority(p + (child._priorityOffset or 1))
	end
	
	if self._myScissor then
		child:inheritScissorRect(self._myScissor)
	end
	
	if self._children == nil then
		self._children = {}
	end
	
	if child._addSelf then
		child:_addSelf()
	end
	
	self._children[child] = child
	self._childrenCount = self._childrenCount + 1
	child:setParent(self)
	node_setLayer(child, self._layer)
	return child
end

function node.removeAll(self, recursion)
	if self._children ~= nil then
		for k, v in pairs(self._children) do
			v:_removeSelf()
			if recursion then
				node.removeAll(v, recursion)
			end
		end
		self._children = nil
	end
	self._childrenCount = 0
end

function node.remove(self, child)
	if child == nil then
		if self._parent ~= nil then
			return node.remove(self._parent, self)
		end
		return false
	end
	if child._parent ~= self then
		return false
	end
	if self._children ~= nil then
		if self._children[child] ~= nil then
			child:_removeSelf()
			self._children[child] = nil
			self._childrenCount = self._childrenCount - 1
		end
	end
	return false
end

function node.destroy(self)
	self:remove()
	if self._children ~= nil then
		for k, v in pairs(self._children) do
			v:destroy()
		end
		self._children = nil
	end
	if self._preNodeDestroy then
		self._preNodeDestroy(self)
	end
end

function node.setPriority(self, p, noRecursion)
	if self._preNodeSetPriority then
		self:_preNodeSetPriority(p)
	end
	if not noRecursion and self._children ~= nil then
		for k, v in pairs(self._children) do
			v:setPriority((p or 0) + (v._priorityOffset or 1), noRecursion)
		end
	end
end

function node.setPriorityOffset(self, p)
	self._priorityOffset = p
	local pp = self._parent and self._parent:getPriority() or 0
	self:setPriority(pp + p)
end

function node.setAnchor(self, anchor, x, y)
	self._anchor = anchor
	local layoutsize = self._parent:getLayoutSize()
	local diffX = math.floor(layoutsize.width / 2)
	local diffY = math.floor(layoutsize.height / 2)
	
	if anchor[1] == "L" then
		x = x - diffX
	elseif anchor[1] == "R" then
		x = x + diffX
	else
		assert(anchor[1] == "M")
	end
	
	if anchor[2] == "T" then
		y = y + diffY
	elseif anchor[2] == "B" then
		y = y - diffY
	else
		assert(anchor[2] == "M")
	end
	
	self:setLoc(x, y)
end

function node.setLayoutSize(self, w, h)
	assert(w and h, "Bad layout size")
	
	local layoutsize = self._layoutsize or {width = 0, height = 0}
	if self._children and (layoutsize.width ~= w or layoutsize.height ~= h) then
		local diffX = math.floor((w - layoutsize.width) / 2)
		local diffY = math.floor((h - layoutsize.height) / 2)
		for i, e in pairs(self._children) do
			local anchor = e._anchor
			if anchor ~= nil then
				if anchor[1] == "L" then
					x = x - diffX
				elseif anchor[1] == "R" then
					x = x + diffX
				end
				if anchor[2] == "T" then
					y = y + diffY
				elseif anchor[2] == "B" then
					y = y - diffY
				end
				e:setLoc(x, y)
			end
		end
	end
	self._layoutsize = {width = w, height = h}
end

function node.getLayoutSize(self)
	local parent = self
	while parent ~= nil do
		if parent._layoutsize ~= nil then
			return parent._layoutsize
		end
		parent = parent._parent
	end
end

function node.getChildrenCount(self)
	return self._childrenCount
end

function node.new(o)
	o = o or MOAIProp2D.new()
	o._preNodeDestroy = o.destroy
	o.destroy = node.destroy
	o.add = node.add
	o.remove = node.remove
	o.removeAll = node.removeAll
	o._preNodeSetScissorRect = o.setScissorRect
	o.setScissorRect = node.setScissorRect
	o.getScissorRect = node.getScissorRect
	o.inheritScissorRect = node.inheritScissorRect
	o._preNodeSetPriority = o.setPriority
	o.setPriority = node.setPriority
	o.setPriorityOffset = node.setPriorityOffset
	o._setLayer = node._setLayer
	o.setAnchor = node.setAnchor
	o.setLayoutSize = node.setLayoutSize
	o.getLayoutSize = node.getLayoutSize
	o.getChildrenCount = node.getChildrenCount
	o._removeSelf = node._removeSelf
	o._childrenCount = 0
	o:setPriority(0)
	return o
end

return node