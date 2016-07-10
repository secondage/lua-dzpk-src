--
-- Author: ChenShao
-- Date: 2015-11-14 13:56:44
--
local UpdateScene = class("UpdateScene", cc.load("mvc").ViewBase)
UpdateScene.RESOURCE_FILENAME = "hall/LoadingScene.csb"

local msgBox = require("app.func.MessageBox")
local json = require("framework.json")
local httpUtils = require("app.func.HttpUtils") 

local bridge = require("app.func.Bridge")
local updateCheck = require("app.func.AppUpdate")


function UpdateScene:onCreate()
	print("UpdateScene:onCreate()")

	self.name = "UpdateScene"
	app.runningScene = self

	if cc.UserDefault:getInstance():getBoolForKey("isFirstLaunchGame", true) then 
		local app_build = bridge.getAppInfo().app_build
		print("app_build = " ..app_build)
		cc.UserDefault:getInstance():setStringForKey("hall_version", app_build)
	end
end

function UpdateScene:onEnter_()
	
end

function UpdateScene:downLoadingUI(gamename, onResult, strZipUrl)
	local layDownloadCtrller = require("app.views.layers.DownLoadLayer").new()
	self.layDownload = layDownloadCtrller:createLayer():addTo(self, 100)

	self.layDownload:hide()
	layDownloadCtrller:startDownload(gamename, onResult, strZipUrl)
end

function UpdateScene:enterLoadingScene()
	require("app.MyApp"):create({viewsRoot = "hall/src/app/views"}):enterScene("LoadingScene")
	
	--[[
	require("init")
	app.test = true
	--cc.dataMgr.playingGame = "twoseventen"
	cc.dataMgr.playingGame = "dzpk"
	local playingGame = cc.dataMgr.playingGame
	cc.FileUtils:getInstance():addSearchPath("src/" ..playingGame.."/res/")
	local resHelper = require(cc.dataMgr.playingGame .."/src/ResHelper")
	resHelper.loadSpriteFrames()
	resHelper.loadAudio()
	cc.dataMgr.selectedGameInfo = {}
	cc.dataMgr.selectedGameInfo.gameType = 1
	require("app.MyApp"):create({viewsRoot = playingGame..".src"}):enterScene("GameScene")
	--]]

end

function UpdateScene:onEnterTransitionFinish_()
	self:enterLoadingScene() --test
	--[[
	updateCheck.checkUpdate(function(canUpdate, needUpdate)
		self:onCheckAppUpdateResult(canUpdate, needUpdate)
	end)
	return
	--]]
	---[[
	if g_Platform_Win32 then
		--self:enterLoadingScene() --test
	else
		--[[
		--检查更新
		if g_Platform_Android and clientConfig.platform ~= "INNER" then
			updateCheck.checkUpdate(function(canUpdate, needUpdate)
				self:onCheckAppUpdateResult(canUpdate, needUpdate)
			end)
			return
		else
			self:getZipUrlFromServer()
		end
		--]]
		--self:getZipUrlFromServer()
	end
	--]]
end

function UpdateScene:onCheckAppUpdateResult(canUpdate, needUpdate)
	if needUpdate then
		local funcOk = function()
			updateCheck.doUpdate()
		end
		local funcCancel = function()
			cc.Director:getInstance():endToLua()
		end
		msgBox.showMsgBoxTwoBtn("需要更新应用程序，是否更新？", funcOk, funcCancel, "应用更新", "马上更新", "不更新", funcCancel)
	elseif canUpdate then
		local funcOk = function()
			updateCheck.doUpdate()
		end
		local funcCancel = function()
			self:getZipUrlFromServer()
		end
		msgBox.showMsgBoxTwoBtn("有更新可用，是否更新？", funcOk, funcCancel, "应用更新", "马上更新", "暂不更新", funcCancel)
	else
		self:getZipUrlFromServer()
	end
end

function UpdateScene:downloadHall()
	local function onResult(ret)--回调
		self.layDownload:hide()
		if ret == 0 then --成功

			self:enterLoadingScene()
		elseif ret == 1 then
			print("没有新版本")	
			self:enterLoadingScene()
		elseif ret == 2 then
			if g_Platform_Win32 then
				self:enterLoadingScene()
			else
				self.layDownload:hide()
				msgBox.showMsgBox("请确认网络是否连接")
			end
		elseif ret == 3 then
			print("开始下载")	
			self.layDownload:show()
		elseif ret == 4 then
			self:enterLoadingScene()
		elseif ret == 5 then
			self.layDownload:show()
		elseif ret == 6 then
			print("没有该游戏")
			self:enterLoadingScene()
		end
	end

	print("<===检测 hall")
	self:downLoadingUI("hall", onResult, urls.zipDownloadurl)
end

function UpdateScene:getZipUrlFromServer()

	urls.zipDownloadurl = "http://125.32.113.103/2d_web_ini/updatezip/"

	if g_Platform_Win32 or clientConfig.platform == "INNER" then
		urls.zipDownloadurl = "http://192.168.1.69/2d_web_ini/updatezip/"
	end

	self:downloadHall()

	
end

function UpdateScene:onExit_()
	cc.Director:getInstance():getTextureCache():removeTextureForKey("Resources/newResources/Login/back.png")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("Resources/newResources/Login/logo1.png")
end


return UpdateScene