local SoundSystem = require "SoundSystem"
local device = require "device"
local url = require "url"

local sound = {}
local dir = "sound/"

function sound.new(path, isMusic, isStreaming)
	local newpath, queryStr = string.split(path, "?")
	local sample
	if isStreaming then
		sample = dir..newpath
	else
		sample = SoundSystem.loadSample(dir..newpath)
	end
	if not sample or not MOAIUntzSystem then
		return
	end
	
	o = MOAIUntzSound.new()
	if isStreaming then
		o:load(sample, false)
	else
		o:load(sample)
	end
	o._volume = 0.5
	if queryStr ~= nil then
		local q = url.parse_query(queryStr)
		if q._volume then
			o._volume = tonumber(q._volume)
		end
		if q._looping then
			o._looping = q._looping == "true"
		end
	end
	
	o:setVolume(o._volume)
	o.isMusic = isMusic
	o.destroy = sound.destroy
	o._preSoundPlay = o.play
	o.play = sound.play
	o._preSoundStop = o.stop
	o.stop = sound.stop
	o._source = path
	SoundSystem.addSound(o)
	return o
end

function sound:destroy()
	self:stop()
	SoundSystem.removeSound(self)
end

function sound:play(looping)
	self:setLooping(looping or self._looping)
	self:_preSoundPlay()
	if SoundSystem.isMute(self.isMusic) then
		self:setVolume(0)
	end
end

function sound:stop()
	if self:isLooping() then
		self:setVolume(o._volume)
	end
	self:_preSoundStop()
end

return sound
