
require "string_ext"

local versionutil = {}
function versionutil.split(ver)
	local major, minor, patch = string.split(ver, "%.")
	return tonumber(major), tonumber(minor), tonumber(patch)
end

function versionutil.numeric(ver)
	local major, minor, patch = versionutil.split(ver)
	return major * 1000000 + minor * 1000 + patch
end
return versionutil
