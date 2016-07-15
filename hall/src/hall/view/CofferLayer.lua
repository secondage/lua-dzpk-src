--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/8/27
-- Time: 14:58
-- To change this template use File | Settings | File Templates.
--
local inputLimit = require("app.func.InputUtil")
local ToastLayer = require("app.func.ToastLayer")
local MsgBox = app.msgBox

local CofferLayer = class("CofferLayer")

function CofferLayer:init(currScene)
    self.currScene = currScene
    self.root = cc.CSLoader:createNode("Layers/CofferLayer.csb")
    self.currScene:addChild(self.root, 20)

    self:initWidgets()
    self:listenEvent()
    self:setVisible(false)
end

function CofferLayer:clearInput()
    self.textSePsw:setString("")
    self.textCurrency:setString("")
end

function CofferLayer:listenEvent()
    self.currScene.eventProtocol:addEventListener("SC_COFFER_OP_ACK_P", function(event) --修改昵称、头像、性别
        print("保险箱操作")
        local ret = event.data.cRet
        if ret == 0 then
            ToastLayer.show("Succeeded")
        elseif ret == 1 then
            ToastLayer.show("Password wrong")
        elseif ret == 2 then
            ToastLayer.show("Not enough chips")
        elseif ret == 3 then
            ToastLayer.show("Not enough chips in safebox")
        elseif ret == 4 then
            ToastLayer.show("Can't set safebox when gameing")
        elseif ret == 5 then
            ToastLayer.show("Safebox not register or timeout")
        else
            ToastLayer.show("Unknown error")
        end
    end)

    self.currScene.eventProtocol:addEventListener("SC_COFFER_RENEWALS_ACK_P", function(event) --修改昵称、头像、性别
        print("保险箱延期")
        local ret = event.data.cRet
        if ret == 0 then
            ToastLayer.show("Succeeded")
        elseif ret == 3 then
            ToastLayer.show("Password wrong")
        elseif ret == 4 then
            ToastLayer.show("Not enough chips")
        elseif ret == 6 then
            ToastLayer.show("Can't set safebox when gameing")
        else
            ToastLayer.show("Unknown error")
        end
    end)

    self.currScene.eventProtocol:addEventListener("PL_PHONE_LC_CHECKSECONDPASSWORD_ACK_P", function(event) --修改昵称、头像、性别
        print("二级密码验证")
        local ret = event.data.nRet
        if ret == 0 then
            --ToastLayer.show("操作成功")
            self.strSePsw = self.textSePsw:getString()
            self.laySePsw:setVisible(false)
            app.popLayer.show(self.layCoffer:getChildByName("Image_background"))
            self.layCoffer:setVisible(true)
        elseif ret == 1 then
            ToastLayer.show("Password wrong")
        elseif ret == 2 then
            ToastLayer.show("Input password")
        else
            ToastLayer.show("Unknown error")
        end
    end)

    self.currScene.eventProtocol:addEventListener("USERDATA_CHANGED", function() --个人信息变动
        self:fillDataToUI()
    end)
end

function CofferLayer:initWidgets()
    self.layCoffer = self.root:getChildByName("Panel_coffer")
    self.laySePsw = self.root:getChildByName("Panel_sePswInput")
    self.layRenewal = self.root:getChildByName("Panel_renewal")

    --二级密码输入
    local laySePsw = self.laySePsw

    local textSePsw = ccui.Helper:seekWidgetByName(laySePsw, "TextField_sePsw")
    self.textSePsw = app.EditBoxFactory:createEditBoxByImage(textSePsw, "")
    local function onPwdInput(name, sender)
        if name == "changed" then
            local pwdInput = self.textSePsw:getString()
            self.textSePsw:setString(inputLimit.ban_ZH_input(pwdInput))
        end
    end
    self.textSePsw:registerScriptEditBoxHandler(onPwdInput)
    self.textSePsw:setInputFlag(0)

    local btnOkSePsw = ccui.Helper:seekWidgetByName(laySePsw, "Button_submit")
    btnOkSePsw:setPressedActionEnabled(true)
    btnOkSePsw:addTouchEventListener(function(widget, type)
        if type == 2 then
            local userData = cc.dataMgr.lobbyUserData.lobbyUser
            app.audioPlayer:playClickBtnEffect()
            if userData.isHaveAdvPasswd == 0 then
                ToastLayer.show("Register second level password frist.")
                return
            end
            local strSePsw = self.textSePsw:getString()
            if string.len(strSePsw) < 8 then
                ToastLayer.show("Input second-level password")
                return
            end

            app.cofferLogic:reqCheckSePsw(strSePsw)
            --self.laySePsw:setVisible(false)
            --self.layCoffer:setVisible(true)
        end
    end)

    local btnCloseSePsw = ccui.Helper:seekWidgetByName(laySePsw, "Button_close")
    btnCloseSePsw:setPressedActionEnabled(true)
    btnCloseSePsw:addTouchEventListener(function(widget, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            self:setVisible(false)
        end
    end)

    --保险箱界面
    local layCoffer = self.layCoffer

    self.labelTime = ccui.Helper:seekWidgetByName(layCoffer, "Text_cofferDate")
    self.labelGameCurrency = ccui.Helper:seekWidgetByName(layCoffer, "BitmapFontLabel_gameCurrency")
    self.labelCofferCurrency = ccui.Helper:seekWidgetByName(layCoffer, "BitmapFontLabel_cofferurrency_0")

    self.checkIn = ccui.Helper:seekWidgetByName(layCoffer, "CheckBox_in")
    self.checkOut = ccui.Helper:seekWidgetByName(layCoffer, "CheckBox_out")
    self.checkIn:addEventListener(function(widget, type)
        app.audioPlayer:playClickBtnEffect()
        self.checkIn:setSelected(true)
        self.checkOut:setSelected(fasle)
    end)
    self.checkOut:addEventListener(function(widget, type)
        app.audioPlayer:playClickBtnEffect()
        self.checkIn:setSelected(fasle)
        self.checkOut:setSelected(true)
    end)

    local textCurrency = ccui.Helper:seekWidgetByName(layCoffer, "TextField_optionNum")
    self.textCurrency = app.EditBoxFactory:createEditBoxByImage(textCurrency, "Number of chips")
    local function onCurrencyInput(name, sender)
        if name == "changed" then
            local strInput = self.textCurrency:getString()
            self.textCurrency:setString(inputLimit.pick_Number_input(strInput))
        end
    end
    self.textCurrency:registerScriptEditBoxHandler(onCurrencyInput)
    self.textCurrency:setInputMode(2)

    local btnOkCoffer = ccui.Helper:seekWidgetByName(layCoffer, "Button_ok")
    btnOkCoffer:setPressedActionEnabled(true)
    btnOkCoffer:addTouchEventListener(function(widget, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            local strCurrency = self.textCurrency:getString()
            self.textCurrency:setString("")
            if strCurrency == "" then
                ToastLayer.show("Number of chips")
                return
            end
            local gameCurrency = tonumber(strCurrency)
            if gameCurrency <= 0 then
                ToastLayer.show("Number of chips is wrong")
                return
            end
            local opType = -1
            if self.checkIn:isSelected() then
                opType = 0
            elseif self.checkOut:isSelected() then
                local userData = cc.dataMgr.lobbyUserData.lobbyUser
                if userData.cofferstate == 1 then
                    opType = 2
                else
                    opType = 1
                end
            end
            if self.strSePsw == nil then
                app.toast.show("Second-level password wrong")
                self:setVisible(false)
            end
            print("reqCofferOp: "..opType.." "..gameCurrency.." "..self.strSePsw)
            app.cofferLogic:reqCofferOp(opType, gameCurrency, self.strSePsw)
        end
    end)

    local btnCloseCoffer = ccui.Helper:seekWidgetByName(layCoffer, "Button_close")
    btnCloseCoffer:setPressedActionEnabled(true)
    btnCloseCoffer:addTouchEventListener(function(widget, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            self:setVisible(false)
        end
    end)

    --续费延期界面
    local layRenewal = self.layRenewal
    local checkMonth1 = ccui.Helper:seekWidgetByName(layRenewal, "CheckBox_month1")
    local checkMonth3 = ccui.Helper:seekWidgetByName(layRenewal, "CheckBox_month3")
    local labelNeedCurrency = ccui.Helper:seekWidgetByName(layRenewal, "Text_needCurrency")
    labelNeedCurrency:setString("Need 10500 chips")
    checkMonth1:addEventListener(function(widget, type)
        app.audioPlayer:playClickBtnEffect()
        checkMonth3:setSelected(fasle)
        checkMonth1:setSelected(true)
        labelNeedCurrency:setString("Need 10500 chips")
    end)
    checkMonth3:addEventListener(function(widget, type)
        app.audioPlayer:playClickBtnEffect()
        checkMonth1:setSelected(fasle)
        checkMonth3:setSelected(true)
        labelNeedCurrency:setString("Need 31500 chips")
    end)
    local btnOkRenewal = ccui.Helper:seekWidgetByName(layRenewal, "Button_ok")
    btnOkRenewal:setPressedActionEnabled(true)
    btnOkRenewal:addTouchEventListener(function(widget, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            local month = 1
            if checkMonth3:isSelected() then
                month = 3
            end
            app.cofferLogic:reqCofferRenewals(month, 0, self.strSePsw)
            layRenewal:setVisible(false)
        end
    end)
    local btnCloseRenewal = ccui.Helper:seekWidgetByName(layRenewal, "Button_close")
    btnCloseRenewal:setPressedActionEnabled(true)
    btnCloseRenewal:addTouchEventListener(function(widget, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            layRenewal:setVisible(false)
        end
    end)

end

function CofferLayer:fillDataToUI()
    local userData = cc.dataMgr.lobbyUserData.lobbyUser

    --日期
    local time = os.date("*t", userData.cofferEnd)
    local strTime = ""
    if userData.cofferstate == 0 then
        strTime = "Not valid"
    else
        strTime = time.year.."Year"..time.month.."Mouth"..time.day.."Day"
        if userData.cofferstate == 1 then
            strTime = strTime.."(Timeout)"
        end
    end
    self.labelTime:setString(strTime)

    --游戏豆状态
    app.utils.updateTextNum(self.labelGameCurrency, userData.gameCurrency.l)
    app.utils.updateTextNum(self.labelCofferCurrency, userData.cofferCurrency.l)
    --self.labelGameCurrency:setString(userData.gameCurrency.l)
    --self.labelCofferCurrency:setString(userData.cofferCurrency.l)

    --操作和输入框，过期时
    if userData.cofferstate == 1 then
        self.checkIn:setSelected(false)
        self.checkOut:setSelected(true)
        self.checkIn:setEnabled(fasle)
        self.checkOut:setEnabled(false)
        self.textCurrency:setEnabled(false)
        self.textCurrency:setString(userData.cofferCurrency.l)
    else
        self.checkIn:setSelected(true)
        self.checkOut:setSelected(false)
        self.checkIn:setEnabled(true)
        self.checkOut:setEnabled(true)
        self.textCurrency:setEnabled(true)
        self.textCurrency:setString("")
    end

    local btnSePsw = ccui.Helper:seekWidgetByName(self.laySePsw, "Button_sePsw")
    btnSePsw:setPressedActionEnabled(true)
    local btnsePsw1 = ccui.Helper:seekWidgetByName(self.laySePsw, "Button_sePsw1")
    btnsePsw1:setPressedActionEnabled(true)
    btnSePsw:setVisible(userData.isHaveAdvPasswd == 0)
    btnsePsw1:setVisible(userData.isHaveAdvPasswd ~= 0)
    function sePsw(widget, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            print("tag:"..widget:getTag())
            self:setVisible(false)
            self.currScene.laySecondPsw:setVisible(true)
        end
    end
    btnSePsw:addTouchEventListener(sePsw)
    btnsePsw1:addTouchEventListener(sePsw)

    local btnRenewal = ccui.Helper:seekWidgetByName(self.layCoffer, "Button_renewal")
    btnRenewal:setPressedActionEnabled(true)
    if userData.cofferstate == 0 then
        local path = "Resources/newResources/Setting/kaitong.png"
        btnRenewal:loadTextures(path, path, path, 1)
        btnRenewal:addTouchEventListener(function(widget, type)
            if type == 2 then
                app.audioPlayer:playClickBtnEffect()
                app.cofferLogic:reqCofferRenewals(1, 0, self.strSePsw)
            end
        end)
    else
        local path = "Resources/newResources/Setting/yanqi.png"
        btnRenewal:loadTextures(path, path, path, 1)
        btnRenewal:addTouchEventListener(function(widget, type)
            if type == 2 then
                app.audioPlayer:playClickBtnEffect()
                app.popLayer.showEx(self.layRenewal)
                --self.layRenewal:setVisible(true)
            end
        end)
    end
end

function CofferLayer:setVisible(bShow)
    if bShow then
        self:clearInput()
        self:fillDataToUI()
        app.popLayer.show(self.laySePsw:getChildByName("Image_background"))
        self.laySePsw:setVisible(true)
        self.layCoffer:setVisible(false)
        self.layRenewal:setVisible(false)
        app.hallScene.nPopLayers = app.hallScene.nPopLayers + 1
    else
        self.strSePsw = nil
        app.hallScene.nPopLayers = app.hallScene.nPopLayers - 1
    end
    self.root:setVisible(bShow)
end

return CofferLayer
