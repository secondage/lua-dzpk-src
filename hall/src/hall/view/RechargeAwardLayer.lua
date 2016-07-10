--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2016/1/29
-- Time: 10:46
-- To change this template use File | Settings | File Templates.
--
local ToastLayer = require("app.func.ToastLayer")
local MsgBox = require("app.func.MessageBox")

local RechargeAwardLayer = class("RechargeAwardLayer")

function RechargeAwardLayer.create()
    local awardLayer = RechargeAwardLayer.new()
    awardLayer:init()
    return awardLayer
end

function RechargeAwardLayer:ctor()

end

function RechargeAwardLayer:init()
    self.root = cc.CSLoader:createNode("Layers/RechargeAwardLayer.csb")
    self.layAward = self.root:getChildByName("Panel_award")
    local btnClose = ccui.Helper:seekWidgetByName(self.layAward, "Button_close")
    btnClose:addTouchEventListener(function(widget, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            self:setVisible(false)
        end
    end)
    self:setVisible(false)

    local layAwardList = ccui.Helper:seekWidgetByName(self.layAward, "Panel_awardItems")
    self.posXLayAwardList = layAwardList:getPositionX()

    self:listenEvent()
end

function RechargeAwardLayer:fillDataToUI()
    --初始化奖励界面
    print("init awardList")
    local awardConfig = cc.dataMgr.rechargeAwardConfig
    if awardConfig == nil or awardConfig.bStartRechargeAward == 0 then return end
    --self.btnAward:setVisible(true)
    local awardInfoList = awardConfig.rechargeAwardInfo
    local awardInfo = cc.dataMgr.rechargeAwardInfo
    if awardInfo == nil then return end

    local awardData
    for i = 1, #awardInfoList do
        local data = awardInfoList[i]
        if data.order == awardInfo.awardOrder then
            awardData = data
            break
        end
    end
    if awardData == nil then
        print("awardData not found")
        self:setVisible(false)
        return
    end

    local userInfoMore = cc.dataMgr.userInfoMore
    local btnGetAward = ccui.Helper:seekWidgetByName(self.layAward, "Button_getAward")
    btnGetAward:setPressedActionEnabled(true)
    btnGetAward:setEnabled(awardInfo.bCanGetAward ~= 0)
    btnGetAward:setBright(awardInfo.bCanGetAward ~= 0)
    btnGetAward:addTouchEventListener(function(obj, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            if awardInfo.bCanGetAward ~= 0 then
                if userInfoMore.phoneBindState == 0 then
                    --未绑定手机号
                    local function funOk()
                        self:setVisible(false)
                        app.hallScene.layPhoneBind:setVisible(true)
                    end
                    MsgBox.showMsgBoxTwoBtn("需要绑定手机号才能领取该奖励", funOk, nil, "充值", "去绑定", "取消")
                    return
                end
                app.shopLogic:reqGetRechargeAward(awardData.order)
            else
                ToastLayer.show("未达到充值限额，无法领取")
            end
        end
    end)
    local labelAwardTips = ccui.Helper:seekWidgetByName(self.layAward, "Text_rechargeAward")
    labelAwardTips:setString(awardData.rechargeMoney)
    --awardData.awardIcon
    local layAwardList = ccui.Helper:seekWidgetByName(self.layAward, "Panel_awardItems")
    layAwardList:setPositionX(self.posXLayAwardList)

    local awardList = awardData.awardTypeInfo
    print("#awardList:"..#awardList)
    for i = 1, 3 do
        if i > #awardList then
            local item = layAwardList:getChildByName("Image_award"..i)
            item:setVisible(false)
        else
            local data = awardList[i]
            local type = data.awardType
            print("awardType = "..type)
            local num = data.awardNum
            print("awardNum = "..num)
            local item = layAwardList:getChildByName("Image_award"..i)
            item:setVisible(true)
            local labelAwardName = item:getChildByName("Text_awardName")
            local strAwardName = data.awardNum
            local strAwardIcon
            if data.awardType == 1 then
                strAwardName = strAwardName.."游戏豆"
                strAwardIcon = "Resources/shop/award_gold.png"
            elseif data.awardType == 2 then
                strAwardName = strAwardName.."元宝"
                strAwardIcon = "Resources/shop/award_ingot.png"
            elseif data.awardType == 3 then
                strAwardName = strAwardName.."天会员"
                strAwardIcon = "Resources/shop/award_vip.png"
            end
            labelAwardName:setString(strAwardName)
            if strAwardIcon ~= nil then
                print("strAwardIcon:"..strAwardIcon)
                local sp = cc.SpriteFrameCache:getInstance():getSpriteFrame(strAwardIcon)
                if sp ~= nil then
                    item:loadTexture(strAwardIcon, 1)
                end
            end
        end
    end

    local sizePanel = layAwardList:getContentSize()
    --print("width:"..sizePanel.width)
    local posX = layAwardList:getPositionX()
    --print("posX:"..posX)
    local offsetX = sizePanel.width / 6 * (3 - #awardList)
    --print("offsetX:"..offsetX)
    layAwardList:setPositionX(posX + offsetX)
    --posX = layAwardList:getPositionX()
    --print("posX:"..posX)
end

function RechargeAwardLayer:listenEvent()
    local function updateUI(event)
        app.holdOn.hide()
        self:fillDataToUI()
    end

    app.hallScene.eventProtocol:addEventListener("PL_PHONE_LC_SHOWFIRSTINFO_ACK_P", updateUI)
    app.hallScene.eventProtocol:addEventListener("PL_PHONE_LC_GETRECHARGEAWARDINFO_ACK_P", updateUI)

    app.hallScene.eventProtocol:addEventListener("PL_PHONE_LC_GETRECHARGEAWARD_ACK_P", function(event) --领取奖励
        print("getAwardResult")
        local ret = event.data.nResult
        if ret == 0 then
            --成功
            ToastLayer.show("领取成功")
        elseif ret == 1 then
            --失败
            ToastLayer.show("领取失败")
        elseif ret == 2 then
            --未绑定手机号
            local function funOk()
                app.hallScene.layPhoneBind:setVisible(true)
            end
            MsgBox.showMsgBoxTwoBtn("需要绑定手机号才能领取该奖励", funOk, nil, "充值", "去绑定", "取消")
        elseif ret == 3 then
            --已经领取过奖励
            ToastLayer.show("您已经领取过该奖励")
        end
    end)
end

function RechargeAwardLayer:setVisible(bShow)
    self.root:setVisible(bShow)
    if bShow then
        self:fillDataToUI()
        app.popLayer.showEx(self.root)
    end
end

return RechargeAwardLayer
