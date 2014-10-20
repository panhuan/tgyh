
local eventhub = require "eventhub"
local ActLog = require "ActLog"
local Buy = require "settings.Buy"
local Player = require "logic.Player"

SMSPay = {}
function SMSPay:init()
	eventhub.bind("SYSTEM_EVENT", "PLAYER_PAY", function(idx)
		Player:smsPay(idx)
		ActLog:smsPayBegin(idx)
	end)
end


return SMSPay