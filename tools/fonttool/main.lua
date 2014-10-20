
package.path = "../../client/lib/?.lua;?.lua;../../base/?.lua"
local file = require "file"
local data = dofile "number.atlas.lua"

local dpi = 72

local point = 72

local ImgWidth, ImgHeight = 512, 512

local tbData = {}

local FontTool = {}

local tbNumberToId = 
{
	[0] = 48,
	[1] = 49,
	[2] = 50,
	[3] = 51,
	[4] = 52,
	[5] = 53,
	[6] = 54,
	[7] = 55,
	[8] = 56,
	[9] = 57,
	["+"] = 43,
	["-"] = 45,
	["("] = 40,
	[")"] = 41,
	["%"] = 37,
	["#"] = 47,		-- 文件名不能有"/" 所以用"#"代替"/"
	["$"] = 58,		-- 文件名不能有":" 所以用"$"代替":"
	["x"] = 120,
}

local tbOffsetPos =
{
	["level1"] = 
	{
		["%"] = {x = 3},
		["+"] = {x = -4, y = 4},
	},
	["exp"] =
	{
		[1] = {y = 1},
		[2] = {y = -1},
		[4] = {y = 1},
		[7] = {y = 1},
		[9] = {y = -1},
		["#"] = {y = -3},
	},
	["money"] = 
	{
		[3] = {y = -1},
		[4] = {y = -1},
		[5] = {y = -1},
		[9] = {y = -1},
	},
	["jsjc"] = 
	{
		["%"] = {x = 3},
		["+"] = {x = -4, y = 4},
	},
	["lock"] =
	{
		[1] = {y = 1},
		[2] = {y = 1},
		[4] = {y = 1},
		[7] = {x = 1, y = 1},
		[9] = {y = 1},
	},
	["buynumber"] =
	{
		[1] = {y = 1},
		[5] = {y = 1},
		[8] = {y = -1},
		[9] = {y = -1},
	},
	["buyprice"] =
	{
		[1] = {y = 1},
		[2] = {y = -1},
		[4] = {y = 1},
		[7] = {y = 1},
		[9] = {y = -1},
	},
	["pet_red"] =
	{
		[1] = {y = 1},
		[2] = {y = 1},
		[4] = {y = 1},
		[5] = {y = 2},
		[7] = {y = 1},
	},
	["enemy"] =
	{
		[2] = {y = -2},
		[3] = {y = -2},
		[8] = {y = -2},
		[9] = {y = -2},
		[0] = {y = -2},
		["-"] = {y = 4},
	},
	["jswz_da"] = 
	{
		[1] = {xadv = 31},
		[2] = {y = 1},
		[3] = {y = 1},
		[9] = {y = 1},
	},
	["timing"] =
	{
		[5] = {y = -1},
		["$"] = {y = 2, xadv = 9},
	},
	["item"] = 
	{
		[1] = {xadv = 12},
		[2] = {xadv = 18},
		[3] = {y = -1, xadv = 18},
		[4] = {xadv = 18},
		[5] = {y = 1, xadv = 18},
		[6] = {y = 1, xadv = 20},
		[7] = {xadv = 18},
		[8] = {y = -1, xadv = 18},
		[9] = {xadv = 20},
		[0] = {y = -1, xadv = 20},
	},
	["rw_sz"] = 
	{
		[1] = {xadv = 18},
		[4] = {y = 1, xadv = 25},
		["#"] = {y = -1},
		["("] = {y = -2},
		[")"] = {y = -2},
		["x"] = {x = 2, y = 2, xadv = 28},
	},
}

local texture = ""

function FontTool:setData(name, key, v)
	local wImg = v.spriteColorRect.width
	local hImg = v.spriteColorRect.height
	local xadvance = wImg
	local xImg = math.floor(v.uvRect.u0 * ImgWidth + 0.5)
	local yImg = math.floor(v.uvRect.v0 * ImgHeight + 0.5)
	local xOffset = 0
	local yOffset = 0
	for k, v in pairs(tbOffsetPos) do
		if k == name then
			for i, j in pairs(v) do
				if key == i then
					xOffset = j.x or 0
					yOffset = j.y or 0
					xadvance = j.xadv or wImg
				end
			end
		end
	end	
	if not tbData[name] then
		tbData[name] = {}
	end
	tbData[name][key] = {x = xImg, y = yImg, w = wImg, h = hImg, xAdv = xadvance, xOffset = xOffset, yOffset = yOffset}
end

function FontTool:OpenFile()
	for key, var in pairs(data) do
		if key == "texture" then
			texture = var
		elseif key == "frames" then
			for k, v in pairs(var) do
				local name = string.sub(v.name, 1, -7)
				local lastKey = string.sub(v.name, -5, -5)
				for i, j in pairs(tbNumberToId) do
					if lastKey == i then
						self:setData(name, lastKey, v)
					elseif tonumber(lastKey) == i then
						self:setData(name, tonumber(lastKey), v)
					end
				end
			end
		end
	end
	self:WriteFile()
end

function FontTool:WriteFile()
	for key, var in pairs(tbData) do
		local text = ""
		local height = 0
		local size = 0
		local str = ""
		for k, v in pairs(var) do
			local id = "char id="..tbNumberToId[k].." "
			local x = "x="..v.x.." "
			local y = "y="..v.y.." "
			local w = "width="..v.w.." "
			local h = "height="..v.h.." "
			local offset = "xoffset="..v.xOffset.." yoffset="..v.yOffset.." "
			local xadvance = "xadvance="..v.xAdv.." "
			local page = "page=0 chnl=0 "
			str = k
			if k == "#" then
				str = "/"
			elseif k == "$" then
				str = ":"
			end
			local letter = "letter=".."\""..str.."\""
			text = text..id..x..y..w..h..offset..xadvance..page..letter.."\n"
			height = v.h
			if height > size then
				size = height
			end
		end
		--size = size / dpi * point
		local title = "info face=\""..key.."\" size="..size.." unicode=0\ncommon lineHeight="..height.." scaleW="..ImgWidth.." scaleH="..ImgHeight.." pages=1 packed=0\npage id=0 file=\""..texture.."\"\nchars count=10\n"
		local totle = title..text
		local filename = key.."-ttf.fnt"
		file.write(filename, totle)
	end
	print("success")
end

FontTool:OpenFile()