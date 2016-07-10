--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/8/24
-- Time: 11:40
-- To change this template use File | Settings | File Templates.
--
local ChangePswLayer = class("ChangePswLayer")
local ToastLayer = require("app.func.ToastLayer")
local InputCheck = require("app.func.InputCheck")
local inputLimit = require("app.func.InputUtil")


local function clearInput(self)
    self.textCurrentPsw:setString("")
    self.textNewPsw:setString("")
    self.textComfirm:setString("")
end

local function initWidgets(self)
    local root = self.rootLayer
    self.labelTips = ccui.Helper:seekWidgetByName(root, "Text_tips")
    self.labelTips:setString("")
    local function clearTips(name, sender)
        if name == "changed" then
            self.labelTips:setString("")
            local strInput = sender:getString()
            sender:setString(inputLimit.ban_ZH_input(strInput))
        end
    end

    local textCurrentPsw = ccui.Helper:seekWidgetByName(root, "TextField_currentPsw")
    self.textCurrentPsw = app.EditBoxFactory:createEditBoxByImage(textCurrentPsw, "输入当前密码")
    self.textCurrentPsw:registerScriptEditBoxHandler(clearTips)
    self.textCurrentPsw:setInputFlag(0)

    local textNewPsw = ccui.Helper:seekWidgetByName(root, "TextField_newPsw")
    self.textNewPsw = app.EditBoxFactory:createEditBoxByImage(textNewPsw, "输入新密码")
    self.textNewPsw:registerScriptEditBoxHandler(clearTips)
    self.textNewPsw:setInputFlag(0)

    local textComfirm = ccui.Helper:seekWidgetByName(root, "TextField_comfirm")
    self.textComfirm = app.EditBoxFactory:createEditBoxByImage(textComfirm, "再次输入新密码")
    self.textComfirm:registerScriptEditBoxHandler(clearTips)
    self.textComfirm:setInputFlag(0)

    local btnChangePsw = ccui.Helper:seekWidgetByName(root, "Button_changePsw")
    btnChangePsw:setPressedActionEnabled(true)
    btnChangePsw:addTouchEventListener(function(widget, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            local strCurrPsw = self.textCurrentPsw:getString()
            local strNewPsw = self.textNewPsw:getString()
            local strComfirm = self.textComfirm:getString()
            clearInput(self)

            local errCode = InputCheck.checkPsw(strCurrPsw)
            if errCode == 1 then
                self.labelTips:setString("请输入原始密码")
                return
            elseif errCode == 2 then
                self.labelTips:setString("密码长度为6~16位")
                return
            --elseif errCode == 3 then
                --self.labelTips:setString("密码不能全为数字或全为字母")
                --return
            end

            errCode = InputCheck.checkPsw(strNewPsw)
            if errCode == 1 then
                self.labelTips:setString("请输入新的密码")
                return
            elseif errCode == 2 then
                self.labelTips:setString("新密码长度为6~16位")
                return
            elseif errCode == 3 then
                self.labelTips:setString("新密码不能全为数字或全为字母")
                return
            end

            if strNewPsw ~= strComfirm then
                self.labelTips:setString("两次新密码输入不一致！")
                return
            end

            if strCurrPsw == strNewPsw then
                self.labelTips:setString("修改的密码不能与旧密码相同。")
                return
            end
            app.individualLogic:reqChangePsw(strCurrPsw, strNewPsw)
        end
    end)
    local btnClose = ccui.Helper:seekWidgetByName(root, "Button_closeChangePsw")
    btnClose:setPressedActionEnabled(true)
    btnClose:addTouchEventListener(function(widget, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            self:setVisible(false)
        end
    end)
end

local function listenEvent(self)
    self.currScene.eventProtocol:addEventListener("SC_CHANGE_PASSWD_P", function(event)
        local ret = event.data.ret
        if ret == 0 then
            ToastLayer.show("密码修改成功，请牢记新的密码。")
            self:setVisible(false)
        elseif ret == 1 then
            self.labelTips:setString("原密码错误")
        else
            self.labelTips:setString("未知错误")
        end
    end)
end

function ChangePswLayer:init(currScene)
    self.root = cc.CSLoader:createNode("Layers/ChangePswLayer.csb")
    self.rootLayer = self.root:getChildByName("Panel_changePsw")
    self.currScene = currScene
    self.currScene:addChild(self.root, 25)
    initWidgets(self)
    listenEvent(self)
    self:setVisible(false)
end

function ChangePswLayer:setVisible(bShow)
    if bShow then
        clearInput(self)
        app.popLayer.show(self.rootLayer:getChildByName("Image_background"))
        app.hallScene.nPopLayers = app.hallScene.nPopLayers + 1
    else
        app.hallScene.nPopLayers = app.hallScene.nPopLayers - 1
    end
    self.root:setVisible(bShow)
end

return ChangePswLayer

