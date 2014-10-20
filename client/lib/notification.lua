
local notification = {}

function notification.setTags(...)
	local t = {...}
	if MOAIJavaVM then
		MOAIJavaVM.runJava("JPush.setTags," .. table.concat(t, ","))
	end
end

function notification.setAlias(name)
	if MOAIJavaVM then
		MOAIJavaVM.runJava("JPush.setAlias," .. name)
	end
end

function notification.push(text)
	if MOAIJavaVM then
		MOAIJavaVM.runJava("notification" .. text)
	end
end

return notification