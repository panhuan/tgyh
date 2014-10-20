
local deviceevent = {}

function deviceevent:init()
	MOAISim.setListener(MOAISim.EVENT_FINALIZE, function() deviceevent.onFinalize() end)
	MOAISim.setListener(MOAISim.EVENT_PAUSE, function() deviceevent.onPause() end)
	MOAISim.setListener(MOAISim.EVENT_RESUME, function() deviceevent.onResume() end)
	
	if MOAIAppAndroid then
		MOAIAppAndroid.setListener(MOAIAppAndroid.BACK_BUTTON_PRESSED, function() deviceevent.onBackBtnPressed() end)
	end
end

function deviceevent.onFinalize()
end

function deviceevent.onPause()
	if deviceevent.onPauseCallback then
		deviceevent.onPauseCallback()
	end
end

function deviceevent.onResume()
	if deviceevent.onResumeCallback then
		deviceevent.onResumeCallback()
	end
end

function deviceevent.onBackBtnPressed()
	if deviceevent.onBackBtnPressedCallback then
		deviceevent.onBackBtnPressedCallback()
	end
end

return deviceevent
