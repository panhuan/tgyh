local metatable = require("metatable")
local compat = {}
compat.mock = {}
local _G = _G

local function mock_if_need(name)
	if _G[name] == nil then
		compat.mock[name] = true
		_G[name] = require("moai.mock." .. name)
	end
end

mock_if_need("MOAISim")
mock_if_need("MOAIApp")
mock_if_need("MOAIInputMgr")
mock_if_need("MOAIHttpTask")
mock_if_need("MOAIThread")
mock_if_need("MOAIEnvironment")
mock_if_need("MOAIAction")
mock_if_need("MOAIActionMgr")
mock_if_need("MOAITouchSensor")

MOAI_VERSION_1_0 = 10000
MOAI_VERSION = MOAI_VERSION_1_0

if _G.os ~= nil then
	if MOAI_VERSION >= MOAI_VERSION_1_0 then
		_G.os.clock = _G.MOAISim.getDeviceTime
	else
		_G.os.clock = _G.MOAISim.getTime
	end
end

return compat
