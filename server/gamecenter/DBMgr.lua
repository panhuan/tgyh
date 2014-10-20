
require "luasql.mysql"
local qlog = require "qlog"

local DBMgr = {}
DBMgr._isConnected = false

function DBMgr:init()
	if not self:connect() then
		return
	end
	
	self:setDatabase()
	self:createPlayerTable()
	self:createOrderTable()
	
	qlog.debug("DBMgr init success!")
end

function DBMgr:connect()
	if not self._env then
		--创建环境对象
		self._env = assert(luasql.mysql())
		
		if not self._env then
			qlog.error("DBMgr:connect env is nil")
			return false
		end
	end

	if not self._conn then
		--连接数据库
		self._conn = assert(self._env:connect(DBConfig.source, DBConfig.user, DBConfig.pwd, DBConfig.ip, DBConfig.port))
		
		if not self._conn then
			qlog.error("DBMgr:connect conn is nil")
			return false
		end
	end

	self._isConnected = true
	return true
end

function DBMgr:disConnect()
	if self._env then
		self._env:close()
	end
	
	if self._conn then
		self._conn:close()
	end
	
	self._isConnected = false
end

function DBMgr:isConnected()
	return self._isConnected
end

function DBMgr:setDatabase()
	assert(self._conn:execute(string.format("USE `%s`", DBConfig.source)))
end

function DBMgr:createPlayerTable()
	assert(self._conn:execute([[
		CREATE TABLE IF NOT EXISTS `player` (
			`guid` char(36) NOT NULL,
			`account` varchar(255) NOT NULL,
			`password` varchar(13) DEFAULT NULL,
			`username` varchar(13) DEFAULT NULL,
			`userdata` text NOT NULL,
			PRIMARY KEY (`guid`),
			KEY `accountindex` (`account`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='contains all users informations';
	]]))
end

function DBMgr:savePlayerData(guid, data)
	assert(self._conn:execute(string.format([[  
		INSERT INTO `player` SET 
		`guid` = '%s', 
		`account` = '%s', 
		`userdata` = '%s' 
        ON DUPLICATE KEY UPDATE 
		`userdata` = '%s'
		]], guid, guid, toescapestring(data), toescapestring(data))  
	))
end

function DBMgr:loadPlayerData(guid)
	local cursor = self._conn:execute(string.format([[  
		SELECT `userdata` FROM `player` WHERE `guid` = '%s'
        ]], guid))
	
	if not cursor or cursor:numrows() == 0 then
		return nil
	end
	
	local data = cursor:fetch({}, "a")
	cursor:close()
	return data.userdata
end

function DBMgr:createOrderTable()
	assert(self._conn:execute([[
		CREATE TABLE IF NOT EXISTS `order` (
			`orderid` varchar(50) NOT NULL,
			`guid` char(36) NOT NULL,
			`account` varchar(255) NOT NULL,
			`status` int(10) DEFAULT 0,
			`time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
			PRIMARY KEY (`orderid`),
			KEY `guidindex` (`guid`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='contains all orders';
	]]))
end

function DBMgr:updateOrder(orderId, guid, status)
	qlog.debug("DBMgr:updateOrder", orderId, guid, status)
	local cursor = assert(self._conn:execute(
		string.format([[
			INSERT INTO `order` SET
			`orderid` = '%s',
			`guid` = '%s',
			`account` = '%s',
			`status` = %d
			ON DUPLICATE KEY UPDATE 
			`status` = %d
		]], orderId, guid, guid, status, status)
	))
end

function DBMgr:getOrderState(orderId)
	qlog.debug("DBMgr:getOrderState", orderId)
	local cursor = assert(self._conn:execute(
		string.format([[
			SELECT `status`, `time` 
			FROM `order` 
			WHERE `orderid` = '%s'
			]], orderId
		)
	))
	
	if cursor:numrows() == 0 then
		return nil
	end
	
	local data = cursor:fetch({}, "a")
	cursor:close()
	return tonumber(data.status)
end

function DBMgr:deleteOrder(orderId)
	local cursor = assert(self._conn:execute(
		string.format([[
			DELETE FROM `order` 
			WHERE `orderid` = '%s'
			]], orderId
		)
	))
	
	qlog.debug("DBMgr:deleteOrder", orderId, cursor)
	
	if cursor == 0 then
		return false
	end
	
	
	return true
end

function DBMgr:initOrderList(tbOrderList)
	local cursor = assert(self._conn:execute([[
		SELECT `orderid`, `guid`, `status`
		FROM `order`
		]]
	))
	
	if cursor:numrows() == 0 then
		qlog.debug("DBMgr:initOrderList list empty")
		return true
	end
	
	local order = cursor:fetch({}, "a")
	while order do
		if order.guid and order.orderid and order.status then
			if not tbOrderList[order.guid] then
				tbOrderList[order.guid] = {}
			end
			
			tbOrderList[order.guid][order.orderid] = tonumber(order.status)
		end
		
		order = cursor:fetch({}, "a")
	end
	
	cursor:close()
	return true
end

return DBMgr
