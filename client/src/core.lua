local launcher = function()
	require "GlobalConstants"
	local gettext = require("gettext.gettext")
	if os.getenv("I18N_TEST") then
		gettext.setlang("*")
	else
		gettext.setlang(PREFERRED_LANGUAGES, "mo/?.mo")
	end
	local device = require "device"
	local ui = require "ui"
	local node = require "node"
	local layer = require "layer"
	local actionset = require "actionset"
	local resource = require "resource"
	local timerutil = require "timerutil"
	local appcache = require "appcache"
	local qlog = require "qlog"
	local random = require "random"
	local camera = require "camera"
	local timer = require "timer"
	local eventhub = require "eventhub"
	local TextBox = require "gfx.TextBox"
	local SoundSystem = require "SoundSystem"
	local SoundManager = require "SoundManager"
	local deviceevent = require "deviceevent"
	local network = require "network"
	local gfxutil = require "gfxutil"
	local ActLog = require "ActLog"
	local Player = require "logic.Player"
	local SMSPay = require "logic.SMSPay"
	local gm = require "gm"
	local UserData = require "UserData"
	local versionctrl = require "versionctrl"
	local OrderMgr = require "logic.OrderMgr"
	local notification = require "notification"
	
	-- imports
	local bucket = resource.bucket

	random.randomseed()
	eventhub.define("UI_EVENT")
	eventhub.register("UI_EVENT", "START_GAME")

	eventhub.define("SYSTEM_EVENT")
	eventhub.register("SYSTEM_EVENT", "RESOURCE_LOAD_COMPLETE")
	eventhub.register("SYSTEM_EVENT", "PLAYER_PAY")
	
	eventhub.define("TASK_EVENT")
	
	eventhub.define("ROOKIE_EVENT")
	eventhub.register("ROOKIE_EVENT", "ROOKIE_TRIGGER")
	eventhub.register("ROOKIE_EVENT", "ROOKIE_END")
	eventhub.register("ROOKIE_EVENT", "ROOKIE_COMPLETE")
	
	ActLog:init(Player)
	if os.getenv("NO_SOUND") then
		MOAIUntzSystem = nil
	end

	MOAISim.openWindow(_("Happy Hero"), device.width, device.height)

	viewport = MOAIViewport.new()
	viewport:setScale(device.ui_width, device.ui_height)
	viewport:setSize(0, 0, device.width, device.height)

	normalCamera = camera.new()

	deviceevent:init()
	SoundSystem:init()
	SoundManager:init()
	
	if VERSION_OPTION:find("SMSPay") then
		SMSPay:init()
	else
		Player:qihooInit()
	end

	ui.Button.onClickSfx = SoundManager.onButtonClickSfx

	gameLayer = layer.new(viewport)
	gameLayer:setSortMode(MOAILayer2D.SORT_PRIORITY_ASCENDING)
	gameLayer:setLayoutSize(device.ui_width, device.ui_height)
	gameLayer._uiname = "gameLayer"
	local _gameLayer = gameLayer
	gameLayer = gameLayer:add(node.new())
	gameLayer.wndToWorld = function(self, ...)
		return _gameLayer:wndToWorld(...)
	end

	uiLayer = layer.new(viewport)
	uiLayer:setSortMode(MOAILayer2D.SORT_PRIORITY_ASCENDING)
	uiLayer:setLayoutSize(device.ui_width, device.ui_height)
	uiLayer._uiname = "uiLayer"
	local _uiLayer = uiLayer
	uiLayer = uiLayer:add(node.new())
	uiLayer.wndToWorld = function(self, ...)
		return _uiLayer:wndToWorld(...)
	end

	popupLayer = layer.new(viewport)
	popupLayer:setSortMode(MOAILayer2D.SORT_PRIORITY_ASCENDING)
	popupLayer:setLayoutSize(device.ui_width, device.ui_height)
	popupLayer._uiname = "popupLayer"
	local _popupLayer = popupLayer
	popupLayer = popupLayer:add(node.new())
	popupLayer.wndToWorld = function(self, ...)
		return _popupLayer:wndToWorld(...)
	end
	local add = popupLayer.add
	local remove = popupLayer.remove
	popupLayer.add = function(self, o)
		if self:getChildrenCount() == 0 then
			local a = 0.5
			uiLayer:setColor(a, a, a)
			gameLayer:setColor(a, a, a)
		end
		return add(self, o)
	end
	popupLayer.remove = function(self, o)
		remove(self, o)
		if self:getChildrenCount() == 0 then
			uiLayer:setColor(1, 1, 1)
			gameLayer:setColor(1, 1, 1)
		end
	end
	
	ui.init()
	ui.insertLayer(_uiLayer)
	ui.insertLayer(_popupLayer)

	mainAS = actionset.new()

	--ui windows
	local GameData = require "logic.GameData"
	local WindowManager = require "WindowManager"
	local ObjectFactory = require "ObjectFactory"
	local GamePlay = require "GamePlay"
	local ResDef = require "settings.ResDef"
	local LoadPanel = require "windows.LoadPanel"
	local StartPanel = require "windows.StartPanel"
	
	WindowManager:init()
	ObjectFactory:init()
	GamePlay:init()
	
	bucket.push("LoadPanel")
	LoadPanel:init()
	WindowManager:open("LoadPanel")
	LoadPanel:resLoadStart()
	bucket.pop()
	
	resource.beginAsyncLoad()
	
	bucket.push("UI")
	
	ResDef:resLoad()
	
	bucket.pop()
	
	resource.endAsyncLoad()

	local function initPanel()
		StartPanel:init()
		
		if VERSION_OPTION:find("Qihoo") then
			PayChannelPanel:init()
		end
		
		
	end
	
	
	eventhub.bind("SYSTEM_EVENT", "RESOURCE_LOAD_COMPLETE", function()
		initPanel()
		if  device.getConnectionType() then
			local url = VS_LIST[math.random(#VS_LIST)]
			versionctrl.update(url, UserData.APP_VERSION, VERSION_OPTION, function(ver)
				if ver then
					UserData.APP_VERSION = ver
					UserData:save()
				end
			end)
		end
		
		WindowManager:close("LoadPanel")
		GamePlay:start()
		-- 回退键默认绑定推出按钮
		deviceevent.onBackBtnPressedCallback = function()
			Player:platformQuitReq()
		end
	end)
	
	timer.new(0.1, function()
		network.step(0)
	end)
	
	timer.new(1, function()
		ActLog:step()
	end)
	
	notification.setTags(VERSION_OPTION)
	
	if _DEBUG then
		timer.new(0.1, function()
			gm.step()
			
			if dotest then
				dotest()
			end
		end)
		
		local w, h = device.ui_width, device.ui_height
		resource.path.push(device.getCachePath("/"))
		local debuginfo = uiLayer:add(TextBox.new("", "normal@8", "#FF00FFFF", "LT", w, h, "#000000FF"))
		debuginfo:setAnchor("LT", w / 2, -h / 2)
		debuginfo:setPriority(9999)
		
		timer.new(0.1, function()
			gm.step()
			local str = string.format("fps:%.02f\n", MOAISim.getPerformance())
			local mem = MOAISim.getMemoryUsage()
			str = str..string.format("mem:%.02fM\n", mem.total / 1024 / 1024)
			str = str..string.format("lua:%.02fM\n", mem.lua / 1024 / 1024)
			str = str..string.format("tex:%.02fM\n", mem.texture / 1024 / 1024)
			if _DEBUG_LEAK then
				local hst = MOAISim.getHistogram()
				for k, v in pairs(hst) do
					str = str..k:sub(5)..":"..v.."\n"
				end
			end
			
			if _DEBUG_INFO then
				debuginfo:setString(str)
			end
		end)
	end
end

local ok, err = pcall(launcher)
if not ok then
	print(err)
end
