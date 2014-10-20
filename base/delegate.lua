
local delegate = {}

function delegate.new()
	local self = {
		_handles = {},
		register = delegate.register,
		invoke = delegate.invoke,
	}
	return self
end

local function _handle_cancel(self)
	self._parent._handles[self] = nil
end

function delegate:register(cb)
	local handle = {
		_parent = self,
		cancel = _handle_cancel,
		cb = cb,
	}
	self._handles[handle] = handle
	return handle
end

function delegate:invoke(...)
	local tb = table.copy(self._handles)
	for k, v in pairs(tb) do
		local ok, err = pcall(v.cb, ...)
		if not ok then
			print("ERROR: " .. debug.getfuncinfo(v) .. ": " .. tostring(err))
		end
	end
end

return delegate