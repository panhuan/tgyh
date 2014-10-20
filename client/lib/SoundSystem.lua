
local SoundSystem = {}

local _samples = {}
local _sounds = {}
local _musics = {}
local _inited = false
local _musicMute = false
local _soundMute = false

function SoundSystem.init()
	if not MOAIUntzSystem or _inited then
		return
	end
	_inited = true
	MOAIUntzSystem.initialize()
	local _M = {
		__mode = "kv"
	}
	setmetatable(_sounds, _M)
	setmetatable(_musics, _M)
end

function SoundSystem.loadSample(path)
	if not MOAIUntzSystem or not _inited then
		return nil
	end
	local sample = _samples[path]
	if sample then
		return sample
	end
	sample = MOAIUntzSampleBuffer.new()
	sample:load(path)
	_samples[path] = sample
	return sample
end

function SoundSystem.isMute(isMusic)
	if isMusic then
		return _musicMute
	end
	return _soundMute
end

function SoundSystem.muteSound(isMute)
	if _soundMute == isMute then
		return
	end
	_soundMute = isMute
	for k, o in pairs(_sounds) do
		if isMute then
			o:setVolume(0)
		else
			o:setVolume(o._volume or 1)
		end
	end
end

function SoundSystem.muteMusic(isMute)
	if _musicMute == isMute then
		return
	end
	_musicMute = isMute
	for k, o in pairs(_musics) do
		if isMute then
			o:setVolume(0)
		else
			o:setVolume(o._volume or 1)
		end
	end
end

function SoundSystem.addSound(o)
	if o.isMusic then
		_musics[o] = o
	else
		_sounds[o] = o
	end
end

function SoundSystem.removeSound(o)
	if o.isMusic then
		_musics[o] = nil
	else
		_sounds[o] = nil
	end
end

return SoundSystem
