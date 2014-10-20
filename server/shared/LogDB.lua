
require "luasql.mysql"
local qlog = require "qlog"

local LogDB = {}
LogDB._isConnected = false

function LogDB:init()
	if not self:connect() then
		return
	end
	
	self:setDatabase()
	self:createTables()
	qlog.debug("LogDB init success!")
end

function LogDB:connect()
	if not self._env then
		--创建环境对象
		self._env = assert(luasql.mysql())
		
		if not self._env then
			qlog.error("LogDB:connect env is nil")
			return false
		end
	end

	if not self._conn then
		--连接数据库
		self._conn = assert(self._env:connect(LogDBConfig.source, LogDBConfig.user, LogDBConfig.pwd, LogDBConfig.ip, LogDBConfig.port))
		
		if not self._conn then
			qlog.error("LogDB:connect conn is nil")
			return false
		end
	end

	self._isConnected = true
	return true
end

function LogDB:disConnect()
	if self._env then
		self._env:close()
	end
	
	if self._conn then
		self._conn:close()
	end
	
	self._isConnected = false
end

function LogDB:isConnected()
	return self._isConnected
end

function LogDB:setDatabase()
	assert(self._conn:execute(string.format("USE `%s`", LogDBConfig.source)))
end

function LogDB:createTables()
	assert(self._conn:execute([[
		CREATE TABLE IF NOT EXISTS `actlog` (
			`playerid` char(36) NOT NULL,
			`uuid` char(36) NOT NULL,
			`level` int(4) NOT NULL,
			`date` datetime NOT NULL,
			`key` varchar(64) NOT NULL,
			`value` text NOT NULL,
			`userdata` text NOT NULL,
			PRIMARY KEY `uuid_pk` (`uuid`),
			INDEX `level_idx` (`level`),
			INDEX `date_idx` (`date`),
			INDEX `key_idx` (`key`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='contains all users informations';
	]]))
end

function LogDB:writeActLog(playerid, uuid, level, timeStamp, key, value, userdata)
	qlog.debug("LogDB:writeActLog", playerid, level, timeStamp, key, value, userdata)
	value = toescapestring(value or "")
	userdata = toescapestring(userdata or "")
	local cursor = assert(self._conn:execute(
		string.format([[
			INSERT IGNORE INTO `actlog` SET
			`playerid` = '%s',
			`uuid` = '%s',
			`level` = %d,
			`date` = '%s',
			`key` = '%s',
			`value` = '%s',
			`userdata` = '%s'
			]], playerid, uuid, level, timeStamp, key, value, userdata)
	))
end

return LogDB
