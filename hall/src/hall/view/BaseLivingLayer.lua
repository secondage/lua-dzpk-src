--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/8/31
-- Time: 14:23
-- To change this template use File | Settings | File Templates.
--
local ToastLayer = require("app.func.ToastLayer")

local BaseLivingLayer = class("BaseLivingLayer")

function BaseLivingLayer:init(currScene)
    self.currScene = currScene
    self:listenEvent()
end

function BaseLivingLayer:initWidgets()
    self.root = cc.CSLoader:createNode("Layers/BaseLivingLayer.csb")
    self.currScene:addChild(self.root, 20)
    self.layBaseLiving = self.root:getChildByName("Panel_baseLiving")

    local layBaseLiving = self.layBaseLiving
    layBaseLiving:addTouchEventListener(function(widget, type)
        if type == 2 then
            self:setVisible(false)
        end
    end)

    local imgBk = ccui.Helper:seekWidgetByName(layBaseLiving, "Image_backGroud")
    self.nodeBoxes = imgBk:getChildByName("Node_boxes")
    self.nodePhone = imgBk:getChildByName("Node_phoneBind")

    self.btnBox = {}
    self.labelAward = {}
    self.imgBoxOpen = {}
    self.imgLight = {}
    --箱子界面
    local nodeBoxes = self.nodeBoxes
    nodeBoxes:setVisible(false)
    for i = 1, 3 do
        local strName = string.format("Node_box%d", i)
        local nodeBox = nodeBoxes:getChildByName(strName)

        local btnBox = nodeBox:getChildByName("Button_box")
        btnBox:setPressedActionEnabled(true)
        self.posY = btnBox:getPositionY()
        self.btnBox[i] = btnBox
        btnBox:setTag(i)
        btnBox:addTouchEventListener(function(widget, type)
            if type == 2 then
                app.audioPlayer:playClickBtnEffect()
                self:stopBoxesAnim()
                self.selectedBoxTag = widget:getTag()
                self:startShakeAnim(widget)
                app.individualLogic:reqGetBaseLiving()

                --self:onBaseLivingReceived()
            end
        end)

        local labelGameCurrency = nodeBox:getChildByName("BitmapFontLabel_gameCurrency")
        labelGameCurrency:setVisible(false)
        self.labelAward[i] = labelGameCurrency

        local imgBoxOpen = nodeBox:getChildByName("Image_boxOpen")
        imgBoxOpen:setVisible(false)
        self.imgBoxOpen[i] = imgBoxOpen

        local imgLight = nodeBox:getChildByName("Image_light")
        imgLight:setVisible(false)
        self.imgLight[i] = imgLight
    end
    self.labelMsg = nodeBoxes:getChildByName("Text_baseLivingMsg")

    --手机号绑定界面
    local nodePhone = self.nodePhone
    nodePhone:setVisible(fasle)
    local btnPhoneBind = nodePhone:getChildByName("Button_phoneBind")
    btnPhoneBind:setPressedActionEnabled(true)
    btnPhoneBind:addTouchEventListener(function(widget, type)
        if type == 2 then
            --跳转至大厅场景并打开手机号绑定界面
            app.audioPlayer:playClickBtnEffect()
            cc.dataMgr.isRoomBackToHall = true
            cc.msgHandler:disconnectFromGame()
            app.sceneSwitcher:enterScene("HallScene", 1)
            self.isBackToHallScene = true
        end
    end)
end

function BaseLivingLayer:fillDataToUI()
    local nodeBoxes = self.nodeBoxes
    local nodePhone = self.nodePhone

    local data = cc.dataMgr.baseLivingData
--[[
    data.nResult = 0
    data.dayGetTimes = 3
    data.getTimes = 1
    data.dayGetCurrency = 1000
    data.showGetCurrencyOne = 1800
    data.showGetCurrencyTwo = 3000
--]]
    if next(data) == nil then return end
    --local userInfoMore = cc.dataMgr.userInfoMore or {phoneBindState = false}
    local bPhoneBinded = data.nResult == 0 --and userInfoMore.phoneBindState ~= 0;
    nodeBoxes:setVisible(bPhoneBinded)
    nodePhone:setVisible(not bPhoneBinded)

    if bPhoneBinded then
        local strMsg = string.format("你获得领取救济宝箱机会，赶快挑选一个继续战斗吧！（今日第%d次，总共%d次。）", data.getTimes, data.dayGetTimes)
        self.labelMsg:setString(strMsg)
        self:startFloatingAnim()
    end

end

function BaseLivingLayer:setVisible(bShow)
    if bShow then
        if self.root == nil then
            self:initWidgets()
            self:fillDataToUI()
        end
        app.popLayer.showEx(self.layBaseLiving:getChildByName("Image_backGroud"))
    else
        if self.root ~= nil then
            self.root:removeSelf()
            self.root = nil
        end
    end
end

function BaseLivingLayer:listenEvent()
    --[[
    self.currScene.eventProtocol:addEventListener("GC_GETBASELIVEING_ACK_P", function(event)
        local ret = event.data.nResult
        if ret == 0 or ret == 1 then
            print("event GC_GETBASELIVEING_ACK_P")
            self:setVisible(true)
        end
    end)
    --]]
    app.baseLivingProtocol:removeEventListenersByEvent("GC_GETBASELIVINGCURRENCY_ACK_P")
    app.baseLivingProtocol:addEventListener("GC_GETBASELIVINGCURRENCY_ACK_P", function(event)
        local ret = event.data.nResult
        if ret == 0 then
            self:onBaseLivingReceived()
        else
            ToastLayer.show("领取失败")
            self:setVisible(false)
        end
    end)
end

function BaseLivingLayer:startFloatingAnim()
    for i = 1, 3 do
        local btnBox = self.btnBox[i]
        btnBox:setVisible(true)
        btnBox:setEnabled(true)

        local offsetY = 15
        local timeAnim = 0.35
        local x, y = btnBox:getPosition()
        local moveToTop = cc.MoveTo:create(timeAnim, cc.p(x, y + offsetY))
        local moveToBase = cc.MoveTo:create(timeAnim, cc.p(x, y))
        local moveToBottom = cc.MoveTo:create(timeAnim, cc.p(x, y - offsetY))
        local sequence = cc.Sequence:create(moveToTop, moveToBase, moveToBottom, moveToBase)
        local anim = cc.RepeatForever:create(sequence)
        btnBox:runAction(anim)
    end
end

function BaseLivingLayer:stopBoxesAnim()
    for i = 1, 3 do
        self.btnBox[i]:stopAllActions()
        self.btnBox[i]:setPositionY(self.posY)
    end
end

function BaseLivingLayer:startShakeAnim(widget)
    local time = 0.05
    local angle = 30.0
    widget:stopAllActions()
    local rotateToTop = cc.RotateTo:create(time, angle);
    local rotateToBase = cc.RotateTo:create(time, 0);
    local rotateToBottom = cc.RotateTo:create(time, -angle);
    local delay = cc.DelayTime:create(0.5);
    local shakeAnim = cc.Sequence:create(rotateToTop, rotateToBase, rotateToBottom, rotateToBase);
    local anim = cc.RepeatForever:create(cc.Sequence:create(shakeAnim, shakeAnim, delay));
    widget:runAction(anim);
end

function BaseLivingLayer:onBaseLivingReceived()
    local data = cc.dataMgr.baseLivingData
    local strMsg = string.format("你获得领取救济宝箱机会，赶快挑选一个继续战斗吧！（今日第%d次，总共%d次。）", data.getTimes + 1, data.dayGetTimes)
    self.labelMsg:setString(strMsg)
    local bTmp = false
    for i = 1, 3 do
        local btnBox = self.btnBox[i]
        local imgLight = self.imgLight[i]
        local imgBoxOpen = self.imgBoxOpen[i]
        local labelAward = self.labelAward[i]
        btnBox:setEnabled(false)
        if i == self.selectedBoxTag then
            self.selectedBoxTag = 0
            labelAward:setString(data.dayGetCurrency)
            local func = cc.CallFunc:create(function()
                btnBox:stopAllActions()
                btnBox:setVisible(false)
                imgBoxOpen:setVisible(true)
                labelAward:setVisible(true)
                imgLight:setVisible(true)
                local rot = cc.RotateBy:create(1.5, 360.0)
                local anim = cc.RepeatForever:create(rot)
                imgLight:runAction(anim)
            end)
            local delay = cc.DelayTime:create(1.0);
            btnBox:runAction(cc.Sequence:create(delay, func))
        else
            if not bTmp then
                labelAward:setString(data.showGetCurrencyOne)
                bTmp = true
            else
                labelAward:setString(data.showGetCurrencyTwo)
            end
            local fc = cc.CallFunc:create(function()
                labelAward:setVisible(true);
                btnBox:setVisible(false);
                imgBoxOpen:setVisible(true);
            end)
            --被点击的箱子打开后两秒另外两个箱子打开
            local delay = cc.DelayTime:create(2.0)
            labelAward:runAction(cc.Sequence:create(delay, fc))
        end
    end
end
app.baseLivingProtocol:removeEventListenersByEvent("GC_GETBASELIVEING_ACK_P")
app.baseLivingProtocol:addEventListener("GC_GETBASELIVEING_ACK_P", function(event)
    print("event GC_GETBASELIVEING_ACK_P")
    local scene = display:getRunningScene().root
    if scene == nil then print("scene is nil") return end
    local ret = event.data.nResult
    if ret == 0 or ret == 1 then
        if scene.baseLivingLayer == nil then
            scene.baseLivingLayer = BaseLivingLayer.new()
            scene.baseLivingLayer:init(scene)
        end
        scene.baseLivingLayer:setVisible(true)
    end
end)

return BaseLivingLayer

