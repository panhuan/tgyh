

local name = {
	[MOAIImage.COLOR_FMT_A_8] = "COLOR_FMT_A_8",
	[MOAIImage.COLOR_FMT_RGB_888] = "COLOR_FMT_RGB_888",
	[MOAIImage.COLOR_FMT_RGB_565] = "COLOR_FMT_RGB_565",
	[MOAIImage.COLOR_FMT_RGBA_5551] = "COLOR_FMT_RGBA_5551",
	[MOAIImage.COLOR_FMT_RGBA_4444] = "COLOR_FMT_RGBA_4444",
	[MOAIImage.COLOR_FMT_RGBA_8888] = "COLOR_FMT_RGBA_8888",
}
local bits = {
	[MOAIImage.COLOR_FMT_A_8] = 1,
	[MOAIImage.COLOR_FMT_RGB_888] = 3,
	[MOAIImage.COLOR_FMT_RGB_565] = 2,
	[MOAIImage.COLOR_FMT_RGBA_5551] = 2,
	[MOAIImage.COLOR_FMT_RGBA_4444] = 2,
	[MOAIImage.COLOR_FMT_RGBA_8888] = 4,
}
function count(path, fileFilter, dirFilter, depth)
	local list = {}
	for_every(path, fileFilter, function(file)
		if file:find(".png$") or file:find(".jpg$") then
			local image = MOAIImage.new()
			image:load(file)
			local w, h = image:getSize()
			local b = bits[image:getFormat()]
			local n = name[image:getFormat()]
			local t = {
				file = file,
				size = w * h * b,
				form = n,
			}
			table.insert(list, t)
		end
	end)
	table.sort(list, function(a, b)
		return a.size > b.size
	end)
	local size = 0
	local MB = 1024 * 1024
	for i, v in ipairs(list) do
		size = size + v.size
		print(string.format("[%.2f MB] %s : %s", v.size / MB, v.file, v.form))
	end
	print(path)
	print(string.format("------------- %d, %dMB ----------", #list, size / MB))
end

count("../client/lua/img/pet")
count("../client/lua/img/monster")
count("../client/lua/img/panel")
count("../client/lua/img")