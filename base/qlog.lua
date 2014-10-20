local qlog = {}
local format = string.format
local write = io.write
local flush = io.flush
local function _log(level, name, ...)
	if name ~= nil then
		print(format("%s %-5s [%s] ", os.date("%Y-%m-%d %H:%M:%S"), level, name), ...)
	else
		print(format("%s %-5s ", os.date("%Y-%m-%d %H:%M:%S"), level), ...)
	end
	flush()
end
local function _newlogger(name)
	return {
		debug = function(...)
			return _log("DEBUG", name, ...)
		end,
		info = function(...)
			return _log("INFO", name, ...)
		end,
		warn = function(...)
			return _log("WARN", name, ...)
		end,
		error = function(...)
			return _log("ERROR", name, ...)
		end,
		fatal = function(...)
			_log("FATAL", name, ...)
			os.exit(1)
		end
	}
end
local _rootlogger = _newlogger()
local _loggers = setmetatable({}, {
	__mode = "v",
	__index = function(t, k)
		if k == nil then
			return _rootlogger
		end
		local l = rawget(t, k)
		if l == nil then
			l = _newlogger(k)
			t[k] = l
		end
		return l
	end
})
function qlog.debug(...)
	return _rootlogger.debug(...)
end
function qlog.info(...)
	return _rootlogger.info(...)
end
function qlog.warn(...)
	return _rootlogger.warn(...)
end
function qlog.error(...)
	return _rootlogger.error(...)
end
function qlog.fatal(...)
	return _rootlogger.fatal(...)
end
function qlog.exists(name)
	return rawget(_loggers, name) ~= nil
end
function qlog.logger(name)
	return _loggers[name]
end
function qlog.loggers(name)
	local l = _loggers[name]
	return l.debug, l.info, l.warn, l.error, l.fatal
end
return qlog
