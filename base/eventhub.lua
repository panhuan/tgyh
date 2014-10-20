
local eventhub = {}
local _debug, _info, _warn, _error = require("qlog").loggers("eventhub")
local _weekRefs = setmetatable({}, {__mode = "k"})
local _strongRefs = {}

function eventhub.define(obj, weeked)
	assert(type(obj) == "string", "expect string, got: "..tostring(obj))
	if not weeked then
		_strongRefs[obj] = {}
	else
		_weekRefs[obj] = {}
	end
end

function eventhub.register(obj, event)
	local bindings = _weekRefs[obj] or _strongRefs[obj]
	bindings[event] = {}
end

function eventhub.bind(obj, event, callback)
	assert(type(callback) == "function", "invalid callback: " .. tostring(callback))
	local bindings = _weekRefs[obj] or _strongRefs[obj]
	assert(bindings, "undefined group: "..tostring(obj))
	local callbacks = bindings[event]
	assert(callbacks, "unregistered event: "..tostring(event))
	table.insert(callbacks, callback)	
	return callback
end

function eventhub.unbind(obj, event, callback)
	
	if event == nil then
		_weekRefs[obj] = nil
	else
		local bindings = _weekRefs[obj] or _strongRefs[obj]
		if bindings ~= nil then
			if callback then
				local callbacks = bindings[event]
				for i = 1, #callbacks do
					if callbacks[i] == callback then
						table.remove(callbacks, i)
						return
					end
				end
			else
				bindings[event] = nil
				if next(bindings) == nil then
					_weekRefs[obj] = nil
				end
			end
		end
	end
end

function eventhub.fire(obj, event, ...)
	if _debug then
		_debug("[" .. tostring(obj) .. "] <- " .. tostring(event), ...)
	end
	local bindings = _weekRefs[obj] or _strongRefs[obj]
	if bindings == nil then
		return
	end
	local callbacks = bindings[event]
	if callbacks == nil then
		return
	end
	
	for i, v in pairs(callbacks) do
		local ok, err = pcall(v, ...)
		if not ok then
			print("ERROR: " .. debug.getfuncinfo(v) .. ": " .. tostring(err))
		end
	end
end

return eventhub
