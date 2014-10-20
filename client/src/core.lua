local launcher = function()
	require "GlobalConstants"
	local gettext = require("gettext.gettext")
	if os.getenv("I18N_TEST") then
		gettext.setlang("*")
	else
		gettext.setlang(PREFERRED_LANGUAGES, "mo/?.mo")
	end
	local device = require "device"
	local util = require "util"
	local ui = require "ui"
	local node = require "node"
	local layer = require "layer"
	local actionset = require "actionset"
	local resource = require "resource"
	local memory = require "memory"
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
	local Task = require "logic.Task"
	local Pet = require "settings.Pet"
	local UserData = require "UserData"
	local versionctrl = require "versionctrl"
	local LuaVM = require "LuaVM"
	local OrderMgr = require "logic.OrderMgr"
	local RandomBox = require "logic.RandomBox"
	local GiftBag = require "logic.GiftBag"
	local notification = require "notification"
	
	-- imports
	local bucket = resource.bucket

	random.randomseed()
	eventhub.define("UI_EVENT")
	eventhub.register("UI_EVENT", "OPEN_START_PANEL")
	eventhub.register("UI_EVENT", "OPEN_MAIN_PANEL")
	eventhub.register("UI_EVENT", "CLOSE_MAIN_PANEL")
	eventhub.register("UI_EVENT", "OPEN_GAME_PANEL")
	eventhub.register("UI_EVENT", "MONEY_CHANGE")
	eventhub.register("UI_EVENT", "GOLD_CHANGE")
	eventhub.register("UI_EVENT", "AP_CHANGE")
	eventhub.register("UI_EVENT", "OPEN_ROLE_PANEL")
	eventhub.register("UI_EVENT", "GAME_REPLAY")
	eventhub.register("UI_EVENT", "OPEN_PET_PANEL")
	eventhub.register("UI_EVENT", "GAME_OVER")
	eventhub.register("UI_EVENT", "OPEN_BUY_PANEL")
	eventhub.register("UI_EVENT", "REFRESH_BUY_PANEL")
	eventhub.register("UI_EVENT", "REFRESH_SHOP_PANEL")
	eventhub.register("UI_EVENT", "OPEN_MESSAGEBOX")
	eventhub.register("UI_EVENT", "OPEN_REWARD_PANEL")
	eventhub.register("UI_EVENT", "CLOSE_GAME_PANEL")
	eventhub.register("UI_EVENT", "PET_UNLOCK")
	eventhub.register("UI_EVENT", "PET_LEVEL_UP")
	eventhub.register("UI_EVENT", "OPEN_ITEM_PANEL")
	eventhub.register("UI_EVENT", "USE_ITEM")
	eventhub.register("UI_EVENT", "ITEM_NUM_CHANGE")
	eventhub.register("UI_EVENT", "OPEN_SYSTEM_PANEL")
	eventhub.register("UI_EVENT", "PLAYER_LEVEL_UP")
	eventhub.register("UI_EVENT", "RESOURCE_LOAD_COMPLETE")
	eventhub.register("UI_EVENT", "PLAYER_EXP_CHANGE")
	eventhub.register("UI_EVENT", "OPEN_ADDSTEP_PANEL")
	eventhub.register("UI_EVENT", "USE_ADD_STEP")
	eventhub.register("UI_EVENT", "NOUSE_ADD_STEP")
	eventhub.register("UI_EVENT", "OPEN_LOAD_PANEL")
	eventhub.register("UI_EVENT", "CLOSE_LOAD_PANEL")
	eventhub.register("UI_EVENT", "SOUND_CHANGE")
	eventhub.register("UI_EVENT", "OPEN_PAUSE_PANEL")
	eventhub.register("UI_EVENT", "SWITCH_PAUSE_PANEL")
	eventhub.register("UI_EVENT", "MISSION_UPDATE")
	eventhub.register("UI_EVENT", "OPEN_MISSION_PANEL")
	eventhub.register("UI_EVENT", "OPEN_STAGE_PANEL")
	eventhub.register("UI_EVENT", "OPEN_EFFECT_PANEL")
	eventhub.register("UI_EVENT", "CLOSE_EFFECT_PANEL")
	eventhub.register("UI_EVENT", "STAR_EFFECT_PAPER")
	eventhub.register("UI_EVENT", "STOP_EFFECT_PAPER")
	eventhub.register("UI_EVENT", "QUIT_GAME")
	eventhub.register("UI_EVENT", "PLAYER_STAGE_CHANGE")
	eventhub.register("UI_EVENT", "OPEN_MONSTER_PANEL")
	eventhub.register("UI_EVENT", "CLOSE_MONSTER_PANEL")
	eventhub.register("UI_EVENT", "OPEN_EVERYDAY_PANEL")
	eventhub.register("UI_EVENT", "STAR_EFFECT_SNOW")
	eventhub.register("UI_EVENT", "STOP_EFFECT_SNOW")
	eventhub.register("UI_EVENT", "WINDOW_SCL_OVER")
	eventhub.register("UI_EVENT", "OPEN_ITEM_EXPLANATION")
	eventhub.register("UI_EVENT", "ROBOT_UNLOCK")
	eventhub.register("UI_EVENT", "OPEN_UNLOCK_PANEL")
	eventhub.register("UI_EVENT", "OPEN_ACTIVITY_PANEL")
	eventhub.register("UI_EVENT", "OPEN_SHOP_PANEL")
	eventhub.register("UI_EVENT", "OPEN_TIMING_PANEL")
	eventhub.register("UI_EVENT", "OPEN_TIMING_HELP")
	eventhub.register("UI_EVENT", "NOUSE_KICK_MONSTER")
	eventhub.register("UI_EVENT", "ATTACK_FINISH")
	eventhub.register("UI_EVENT", "PAUSE_GAME")
	eventhub.register("UI_EVENT", "OPEN_FAILEDTIP_PANEL")
	eventhub.register("UI_EVENT", "OPEN_TASK_PANEL")
	eventhub.register("UI_EVENT", "TASK_NOACCEPT_COUNT")
	eventhub.register("UI_EVENT", "SUPERSKILL_ROBOT")
	eventhub.register("UI_EVENT", "PLAYER_PAY_FAILED")
	eventhub.register("UI_EVENT", "PLAYER_PAY_CANCEL")
	eventhub.register("UI_EVENT", "PLAYER_PAY_SUCCESS")

	eventhub.define("SYSTEM_EVENT")
	eventhub.register("SYSTEM_EVENT", "CLEAR_GAME_DATA")
	eventhub.register("SYSTEM_EVENT", "GAME_DATA_TYPE")
	eventhub.register("SYSTEM_EVENT", "PLAYER_PAY")
	eventhub.register("SYSTEM_EVENT", "OPEN_PAY_CHANNEL_PANEL")
	eventhub.register("SYSTEM_EVENT", "RANDOM_ITEM_FINISH")
	eventhub.register("SYSTEM_EVENT", "REQUEST_USE_ITEM_IN_GAME")
	eventhub.register("SYSTEM_EVENT", "BUY_MONEY")
	eventhub.register("SYSTEM_EVENT", "BUY_GOLD")
	eventhub.register("SYSTEM_EVENT", "BUY_AP")
	eventhub.register("SYSTEM_EVENT", "BUY_RANDOMBOX")
	eventhub.register("SYSTEM_EVENT", "BUY_GIFT_BAG")
	
	eventhub.define("TASK_EVENT")
	eventhub.register("TASK_EVENT", "TASK_INIT_FINISH")
	eventhub.register("TASK_EVENT", "TASK_UPDATE")
	eventhub.register("TASK_EVENT", "TASK_FINISH")
	eventhub.register("TASK_EVENT", "ORDER_SUCCESS")
	eventhub.register("TASK_EVENT", "MISSION_FINISH")
	eventhub.register("TASK_EVENT", "STAGE_MONSTER")
	eventhub.register("TASK_EVENT", "PET_LEVELUP")
	eventhub.register("TASK_EVENT", "MISSION_STAR")
	eventhub.register("TASK_EVENT", "MISSION_START")
	eventhub.register("TASK_EVENT", "STAGE_START")
	eventhub.register("TASK_EVENT", "TIMING_START")
	
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

	stageLayer = layer.new(viewport)
	stageLayer:setSortMode(MOAILayer2D.SORT_PRIORITY_ASCENDING)
	stageLayer:setLayoutSize(device.ui_width, device.ui_height)
	stageLayer._uiname = "stageLayer"
	stageLayer:setCamera(normalCamera)
	local _stageLayer = stageLayer
	stageLayer = stageLayer:add(node.new())
	stageLayer.wndToWorld = function(self, ...)
		return _stageLayer:wndToWorld(...)
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
			stageLayer:setColor(a, a, a)
		end
		return add(self, o)
	end
	popupLayer.remove = function(self, o)
		remove(self, o)
		if self:getChildrenCount() == 0 then
			uiLayer:setColor(1, 1, 1)
			gameLayer:setColor(1, 1, 1)
			stageLayer:setColor(1, 1, 1)
		end
	end
	
	topEffectLayer = layer.new(viewport)
	topEffectLayer:setSortMode(MOAILayer2D.SORT_PRIORITY_ASCENDING)
	topEffectLayer:setLayoutSize(device.ui_width, device.ui_height)
	topEffectLayer._uiname = "topeffectLayer"
	local _topEffectLayer = topEffectLayer
	topEffectLayer = topEffectLayer:add(node.new())
	topEffectLayer.wndToWorld = function(self, ...)
		return _topEffectLayer:wndToWorld(...)
	end
	
	ui.init()
	ui.insertLayer(_stageLayer)
	ui.insertLayer(_uiLayer)
	ui.insertLayer(_popupLayer)
	ui.insertLayer(_topEffectLayer)

	mainAS = actionset.new()

	--ui windows
	local GameData = require "logic.GameData"
	local StartPanel = require "windows.StartPanel"
	local MainPanel = require "windows.MainPanel"
	local FightTopPanel = require "windows.FightTopPanel"
	local FinishPanel = require "windows.FinishPanel"
	local GamePlay = require "GamePlay"
	local PausePanel = require "windows.PausePanel"
	local RolePanel = require "windows.RolePanel"
	local PetPanel = require "windows.PetPanel"
	local BuyPanel = require "windows.BuyPanel"
	local MessageBox = require "windows.MessageBox"
	local ItemPanel = require "windows.ItemPanel"
	local SystemPanel = require "windows.SystemPanel"
	local AddStepPanel = require "windows.AddStepPanel"
	local LoadPanel = require "windows.LoadPanel"
	local RookiePanel = require "windows.RookiePanel"
	local MissionFinishPanel = require "windows.MissionFinishPanel"
	local MissionStartPanel = require "windows.MissionStartPanel"
	local StageStartPanel = require "windows.StageStartPanel"
	local TopEffectPanel = require "windows.TopEffectPanel"
	local MonsterPanel = require "windows.MonsterPanel"
	local EverydayAwardPanel = require "windows.EverydayAwardPanel"
	local ItemExplanationPanel = require "windows.ItemExplanationPanel"
	local RandomItemPanel = require "windows.RandomItemPanel"
	local TipPanel = require "windows.TipPanel"
	local RookieGuide = require "logic.RookieGuide"
	local PetRobotUnlock = require "windows.PetRobotUnlock"
	local StoryPanel = require "windows.StoryPanel"
	local RewardPanel = require "windows.RewardPanel"
	local ActivityPanel = require "windows.ActivityPanel"
	local NetworkTipPanel = require "windows.NetworkTipPanel"
	local TimingStartPanel = require "windows.TimingStartPanel"
	local TimingHelp = require "windows.TimingHelp"
	local PayChannelPanel = require "windows.PayChannelPanel"
	local FailedTip = require "windows.FailedTip"
	local TaskPanel = require "windows.TaskPanel"
	local ShopPanel = require "windows.ShopPanel"
	
	bucket.push("StartPanel")
	LoadPanel:init()
	eventhub.fire("UI_EVENT", "OPEN_LOAD_PANEL")
	LoadPanel:resLoadStart()
	bucket.pop()
	
	resource.beginAsyncLoad()
	gfxutil.preLoadAssets("ui.atlas.png")
	
	bucket.push("UI")
	gfxutil.preLoadAssets("effect.atlas.png")
	gfxutil.preLoadAssets("shoppanel.atlas.png")
	gfxutil.preLoadAssets("activitypanel.atlas.png")
	
	gfxutil.preLoadAssets("energy.png")
	gfxutil.preLoadAssets("finish_exp.png")
	gfxutil.preLoadAssets("expfillbar.png")
	gfxutil.preLoadAssets("mission_win_exp.png")
	
	if device.ram > device.RAM_LO then
		gfxutil.preLoadAssets("panel/fail_title.atlas.png")
		gfxutil.preLoadAssets("panel/win_title.atlas.png")
		gfxutil.preLoadAssets("panel/item_explantion_bg.atlas.png")
		gfxutil.preLoadAssets("panel/mission_finish_1.atlas.png")
		gfxutil.preLoadAssets("panel/mission_finish_2.atlas.png")
		gfxutil.preLoadAssets("panel/panel_1.atlas.png")
		gfxutil.preLoadAssets("panel/setting_panel.atlas.png")
		gfxutil.preLoadAssets("panel/step_bg.atlas.png")
		gfxutil.preLoadAssets("panel/system_bg.atlas.png")
		gfxutil.preLoadAssets("panel/mask_panel.atlas.png")
		gfxutil.preLoadAssets("panel/reward_bg.atlas.png")
		gfxutil.preLoadAssets("panel/mission_win_bg.atlas.png")
		gfxutil.preLoadAssets("panel/pet_unlock.atlas.png")
		gfxutil.preLoadAssets("panel/cr_xx_di.atlas.png")
		gfxutil.preLoadAssets("panel/petinfo_panel.atlas.png")
		gfxutil.preLoadAssets("panel/sbts_bj.atlas.png")
		gfxutil.preLoadAssets("panel/sb_4.atlas.png")
		gfxutil.preLoadAssets("panel/wh_ts_1.atlas.png")
		gfxutil.preLoadAssets("panel/js_di.atlas.png")
		gfxutil.preLoadAssets("panel/zf_di.atlas.png")
		gfxutil.preLoadAssets("panel/loadbg.atlas.png")
	end
	
	gfxutil.preLoadAssets("background_1.jpg")
	gfxutil.preLoadAssets("background_2.jpg")
	gfxutil.preLoadAssets("background_3.jpg")
	gfxutil.preLoadAssets("background_4.jpg")
	gfxutil.preLoadAssets("background_5.jpg")
	gfxutil.preLoadAssets("background_6.jpg")
	
	for _, pet in pairs (Pet.tbPetPic) do
		gfxutil.preLoadAssets(pet.pet)
		gfxutil.preLoadAssets(pet.robot)
	end
	
	bucket.push("StoryPanel")
	if not UserData.openingStoryPlayed then
		gfxutil.preLoadAssets("story.atlas.png")
	end
	bucket.pop()
	
	if not UserData:rookieGuideisOver() then
		gfxutil.preLoadAssets("rookie.atlas.png")
	end
	
	bucket.pop()
	resource.endAsyncLoad()

	local function initPanel()
		StartPanel:init()
		MainPanel:init()
		FightTopPanel:init()
		FinishPanel:init()
		GamePlay:init()
		PausePanel:init()
		RolePanel:init()
		PetPanel:init()
		BuyPanel:init()
		MessageBox:init()
		ItemPanel:init()
		SystemPanel:init()
		AddStepPanel:init()
		RookiePanel:init()
		MissionFinishPanel:init()
		MissionStartPanel:init()
		StageStartPanel:init()
		TopEffectPanel:init()
		MonsterPanel:init()
		EverydayAwardPanel:init()
		TipPanel:init() 
		ItemExplanationPanel:init()
		RandomItemPanel:init()
		PetRobotUnlock:init()
		StoryPanel:init()
		RewardPanel:init()
		ActivityPanel:init()
		NetworkTipPanel:init()
		TimingStartPanel:init()
		TimingHelp:init()
		FailedTip:init()
		TaskPanel:init()
		ShopPanel:init()
		
		if VERSION_OPTION:find("Qihoo") then
			PayChannelPanel:init()
		end
		
		Task:init()
		OrderMgr:init()
		RandomBox:init()
		GiftBag:init()
	end

	eventhub.bind("UI_EVENT", "OPEN_MAIN_PANEL", function()
		if device.ram < device.RAM_X_HI then
			bucket.softRelease("GamePlay", 0, MOAITexture.CPU_SIDE + MOAITexture.GPU_SIDE)
		end
	end)
	
	eventhub.bind("UI_EVENT", "OPEN_MISSION_PANEL", function()
		resource.beginAsyncLoad()
		GamePlay:preLoad()
		resource.endAsyncLoad()
	end)
	
	eventhub.bind("UI_EVENT", "RESOURCE_LOAD_COMPLETE", function()
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
		eventhub.fire("UI_EVENT", "CLOSE_LOAD_PANEL")
		-- 回退键默认绑定推出按钮
		deviceevent.onBackBtnPressedCallback = function()
			Player:platformQuitReq()
		end
		
		GameData:init()
		RookieGuide:init()
		
		if not GameData:onLoadData() then
			eventhub.fire("UI_EVENT", "OPEN_START_PANEL")
		end
		eventhub.fire("UI_EVENT", "OPEN_EFFECT_PANEL")
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
