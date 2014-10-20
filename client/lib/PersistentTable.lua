local file = require "file"
local util = require "util"
local device = require "device"
local crypto = require "crypto"
local stream = require "stream"

local PersistentTable = {}
PersistentTable.__index = PersistentTable

function PersistentTable.new(filePath, basePath, keystore, default)
	local filename
	if basePath == true then
		filename = device.getDocumentsPath() .. "/" .. filePath
	elseif basePath == false then
		filename = device.getCachePath() .. "/" .. filePath
	elseif basePath ~= nil then
		filename = basePath .. "/" .. filePath
	end
	local mt = {}
	mt.filename = filename
	
	if type(keystore) == "string" then
		mt.hmac = filename .. ".sum"
		mt.keystore = keystore
	end
	
	local err
	local t
	local data = file.read(filename)
	if data then
		if mt.hmac then
			local sum = file.read(mt.hmac)
			local sha = crypto.hmac.digest("sha1", data, keystore)
			if sha ~= sum then
				if file.exists(mt.filename..".bak") and file.exists(mt.hmac..".bak") then
					os.remove(mt.filename)
					os.remove(mt.hmac)
					
					os.rename(mt.filename..".bak", mt.filename)
					os.rename(mt.hmac..".bak", mt.hmac)
					err = "recover data"
					return PersistentTable.new(filePath, basePath, keystore, default)
				else
					err = "reset data"
					data = nil
				end
			end
		end
	end
	if data then
		data = crypto.decode(data)
		local s = stream.new(data)
		t = s:read()
	end
	if not t then
		t = {}
	end
	setmetatable(t, mt)
	t.save = PersistentTable.save
	t.insert = PersistentTable.insert
	t.remove = PersistentTable.remove
	t.pop = PersistentTable.pop
	t.push = PersistentTable.push
	t.put = PersistentTable.put
	t.takeTable = PersistentTable.takeTable
	if default then
		table.merge(t, default, true)
	end
	return t, err
end

function PersistentTable:takeTable(visited)
	local o = {}
	visited = visited or {}
	visited[o] = o
	for k, v in pairs(self) do
		local kt = type(k)
		assert(kt == "boolean" or kt == "number" or kt == "string", "unsaveable type of key")
		local vt = type(v)
		if visited[v] then
			o[k] = visited[v]
		elseif vt == "userdata" then
			local f = getfield(v, "__tostring")
			if f then
				local s = f(v)
				o[k] = s
				visited[v] = s
			end
		elseif vt == "table" then
			local t = PersistentTable.takeTable(v, visited)
			o[k] = t
			visited[v] = t
		elseif vt == "function" then
		else
			o[k] = v
		end
	end
	return o
end

function PersistentTable:save()
	local mt = getmetatable(self)
	local t = self:takeTable()
	local s = stream.new()
	s:write(t)
	local data = crypto.encode(s:tostring())
	file.write(mt.filename..".swp", data, true)
	
	os.remove(mt.filename..".bak")
	os.rename(mt.filename, mt.filename..".bak")
	os.rename(mt.filename..".swp", mt.filename)
	
	if mt.hmac then
		local sha = crypto.hmac.digest("sha1", data, mt.keystore)
		file.write(mt.hmac..".swp", sha)
		
		os.remove(mt.hmac..".bak")
		os.rename(mt.hmac, mt.hmac..".bak")
		os.rename(mt.hmac..".swp", mt.hmac)
	end
end

function PersistentTable:insert(...)
	table.insert(self, ...)
	self:save()
end

function PersistentTable:remove(n)
	if n == nil then
		n = #self
	end
	local result = self[n]
	table.remove(self, n)
	self:save()
	return result
end

function PersistentTable:pop()
	return self:remove(nil)
end

function PersistentTable:push(value)
	return self:insert(value)
end

function PersistentTable:put(key, value)
	self[key] = value
	self:save()
end

return PersistentTable
