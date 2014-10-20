
_WINDOWS = MOAIEnvironment.osBrand ~= MOAIEnvironment.OS_BRAND_ANDROID and
	MOAIEnvironment.osBrand ~= MOAIEnvironment.OS_BRAND_IOS
_DEBUG = false
_DEBUG_INFO = false
_DEBUG_LEAK = false

function MOAIEnvironment.getDevModel()
	return MOAIEnvironment.devModel
end

function MOAIEnvironment.getAppVersion()
	return MOAIEnvironment.appVersion
end

function MOAIEnvironment.getUDID()
	return MOAIEnvironment.udid
end

function MOAIEnvironment.getOSBrand()
	return MOAIEnvironment.osBrand
end

function MOAIEnvironment.getDocumentDirectory()
	return MOAIEnvironment.documentDirectory or "docs"
end

function MOAIEnvironment.getCacheDirectory()
	return MOAIEnvironment.cacheDirectory or "cache"
end

function MOAIEnvironment.getAppID()
	return MOAIEnvironment.appID or "myAppID"
end

local macAddress = MOAIEnvironment.getMACAddress()
function MOAIEnvironment.getMACAddress()
	return MOAIEnvironment.macAddress or macAddress
end

if _WINDOWS then
	function MOAIEnvironment.getDeviceSize()
		return 320, 480
	end

	function MOAIEnvironment.getDeviceDpi()
		return 132
	end
	MOAIEnvironment.documentDirectory = nil
	MOAIEnvironment.connectionType = MOAIEnvironment.CONNECTION_TYPE_WIFI
else
	function MOAIEnvironment.getDeviceSize()
		return MOAIGfxDevice.getViewSize()
	end

	function MOAIEnvironment.getDeviceDpi()
		return MOAIEnvironment.screenDpi
	end
end

function print(...)
	local args = {...}
	local argc = select("#", ...)

	local output = tostring(args[1])
	for i = 2, argc do
		output = output.." "..tostring(args[i])
	end

	MOAILogMgr.log(output.."\n")
end

loadstring = loadstring or load
package.loaders = package.loaders or package.searchers
local docDir = MOAIEnvironment.getDocumentDirectory()
local cacheDir = MOAIEnvironment.getCacheDirectory()
local cwd = MOAIFileSystem.getWorkingDirectory()
print("--------------------------------------")
print("-- document directory: "..docDir)
print("-- cache directory: "..cacheDir)
print("-- working directory: "..cwd)
print("--------------------------------------")

MOAIFileSystem.affirmPath(cacheDir)
debug.logfile = "game "..os.date("%Y-%m-%d %H-%M-%S")..".log"
local path = cacheDir.."/"..debug.logfile
MOAILogMgr.openFile(path)
print("log file: "..path)
package.path = docDir.."/?.lua;../?.lua;./?.lua;../lib/?.lua;../src/?.lua;"
pcall(dofile, cacheDir.."/config.lua")

if _DEBUG then
	local lastdate
	function dotest()
		local file = cacheDir.."/test.lua"
		local tb = lfs.attributes(file)
		if tb and lastdate ~= tb.modification then
			lastdate = tb.modification
			local ok, err = pcall(dofile, file)
			print(string.format("[TEST]", cmd), err and err or "ok")
		end
	end
	package.path = package.path.."../../base/?.lua;../../base/dbgp/?.lua;"
	MOAISim.setHistogramEnabled(true)
	MOAISim.setLeakTrackingEnabled(true)
	local crypto = require "crypto"
	crypto.lock(false)
end

local pakutil = require "pakutil"
pakutil.path = docDir.."/pak/?;"..cwd.."../pak/?;"
pakutil.load("base")
pakutil.load("lib")
pakutil.load("src")

require "base_ext"
require "moai.extend"
require "constants"

SIGNATURES = {
	qihoo = "308204273082030fa003020102020400e011ef300d06092a864886f70d01010b05003081c2310b300906035504061302636e3112301006035504080c09e4b88ae6b5b7e5b8823112301006035504070c09e4b88ae6b5b7e5b882312d302b060355040a0c24e4b88ae6b5b7e8b5a4e99c84e7bd91e7bb9ce7a791e68a80e69c89e99990e585ace58fb8312d302b060355040b0c24e4b88ae6b5b7e8b5a4e99c84e7bd91e7bb9ce7a791e68a80e69c89e99990e585ace58fb8312d302b06035504030c24e4b88ae6b5b7e8b5a4e99c84e7bd91e7bb9ce7a791e68a80e69c89e99990e585ace58fb83020170d3134303731393033333531395a180f33303133313131393033333531395a3081c2310b300906035504061302636e3112301006035504080c09e4b88ae6b5b7e5b8823112301006035504070c09e4b88ae6b5b7e5b882312d302b060355040a0c24e4b88ae6b5b7e8b5a4e99c84e7bd91e7bb9ce7a791e68a80e69c89e99990e585ace58fb8312d302b060355040b0c24e4b88ae6b5b7e8b5a4e99c84e7bd91e7bb9ce7a791e68a80e69c89e99990e585ace58fb8312d302b06035504030c24e4b88ae6b5b7e8b5a4e99c84e7bd91e7bb9ce7a791e68a80e69c89e99990e585ace58fb830820122300d06092a864886f70d01010105000382010f003082010a0282010100a4f655d4565a9034a7555518ee92c7eaf72ae15c25b40bad9b7c1762f1b5b27da2fed43aa78623ecb2178aeb45c41df564f1a2b2c9b0cb416f3257b522c9188c57d91d051cbc842e38cc4abea6146df4edf03e07d6a6c2c7f0f9ada388f18a535605332340b810884ae4ef39461699a6925e683bb81dd1c2803d31325c732298ac9f20a3270711fa91692df17fac38785efa3af5b4be464ca2310c39fe31dd9195ae6c04139a424c709e2ddbe22642df562ea398c37ce3f2bb4a394ad63b40edb096eb3ebc61528e70d14460bdc4acca39f322c7fa9ec0a6913ff39363f2e7ee4631ea306a5be94dcde334e8babe3750f599b45bd5f177d8e0a654b954bdbc9b0203010001a321301f301d0603551d0e041604146f556f781246ef0421c0d013427f81f6efa2eeab300d06092a864886f70d01010b050003820101006be40703c779058bf6bb07ccd96188eb66cfa58eba39250367fbac845a44bd44c5845e6864b2adc87c144eae814fad6fff8e408b2bcf27df23f4a631648d5f7675e87b32245c224cb76d73647d42cdf2bbc91ca804fcbc0af58125647a5a5415abf722077f3c7feef4915b9f39f566a604cf1c109867334784a0d9551b67f9cdb39b20fec43a8614ed2aa7e06248f27cac54646d7fb7966f73f9206e7f8e2dfc751c7c74cb7dfde5285f04e085707cf35994bdf88756beb4cfef8ad9b0b7d34490d809e642f9bca58a39763249f14287e057f5e4e09dfdf894f3f4708a8900991de033f0c621d6970c744bbd252e8da5a39fdf4a2f4bab56185873bda81a3f73",
	chuangwei_mm = "30820245308201b0a003020102020413f5b1eb300b06092a864886f70d0101053033310b300906035504061302434e3124302206035504030c1b434d4341206170706c69636174696f6e207369676e696e67204341301e170d3134303232303033323135365a170d3334303232303033323135365a303b310b300906035504061302434e311a30180603550405131132303134303232303131313933373234323110300e06035504030c073339303130383330819d300b06092a864886f70d01010103818d0030818902818100869b85c81e647935a9443a1c3d23509f7bb266ae49c55ce5df192419adeb1049379473d8dc9fdd06587900d9766aa79b6b66ff71392cc65bb3f1d42c14c43fbc9c30f8bdf34bdbb86add4a1768abf74afcc3dc90afbc73d2e6793d39a5ed4ed2f84f501edec9876c7948f91538a0423f3180d4a9bc8ecee5771948a997a8903d0203010001a364306230130603551d25040c300a06082b06010505070303301f0603551d230418301680149721b225cce93fd2a653684196e6577167dbb28d300b0603551d0f040403020780301d0603551d0e0416041423e9c6e1c98b70d994d6ba355f298e9a499cf95b300b06092a864886f70d01010503818100044c82971f1416e8cf01db9656808af581107b3ed83ea5ba5ba5532d5af1c4717c394a4c4964f6d83094bd9200b7ed75510006aca53587dd3d78360f20f366fdf400a2086a58dcb5324babc12d8c543442c9b5746d9a3165e4787dad3c402f6c77181567ae380fc9df61ea7211a2d7bb31ec3f9ac7836cb0bb8f50cba1d1da7e",
	chuangwei = "3082041930820301a0030201020204686e91c8300d06092a864886f70d01010b05003081bb310b300906035504061302434e310e300c060355040813054368696e61310f300d06035504070c06e4b88ae6b5b7312d302b060355040a0c24e4b88ae6b5b7e7a390e6a193e7bd91e7bb9ce7a791e68a80e69c89e99990e585ace58fb8312d302b060355040b0c24e4b88ae6b5b7e7a390e6a193e7bd91e7bb9ce7a791e68a80e69c89e99990e585ace58fb8312d302b06035504030c24e4b88ae6b5b7e7a390e6a193e7bd91e7bb9ce7a791e68a80e69c89e99990e585ace58fb83020170d3134303831393033323233335a180f33303133313232303033323233335a3081bb310b300906035504061302434e310e300c060355040813054368696e61310f300d06035504070c06e4b88ae6b5b7312d302b060355040a0c24e4b88ae6b5b7e7a390e6a193e7bd91e7bb9ce7a791e68a80e69c89e99990e585ace58fb8312d302b060355040b0c24e4b88ae6b5b7e7a390e6a193e7bd91e7bb9ce7a791e68a80e69c89e99990e585ace58fb8312d302b06035504030c24e4b88ae6b5b7e7a390e6a193e7bd91e7bb9ce7a791e68a80e69c89e99990e585ace58fb830820122300d06092a864886f70d01010105000382010f003082010a0282010100f9e2bef38054cdbf08cd9fd59ea5a5b1eb9f4c67a7b8ff7445162e239e92ae1ec22f318da81482b3b5d140f8b95cc57cbbdf0bbe9a0828d696661ee602042bd364e6cc012b7cc46797d196b9dca6490a988fb507d66b5dbd0ab3203977cfe47e9d9e5eba31ede8cfe360e9b9985a835d8384c668bac59fcc588566f9b322798ae280aafe01886ec39afb6c4ef5fa316c0c86148271e333d1a54751555c29d26a2093d0b89e3a10c52968f3cc3b938d6169837b3ebac0100086f55f272ce02308daeda2c60519a534e7079538e2b04b3c7eef5c9f3e8b173813e12520f46d6011515b44ebdbe21b1d0a41991e24ae060dbfa97cddea66d80e405a56a82f0f73170203010001a321301f301d0603551d0e041604140817a3970fe8d89cd0aa92af05d14c098a37f43e300d06092a864886f70d01010b0500038201010063d6c3b8d04ca80020f0414441522a29ea95fb5eb50350bfc4de9b2df967cd02534ff7dc77b01e7496ed834d61d65ffbf75cd30fa05ef1b47fca2486b0cf8856c645a24d869000b539a956dc86e38b0d9173e560a1b86d085dc0a125823b5a481fc6d9a213d4820670d9e6f256d54520dfbf38083113628e3d5284c5392f2a020b4fd8b9c66692d052210ae1311cd709021f3b4eda5b7982db8257a300f82b7a3d79d51451979bad79c0471cb7793d7669408f433d71421be3237df33f8f3fc0420238d8057c641d017516be9fa5c83350779ecd1a97c9b5c2c24b155b6b235684d28a58367d979f040cd922c0c3a475c7c95d0f347a96dd889df61a20486236",
}

local key = "54C319E9A6CDD5B78AD771FA595CB897"
local crypto = require "crypto"
local signature = MOAIAppAndroid.getSignature()
local sha = crypto.hmac.digest("sha1", signature, key)
local die = os.exit

local ok = false
for k, v in pairs(SIGNATURES) do
	if signature == v then
		printf("========= this app is '%s' ==========", k)
		ok = true
	end
end

if not ok then
	printf("sha:", sha)
	printf("signature:", #signature, signature)
	die()
end