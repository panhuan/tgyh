
local columns, rows = 7, 6
local radius = 2

--偶数列和奇数列的计算中心在下面设置
local centerColumn
local centerRow

local singular = 
{
	[1] = {0, 1},
	[2] = {1, 0},
	[3] = {1, -1},
	[4] = {0, -1},
	[5] = {-1, -1},
	[6] = {-1, 0},
}
local even = 
{
	[1] = {0, 1},
	[2] = {1, 1},
	[3] = {1, 0},
	[4] = {0, -1},
	[5] = {-1, 0},
	[6] = {-1, 1},
}

local function _tokey(v)
	local tname = type(v)
	if tname == "number" then
		return string.format("[%d]", v)
	elseif tname == "string" then
		return string.format("[%q]", v)
	end
	return string.format("[%s]", tostring(v))
end

local function todetailstring(v, nometa, sep, tab, _pre, _loc, _ref)
	_pre = _pre or ""
	_loc = _loc or "*"
	_ref = _ref or {}
	_ref[v] = _loc
	local str = _pre
	local tname = type(v)
	if tname == "table" then
		local comma = ""
		for k, v in pairs(v) do
			str = str..comma
			comma = ","
			str = str..sep..tab.._pre.._tokey(k)..tab.."="
			if not _ref[v] then
				local tname = type(v)
				if tname == "table" or tname == "userdata" then
					local _loc = _loc.._tokey(k)
					str = str..tab..todetailstring(v, nometa, sep, tab, _pre..tab, _loc, _ref)
					_ref[v] = _loc
				else
					str = str..tab..tostring(v)
				end
			else
				str = str..tab.._ref[v]
			end
		end
		if not nometa then
			local _M = getmetatable(v)
			if _M then
				str = str..sep..tab.._pre.."_M"..tab.."="..tab..todetailstring(_M, nometa, sep, tab, _pre..tab, _loc, _ref)
			end
		end
		if str == "" then
			str = "{}"
		else
			str = "{"..str..sep.._pre.."}"
		end
	elseif tname == "userdata" then
		str = str..tostring(v)
		if not nometa then
			local _M = getmetatable(v)
			if _M then
				str = str.." "..todetailstring(_M, nometa, sep, tab, _pre, _loc, _ref)
			end
		end
	else
		str = str..tostring(str)
	end
	return str
end

local function toprettystring(v, nometa)
	return todetailstring(v, nometa, "\n", "\t")
end


local function nextBall(column, row, dir)
	local t
	if math.fmod(column, 2) == 0 then
		t = even
	else
		t = singular
	end
	local c = column + t[dir][1]
	local r = row + t[dir][2]
	if c >= 1 and c <= columns and r >= 1 and r <= rows then
		return c, r
	end
end

local function generateBombRoundLocs(column, row, tbRoundLoc, tbTotalLoc)
	for d = 1, 6 do
		local c, r = column, row
		c, r = nextBall(c, r, d)
		if c and r then
			if not tbRoundLoc[c] then
				tbRoundLoc[c] = {}
			end
			tbRoundLoc[c][r] = true
			
			if not tbTotalLoc[c] then
				tbTotalLoc[c] = {}
			end
			tbTotalLoc[c][r] = true
		end
	end
end

local function Run(columnType, writeType)
	if columnType == "even" then
		centerColumn = 4
		centerRow = 3
	elseif columnType == "singular" then
		centerColumn = 3
		centerRow = 4
	else
		print("[ERR] columnType error", columnType)
		return
	end
	
	
	local tbTotalLoc = {}
	local tbRoundLoc = {}
	local tbTempLoc = {}
	tbTempLoc[centerColumn] = {}
	tbTempLoc[centerColumn][centerRow] = true

	local curRadius = 1
	while (curRadius <= radius) do
		for i = 1, columns do 
			for j = 1, rows do
				if tbTempLoc[i] and tbTempLoc[i][j] then
					generateBombRoundLocs(i, j, tbRoundLoc, tbTotalLoc)
				end
			end
		end
		tbTempLoc = tbRoundLoc
		tbRoundLoc = {}
		curRadius = curRadius + 1
	end
	
	local tbOffset = {}
	local tb = {}
	for i = 1, columns do 
		for j = 1, rows do
			if tbTotalLoc[i] and tbTotalLoc[i][j] then
				table.insert(tbOffset, {offC = i - centerColumn, offR = j - centerRow})
			end
		end
	end
	
	local file = io.open("bomb_round_offs.txt", writeType)
	file:write("local "..columnType.."BombRoundOffs = "..toprettystring(tbOffset).."\n\n")
	file:close()
end

Run("singular", "w")
Run("even", "a")

print("success!")
