--
-- Author: ChenShao
-- Date: 2015-08-19 15:57:26
--
local SetttingCtrlLayer = class("SetttingCtrlLayer")
--local audioPlayer = require("app.func.AudioPlayer")
local inputUtil = require("app.func.InputUtil")

local function procUI(self)

	self.panelRoot = self.settingLayer:getChildByName("Panel_root")
	local panelRoot = self.panelRoot
	--音乐
	local sliderMusic = panelRoot:getChildByName("Slider_music")
	local checkBoxMusic = panelRoot:getChildByName("CheckBox_music")
	sliderMusic:addEventListener(function (obj, type)
		if type == 0 then
			local musicVolume = obj:getPercent() / 100
			print("musicVolume = " ..musicVolume)
			app.audioPlayer:setMusicVolume(musicVolume)
			cc.UserDefault:getInstance():setFloatForKey("musicVolume", musicVolume)
			checkBoxMusic:setSelected(musicVolume ~= 0)
			cc.UserDefault:getInstance():setBoolForKey("isMusic", (musicVolume ~= 0) and true or false)

			--print("app.audioPlayer:isMusicPlaying() = " ..app.audioPlayer:isMusicPlaying() )
			if app.audioPlayer:isMusicPlaying() == false then
				if app.runningScene.name == "HallScene" then 
					app.audioPlayer:playHallMusic()
				else
					app.audioPlayer:playGamingMusic()
				end
			end
		end
	end)
	local musicVolume = cc.UserDefault:getInstance():getFloatForKey("musicVolume", 1)
	print("musicVolume = " ..musicVolume)
	sliderMusic:setPercent(musicVolume * 100)
	checkBoxMusic:setSelected(musicVolume ~= 0)
	checkBoxMusic:addEventListener(function(obj, type)
		app.audioPlayer:playClickBtnEffect()
		local musicVolume = 0
		if type == 0 then
			print("open music")
			musicVolume = 0.5
			cc.UserDefault:getInstance():setBoolForKey("isMusic", true)
			if app.runningScene.name == "HallScene" then 
				app.audioPlayer:playHallMusic()
			else
				app.audioPlayer:playGamingMusic()
			end
		else 
			musicVolume = 0
			print("close music")
			cc.UserDefault:getInstance():setBoolForKey("isMusic", false)
			app.audioPlayer:stopMusic()
		end
		app.audioPlayer:setMusicVolume(musicVolume)
		cc.UserDefault:getInstance():setFloatForKey("musicVolume", musicVolume)
		sliderMusic:setPercent(musicVolume * 100)
	end)

	--音效
	local sliderEffect = panelRoot:getChildByName("Slider_effect")
	local checkBoxEffect = panelRoot:getChildByName("CheckBox_effect")
	sliderEffect:addEventListener(function (obj, type)
		if type == 0 then
			
			local effectVolume = obj:getPercent() / 100
			app.audioPlayer:setEffectsVolume(effectVolume)
			cc.UserDefault:getInstance():setFloatForKey("effectVolume", effectVolume)
			checkBoxEffect:setSelected(effectVolume ~= 0)
			cc.UserDefault:getInstance():setBoolForKey("isEffect", (effectVolume ~= 0) and true or false)
		end
	end)
	local effectVolume = cc.UserDefault:getInstance():getFloatForKey("effectVolume", 1)
	sliderEffect:setPercent(effectVolume * 100)
	checkBoxEffect:setSelected(effectVolume ~= 0)
	checkBoxEffect:addEventListener(function(obj, type)
		app.audioPlayer:playClickBtnEffect()
		local effectVolume = 0
		if type == 0 then
			effectVolume = 0.5
			cc.UserDefault:getInstance():setBoolForKey("isEffect", true)
		else 
			effectVolume = 0
			cc.UserDefault:getInstance():setBoolForKey("isEffect", false)
		end
		app.audioPlayer:setEffectsVolume(effectVolume)
		cc.UserDefault:getInstance():setFloatForKey("effectVolume", effectVolume)
		sliderEffect:setPercent(effectVolume * 100)
	end)

	--震动
	local checkBoxShock = panelRoot:getChildByName("CheckBox_shock")
	--local txtShockState = panelRoot:getChildByName("Text_shock_state")
	checkBoxShock:addEventListener(function (obj, type)
		app.audioPlayer:playClickBtnEffect()
		checkBoxShock:setSelected(type == 0)
		cc.UserDefault:getInstance():setBoolForKey("isShock", type == 0)
		--txtShockState:setString((type == 0) and "开" or "关")
	end)
	local isShock = cc.UserDefault:getInstance():getBoolForKey("isShock", false)
	checkBoxShock:setSelected(isShock)
	--txtShockState:setString(isShock and "开" or "关")

	--切换账号
	local btnSwitchAccount =panelRoot:getChildByName("Button_switchAccount")
	btnSwitchAccount:setPressedActionEnabled(true)
	btnSwitchAccount:addTouchEventListener(function (obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			
			local function onButtonClicked(event)
				cc.UserDefault:getInstance():setStringForKey("username", "")
				cc.UserDefault:getInstance():setStringForKey("password", "")
    			
    			cc.dataMgr.isChangeAccLogin = true
    			cc.msgHandler:disconnectFromLobby()
				
				app.sceneSwitcher:enterScene("LoginScene")
    		
			end
			app.msgBox.showMsgBoxTwoBtn("Change Account?", onButtonClicked)
		end
	end)



	--关闭按钮
	local btnClose = panelRoot:getChildByName("Button_close")
	btnClose:setPressedActionEnabled(true)
	btnClose:addTouchEventListener(function (obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			self.settingLayer:hide()
			self.settingLayer:removeSelf()
			
			if app.runningScene.name == "HallScene" or app.runningScene.name == "RoomScene" then
				app.runningScene.nPopLayers = app.runningScene.nPopLayers - 1
			end

			--取消模糊
			--[[cancelBlurBg(app.hallScene)
			app.hallScene.gameListLayer:show()]]
			--
		end
	end)

	--更新按钮
	local btnUpdate = panelRoot:getChildByName("Button_update")
	btnUpdate:setPressedActionEnabled(true)
	btnUpdate:hide()
	btnUpdate:addTouchEventListener(function (obj, type)
		if type == 2 then

		end
	end)

	--版本号显示
	local function setVersionCode()
		local txtVersionCode = panelRoot:getChildByName("Text_versionCode")
		local targetPlatform = cc.Application:getInstance():getTargetPlatform()
		if targetPlatform ~= cc.PLATFORM_OS_WINDOWS then
			local bridge = require("app.func.Bridge")
			local ret = bridge.getAppInfo()
			if ret ~= nil then
				txtVersionCode:setString(ret.app_version .."." ..ret.app_build)
			end
		end
	end
	setVersionCode()

	--账号相关
	local txtNickName = panelRoot:getChildByName("Text_userNickName")
	local nickName = inputUtil.getReducedString(cc.dataMgr.lobbyUserData.lobbyUser.strNickNamebuf, 12, "..")
	txtNickName:setString(nickName)


	local strPhone = panelRoot:getChildByName("Text_versionCode_0")
	strPhone:setString("4008-167-667"):hide()

	panelRoot:getChildByName("Text_13_0"):hide()

	local btnPhone = panelRoot:getChildByName("Button_Phone"):hide()
	btnPhone:setPressedActionEnabled(true)
	btnPhone:addTouchEventListener(function (obj, type)
		if type == 2 then
			if not g_Platform_Win32 then
				local bridge = require("app.func.Bridge")
				bridge.callPhone(strPhone:getString())
			end
		end
	end)

	local txtNameBg = panelRoot:getChildByName("Image_5")

	if app.runningScene.name == "RoomScene" then
		btnSwitchAccount:hide()
		txtNickName:hide()
		txtNameBg:hide()
	else
		btnSwitchAccount:show()
		txtNickName:show()
		txtNameBg:show()
	end
end

function SetttingCtrlLayer:createLayer()
	self.settingLayer = cc.CSLoader:createNode("Layers/SettingLayer.csb")
	procUI(self)

	self.settingLayer:onNodeEvent("exit", function()
		print("<------exit self.settingLayer")
		app.runningScene.settinglayer = nil
	end)
	return self.settingLayer
end

return SetttingCtrlLayer