--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/8/24
-- Time: 15:15
-- To change this template use File | Settings | File Templates.
--
local inputLimit = require("app.func.InputUtil")
local SecondPswLayer = class("SecondPswLayer")
local ToastLayer = require("app.func.ToastLayer")
local InputCheck = require("app.func.InputCheck")

local cardTypes = {
    "身份证",
    "军官证",
    "护照",
    "电话号码",
    "其他证件"
}
local questions = {
    "您的生日的日期？",
    "您最喜欢的颜色？",
    "您的母亲的名字？",
    "您的父亲的名字？",
    "您的爱人的名字？",
    "您同桌的名字？",
    "您的宠物的名字是什么？",
    "您最喜欢的歌手的是？",
    "您最喜欢的体育运动？",
    "您最喜欢的作家？",
    "您的小学的名字？"
}

local function clearInput(self)
    self.textSecondPsw:setString("")
    self.textComfirm:setString("")
    self.textCardType:setString("")
    self.textCardNum:setString("")
    self.textQuestion:setString("")
    self.textAnswer:setString("")
end

local function listenEvent(self)
    self.currScene.eventProtocol:addEventListener("SC_CREATE_SEPASSWD_P", function(event)
        local ret = event.data.ret
        if ret == 0 then
            ToastLayer.show("操作成功")
            self:setVisible(false)
        else
            self.labelTips:setString("操作失败")
        end
        clearInput(self)
    end)

    self.currScene.eventProtocol:addEventListener("SC_CHANGE_SEPWD_P", function(event)
        local ret = event.data.ret
        if ret == 0 then
            ToastLayer.show("操作成功")
            self:setVisible(false)
        elseif ret == 2 then
            ToastLayer.show("证件类型错误")
        elseif ret == 3 then
            ToastLayer.show("证件号码错误")
        elseif ret == 4 then
            ToastLayer.show("密保问题错误")
        elseif ret == 5 then
            ToastLayer.show("密保问题答案错误")
        else
            ToastLayer.show("操作失败")
        end
        clearInput(self)
        self:fillDataToUI()
    end)
end

local function initListViews(self)
    local listCardType = ccui.Helper:seekWidgetByName(self.layCardType, "ListView_cardType")
    local itemCardType = ccui.Helper:seekWidgetByName(self.layCardType, "Image_cardTypeItem")
    itemCardType:setVisible(false)
    for i = 1, #cardTypes do
        local item = itemCardType:clone()
        local labelType = item:getChildByName("Text_cardType")
        labelType:setString(cardTypes[i])
        item:setVisible(true)
        listCardType:insertCustomItem(item, i - 1)
    end
    listCardType:addEventListener(function(widget, type)
        if type == 1 then
            local index = listCardType:getCurSelectedIndex()
            local text = listCardType:getItem(index):getChildByName("Text_cardType")

            self.textCardType:setString(text:getString())
            self.layCardType:setVisible(false)
        end
    end)

    local listQuestion = ccui.Helper:seekWidgetByName(self.layQuestion, "ListView_question")
    local itemQuestion = ccui.Helper:seekWidgetByName(self.layQuestion, "Image_question")
    itemQuestion:setVisible(false)
    for i = 1, #questions do
        local item = itemQuestion:clone()
        local labelQuestion = item:getChildByName("Text_question")
        labelQuestion:setString(questions[i])
        item:setVisible(true)
        listQuestion:insertCustomItem(item, i - 1)
    end
    listQuestion:addEventListener(function(widget, type)
        if type == 1 then
            local index = listQuestion:getCurSelectedIndex()
            local text = listQuestion:getItem(index):getChildByName("Text_question")
            self.textQuestion:setString(text:getString())
            self.layQuestion:setVisible(false)
        end
    end)
end

local function initWidgets(self)
    local root = self.rootLayer
    self.labelAwardTip = ccui.Helper:seekWidgetByName(root, "Text_awardTip")
    self.labelAwardTip:setString("注册成功将获得10000游戏豆")

    local textSecondPsw = ccui.Helper:seekWidgetByName(root, "TextField_secondPsw")
    self.textSecondPsw = app.EditBoxFactory:createEditBoxByImage(textSecondPsw, "请输入二级密码")
    local function onPwdInput(name, sender)
        if name == "changed" then
            local strInput = self.textSecondPsw:getString()
            self.textSecondPsw:setString(inputLimit.ban_ZH_input(strInput))
        end
    end
    self.textSecondPsw:registerScriptEditBoxHandler(onPwdInput)
    self.textSecondPsw:setInputFlag(0)

    local textComfirm = ccui.Helper:seekWidgetByName(root, "TextField_comfirm")
    self.textComfirm = app.EditBoxFactory:createEditBoxByImage(textComfirm, "请再次输入二级密码")
    local function onComfirmInput(name, sender)
        if name == "changed" then
            local strInput = self.textComfirm:getString()
            self.textComfirm:setString(inputLimit.ban_ZH_input(strInput))
        end
    end
    self.textComfirm:registerScriptEditBoxHandler(onComfirmInput)
    self.textComfirm:setInputFlag(0)

    self.textCardType = ccui.Helper:seekWidgetByName(root, "TextField_cardType")

    self.textCardNum = ccui.Helper:seekWidgetByName(root, "TextField_cardNum")
    local function onCardNumInput(object, event)
        if event == ccui.TextFiledEventType.insert_text then
            local strInput = self.textCardNum:getString()
            self.textCardNum:setString(inputLimit.pick_Number_input(strInput))
        end
    end
    self.textCardNum:addEventListener(onCardNumInput)

    local textAnswer = ccui.Helper:seekWidgetByName(root, "TextField_answer")
    self.textAnswer = app.EditBoxFactory:createEditBoxByImage(textAnswer, "请输入密码答案")

    self.btnSubmit = ccui.Helper:seekWidgetByName(root, "Button_submit")
    self.btnSubmit:setPressedActionEnabled(true)
    self.btnSubmit0 = ccui.Helper:seekWidgetByName(root, "Button_submit_0")
    self.btnSubmit0:setPressedActionEnabled(true)
    self.btnSubmit:addTouchEventListener(function(widget, type)self:onBtnSubmit(widget, type) end)
    self.btnSubmit0:addTouchEventListener(function(widget, type)self:onBtnSubmit(widget, type) end)

    self.btnCardType = ccui.Helper:seekWidgetByName(root, "Button_cardType")
    self.btnCardType:addTouchEventListener(function(widget, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            self.layCardType:setVisible(true)
        end
    end)

    local textQuestion = ccui.Helper:seekWidgetByName(root, "TextField_question")
    self.textQuestion = app.EditBoxFactory:createEditBoxByImage(textQuestion, "请选择密保问题")
    self.textQuestion:setEnabled(false)
    self.btnQuestion = ccui.Helper:seekWidgetByName(root, "Button_question")
    self.btnQuestion:addTouchEventListener(function(widget, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            self.layQuestion:setVisible(true)
        end
    end)

    self.layCardType = ccui.Helper:seekWidgetByName(root, "Panel_cardType")
    self.layCardType:setVisible(false)
    self.layCardType:addTouchEventListener(function(widget, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            self.layCardType:setVisible(false)
        end
    end)
    self.layQuestion = ccui.Helper:seekWidgetByName(root, "Panel_question")
    self.layQuestion:setVisible(false)
    self.layQuestion:addTouchEventListener(function(widget, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            self.layQuestion:setVisible(false)
        end
    end)
    local btnClose = ccui.Helper:seekWidgetByName(root, "Button_close")
    btnClose:setPressedActionEnabled(true)
    btnClose:addTouchEventListener(function(widget, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            self:setVisible(false)
            --self.currScene.layIndividual:setVisible(true)
        end
    end)
    initListViews(self)
    clearInput(self)
end

function SecondPswLayer:fillDataToUI()
    local userData = cc.dataMgr.lobbyUserData.lobbyUser
    self.btnSubmit:setVisible(userData.isHaveAdvPasswd == 0)
    self.btnSubmit0:setVisible(userData.isHaveAdvPasswd ~= 0)
    self.labelAwardTip:setVisible(userData.isHaveAdvPasswd == 0)
end

function SecondPswLayer:onBtnSubmit(widget, type)
    if type == 2 then
        app.audioPlayer:playClickBtnEffect()
        local strSePsw = self.textSecondPsw:getString()
        local strComfirm = self.textComfirm:getString()
        --local strCardType = self.textCardType:getString()
        --local strCardNum = self.textCardNum:getString()
        local strQuestion = self.textQuestion:getString()
        local strAnswer = self.textAnswer:getString()

        local errCode = InputCheck.checkSePsw(strSePsw)
        print("check sepsw, errCode:"..errCode)
        if errCode == 1 then
            ToastLayer.show("请输入二级密码")
            return
        elseif errCode == 2 then
            ToastLayer.show("二级密码长度为8~16位")
            return
        elseif errCode == 3 then
            ToastLayer.show("二级密码不能全为数字或全为字母")
            return
        end

        if strSePsw ~= strComfirm then
            ToastLayer.show("两次输入的二级密码不一致")
            return
        end

        --[[
        if strCardType == "" then
            ToastLayer.show("请选择证件类型")
            return
        end

        if strCardNum == "" then
            ToastLayer.show("请填写证件号码")
            return
        end

        if strCardType == "身份证" then
            errCode = InputCheck.checkCardId(strCardNum)
            print("checkCardId, errCode:"..errCode)
            if errCode == 1 then
                ToastLayer.show("请填写证件号码")
                return
            elseif errCode == 2 then
                ToastLayer.show("请输入完整的身份证号")
                return
            elseif errCode == 3 then
                ToastLayer.show("身份证号中有错误的字符")
                return
            elseif errCode == 4 or errCode == 5 then
                ToastLayer.show("错误的身份证号")
                return
            end
        end
        --]]

        if strQuestion == "" then
            ToastLayer.show("请选择密保问题")
            return
        end

        if strAnswer == "" then
            ToastLayer.show("请填写密保答案")
            return
        end

        local userData = cc.dataMgr.lobbyUserData.lobbyUser
        if userData.isHaveAdvPasswd == 0 then
            app.individualLogic:reqCreateSepsw(strSePsw, "", "", strQuestion, strAnswer)
        else
            app.individualLogic:reqChangeSepsw(strSePsw, "", "", strQuestion, strAnswer)
        end
    end
end

function SecondPswLayer:init(currScene)
    self.root = cc.CSLoader:createNode("Layers/SecondPswLayer.csb")
    self.rootLayer = self.root:getChildByName("Panel_secondPsw")
    self.currScene = currScene
    self.currScene:addChild(self.root, 25)
    initWidgets(self)
    listenEvent(self)
    self:setVisible(false)
end

function SecondPswLayer:setVisible(bShow, lastLayer)
    self.root:setVisible(bShow)
    if self.latLayer ~= nil and not bShow then
        self.lastLayer:setVisible(true)
    end

    if bShow then
        clearInput(self)
        self:fillDataToUI()
        app.popLayer.show(self.rootLayer:getChildByName("Image_background"))
        app.hallScene.nPopLayers = app.hallScene.nPopLayers + 1
    else
        app.hallScene.nPopLayers = app.hallScene.nPopLayers - 1
    end

    self.lastLayer = lastLayer
end

return SecondPswLayer