local WeightTable = {}
WeightTable.__index = WeightTable
WeightTable.__mode = "k"
function WeightTable.new(tt)
	tt = tt or {}
	setmetatable(tt, WeightTable)
	return tt
end
function WeightTable:set(item, w)
	if item ~= nil then
		self[item] = w
	end
end
function WeightTable:add(item, w)
	if item ~= nil then
		local _w = self[item]
		self[item] = (_w or 0) + w
	end
end
function WeightTable:mul(item, w)
	if item ~= nil then
		local _w = self[item]
		self[item] = (_w or 1) * w
	end
end
function WeightTable:reset()
	for k, v in pairs(self) do
		self[k] = nil
	end
end
function WeightTable:lowest()
	local item, best
	for i, w in pairs(self) do
		if item == nil or w < best then
			item = i
			best = w
		end
	end
	return item, best
end
function WeightTable:highest()
	local item, best
	for i, w in pairs(self) do
		if item == nil or best < w then
			item = i
			best = w
		end
	end
	return item, best
end
return WeightTable
