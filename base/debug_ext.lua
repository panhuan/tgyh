
function debug.traceall(level)
	local ret = ""
	level = level or 2
	ret = ret .. "stack traceback:\n"
	while true do	
		--get stack info	
		local info = debug.getinfo(level, "Sln")
		if not info then
			break
		end
		
		if info.what == "C" then	-- C function	
			ret = ret .. tostring(level) .. "\tC function\n"
		else						-- Lua function	
			ret = ret .. string.format("\t[%s]:%d in function '%s'\n", info.short_src, info.currentline, info.name or "?")
		end
		--get local vars	
		local i = 1
		while true do	
			local name, value = debug.getlocal(level, i)
			if not name then
				break
			end
			ret = ret .. "\t\t" .. name .. "=" .. toprettystring(value) .. "\n"
			i = i + 1
		end
		level = level + 1
	end
	return ret
end

function debug.getfuncinfo(f)
	assert(type(f) == "function")
	
	local t = debug.getinfo(f, "Sln")
	local s = tostring(f)
	if t.what == "C" then
		return string.format("[C] %s '%s'", s, t.name)
	end
	return string.format("[%s] %s '%s' %s:%d", t.what, s, t.name or "*", t.source, t.linedefined)
end

function debug.getlocinfo(n)
	local t = debug.getinfo((n or 1) + 1, "Sln")
	if t.what == "C" then
		return string.format("[C] function '%s'", t.name)
	end
	return string.format("[%s] %s:%d '%s'", t.what, t.source, t.currentline, t.name or "*")
end