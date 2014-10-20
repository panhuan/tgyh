
function rename2atlas(path)
	for_every(path, nil, function(file)
		local filename = string.gsub(file, "(.*) %((.+)%)(.png)$", "%1%2%3")
		if not filename then
			print("filename is not matched!", file)
			return
		end
		local cmd = string.format("move %q %q", file:gsub("/", "\\"), filename:gsub("/", "\\"))
		print(cmd)
		os.execute (cmd)
	end)
end

function rename(path, pat, str)
	for_every(path, nil, function(file)
		file = file:gsub("/", "\\")
		if file:find(pat) then
			local cmd = string.format("move %q %q", file, file:gsub(pat, str))
			print(cmd)
			os.execute (cmd)
		end
	end)
end