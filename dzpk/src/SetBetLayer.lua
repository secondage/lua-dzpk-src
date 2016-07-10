--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/11/24
-- Time: 19:22
-- To change this template use File | Settings | File Templates.
--

local SetBetLayer = class("SetBetLayer")
local scheduler = require("framework.scheduler")
function SetBetLayer:ctor()
    self.tableID = 0
    self.chairID = 0
end

function SetBetLayer:createSetBetLayer(spParent, path)
    path = path or "setBetDZPK/SetBetLayer.csb"
    self.setBetLayer = cc.CSLoader:createNode(path)
    self.setBetLayer:addTo(spParent, 11):hide()
    self:init()
    return self.setBetLayer
end

function SetBetLayer:init()
    local roof = self.setBetLayer:getChildByName("Panel_roof"):show()
    roof:addTouchEventListener(function(obj, type)
        if type == 2 then
            self:hideSetBetUI()
        end
    end)
    local setBetNode = self.setBetLayer:getChildByName("ProjectNode_setBet")
    local imgBK = setBetNode:getChildByName("Image_bg")

    local function onBtnPress(betNum)
        app.audioPlayer:playClickBtnEffect()
        if self.OpHandler then scheduler.unscheduleGlobal(self.OpHandler) end
       app.castMultipleSetLogic:sendCastSetReq(betNum, 0)
    end

    local btn10 = imgBK:getChildByName("Button_10")
    btn10:addTouchEventListener(function (obj, type)
        if type == 2 then
            onBtnPress(10)
        end
    end)

    local btn100 = imgBK:getChildByName("Button_100")
    btn100:addTouchEventListener(function (obj, type)
        if type == 2 then
            onBtnPress(100)
        end
    end)

    local btn1000 = imgBK:getChildByName("Button_1000")
    btn1000:addTouchEventListener(function (obj, type)
        if type == 2 then
            onBtnPress(1000)
        end
    end)

    local btn1W = imgBK:getChildByName("Button_1W")
    btn1W:addTouchEventListener(function (obj, type)
        if type == 2 then
            onBtnPress(10000)
        end
    end)

    local btn10W = imgBK:getChildByName("Button_10W")
    btn10W:addTouchEventListener(function (obj, type)
        if type == 2 then
            onBtnPress(100000)
        end
    end)

    local btnClose = imgBK:getChildByName("Button_close")
    btnClose:addTouchEventListener(function (obj, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            self:hideSetBetUI()
        end
    end)
end

function SetBetLayer:OnTimerOp()
    self.opTime = self.opTime - 1
    local coutdown = self.setBetLayer:getChildByName("ProjectNode_setBet"):getChildByName("Image_bg"):getChildByName("Text_cout_down_content")
    coutdown:setString(string.format("(%02ds)", self.opTime))
    print("self.opTime = ".. self.opTime)
    if self.opTime <= 0 then
        if self.OpHandler then scheduler.unscheduleGlobal(self.OpHandler) end
        self.setBetLayer:hide()
    end
end

local function setBtnEnable(btn, bshow)
    if btn ~= nil then
        btn:setTouchEnabled(bshow)
        btn:setBright(bshow)
    end
end

function SetBetLayer:showSetBetUI()
    self.setBetLayer:show()
    self.OpHandler = scheduler.scheduleGlobal(handler(self, SetBetLayer.OnTimerOp), 1)
    self.opTime = 15

    local setBetNode = self.setBetLayer:getChildByName("ProjectNode_setBet")
    local imgBK = setBetNode:getChildByName("Image_bg")

    local btn = {}
    btn[10] = imgBK:getChildByName("Button_10")
    btn[100] = imgBK:getChildByName("Button_100")
    btn[1000] = imgBK:getChildByName("Button_1000")
    btn[10000] = imgBK:getChildByName("Button_1W")
    btn[100000] = imgBK:getChildByName("Button_10W")

    for k, v in pairs(btn) do
        if cc.dataMgr.castMultSet.beiShuInfo.betInfo[k] then
            setBtnEnable(v, true)
        else
            setBtnEnable(v, false)
        end
    end

    for k, v in pairs(cc.dataMgr.castMultSet.beiShuInfo.betInfo) do
        if i64_toInt(cc.dataMgr.lobbyUserData.lobbyUser.gameCurrency) < v then
            setBtnEnable(btn[k], false)
        end
    end
end

function SetBetLayer:hideSetBetUI()
    self.setBetLayer:hide()
    if self.OpHandler then scheduler.unscheduleGlobal(self.OpHandler) end
end

function SetBetLayer:isVisible()
    return self.setBetLayer:isVisible()
end

function SetBetLayer:setSeatInfo(tableID, chairID)
    self.tableID = tableID
    self.chairID = chairID
end

function SetBetLayer:sendEnterSeat()
    cc.dataMgr.tableBetInfoInRoom[self.tableID + 1] = cc.dataMgr.castMultSet.beiShuInfo.nBet
    cc.showLoading("正在加入桌子")
    cc.lobbyController:sendLoginTableReq(self.tableID, self.chairID)
end
return SetBetLayer