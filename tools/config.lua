
package.path = "?.lua;libs/?.lua;../base/?.lua;../client/lib/?.lua"
package.cpath = "clibs/?.dll"

require "base_ext"

local lfs = require "lfs"

function for_every(path, fileFilter, fileCb, dirFilter, dirCb, depth)
	local mode = lfs.attributes(path, "mode")
	if mode == "file" then
		if fileCb then
			if not fileFilter or path:find(fileFilter) then
				fileCb(path)
			end
		end
		return;
	end
	
	for entry in lfs.dir(path) do
		if entry ~= "." and entry ~= ".." then
			local subpath = path.."/"..entry
			local mode = lfs.attributes(subpath, "mode")
			if mode == "file" then
				if fileCb then
					if not fileFilter or subpath:find(fileFilter) then
						fileCb(subpath)
					end
				end
			elseif mode == "directory" then
				if dirCb then
					if not dirFilter or subpath:find(dirFilter) then
						dirCb(subpath)
					end
				end
				if depth then
					if depth > 1 then
						for_every(subpath, fileFilter, fileCb, dirFilter, dirCb, depth - 1);
					end
				else
					for_every(subpath, fileFilter, fileCb, dirFilter, dirCb, nil)
				end
			end
		end
	end
end