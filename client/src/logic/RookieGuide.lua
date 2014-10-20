
local eventhub = require "eventhub"
local UserData = require "UserData"
local RookiePanel = require "windows.RookiePanel"


local RookieGuide = {}


function RookieGuide:init()
	eventhub.bind("ROOKIE_EVENT", "ROOKIE_TRIGGER", function(name)
		self:_start(name)
	end)
	eventhub.bind("ROOKIE_EVENT", "ROOKIE_END", function(name)
		self:_end(name)
	end)
	eventhub.bind("ROOKIE_EVENT", "ROOKIE_END", function(name)
		self:_end(name)
	end)
end

function RookieGuide:_start(name)
	if self._triggerName then
		return
	end

	if not UserData:getRookieGuide(name) then
		if RookiePanel._tbFun[name] then
			self._triggerName = name
			RookiePanel._tbFun[name](RookiePanel)
		end
	end
end

function RookieGuide:_end(name)
	if self._triggerName and self._triggerName == name and not UserData:getRookieGuide(name) then
		UserData:setRookieGuide(name)
		self._triggerName = nil
	end
end

return RookieGuide