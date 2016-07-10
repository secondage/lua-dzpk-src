--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/11/25
-- Time: 15:53
-- To change this template use File | Settings | File Templates.
--

local AddChipLayer = class("AddChipLayer", function()
    return display.newLayer()
end)
function AddChipLayer:ctor()

end

function AddChipLayer:createAddChipLayer(path)
    path = path or "dzpk/res/LayerAddChip.csb"
    self.addChipLayer = cc.CSLoader:createNode(path)
    self.addChipLayer:setPosition(568, 320)
    self:init()
    return self.addChipLayer
end

function AddChipLayer:init()
    local roof = self.addChipLayer:getChildByName("Panel_roof"):show()
    roof:setPosition(-568, -320)
    local function onCloseEvt(obj, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            self:hideAddChip()
        end
    end
    roof:addTouchEventListener(onCloseEvt)

    local imgBK = self.addChipLayer:getChildByName("Image_bk")
    imgBK:setPosition(0, 0)
    local btnClose = imgBK:getChildByName("Button_close")
    btnClose:addTouchEventListener(function (obj, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            self:hideAddChip()
        end
    end)

    local textCurBeansNum = imgBK:getChildByName("Text_cur_beans_num")
    textCurBeansNum:setString(string.format("%d", i64_toInt(cc.dataMgr.lobbyUserData.lobbyUser.gameCurrency)))

    --dump(cc.dataMgr.tableBetInfoInRoom)
    self.fntAddChip = imgBK:getChildByName("BitmapFontLabel_rebring_num")

    self.sliderAdd = imgBK:getChildByName("Slider_rebring")

    self.textLeastBring = imgBK:getChildByName("Text_least_bring")

    self.textMostBring = imgBK:getChildByName("Text_most_bring")

    local checkAutoAdd = imgBK:getChildByName("CheckBox_auto_rebring")
    checkAutoAdd:setSelected(false)
    checkAutoAdd:addEventListener(function (obj, type)
        app.audioPlayer:playClickBtnEffect()
        if type == 1 then
            obj:setSelected(false)
            self.isAutoAddChip = false
        elseif type == 0 then
            obj:setSelected(true)
            self.isAutoAddChip = true
        end
    end)

    local btnOk = imgBK:getChildByName("Button_ok")
    btnOk:addTouchEventListener(function (obj, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            self:hideAddChip()
            self:sendAddChip(self.supplyGameCurrency, self.isAutoAddChip)
        end
    end)
end

function AddChipLayer:GetMinBringBet()
    return cc.dataMgr.bringLeastTimes * self.baseBet
end

function AddChipLayer:onSetBet(bet)
    self.baseBet = bet
end

function AddChipLayer:GetMaxBringBet()
    if self.baseBet >= 100000 then
        return cc.dataMgr.tenThousandBringMostTimes * self.baseBet
    end
    return cc.dataMgr.bringMostTimes * self.baseBet
end

function AddChipLayer:showAddChip()
    app.popLayer.show(self.addChipLayer)
    local betTmpleast = self:GetMinBringBet()
    local betTmpMost = self:GetMaxBringBet()
    if i64_toInt(cc.dataMgr.lobbyUserData.lobbyUser.gameCurrency) < self:GetMaxBringBet() then
        betTmpMost = i64_toInt(cc.dataMgr.lobbyUserData.lobbyUser.gameCurrency)
    end

    local imgBK = self.addChipLayer:getChildByName("Image_bk")
    local textCurBeansNum = imgBK:getChildByName("Text_cur_beans_num")
    textCurBeansNum:setString(string.format("%d", i64_toInt(cc.dataMgr.lobbyUserData.lobbyUser.gameCurrency)))

    self.textLeastBring:setString(string.format("最小买入：%d", betTmpleast))
    self.textMostBring:setString(string.format("最大买入：%d", betTmpMost))

    self.fntAddChip:setString(string.format("%d", betTmpleast))
    self.supplyGameCurrency = betTmpleast

    self.sliderAdd:setPercent(10)
    self.sliderAdd:addEventListener(function (obj, type)
        local realPercent = -1
        if obj:getPercent() < 10 then
            obj:setPercent(10)
            realPercent = 0
        elseif obj:getPercent() > 90 then
            obj:setPercent(90)
            realPercent = 1
        else
            realPercent = (obj:getPercent() - 10) / 80
            --print("realPercent = " .. realPercent)
        end
        if realPercent <= 100 and realPercent >= 0 then
            local curBet = betTmpleast + (betTmpMost - betTmpleast) * realPercent
            self.fntAddChip:setString(string.format("%d", curBet))
            self.supplyGameCurrency = curBet
        end
    end)
end

function AddChipLayer:hideAddChip()
    self.addChipLayer:hide()
end

function AddChipLayer:sendAddChip(supplyGameCurrency, bAutoBuy)
    local req = wnet.CG_SUPPLYGAMECURRENCY.new(cc.protocolNumber.CG_SUPPLYGAMECURRENCY_REQ_P, cc.dataMgr.lobbyLoginData.userID)
    cc.msgHandler.socketGame:send(req:bufferIn(supplyGameCurrency, bAutoBuy):getPack())
end

return AddChipLayer

