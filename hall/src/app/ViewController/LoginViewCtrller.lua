--
-- Author: ChenShao
-- Date: 2015-11-26 10:03:36
--
local LoginViewCtrller = class("LoginViewCtrller")

function LoginViewCtrller:ctor()
	self:initAccountData()

	self:listenEvent()
end

function LoginViewCtrller:startConnect()
	self:createSocketConnect()
end

function LoginViewCtrller:initAccountData()
	self.username = cc.UserDefault:getInstance():getStringForKey("username", "")
	self.password = cc.UserDefault:getInstance():getStringForKey("password", "")

	if self.username ~= "" and self.password ~= "" then
		self.bAutoLogin = true
	else
		self.bAutoLogin = false
	end
end

function LoginViewCtrller:saveAccountData()
	cc.UserDefault:getInstance():setStringForKey("username", self.username)
	cc.UserDefault:getInstance():setStringForKey("password", self.password)
end

function LoginViewCtrller:createSocketConnect()
	cc.msgHandler:connectToLogin()
end

function LoginViewCtrller:listenEvent()
	app.runningScene.eventProtocol:addEventListener("LOGIN_SRV_CONNECTED", function(event)
		print("login socket connect 建立成功")

		if self.bAutoLogin then		
			self:saveAccountData()
			cc.lobbyController:login(self.username, self.password)
		end

		if cc.UserDefault:getInstance():getBoolForKey("isGuestLogin", false) then --游客自动登录
			cc.dataMgr.guestLogin = true
			local req = wnet.CL_TRAIL_LOGIN_REQ.new(cc.protocolNumber.PL_PHONE_CL_TRAIL_LOGIN_REQ_P)
			local device = require("framework.device")
			cc.msgHandler.socketLogin:send(req:bufferIn(device.getOpenUDID()):getPack())
		end
	end)

	app.runningScene.eventProtocol:addEventListener("PL_PHONE_LC_LOGIN_ACK_P", function(event)
		local info = ""
		if event.data.loginRet == wnet.ELoginResult.ELOGIN_RESULT_OK then
			cc.msgHandler:connectToLobby()
		elseif event.data.loginRet == 1 then info = "Validcode wrong"
		elseif event.data.loginRet == 2 then info = "Account not exist"
		elseif event.data.loginRet == 3 then info = "Password wrong"
		elseif event.data.loginRet == 4 then info = "Account logged in on the other host"
		elseif event.data.loginRet == 5 then info = "Account banned"
		elseif event.data.loginRet == 6 then info = "Account banned"
		elseif event.data.loginRet == 7 then info = "Account failed"
		elseif event.data.loginRet == 8 then info = "Account logged in"
		elseif event.data.loginRet == 9 then info = "System busy"
		elseif event.data.loginRet == 10 then info = "Dynamic pwd wrong" end

		if event.data.loginRet ~= wnet.ELoginResult.ELOGIN_RESULT_OK then
			local function clickOK()
                app.sceneSwitcher:enterScene("LoginScene")
            end
            app.holdOn.hide()
            app.msgBox.showMsgBoxEx({strMsg = info, funcOk = clickOK, isHideX = true})
		end
	end)

	
	app.runningScene.eventProtocol:addEventListener("LOBBY_SRV_CONNECTED", function(event)
		print("lobby socket connect 建立成功")
		cc.lobbyController:sendUserLoginReq()
	end)

	app.runningScene.eventProtocol:addEventListener("PL_PHONE_SC_USERLOGIN_ACK_P", function(event)
		app.holdOn.hide()
		local ret = event.data.lobbyResult
		if ret == 0 then
			print("<-===initView")
			if not cc.dataMgr.isBroken then
				app.runningScene:initView()
			end
		elseif ret == 1 then
			local function clickOK()
                app.sceneSwitcher:enterScene("LoginScene")
            end
            app.holdOn.hide()
            app.msgBox.showMsgBoxEx({strMsg = "Account logged in!", funcOk = clickOK, isHideX = true})
		else
			local function clickOK()
                app.sceneSwitcher:enterScene("LoginScene")
            end
            app.holdOn.hide()
            app.msgBox.showMsgBoxEx({strMsg = "Disconnect, login again!", funcOk = clickOK, isHideX = true})
		end
	end)
end

return LoginViewCtrller