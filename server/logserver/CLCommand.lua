
local qlog = require "qlog"
local LogDB = require "LogDB"
local CLCommand = {}

function CLCommand.writeActLog(c, guid, id, level, timeStamp, key, value, userdata)
	LogDB:writeActLog(guid, id, level, timeStamp, key, value, userdata)
	return true
end

return CLCommand