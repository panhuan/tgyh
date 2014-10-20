
local device = require("device")
ACU_BUNDLE_ID = "com.modou.kaixin"
ANDROID_PRODUCT_ID = "com.modou.kaixin"
VERSION = MOAIEnvironment.getAppVersion()
if VERSION == nil or VERSION == "UNKNOWN" then
  do
    local versioned
    local prop = io.open("../project.properties", "r")
    if prop then
      for lines in prop:lines() do
        if lines:find("bundle.version.short=") then
          VERSION = lines:match("%s*=(.+)")
          versioned = true
          break
        end
      end
      prop:close()
    end
    if not versioned then
      VERSION = "dev"
      ACU_VERSION = "dev"
    else
      ACU_VERSION = VERSION:match("^(%d+%.%d+)") .. "dev"
    end
  end
else
  ACU_VERSION = VERSION:match("^(%d+%.%d+)")
  local channel = VERSION:match("%(([^%)]+)%)$")
  if channel ~= nil then
    ACU_VERSION = ACU_VERSION .. channel
  end
end
assert(ACU_BUNDLE_ID ~= "UNKNOWN" and ACU_BUNDLE_ID ~= nil, "invalid bundle id")
print("\tAppId:      ", ACU_BUNDLE_ID)
print("\tAppVersion: ", VERSION)
print("\tACU:        ", ACU_VERSION)
APPCACHE_URL = "http://www.kaixinol.com/" .. ACU_BUNDLE_ID .. "/" .. ACU_VERSION .. "/manifest.jws"
DISPLAY_DEBUG_INFO = false
DEBUG_STORE = false
DEBUG_PHYSICS = false
DEBUG_CONSTRUCTION_SPAWN = false
SIMULATE_LOW_FILL = false
SIMULATE_LOW_CPU = false
if SIMULATE_LOW_FILL then
  device.fill = device.FILL_RATE_LO
end
if SIMULATE_LOW_CPU then
  device.cpu = device.CPU_LO
end
KB = 1024
MB = KB * KB
device.ram = device.RAM_LO
if MOAIEnvironment.osBrand ~= MOAIEnvironment.OS_BRAND_WINDOWS then
	local f = io.open("/proc/meminfo", "r")
	local meminfo = f:read("*all")
	print("-------------- MEMINFO -------------")
	print(meminfo)
	local a, b, totalMem = meminfo:find("MemTotal:[ \t]*(%d+)")
	totalMem = tonumber(totalMem)
	if totalMem then
		if totalMem > 768 * KB then
			device.ram = device.RAM_X_HI
		elseif totalMem > 512 * KB then
			device.ram = device.RAM_HI
		end
	end
	print("---- TOTAL RAM:", totalMem)
end
print("---- RAM LEVEL:", device.ram)

PET_COUNT = 5
PET_MAX_LEVEL = 30
VS_LIST = VS_LIST or {
	"http://vs1.kaixinol.com",
	"http://vs2.kaixinol.com",
	"http://vs3.kaixinol.com",
	"http://vs4.kaixinol.com",
	"http://vs5.kaixinol.com",
	"http://vs6.kaixinol.com",
	"http://vs7.kaixinol.com",
	"http://vs8.kaixinol.com",
	"http://vs9.kaixinol.com",
}
WS_LIST = WS_LIST or {
	"www.a1.kaixinol.com",
	"www.a2.kaixinol.com",
	"www.a3.kaixinol.com",
	"www.a4.kaixinol.com",
	"www.a5.kaixinol.com",
	"www.a6.kaixinol.com",
	"www.a7.kaixinol.com",
	"www.a8.kaixinol.com",
	"www.a9.kaixinol.com",
}

APP_VERSION = "1.4.0"
VERSION_OPTION = "SMSPay|mini"
-- VERSION_OPTION = "Qihoo|mini"

