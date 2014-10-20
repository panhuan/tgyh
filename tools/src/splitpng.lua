

function splitpng(file, x, y, w, h)
	local image = MOAIImage.new()
	image:load(file)
	local _, _, name = file:find("([^/\.]+).png")
	
	for i = 1, y do
		for j = 1, x do
			local out = MOAIImage.new()
			out:init(w, h, MOAIImage.COLOR_FMT_RGBA_8888)
			out:copyRect(image, (j - 1) * w, (i - 1) * h, j * w, i * h, 0, 0, w, h)
			out:writePNG(string.format("out/%s_%d_%d.png", name, i, j))
		end
	end
end

-- splitpng("entities.png", 8, 8, 1024/8, 1024/8)
splitpng("out/8_5.png", 2, 2, 16, 32)