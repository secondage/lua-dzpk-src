require "data.protocolPublic"

local GameScene = class("GameScene", cc.load("mvc").ViewBase)
local scheduler = require("framework.scheduler")
GameScene.RESOURCE_FILENAME = "dzpk/res/MainScene.csb"
local GameSceneEvents = {}

GameScene.RESOURCE_BINDING = GameSceneEvents

local _attribute = require("dzpk.src.Attribute")
function app.seekChildByName(root,name)
    if root:getName()==name then
        return root
    else
        local child = root:getChildren()
        for i=1,#child do
            local tmp = app.seekChildByName(child[i],name)
            if tmp~=nil then
                return tmp
            end
        end
    end
    return nil
end

function GameScene:onCreate()
    print("---------GameScene:onCreate()")
    
    self.name = "GameScene"
    app.runningScene = self
    
    self.eventProtocol = require("framework.components.behavior.EventProtocol").new()
    cc.msgHandler:setPlayingScene(self)
    self:listenEvent()
    cc.dataMgr.tableUsers = {}
   -- self.tableUsers = {}
    self.tableUsersByChair = {}
    self.gameUsersUI = {}
    self.winFrame = {}
    self.loseFrame = {}
    self.isFirst = true
    self:initData()
    self.schedulerLevelTable = nil
    app.gameResNode = self:getResourceNode()
    self.tableBg = app.seekChildByName(app.gameResNode, "Image_back_ground")
    app.gamePublic = require(app.codeSrc .."GamePublic")
    app.gameViewController = require(app.codeSrc.. "GameViewController").new()
    self.gameLayer = self:createGameLayer():addTo(app.gameResNode, 10) --添加游戏层
    app.gameModel = require(app.codeSrc.. "GameModel").new()
    app.gameProtocol = require(app.codeSrc.. "GameProtocol").new()
    app.miniGameMsgHandler = require(app.codeSrc.. "MiniGameMsgHandler").new()

    cc.protocolNumber:registerMiniGameProNumber()

    self:procMainUI()
end

function GameScene:initData()
    app.codeSrc = cc.dataMgr.playingGame ..".src."
    app.codeRes = cc.dataMgr.playingGame .."/res/"

    self.isExiting = false
end

function GameScene:clearData()
    app.gameLayer = nil
    app.gameModel = nil
    app.gameViewController = nil
    app.gameProtocol = nil
    app.miniGameMsgHandler = nil
    app.gameResNode = nil
    app.gamePublic = nil
    app.codeSrc = nil
    cc.dataMgr.tableUsers = {}
end

function GameScene:createGameLayer()
    app.gameLayer = require(app.codeSrc .."GameLayer").new()
    return app.gameLayer
end

local function procGameUserUI(self)

    if app.isTest then
        cc.dataMgr.tablePlyNum = 9
    end
    print("cc.dataMgr.tablePlyNum = " ..cc.dataMgr.tablePlyNum)

    local pathRes = app.codeRes .. "NodeGameUser.csb"
    self.NodeUserInfo = cc.CSLoader:createNode(pathRes)
    self.NodeUserInfo:addTo(self.tableBg, 1)
    self.gameUsersUI[0] = self.NodeUserInfo:getChildByName("Panel_user")
    for i = 1, 8 do
        self.gameUsersUI[i] = self.gameUsersUI[0]:clone()
        self.gameUsersUI[i]:addTo(self.NodeUserInfo)
    end

    self.gameUserCurBetPos = {}

    for i = 0, 8 do
        self.gameUsersUI[i]:hide()

        local btnUser = self.gameUsersUI[i]:getChildByName("Image_normal_bg")
        btnUser:setTouchEnabled(true)
        btnUser:addTouchEventListener(function (obj, type)
            if type == 2 and not app.gameViewController.clickBtnLeave then
                app.gameLayer.userInfoLayer:setScale(0)
                app.gameLayer.userInfoLayer:show()
                local scaleTo = cc.ScaleTo:create(0.3, 1)
                local scaleTo_EaseOut = cc.EaseBackOut:create(scaleTo)
                app.gameLayer.userInfoLayer:updateUserInfoLayerByChair(i)
                local layRoof = app.seekChildByName(app.gameResNode, "Node_back_ground"):getChildByName("Panel_roof"):show()
                local callFun = cc.CallFunc:create(function ()
                    if app.gameLayer.userInfoLayer:isVisible() then
                        app.gameLayer.userInfoLayer:hide()
                        layRoof:hide()
                    end
                end)
                local actionDelay = cc.DelayTime:create(3)
                app.gameLayer.userInfoLayer:stopAllActions()
                app.gameLayer.userInfoLayer:runAction(cc.Sequence:create(scaleTo_EaseOut, actionDelay, callFun, nil))
            end
        end)

        self.gameUsersUI[i]:getChildByName("Panel_user_info"):hide()
        self.gameUsersUI[i]:getChildByName("Panel_user_info"):getChildByName("Image_status"):hide()
        self.gameUsersUI[i]:getChildByName("Button_sit_down"):hide()
        self.gameUsersUI[i]:getChildByName("Image_qi_pai"):hide()
        if i == 0 then
            app.gameLayer.spSelfGiveUp = self.gameUsersUI[i]:getChildByName("Image_qi_pai"):clone()
            app.gameLayer.spSelfGiveUp:addTo(app.gameLayer, 11)
            :setPosition(_attribute.gameUserPos[0].x, _attribute.gameUserPos[0].y)
        end

        self.winFrame[i] = self.gameUsersUI[i]:getChildByName("Image_win_score")
        self.winFrame[i]:retain()
        self.winFrame[i]:removeFromParent()
        self.winFrame[i]:addTo(app.gameLayer, 11)
        self.winFrame[i]:setPosition(_attribute.gameUserPos[i].x, _attribute.gameUserPos[i].y - 18)
        self.winFrame[i]:hide()
        self.loseFrame[i] = self.gameUsersUI[i]:getChildByName("Image_lose_score")
        self.loseFrame[i]:retain()
        self.loseFrame[i]:removeFromParent()
        self.loseFrame[i]:addTo(app.gameLayer, 11)
        self.loseFrame[i]:setPosition(_attribute.gameUserPos[i].x, _attribute.gameUserPos[i].y - 18)
        self.loseFrame[i]:hide()
        self.gameUsersUI[i]:setPosition(_attribute.gameUserPos[i].x, _attribute.gameUserPos[i].y)
        self.gameUsersUI[i]:getChildByName("Panel_user_info"):getChildByName("Image_jetton"):hide()
        if i == 2 or i == 3 then
            local bankerImg = self.gameUsersUI[i]:getChildByName("Panel_user_info"):getChildByName("Image_banker")
            local posX, posY = bankerImg:getPosition()
            bankerImg:setPosition(posX - 155, posY)
        end
        local jettonFrame = self.gameUsersUI[i]:getChildByName("Panel_user_info"):getChildByName("Image_weight_frame")
        local posX, posY = jettonFrame:getPosition()
        self.gameUserCurBetPos[i] = {}
        self.gameUserCurBetPos[i].x = _attribute.gameUserPos[i].x - 53.42
        self.gameUserCurBetPos[i].y = _attribute.gameUserPos[i].y + 98.535
        if i == 2 then
            jettonFrame:setPosition(posX - 130, posY - 100)
            self.gameUserCurBetPos[i].x = self.gameUserCurBetPos[i].x - 130
            self.gameUserCurBetPos[i].y = self.gameUserCurBetPos[i].y - 100
        elseif i == 3 then
            jettonFrame:setPosition(posX - 100, posY - 195)
            self.gameUserCurBetPos[i].x = self.gameUserCurBetPos[i].x - 100
            self.gameUserCurBetPos[i].y = self.gameUserCurBetPos[i].y - 195
        elseif i == 4 or i == 5 then
            jettonFrame:setPosition(posX, posY - 200)
            --local jettonImg = self.gameUsersUI[i]:getChildByName("Panel_user_info"):getChildByName("Image_jetton")
            --posX, posY = jettonImg:getPosition()
            --jettonImg:setPosition(posX, posY - 200)
            self.gameUserCurBetPos[i].y = self.gameUserCurBetPos[i].y - 200
        elseif i == 6 then
            jettonFrame:setPosition(posX + 100, posY - 195)
            self.gameUserCurBetPos[i].x = self.gameUserCurBetPos[i].x + 100
            self.gameUserCurBetPos[i].y = self.gameUserCurBetPos[i].y - 195
        elseif i == 7 then
            jettonFrame:setPosition(posX + 130, posY - 100)
            self.gameUserCurBetPos[i].x = self.gameUserCurBetPos[i].x + 130
            self.gameUserCurBetPos[i].y = self.gameUserCurBetPos[i].y - 100
        end


        app.gameViewController.showTalkFrame[i]:addTo(app.gameLayer,  12)

        app.gameViewController.showTalkFrame[i]:setPosition(_attribute.gameUserPos[i].x, _attribute.gameUserPos[i].y)

        if app.test then
            self.gameUsersUI[i]:show()
            self.gameUsersUI[i]:getChildByName("Panel_user_info"):show()
            self.gameUsersUI[i]:getChildByName("Panel_user_info"):getChildByName("Image_weight_frame"):show()
        end
    end

    app.gameViewController.operateNode:addTo(app.gameLayer, 11)

    -- 创建自己开牌动画
    app.gameLayer:createSelfOpenCardsAnimation()

    -- 创建其他人开牌动画
    app.gameLayer:createOtherOpenCardsAnimation()
end

function GameScene:procMainUI()
    --app.gameViewController:procUI()

    procGameUserUI(self)

    if app.isTest then
        app.gameLayer.bringBetLayer:showBringBetUI()
    end
end

local function localChairIDToUI(chairid)
    local _x = chairid - cc.dataMgr.selectedChairID
    local _c = 3 + _x
    if _c > 4 then
        return _c - 4
    elseif _c < 1 then
        return 4
    else
        return _c
    end
end

local function S2CChair(chairid)
    local diff = chairid - cc.dataMgr.selectedChairID
    local pos = -1
    if diff == 0 then  pos = 0
    elseif diff == 1 or diff == -8 then pos = 1
    elseif diff == 2 or diff == -7 then pos = 2
    elseif diff == 3 or diff == -6 then pos = 3
    elseif diff == 4 or diff == -5 then pos = 4
    elseif diff == 5 or diff == -4 then pos = 5
    elseif diff == 6 or diff == -3 then pos = 6
    elseif diff == 7 or diff == -2 then pos = 7
    elseif diff == 8 or diff == -1 then pos = 8 end
    return pos
end

local function _procBigNumber(num)
    --get
    if num <= 100000 then
        return tostring(num)
    elseif num <= 1000000 then
        local _b = num / 10000
        local s = string.format("%.2f万", _b)
        return s
    elseif num <= 100000000 then
        local _b = math.floor(num / 10000)
        return _b .. "万"
    else
        local _b = math.floor(num / 100000000)
        local s = string.format("%.2f亿", _b)
        return s
    end
end

local function getWinRate(win, lose, draw)
    if win == 0 then
        return "0%"
    elseif lose + draw == 0 then
        return "100%"
    else
        local rate = win / (win + lose + draw) * 100
        return string.format("%.2f", rate) .."%"
    end
end

function GameScene:onEnter_()
    print("---------GameScene:onEnter_()")
    self.gameLayer:onEnter()
    self:registerKey()
    self:initGameUI()

    if not app.isTest then
        if not cc.dataMgr.isBroken and not cc.dataMgr.isWatcher then
            --self:schedulerLevelTableFunc()
        end
    end
    ----[[
    if not app.test then
        print("cc.dataMgr.selectedTableID = ".. cc.dataMgr.selectedTableID)
        self.gameLayer.baseBet = cc.dataMgr.tableBetInfoInRoom[cc.dataMgr.selectedTableID + 1]
        if self.gameLayer.baseBet ~= nil then
            print("self.gameLayer.baseBet = ".. self.gameLayer.baseBet)
            require(app.codeSrc .."BringBetUI"):onSetBet(self.gameLayer.baseBet)
            -- 显示设置带入游戏豆界面
            if  not cc.dataMgr.isWatcher and self.gameLayer.baseBet ~= nil then
                require(app.codeSrc .."BringBetUI"):showBringBetUI()
            end
        end
    end

    --循环赛
    if cc.dataMgr.selectGameType == 8  then
        if cc.dataMgr.randMatch and cc.dataMgr.randMatch.matchInfo and cc.dataMgr.randMatch.matchInfo.matchType then
            self:initRandMatch(cc.dataMgr.randMatch.matchInfo.matchType)
        else
            self:initRandMatch(0)
        end
    end
    --]]
end

function GameScene:onEnterTransitionFinish_()
    print("---------GameScene:onEnterTransitionFinish_()")
    cc.sceneTransFini = true
    app.gameAudioPlayer = require(cc.dataMgr.playingGame ..".src.GameAudioPlayer")
    app.gameAudioPlayer.loadAllEffects()

    --[[if cc.dataMgr.isBroken then
        app.taskLayerCtrller.eventProtocol:dispatchEvent({ name = "GC_TASK_TASKINFOLIST_ACK_P"})
        app.taskLayerCtrller.eventProtocol:dispatchEvent({ name = "Evt_Update_GameTask", data = app.taskLogic.yuanbaoTaskId })
    end
    --]]
end

function GameScene:onExit_()
    print("---------GameScene:onExit_()")
    if self.schedulerLevelTable then
        scheduler.unscheduleGlobal(self.schedulerLevelTable)
        self.schedulerLevelTable = nil
    end

    if self.StartRoundHandler then
        scheduler.unscheduleGlobal(self.StartRoundHandler)
        self.StartRoundHandler = nil
    end

    app.gameViewController:removeAllScheduler()
    app.gameViewController.operateNode:release()
    app.gameViewController.ImgPaixing:release()
    self:clearData()
    self.eventProtocol:removeAllEventListeners()

    
    self.gameLayer:onExit()

    cc.dataMgr.isWatcher = false
    cc.dataMgr.isBroken = false
    cc.dataMgr.gamingState = false

    for i = 0, 8 do
        self.winFrame[i]:release()
        self.loseFrame[i]:release()
    end


end

function GameScene:listenEvent()
    self.eventProtocol:addEventListener("GC_TABLEUSERBRINGGAMECURRENCY_ACK_P", handler(self, GameScene.onGC_TABLEUSERBRINGGAMECURRENCY_ACK_P))
    self.eventProtocol:addEventListener("GC_DZ_STARTTIMER_P", handler(self, GameScene.onGC_DZ_STARTTIMER_P))
    self.eventProtocol:addEventListener("GC_GAME_START_P", handler(self, GameScene.onGC_GAME_START_P))
    self.eventProtocol:addEventListener("GC_HANDUP_P", handler(self, GameScene.onGC_HANDUP_P))
    self.eventProtocol:addEventListener("GC_ENTERTABLE_P", handler(self, GameScene.onGC_ENTERTABLE_P))
    self.eventProtocol:addEventListener("GC_LEAVETABLE_P", handler(self, GameScene.onGC_LEAVETABLE_P))
    self.eventProtocol:addEventListener("GC_STARTTIMER_P", handler(self, GameScene.onGC_STARTTIMER_P))
    self.eventProtocol:addEventListener("GC_TABLE_USERLIST_P", handler(self, GameScene.onGC_TABLE_USERLIST_P))
    self.eventProtocol:addEventListener("Evt_Update_User_Info", handler(self, GameScene.onUpdateUserInfo))
    self.eventProtocol:addEventListener("EvtUpdateUserPlayCurrency", handler(self, GameScene.onEvtUpdateUserPlayCurrency))
end

function GameScene:onGC_TABLEUSERBRINGGAMECURRENCY_ACK_P(event)
    print("GameScene:onGC_TABLEUSERBRINGGAMECURRENCY_ACK_P")
    local data = event.data
    --dump(data.tableUserBringGameCurrency)
    for i,v in pairs(data.tableUserBringGameCurrency) do
        local tableUser = nil
        table.foreach(cc.dataMgr.tableUsers, function (_i, _v)
            --print("_i = ".. _i.. ", v.userID = " .. v.userId)
            if _i == v.userId then
                tableUser = cc.dataMgr.tableUsers[_i]
                return
            end
        end)
        if tableUser ~= nil then
            tableUser.playCurrency = i64_toInt(v.bringGameCurrecny)
            --print("tableUser.playCurrency = ".. tableUser.playCurrency)
            self:updateUserPlayCurrencyUI(v.userId)
        end
    end
end

function GameScene:onGC_DZ_STARTTIMER_P(event)
    print"GameScene:onGC_DZ_STARTTIMER_P"
    local data = event.data
    if self.StartRoundHandler then scheduler.unscheduleGlobal(self.StartRoundHandler) self.StartRoundHandler = nil end
    if data.timerSec < 0 then
        app.gameLayer.waitingMs = -1
    else
        app.gameLayer.waitingMs = data.timerSec / 1000
    end
    print("onGC_DZ_STARTTIMER_P:app.gameLayer.waitingMs = ".. app.gameLayer.waitingMs)

    if app.gameLayer.waitingMs ~= -1 then
        app.gameLayer.waitingMs = app.gameLayer.waitingMs - 1
        self.StartRoundHandler = scheduler.scheduleGlobal(handler(self, GameScene.OnTimerStartRound), 1)
    end
end

function GameScene:OnTimerStartRound()
    app.gameLayer.waitingMs = app.gameLayer.waitingMs - 1
    if app.gameLayer.waitingMs > 0 and app.gameLayer.waitingMs <= 10 and not app.bGaming then
        app.gameViewController.waitUser:hide()
        app.gameViewController.waitStart:show()

        if not app.gameViewController.chipImg:isVisible() then
            app.gameViewController.chipImg:show()
            app.gameViewController.chipFrame:stopAllActions()
            app.gameViewController.chipFrame:playAnimationForever(display.getAnimationCache("chipAnimation"))
        end
    else
        app.gameViewController.waitStart:hide()
        app.gameViewController.chipImg:hide()
        app.gameViewController.chipFrame:hide()
        app.gameViewController.chipFrame:stopAllActions()
    end
    app.gameViewController.countDownStartRound:setString(string.format("%d", app.gameLayer.waitingMs))
    print("OnTimerStartRound:app.gameLayer.waitingMs = ".. app.gameLayer.waitingMs)
    if app.gameLayer.waitingMs <= 0 then
        if self.StartRoundHandler then scheduler.unscheduleGlobal(self.StartRoundHandler) self.StartRoundHandler = nil end
        app.gameViewController.waitStart:hide()
    end
end
function GameScene:onUpdateUserInfo(event) --更新游戏豆 积分
    --dump(event.data)
    local userdata = cc.dataMgr.tableUsers[event.data.userID]
    local chairID = userdata.gameData.chairID
    local _userlayer = self.gameUsersUI[S2CChair(chairID)]

    --[[local _money = _userlayer:getChildByName("Panel"):getChildByName("FontMoney")
    local gameCurrency = i64_toInt(userdata.userData.gameCurrency)
    if event.data.gameType == 0 then
        _money:setString(_procBigNumber(gameCurrency))
    else
        print("nScore = " ..userdata.gameData.nScore)
        _money:setString(userdata.gameData.nScore)
    end
    
    local imgUserInfoBg = _userlayer:getChildByName("Panel"):getChildByName("Image_userInfoBg")
    local fontBean = imgUserInfoBg:getChildByName("BitmapFontLabel_bean"):show()
     if event.data.gameType == 0 then
        fontBean:setString(gameCurrency)
    else
        fontBean:setString(userdata.gameData.nScore)
    end

     local textWinRate = imgUserInfoBg:getChildByName("Text_winRate"):show()
    textWinRate:setString(getWinRate(userdata.gameData.nWin, userdata.gameData.nLose, userdata.gameData.nDraw))]]
end

function GameScene:onEvtUpdateUserPlayCurrency(event)
    print("GameScene:onEvtUpdateUserPlayCurrency")
    local data = event.data
    if data.userID == cc.dataMgr.lobbyUserData.lobbyUser.userID and not cc.dataMgr.isWatcher then
        if cc.dataMgr.tableUsers[cc.dataMgr.lobbyUserData.lobbyUser.userID].playCurrency < app.gameLayer.baseBet then
            --[[if i64_toInt(cc.dataMgr.lobbyUserData.lobbyUser.gameCurrency) < app.gameLayer.baseBet then
                app.msgbox.showMsgBox("游戏豆不足，离开房间", function ()
                    cc.lobbyController:sendLeaveTableReq()
                    app.sceneSwitcher:enterScene("RoomScene")
                end)
            else
                app.gameLayer.bringBetLayer:showBringBetUI()
            end]]
        else
            --app.gameLayer.bringBetLayer:hideBringBetUI()
            self:updateUserPlayCurrencyUI(data.userID)
        end
    else
        self:updateUserPlayCurrencyUI(data.userID)
    end
end

function GameScene:updateUserPlayCurrencyUI(userID)
    local userdata = cc.dataMgr.tableUsers[userID]
    local chairID = userdata.gameData.chairID
    local _userlayer = self.gameUsersUI[S2CChair(chairID)]

    local bringBet = _userlayer:getChildByName("Panel_user_info"):getChildByName("BitmapFontLabel_cur_beans_num")
    local cur = cc.dataMgr.tableUsers[userID].playCurrency
    if cur == nil then cur = 0 end
    bringBet:setString(string.format("%d", cur))
    app.gameLayer.tablePlayer[S2CChair(chairID)].playCurrency = cur
end

function GameScene:onGC_GAME_START_P()
    print("game start")
    app.bGaming = true
    cc.dataMgr.isBroken = false

    app.gameLayer:onStartGame()
    app.gameViewController.waitStart:hide()
    app.gameViewController.chipImg:hide()
    app.gameViewController.chipFrame:hide()
    app.gameViewController.chipFrame:stopAllActions()
    app.gameAudioPlayer.playStartEffect()

    app.runningScene.resetGame()
    app.runningScene.initGameStateUI(3)
end

function GameScene:onGC_HANDUP_P(event)
   --[[app.holdOn.hide()
   local data = event.data
   local gameUser = self.gameUsersUI[S2CChair(data)]
   dump(self.gameUsersUI)
   local image = gameUser:getChildByName("Panel")
   :getChildByName("ImageReady"):show()
   if S2CChair(data) == 0 then
        if self.schedulerLevelTable then
            print("取消计时器onGC_HANDUP_P")
            scheduler.unscheduleGlobal(self.schedulerLevelTable)
            self.schedulerLevelTable = nil
        end
        
        if self.fontdown then
            self.fontdown:hide()
        end
        
        app.gameViewController.nodeTimer:show()
        self:getResourceNode():getChildByName("ButtonHandUp"):hide()
        
        app.gameViewController:removeBaoCard(0)

        app.gameViewController:updateShengYuNum()

        app.gameViewController:setBet(0)

        app.gameViewController:hideBankerIcon(0)
    end
    --]]
end

local iconv = require "iconv"
local encoding = iconv.new("utf-8", "GB18030") --多字节 -->utf8  接受服务器带中文字字段
local decoding = iconv.new("GB18030", "utf-8") --utf8 -->多字节 发送到服务器 带中文字字段

local function ClampText(spText, str, width)
    local ret = spText:getAutoRenderSize().width
    --print("spText:getAutoRenderSize().width = " .. spText:getAutoRenderSize().width)
    if ret > width then
        local i = string.len(str)
        repeat
            --local hz0 = string.byte(str, i)
            --i = i +1
            --print("--hz0 = ".. hz0)
            --[[if hz0 >= 0xA1 and hz0 <= 0xF7 then
                spText:setString(Mutiple2UTF8(string.sub(str, 1, i + 1)))
                i = i + 2
                --print("这是一个汉字")
            else
                spText:setString(Mutiple2UTF8(string.sub(str, 1, i)))
                i = i + 1
                --print("这是一个字符")
            end--]]

            local w = spText:getAutoRenderSize().width
            print("w..spText:getAutoRenderSize().width = " .. spText:getAutoRenderSize().width)
        until w < width --or i < 1
        --spText:setString(spText:getString() .. "..")
    end
end

local function cutOutname(Text,str,type)
    local upline= 10
    local size=0
    if type==1 then
        size=80
    elseif type==2 then
        size=100
    elseif type == 3 then
        size = 110
    end

    local nameSize=Text:setString(str):getAutoRenderSize().width
    local mutiplyContent=UTF82Mutiple(str)
    if nameSize<size then
        return str
    else
        local index=1
        local width=0
        while true do
            if width>=size then
                return Text:getString()
            end
            local hz0=string.byte(mutiplyContent,index)
            if hz0 >= 0xA1 and hz0 <= 0xF7 then
                index=index+2
                if index==upline then
                    local st=Mutiple2UTF8(string.sub(mutiplyContent,1,index-2))
                    Text:setString(st)
                    return Text:getString()
                end
                if index==upline-1 then
                    local st=Mutiple2UTF8(string.sub(mutiplyContent,1,index-1))
                    Text:setString(st)
                    return Text:getString()
                end
                local st=Mutiple2UTF8(string.sub(mutiplyContent,1,index))
                Text:setString(st)
            else
                index=index+1
                local st=Mutiple2UTF8(string.sub(mutiplyContent,1,index))
                Text:setString(st)
            end
            width=Text:getAutoRenderSize().width
        end
    end
end

function GameScene:updateUserInfo(v, flag) --flag 1 为进入桌子 0 为退出桌子·


    local _userlayer = self.gameUsersUI[S2CChair(v.gameData.chairID)]

    if flag == 0 then
        _userlayer:setVisible(false)
        return
    end
    _userlayer:setVisible(true)
    _userlayer:getChildByName("Panel_user_info"):show()

    local strNickName = v.userData.strNickName
   
    local _name = _userlayer:getChildByName("Panel_user_info"):getChildByName("Text_name")
    --print("strNickName = ".. encoding:iconv(strNickName))
    _name:setString(strNickName)
    --ClampText(_name, UTF82Mutiple(strNickName), 80)
    cutOutname(_name, strNickName, 1)

    local _img = _userlayer:getChildByName("Panel_user_info"):getChildByName("Image_head")
    _img:show()
    local _icon = v.userData.icon
    if _icon > 10 then
        _icon = 0
    end
    local fn = "avatar/" .. _icon .. ".jpg"
    _img:loadTexture(fn)

    self:updateUserPlayCurrencyUI(v.userData.userID)

    _userlayer:getChildByName("Panel_user_info"):getChildByName("Image_weight_frame"):hide()
    _userlayer:getChildByName("Panel_user_info"):getChildByName("Image_banker"):hide()


end

function GameScene:onGC_ENTERTABLE_P(event)

    local userInfo = event.data.gameUser
   -- dump(event.data)
    ----[[
    if cc.dataMgr.selectedTableID == userInfo.gameData.tableID then --屏蔽其他桌子的
        print(S2CChair(userInfo.gameData.chairID) .."号进桌")

        cc.dataMgr.tableUsers[userInfo.userData.userID] = userInfo

        self:updateUserInfo(userInfo, 1)
        self.tableUsersByChair[S2CChair(userInfo.gameData.chairID)] = userInfo
    end
    --]]
    print("ENTERTABLE:cc.dataMgr.selectedChairID = " .. cc.dataMgr.selectedChairID)
    self:showWaitUsersImg()

    if not app.test then
        if self.gameLayer.baseBet == nil then
            dump(cc.dataMgr.tableBetInfoInRoom)
            print("cc.dataMgr.selectedTableID = ".. cc.dataMgr.selectedTableID)
            self.gameLayer.baseBet = cc.dataMgr.tableBetInfoInRoom[cc.dataMgr.selectedTableID + 1]
            if self.gameLayer.baseBet ~= nil then
                print("self.gameLayer.baseBet = ".. self.gameLayer.baseBet)
                require(app.codeSrc .."BringBetUI"):onSetBet(self.gameLayer.baseBet)
                -- 显示设置带入游戏豆界面
                if  not cc.dataMgr.isWatcher and self.gameLayer.baseBet ~= nil then
                    require(app.codeSrc .."BringBetUI"):showBringBetUI()
                end
            end
        end
    end
end

function GameScene:onGC_LEAVETABLE_P(event)
    --already exist in userlist?
   -- print"GameScene:onGC_LEAVETABLE_P"
    --dump(event.data)
    local userInfo = cc.dataMgr.tableUsers[event.data.userID] --离桌的可能不是自己所在的桌子
    --dump(cc.dataMgr.tableUsers)
    if userInfo then
        print(S2CChair(userInfo.gameData.chairID) .."号离桌")
        self:updateUserInfo(userInfo, 0)
        cc.dataMgr.tableUsers[event.data.userID] = nil
        self.tableUsersByChair[S2CChair(userInfo.gameData.chairID)] = nil

        local chair = S2CChair(userInfo.gameData.chairID)
        print("LEAVETABLE:cc.dataMgr.selectedChairID = " .. cc.dataMgr.selectedChairID)
        if event.data.userID == cc.dataMgr.lobbyUserData.lobbyUser.userID then
            if self.resultAgain then
                self.resultAgain = nil
                return
            end
           -- app.exitGameSceneSkip()
            app.sceneSwitcher:enterScene("RoomScene") 
        end


        if app.gameViewController.EndTypeImg[chair] ~= nil then
            app.gameViewController.EndTypeImg[chair]:removeSelf()
            app.gameViewController.EndTypeImg[chair] = nil
        end

        -- 清除结算分数
        self.winFrame[chair]:hide()
        self.loseFrame[chair]:hide()

        app.gameLayer.cardsLayer:removeHandCards(chair)

        self:showWaitUsersImg()

        -- 隐藏赢牌动画
        -- 隐藏个人特效
        app.gameLayer.userBalanceFrame[chair].frame1:stopAllActions()
        :hide()
        app.gameLayer.userBalanceFrame[chair].frame2:stopAllActions()
        :hide()

        --dump(app.gameLayer.ChairIdInGaming)
        local count = table.nums(app.gameLayer.ChairIdInGaming)
        for i = 0, count - 1 do
            if app.gameLayer.ChairIdInGaming[i] == chair then
                for j = i, count - 2 do
                    app.gameLayer.ChairIdInGaming[j] = app.gameLayer.ChairIdInGaming[j + 1]
                end
                app.gameLayer.ChairIdInGaming[count - 1] = nil
                break
            end
        end
       --dump(app.gameLayer.ChairIdInGaming)
    end
end

function GameScene:showWaitUsersImg()
    local bSelf = false
    for k, v in pairs(self.tableUsersByChair) do
       if k == 0 then
           bSelf = true
       end
    end

    if table.nums(self.tableUsersByChair) == 1 and bSelf then
        print"sdsdsdsdsdsdsdsds"
        if self.StartRoundHandler then scheduler.unscheduleGlobal(self.StartRoundHandler) self.StartRoundHandler = nil end
        app.gameViewController.waitUser:show()
        app.gameViewController.waitStart:hide()
        app.gameViewController.chipImg:show()
        app.gameViewController.chipFrame:stopAllActions()
        app.gameViewController.chipFrame:playAnimationForever(display.getAnimationCache("chipAnimation"))
    end
end

function GameScene:onGC_TABLE_USERLIST_P(event)
    print("onGC_TABLE_USERLIST_P")
    table.foreach(event.data.userList, function(i, userInfo)
        --6 为旁观 不加入列表
        --dump(userInfo)
        print("userInfo.gameData.chairID=".. userInfo.gameData.chairID.. ",cc.dataMgr.selectedChairID=" .. cc.dataMgr.selectedChairID)
        if userInfo.gameData.userStatus ~= 6 --[[and userInfo.gameData.chairID ~= cc.dataMgr.selectedChairID]] then --自己在onGC_ENTERTABLE_P处理
            print(S2CChair(userInfo.gameData.chairID) .."号椅子")
            cc.dataMgr.tableUsers[userInfo.userData.userID] = userInfo
            self:updateUserInfo(userInfo, 1)
            self.tableUsersByChair[S2CChair(userInfo.gameData.chairID)] = userInfo
         end
    end)
    self:showWaitUsersImg()
end

function GameScene:schedulerLevelTableFunc()

    --local _userlayer = self.gameUsersUI[0]
    --local fontdown = _userlayer:getChildByName("Panel"):getChildByName("ImageAvatarBG"):getChildByName("FontCount")
    --self.fontdown = fontdown
    --fontdown:setVisible(true)
    --fontdown:setString("20")
    
    local dcount = 20
    
    print("打开计时器")
    self.schedulerLevelTable = scheduler.scheduleGlobal(function()
        --fontdown:setString(dcount)
        if dcount < 0 then
          

           if self.schedulerLevelTable then
               scheduler.unscheduleGlobal(self.schedulerLevelTable)
               self.schedulerLevelTable = nil
           end
          -- app.exitGameSceneSkip()

           cc.lobbyController:sendLeaveTableReq()
           app.sceneSwitcher:enterScene("RoomScene")
        end
        
        dcount = dcount - 1
    end, 1)
end

function GameScene:onGC_STARTTIMER_P(event)
    --print("start time ")

    --[[local v = cc.dataMgr.userTable[cc.dataMgr.gameData.userID]
    if v == nil then return end
    print("onGC_STARTTIMER_P ", v.gameData.userStatus)

    if v ~= nil and v.gameData.userStatus == wnet.EUserStatus.EGAME_STATUS_READY then
        --已经举手
        return
    end
    print("start time "..event.data.timeEvent.." "..event.data.timeSec)]]

end

function GameScene:GetCardPos(chair, index)
    local posX, posY
    local offset = {}
    offset.x = index * _attribute.CardsInterval.x
    offset.y = index * _attribute.CardsInterval.y

    local userPosX, userPosY = self.gameUsersUI[chair]:getPosition()
    posX = userPosX - _attribute.CardsInterval.x / 2 + offset.x + 1
    posY = userPosY + offset.y - 2
    return posX, posY
end

function GameScene:registerKey()
    local keyListener = cc.EventListenerKeyboard:create()
    local function onKeyRelease(code, event)
        print("EVENT_KEYBOARD_PRESSED, code:"..code)
        if code == cc.KeyCode.KEY_BACK or code == cc.KeyCode.KEY_BACKSPACE then
            app.audioPlayer:playClickBtnEffect()
            if app.bGaming == true and not cc.dataMgr.isWatcher and app.gameLayer.isSelfInGaming then
                app.toast.show("很抱歉,游戏中不能退出")
            else
                if not self.isExiting then
                    app.holdOn.show("请稍后...")
                    self.isExiting = true
                    cc.lobbyController:sendLeaveTableReq()
                    --app.exitGameSceneSkip()
                    app.sceneSwitcher:enterScene("RoomScene") --leave table处理
                end
            end
        end
    end
    keyListener:registerScriptHandler(onKeyRelease, cc.Handler.EVENT_KEYBOARD_RELEASED)
    local eventDispatch = self:getEventDispatcher()
    eventDispatch:addEventListenerWithSceneGraphPriority(keyListener, self)
end

-------------- 加入循环赛部分 -------
--- 处理循环赛场消息
function GameScene:onGC_NOCHEAT_MATCH_INFO_ACK_P(event)
    if (cc.dataMgr.randMatch.matchInfo.matchType==1) or (cc.dataMgr.randMatch.matchInfo.matchType==2) then
        self:initRandMatch(cc.dataMgr.randMatch.matchInfo.matchType)
        --app.randMatch.randMatchUI:setAwardTime(cc.dataMgr.randMatch.matchInfo.awardTimeSpan)
    end
end

--- 初始化循环赛
function GameScene:initRandMatch(mtype)
    self.exitGameSceneBtn = app.seekChildByName(app.runningScene,"ButtonBack")
    cc.dataMgr.withoutRoomScene = true
    cc.dataMgr.useRandMatch = true
    if self.schedulerLevelTableHander~=nil then
        scheduler.unscheduleGlobal(self.schedulerLevelTableHander)
        self.schedulerLevelTableHander = nil
    end

    if app.randMatch==nil or app.randMatch.rootLyr~=app.runningScene:getResourceNode() then
        app.randMatch = require("match/src/RoundMatch").new()
        app.randMatch:init(app.runningScene:getResourceNode(),self.eventProtocol)
        app.randMatch:initRoundMatchUI(mtype)
    end

    if mtype and cc.dataMgr.randMatch and cc.dataMgr.randMatch.matchInfo then
        local info = cc.dataMgr.randMatch.matchInfo
        if info.matchType then
            app.randMatch:setMatchType(info.matchType)
            app.randMatch:setMatchStartState()
        end
        if info.matchType==1 and info.awardTimeSpan and (i64_toInt(info.endTime)>=i64_toInt(info.srvTime) and i64_toInt(info.startTime)<=i64_toInt(info.srvTime)) then
            app.randMatch.randMatchUI:setAwardTime(info.awardTimeSpan)
        else
            app.randMatch.randMatchUI:setAwardTime(0)
        end
    end

    app.runningScene.initGameUI()
    if mtype==0 or mtype==1 or mtype==2 then
        if app.gameModel.isGaming and app.gameModel.isGaming == true then
            app.runningScene.initGameStateUI(3)
        else
            app.runningScene.initGameStateUI(1)
        end
    end
end


------------ 此处修改各自游戏对应状态UI起 ----------
---根据游戏状态初始化和循环赛相关的其他资源 0:无；-1：等待；-2：准备；3：游戏开始；4：结算
function GameScene.initGameStateUI(state,root)
    --[[root = root or app.runningScene
    local handUpBtn = app.seekChildByName(root,"Button_ready"):setVisible(true)
    local change = app.seekChildByName(root,"Button_change_table")
    local leave = app.seekChildByName(root,"Button_leave_table")
    if cc.dataMgr.selectGameType==7 or cc.dataMgr.selectGameType==8 then
        handUpBtn:setVisible(false)
        change:setVisible(false)
        leave:setVisible(false)
    end
    --]]

    if cc.dataMgr.selectGameType == 7 then
        --[[if state >= 3 then
            app.seekChildByName(root,"ButtonBack"):setVisible(false)
        end
        if state == 4 then
            app.seekChildByName(root,"Button_btnBackToRoom"):setVisible(false)
            app.seekChildByName(root,"Button_btnAgain"):setVisible(false)
            if app.runningScene.schedulerLevelTableHander~= nil then
                scheduler.unscheduleGlobal(app.runningScene.schedulerLevelTableHander)
            end
        end--]]
        app.challenge:setChallengeState(state,{root = app.runningScene,eventProtocol = app.runningScene.eventProtocol})
    elseif cc.dataMgr.selectGameType == 8 then
        app.randMatch:setGameState(state)
        --[[if state == 4 then
            handUpBtn:setVisible(true):setLocalZOrder(10)
        end--]]
    elseif cc.dataMgr.selectGameType == 10 then
        --[[ app.seekChildByName(root,"Button_btnBackToRoom"):setVisible(false)
        app.seekChildByName(root,"Button_btnAgain"):setVisible(false)
               if state == 4 then
                    change:setVisible(true)
                    agin:setVisible(true)
                end]]
        return
    else
        return
    end

    --[[app.seekChildByName(root,"FontCount"):setVisible(false)
    local bGame = false
    if state<=2 then
        bGame = false
    elseif state>2 then
        bGame = true
    end
    if cc.dataMgr.randMatch and cc.dataMgr.randMatch.matchInfo and cc.dataMgr.randMatch.matchInfo.matchType == 2 then
        app.seekChildByName(root,"Node_set"):setVisible(bGame)
        --app.seekChildByName(root,"Node_task"):setVisible(bGame)
    end
    app.seekChildByName(root,"Node_timer"):setVisible(bGame)
    app.seekChildByName(root,"Sprite_baoCardbg"):setVisible(bGame)
    local userNode = app.seekChildByName(root,"Node_gameUser"):setVisible(bGame)
    for i=0,3 do
        app.seekChildByName(userNode,"GameUser"..i):setVisible(true)
    end
    --]]
end


--- 结算界面返回gameScene准备界面的重置UI函数
function GameScene.resetGame()
    app.gameLayer:restartGame()

   --[[ local againBtn = app.seekChildByName(root,"Button_btnAgain")
    if againBtn ~= nil then
        app.seekChildByName(app.runningScene,"ButtonHandUp"):hide()
        app.gameLayer.cardsLayer:removeAllCards()
        app.gameLayer.cardsTouchLayer:show()
        app.seekChildByName(root,"Node_winTiles"):removeAllChildren()
        app.gameLayer.resultLayer:removeFromParent()
        cancelBlurBg(root)
        local gmScene = app.runningScene
        cc.lobbyController:sendLeaveTableReq()
        gmScene.resultAgain = true
        if gmScene.schedulerLevelTableHander ~= nil then
            scheduler.unscheduleGlobal(gmScene.schedulerLevelTableHander)
            gmScene.schedulerLevelTableHander = nil
        end
    end

    local op = {isPass = false,isChow = false,isPong=false,isKong=false,isTing=false,isHu=false}
    app.gameLayer.specialEffectLayer:showCurOpBtns(op)
    if app.gameLayer.specialEffectLayer.schedulerHandler_HideOpBtns~=nil then
        scheduler.unscheduleGlobal(app.gameLayer.specialEffectLayer.schedulerHandler_HideOpBtns)
        app.gameLayer.specialEffectLayer.schedulerHandler_HideOpBtns = nil
    end
    app.gameLayer.cardsLayer:removeAllCards()
    app.gameLayer.cardsTouchLayer:show()
    --]]
end

--- 修改各种游戏模式 UI，区别于 initGameStateUI 只调用一次
function GameScene.initGameUI(mtype)
    local root = app.runningScene
    if cc.dataMgr.selectGameType == 8 then
        --[[app.seekChildByName(root,"ButtonHandUp"):addTouchEventListener(function(obj,type)
            if type == 2 then
                app.audioPlayer:playClickBtnEffect()
                if app.randMatch.gameState == 4 then
                    cc.lobbyController:sendLeaveTableReq()
                    root.resultAgain = true
                    app.runningScene.resetGame()
                    app.runningScene.initGameStateUI(1)
                end
                app.randMatch.randMatchlogic:sendJoinGameReq()
            end
        end)
        --]]
        --[[        app.seekChildByName(root,"Button_change_table"):addTouchEventListener(function(obj,type)
                    if type == 2 then
                        app.audioPlayer:playClickBtnEffect()
                        root.initFastRoom()
                    end
                end)
                app.seekChildByName(root,"Button_continue"):addTouchEventListener(function(obj,type)
                    if type == 2 then
                        app.audioPlayer:playClickBtnEffect()
                        app.runningScene.resetGame()
                        --app.toast.show("正在匹配桌子...")

                        root.eventProtocol:addEventListener("GC_ENTERTABLE_ACK_P", function()
                            cc.lobbyController:sendHandUpReq()
                        end)
                        cc.lobbyController:sendFastJoinReq()
                    end
                end)]]
        --- 添加空位置点击邀请功能
    elseif app.funcPublic.isWrapGame() then
        for i=1,cc.dataMgr.tablePlyNum do
            local avatar = app.seekChildByName(app.seekChildByName(app.runningScene,"GameUser"..(i-1)),"ImageAvatarBG")
            avatar:setTouchEnabled(true):addTouchEventListener(function(obj, type)
                if type == 2 then
                    if app.runningScene.tableUsersByChair[i-1] == nil then
                        app.audioPlayer:playClickBtnEffect()
                        app.inviteFriend:show(true)
                        return
                    end
                end
            end)
        end

    end

end
------------ 此处修改各自游戏对应状态UI止 ----------

--- 延迟退桌子  app.funcPublic.isWrapGame
function GameScene:delayExitTable(text)
    if self.delayExitScheduler~=nil then
        scheduler.unscheduleGlobal(self.delayExitScheduler)
        self.delayExitScheduler = nil
    end
    self.delayExitScheduler = scheduler.performWithDelayGlobal(function()
       -- app.exitGameSceneSkip()
        app.sceneSwitcher:enterScene("RoomScene")
    end,3)

    if text ~= nil then
        app.msgBox.showMsgBox(text,function()
            if self.delayExitScheduler~=nil then
                scheduler.unscheduleGlobal(self.delayExitScheduler)
                self.delayExitScheduler = nil
                app.sceneSwitcher:enterScene("RoomScene")
                --app.exitGameSceneSkip()
            end
        end,"","",true)
    end
end


return GameScene
