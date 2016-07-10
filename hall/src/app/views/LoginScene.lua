require "data.protocolPublic"

local LoginScene = class("LoginScene", cc.load("mvc").ViewBase)

LoginScene.RESOURCE_FILENAME = "hall/MainScene.csb"

local inputLimit = require("app.func.InputUtil")
local animationUtils = require("app.func.AnimationUtils")
local ANIMATION_BTN_FENGLEI = btnFengLeiAnimation
local ANIMATION_BTN_GUEST = btnGuestAnimation
local ANIMATION_LOGO = logoAnimation

function LoginScene:onCreate()
	self.name = "LoginScene"
	self.flag = 0		--0:最初状态 1:登录 2:注册
	printf("resource node = %s", tostring(self:getResourceNode()))
	self.eventProtocol = require("framework.components.behavior.EventProtocol").new()
	cc.msgHandler:setPlayingScene(self)

	app.loginScene = self
	--self.isautologin = false
	cc.dataMgr.guestLogin = false

	app.runningScene = self

	local imgLogo = self:getResourceNode():getChildByName("Panel_1"):hide()
	
	
	local layDengLuZhuChe = self:getResourceNode():getChildByName("Node_dengluzhuce"):hide()
	self.layDengLuZhuChe = layDengLuZhuChe

	local nodeAccInfo = self:getResourceNode():getChildByName("Node_accInfo"):hide()
	self.nodeAccInfo = nodeAccInfo
	local posNodeAccInfo = nodeAccInfo:getPosition()
	check = nodeAccInfo:getChildByName("CheckBoxRem"):hide()
	local btnLogin = layDengLuZhuChe:getChildByName("Button_login")
	self.btnLogin = btnLogin
	local btnReg = layDengLuZhuChe:getChildByName("Button_btnReg")
	self.btnReg = btnReg

	self.registerLayer = nil
	btnReg:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			self:logoAction()
			if self.registerLayer == nil then
				self.registerLayer = require("app.views.layers.RegisterLayer"):createLayer():addTo(self, 100)
			end

			app.popLayer.showEx(self.registerLayer:getChildByName("Panel_infoInputLayer"))
			self.registerLayer:show()
			layDengLuZhuChe:getChildByName("Button_back"):hide()
			self.flag = 2
		end
	end)
	btnLogin:addTouchEventListener(handler(self, LoginScene.onBtnLoginClick))
	btnLogin:setPressedActionEnabled(true)
	btnReg:setPressedActionEnabled(true)


	local layType = self:getResourceNode():getChildByName("Panel_2")
	self.layType = layType
	local btnFengLeiLogin = layType:getChildByName("Button_fengleihao"):hide()
	btnFengLeiLogin:setPressedActionEnabled(true)
	self.btnFengLeiLogin = btnFengLeiLogin
	btnFengLeiLogin:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			self:logoAction()
			layType:hide()
			
			self.flag = 1
		end
	end)
	nodeAccInfo:show()
	layDengLuZhuChe:show()

	local btnBackToLayType = layDengLuZhuChe:getChildByName("Button_back"):hide()
	btnBackToLayType:setPressedActionEnabled(true)
	btnBackToLayType:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			self:logoAction(true)
			layType:show()
			nodeAccInfo:hide()
			layDengLuZhuChe:hide()
			self.flag = 0
		end
	end)

	local btnGuestLogin = layType:getChildByName("Button_youke"):hide()
	btnGuestLogin:setPressedActionEnabled(true)
	self.btnGuestLogin = btnGuestLogin
	btnGuestLogin:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			app.holdOn.show("正在获取登录信息...")
			self:reqGuestLogin()
		end
	end)


	self.username = cc.UserDefault:getInstance():getStringForKey("username", "")
	self.password = cc.UserDefault:getInstance():getStringForKey("password", "")

	local check = nodeAccInfo:getChildByName("CheckBoxRem")
	check:setSelected(true)
	
	local accountInputTmp = nodeAccInfo:getChildByName("TextField_tfAcc"):hide()
	--local accountInputBg = nodeAccInfo:getChildByName("Image_accbg"):getChildByName("Image_3"):hide()
	local accountInput = app.EditBoxFactory:createEditBoxByImage(accountInputTmp, "请输入用户名", "editboxbg0.png", 50)
	accountInput:setTag(10)
	accountInput:setOpacity(0)
	accountInput:setFontColor(cc.c4b(255, 255, 255, 255))
	accountInput:setPlaceholderFontColor(cc.c4b(255, 255, 255, 255))
	accountInput:registerScriptEditBoxHandler(function(name, sender)
		print("name = " ..name)
		if name == "began" then
			self.username = ""
			self.password = ""
		elseif name == "changed" then
			self.pwdInput:setString("")
		elseif name == "ended" then
			self.username = accountInput:getString()
		end
	end)
	
	self.accountInput = accountInput

	local pwdInputTmp = nodeAccInfo:getChildByName("TextField_tfPwd"):hide()
	--local pwdInputBg = nodeAccInfo:getChildByName("Image_pwdbg"):getChildByName("Image_3"):hide()
	local pwdInput = app.EditBoxFactory:createEditBoxByImage(pwdInputTmp, "请输入密码", "editboxbg0.png", 50)
	pwdInput:setTag(11)
	pwdInput:setOpacity(0)
	pwdInput:setReturnType(1)
	pwdInput:setFontColor(cc.c4b(255, 255, 255, 255))
	pwdInput:setPlaceholderFontColor(cc.c4b(255, 255, 255, 255))
	pwdInput:registerScriptEditBoxHandler(function(name, sender)
		if name == "began" then
			pwdInput:setString("")
			self.password = ""
		elseif name == "return" then
			self:onBtnLoginClick(nil, 2)
		end
	end)
	pwdInput:setInputFlag(0)
	self.pwdInput = pwdInput

	if self.username ~= "" and self.password ~= "" then
	--	self.isautologin = true --屏蔽该句  == 屏幕自动登录
		accountInput:setString(self.username)
		pwdInput:setString("********")	
	end

	self:registerKey()

	require("app.views.Test").new():addTo(self)

	-- 清理原有游戏对象
	for k,v in pairs(cc.dataMgr.hallClearObj) do
		if v and v.onExit then
			v:onExit()
		end
		cc.dataMgr.hallClearObj[k] = nil
	end

	self:removeUnusedTextures()
end

function LoginScene:logoAction(isBack)
	--[[
	local node = self:getResourceNode():getChildByName("Panel_1")
	local pos = cc.p(0, 55)
	if isBack then
		pos = cc.p(0, 0)
	end
	local actMoveBy = cc.MoveTo:create(0.15, pos)

	node:runAction(actMoveBy)
	]]
end


function LoginScene:onEnter_()
	self:listenEvent()
	cc.sceneTransFini = true
	cc.dataMgr:clear()
end


function LoginScene:reqGuestLogin()
	cc.dataMgr.guestLogin = true
	local req = wnet.CL_TRAIL_LOGIN_REQ.new(cc.protocolNumber.PL_PHONE_CL_TRAIL_LOGIN_REQ_P)
	local device = require("framework.device")
	cc.msgHandler.socketLogin:send(req:bufferIn(device.getOpenUDID()):getPack())


end

function LoginScene:onExit_()
	self.eventProtocol:removeAllEventListeners()
	app.loginScene = nil

	animationUtils.removeAnimationCacheByName(ANIMATION_BTN_FENGLEI)
	animationUtils.removeAnimationCacheByName(ANIMATION_BTN_GUEST)
end

function LoginScene:onBtnLoginClick(obj, type)
	if type == 2 then
		app.audioPlayer:playClickBtnEffect()
		
		local accountInput = self.accountInput
		local pwdInput = self.pwdInput
		local username = accountInput:getString()
		local password = pwdInput:getString()

		if username == "" then
			app.toast.show("账号不能为空")
			return
		end
		if password == "" then
			app.toast.show("密码不能为空")
			return
		end

		app.holdOn.showEx("登录中...", {
			listener = function()
				pickBtn(self.btnLogin)
				pickBtn(self.btnReg)
				app.msgBox.showMsgBox("连接失败,请检查网络是否连接")
			end
		})

		banBtn(self.btnLogin)
		banBtn(self.btnReg)
		if self.username ~= "" and self.password ~= "" then
			cc.lobbyController:login(self.username, self.password)
		elseif username ~= "" and password ~= "" then
			self:login(username, password)
		end

		cc.UserDefault:getInstance():setBoolForKey("isGuestLogin", false) --取消游客登陆标识
	end
end

function LoginScene:login(strUserName, strPwd)
	local md5 = MD5:create()
	local pwd = md5:ComplexMD5(strPwd)

	self.username = strUserName
	self.password = pwd
	cc.lobbyController:login(strUserName, pwd)
end

function LoginScene:listenEvent()
	self.eventProtocol:addEventListener("PL_PHONE_LC_LOGIN_ACK_P", handler(self, LoginScene.onPL_PHONE_LC_LOGIN_ACK_P))
	self.eventProtocol:addEventListener("LOGIN_SRV_CONNECTED", handler(self, LoginScene.onLOGIN_SRV_CONNECTED))
	self.eventProtocol:addEventListener("LOBBY_SRV_CONNECTED", handler(self, LoginScene.onLOBBY_SRV_CONNECTED))
	self.eventProtocol:addEventListener("PL_PHONE_SC_USERLOGIN_ACK_P", handler(self, LoginScene.onPL_PHONE_SC_USERLOGIN_ACK_P))
	self.eventProtocol:addEventListener("ON_RESUME", function()
		cc.msgHandler:disconnectFromLogin()
		cc.msgHandler:connectToLogin()
	end)

	----////////////以下为断线重连用
	self.eventProtocol:addEventListener("PL_PHONE_SC_GAMELIST_ACK_P", function() --获取房间列表回复
		app.holdOn.show("正在获取房间内信息...", 0.5)
		for i = 0, #cc.dataMgr.gameList.vecGameInfo - 1 do
			local v = cc.dataMgr.gameList.vecGameInfo[i + 1]
			if  cc.dataMgr.selectServerID == v.svrInfo.srvID then
				cc.dataMgr.selectedGameSrv = table.deepcopy(v.svrInfo)
				cc.dataMgr.selectedGameInfo = table.deepcopy(v.gameInfo)

				cc.dataMgr.maxTableCount = v.gameInfo.tableNum
				cc.dataMgr.tablePlyNum = v.gameInfo.tablePlyNum
				cc.dataMgr.gameName = v.gameInfo.gameName
				cc.dataMgr.selectGameType = v.gameInfo.gameType

				--断线重连从数据库获取游戏名
				local db = require("app.func.GameDB")
				--cc.dataMgr.playingGame = "ccmj"
				cc.dataMgr.playingGame = db.getGameNameByGameID(cc.dataMgr.selectGameID)

				app.taskLogic:initData() 

				cc.msgHandler:connectToGame(v.svrInfo.srvIP, v.svrInfo.srvPort)
				break
			end	
		end
	end)

	self.eventProtocol:addEventListener("GAME_SRV_CONNECTED", function() --连接lobby服务器
		print("game srv connected..")
		cc.lobbyController:sendGameLoginReq()
	end)

	self.eventProtocol:addEventListener("PL_PHONE_GC_LOGIN_ACK_P", function(event) --请求登陆lobby服务器回复
		if event.data.bRet == wnet.EGameResult.EGAME_RESULT_OK then
			if cc.dataMgr.withoutRoomScene == false then
				app.sceneSwitcher:enterScene("RoomScene")
			else
				app.sceneSwitcher:enterScene("GameScene")
			end
			cc.dataMgr.gamingState = true
		else
			print("login game server failed. " .. event.data.bRet)
		end
	end)

	self.eventProtocol:addEventListener("GC_ENTERTABLE_ACK_P", function(event)
		local ret = event.data.result
		if ret == wnet.EnterTable_Result.EnterTable_OK then
			cc.dataMgr.isWatcher = false
			app.sceneSwitcher:enterScene("GameScene")
		end
	end)
	------------------------------///////////////////
end

function LoginScene:onPL_PHONE_LC_LOGIN_ACK_P(event)
	
	if event.data.loginRet == wnet.ELoginResult.ELOGIN_RESULT_OK then
		--save account
		local nodeAccInfo = self:getResourceNode():getChildByName("Node_accInfo")
		local check = nodeAccInfo:getChildByName("CheckBoxRem")
		if check:isSelected() == true then
			cc.UserDefault:getInstance():setStringForKey("username", self.username)
			cc.UserDefault:getInstance():setStringForKey("password", self.password)
		else
			cc.UserDefault:getInstance():setStringForKey("username", "")
			cc.UserDefault:getInstance():setStringForKey("password", "")
		end
		cc.msgHandler:connectToLobby()
	else
		pickBtn(self.btnLogin)
		pickBtn(self.btnReg)
		cc.hideLoading()
		print("onPL_PHONE_LC_LOGIN_ACK_P failed "..event.data.loginRet)
		if event.data.loginRet == 1 then app.toast.show("验证码错误")
		elseif event.data.loginRet == 2 then app.toast.show("用户不存在")
		elseif event.data.loginRet == 3 then app.toast.show("密码错误")
		elseif event.data.loginRet == 4 then app.toast.show("账号绑定在其它机器登录")
		elseif event.data.loginRet == 5 then app.toast.show("账号被禁用")
		elseif event.data.loginRet == 6 then app.toast.show("账号被封冻")
		elseif event.data.loginRet == 7 then app.toast.show("账号失效")
		elseif event.data.loginRet == 8 then app.toast.show("账号已经登录")
		elseif event.data.loginRet == 9 then app.toast.show("系统繁忙")
		elseif event.data.loginRet == 10 then app.toast.show("动态密码错误") end
	end
end

-------------
local function showDialogue(self)
	app.holdOn.show("连接中...", 0, self, handler(self, self.showDialogue))
end

function LoginScene:showDialogue()
	app.msgBox.showMsgBoxTwoBtn("再次执行！", function()
		showDialogue(self)
	end)
end
-------------

function LoginScene:onEnterTransitionFinish_()
	--showDialogue(self)		
	app.holdOn.show("连接中...", 0, self, function()
		cc.msgHandler:connect("login")
		app.msgBox.showMsgBox("连接失败,请检查网络是否连接")
	end)
	
	cc.msgHandler:connectToLogin()

end

function LoginScene:removeUnusedTextures()
	cc.Director:getInstance():getTextureCache():removeTextureForKey("Resources/newResources/Login/back.png")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("Resources/newResources/Login/logo1.png")
end

function LoginScene:onLOGIN_SRV_CONNECTED()
	app.holdOn.hide()
	print("<----1111111111onLOGIN_SRV_CONNECTED")

	--[[local callfunc = cc.CallFunc:create(function()
		print("<----auto")
		if self.isautologin and cc.dataMgr.isChangeAccLogin == false then	
			app.holdOn.showEx("登录中...", {
				listener = function()
					app.msgBox.showMsgBox("连接失败,请检查网络是否连接")
				end
			})
			cc.lobbyController:login(self.username, self.password)
		end
	end)]]
	
	local layType = self:getResourceNode():getChildByName("Panel_2")
	--layType:getChildByName("Button_fengleihao"):show()
	--layType:getChildByName("Button_youke"):hide()

	local imgLogo = self:getResourceNode():getChildByName("Panel_1"):hide()
	--[[
	local action = cc.CSLoader:createTimeline("hall/MainScene.csb")
	self:runAction(action)
	action:gotoFrameAndPlay(0, false)

	print("<----auto2222222222")
	local delayTime = cc.DelayTime:create(1.0)
	self:runAction(cc.Sequence:create(delayTime, callfunc))
	]]

	--[[local imgLogo = self:getResourceNode():getChildByName("Panel_1"):getChildByName("Image_tu2")
	local logoFirstFrame = animationUtils.createAnimation("logo_", 14, ANIMATION_LOGO, 0.08):addTo(imgLogo)
	animationUtils.playAnimationByName(logoFirstFrame, ANIMATION_LOGO, {x = imgLogo:getContentSize().width / 2, 
		y = imgLogo:getContentSize().height / 2}, {delay = 1.5, removeSelf = true})
	
	local btnFengLeiFirstFrame = animationUtils.createAnimation("btn_", 10, ANIMATION_BTN_FENGLEI, 0.08):addTo(self.btnFengLeiLogin)
	animationUtils.playAnimationByName(btnFengLeiFirstFrame, ANIMATION_BTN_FENGLEI, {x = self.btnFengLeiLogin:getContentSize().width / 2, 
		y = self.btnFengLeiLogin:getContentSize().height / 2}, {delay = 2.5, removeSelf = true})

	local btnGuestFirstFrame = animationUtils.createAnimation("btn_", 10, ANIMATION_BTN_GUEST, 0.08):addTo(self.btnGuestLogin)
	animationUtils.playAnimationByName(btnGuestFirstFrame, ANIMATION_BTN_GUEST, {x = self.btnGuestLogin:getContentSize().width / 2, 
		y = self.btnGuestLogin:getContentSize().height / 2}, {delay = 2.5, removeSelf = true})
]]
	--app.audioPlayer:playEffectByName("fenglei_logo")

end


function LoginScene:onLOBBY_SRV_CONNECTED()
	--change to lobby scene
	print("-----222222222222onLOBBY_SRV_CONNECTED")
	cc.lobbyController:sendUserLoginReq()

end


function LoginScene:onPL_PHONE_SC_USERLOGIN_ACK_P(event)
	self.isChangeAccLogin = false
	app.holdOn.hide()
	local ret = event.data.lobbyResult

	if ret == 0 then
		if not cc.dataMgr.isBroken then
			cc.dataMgr.isCommonLogin = true
			app.sceneSwitcher:enterScene("HallScene")
		end
	elseif ret == 1 then
		app.msgBox.showMsgBox("账号已经登录!")
	else
		
		app.msgBox.showMsgBox("系统繁忙!")
	end
	
	if ret ~= 0 then
		pickBtn(self.btnLogin)
		pickBtn(self.btnReg)
	end
end

function LoginScene:registerKey()
	local keyListener = cc.EventListenerKeyboard:create()
	local function onKeyRelease(code, event)
		if code == cc.KeyCode.KEY_BACK  or code == cc.KeyCode.KEY_BACKSPACE then
			if app.holdOn.holdOnLayer ~= nil then
				--app.holdOn:hide()
			elseif app.msgBox.root ~= nil then
				app.msgBox.hide()
			elseif self.flag == 1 then
				self.layType:show()
				self.nodeAccInfo:hide()
				self.layDengLuZhuChe:hide()
				self.flag = 0
			elseif self.flag == 2 then
				if self.registerLayer ~= nil then
					self.registerLayer:hide()
					self.registerLayer = nil
				end
				self.flag = 1
			else
				if not cc.sceneTransFini then return end
				local function funcOk()
					cc.Director:getInstance():endToLua()
				end
				app.msgBox.showMsgBoxTwoBtn("是否退出应用？", funcOk)
			end
		end
	end
	keyListener:registerScriptHandler(onKeyRelease, cc.Handler.EVENT_KEYBOARD_RELEASED)
	local eventDispatch = self:getEventDispatcher()
	eventDispatch:addEventListenerWithSceneGraphPriority(keyListener, self)
end

return LoginScene
