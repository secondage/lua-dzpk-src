--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/8/26
-- Time: 11:32
-- To change this template use File | Settings | File Templates.
--
local CoinAnim = require("hall.view.CoinDropAnim")
local ToastLayer = require("app.func.ToastLayer")
local MsgBox = app.msgBox

local SignInLyaer = class("SignInLayer")

function SignInLyaer:init(currScene, parentLayer)
    self.parentLayer = parentLayer
    self.currScene = currScene
    --大厅和福利中心用两套画布配置
    if parentLayer ~= nil then
        self.root = cc.CSLoader:createNode("Layers/BenefitSignInLayer.csb")
        parentLayer:addChild(self.root, 20)
    else
        self.root = cc.CSLoader:createNode("Layers/SignInLayer.csb")
        currScene:addChild(self.root, 20)
    end

    self:initWidgets()
    self:listenEvent()
    self:setVisible(false)
end

function SignInLyaer:listenEvent()
    print("init signIn layer event listener")

    if self.parentLayer == nil then
        self.currScene.eventProtocol:removeEventListenersByEvent("PL_PHONE_LC_INISIGNININFO_ACK_P")
        self.currScene.eventProtocol:addEventListener("PL_PHONE_LC_INISIGNININFO_ACK_P", function(event) --签到信息
            print("sign in data received, bSignIn:"..event.data.bSignIn)
            --新手指引期间禁用
            for key, value in pairs(cc.dataMgr.guiderFlag) do
                if value then
                    return
                end
            end
            self:setVisible(event.data.bSignIn == 0)
        end)
    end

    self.currScene.eventProtocol:addEventListener("PL_PHONE_LC_SIGNIN_ACK_P", function(event) --修改昵称、头像、性别
        if not self.root:isVisible() then
            return
        end
        local ret = event.data.signResult
        if ret == 0 then
            local signInData = cc.dataMgr.signInData
            local awardInfo = signInData.signInAwardInfo
            local index = signInData.signInDay + 1      --已经签到成功，天数加一
            if index > 5 then index = 5 end
            local awardData = awardInfo.awardInfo[index]
            local awardGameCurrency = awardData.awardGameCurrency
            local awardIngore = awardData.awardIngore
            local awardVipDays = awardData.awardVipDays
            local userData = cc.dataMgr.lobbyUserData.lobbyUser
            local bVip = not((userData.vipBegin == 0 and userData.vipExp) or userData.vipLevel < 0)
            if event.data.awardDouble > 0 then
                awardGameCurrency = awardGameCurrency + awardGameCurrency
            end
            local strAward
            if event.data.awardDouble > 0 then
                strAward = "您获得双倍签到奖励："
            else
                strAward = "恭喜您获得签到奖励："
            end
            local strVipEx = ""
            if bVip then
                strVipEx = strVipEx.."(含VIP奖励加成："
                local awardGameCurrencyEx = awardGameCurrency * (awardInfo.vipRate / 100)
                if awardGameCurrencyEx > 0 then
                    strVipEx = strVipEx..awardGameCurrencyEx.."游戏豆"
                end
                strVipEx = strVipEx..")"
                awardGameCurrency = awardGameCurrency + awardGameCurrencyEx
            end

            if awardGameCurrency > 0 then
                strAward = strAward..awardGameCurrency.."游戏豆"
            end
            if awardIngore > 0 then
                strAward = strAward..awardIngore.."元宝"
            end
            if awardVipDays > 0 then
                strAward = strAward..awardVipDays.."天会员"
            end

            strAward = strAward..strVipEx

            MsgBox.showMsgBox(strAward)
            self:startCoinsDropAnim()
        elseif ret == 1 then
            ToastLayer.show("签到失败")
        elseif ret == 2 then
            local function funcOk()
                self.currScene.layPhoneBind:setVisible(true)
            end
            MsgBox.showMsgBoxTwoBtn("您尚未绑定手机，无法签到。", funcOk, nil, "签到", "去绑定", "取消")
        end
    end)

    self.currScene.eventProtocol:addEventListener("SIGN_IN_UPDATE", function(event) --签到信息刷新
        if not self.root:isVisible() then
            return
        end
        self:fillDataToUI()
    end)
end

function SignInLyaer:initWidgets()
    local laySignIn = self.root:getChildByName("Panel_signIn")

    self.listSignIn = ccui.Helper:seekWidgetByName(laySignIn, "ListView_signIn")

    self.signItem = ccui.Helper:seekWidgetByName(laySignIn, "Image_signItem")
    self.signItem:setVisible(false)

    local btnClose = ccui.Helper:seekWidgetByName(laySignIn, "Button_close")
    btnClose:setPressedActionEnabled(true)
    btnClose:addTouchEventListener(function(widget, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            self:setVisible(false)
        end
    end)

    self.labelInfo = ccui.Helper:seekWidgetByName(laySignIn, "Text_information")

    local btnVip = ccui.Helper:seekWidgetByName(laySignIn, "Button_vip")
    if btnVip~= nil then
        btnVip:setPressedActionEnabled(true)
        btnVip:addTouchEventListener(function(widget, type)
            if type == 2 then
                app.audioPlayer:playClickBtnEffect()
                self.currScene.layBenefit:setVisible(false)
                self:setVisible(false)
                self.currScene.layVip:setVisible(true)
            end
        end)
    end

    self.btnSignIn = ccui.Helper:seekWidgetByName(laySignIn, "Button_signIn")
    self.btnSignIn:setPressedActionEnabled(true)
    self.btnSignIn:addTouchEventListener(function(widget, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            --[[
            local userInfoMore = cc.dataMgr.userInfoMore
            if userInfoMore == nil then return end
            if userInfoMore.phoneBindState == 0 then
                local function funcOk()
                    self.currScene.layPhoneBind:setVisible(true)
                end
                MsgBox.showMsgBoxTwoBtn("您尚未绑定手机，无法签到。", funcOk, nil, "签到", "去绑定", "取消")
                return
            end
            --]]

            app.signInLogic:reqSignIn()
        end
    end)
end

local function playShiningAnim(item)
    local anim = {}
    local frames = {}
    for i = 0, 8 do
        local strFile = string.format("Resources/signIn/singin_%02d.png", i)
        local spFrame = display.newSpriteFrame(strFile)
        frames[i] = spFrame
    end
    anim.action, anim.sp = display.newAnimation(frames, 0.1)
    local size = item:getContentSize()
    anim.sp:setPosition(size.width / 2, size.height / 2)
    item:addChild(anim.sp, 0)
    local delay = cc.DelayTime:create(1.5)
    anim.sp:playAnimationForeverEx(anim.action, delay)
end

function SignInLyaer:fillDataToUI()
    local signInData = cc.dataMgr.signInData
    if signInData == nil then return end

    local awardInfo = signInData.signInAwardInfo
    local strVip = self.labelInfo:getString()
    print("strVip"..strVip)
    if string.find(strVip, "%%d")~= nil then
        strVip = string.format(strVip, awardInfo.vipRate)
        self.labelInfo:setString(strVip)
    end

    local awardList = awardInfo.awardInfo
    print("signin size:"..#awardList)
    self.listSignIn:removeAllItems()
    self.btnSignIn:setEnabled(signInData.bSignIn == 0)
    self.btnSignIn:setBright(signInData.bSignIn == 0)
    for i = 1, #awardList do
        local item = self.signItem:clone()
        item:setVisible(true)

        local imgTitle = ccui.Helper:seekWidgetByName(item, "Image_title")
        local strPath = "Resources/signIn/day"..i..".png"
        local sp = cc.SpriteFrameCache:getInstance():getSpriteFrame(strPath)
        if sp ~= nil then
            imgTitle:loadTexture(strPath, 1)
        end

        local imgSigned = ccui.Helper:seekWidgetByName(item, "Image_signed")
        if i <= signInData.signInDay then
            if (i == #awardList and signInData.bSignIn == 0) then
                imgSigned:setVisible(false)
            else
                imgSigned:setVisible(true)
            end
        else
            imgSigned:setVisible(false)
            --[[
            local spIcon
            if i < 6 then
                spIcon = display.newSprite("#Resources/shop/gold-"..i..".png")
            else
                spIcon = display.newSprite("#Resources/shop/gold-6.png")
            end
            spIcon:setPosition(90, 117)
            item:addChild(spIcon, 1)
            --]]
        end
        local textAward = item:getChildByName("Text_award")
        local data = awardList[i]
        local awards = {}
        local strAward = ""
        if data.awardGameCurrency > 0 then
            strAward = strAward..data.awardGameCurrency.."游戏豆"
        end
        if data.awardIngore > 0 then
            awards[#awards + 1] = data.awardIngore.."元宝"
        end
        if data.awardVipDays > 0 then
            awards[#awards + 1] = data.awardVipDays.."天会员"
        end
        for i = 1, #awards do
            if i == 1 then
                strAward = strAward.."\n"..awards[i]
            else
                strAward = strAward.." "..awards[i]
            end
        end
        if #awards > 0 then
            textAward:setFontSize(18)
        else
            textAward:setFontSize(26)
        end
        textAward:setString(strAward)
        if signInData.bSignIn == 0 and
                (i == signInData.signInDay + 1 or (i == #awardList and signInData.signInDay >= #awardList)) then
            playShiningAnim(item)
        end

            --[[
            --if i == signInData.signInDay + 1 then playBorderAnim(item) end
            if signInData.bSignIn == 0 and
                    (i == signInData.signInDay + 1 or (i == #awardList and signInData.signInDay >= #awardList)) then
                --imgSign:setVisible(true)
                playScaleAnim(item)
                item:addTouchEventListener(function(widget, type)
                    if type == 2 then
                        app.audioPlayer:playClickBtnEffect()

                    end
                end)
            else
                item:addTouchEventListener(function(widget, type)
                    if type == 2 then
                        app.audioPlayer:playClickBtnEffect()
                        local data = awardList[i]
                        local strAward = ""
                        if data.awardGameCurrency > 0 then
                            strAward = strAward..data.awardGameCurrency.."游戏豆"
                        end
                        if data.awardIngore > 0 then
                            if strAward ~= "" then strAward = strAward.."+" end
                            strAward = strAward..data.awardIngore.."元宝"
                        end
                        if data.awardVipDays > 0 then
                            if strAward ~= "" then strAward = strAward.."+" end
                            strAward = strAward..data.awardVipDays.."天会员"
                        end

                        MsgBox.showMsgBox(strAward)
                    end
                end)
            end
            --]]
        self.listSignIn:insertCustomItem(item, i - 1)
    end
end

function SignInLyaer:setVisible(bShow)
    if bShow then
        self:fillDataToUI()
        --self:startCoinsDropAnim()
        if self.parentLayer == nil then
            app.popLayer.showEx(self.root:getChildByName("Panel_signIn"):getChildByName("Image_background"))
            app.hallScene.nPopLayers = app.hallScene.nPopLayers + 1
        end
    else
        if self.parentLayer == nil then
            app.hallScenenPopLayers = app.hallScene.nPopLayers - 1
        end
    end
    self.root:setVisible(bShow)
end

function SignInLyaer:startCoinsDropAnim()
    app.audioPlayer:playEffectByName("coin_drop")
    math.randomseed(os.time())
    for i = 1, 120 do
        local x = math.random(1, 1136)
        local anim = CoinAnim.new():init(x, 960, 40, 0.2, 300, 0.7)
        display:getRunningScene():addChild(anim, 500)
    end
end

return SignInLyaer

