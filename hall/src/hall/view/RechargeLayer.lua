--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/9/10
-- Time: 11:08
-- To change this template use File | Settings | File Templates.
--
local ToastLayer = require("app.func.ToastLayer")
local MsgBox = require("app.func.MessageBox")
local targetPlatform = cc.Application:getInstance():getTargetPlatform()
local ReminderPoint = require("hall.view.ReminderPoint")

local RechargeLayer = class("RechargeLayer")

function RechargeLayer:init(currScene, parentLayer)
    print("init recharge layer")
    self.currScene = currScene
    self.root = cc.CSLoader:createNode("Layers/RechargeLayer.csb")
    print("recharge resource loaded")
    parentLayer:addChild(self.root, 25)

    self:initWidgets()
    self:listenEvent()
    self:setVisible(false)
end

function RechargeLayer:initWidgets()
    self.layRecharge = self.root:getChildByName("Panel_recharge")
    local layRecharge = self.layRecharge

    self.listRecharge = layRecharge:getChildByName("ListView_recharge")
    self.layListItem = layRecharge:getChildByName("Panel_rechargeListItem")
    self.layListItem:setVisible(false)
    self.layPlatform = layRecharge:getChildByName("Panel_selectPlatform")
    self.layPlatform:setVisible(false)
--    self.layPlatform:addTouchEventListener(function(widget, type)
--        if type == 2 then
--            app.audioPlayer:playClickBtnEffect()
--            self.layPlatform:setVisible(false)
--        end
--    end)
    local btnWechatPay = ccui.Helper:seekWidgetByName(self.layPlatform, "Button_wechatPay")
    btnWechatPay:setPressedActionEnabled(true)
    btnWechatPay:addTouchEventListener(function(widget, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            if targetPlatform ~= cc.PLATFORM_OS_WINDOWS then
                local bridge = require("app.func.Bridge")
                local bWeChatApiUseable = bridge.isWeChatInstalled() and bridge.isWeChatAPISupported()
                if bWeChatApiUseable then
                    app.shopLogic:reqGetOrderInfoWeChat(self.selectedProductId)
                    app.holdOn.show("正在获取订单信息……", 1)
                else
                    app.toast.show("抱歉，请先安装最新版本微信")
                end
            end
        end
    end)
    local btnAliPay = ccui.Helper:seekWidgetByName(self.layPlatform, "Button_aliPay")
    btnAliPay:setPressedActionEnabled(true)
    btnAliPay:addTouchEventListener(function(widget, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            app.shopLogic:reqGetOderInfoAliPay(self.selectedProductId)
            app.holdOn.show("正在获取订单信息……", 1)
        end
    end)
    local btnUPPay = ccui.Helper:seekWidgetByName(self.layPlatform, "Button_UPPay")
    btnUPPay:setPressedActionEnabled(true)
    btnUPPay:addTouchEventListener(function(widget, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            app.shopLogic:reqGetOrderInfoUPPay(self.selectedProductId)
            app.holdOn.show("正在获取订单信息……", 1)
        end
    end)

    local btnClose = ccui.Helper:seekWidgetByName(self.layPlatform, "Button_close")
    btnClose:addTouchEventListener(function(widget, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            self.layPlatform:setVisible(false)
        end
    end)

    --[[
    self.btnAward = layRecharge:getChildByName("Button_award")
    self.btnAward:setPressedActionEnabled(true)
    self.btnAward:setVisible(false)
    self.btnAward:addTouchEventListener(function(widget, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()

            app.popLayer.showEx(self.layAward)
            self.layAward:setVisible(true)
            self:fillDataToAwardList()
        end
    end)
    ReminderPoint.new():init(self.btnAward, "rechargeAward", self.currScene)
    self.layAward = layRecharge:getChildByName("Panel_award")
    self.layAward:addTouchEventListener(function(widget, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            self.layAward:setVisible(false)
        end
    end)
    self.layAward:setVisible(false)

    local layAwardList = ccui.Helper:seekWidgetByName(self.layAward, "Panel_awardItems")
    self.posXLayAwardList = layAwardList:getPositionX()
    --]]
end

function RechargeLayer:listenEvent()
    self.currScene.eventProtocol:addEventListener("PRODUCT_LIST", function(event) --商品列表
        print("products list is received")
        app.holdOn.hide()
        self:fillDataToProductList()
    end)

    --[[
    local function updateUI(event)
        app.holdOn.hide()
        self:fillDataToAwardList()
    end

    self.currScene.eventProtocol:addEventListener("PL_PHONE_LC_SHOWFIRSTINFO_ACK_P", updateUI)
    self.currScene.eventProtocol:addEventListener("PL_PHONE_LC_GETRECHARGEAWARDINFO_ACK_P", updateUI)

    self.currScene.eventProtocol:addEventListener("PL_PHONE_LC_GETRECHARGEAWARD_ACK_P", function(event) --领取奖励
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
                self.currScene.layPhoneBind:setVisible(true)
            end
            MsgBox.showMsgBoxTwoBtn("需要绑定手机号才能领取该奖励", funOk, nil, "充值", "去绑定", "取消")
        elseif ret == 3 then
            --已经领取过奖励
            ToastLayer.show("您已经领取过该奖励")
        end
    end)
    --]]

    self.currScene.eventProtocol:addEventListener("ORDER_INFO", function(event) --订单信息
        print("order info result")
        app.holdOn.hide()
        if event.data == "success" then
            app.holdOn.show("跳转至支付页面……")
            self.bRecharging = true
        else
            ToastLayer.show("获取订单信息失败:"..event.data)
        end
        self.layPlatform:setVisible(false)
    end)

    self.currScene.eventProtocol:addEventListener("PAY_RESULT", function(event) --支付结果
        print("pay result")
        app.holdOn.hide()
        local ret = event.data.result
        local strMsg = "支付失败"
        if ret == "success" then
            strMsg = "恭喜你充值成功，游戏豆将于稍后到账！"
            app.shopLogic:upDateCurrencyInfo()
        elseif ret == "failed" then
            strMsg = "支付失败"
        elseif ret == "canceled" then
            strMsg = "操作已取消"
        elseif ret == "erro" then
            strMsg = "支付出错"
        elseif ret == "comfirm" then
            strMsg = "支付结果确认中"
        end
        local function showResult()
            ToastLayer.show(strMsg)
        end
        if targetPlatform == cc.PLATFORM_OS_ANDROID then
            local delay = cc.DelayTime:create(1);
            local fc = cc.CallFunc:create(showResult)
            self.root:runAction(cc.Sequence:create(delay, fc))
        else
            showResult()
        end
    end)

    self.currScene.eventProtocol:addEventListener("ON_RESUME", function(event) --后台唤醒
        print("event ON_RESUME")
        if self.bRecharging then
            app.holdOn.hide()
        end
    end)
end

function RechargeLayer:setVisible(bShow)
    if bShow then
        self:fillDataToProductList()
        --self:fillDataToAwardList()
        if cc.dataMgr.productsList == nil then
            if targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD then
                app.shopLogic:ios_reqGetProductsList()
                app.holdOn.show("正在获取商品信息，请稍候……")
            else
                app.shopLogic:reqGetProductsList()
                app.holdOn.show("正在获取商品信息，请稍候……")
            end
        end
        --[[
        app.shopLogic:reqGetRechargeAwardInfo()
        self.layAward:setVisible(false)
        --]]
    end

    self.root:setVisible(bShow)
end

function RechargeLayer:fillDataToProductList()
    --初始化商品列表
    print("init productList")
    self.listRecharge:removeAllItems()
    local productsList = cc.dataMgr.productsList
    if productsList == nil then print("productList is nil") return end
    local nColumn = 4
    local nRow = #productsList / nColumn
    local nRest = #productsList % nColumn
    if nRest ~= 0 then nRow = nRow + 1 end
    local count = 0
    for i = 1, nRow do
        local layItem = self.layListItem:clone()
        layItem:setVisible(true)
        for j = 1, nColumn do
            local item = layItem:getChildByName("Image_item"..j)
            item:setVisible(false)
        end
        for j = 1, nColumn do
            count = count + 1
            --print(#productsList)
            if count > #productsList then break end
            local data = productsList[count]
            local item = layItem:getChildByName("Image_item"..j)
            item:setVisible(true)
            local imgTag = item:getChildByName("Image_tag")

            local labelProductName = item:getChildByName("Text_productName")
            local labelPrice = item:getChildByName("BitmapFontLabel_price")

            if targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD then
                local strTagFile
                if data.State == 1 then
                    strTagFile = "Resources/shop/shop_newProduct.png"
                elseif data.State == 2 then
                    strTagFile = "Resources/shop/shop_hot.png"
                end
                if strTagFile ~= nil then
                    local sp = cc.SpriteFrameCache:getInstance():getSpriteFrame(strTagFile)
                    if sp ~= nil then
                        imgTag:loadTexture(strTagFile, 1)
                    end
                else
                    imgTag:setVisible(false)
                end
                labelPrice:setString(data.productPrice.."元")

                local strProductType = ""
                if data.productType == 1 then
                    strProductType = "游戏豆"
                elseif data.productType == 2 then
                    strProductType = "风雷币"
                end
                local strName = data.productNum
                if data.productNum > 10000000 then
                    strName = strName.."\n"
                end
                labelProductName:setString(data.productNum..strProductType)

                local iconFile = "#Resources/shop/shopIcon_0.png"
                if data.Icon ~= nil and data.Icon >= 0 and data.Icon < 5 then
                    iconFile = "#Resources/shop/shopIcon_"..data.Icon..".png"
                end
                local sp = display.newSprite(iconFile)
                sp:setPosition(item:getContentSize().width / 2, 130)
                item:addChild(sp, 1)

                item:addTouchEventListener(function(obj, type)
                    if type == 2 then
                        app.audioPlayer:playClickBtnEffect()
                        --[[
                        if cc.dataMgr.guestLogin then
                            local function funcOk()
                                self.currScene.layShop:setVisible(fasle)
                                local bindCtr = require("hall.view.AccountBindLayer")
                                local bindAccountLayer = bindCtr:createLayer()
                                self.currScene:addChild(bindAccountLayer, 20)
                                app.hallScene.bindAccountLayer = bindAccountLayer
                                app.hallScene.nPopLayers = app.hallScene.nPopLayers + 1
                            end
                            app.msgBox.showMsgBoxTwoBtn("您正处于试玩状态下，请绑定为正式账号再进行此操作", funcOk, nil, nil, "去绑定")
                            return
                        end
                        --]]
                        self.selectedProductId = data.productId
                        --self.layPlatform:setVisible(true)
                        local bridge = require("app.func.Bridge")
                        bridge.IOSPay(data.productId)
                    end
                end)
            else
                local strTagFile
                if data.State == 1 then
                    strTagFile = "Resources/shop/shop_newProduct.png"
                elseif data.State == 2 then
                    strTagFile = "Resources/shop/shop_hot.png"
                end
                if strTagFile ~= nil then
                    local sp = cc.SpriteFrameCache:getInstance():getSpriteFrame(strTagFile)
                    if sp ~= nil then
                        imgTag:loadTexture(strTagFile, 1)
                    end
                else
                    imgTag:setVisible(false)
                end
                labelPrice:setString(data.Price.."元")
                local strName = data.ProductName
                local ch = string.byte(strName, 7)
                if ch >= 48 and ch <= 57 then
                    local index
                    for i = 1, string.len(strName) do
                        local char = string.byte(strName, i)
                        if char < 48 or char > 57 then
                            index = i - 1
                            break
                        end
                    end
                    if index ~= nil then
                        strName = string.sub(strName, 1, index).."\n"..string.sub(strName, index + 1, -1)
                    end
                end
                labelProductName:setString(strName)
                local iconFile = "#Resources/shop/shopIcon_0.png"
                if data.Icon ~= nil and data.Icon >= 0 and data.Icon < 5 then
                    iconFile = "#Resources/shop/shopIcon_"..data.Icon..".png"
                end
                local sp = display.newSprite(iconFile)
                sp:setPosition(item:getContentSize().width / 2, 130)
                item:addChild(sp, 1)
                item:addTouchEventListener(function(obj, type)
                    if type == 2 then
                        app.audioPlayer:playClickBtnEffect()
                        --[[
                        if cc.dataMgr.guestLogin then
                            local function funcOk()
                                self.currScene.layShop:setVisible(fasle)
                                local bindCtr = require("hall.view.AccountBindLayer")
                                local bindAccountLayer = bindCtr:createLayer()
                                self.currScene:addChild(bindAccountLayer, 20)
                                app.hallScene.bindAccountLayer = bindAccountLayer
                                app.hallScene.nPopLayers = app.hallScene.nPopLayers + 1
                            end
                            app.msgBox.showMsgBoxTwoBtn("您正处于试玩状态下，请绑定为正式账号再进行此操作", funcOk, nil, nil, "去绑定")
                            return
                        end
                        --]]
                        self.selectedProductId = data.Id
                        app.popLayer.showEx(self.layPlatform)
                        self.layPlatform:setVisible(true)
                    end
                end)
            end
        end
        self.listRecharge:insertCustomItem(layItem, i - 1)
    end
end

--[[
function RechargeLayer:fillDataToAwardList()
    --初始化奖励界面
    print("init awardList")
    local awardConfig = cc.dataMgr.rechargeAwardConfig
    if awardConfig == nil or awardConfig.bStartRechargeAward == 0 then return end
    self.btnAward:setVisible(true)
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
        self.btnAward:setVisible(false)
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
                        self.currScene.layPhoneBind:setVisible(true)
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
--]]

return RechargeLayer

