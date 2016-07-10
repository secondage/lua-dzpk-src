--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/8/31
-- Time: 10:10
-- To change this template use File | Settings | File Templates.
--
local ToastLayer = require("app.func.ToastLayer")
local MsgBox = app.msgBox
local inputLimit = require("app.func.InputUtil")

local VipLayer = class("VipLayer")

function VipLayer:init(currScene, parentLayer)
    print("init vip layer")
    self.currScene = currScene
    self.root = cc.CSLoader:createNode("Layers/VipLayer.csb")
    print("vip resource loaded")
    parentLayer:addChild(self.root, 25)

    self:initWidgets()
    self:listenEvent()
    self:setVisible(false)
end

function VipLayer:onBtnVipPay(widget, type)
    if type == 2 then
        app.audioPlayer:playClickBtnEffect()
        local tag = widget:getTag()
        local days = 0
        local price = 0
        if tag == 0 then
            days = 30
            price = 10.5
        elseif tag == 1 then
            days = 90
            price = 31.5
        elseif tag == 2 then
            days = 180
            price = 63
        elseif tag == 3 then
            days = 360
            price = 126
        end

        local userData = cc.dataMgr.lobbyUserData.lobbyUser

        if userData.gameCurrency.l < price * 10000 then
            ToastLayer.show("游戏豆不足，无法购买！")
            return
        end

        local strMsg = "您是否确认购买会员:"..days.."天,花费:"..price.."万游戏豆"

        local opType = 0
        if userData.vipLevel == 0 then
            opType = 0
        else
            opType = 1
        end

        local function onBtnOk()
            print("show sepsw input")
            self.opType = opType
            self.days = days
            self.textSePsw:setString("")
            self.laySePsw:setVisible(true)
        end
        MsgBox.showMsgBoxTwoBtn(strMsg, onBtnOk, nil, "购买会员", "确定", "取消")
    end
end

function VipLayer:initWidgets()
    self.layVip = self.root:getChildByName("Panel_vip")
    self.laySePsw = self.root:getChildByName("Panel_sePswInput")

    local layVip = self.layVip
    local layVipDate = layVip:getChildByName("Panel_daoqishijian")
    self.labelVipLevel = ccui.Helper:seekWidgetByName(layVip, "BitmapFontLabel_vipLevel")
    self.nodeVipDate = layVipDate:getChildByName("Node_vipDate")
    self.labelVipDate = self.nodeVipDate:getChildByName("BitmapFontLabel_vipDate")
    self.nodeVipDisabled = layVipDate:getChildByName("Node_vipDisabled")
    self.nodeVipOutDate = layVipDate:getChildByName("Node_vipOutDate")

    --头像
    local layAvatar = self.root:getChildByName("ImageAvatarBG")
    self.imgAvatar = layAvatar:getChildByName("ImageAvatar")
    self.imgAvatarBorder = layAvatar:getChildByName("Image_avatarBorder")
    self.imgVipStateEnabled = layAvatar:getChildByName("Image_vipState_enabled")
    self.imgVipStateDisabled = layAvatar:getChildByName("Image_vipState_disabled")
    self.lableVipLevelEnabled = layAvatar:getChildByName("BitmapFontLabel_vipLevel_enabled")
    self.lableVipLevelDisabled = layAvatar:getChildByName("BitmapFontLabel_vipLevel_disabled")

    local listVip = ccui.Helper:seekWidgetByName(layVip, "ListView_vip")
    --1个月
    local panel_0 = ccui.Helper:seekWidgetByName(layVip, "Panel_vipItem_1")
    local btnPrice_0 = panel_0:getChildByName("Button_price")
    btnPrice_0:setTag(0)
    btnPrice_0:setPressedActionEnabled(true)
    btnPrice_0:addTouchEventListener(function(widget, type)self:onBtnVipPay(widget, type)
    end)
    --3个月
    local panel_1 = ccui.Helper:seekWidgetByName(layVip, "Panel_vipItem_3")
    local btnPrice_1 = panel_1:getChildByName("Button_price")
    btnPrice_1:setTag(1)
    btnPrice_1:setPressedActionEnabled(true)
    btnPrice_1:addTouchEventListener(function(widget, type)self:onBtnVipPay(widget, type)
    end)

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
                ToastLayer.show("请先注册二级密码")
                return
            end
            local strSePsw = self.textSePsw:getString()
            if string.len(strSePsw) < 8 then
                ToastLayer.show("请输入正确的二级密码")
                return
            end

            app.individualLogic:reqVipPay(self.days / 30, 0, self.opType, strSePsw)
        end
    end)

    local btnCloseSePsw = ccui.Helper:seekWidgetByName(laySePsw, "Button_close")
    btnCloseSePsw:setPressedActionEnabled(true)
    btnCloseSePsw:addTouchEventListener(function(widget, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            laySePsw:setVisible(false)
        end
    end)

    ---[[
    local layBackground = self.root:getChildByName("Panel_shop")
    local btnReturn = layBackground:getChildByName("Button_return")
    btnReturn:setPressedActionEnabled(true)
    btnReturn:addTouchEventListener(function(widget, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            self:setVisible(false)
        end
    end)
    --]]
end

function VipLayer:fillDataToUI()
    local userData = cc.dataMgr.lobbyUserData.lobbyUser
    if userData.vipLevel == 0 then
        self.labelVipLevel:setString(0)
        self.nodeVipDate:setVisible(false)
        self.nodeVipDisabled:setVisible(true)
        self.nodeVipOutDate:setVisible(false)
    elseif userData.vipLevel < 0 then
        self.labelVipLevel:setString(-userData.vipLevel)
        self.nodeVipDate:setVisible(false)
        self.nodeVipDisabled:setVisible(false)
        self.nodeVipOutDate:setVisible(true)
    else
        self.labelVipLevel:setString(userData.vipLevel)
        local vipEnd = os.date("*t", userData.vipEnd)
        local strTime = vipEnd.year.."/"..vipEnd.month.."/"..vipEnd.day
        self.nodeVipDate:setVisible(true)
        self.nodeVipDisabled:setVisible(false)
        self.nodeVipOutDate:setVisible(false)
        self.labelVipDate:setString(strTime)
    end

    local fn = "avatar/" .. userData.icon .. ".jpg"
    self.imgAvatar:loadTexture(fn, ccui.TextureResType.localType)
    if userData.vipLevel <= 0 then
        local strImgPath = "Resources/newResources/Vip/touxiangkuang-hui.png"
        print("strImgPath"..strImgPath)
        self.imgAvatarBorder:loadTexture(strImgPath, 1)
        self.imgVipStateEnabled:setVisible(false)
        self.imgVipStateDisabled:setVisible(true)
        self.lableVipLevelEnabled:setVisible(false)
        self.lableVipLevelDisabled:setVisible(true)
        self.lableVipLevelDisabled:setString(-userData.vipLevel)
    else
        local strImgPath = "Resources/newResources/Vip/touxiangkuang-jin.png"
        print("strImgPath"..strImgPath)
        self.imgAvatarBorder:loadTexture(strImgPath, 1)
        self.imgVipStateEnabled:setVisible(true)
        self.imgVipStateDisabled:setVisible(false)
        self.lableVipLevelEnabled:setVisible(true)
        self.lableVipLevelEnabled:setString(userData.vipLevel)
        self.lableVipLevelDisabled:setVisible(false)
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
            self:setVisible(false)
            print("tag:"..widget:getTag())
            self.laySePsw:setVisible(false)
            self.currScene.laySecondPsw:setVisible(true)
        end
    end
    btnSePsw:addTouchEventListener(sePsw)
    btnsePsw1:addTouchEventListener(sePsw)
end

function VipLayer:setVisible(bShow)
    if bShow then
        self:fillDataToUI()
        app.popLayer.showEx(self.root)
    else
        app.hallScene:showHallUI()
    end
    self.laySePsw:setVisible(false)
    self.root:setVisible(bShow)
end

function VipLayer:listenEvent()
    self.currScene.eventProtocol:addEventListener("SC_VIP_PAY_P", function(event) --修改昵称、头像、性别
        print("会员支付")
        local ret = event.data.ret
        if ret == 0 then
            ToastLayer.show("操作成功！")
            self.laySePsw:setVisible(false)
        elseif ret == 1 then
            ToastLayer.show("游戏豆不足")
            self.laySePsw:setVisible(false)
        elseif ret == 2 then
            ToastLayer.show("风雷币不足")
            self.laySePsw:setVisible(false)
        elseif ret == 3 then
            ToastLayer.show("游戏中不能进行该操作")
            self.laySePsw:setVisible(false)
        elseif ret == 4 then
            ToastLayer.show("二级密码错误")
        else
            ToastLayer.show("未知错误")
        end
        self:fillDataToUI()
    end)
end

return VipLayer

