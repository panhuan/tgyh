
local node = require "node"
local resource = require "resource"

local ColorPatch = {}

function ColorPatch.new(width, height, color)
	if not color or not width or not height then
		return
	end
	
	local self = node.new(MOAIProp2D.new())
	self._width = width
	self._height = height
	
	local fmt = MOAIVertexFormat.new()
	fmt:declareCoord(1, MOAIVertexFormat.GL_FLOAT, 2)
		
	local vbo = MOAIVertexBuffer.new()
	vbo:setFormat(fmt)
	self.vbo = vbo
	
	local mesh = MOAIMesh.new()
	mesh:setPrimType(MOAIMesh.GL_TRIANGLE_STRIP)
	mesh:setVertexBuffer(vbo)
	self:setDeck(mesh)
	self.setColor = ColorPatch.setColor
	self:setColor(color)
	
	return self
end

function ColorPatch:setColor(color)
	local width = self._width
	local height = self._height
	local vbo = self.vbo
	vbo:reserveVerts(4)
	vbo:reset()
	
	vbo:writeFloat(-width/2, -height/2)
	vbo:writeFloat(-width/2, height/2)
	vbo:writeFloat(width/2, -height/2)
	vbo:writeFloat(width/2, height/2)
	
	if MOAIGfxDevice.isProgrammable() then
      self:setShader(resource.shader(color))
	end
  
	vbo:bless()
end

return ColorPatch