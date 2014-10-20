
-- package.path = "../../client/lib/?.lua;?.lua;../../base/?.lua"
-- local file = require "file"
-- local data = dofile "number.atlas.lua"

local file = require "file"

local flaTool = {}

function flaTool:loadFlaFile(path)
	self._data = {}
	print("flaTool loadFlaFile '"..path.."'")
	for_every(path, nil, function(file)
		local index = nil
		if string.find(file, "_hit.fla.lua") ~= nil then
			local pos = string.find(file, "_hit.fla.lua") - 1
			index = string.sub(file, 1, pos)
			index = index:gsub(path.."/", "")
			self._data[index] = self._data[index] or {}
			self._data[index].hit = dofile(file)
		elseif string.find(file, "_idl.fla.lua") ~= nil then
			local pos = string.find(file, "_idl.fla.lua") - 1
			index = string.sub(file, 1, pos)
			index = index:gsub(path.."/", "")
			self._data[index] = self._data[index] or {}
			self._data[index].idl = dofile(file)
		elseif string.find(file, "_hit.fla.png") ~= nil then
			local pos = string.find(file, "_hit.fla.png") - 1
			index = string.sub(file, 1, pos)
			index = index:gsub(path.."/", "")
			self._data[index] = self._data[index] or {}
			self._data[index].hitpng = file:gsub(path.."/", "")
		elseif string.find(file, "_idl.fla.png") ~= nil then
			local pos = string.find(file, "_idl.fla.png") - 1
			index = string.sub(file, 1, pos)
			index = index:gsub(path.."/", "")
			self._data[index] = self._data[index] or {}
			self._data[index].idlpng = file:gsub(path.."/", "")
		else
			print("##--[***error***]--## file name: "..file)
		end
	end, nil, nil, 1)
	self:createNewData()
	self:createNewFile(path)
end

function flaTool:compareData(index)
	local same = true
	local hit = self._data[index].hit
	local idl = self._data[index].idl
	if hit.fps ~= idl.fps then
		print("##--compareData fps", index)
		same = false
	end
	if hit.width ~= idl.width then
		print("##--compareData width", index)
		if hit.width > idl.width then
			idl.width = hit.width
		else
			hit.width = idl.width
		end
	end
	if hit.height ~= idl.height then
		print("##--compareData height", index)
		if hit.height > idl.height then
			idl.height = hit.height
		else
			hit.height = idl.height
		end
	end
	if #hit.brushDeck ~= #idl.brushDeck then
		print("##--compareData brushDeck count", index)
		same = false
	end
	for i = 1, #hit.brushDeck do
		local hitDeck = hit.brushDeck[i]
		local idlDeck = idl.brushDeck[i]
		if hitDeck.u0 ~= idlDeck.u0 then
			print("##--compareData u0", index, i)
			same = false
		end
		if hitDeck.v0 ~= idlDeck.v0 then
			print("##--compareData v0", index, i)
			same = false
		end
		if hitDeck.u1 ~= idlDeck.u1 then
			print("##--compareData u1", index, i)
			same = false
		end
		if hitDeck.v1 ~= idlDeck.v1 then
			print("##--compareData v1", index, i)
			same = false
		end
		if hitDeck.w ~= idlDeck.w then
			print("##--compareData w", index, i)
			same = false
		end
		if hitDeck.h ~= idlDeck.h then
			print("##--compareData h", index, i)
			same = false
		end
		if hitDeck.r and idlDeck.r and hitDeck.r ~= idlDeck.r then
			print("##--compareData r", index, i)
			same = false
		end
		if hitDeck.r and not idlDeck.r then
			print("##--compareData r", index, i)
			same = false
		end
		if not hitDeck.r and idlDeck.r then
			print("##--compareData r", index, i)
			same = false
		end
	end
	return same
end

function flaTool:createNewData()
	local count = 0
	self._newData = {}
	for index, data in pairs(self._data) do
		if self:compareData(index) then
			if data.hit and data.idl then
				local newData = {}
				newData.texture = index..".fla.png"
				newData.fps = data.hit.fps
				newData.width = data.hit.width
				newData.height = data.hit.height
				newData.brushDeck = data.hit.brushDeck
				newData.timelines = {}
				newData.timelines.hit = data.hit.timeline
				newData.timelines.idl = data.idl.timeline
				self._newData[index] = newData
			end
		else
			count = count + 1
		end
	end
	print("##--can not cteate count is: ", count)
end

function flaTool:createNewFile(out)
	local newOut = out.."/new/"
	os.execute("md ".."\""..newOut.."\"")
	for index, var in pairs(self._newData) do
		local path = newOut..index..".fla.lua"
		local text = "return "..toprettystring(var)
		file.write(path, text)
		local srcImg = out.."/"..self._data[index].hitpng
		local dstImg = newOut..var.texture
		file.copy(srcImg, dstImg)
	end
end

return function (path)
	flaTool:loadFlaFile(path)
end