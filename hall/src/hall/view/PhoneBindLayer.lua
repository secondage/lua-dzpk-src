--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/8/25
-- Time: 9:13
-- To change this template use File | Settings | File Templates.
--
local inputCheck = require("app.func.InputCheck")
local inputLimit = require("app.func.InputUtil")
require "framework.utils.bit"
local ToastLayer = require("app.func.ToastLayer")
local scheduler = require("framework.scheduler")

local PhoneBindLayer = class("PhoneBindLayer")

local function clearInput(self)

end

local function listenEvent(self)

    self.currScene.eventProtocol:addEventListener("SC_PHONEBIND_CHECK_PHONECODE_P", function(event)
        local ret = event.data.nResult
        if ret ~= 0 then self:stopTimer() end
        if ret == 0 then
            --手机号验证成功，正在获取验证码
        elseif ret == 1 then
            ToastLayer.show("手机号码已经被使用")
        elseif ret == 2 then
            ToastLayer.show("手机号码已经被使用")
        else
            ToastLayer.show("验证手机号码出现错误,请稍后重试")
        end
    end)

    self.currScene.eventProtocol:addEventListener("LC_PHONECODE_GET_VALIDATECODE_ACK_P", function(event)
        local ret = event.data.nResult
        if ret ~= 0 then self:stopTimer() end
        if ret == 0 then
            ToastLayer.show("验证码已发送")
            if clientConfig.platform == "INNER" then
                ToastLayer.show(event.data.validCode)
            end
        elseif ret == 1 then
            ToastLayer.show("获取验证码失败，请稍后再试")
        elseif ret == 2 then
            ToastLayer.show("获取验证码次数已到达上限")
        elseif ret == 3 then
            ToastLayer.show("系统繁忙，请稍后再试")
        elseif ret == 4 then
            ToastLayer.show("十分钟内获取验证码次数不能超过三次")
        elseif ret == 5 then
            ToastLayer.show("超过绑定数量上限")
        elseif ret == 6 then
            ToastLayer.show("该手机号已被绑定")
        elseif ret == 7 then
            ToastLayer.show("一天只能进行一次手机号绑定或解绑操作")
        elseif ret == 8 then
            ToastLayer.show("该手机号已被使用，无法再进行绑定")
        elseif ret == 9 then
            ToastLayer.show("一个用户当天只能绑定一个手机号")
        elseif ret == 10 then
            ToastLayer.show("绑定手机后24小时内不能解除绑定")
        else
            ToastLayer.show("未知错误")
        end
    end)

    self.currScene.eventProtocol:addEventListener("LC_CHECK_PHONEVALIDATECODE_ACK_P", function(event)
        local ret = event.data.nResult
        if ret == 0 then
            --验证成功，正在绑定手机号
        elseif ret == 1 then
            ToastLayer.show("验证码错误")
        elseif ret == 2 then
            ToastLayer.show("验证码已过期")
        else
            ToastLayer.show("未知错误")
        end
        self:fillDataToUI()
    end)

    self.currScene.eventProtocol:addEventListener("SC_PHONECODEBIND_ACK_P", function(event)
        local ret = event.data.nResult
        if ret == 0 then
            --绑定成功，领取奖励中
        elseif ret == 1 then
            ToastLayer.show("绑定失败")
        elseif ret == 2 then
            ToastLayer.show("该手机号已被绑定")
        elseif ret == 3 then
            ToastLayer.show("操作成功")
        elseif ret == 4 then
            ToastLayer.show("一天只能进行一次手机号绑定或解绑操作")
        elseif ret == 5 then
            ToastLayer.show("该手机号已被使用，无法再进行绑定")
        elseif ret == 6 then
            ToastLayer.show("一个用户当天只能绑定一个手机号")
        else
            ToastLayer.show("未知错误")
        end
        self:fillDataToUI()
    end)

    self.currScene.eventProtocol:addEventListener("SC_REMOVEPHONEBIND_ACK_P", function(event)
        local ret = event.data.ret
        if ret == 0 then
            ToastLayer.show("操作成功")
        else
            ToastLayer.show("操作失败")
        end
        self:fillDataToUI()
    end)

    self.currScene.eventProtocol:addEventListener("SC_GETPHONECODEBIND_RESULT_ACK_P", function(event)
        self:fillDataToUI()
    end)

    self.currScene.eventProtocol:addEventListener("SC_BIND_GETAWARD_ACK_P", function(event)
        local ret = event.data.nResult
        if ret == 0 then
            ToastLayer.show("绑定手机号成功，获得"..event.data.awardGameCurrency.l.."游戏豆奖励")
        else
            ToastLayer.show("操作成功")
        end
        self:fillDataToUI()
    end)

end


local function initWidgets(self)
    local root = self.rootLayer

    local textPhoneNum = ccui.Helper:seekWidgetByName(root, "TextField_phoneNum")
    self.textPhoneNum = app.EditBoxFactory:createEditBoxByImage(textPhoneNum, "请输入手机号")
    local function onPhoneNumInput(name, sender)
        if name == "changed" then
            local strInput = self.textPhoneNum:getString()
            self.textPhoneNum:setString(inputLimit.pick_Number_input(strInput))
        end
    end
    self.textPhoneNum:registerScriptEditBoxHandler(onPhoneNumInput)
    self.textPhoneNum:setInputMode(2)
    self.textPhoneNum:setMaxLength(11)

    local textValidCode = ccui.Helper:seekWidgetByName(root, "TextField_validCode")
    self.textValidCode = app.EditBoxFactory:createEditBoxByImage(textValidCode, "验证码")
    local function onValidInput(name, sender)
        if name == "changed" then
            local strInput = self.textValidCode:getString()
            self.textValidCode:setString(inputLimit.pick_Number_input(strInput))
        end
    end
    self.textValidCode:registerScriptEditBoxHandler(onValidInput)
    self.textValidCode:setInputMode(2)
    self.textValidCode:setMaxLength(6)

    self.btnGetValidCode = ccui.Helper:seekWidgetByName(root, "Button_getValidCode")
    self.btnGetValidCode:setPressedActionEnabled(true)
    self.btnGetValidCode:addTouchEventListener(function(widget, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            local userInfoMore = cc.dataMgr.userInfoMore
            if userInfoMore.phoneBindState == 0 then
                local strPhone = self.textPhoneNum:getString()
                local ret = inputCheck.checkPhoneNum(strPhone)
                if not ret then
                    ToastLayer.show("请输入正确的手机号码")
                    return
                end
                print("reqPhoneBindCheckPhoneCode:"..strPhone)
                self:startBtnVaildTimer()
                app.phoneLogic:reqPhoneBindCheckPhonecode(strPhone)
            else
                self:startBtnVaildTimer()
                app.phoneLogic:reqGetValidCode(userInfoMore.strBindingPhone, 3, 1)
            end
        end
    end)
    self.checkPhoneLogin = ccui.Helper:seekWidgetByName(root, "CheckBox_phoneLogin")
    self.checkPhoneLogin:addEventListener(function(widget, type)
        app.audioPlayer:playClickBtnEffect()
        local userInfoMore = cc.dataMgr.userInfoMore
        if userInfoMore.phoneBindState == 0 then
            ToastLayer.show("未绑定手机号不能进行该操作")
            self.checkPhoneLogin:setSelected(false)
            return
        end

        if type == 0 then
            app.phoneLogic:reqSetUsePhoneLogin()
        elseif type == 1 then
            app.phoneLogic:reqCancelUsePhoneLogin()
        end
    end)
    self.btnSubmit = ccui.Helper:seekWidgetByName(root, "Button_submit")
    self.btnSubmit:setPressedActionEnabled(true)
    self.labelTime = ccui.Helper:seekWidgetByName(root, "Text_countDown")
    self.btnSubmit:addTouchEventListener(function(widget, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            local userInfoMore = cc.dataMgr.userInfoMore
            local strValidCode = self.textValidCode:getString()
            local strPhone = self.textPhoneNum:getString()
            local ret = inputCheck.checkPhoneNum(strPhone)
            if not ret or string.len(strPhone) < 11 then
                ToastLayer.show("请输入正确的手机号码")
                return
            end
            if string.len(strValidCode) < 6 then
                ToastLayer.show("请输入正确的验证码")
                return
            end
            if userInfoMore.phoneBindState == 0 then
                app.phoneLogic:reqCheckPhoneValidCode(strPhone, tonumber(strValidCode), 2)
            else
                app.phoneLogic:reqCheckPhoneValidCode(strPhone, tonumber(strValidCode), 3)
            end
        end
    end)
    local btnClose = ccui.Helper:seekWidgetByName(root, "Button_close")
    btnClose:setPressedActionEnabled(true)
    btnClose:addTouchEventListener(function(widget, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            --self.currScene.layIndividual:setVisible(true)
            self:setVisible(false)
        end
    end)
end

function PhoneBindLayer:init(currScene)
    self.root = cc.CSLoader:createNode("Layers/PhoneBindLayer.csb")
    self.rootLayer = self.root:getChildByName("Panel_phoneBind")
    self.currScene = currScene
    self.currScene:addChild(self.root, 25)
    initWidgets(self)
    listenEvent(self)
    self:setVisible(false)
end

function PhoneBindLayer:fillDataToUI()
    local userInfoMore = cc.dataMgr.userInfoMore
    if userInfoMore == nil then return end

    if userInfoMore.phoneBindState ~= 0 then
        --self.btnSubmit:setTitleText("解除绑定")
        self.textPhoneNum:setString(userInfoMore.strBindingPhone)
        self.textPhoneNum:setEnabled(false)
    else
        --self.btnSubmit:setTitleText("绑定手机号")
        self.textPhoneNum:setString("")
        self.textPhoneNum:setEnabled(true)
    end
    self.textValidCode:setString("")
    self.checkPhoneLogin:setSelected(bit.band(userInfoMore.phoneBindState, 2) ~= 0)
end

function PhoneBindLayer:setVisible(bShow, lastLayer)
    if bShow then
        self:fillDataToUI()
        app.popLayer.show(self.rootLayer:getChildByName("Image_background"))
        app.hallScene.nPopLayers = app.hallScene.nPopLayers + 1
    else
        app.hallScene.nPopLayers = app.hallScene.nPopLayers - 1
    end
    self.root:setVisible(bShow)
    if self.latLayer ~= nil and not bShow then
        self.lastLayer:setVisible(true)
    end
    self.lastLayer = lastLayer
end

function PhoneBindLayer:startBtnVaildTimer()
    self.timeBtnValid = 60
    self:stopTimer()
    self.btnGetValidCode:setEnabled(false)
    self.btnGetValidCode:setBright(false)
    local function onBtnValidCodeTimer()
        local strCountDown = ""
        if self.timeBtnValid > 0 then
            strCountDown = "("..self.timeBtnValid.."秒)"
            self.btnGetValidCode:setEnabled(false)
            self.btnGetValidCode:setBright(false)
        end
        self.btnGetValidCode:setTitleText("获取验证码"..strCountDown)

        if self.timeBtnValid <= 0 then
            self.btnGetValidCode:setEnabled(true)
            self.btnGetValidCode:setBright(true)
            self:stopTimer()
        else
            self.timeBtnValid = self.timeBtnValid - 1
        end
    end
    self.validScheduler = scheduler.scheduleGlobal(onBtnValidCodeTimer, 1.0)
end

function PhoneBindLayer:stopTimer()
    if self.validScheduler ~= nil then
        scheduler.unscheduleGlobal(self.validScheduler)
        self.btnGetValidCode:setEnabled(true)
        self.btnGetValidCode:setBright(true)
        self.btnGetValidCode:setTitleText("获取验证码")
        self.validScheduler = nil
        self.labelTime:setString("")
    end
end

return PhoneBindLayer

