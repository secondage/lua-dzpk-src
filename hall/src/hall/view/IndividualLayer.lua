--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/8/26
-- Time: 10:01
-- To change this template use File | Settings | File Templates.
--
local inputCheck = require("app.func.InputCheck")
local honourExp = {5600, 12000, 24000, 48000, 84000, 144000, 240000, 396000, 648000, 1056000, 1716000, 2784000, 3884000, 5444000,
    7688000, 9762000, 12288000, 15970000
};
local ToastLayer = require("app.func.ToastLayer")

local IndividualLayer = class("IndividualLayer")
--IndividualLayer.layChangePsw = require("hall.view.ChangePswLayer").new()
--IndividualLayer.laySecondPsw = require("hall.view.SecondPswLayer").new()
--IndividualLayer.layPhoneBind = require("hall.view.PhoneBindLayer").new()
--IndividualLayer.layAvatarSel = require("hall.view.AvatarSelectLayer").new()

function IndividualLayer:init(currScene)
    self.currScene = currScene
    self.root = cc.CSLoader:createNode("Layers/IndividualLayer.csb")
    self.currScene:addChild(self.root, 20)

    self:listenEvent()
    self:initWidgetsEventListener()
    self:setVisible(false)
end

function IndividualLayer:listenEvent()
    self.currScene.eventProtocol:addEventListener("SC_CHANGE_NICKNAME_P", function(event) --修改昵称、头像、性别
    if event.data.ret == 0 then
        ToastLayer.show("修改成功")
    else
        if event.data.ret == 1 then
            ToastLayer.show("昵称已存在")--昵称已存在
        elseif event.data.ret == 2 then
            ToastLayer.show("昵称非法")--昵称非法
        else
            ToastLayer.show("未知错误")--未知错误
        end
    end
    end)

    self.currScene.eventProtocol:addEventListener("USERDATA_CHANGED", function() --个人信息变动
    self:fillDataToUI()
    end)
end

function IndividualLayer:setVisible(bShow)
    if bShow then
        self:fillDataToUI()
        app.hallScene.nPopLayers = app.hallScene.nPopLayers + 1
        app.popLayer.show(self.root:getChildByName("Panel_individual"):getChildByName("Image_background"))
    else
        app.hallScene.nPopLayers = app.hallScene.nPopLayers - 1
    end
    self.root:setVisible(bShow)
end

function IndividualLayer:fillDataToUI()
    local userData = cc.dataMgr.lobbyUserData.lobbyUser
    local userInfoMore = cc.dataMgr.userInfoMore
    if userInfoMore == nil then return end
    print("IndividualLayer:fillDataToUI()")

    local layIndividual = self.root:getChildByName("Panel_individual")
    --头像
    local avatarFile = "avatar/"..userData.icon..".jpg"
    --print(avatarFile)
    self.imgAvatar:loadTexture(avatarFile, ccui.TextureResType.localType)

    --ID
    local labelID = ccui.Helper:seekWidgetByName(layIndividual, "BitmapFontLabel_userId")
    labelID:setString(userData.userID)

    --昵称
    self.textNickName:setString(userData.strNickNamebuf)

    --性别
    self.checkGenderMale:setSelected(userData.gender == 0)
    self.checkGenderFemale:setSelected(userData.gender == 1)

    --游戏豆
    local labelGameCurrency = ccui.Helper:seekWidgetByName(layIndividual, "gameCurrency")
    labelGameCurrency:setString(userData.gameCurrency.l)

    --元宝
    local labelIngot = ccui.Helper:seekWidgetByName(layIndividual, "Text_ingot")
    if userInfoMore ~= nil and userInfoMore.ingot ~= nil then
        labelIngot:setString(userInfoMore.ingot.l)
    end

    --会员
    local labelVip = ccui.Helper:seekWidgetByName(layIndividual, "Text_vipState")
    local strVip = ""
    if userData.vipBegin ==0 and userData.vipExp == 0 then
        strVip = "未开通"
    else
        if userData.vipLevel < 0 then
            strVip = -userData.vipLevel.."级(已过期)"
        else
            strVip = userData.vipLevel.."级"
        end
    end
    labelVip:setString(strVip)
    local nextLevel = userData.honorLevel + 1
    if nextLevel > 18 then nextLevel = 18 end

    --声望
    local progressHonour = ccui.Helper:seekWidgetByName(layIndividual, "LoadingBar_honour")
    progressHonour:setPercent(100 * userData.honor / honourExp[nextLevel])
    local labelHonour = ccui.Helper:seekWidgetByName(layIndividual, "Text_honour")
    labelHonour:setString(userData.honor.."/"..honourExp[nextLevel])
    local labelHonourLevel = ccui.Helper:seekWidgetByName(layIndividual, "Text_honourLevel")
    labelHonourLevel:setString("Lv."..userData.honorLevel)

    --手机号绑定
    local btnPhoneBinded = ccui.Helper:seekWidgetByName(layIndividual, "Button_phoneBinded")
    btnPhoneBinded:setPressedActionEnabled(true)
    local btnPhoneNotBinded = ccui.Helper:seekWidgetByName(layIndividual, "Button_phoneNotBinded")
    btnPhoneNotBinded:setPressedActionEnabled(true)
    btnPhoneBinded:setVisible(userInfoMore.phoneBindState ~= 0)
    btnPhoneNotBinded:setVisible(userInfoMore.phoneBindState == 0)

    --试玩账号
    local btnChangePsw = ccui.Helper:seekWidgetByName(layIndividual, "Button_changePsw")
    btnChangePsw:setVisible(not cc.dataMgr.guestLogin)
    local btnBindAccount = ccui.Helper:seekWidgetByName(layIndividual, "Button_bindAccount")
    btnBindAccount:setVisible(cc.dataMgr.guestLogin)
end

function IndividualLayer:initWidgetsEventListener()
    local layIndividual = self.root:getChildByName("Panel_individual")
    local function onIndividualLayerClicked(widget, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            self:setVisible(false)
        end
    end
    --layIndividual:addTouchEventListener(onIndividualLayerClicked)
    --绑定手机号
    local btnPhoneBinded = ccui.Helper:seekWidgetByName(layIndividual, "Button_phoneBinded")
    btnPhoneBinded:setPressedActionEnabled(true)
    local btnPhoneNotBinded = ccui.Helper:seekWidgetByName(layIndividual, "Button_phoneNotBinded")
    btnPhoneNotBinded:setPressedActionEnabled(true)
    local function onBtnPhoneBind(widget, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            self:setVisible(false)
            self.currScene.layPhoneBind:setVisible(true)
        end
    end
    btnPhoneBinded:addTouchEventListener(onBtnPhoneBind)
    btnPhoneNotBinded:addTouchEventListener(onBtnPhoneBind)

    --二级密码
    local btnSePsw = ccui.Helper:seekWidgetByName(layIndividual, "Button_sePsw")
    btnSePsw:setPressedActionEnabled(true)
    local function onBtnSePsw(widget, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            self:setVisible(false)
            self.currScene.laySecondPsw:setVisible(true)
        end
    end
    btnSePsw:addTouchEventListener(onBtnSePsw)

    --修改登录密码
    local btnChangePsw = ccui.Helper:seekWidgetByName(layIndividual, "Button_changePsw")
    btnChangePsw:setPressedActionEnabled(true)
    local function onBtnChangePsw(widget, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            self:setVisible(false)
            self.currScene.layChangePsw:setVisible(true)
        end
    end
    btnChangePsw:addTouchEventListener(onBtnChangePsw)

    --绑定正式账号
    local btnBindAccount = ccui.Helper:seekWidgetByName(layIndividual, "Button_bindAccount")
    btnBindAccount:setPressedActionEnabled(true)
    local function onBtnBindAccount(widget, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()

            local bindCtr = require("hall.view.AccountBindLayer")
            local bindAccountLayer = bindCtr:createLayer()
            self.currScene:addChild(bindAccountLayer, 20)
            app.hallScene.nPopLayers = app.hallScene.nPopLayers + 1
            self.currScene.bindAccountLayer = bindAccountLayer
            self:setVisible(fasle)
        end
    end
    btnBindAccount:addTouchEventListener(onBtnBindAccount)

    --充值
    local btnRecharge = ccui.Helper:seekWidgetByName(layIndividual, "Button_recharge")
    btnRecharge:setPressedActionEnabled(true)
    local function onBtnRecharge(widget, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            self:setVisible(false)
            self.currScene.layShop:setVisible(true)
            self.currScene:hideHallUI()
        end
    end
    btnRecharge:addTouchEventListener(onBtnRecharge)
    if app.isAccessAndroidStore == 0 then
        btnRecharge:setVisible(false)
    end

    --抽奖
    local btnLottery = ccui.Helper:seekWidgetByName(layIndividual, "Button_lottery")
    btnLottery:setPressedActionEnabled(true)
    local function onBtnLottery(widget, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            self:setVisible(false)
            self.currScene:showLotteryLayer()
            self.currScene:hideHallUI()
        end
    end
    btnLottery:addTouchEventListener(onBtnLottery)

    --兑换
    local btnExchange = ccui.Helper:seekWidgetByName(layIndividual, "Button_exchange")
    btnExchange:setPressedActionEnabled(true)
    local function onBtnExchange(widget, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            self:setVisible(false)
            self.currScene:showExchangeLayer()
            self.currScene:hideHallUI()
        end
    end
    btnExchange:addTouchEventListener(onBtnExchange)

    --性别
    self.checkGenderMale = ccui.Helper:seekWidgetByName(layIndividual, "CheckBox_male")
    self.checkGenderFemale = ccui.Helper:seekWidgetByName(layIndividual, "CheckBox_female")
    local function onCheckMale(widget, type)
        app.audioPlayer:playClickBtnEffect()
        if type == 0 then
            local userData = cc.dataMgr.lobbyUserData.lobbyUser
            if (userData.gender ~= 0) then
                app.individualLogic:reqChangeBasicInfo(0, "", userData.icon)
            end
        end
        self.checkGenderMale:setSelected(true)
        self.checkGenderFemale:setSelected(false)
    end
    self.checkGenderMale:addEventListener(onCheckMale)

    local function onCheckFemale(widget, type)
        app.audioPlayer:playClickBtnEffect()
        if type == 0 then
            local userData = cc.dataMgr.lobbyUserData.lobbyUser
            if (userData.gender ~= 1) then
                app.individualLogic:reqChangeBasicInfo(1, "", userData.icon)
            end
        end
        self.checkGenderMale:setSelected(false)
        self.checkGenderFemale:setSelected(true)
    end
    self.checkGenderFemale:addEventListener(onCheckFemale)

    --昵称
    local textNickName = ccui.Helper:seekWidgetByName(layIndividual, "TextField_nickName")
    self.textNickName =  app.EditBoxFactory:createEditBoxByImage(textNickName, "")
    local function onTextNickNameInput(name, sender)
        if name == "ended" then
            local userData = cc.dataMgr.lobbyUserData.lobbyUser
            if userData.strNickNamebuf ~= self.textNickName:getString() then
                local strNickName = self.textNickName:getString()
                local mutipleNickName = UTF82Mutiple(strNickName)
                if string.len(mutipleNickName) < 6 or string.len(mutipleNickName) > 16 then
                    ToastLayer.show("昵称长度为6~16字符")
                    self:fillDataToUI()
                    return
                end
                if inputCheck.contaiIllegalChar(strNickName) then
                    ToastLayer.show("昵称含有非法字符")
                    self:fillDataToUI()
                    return
                end
                app.individualLogic:reqChangeBasicInfo(userData.gender, strNickName, userData.icon)
            end
        end
    end
    self.textNickName:registerScriptEditBoxHandler(onTextNickNameInput)

    --头像
    self.imgAvatar = ccui.Helper:seekWidgetByName(layIndividual, "Image_headIcon")
    local function onAvatarClicked(widget, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            self.currScene.layAvatarSel:setVisible(true)
        end
    end
    self.imgAvatar:addTouchEventListener(onAvatarClicked)

    --退出
    local btnClose = ccui.Helper:seekWidgetByName(layIndividual, "Button_close")
    btnClose:setPressedActionEnabled(true)
    local function onBtnClose(widget, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            self:setVisible(false)
        end
    end
    btnClose:addTouchEventListener(onBtnClose)
end

return IndividualLayer

