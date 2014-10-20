
local url = require "url"
local node = require "node"
local resource = require "resource"

local ParticleSystem = {}

function ParticleSystem.noop()
end

function ParticleSystem.new(particleName)
	local particleName, queryStr = string.split(particleName, "?")
	local o
	if string.find(particleName, ".pex") ~= nil then
		local texture, emitter
		if MOAIParticlePexPlugin then
			do
				local plugin = resource.pexparticle(particleName)
				local maxParticles = plugin:getMaxParticles()
				local blendsrc, blenddst = plugin:getBlendMode()
				local minLifespan, maxLifespan = plugin:getLifespan()
				local duration = plugin:getDuration()
				local xMin, yMin, xMax, yMax = plugin:getRect()
				o = node.new(MOAIParticleSystem2D.new())
				o._duration = duration
				o._lifespan = maxLifespan
				o:reserveParticles(maxParticles, plugin:getSize())
				o:reserveSprites(maxParticles)
				o:reserveStates(1)
				o:setBlendMode(blendsrc, blenddst)
				local state = MOAIParticleState.new()
				state:setTerm(minLifespan, maxLifespan)
				state:setPlugin(plugin)
				o:setState(1, state)
				texture = plugin:getTextureName()
				emitter = MOAIParticleTimedEmitter.new()
				emitter:setParent(o)
				emitter:setSystem(o)
				emitter:setEmission(plugin:getEmission())
				emitter:setFrequency(plugin:getFrequency())
				emitter:setRect(xMin, yMin, xMax, yMax)
			end
		else
			o, emitter, texture = MOAIParticlePlugin.loadExternal(particleName)
			o = node.new(o)
		end
		local tex = resource.deck(texture)
		tex:setRect(-0.5, -0.5, 0.5, 0.5)
		o:setDeck(tex)
		local emitters = {}
		emitters[1] = emitter
		o.emitters = emitters
	else
		o = dofile(resource.path.resolvepath(particleName))
	end
	if queryStr then
		local q = url.parse_query(queryStr)
		if q.dur then
			o._duration = tonumber(q.dur)
		end
		if q.life then
			o._lifespan = tonumber(q.life)
		end
		if q.loop == "true" then
			o._duration = -1
		end
		if q.scl then
			local x, y = string.split(q.scl, ",")
			o:setScl(tonumber(x), tonumber(x or y))
		end
		if q.rot then
			local rot = tonumber(q.rot)
			o:setRot(rot)
		end
		if q.pri then
			local pri = tonumber(q.pri)
			o:setPriority(pri)
		end
		if q.loc then
			local x, y = string.split(q.loc, ",")
			o:setLoc(tonumber(x), tonumber(y))
		end
		if q.alpha then
			o:setColor(tonumber(q.alpha), tonumber(q.alpha), tonumber(q.alpha), tonumber(q.alpha))
		end
	end
	o.startSystem = ParticleSystem.startSystem
	o.stopEmitters = ParticleSystem.stopEmitters
	o.stopSystem = ParticleSystem.stopSystem
	o.surgeSystem = ParticleSystem.surgeSystem
	o.updateSystem = ParticleSystem.updateSystem
	return o
end

function ParticleSystem:startSystem(noEmitters)
	self:start()
	if not noEmitters then
		for k, v in pairs(self.emitters) do
			v:start()
		end
	end
end

function ParticleSystem:stopEmitters()
	for k, v in pairs(self.emitters) do
		v:stop()
	end
end

function ParticleSystem:stopSystem()
	self:stop()
	self:stopEmitters()
end

function ParticleSystem:surgeSystem(val)
	for k, v in pairs(self.emitters) do
		v:surge(val)
	end
end

function ParticleSystem:updateSystem()
	self:forceUpdate()
	for k, v in pairs(self.emitters) do
		v:forceUpdate()
	end
end

return ParticleSystem
