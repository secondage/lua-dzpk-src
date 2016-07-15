--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/11/16
-- Time: 10:34
-- To change this template use File | Settings | File Templates.
--
local BringBetUI = class("BringBetUI", function()
    return display.newLayer()
end)
local scheduler = require("framework.scheduler")
function BringBetUI:ctor()
    self.currentBet = 0
    self.isAutoAddBet = false
    self.OpHandler = nil
end

function BringBetUI:createBringBetUI(pathRes)
    pathRes = pathRes or app.codeRes .. "LayerBringUserBet.csb"
    self.BringBetLayer = cc.CSLoader:createNode(pathRes)
    --if app.runningScene.tableBg == nil then return nil end
    --self.BringBetLayer:setPosition(app.runningScene.tableBg:getContentSize().width/2, app.runningScene.tableBg:getContentSize().height/2)
    self:init()
    return self.BringBetLayer
end

function BringBetUI:showBringBetUI()
    app.popLayer.show(self.BringBetLayer)
    self.OpHandler = scheduler.scheduleGlobal(handler(self, BringBetUI.OnTimerOp), 1)
    self.opTime = 15

    self.slider:setPercent(0)

    self.totalBeansNum = self.BringBetLayer:getChildByName("Panel_bring"):getChildByName("ProjectNode_bring"):getChildByName("Text_total_beans_num")
    self.totalBeansNum:setString(string.format("%d", i64_toInt(cc.dataMgr.lobbyUserData.lobbyUser.gameCurrency)))

    self.betNum:setString(string.format("%d", self.baseBet))
    local betTmpleast, betTmpMost = self:GetMinBringBet(), self:GetMaxBringBet()
    if i64_toInt(cc.dataMgr.lobbyUserData.lobbyUser.gameCurrency) < self:GetMaxBringBet() then
        betTmpMost = i64_toInt(cc.dataMgr.lobbyUserData.lobbyUser.gameCurrency)
    end
    self.bringBetNum:setString(string.format("%d", betTmpleast))
    self.currentBet = betTmpleast
    self.BringBetAtLeastNum:setString(string.format("%d", betTmpleast))
    self.BringBetAtMostNum:setString(string.format("%d", betTmpMost))
    self.slider:addEventListener(function (obj, type)
        if type == 0 then
            local value = obj:getPercent() / 100
            local curBet = betTmpleast + (betTmpMost - betTmpleast) * value
            self.bringBetNum:setString(string.format("%d", curBet))
            self.currentBet = curBet
        end
    end)
end

function BringBetUI:hideBringBetUI()
    self.BringBetLayer:hide()
    if self.OpHandler then scheduler.unscheduleGlobal(self.OpHandler) end
end

function BringBetUI:OnTimerOp()
    self.opTime = self.opTime - 1
    local btnCancel = self.BringBetLayer:getChildByName("Panel_bring"):getChildByName("ProjectNode_bring"):getChildByName("Button_cancel")

    btnCancel:getChildByName("BitmapFontLabel_cancel_num"):setString(string.format("%d", self.opTime))
    print("self.opTime = ".. self.opTime)
    if self.opTime <= 0 then
        if self.OpHandler then scheduler.unscheduleGlobal(self.OpHandler) end
        cc.lobbyController:sendLeaveTableReq()
        app.sceneSwitcher:enterScene("RoomScene")
        --app.exitGameSceneSkip()
    end
end

function BringBetUI:GetMinBringBet()
    return cc.dataMgr.bringLeastTimes * self.baseBet
end

function BringBetUI:onSetBet(bet)
    self.baseBet = bet
end

function BringBetUI:GetMaxBringBet()
    print("cc.dataMgr.tenThousandBringMostTimes=".. cc.dataMgr.tenThousandBringMostTimes.. ",cc.dataMgr.bringMostTimes=".. cc.dataMgr.bringMostTimes)
    if self.baseBet >= 100000 then
        return cc.dataMgr.tenThousandBringMostTimes * self.baseBet
    end
    return cc.dataMgr.bringMostTimes * self.baseBet

end

function BringBetUI:init()
    self.bringBetNum = self.BringBetLayer:getChildByName("Panel_bring"):getChildByName("ProjectNode_bring"):getChildByName("Image_bring_num_bk"):getChildByName("Text_bring_bet_num")

    self.slider = self.BringBetLayer:getChildByName("Panel_bring"):getChildByName("ProjectNode_bring"):getChildByName("Slider_bring_bet")
    self.slider:setPercent(0)

    self.betNum = self.BringBetLayer:getChildByName("Panel_bring"):getChildByName("ProjectNode_bring"):getChildByName("Text_bet")

    self.totalBeansNum = self.BringBetLayer:getChildByName("Panel_bring"):getChildByName("ProjectNode_bring"):getChildByName("Text_total_beans_num")
    self.totalBeansNum:setString(string.format("%d", i64_toInt(cc.dataMgr.lobbyUserData.lobbyUser.gameCurrency)))

    self.BringBetAtLeastNum = self.BringBetLayer:getChildByName("Panel_bring"):getChildByName("ProjectNode_bring"):getChildByName("Text_bring_beans_num_at_least")

    self.BringBetAtMostNum = self.BringBetLayer:getChildByName("Panel_bring"):getChildByName("ProjectNode_bring"):getChildByName("Text_bring_beans_num_at_most")

    local CheckAutoBring = self.BringBetLayer:getChildByName("Panel_bring"):getChildByName("ProjectNode_bring"):getChildByName("CheckBox_auto_bring")
    CheckAutoBring:setSelected(false)
    CheckAutoBring:addEventListener(function (obj, type)
        app.audioPlayer:playClickBtnEffect()
        if type == 1 then
            obj:setSelected(false)
            app.gameLayer.bAutoBringBet = false
            self.isAutoAddBet = false
        elseif type == 0 then
            obj:setSelected(true)
            app.gameLayer.bAutoBringBet = true
            self.isAutoAddBet = true
        end
    end)

    local btnCancel = self.BringBetLayer:getChildByName("Panel_bring"):getChildByName("ProjectNode_bring"):getChildByName("Button_cancel")
    btnCancel:addTouchEventListener(function (obj, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            if self.OpHandler then scheduler.unscheduleGlobal(self.OpHandler) end
            cc.lobbyController:sendLeaveTableReq()
            app.sceneSwitcher:enterScene("RoomScene")
            --app.exitGameSceneSkip()
        end
    end)

    local btnOk = self.BringBetLayer:getChildByName("Panel_bring"):getChildByName("ProjectNode_bring"):getChildByName("Button_ok")
    btnOk:addTouchEventListener(function (obj, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            self:hideBringBetUI()
            local req = wnet.CG_SETCURRENTTABLE_USERINFO.new(cc.protocolNumber.CG_SETCURRENTTABLE_USERINFO_REQ_P, cc.dataMgr.lobbyLoginData.userID)
            local bringGameCurrency = i64(self.currentBet)
            print("bringGameCurrency = ".. self.currentBet)
            cc.msgHandler.socketGame:send(req:bufferIn(bringGameCurrency, self.isAutoAddBet):getPack())
            print("send CG_SETCURRENTTABLE_USERINFO_REQ_P,(" .. self.currentBet .. ")")
        end
    end)

    local btnClose = self.BringBetLayer:getChildByName("Panel_bring"):getChildByName("ProjectNode_bring"):getChildByName("Button_close")
    btnClose:addTouchEventListener(function (obj, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            if self.OpHandler then scheduler.unscheduleGlobal(self.OpHandler) end
            cc.lobbyController:sendLeaveTableReq()
            app.sceneSwitcher:enterScene("RoomScene")
           -- app.exitGameSceneSkip()
        end
    end)
end

return BringBetUI