--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/11/10
-- Time: 14:12
-- To change this template use File | Settings | File Templates.
--
--
-- Author: ChenShao
-- Date: 2015-09-15 19:41:27
--
local AccountBindLayerCtrller = class("AccountBindLayerCtrller")

local inputLimit = require("app.func.InputUtil")
local inputCheck = require("app.func.InputCheck")

local function procUI(self)
    local userData = cc.dataMgr.lobbyUserData.lobbyUser
    local bChangeNickName = string.len(userData.strNickNamebuf) < 6 or string.len(userData.strNickNamebuf) > 16
    self.infoInputLayer = self.registerLayer:getChildByName("Panel_infoInputLayer")

    local imgbg = self.infoInputLayer:getChildByName("Image_dikuang")
    imgbg:setTouchEnabled(true)

    local btnBack = self.infoInputLayer:getChildByName("Button_btnBack")
    local function onBtnBack(sender, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            app.hallScene.bindAccountLayer = nil
            app.hallScene.nPopLayers = app.hallScene.nPopLayers - 1
            self.registerLayer:removeSelf()
        end
    end
    btnBack:addTouchEventListener(onBtnBack)

    local layAccount = self.infoInputLayer:getChildByName("Panel_account")
    local txtAccInputTmp = layAccount:getChildByName("TextField_inputAccount"):hide()
    local txtAccInput = app.EditBoxFactory:createEditBoxByImage(txtAccInputTmp, "请输入用户名")

    local layNickName = self.infoInputLayer:getChildByName("Panel_nickName")
    local txtNickNameInputTmp = layNickName:getChildByName("TextField_inputNickName"):hide()
    --local txtNickNameInputBg = self.infoInputLayer:getChildByName("shurukuang_2_0"):hide()
    local txtNickNameInput = app.EditBoxFactory:createEditBoxByImage(txtNickNameInputTmp, "请输入昵称")

    local layPsw = self.infoInputLayer:getChildByName("Panel_passWord")
    local txtPwdInputTmp = layPsw:getChildByName("TextField_inputPwd")
    --local txtPwdInputBg = self.infoInputLayer:getChildByName("shurukuang_2_0_0"):hide()
    local txtPwdInput = app.EditBoxFactory:createEditBoxByImage(txtPwdInputTmp, "请输入密码")
    txtPwdInput:setInputFlag(0)
    txtPwdInput:registerScriptEditBoxHandler(function(name, sender)
        if name == "began" then
            txtPwdInput:setString("")
        elseif name == "changed" then
            local pwdInput = txtPwdInput:getString()
            txtPwdInput:setString(inputLimit.ban_ZH_input(pwdInput))
        end
    end)

    if not bChangeNickName then
        layNickName:setVisible(false)
        local posAccountY = layAccount:getPositionY()
        layAccount:setPositionY(posAccountY - 40)
        local posPswY = layPsw:getPositionY()
        layPsw:setPositionY(posPswY + 40)
    end

    local btnOK = self.infoInputLayer:getChildByName("Button_btnOK")
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
            local nickName = userData.strNickNamebuf
            if bChangeNickName then
                nickName = txtNickNameInput:getString()
            end
            local pwdInput = txtPwdInput:getString()

            local mutipleAccInput = UTF82Mutiple(accInput)
            local mutipleNickName = UTF82Mutiple(nickName)

            if string.len(mutipleAccInput) == 0 then
                app.toast.show("账号不能为空")
                return
            end

            print("string.len(mutipleAccInput) = " ..string.len(mutipleAccInput))
            if string.len(mutipleAccInput) < 6 or string.len(mutipleAccInput) > 16 then
                app.toast.show("账号长度必须为6~16个字符,请重新输入")
                return
            end

            if inputCheck.checkIsNumberOnly(mutipleAccInput) then
                app.toast.show("账号不能全为数字")
                return
            end

            if bChangeNickName then
                if string.len(mutipleNickName) == 0 then
                    app.toast.show("昵称不能为空")
                    return
                end

                if string.len(mutipleNickName) < 6 or string.len(mutipleNickName) > 16 then
                    app.toast.show("昵称长度必须为6~16个字符,请重新输入")
                    return
                end
            end

            if string.len(txtPwdInput:getString()) == 0 then
                app.toast.show("密码不能为空")
                return
            end

            if string.len(txtPwdInput:getString()) < 6 or string.len(txtPwdInput:getString()) > 16 then
                app.toast.show("密码长度不符合")
                return
            end

            if inputCheck.checkIsSingleType(txtPwdInput:getString()) then
                app.toast.show("密码必须为6~16个英文+数字的组合,请重新输入")
                return
            end

            app.holdOn.show("正在处理,请稍候...", 0.1)
            self.strAccount = txtAccInput:getString()
            --local nickName = mutipleNickName
            self.strPsw = pwdInput
            app.individualLogic:reqAccountBind(mutipleAccInput, pwdInput, nickName)
        end
    end
    btnOK:addTouchEventListener(onBtnOK)
end

local function listenEvent(self)
    app.hallScene.eventProtocol:removeEventListenersByEvent("SC_TRAIL_TRANSFER_P")
    app.hallScene.eventProtocol:addEventListener("SC_TRAIL_TRANSFER_P", function(event)
        print("event SC_TRAIL_TRANSFER_P")
        app.holdOn.hide()
        local ret = event.data.transferResult
        if ret == 0 then
            cc.UserDefault:getInstance():setStringForKey("username", self.strAccount)
            local md5 = MD5:create()
            self.strPsw = md5:ComplexMD5(self.strPsw)
            cc.UserDefault:getInstance():setStringForKey("password", self.strPsw)
            local function funcOk()
                cc.msgHandler:disconnectFromLobby()
                cc.dataMgr.isChangeAccLogin = true
                app.sceneSwitcher:enterScene("LoginScene")
            end
            app.msgBox.showMsgBox("您已成功绑定账号，请重新登录", funcOk, nil, nil, true)
        elseif ret == 1 then
            app.toast.show("验证码错误")
        elseif ret == 2 then
            app.toast.show("用户名已被注册")
        elseif ret == 3 then
            app.toast.show("昵称已经被注册")
        elseif ret == 5 then
            app.toast.show("系统繁忙，请稍后再试")
        elseif ret == 6 then
            app.toast.show("操作过于频繁，请稍后再试")
        end
    end)
end

function AccountBindLayerCtrller:createLayer()
    self.registerLayer = cc.CSLoader:createNode("Layers/AccountBindLayer.csb")
    procUI(self)
    app.popLayer.showEx(self.infoInputLayer)
    listenEvent(self)
    return self.registerLayer
end

return AccountBindLayerCtrller

