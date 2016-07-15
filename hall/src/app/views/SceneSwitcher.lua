local SceneSwitcher = class("SceneSwitcher")
local scheduler = require("framework.scheduler")

function SceneSwitcher:ctor()
	self.viewFlag = nil
end

local function doThingsBeforEnterGameScene()
	local playingGame = cc.dataMgr.playingGame
	cc.FileUtils:getInstance():addSearchPath("src/" ..playingGame.."/res", true)
	cc.FileUtils:getInstance():addSearchPath(g_writablePath .."/update/" ..playingGame.."/res", true)

	--[[if g_isMahj(cc.dataMgr.playingGame) then
		cc.FileUtils:getInstance():addSearchPath("src/mahjres", true)
		cc.FileUtils:getInstance():addSearchPath(g_writablePath .."/update/mahjres", true)
	end]]

	local resHelper = require(playingGame .."/src/ResHelper")
	resHelper.loadSpriteFrames()
	resHelper.loadAudio()
end

function SceneSwitcher:enterScene(sceneName, viewFlag)
	print("enterScene is " ..sceneName)

	app.layBulletin = nil

	app.toast.clearToastLayers()
	-- do some things before switch scene
	cc.sceneTransFini = false
	self.viewFlag = viewFlag		--跨场景打开界面时，在onEnter内根据flag显示对应界面
	if sceneName == "GameScene" then
		
		doThingsBeforEnterGameScene()
		require("app.MyApp"):create({viewsRoot = cc.dataMgr.playingGame ..".src"}):enterScene("GameScene", "FADE", 0.5)
	else
		if app.runningScene and app.runningScene.name == "GameScene" then
			print("<----remove GameScene search")
			-- 清理原有游戏对象
			for k,v in pairs(cc.dataMgr.hallClearObj) do
				if v and v.onExit then
					v:onExit()
				end
				cc.dataMgr.hallClearObj[k] = nil
			end
			print("<----remove GameScene 222222")

			--cc.FileUtils:getInstance():removeSearchPath(true)
		--	cc.FileUtils:getInstance():removeSearchPath(true)

			--[[if g_isMahj(cc.dataMgr.playingGame) then
				cc.FileUtils:getInstance():removeSearchPath(true)
				cc.FileUtils:getInstance():removeSearchPath(true)
			end]]
		end
		require("app.MyApp"):create({viewsRoot = "hall/src/app/views"}):enterScene(sceneName, "FADE", 0.5)
		
	end
	-- do some things after switch scene

end

return SceneSwitcher
