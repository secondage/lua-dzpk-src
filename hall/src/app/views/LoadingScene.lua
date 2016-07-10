--
-- Author: ChenShao
-- Date: 2015-09-16 14:56:43
--
require("app.func.Urls")
require("init")

local LoadingScene = class("LoadingScene", cc.load("mvc").ViewBase)
--LoadingScene.RESOURCE_FILENAME = "hall/LoadingScene.csb"

local db = require("app.func.GameDB")
local json = require("framework.json")
local httpUtils = require("app.func.HttpUtils")

local function loadSpriteFrames()
	local packName = "publicui/"
	--display.loadSpriteFrames(packName .."paintAnimation.plist", packName .."paintAnimation.png")
	display.loadSpriteFrames(packName .."channelUI.plist", packName .."channelUI.png")
	display.loadSpriteFrames("publicui/ChatExpression.plist", "publicui/ChatExpression.png")

end

local function enterNextStep()
	
	loadSpriteFrames()
	app.audioPlayer:loadAudio()
	app.audioPlayer:playHallMusic()


	local function isAutoLogin()
		local username = cc.UserDefault:getInstance():getStringForKey("username", "")
		local password = cc.UserDefault:getInstance():getStringForKey("password", "")

		if (username ~= "" and password ~= "") or cc.UserDefault:getInstance():getBoolForKey("isGuestLogin", false) then
			return true
		end
		return false
	end

	local nextScene = ""
	if isAutoLogin() then
		nextScene = "HallScene"
	else
		nextScene = "LoginScene"
	end

	local scheduler = require("framework.scheduler")
	scheduler.performWithDelayGlobal(function()
		app.sceneSwitcher:enterScene(nextScene)
	end, 0.5)
end

local function sendChannelTag2Server()
	if not cc.UserDefault:getInstance():getBoolForKey("isFirstLaunchGame", true) then
		return
	end

	g_channel = g_channel or 0
	local device = require("framework.device")
	local strUrl = urls.channelUrl .."source=" ..g_channel .."&appName=hall&imei=" ..device.getOpenUDID()
	print("channel_strUrl = " ..strUrl) 
	httpUtils.reqHttp(strUrl, function(ret, response)
		if ret then
			print("response = " ..response)
		end
	end) 
end

function LoadingScene:onCreate()
	print("LoadingScene:onCreate()")

	self.name = "LoadingScene"
	app.runningScene = self
	
	local imgbg = ccui.ImageView:create("back.jpg")
	imgbg:addTo(self)
	imgbg:pos(display.cx, display.cy)

 	self:dealPreGames()
 	--sendChannelTag2Server()
 	--self:checkTaskJSonVersion()

 --	self:getZipUrlFromServer()

 	self:readLoginIni()
end


function LoadingScene:onEnter_()

end

function LoadingScene:readLoginIni()
	httpUtils.reqHttp("http://121.42.61.41/login.json", function(ret, response)
		if ret then
			local info = json.decode(response)

			print("info.ip = " ..info.ip)
			clientConfig.serverAddress = info.ip
			enterNextStep()
		end
	end)

	--clientConfig.serverAddress = "192.168.11.107"
    --enterNextStep()

end

local function readPreGamesJson()
	if cc.UserDefault:getInstance():getBoolForKey("isFirstLaunchGame", true) then
		httpUtils.reqHttp(urls.preGamesList, function(ret, response)
			if ret then
				local infos = json.decode(response)

				for i = 1, #infos do
					local info = infos[i] 
					db.addNewGame(info.gameid, info.name, info.nameZH, 1, 0)
				end
			end
		end)
	end
end

function LoadingScene:dealPreGames()
	db.createTable()

	db.addNewGame(90, "dzpk", "德州扑克", 1, 1)
	cc.UserDefault:getInstance():setStringForKey("dzpk_version", "1.0")
	--[[
	if g_Platform_Win32 then
		db.addNewGame(90010, "ccmj", "长春麻将", 1, 1)
		cc.UserDefault:getInstance():setStringForKey("ccmj_version", "1.0")
	elseif g_Platform_Ios then
		db.addNewGame(90010, "ccmj", "长春麻将", 1, 1)
		cc.UserDefault:getInstance():setStringForKey("ccmj_version", "1.0")
	elseif g_Platform_Android then
		db.addNewGame(90010, "ccmj", "长春麻将", 1, 1)
		cc.UserDefault:getInstance():setStringForKey("ccmj_version", "1.0")

		--readPreGamesJson()
	end
	]]
end

function LoadingScene:onEnterTransitionFinish_()
	app.isAccessAppleStore = 0
	
	--clientConfig.serverAddress = "192.168.83.128"
	--enterNextStep()
	--[[
	if g_Platform_Ios then
		print("urls.accessAppleStore = " ..urls.accessAppleStore)
		httpUtils.reqHttp(urls.accessAppleStore, function(ret, response)
			if ret then		
				local info = json.decode(response)
				
				app.isAccessAppleStore = info.access
				print("app.isAccessAppleStore = " ..app.isAccessAppleStore)
				enterNextStep()
			else
				app.isAccessAndroidStore = 1
				enterNextStep()
			end
		end)
	elseif g_Platform_Android then
		print("urls.accessAndroidStore = " ..urls.accessAndroidStore)
		httpUtils.reqHttp(urls.accessAndroidStore, function(ret, response)
			if ret then		
				local info = json.decode(response)
				
				app.isAccessAndroidStore = info.access
				print("app.isAccessAndroidStore = " ..app.isAccessAndroidStore)
				enterNextStep()
			else
				app.isAccessAndroidStore = 1
				enterNextStep()
			end
		end)
	elseif g_Platform_Win32 then
		app.isAccessAppleStore = 0--test
		enterNextStep()
	else
		app.isAccessAppleStore = 1
		enterNextStep()
	end
	]]
end

function LoadingScene:onExit_()
	--app.holdOn.hide()

	cc.UserDefault:getInstance():setBoolForKey("isFirstLaunchGame", false)
end

function LoadingScene:checkTaskJSonVersion() --在此获取服务器taskjson版本号，为了 后续增强用户体验
	local gameInfo = db.readGameInfo()
	--dump(gameInfo)
	 for i = 1, #gameInfo do
    	local game = gameInfo[i]

		local urlVersion = urls.taskJsonVerion ..game.gameName .."_task_version"
		httpUtils.reqHttp(urlVersion, function(ret, response)
			if ret then
				local serverVersion = tonumber(response)
				print(game.gameName .."task json verison = " ..serverVersion)

				app.taskLogic.checkVersion[game.gameName] = serverVersion
			end
		end)
    end
end

function LoadingScene:getZipUrlFromServer()
	local url = urls.minigameDownloadurl .."zipdownloadurl.json"
	httpUtils.reqHttp(url, function(ret, response)
		if ret then		
			local info = json.decode(response)
			--dump(info)
			urls.updateZipDownloadurl = info.updateZipRoot
			urls.fullZipDownloadurl = info.fullZipRoot

			if g_Platform_Win32 or clientConfig.platform == "INNER" then
				urls.updateZipDownloadurl = info.updateZipRoot_win32
				urls.fullZipDownloadurl = info.fullZipRoot_win32
			end
		end
	end)
end

return LoadingScene