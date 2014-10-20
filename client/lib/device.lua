require("moai.compat")
local file = require("file")
local device_profile = require("device.profile")
local device = {}
device.hasPVR = false
device.hasOGG = false
device.IDIOM_HANDSET = "handset"
device.IDIOM_TABLET = "tablet"
device.ASSET_MODE_LO = 1
device.ASSET_MODE_HI = 2
device.ASSET_MODE_X_HI = 3
device.FILL_RATE_LO = 1
device.FILL_RATE_HI = 2
device.CPU_LO = 1
device.CPU_HI = 2
device.OS_IOS = "ios"
device.OS_ANDROID = "android"
device.RAM_LO = 1
device.RAM_HI = 2
device.RAM_X_HI = 3

device.PLATFORM_IOS = "ios"
device.PLATFORM_IOS_TESTFLIGHT = "ios_testflight"
device.PLATFORM_ANDROID_GOOGLE = "android_google"
device.PLATFORM_ANDROID_AMAZON = "android_amazon"
device.PLATFORM_ANDROID_360 = "android_360"
device.PLATFORM_OSX_APPSTORE = "osx_store"
device.PLATFORM_OSX = "osx"
device.PLATFORM_OSX_STEAM = "osx_steam"
device.PLATFORM_WINDOWS = "windows"
device.PLATFORM_WINDOWS_STEAM = "windows_steam"
device.PLATFORM_LINUX = "linux"
device.PLATFORM_UNKNOWN = "unknown"

device.asset_rez = device.ASSET_MODE_LO

local profile
local profileName = os.getenv("MOAI_DEVICE_PROFILE")
if profileName ~= nil then
	profile = require("device.profile").get(profileName:lower())
	print("Using device profile: " .. profileName)
elseif os.getenv("SIMULATE_SCREEN_SIZE") then
	profileName = "manual"
	profile = {
		width = tonumber(os.getenv("SIMULATE_SCREEN_W")),
		height = tonumber(os.getenv("SIMULATE_SCREEN_H"))
	}
	print("Using screen size: " .. profile.width .. "x" .. profile.height)
elseif os.getenv("DEVICE_WIDTH") then
	profileName = "manual"
	profile = {
		width = tonumber(os.getenv("DEVICE_WIDTH")),
		height = tonumber(os.getenv("DEVICE_HEIGHT"))
	}
	print("Using device size: " .. profile.width .. "x" .. profile.height)
end

local platform
if os.getenv("DEVICE_PLATFORM") then
	platform = os.getenv("DEVICE_PLATFORM")
else
	platform = MOAIEnvironment.getDevModel()
end

if profile == nil then
	profile = {}
	profile.width, profile.height = MOAIEnvironment.getDeviceSize()
	profile.dpi = MOAIEnvironment.getDeviceDpi()
	print("Found device size: ", profile.width, profile.height)
elseif os.getenv("MOAI_DEVICE_PORTRAIT") and profile.width > profile.height then
	profile.width, profile.height = profile.height, profile.width
end

device.width, device.height = profile.width, profile.height
if device.width <= 0 then
	print("Could not find default width, use 1024")
	device.width = 1024
end

if device.height <= 0 then
	print("Could not find default height, use 768")
	device.height = 768
end

local shortestSide = device.width
if device.height < device.width then
	shortestSide = device.height
end

if false and shortestSide >= 720 then
	device.ui_scale = 720 / shortestSide
	device.ui_idiom = device.IDIOM_TABLET
	if shortestSide >= 1536 then
		device.ui_assetrez = device.ASSET_MODE_X_HI
	else
		device.ui_assetrez = device.ASSET_MODE_HI
		if os.getenv("DEVICE_RETINA") then
			device.ui_assetrez = device.ASSET_MODE_X_HI
		end
	end
else
	device.ui_scale = 640 / shortestSide
	device.ui_idiom = device.IDIOM_HANDSET
	if shortestSide <= 320 then
		device.ui_assetrez = device.ASSET_MODE_LO
		if os.getenv("DEVICE_RETINA") then
			device.ui_assetrez = device.ASSET_MODE_HI
		end
	else
		device.ui_assetrez = device.ASSET_MODE_HI
	end
end

device.ui_width = device.width * device.ui_scale
device.ui_height = device.height * device.ui_scale
device.fill = device.FILL_RATE_HI
device.cpu = device.CPU_HI
local version = MOAIEnvironment.getAppVersion()
local osbrand = MOAIEnvironment.getOSBrand()
if osbrand == MOAIEnvironment.OS_BRAND_IOS then
	do
		local iosProfile = device_profile.getIOSProfile(MOAIEnvironment.getDevModel():lower())
		device.hasPVR = true
		device.hasCAF = true
		profile.dpi = iosProfile.dpi
		device.fill = iosProfile.fill
		device.cpu = iosProfile.cpu
		device.perf = iosProfile.perf
		device.displayName = iosProfile.name
		device.os = device.OS_IOS
		device.platform = device.PLATFORM_IOS
	end
elseif osbrand == MOAIEnvironment.OS_BRAND_ANDROID then
	profile.dpi = MOAIEnvironment.getDeviceDpi()
	device.os = device.OS_ANDROID
	device.displayName = "Android"
	if device.ui_assetrez == device.ASSET_MODE_HI then
		if MOAIEnvironment.numProcessors > 2 then
			device.cpu = device.CPU_HI
			device.fill = device.FILL_RATE_HI
		else
			device.cpu = device.CPU_LO
			device.fill = device.FILL_RATE_LO
		end
	else
		device.cpu = device.CPU_LO
		device.perf = device.CPU_LO
		device.fill = device.FILL_RATE_LO
	end
	
	device.platform = MOAIEnvironment.devPlatform or device.PLATFORM_UNKNOWN
else
	device.platform = device.PLATFORM_UNKNOWN
end

if os.getenv("MOAI_UDID") then
	device.udid = os.getenv("MOAI_UDID")
else
	device.udid = MOAIEnvironment.getUDID()
end

local appId = MOAIEnvironment.getAppID()
if device.platform == device.PLATFORM_IOS then
	device.storeURL = "itms-apps://itunes.com/apps/" .. appId
elseif device.platform == device.PLATFORM_ANDROID_GOOGLE then
	device.storeURL = "market://details?id=" .. appId
elseif device.platform == device.PLATFORM_ANDROID_AMAZON then
	device.storeURL = "amzn://apps/android?p=" .. appId
else
	device.storeURL = "http://www.harebrained-schemes.com?appId=" .. appId .. "&store=1&os=" .. osbrand
end

device.dpi = profile.dpi or 132
device.ui_dpi = device.dpi * device.ui_scale
function device:size()
	return self.width, self.height
end

local cacheDir, docsDir
if MOAIApp ~= nil and MOAIApp.getDirectoryInDomain then
	docsDir = MOAIApp.getDirectoryInDomain(MOAIApp.DOMAIN_DOCUMENTS)
	cacheDir = MOAIApp.getDirectoryInDomain(MOAIApp.DOMAIN_CACHES)
else
	docsDir = MOAIEnvironment.getDocumentDirectory()
	cacheDir = MOAIEnvironment.getCacheDirectory()
end

local function _makePath(basePath, path, affirmPath)
	local p
	if path == nil then
		p = basePath
	else
		p = string.format("%s/%s", basePath, path)
	end
	if affirmPath ~= false and not file.exists(p) then
		file.mkdir(p)
	end
	return p
end

function device.getDocumentsPath(path, affirmPath)
	return _makePath(docsDir, path, affirmPath)
end

function device.getCachePath(path, affirmPath)
	return _makePath(cacheDir, path, affirmPath)
end

function device.getConnectionType()
	if MOAIEnvironment.connectionType == MOAIEnvironment.CONNECTION_TYPE_NONE then
		return nil
	elseif MOAIEnvironment.connectionType == MOAIEnvironment.CONNECTION_TYPE_WIFI then
		return "wifi"
	elseif MOAIEnvironment.connectionType == MOAIEnvironment.CONNECTION_TYPE_WWAN then
		return "wwan"
	end
end

function device.screenshot(path, cb)
	local img = MOAIImage.new()
	MOAIGfxDevice.getFrameBuffer():grabNextFrame(img, function()
		img:writePNG(path)
		if cb then
			cb(img)
		end
	end)
end

return device
