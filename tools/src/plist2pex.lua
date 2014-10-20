
require "LuaXml"

function node2table(xml)
	return table.clone(xml, true)
end

local plist2value = {
	["string"]	= function(v) return v[1] end,
	["integer"]	= function(v) return tonumber(v[1]) end,
	["real"]	= function(v) return tonumber(v[1]) end,
	["true"]	= function(v) return true end,
	["false"]	= function(v) return false end,
	["data"]	= function(v) return v[1] end,
	["array"]	= function(v) return array2table(v) end,
	["dict"]	= function(v) return dict2table(v) end,
}

local plist2string = {
	["string"]	= function(v) return v[1] end,
	["integer"]	= function(v) return v[1] end,
	["real"]	= function(v) return v[1] end,
	["true"]	= function(v) return v[1] end,
	["false"]	= function(v) return v[1] end,
	["data"]	= function(v) return v[1] end,
	["array"]	= function(v) return array2table(v) end,
	["dict"]	= function(v) return dict2table(v) end,
}

function dict2table(node, map)
	local tb = {}
	for i = 1, #node, 2 do
		local k = node[i][1]
		local v = node[i + 1]
		assert(not tb[k], "duplicate key!")
		tb[k] = map[v[0]](v)
	end
	return tb
end

function array2table(node)
	local tb = {}
	for i, v in ipairs(node) do
		tb[i] = plist2value[v[0]](v)
	end
	return tb
end

return function (path, fileFilter, dirFilter, depth)
	print("begin convert '"..path.."'")
	for_every(path, fileFilter or ".plist$", function(filename)
		local node = xml.load(filename)
		local dict = dict2table(node[1]:find("dict"), plist2string)
		local filename = string.gsub(filename, "\\", "/")
		local pex = string.gsub(filename, "(.*).plist$", "%1.pex")
		print(filename, "===>", pex)
		local f = io.open(pex, "w")
		f:write("<particleEmitterConfig>", "\n")
		f:write(string.format("	<angle value=%q />", dict.angle), "\n")
		f:write(string.format("	<angleVariance value=%q />", dict.angleVariance), "\n")
		f:write(string.format("	<blendFuncDestination value=%q />", dict.blendFuncDestination), "\n")
		f:write(string.format("	<blendFuncSource value=%q />", dict.blendFuncSource), "\n")
		f:write(string.format("	<duration value=%q />", dict.duration), "\n")
		f:write(string.format("	<emitterType value=%q />", dict.emitterType), "\n")
		f:write(string.format("	<finishParticleSize value=%q />", dict.finishParticleSize), "\n")
		f:write(string.format("	<FinishParticleSizeVariance value=%q />", dict.finishParticleSizeVariance), "\n")
		f:write(string.format("	<finishColor red=%q green=%q blue=%q alpha=%q />",
			dict.finishColorRed,
			dict.finishColorGreen,
			dict.finishColorBlue,
			dict.finishColorAlpha), "\n")
		f:write(string.format("	<finishColorVariance red=%q green=%q blue=%q alpha=%q />",
			dict.finishColorVarianceRed,
			dict.finishColorVarianceGreen,
			dict.finishColorVarianceBlue,
			dict.finishColorVarianceAlpha), "\n")
		f:write(string.format("	<gravity x=%q y=%q />",
			dict.gravityx,
			dict.gravityy), "\n")
		f:write(string.format("	<maxParticles value=%q />", dict.maxParticles), "\n")
		f:write(string.format("	<maxRadius value=%q />", dict.maxRadius), "\n")
		f:write(string.format("	<maxRadiusVariance value=%q />", dict.maxRadiusVariance), "\n")
		f:write(string.format("	<minRadius value=%q />", dict.minRadius), "\n")
		f:write(string.format("	<particleLifeSpan value=%q />", dict.particleLifespan), "\n")
		f:write(string.format("	<particleLifespanVariance value=%q />", dict.particleLifespanVariance), "\n")
		f:write(string.format("	<radialAccelVariance value=%q />", dict.radialAccelVariance), "\n")
		f:write(string.format("	<radialAcceleration value=%q />", dict.radialAcceleration), "\n")
		f:write(string.format("	<rotatePerSecond value=%q />", dict.rotatePerSecond), "\n")
		f:write(string.format("	<rotatePerSecondVariance value=%q />", dict.rotatePerSecondVariance), "\n")
		f:write(string.format("	<rotationEnd value=%q />", dict.rotationEnd), "\n")
		f:write(string.format("	<rotationEndVariance value=%q />", dict.rotationEndVariance), "\n")
		f:write(string.format("	<rotationStart value=%q />", dict.rotationStart), "\n")
		f:write(string.format("	<rotationStartVariance value=%q />", dict.rotationStartVariance), "\n")
		f:write(string.format("	<sourcePositionVariance x=%q y=%q />",
			dict.sourcePositionVariancex,
			dict.sourcePositionVariancey), "\n")
		f:write(string.format("	<sourcePosition x=%q y=%q />",
			dict.sourcePositionx,
			dict.sourcePositiony), "\n")
		f:write(string.format("	<speed value=%q />", dict.speed), "\n")
		f:write(string.format("	<speedVariance value=%q />", dict.speedVariance), "\n")
		f:write(string.format("	<startColor red=%q green=%q blue=%q alpha=%q />",
			dict.startColorRed,
			dict.startColorGreen,
			dict.startColorBlue,
			dict.startColorAlpha), "\n")
		f:write(string.format("	<startColorVariance red=%q green=%q blue=%q alpha=%q />",
			dict.startColorVarianceRed,
			dict.startColorVarianceGreen,
			dict.startColorVarianceBlue,
			dict.startColorVarianceAlpha), "\n")
		f:write(string.format("	<startParticleSize value=%q />", dict.startParticleSize), "\n")
		f:write(string.format("	<startParticleSizeVariance value=%q />", dict.startParticleSizeVariance), "\n")
		f:write(string.format("	<tangentialAccelVariance value=%q />", dict.tangentialAccelVariance), "\n")
		f:write(string.format("	<tangentialAcceleration value=%q />", dict.tangentialAcceleration), "\n")
		f:write(string.format("	<texture name=%q />", dict.textureFileName), "\n")
		f:write("</particleEmitterConfig>", "\n")
		f:close()
	end)
end