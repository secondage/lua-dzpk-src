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
		elseif event.data.loginRet == 1 then info = "验证码错误"
		elseif event.data.loginRet == 2 then info = "用户不存在"
		elseif event.data.loginRet == 3 then info = "密码错误"
		elseif event.data.loginRet == 4 then info = "账号绑定在其它机器登录"
		elseif event.data.loginRet == 5 then info = "账号被禁用"
		elseif event.data.loginRet == 6 then info = "账号被封冻"
		elseif event.data.loginRet == 7 then info = "账号失效"
		elseif event.data.loginRet == 8 then info = "账号已经登录"
		elseif event.data.loginRet == 9 then info = "系统繁忙"
		elseif event.data.loginRet == 10 then info = "动态密码错误" end

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
            app.msgBox.showMsgBoxEx({strMsg = "账号已经登录!", funcOk = clickOK, isHideX = true})
		else
			local function clickOK()
                app.sceneSwitcher:enterScene("LoginScene")
            end
            app.holdOn.hide()
            app.msgBox.showMsgBoxEx({strMsg = "连接已断开,请重新登录!", funcOk = clickOK, isHideX = true})
		end
	end)
end

return LoginViewCtrller