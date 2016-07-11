--
-- Author: ChenShao
-- Date: 2015-09-15 19:41:27
--
local RegisterLayerCtrller = class("RegisterLayer")

local inputLimit = require("app.func.InputUtil")
local scheduler = require("framework.scheduler")
local inputCheck = require("app.func.InputCheck")
local device = require("framework.device")

local function sendRegReq(accInput, niceName, pwdInput)
	local data = {}
	data.strAccount = accInput
	data.strNickName = niceName
	data.strPasswd = pwdInput
	data.icon = 1
	data.gender = 0
	data.phoneReg = 1
	data.strMac = device.getOpenUDID()
	cc.lobbyController:sendRegReq(data)
end

function RegisterLayerCtrller:clearUI()

end

function RegisterLayerCtrller:clearPtUI()
	self.txtAccInput:setString("")
	self.txtNickNameInput:setString("")
	self.txtPwdInput:setString("")
	self.phoneRegLayer1:hide()
	self.phoneRegLayer2:hide()
end

function RegisterLayerCtrller:clearPhoneUI()
	self.txtPhoneNumber_phone:setString("")
	self.txtAuth_phone:setString("")
	--self.txtAuth_phone:setTouchEnabled(true)
	self.txtPhoneNickName_phone:setString("")
	self.txtPhonePwd_phone:setString("")
end

local function procUI(self)
	self.infoInputLayer = self.registerLayer:getChildByName("Panel_infoInputLayer")
	self.ptRegLayer = self.infoInputLayer:getChildByName("Panel_putongzhuce"):hide()
	self.phoneRegLayer1 = self.infoInputLayer:getChildByName("Panel_shoujizhuce1"):show()
	self.phoneRegLayer2 = self.infoInputLayer:getChildByName("Panel_shoujizhuce2"):hide()

	local checkBoxPt = self.infoInputLayer:getChildByName("CheckBox_ptreg"):hide()
	checkBoxPt:setSelected(false)
	checkBoxPt:setEnabled(true)
	checkBoxPt.userdata = self.ptRegLayer
	self.ptRegLayer:show()

	local checkBoxPhone = self.infoInputLayer:getChildByName("CheckBox_shoujizhuce"):hide()
	checkBoxPhone:setSelected(true)
	checkBoxPhone:setEnabled(false)
	checkBoxPhone.userdata = self.phoneRegLayer1
	self.phoneRegLayer1:hide()

	local function setSelected(obj, type)
		if obj == checkBoxPt then
			checkBoxPhone:setSelected(false)
			checkBoxPhone.userdata:hide()
			checkBoxPhone:setEnabled(true)
			self:clearPtUI()
		else
			checkBoxPt:setSelected(false)
			checkBoxPt.userdata:hide()
			checkBoxPt:setEnabled(true)
			self:clearPhoneUI()
			self.phoneRegLayer1:show()
			self.phoneRegLayer2:hide()
		end
		
		obj:setSelected(true)
		obj.userdata:show()
		obj:setEnabled(false)
	end
	checkBoxPt:addEventListener(setSelected)
	checkBoxPhone:addEventListener(setSelected)

	local imgbg = self.infoInputLayer:getChildByName("Image_dikuang")
	imgbg:setTouchEnabled(true)

	local btnBack = self.infoInputLayer:getChildByName("Button_btnBack")
	btnBack:setPressedActionEnabled(true)
	local function onBtnBack(sender, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			self.registerLayer:removeSelf()
			app.loginScene.registerLayer = nil

			--app.loginScene:getResourceNode():getChildByName("Node_dengluzhuce"):getChildByName("Button_back"):show()
		end
	end
	btnBack:addTouchEventListener(onBtnBack)

	self:procPtLayer()
	self:procPhonePayer()
	self:procPhonePayer_2()
end

function RegisterLayerCtrller:procPhonePayer_2()
	local txtAccount = self.phoneRegLayer2:getChildByName("Text_account")
	self.txtAccount_phone = txtAccount
	


	local txtPhoneNickName_phone_Temp = self.phoneRegLayer2:getChildByName("TextField_inputNickName")
	txtPhoneNickName_phone = app.EditBoxFactory:createEditBoxByImage(txtPhoneNickName_phone_Temp, "Please input nickName")
	self.txtPhoneNickName_phone = txtPhoneNickName_phone

	local txtPhonePwd_phone_Temp = self.phoneRegLayer2:getChildByName("TextField_inputPwd")
	txtPhonePwd_phone = app.EditBoxFactory:createEditBoxByImage(txtPhonePwd_phone_Temp, "Please input password")
	self.txtPhonePwd_phone = txtPhonePwd_phone

	local btnOK = self.phoneRegLayer2:getChildByName("Button_btnOK")
	btnOK:setPressedActionEnabled(true)
	btnOK:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()

			local nickName = txtPhoneNickName_phone:getString()
			local pwdInput = MD5:create():ComplexMD5(txtPhonePwd_phone:getString())

			local mutipleNickName = UTF82Mutiple(nickName)

			if string.len(mutipleNickName) == 0 then
				app.toast.show("Nickname empty")
				return
			end

			if string.len(mutipleNickName) < 6 or string.len(mutipleNickName) > 16 then
				app.toast.show("昵称长度必须为6~16个字符,请重新输入")
				return
			end

			if string.len(txtPhonePwd_phone:getString()) == 0 then
				app.toast.show("密码不能为空")
				return
			end

			if string.len(txtPhonePwd_phone:getString()) < 6 or string.len(txtPhonePwd_phone:getString()) > 16 then
				app.toast.show("密码长度不符合")
				return
			end

			if inputCheck.checkIsSingleType(txtPhonePwd_phone:getString()) then
				app.toast.show("密码必须为6~16个英文+数字的组合,请重新输入")
				return
			end


			app.holdOn.show("注册中,请稍候...", 0.1)
			self.accInput = txtAccount:getString()
			self.nickName = nickName
			self.pwdInput = pwdInput
			sendRegReq(self.accInput, mutipleNickName, pwdInput)
		end
	end)
end

function RegisterLayerCtrller:procPhonePayer()
	local txtPhoneNumber_phone_Temp = self.phoneRegLayer1:getChildByName("TextField_inputAccount")
	txtPhoneNumber_phone = app.EditBoxFactory:createEditBoxByImage(txtPhoneNumber_phone_Temp, "请输入手机号码")
	txtPhoneNumber_phone:setInputMode(2)
	txtPhoneNumber_phone:setMaxLength(11)
	self.txtPhoneNumber_phone = txtPhoneNumber_phone

	local txtAuth_phone_temp = self.phoneRegLayer1:getChildByName("TextField_inputNickName")
	txtAuth_phone = app.EditBoxFactory:createEditBoxByImage(txtAuth_phone_temp, "请输入验证码")
	txtAuth_phone:setInputMode(2)
	txtAuth_phone:setMaxLength(6)
	self.txtAuth_phone = txtAuth_phone

	local btnGetAuth = self.phoneRegLayer1:getChildByName("Button_6")
	btnGetAuth:setPressedActionEnabled(true)
	btnGetAuth:setTitleText("获取验证码")
	self.btnGetAuth = btnGetAuth
	btnGetAuth:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			local strPhoneNum = txtPhoneNumber_phone:getString()
			
			if string.len(strPhoneNum) ~= 11 or not inputCheck.checkIsNumberOnly(strPhoneNum) then
				app.toast.show("手机号填写不正确")
				return
			end

			if not inputCheck.checkPhoneNum(strPhoneNum) then
				app.toast.show("手机号填写不正确")
				return
			end

			print("strPhoneNum = " ..strPhoneNum)
			btnGetAuth:setTouchEnabled(false)
			cc.lobbyController:verifyPhoneNumber(strPhoneNum)
			
		end
	end)

	local btnOK_1 = self.phoneRegLayer1:getChildByName("Button_btnOK")
	btnOK_1:setPressedActionEnabled(true)
	btnOK_1:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()

			local strPhoneNum = txtPhoneNumber_phone:getString()
			if string.len(strPhoneNum) ~= 11 or not inputCheck.checkIsNumberOnly(strPhoneNum) then
				app.toast.show("手机号填写不正确")
				return
			end

			if not inputCheck.checkPhoneNum(strPhoneNum) then
				app.toast.show("手机号填写不正确")
				return
			end
			
			local strAuth = txtAuth_phone:getString()
			if string.len(strAuth) ~= 6 or not inputCheck.checkIsNumberOnly(strAuth) then
				app.toast.show("验证码填写不正确")
				return
			end

			print("strAuth = " ..strAuth)
			app.holdOn.show("正在验证...")
			self.strPhoneNum = txtPhoneNumber_phone:getString()
			cc.lobbyController:verifyValidCode(self.strPhoneNum, strAuth)
		end
	end)
end

function RegisterLayerCtrller:procPtLayer()
	local txtAccInputTmp = self.ptRegLayer:getChildByName("TextField_inputAccount"):hide()
	txtAccInput = app.EditBoxFactory:createEditBoxByImage(txtAccInputTmp, "请输入用户名")
	self.txtAccInput = txtAccInput

	local txtNickNameInputTmp = self.ptRegLayer:getChildByName("TextField_inputNickName"):hide()
	txtNickNameInput = app.EditBoxFactory:createEditBoxByImage(txtNickNameInputTmp, "请输入昵称")
	self.txtNickNameInput = txtNickNameInput

	local txtPwdInputTmp = self.ptRegLayer:getChildByName("TextField_inputPwd")
	txtPwdInput = app.EditBoxFactory:createEditBoxByImage(txtPwdInputTmp, "请输入密码")
	self.txtPwdInput = txtPwdInput
	txtPwdInput:setInputFlag(0)
	txtPwdInput:registerScriptEditBoxHandler(function(name, sender)
		if name == "began" then
			txtPwdInput:setString("")
		elseif name == "changed" then
			local pwdInput = txtPwdInput:getString()
			txtPwdInput:setString(inputLimit.ban_ZH_input(pwdInput))
		end
	end)

	local btnOK = self.ptRegLayer:getChildByName("Button_btnOK")
	btnOK:setPressedActionEnabled(true)
	local function onPwdInput(object, event)
		if event == ccui.TextFiledEventType.delete_backward then
			txtPwdInput:setString("")
		end
		if event == ccui.TextFiledEventType.insert_text then
			local pwdInput = txtPwdInput:getString()
			txtPwdInput:setString(inputLimit.ban_ZH_input(pwdInput))
		end
	end
	--txtPwdInput:addEventListener(onPwdInput)

	local function onBtnOK(sender, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			local accInput = txtAccInput:getString()
			local nickName = txtNickNameInput:getString()
			local pwdInput = MD5:create():ComplexMD5(txtPwdInput:getString())

			local mutipleAccInput = UTF82Mutiple(accInput)
			local mutipleNickName = UTF82Mutiple(nickName)

			if string.len(mutipleAccInput) == 0 then
				app.toast.show("Nickname must non-empty")
				return
			end

			print("string.len(mutipleAccInput) = " ..string.len(mutipleAccInput))
			if string.len(mutipleAccInput) < 6 or string.len(mutipleAccInput) > 16 then
				app.toast.show("Nickname must in 6-16 chars")
				return
			end

			if inputCheck.checkIsNumberOnly(mutipleAccInput) then
				app.toast.show("Account not all number")
				return
			end

			if string.len(mutipleNickName) == 0 then
				app.toast.show("Account must non-empty")
				return
			end

			if string.len(mutipleNickName) < 6 or string.len(mutipleNickName) > 16 then
				app.toast.show("Account must in 6-16 chars")
				return
			end

			if string.len(txtPwdInput:getString()) == 0 then
				app.toast.show("Password must non-empty")
				return
			end

			if string.len(txtPwdInput:getString()) < 6 or string.len(txtPwdInput:getString()) > 16 then
				app.toast.show("Password must in 6-16 chars")
				return
			end

			if inputCheck.checkIsSingleType(txtPwdInput:getString()) then
				app.toast.show("Password must number and letters in 6-16 chars")
				return
			end
		
			app.holdOn.show("Waiting for register...", 0.1)
			self.accInput = txtAccInput:getString()
			self.nickName = txtNickNameInput:getString()
			self.pwdInput = pwdInput
			sendRegReq(mutipleAccInput, mutipleNickName, pwdInput)
		end
	end
	btnOK:addTouchEventListener(onBtnOK)
end

local function listenEvent(self)
	app.loginScene.eventProtocol:removeEventListenersByEvent("LC_PHONECODE_REG_ACK_P")
	app.loginScene.eventProtocol:addEventListener("LC_PHONECODE_REG_ACK_P", handler(self, self.onLC_PHONECODE_REG_ACK_P))

	app.loginScene.eventProtocol:removeEventListenersByEvent("LC_CHECK_PHONECODE_P")
	app.loginScene.eventProtocol:addEventListener("LC_CHECK_PHONECODE_P", handler(self, self.onLC_CHECK_PHONECODE_P))

	app.loginScene.eventProtocol:removeEventListenersByEvent("LC_PHONECODE_GET_VALIDATECODE_ACK_P")
	app.loginScene.eventProtocol:addEventListener("LC_PHONECODE_GET_VALIDATECODE_ACK_P", handler(self, self.onLC_PHONECODE_GET_VALIDATECODE_ACK_P))

	app.loginScene.eventProtocol:removeEventListenersByEvent("LC_CHECK_PHONEVALIDATECODE_ACK")
	app.loginScene.eventProtocol:addEventListener("LC_CHECK_PHONEVALIDATECODE_ACK", handler(self, self.onLC_CHECK_PHONEVALIDATECODE_ACK_P))
end

function RegisterLayerCtrller:onLC_CHECK_PHONEVALIDATECODE_ACK_P(event)
	--dump(event.data)
	app.holdOn.hide()
	local ret = event.data.nResult

	if ret == 0 then
		self.phoneRegLayer1:hide()
		self.phoneRegLayer2:show()
		self.txtAccount_phone:setString("m" ..self.strPhoneNum)
	elseif ret == 1 then
		app.toast.show("验证码错误")
	elseif ret == 2 then
		app.toast.show("验证码有效期已过")
	elseif ret == 3 then
		app.toast.show("原因不明")
	end
end

function RegisterLayerCtrller:onLC_PHONECODE_GET_VALIDATECODE_ACK_P(event)
	local data = event.data
	local ret = data.nResult
	self.btnGetAuth:setTouchEnabled(true)
	if ret == 3 then
		app.toast.show("系统繁忙")
	elseif ret == 2 then
		app.toast.show("获取次数已满")
	elseif ret == 4 then
		app.toast.show("10分钟内超过3次")
	elseif ret == 0 then
		app.toast.show("验证码已发送,请注意查收")
		local validCode = data.validCode 
		if validCode ~= 0 then --内网测试
			self.txtAuth_phone:setString(validCode)
		end

		local resendDownSec = 60
		self.btnGetAuth:setTitleText("剩余" ..resendDownSec .."秒")
		self.btnGetAuth:setTouchEnabled(false)
		self.authScheduler = scheduler.scheduleGlobal(function()
			resendDownSec = resendDownSec - 1
			self.btnGetAuth:setTitleText("剩余" ..resendDownSec .."秒")

			if resendDownSec == 0 then
				self.btnGetAuth:setTitleText("发送验证码")
				self.btnGetAuth:setTouchEnabled(true)
				if self.authScheduler then
					scheduler.unscheduleGlobal(self.authScheduler)
					self.authScheduler = nil
				end
			end
		end, 1)
	else
		app.toast.show("未知原因" ..ret)
	end
end

function RegisterLayerCtrller:onLC_CHECK_PHONECODE_P(event)
	self.btnGetAuth:setTouchEnabled(true)
	local ret = event.data.nResult
	local strCode = event.data.strCode
	if ret == 0 then
		self.btnGetAuth:setTouchEnabled(false)
		--app.toast.show("验证码已发送,请注意查收")
		cc.lobbyController:checkPhoneAuth(strCode)
	elseif ret == 1 then
		app.toast.show("手机号重复")
	elseif ret == 2 then
		app.toast.show("手机号已被使用")
	elseif ret == 3 then
		app.toast.show("原因不明")
	end
end

function RegisterLayerCtrller:onLC_PHONECODE_REG_ACK_P(event)
	cc.hideLoading()
	local data = event.data
	print("<===========onLC_PHONECODE_REG_ACK_P")
	if data.ret == 0 then
		app.loginScene.username = self.accInput
		app.loginScene.password = self.pwdInput
		--cc.UserDefault:getInstance():setStringForKey("username", self.accInput)
		--cc.UserDefault:getInstance():setStringForKey("password", self.pwdInput)
		local time = app.toast.show("Congratulations,register successful!")
		scheduler.performWithDelayGlobal(function()
			self.registerLayer:removeSelf()
			app.loginScene.registerLayer = nil
			print("self.infoInputLayer.accInput = " ..self.accInput)
			local nodeAccInfo = app.loginScene:getResourceNode():getChildByName("Node_accInfo")
			nodeAccInfo:getChildByTag(10):setString(self.accInput)
			nodeAccInfo:getChildByTag(11):setString("********")
			--app.loginScene:getResourceNode():getChildByName("Node_dengluzhuce"):getChildByName("Button_back"):show()
		end, time)
	elseif data.ret == 1 then app.toast.show("Validcode wrong!")
	elseif data.ret == 2 then app.toast.show("Account has be used!")
	elseif data.ret == 3 then app.toast.show("Nickname has be used!")
	elseif data.ret == 4 then app.toast.show("Time is not up!")
	elseif data.ret == 5 then app.toast.show("System busy!")
	--elseif data.ret == 7 then app.toast.show("手机号码已被使用")
	end
end

function RegisterLayerCtrller:createLayer()
	self.registerLayer = cc.CSLoader:createNode("Layers/RegisterLayer.csb")

	self.regType = 0 -- 0为手机 1 为普通

	self.registerLayer:onNodeEvent("exit", function()
		if self.authScheduler then
			scheduler.unscheduleGlobal(self.authScheduler)
			self.authScheduler = nil
		end
	end)

	procUI(self)
	listenEvent(self)
	return self.registerLayer
end

return RegisterLayerCtrller