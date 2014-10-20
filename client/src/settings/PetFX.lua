
local Sprite = require "gfx.Sprite"
local Particle = require "gfx.Particle"
local SpinPatch = require "gfx.SpinPatch"
local Image = require "gfx.Image"
local node = require "node"

local bot, top = 0, 100

local tbSpinPatchPic =
{
	huaxin = 
	{
		"pet/huaxin_robot_garner_01.png",
	},
	tianxin = 
	{
		"pet/tianxin_robot_garner_01.png",
		"pet/tianxin_robot_garner_02.png",
	},
	cuxin = 
	{
		"pet/cuxin_robot_garner_01.png",
	},
	xiaoxin = 
	{
		"pet/xiaoxin_robot_garner_01.png",
	},
}


local function kaixin_robot_garner_template(pex)
	local root = node.new()
	-- local o = root:add(Sprite.new("pet/kaixin_robot.atlas.png#garner_01?loop=true&loc=10,-50"))
	-- o:setPriorityOffset(top)
	if pex then
		local o2 = root:add(Particle.new(pex))
		o2:begin()
		o2:setPriorityOffset(top + 1)
	end
	return root
end

local function huaxin_robot_garner_template(pex)
	local root = node.new()
	local o = root:add(SpinPatch.new(tbSpinPatchPic.huaxin[1]))
	o:setScl(0.5, 0.25)
	o:setLoc(0, -60)
	local a = o:seekSpin(0, -360, 3, true)
	local _removeSelf = o._removeSelf
	o._removeSelf = function()
		a:stop()
		_removeSelf(o)
	end
	o:setPriorityOffset(bot)
	if pex then
		local o2 = root:add(Particle.new(pex, mainAS))
		o2:begin()
		o2:setPriorityOffset(top + 1)
	end
	return root
end

local function tianxin_robot_garner_template(pex)
	local root = node.new()
	local o = root:add(SpinPatch.new(tbSpinPatchPic.tianxin[2]))
	o:setScl(0.5, 0.25)
	o:setLoc(0, -60)
	local a = o:seekSpin(0, -360, 3, true)
	local _removeSelf = o._removeSelf
	o._removeSelf = function()
		a:stop()
		_removeSelf(o)
	end
	o:setPriorityOffset(bot)
	if pex then
		local o2 = root:add(Particle.new(pex, mainAS))
		o2:begin()
		o2:setPriorityOffset(top + 1)
	end
	return root
end

local function cuxin_robot_garner_template(pex)
	local root = node.new()
	local o = root:add(SpinPatch.new(tbSpinPatchPic.cuxin[1]))
	o:setScl(0.5, 0.25)
	o:setLoc(0, -60)
	local a = o:seekSpin(0, -360, 3, true)
	local _removeSelf = o._removeSelf
	o._removeSelf = function()
		a:stop()
		_removeSelf(o)
	end
	o:setPriorityOffset(bot)
	if pex then
		local o2 = root:add(Particle.new(pex, mainAS))
		o2:begin()
		o2:setPriorityOffset(top + 1)
	end
	return root
end

local function xiaoxin_robot_garner_template(pex)
	local root = node.new()
	local o = root:add(Sprite.new("pet/xiaoxin_man.atlas.png#garner_02?loop=true&scl=1&loc=0,-20"))
	o:setBlendMode(MOAIProp.BLEND_ADD)
	o:setPriorityOffset(top)
	if pex then
		local o2 = root:add(Particle.new(pex))
		o2:begin()
		o2:setPriorityOffset(top + 1)
	end
	return root
end

-- local function xiaoxin_robot_garner_template2(pex)
	-- local root = node.new()
	-- local o = root:add(SpinPatch.new(tbSpinPatchPic.xiaoxin[1]))
	-- o:setLoc(-20, -120)
	-- o:setScl(1, 0.5)
	-- local a = o:seekSpin(0, -360, 3, true)
	-- local _removeSelf = o._removeSelf
	-- o._removeSelf = function()
		-- a:stop()
		-- _removeSelf(o)
	-- end
	-- o:setPriorityOffset(bot)
	-- if pex then
		-- local o2 = root:add(Particle.new("garner/"..pex))
		-- o2:setLoc(-20, -100)
		-- o2:begin()
		-- o2:setPriorityOffset(top + 1)
	-- end
	-- return root
-- end

local PetFX = {
	["kaixin_man"] = {
		baseCount = 2,
		garner = {
			[1] = function()
				return kaixin_robot_garner_template("kaixin_robot_garner_01.pex?loc=0,-75")
			end,
			[2] = function()
				return kaixin_robot_garner_template("kaixin_robot_garner_02.pex?loc=0,-75")
			end,
			[3] = function()
				return kaixin_robot_garner_template("kaixin_robot_garner_03.pex?loc=0,-75")
			end,
			[4] = function()
				return kaixin_robot_garner_template("kaixin_robot_garner_04.pex?loc=0,-75")
			end,
			[5] = function()
				return kaixin_robot_garner_template("kaixin_robot_garner_05.pex?loc=0,-75")
			end,
			[6] = function()
				return kaixin_robot_garner_template("kaixin_robot_garner_06.pex?loc=0,-75")
			end,
		},
		impact = {
			[1] = function()
				return Sprite.new("pet/kaixin_robot.atlas.png#kaixin_robot_impact_01")
			end,
			[2] = function()
				return Sprite.new("pet/kaixin_robot.atlas.png#kaixin_robot_impact_02")
			end,
			[3] = function()
				return Sprite.new("pet/kaixin_robot.atlas.png#kaixin_robot_impact_03")
			end,
		},
	},
	["huaxin_man"] = {
		baseCount = 2,
		garner = {
			[1] = function()
				return huaxin_robot_garner_template()
			end,
			[2] = function()
				return huaxin_robot_garner_template("huaxin_robot_garner_02.pex?loc=0,-50&scl=0.5")
			end,
			[3] = function()
				return huaxin_robot_garner_template("huaxin_robot_garner_03.pex?loc=0,-50&scl=0.5")
			end,
			[4] = function()
				return huaxin_robot_garner_template("huaxin_robot_garner_04.pex?loc=0,-50&scl=0.5")
			end,
			[5] = function()
				return huaxin_robot_garner_template("huaxin_robot_garner_05.pex?loc=0,-50&scl=0.5")
			end,
			[6] = function()
				return huaxin_robot_garner_template("huaxin_robot_garner_06.pex?loc=0,-50&scl=0.5")
			end,
		},
		impact = {
			[1] = function()
				return Sprite.new("pet/huaxin_robot.atlas.png#huaxin_robot_impact_01")
			end,
			[2] = function()
				return Sprite.new("pet/huaxin_robot.atlas.png#huaxin_robot_impact_02")
			end,
			[3] = function()
				return Sprite.new("pet/huaxin_robot.atlas.png#huaxin_robot_impact_03")
			end,
		},
	},
	["tianxin_man"] = {
		baseCount = 2,
		garner = {
			[1] = function()
				return tianxin_robot_garner_template()
			end,
			[2] = function()
				return tianxin_robot_garner_template("tianxin_robot_garner_02.pex?scl=0.5")
			end,
			[3] = function()
				return tianxin_robot_garner_template("tianxin_robot_garner_03.pex?scl=0.5")
			end,
			[4] = function()
				return tianxin_robot_garner_template("tianxin_robot_garner_04.pex?scl=0.5")
			end,
			[5] = function()
				return tianxin_robot_garner_template("tianxin_robot_garner_05.pex?scl=0.5")
			end,
			[6] = function()
				return tianxin_robot_garner_template("tianxin_robot_garner_06.pex?scl=0.5")
			end,
		},
		impact = {
			[1] = function()
				return Sprite.new("pet/tianxin_robot.atlas.png#tianxin_robot_impact_01")
			end,
			[2] = function()
				return Sprite.new("pet/tianxin_robot.atlas.png#tianxin_robot_impact_02")
			end,
			[3] = function()
				return Sprite.new("pet/tianxin_robot.atlas.png#tianxin_robot_impact_03")
			end,
		},
	},
	["cuxin_man"] = {
		baseCount = 2,
		garner = {
			[1] = function()
				return cuxin_robot_garner_template()
			end,
			[2] = function()
				return cuxin_robot_garner_template("cuxin_robot_garner_02.pex?scl=0.5")
			end,
			[3] = function()
				return cuxin_robot_garner_template("cuxin_robot_garner_03.pex?scl=0.5")
			end,
			[4] = function()
				return cuxin_robot_garner_template("cuxin_robot_garner_04.pex?scl=0.5")
			end,
			[5] = function()
				return cuxin_robot_garner_template("cuxin_robot_garner_05.pex?scl=0.5")
			end,
			[6] = function()
				return cuxin_robot_garner_template("cuxin_robot_garner_06.pex?scl=0.5")
			end,
		},
		impact = {
			[1] = function()
				return Sprite.new("pet/cuxin_robot.atlas.png#cuxin_robot_impact_01")
			end,
			[2] = function()
				return Sprite.new("pet/cuxin_robot.atlas.png#cuxin_robot_impact_02")
			end,
			[3] = function()
				return Sprite.new("pet/cuxin_robot.atlas.png#cuxin_robot_impact_03")
			end,
		},
	},
	["xiaoxin_man"] = {
		baseCount = 2,
		garner = {
			[1] = function()
				return xiaoxin_robot_garner_template()
			end,
			[2] = function()
				return xiaoxin_robot_garner_template("xiaoxin_robot_garner_02.pex?loc=0,-50&scl=0.5")
			end,
			[3] = function()
				return xiaoxin_robot_garner_template("xiaoxin_robot_garner_03.pex?loc=0,-50&scl=0.5")
			end,
			[4] = function()
				return xiaoxin_robot_garner_template("xiaoxin_robot_garner_04.pex?loc=0,-50&scl=0.5")
			end,
			[5] = function()
				return xiaoxin_robot_garner_template("xiaoxin_robot_garner_05.pex?loc=0,-50&scl=0.5")
			end,
			[6] = function()
				return xiaoxin_robot_garner_template("xiaoxin_robot_garner_06.pex?loc=0,-50&scl=0.5")
			end,
		},
		impact = {
			[1] = function()
				return Sprite.new("pet/xiaoxin_robot.atlas.png#xiaoxin_robot_impact_01")
			end,
			[2] = function()
				return Sprite.new("pet/xiaoxin_robot.atlas.png#xiaoxin_robot_impact_02")
			end,
			[3] = function()
				return Sprite.new("pet/xiaoxin_robot.atlas.png#xiaoxin_robot_impact_03")
			end,
		},
	},
}

PetFX.tbSpinPatchPic = tbSpinPatchPic

return PetFX