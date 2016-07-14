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
	--display.loadSpriteFrames(packName .."channelUI.plist", packName .."channelUI.png")
	--display.loadSpriteFrames("publicui/ChatExpression.plist", "publicui/ChatExpression.png")

end

local function enterNextStep()
	
	--loadSpriteFrames()

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


function LoadingScene:onCreate()
	print("LoadingScene:onCreate()")

	self.name = "LoadingScene"
	app.runningScene = self
	
	local imgbg = ccui.ImageView:create("back.jpg")
	imgbg:addTo(self)
	imgbg:pos(display.cx, display.cy)

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

	--clientConfig.serverAddress = "192.168.11.109"
    --enterNextStep()

end

function LoadingScene:dealPreGames()
	db.createTable()

	db.addNewGame(90, "dzpk", "德州扑克", 1, 1)
	cc.UserDefault:getInstance():setStringForKey("dzpk_version", "1.0")

end

function LoadingScene:onEnterTransitionFinish_()
	app.isAccessAppleStore = 0
	
	
end

function LoadingScene:onExit_()

end


return LoadingScene