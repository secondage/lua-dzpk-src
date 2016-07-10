require "data.protocolPublic"

local socketTCP = require "framework.net.SocketTCP"
local scheduler = require("framework.scheduler")
local packBody = require "data.packBody"
local ByteArray = require "framework.utils.ByteArray"
local targetPlatform = cc.Application:getInstance():getTargetPlatform()

require "loading"

local MsgHandler = class("MsgHandler")
function MsgHandler:ctor()
    self.playingScene = nil
    self.name = "msgHandler"

    self.socketLogin = nil
   -- self.socketLogin = socketTCP.new(clientConfig.serverAddress, clientConfig.serverPort, clientConfig.retryConnectWhenFailure)
    --self.socketLogin = socketTCP.new("125.32.114.18", 26661, true)
    --self.socketLogin = socketTCP.new("125.32.113.107", 26761, true)
    --self.socketLogin = socketTCP.new("192.168.1.100", 9310, false)
    --self.socketLogin = socketTCP.new("192.168.1.43", 6310, false)
    --self.socketLogin = socketTCP.new("127.0.0.1", 9090, false)
    self.socketLobby = nil
    self.socketGame = nil
    self.heartBeatCheckBuffer = wnet.heartBeatCheck.new(cc.protocolNumber.CS_HEARTBEAT_CHECK_P):bufferIn()
    self.buffer = nil
    self.pack = nil
    self.dataQueue = {}
    self.shareMsgObj = {}       --需实现:procMsgs(_socket, buffer, pack.opCode) 接口，消息接收器集合

    self.socetLoginConnected = false
end

function MsgHandler:onExit_()
    print("msgHandler exit..")
end

function MsgHandler:stopReceiveMsg()
    scheduler.unscheduleGlobal(self.tickScheduler)
end

function MsgHandler:connect(stage)
    local _socket = nil
    if stage == "login" then
        _socket = self.socketLogin
    elseif stage == "lobby" then
        _socket = self.socketLobby
    elseif stage == "game" then
        _socket = self.socketGame
    end
    assert(_socket, "invalid socket instence")
    local function onStatus(__event)
        -- print(string.format("socket status: %s", __event.name))
    end

    local function onConnected(__event)
        print("connected, stage:"..stage)
       -- cc.hideLoading()
        if stage == "login" then
            self.socetLoginConnected = true
            self.playingScene.eventProtocol:dispatchEvent({ name = "LOGIN_SRV_CONNECTED" })
        end
        if stage == "lobby" then
            self.socetLoginConnected = false
            display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "LOBBY_SRV_CONNECTED" })
        end
        if stage == "game" then
            display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "GAME_SRV_CONNECTED" })
        end
    end

    local function onClose(__event)
        print("connect close.")
        print(string.format("socket status: %s", __event.name))

    end

    local function onClosed(__event)
        print("connect closed.")
        print(string.format("socket status: %s", __event.name))


        if __event.socket == self.socketGame then
            if app.runningScene.name == "RoomScene" or app.runningScene.name == "GameScene" then
                local function clickOK()
                    cc.dataMgr.isChangeAccLogin = true
                    cc.dataMgr.isRoomBackToHall = true
                    self:disconnectFromGame()
                    app.sceneSwitcher:enterScene("LoginScene")
                end
                if not cc.dataMgr.isRoomBackToHall and not cc.dataMgr.bHallShowChannel then
                    app.holdOn.hide()
                    app.msgBox.showMsgBoxEx({strMsg = "连接已断开!", funcOk = clickOK, isHideX = true})
                end
            end
        elseif __event.socket == self.socketLobby then
            if not cc.dataMgr.isChangeAccLogin and not cc.dataMgr.isRoomBackToHall then
                app.holdOn.hide()
                app.holdOn.show("连接已断开,正在重连")

                self:disconnectFromGame()
               
                cc.dataMgr.isReLogin = true
                app.sceneSwitcher:enterScene("HallScene")
            end
             --[[local function clickOK()
                cc.dataMgr.isChangeAccLogin = true
                self:disconnectFromGame()
                app.sceneSwitcher:enterScene("LoginScene")
            end
             if not cc.dataMgr.isRoomBackToHall then
                 app.holdOn.hide()
                app.msgBox.showMsgBoxEx({strMsg = "连接已断开,请重新登录!", funcOk = clickOK, isHideX = true})
            end
            ]]
        end
        
        --[[
        if __event.socket ~= self.socketLogin then
            local function clickOK()
                cc.dataMgr.isChangeAccLogin = true

                self:disconnectFromGame()
                self:disconnectFromLobby()

                app.sceneSwitcher:enterScene("LoginScene")
            end
            app.holdOn.hide()
            if not cc.dataMgr.isRoomBackToHall then
                app.msgBox.showMsgBoxEx({strMsg = "连接已断开,请重新登录!", funcOk = clickOK, isHideX = true})
            end
        end]]
    end

    local function onConnectFailed(__event)
        print("connect failed.")
        print(string.format("socket status: %s", __event.name))
    end


    local function onData(__event)
       -- cc.hideLoading()
        self.procs = {}
        function self.procs.proc_SC_HEARTBEAT_CHECK_P(socket, buf)
            if self.socketLobby ~= nil then
                print("lobby heart beat")
                self.socketLobby:send(self.heartBeatCheckBuffer:getPack())
            end
            if self.socketGame ~= nil then
                print("game heart beat")
                self.socketGame:send(self.heartBeatCheckBuffer:getPack())
            end
        end

        function self.procs.proc_SC_KICKOUT_LOBBY_P(socket, buf)
            print("<----被T出大厅")
            app.holdOn.hide()
            local function clickOK()
                cc.dataMgr.isChangeAccLogin = true
                app.sceneSwitcher:enterScene("LoginScene")
            end

            app.msgBox.showMsgBoxEx({strMsg = "连接已断开,请重新登录!", funcOk = clickOK, isHideX = true})
        end

        --手机注册
        function self.procs.proc_LC_CHECK_PHONECODE_P(socket, buf)
            print("<---检测手机号回复")
            local ack = wnet.LC_CHECK_PHONECODE.new()
            ack:bufferOut(buf)
           -- dump(ack)
            display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "LC_CHECK_PHONECODE_P", data = ack })
        end

        function self.procs.proc_LC_PHONECODE_GET_VALIDATECODE_ACK_P(socket, buf)
            local ack = wnet.LC_PHONECODE_GET_VALIDATECODE_ACK.new()
            ack:bufferOut(buf)
            --dump(ack)
            display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "LC_PHONECODE_GET_VALIDATECODE_ACK", data = ack })
        end

        function self.procs.proc_LC_CHECK_PHONEVALIDATECODE_ACK_P(socket, buf)
            local ack = wnet.LC_CHECK_PHONEVALIDATECODE_ACK.new()
            ack:bufferOut(buf)
            --dump(ack)
            display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "LC_CHECK_PHONEVALIDATECODE_ACK", data = ack })
        end
        ---

        function self.procs.proc_PL_PHONE_SC_USERLOGIN_ACK_P(socket, buf)
            print("proc_PL_PHONE_SC_USERLOGIN_ACK_P")
            --print("i am here.".._self.playingScene)
            --assert(cc.Director:getInstance():getRunningScene(), self.name .. " is not playing scene."
            cc.dataMgr.lobbyUserData = wnet.SC_USERLOGIN_ACK.new()
            cc.dataMgr.lobbyUserData:bufferOut(buf)


            if cc.dataMgr.lobbyUserData.lobbyResult == 0 then --登录成功
                app.phoneLogic:reqPhoneCodeBindResult()
                app.shopLogic:reqGetRechargeAwardInfo()
                self:disconnectFromLogin()
            end
            
            if targetPlatform ~= cc.PLATFORM_OS_WINDOWS then
                local bridge = require("app.func.Bridge")
                bridge.setCurrUserId(cc.dataMgr.lobbyLoginData.userID)
            end
            

            display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "PL_PHONE_SC_USERLOGIN_ACK_P", data = cc.dataMgr.lobbyUserData})
        end

        function self.procs.proc_PL_PHONE_LC_LOGIN_ACK_P(socket, buf)
            cc.dataMgr.lobbyLoginData = wnet.lobbyLoginAck.new()
            cc.dataMgr.lobbyLoginData:bufferOut(buf)
            display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "PL_PHONE_LC_LOGIN_ACK_P", data = cc.dataMgr.lobbyLoginData })
        end

        function self.procs.proc_LC_TRAIL_LOGIN_ACK_P(socket, buf)
            print("proc_LC_TRAIL_LOGIN_ACK_P")
            local ack = wnet.LC_TRAIL_LOGIN_ACK.new()
            ack:bufferOut(buf)
            if ack.loginRet == 0 then
                cc.dataMgr.lobbyLoginData.userID = ack.userID
                cc.dataMgr.lobbyLoginData.passCode = ack.strPassCode
                
                cc.UserDefault:getInstance():setBoolForKey("isGuestLogin", true)
                self:connectToLobby(ack.strIP, ack.wPort)
            else
                app.holdOn.hide()
                app.toast.show("登录失败" ..ack.loginRet)
                cc.dataMgr.guestLogin = false
            end
        end

        function self.procs.proc_PL_PHONE_SC_GAMELIST_ACK_P(socket, buf)
            cc.dataMgr.gameList = wnet.SC_GAMELIST_ACK.new()
            cc.dataMgr.gameList:bufferOut(buf)

            if #cc.dataMgr.gameList.vecGameInfo > 1 then
                table.sort(cc.dataMgr.gameList.vecGameInfo, function(x, y)
                    return x.gameInfo.sortID < y.gameInfo.sortID
                end)
            end

            cc.dataMgr.gameLists[cc.dataMgr.playingGame] = cc.dataMgr.gameList

            
            display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "PL_PHONE_SC_GAMELIST_ACK_P" })
        end

        function self.procs.proc_PL_PHONE_GC_LOGIN_ACK_P(socket, buf)
            cc.dataMgr.gameData = wnet.PL_PHONE_GC_LOGIN_ACK.new()
            cc.dataMgr.gameData:bufferOut(buf)
            print(cc.dataMgr.gameData:toString())
            display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "PL_PHONE_GC_LOGIN_ACK_P", data = cc.dataMgr.gameData })

            if cc.dataMgr.gameData.bRet == wnet.EGameResult.EGAME_RESULT_OK then
                
            end
        end

        function self.procs.proc_GC_ROOM_USERLIST_P(socket, buf)
            local ack = wnet.GC_ROOM_USERLIST.new()
            ack:bufferOut(buf)
            local _start = 0
            local _count = 0
            if cc.dataMgr.userList.userList == nil then
                _start = 0
                _count = #ack
                cc.dataMgr.userList = table.deepcopy(ack)
            else
                _start = #cc.dataMgr.userList.userList
                _count = #ack
                table.foreach(ack.userList,
                    function(i, v)
                        table.insert(cc.dataMgr.userList.userList, v)
                    end)
            end
            --print(cc.dataMgr.userList:toString())
            display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "GC_ROOM_USERLIST_P", data = { _start, _count } })
        end


        function self.procs.proc_GC_TABLE_STATSLIST_P(socket, buf)
            local ack = wnet.GC_TABLE_STATUSLIST.new()
            ack = wnet.GC_TABLE_STATUSLIST.new()
            ack:bufferOut(buf)

            for i = 1, #ack.statusList do
                cc.dataMgr.tableStatusList[ack.statusList[i].tableID + 1] = ack.statusList[i].status
            end

            --dump(cc.dataMgr.tableStatusList)
    
            display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "GC_TABLE_STATSLIST_P" })
        end

        function self.procs.proc_GC_TABLE_STATUS_UP_P(socket, buf)
            local ack = wnet.GC_TABLE_STATUS_UP.new()
            ack:bufferOut(buf)
            --dump(ack)
            cc.dataMgr.tableStatusList[ack.tableID + 1] = ack.status
            if display:getRunningScene().root then
                display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "GC_TABLE_STATUS_UP_P", data = ack })
            end
        end

        function self.procs.proc_GC_ENTERTABLE_P(socket, buf)
            print("proc_GC_ENTERTABLE_P")
            local ack = wnet.PL_PHONE_GC_ENTERTABLE.new()
            ack:bufferOut(buf)
            if ack.isOB == 1 then
                print("旁观加入")
                return
            end
            if ack.gameUser.userData.userID == cc.dataMgr.gameData.userID then
                cc.dataMgr.selectedTableID = ack.tableID
                cc.dataMgr.selectedChairID = ack.chairID
            end
           --[[ if cc.dataMgr.gameData.userID == ack.gameUser.gameData.userID then
                cc.dataMgr.gameData = table.deepcopy(ack.gameUser.gameData)
            end]]

           
            display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "GC_ENTERTABLE_P", data = ack })
        end

        function self.procs.proc_GC_LEAVETABLE_P(socket, buf)
            local ack = wnet.GC_LEAVETABLE.new()
            ack:bufferOut(buf)
             if ack.isOB == 1 then
                print("旁观离开")
                return
             end
            

            display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "GC_LEAVETABLE_P", data = ack })

            if ack.userID == cc.dataMgr.gameData.userID then
                cc.dataMgr.selectedTableID = -1
                cc.dataMgr.selectedChairID = -1
                if app.funcPublic.isWrapGame() and app.runningScene.name == "GameScene" then
                    app.sceneSwitcher:enterScene("RoomScene")
                end

                print("<----refresh user currency info")
                --同步玩家代币信息
                app.cofferLogic:reqGetBankData()
            end
        end

        function self.procs.proc_GC_GAMEUSER_UP_P(socket, buf)
            local ack = wnet.GC_GAMEUSER_UP.new()
            ack:bufferOut(buf)

           -- dump(ack)
            table.foreach(ack.attrList, function(i, v)
                local attrEntry = v.attrEntry
                local attrValue = v.attrValue

                if attrEntry == wnet.Attr_Entry.eAttrEntry_Money then --游戏豆更新
                    if cc.dataMgr.tableUsers and cc.dataMgr.tableUsers[ack.userID] then
                        if ack.userID == cc.dataMgr.lobbyUserData.lobbyUser.userID then
                            cc.dataMgr.lobbyUserData.lobbyUser.gameCurrency.l = v.attrValue
                        end
                        
                        cc.dataMgr.tableUsers[ack.userID].userData.gameCurrency.l = v.attrValue
                        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "Evt_Update_User_Info", data = {userID = ack.userID, gameType = 0}})
                    end
                elseif attrEntry == wnet.Attr_Entry.eAttrEntry_Score then --积分更新
                     if cc.dataMgr.tableUsers and cc.dataMgr.tableUsers[ack.userID] then
                        cc.dataMgr.tableUsers[ack.userID].gameData.nScore = v.attrValue
                        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "Evt_Update_User_Info", data = {userID = ack.userID, gameType = 1}})
                    end
                elseif attrEntry == wnet.Attr_Entry.eAttrEntry_Status then   --游戏状态更新
                    if display:getRunningScene().root then
                        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "Evt_Update_User_Status", data = {userID = ack.userID, value = v.attrValue}})
                    end
                elseif attrEntry == wnet.Attr_Entry.eAttrEntry_Win then
                     if cc.dataMgr.tableUsers and cc.dataMgr.tableUsers[ack.userID] then
                        cc.dataMgr.tableUsers[ack.userID].gameData.nWin = v.attrValue
                    end
                elseif attrEntry == wnet.Attr_Entry.eAttrEntry_Lose then
                     if cc.dataMgr.tableUsers and cc.dataMgr.tableUsers[ack.userID] then
                        cc.dataMgr.tableUsers[ack.userID].gameData.nLose = v.attrValue
                    end
                elseif attrEntry == wnet.Attr_Entry.eAttrEntry_Draw then
                     if cc.dataMgr.tableUsers and cc.dataMgr.tableUsers[ack.userID] then
                        cc.dataMgr.tableUsers[ack.userID].gameData.nDraw = v.attrValue
                    end
                end
            end)

            local tableUser = nil
            table.foreach(cc.dataMgr.tableUsers, function (i, v)
                if i == ack.userID then
                    tableUser = cc.dataMgr.tableUsers[i]
                    return
                end
            end)
            --dump(cc.dataMgr.tableUsers)
            if tableUser ~= nil  then
                table.foreach(ack.attrList, function(i, v)
                    local attrEntry = v.attrEntry
                    local attrValue = v.attrValue
                    if attrEntry == wnet.Attr_Entry.eAtrrEntry_GameMoney then
                        tableUser.playCurrency = attrValue
                        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "EvtUpdateUserPlayCurrency", data = ack})
                    end
                end)
            end
            --display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "GC_GAMEUSER_UP_P", data = ack })
            ack = {}
        end

        function self.procs.proc_GC_ENTERTABLE_ACK_P(socket, buf)
            local ack = wnet.GC_ENTERTABLE_ACK.new()
            ack:bufferOut(buf)
            display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "GC_ENTERTABLE_ACK_P", data = ack })
            ack = {}
        end

        function self.procs.proc_GC_HANDUP_P(socket, buf)
            local ack = wnet.GC_HANDUP.new()
            ack:bufferOut(buf)
            display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "GC_HANDUP_P", data = ack.chairID })
            ack = {}
        end

        function self.procs.proc_GC_STARTTIMER_P(socket, buf)
            local ack = wnet.GC_STARTTIMER.new()
            ack:bufferOut(buf)
            display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "GC_STARTTIMER_P", data = ack })
            ack = {}
        end

        function self.procs.proc_GC_TABLE_USERLIST_P(socket, buf)
            local ack = wnet.GC_TABLE_USERLIST.new()
            ack:bufferOut(buf)

            for _, v in pairs(ack.userList) do
                if v.userData.userID == cc.dataMgr.gameData.userID then
                    cc.dataMgr.selectedTableID = v.gameData.tableID
                    cc.dataMgr.selectedChairID = v.gameData.chairID
                    print("cc.dataMgr.selectedChairID = " ..cc.dataMgr.selectedChairID)
                end
            end

            display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "GC_TABLE_USERLIST_P", data = ack })
            ack = {}
        end

        function self.procs.proc_LC_PHONECODE_REG_ACK_P(socket, buf)
            local ack = wnet.LC_REG_ACK.new()
            ack:bufferOut(buf)
            if ack.ret == 0 and clientConfig.regPresent then
                app.individualLogic:reqRegForPresent(ack.uerID)
            end
            display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "LC_PHONECODE_REG_ACK_P", data = ack })
            ack = {}
        end

        function self.procs.proc_PL_PHONE_LC_USERRANK_ACK_P(socket, buf)
            local ack = wnet.PL_PHONE_LC_USERRANK_ACK_P.new()
            ack:bufferOut(buf)
            display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "PL_PHONE_LC_USERRANK_ACK_P", data = ack })
            ack = {}
        end

        function self.procs.proc_PL_PHONE_LC_SELFUSERRANK_ACK_P(socket, buf)
            local ack = wnet.PL_PHONE_LC_SELFUSERRANK_ACK_P.new()
            ack:bufferOut(buf)
            display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "PL_PHONE_LC_SELFUSERRANK_ACK_P", data = ack })
            ack = {}
        end

        function self.procs.proc_DC_USER_LOAD_BROKEN_GAME_P(socket, buf)
            print("是否为断线重连")
            local ack = wnet.BROKEN_GAME_LIST.new()
            ack:bufferOut(buf)
            cc.dataMgr.isBroken = false
            --dump(ack)
            if #ack.vList ~= 0 then
                print("cc.dataMgr.isBroken")
                app.holdOn.show("正在进入桌子...")
                cc.dataMgr.isBroken = true
                cc.dataMgr.selectServerID = ack.vList[1].srvId
                cc.dataMgr.selectRoomID = ack.vList[1].roomId
                cc.dataMgr.selectGameID = ack.vList[1].gameId

                print("断线重连 gameid = " ..cc.dataMgr.selectGameID)
                cc.lobbyController:sendGameListReq(cc.dataMgr.selectGameID)
            end
        end

       -------------------------------中国象棋协议退出------------------------------------------
       function self.procs.proc_GC_AGREELEAVE_ACK_P(socket, buf)
           print"proc_GC_AGREELEAVE_ACK_P"
           local ack = wnet.GC_AGREELEAVE_ACK.new()
           ack:bufferOut(buf)
           display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "GC_AGREELEAVE_ACK_P", data = ack })
       end


       function self.procs.proc_GC_AGREELEAVE_ASK_P(socket, buf)
           print"proc_GC_AGREELEAVE_ACK_P11111111111111"
           local ack = wnet.GC_AGREELEAVE_ASK.new()
           ack:bufferOut(buf)
           display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "GC_AGREELEAVE_ASK_P", data = ack })
       end
       ----------------------------------完------------------------------------------------
       ------------------------------德州扑克补充-------------------------------------
       function self.procs.proc_GC_GETSHOWSETBETINFO_ACK_P(socket, buf)
           print("proc_GC_GETSHOWSETBETINFO_ACK_P")
           local ack = wnet.GC_GETSHOWSETBETINFO.new()
           ack:bufferOut(buf)
           display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "GC_GETSHOWSETBETINFO_ACK_P", data = ack })

       end

       function self.procs.proc_GC_CHECKBET_ACK_P(socket, buf)
           print"proc_GC_CHECKBET_ACK_P"
           local ack = wnet.GC_CHECKBET_ACK.new()
           ack:bufferOut(buf)
           display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "GC_CHECKBET_ACK_P", data = ack })

       end

       function self.procs.proc_GC_TABLEUSERBRINGGAMECURRENCY_ACK_P(socket, buf)
           print"proc_GC_TABLEUSERBRINGGAMECURRENCY_ACK_P"
           local ack = wnet.GC_TABLEUSERBRINGGAMECURRENCY.new()
           ack:bufferOut(buf)
           display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "GC_TABLEUSERBRINGGAMECURRENCY_ACK_P", data = ack })
       end

       function self.procs.proc_GC_SUPPLYINFO_ACK_P(socket, buf)
           print"proc_GC_SUPPLYINFO_ACK_P"
           local ack = wnet.GC_SUPPLYINFO.new()
           ack:bufferOut(buf)
           display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "GC_SUPPLYINFO_ACK_P", data = ack })
       end

       function self.procs.proc_GC_BRINGGAMECURRENCY_INFO_ACK_P(socket, buf)
           print("proc_GC_BRINGGAMECURRENCY_INFO_ACK_P")
           local ack = wnet.GC_BRINGGAMECURRENCY_INFO.new()
           ack:bufferOut(buf)
           cc.dataMgr.bringLeastTimes = ack.bringLeastTimes
           cc.dataMgr.bringMostTimes = ack.bringMostTimes
           cc.dataMgr.tenThousandBringMostTimes = ack.tenThousandBringMostTimes
       end

       function self.procs.proc_GC_DZ_STARTTIMER_P(socket, buf)
           print"proc_GC_DZ_STARTTIMER_P"
           local ack = wnet.GC_DZ_STARTTIMER.new()
           ack:bufferOut(buf)
           display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "GC_DZ_STARTTIMER_P", data = ack })
       end
        -------------------------------补充 止------------------------------------------


        ----------------------------聊天 start------------------------------------------
        function self.procs.proc_GC_TABLECHAT_P(socket, buf)
            local ack = wnet.CHAT_MSG.new()
            ack:bufferOut(buf)
            if app.gameLayer ~= nil then
                app.gameLayer.chatLayer.eventProtocol:dispatchEvent({ name = "GC_TABLECHAT_P", data = ack })
            end
            display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "GC_TABLECHAT_P", data = ack })
        end
        function self.procs.proc_GC_TABLE_CHATFAIL_P(socket, buf)
            local ack = wnet.CHAT_FAIL.new()
            --print("聊天失败")
            ack:bufferOut(buf)
            if app.gameLayer ~= nil then
                app.gameLayer.chatLayer.eventProtocol:dispatchEvent({ name = "GC_TABLE_CHATFAIL_P", data = ack })
            end
            display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "GC_TABLE_CHATFAIL_P", data = ack })
        end
        -----------------------------聊天 end-----------------------------------------

		---------------------------- mini game proc start------------------------------
        function self.procs.proc_GC_GAME_START_P(socket, buf) --游戏开始
            cc.dataMgr.isBroken = false
            display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "GC_GAME_START_P"})
            if app.gameLayer ~= nil then
                app.gameLayer.eventProtocol:dispatchEvent({ name = "GC_GAME_START_P"})
            end
        end

		function self.procs.proc_mini_game_msg(socket, buf, opCode)
            if app.miniGameMsgHandler ~= nil then
                app.miniGameMsgHandler:procMsgs(socket, buf, opCode)
            else
                --print("miniGameMsgHandler is nil")
            end
		end
		---------------------------- mini game proc end------------------------------
        ----------------------------------------防作弊场协议 起---------------------------
       wnet.GC_NOCHEAT_MATCH_INFO_ACK_P = class("GC_NOCHEAT_MATCH_INFO_ACK_P", packBody)
       function wnet.GC_NOCHEAT_MATCH_INFO_ACK_P:ctor(code, uid, pnum, mapid, syncid)
           wnet.GC_NOCHEAT_MATCH_INFO_ACK_P.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
           self.name = "GC_NOCHEAT_MATCH_INFO_ACK_P"
       end
       function wnet.GC_NOCHEAT_MATCH_INFO_ACK_P:bufferOut(buf)
           if cc.dataMgr.randMatch==nil then
               cc.dataMgr.randMatch = {}
           end
           cc.dataMgr.randMatch.matchInfo = {}
           local data = {}

           data.srvID = buf:readInt()
           data.matchType = buf:readInt()
           local gch = buf:readUInt()
           local gcl = buf:readUInt()
           data.startTime = i64(gch, gcl)
           gch = buf:readUInt()
           gcl = buf:readUInt()
           data.endTime = i64(gch, gcl)
           data.bStartMatch = buf:readBool()
           data.bReconn = buf:readBool()
           data.matchMaxCount = buf:readInt()
           data.MatchMinCount = buf:readInt()
           data.strName = buf:readStringUShort()
           data.strCode = buf:readStringUShort()
           data.strIcon = buf:readStringUShort()
           data.awardTimeSpan = buf:readInt()
           gch = buf:readUInt()
           gcl = buf:readUInt()
           data.rDayStartTime = i64(gch, gcl)
           gch = buf:readUInt()
           gcl = buf:readUInt()
           data.rDayEndTime = i64(gch, gcl)
           data.strIcon1 = buf:readStringUShort()
           gch = buf:readUInt()
           gcl = buf:readUInt()
           data.srvTime = i64(gch, gcl)

           cc.dataMgr.randMatch.matchInfo = data
       end
       function self.procs.proc_GC_NOCHEAT_MATCH_INFO_ACK_P(socket, buf)
           local ack = wnet.GC_NOCHEAT_MATCH_INFO_ACK_P.new()
           ack:bufferOut(buf)
           if (cc.dataMgr.randMatch.matchInfo.matchType==1) or (cc.dataMgr.randMatch.matchInfo.matchType==2) then
               cc.dataMgr.withoutRoomScene = true
               cc.dataMgr.useRandMatch = true
--[[               if app.randMatch and app.randMatch.randMatchUI and app.randMatch.randMatchListUI and app.runningScene.name=="GameScene" then
                   app.randMatch.randMatchUI:setAwardTime(cc.dataMgr.randMatch.matchInfo.awardTimeSpan)
                   app.randMatch.randMatchListUI:setMatchType(cc.dataMgr.randMatch.matchInfo.matchType)
               end]]
           end
           display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "GC_NOCHEAT_MATCH_INFO_ACK_P", data = cc.dataMgr.randMatch.matchInfo })
       end
       ----------------------------------------防作弊场协议 止---------------------------

       ----------------------------------------底注设置 起---------------------------
       wnet.GC_GETBETSETINFO_ACK_P = class("GC_GETBETSETINFO_ACK_P", packBody)
       function wnet.GC_GETBETSETINFO_ACK_P:ctor(code, uid, pnum, mapid, syncid)
           wnet.GC_GETBETSETINFO_ACK_P.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
           self.name = "GC_GETBETSETINFO_ACK_P"
       end
       function wnet.GC_GETBETSETINFO_ACK_P:bufferOut(buf)
           self.bSetBet = buf:readBool()
           self.nBet = buf:readInt()
           self.betInfo = {}
           local len = buf:readShort()
           for i=1,len do
               local key = buf:readInt()
               local value = buf:readInt()
               self.betInfo[key] = value
           end
           self.gameCurrencyLimit = buf:readInt()
       end
       function self.procs.proc_GC_GETBETSETINFO_ACK_P(socket, buf)
            print("<=== proc_GC_GETBETSETINFO_ACK_P===")
           local ack = wnet.GC_GETBETSETINFO_ACK_P.new()
           ack:bufferOut(buf)
           cc.dataMgr.castMultSetInfo.useCastMultSet = true
           cc.dataMgr.castMultSetInfo.castMultInfo = ack
           local tmpData = {}
           tmpData.bSetBet = ack.bSetBet
           tmpData.nBet = ack.nBet
           tmpData.betInfo = table.deepcopy(ack.betInfo)
           tmpData.gameCurrencyLimit = ack.gameCurrencyLimit
           if cc.dataMgr.castMultSet == nil then
               cc.dataMgr.castMultSet = {}
           end
           cc.dataMgr.castMultSet.beiShuInfo = tmpData
           display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "GC_GETBETSETINFO_ACK_P", data = ack })
       end
       ----------------------------------------底注设置 止---------------------------
       ----------------------------------------挑战赛 起---------------------------
       wnet.GC_CHALLENGE_INFO_P = class("GC_CHALLENGE_INFO_P", packBody)
       function wnet.GC_CHALLENGE_INFO_P:ctor(code, uid, pnum, mapid, syncid)
           wnet.GC_CHALLENGE_INFO_P.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
           self.name = "GC_CHALLENGE_INFO_P"
       end
       function wnet.GC_CHALLENGE_INFO_P:bufferOut(buf)
           local data = {}
           data.srvID = buf:readInt()
           data.nMatchUserNum = buf:readInt()
           data.nCurEnrollNum = buf:readInt()
           data.nCount = buf:readInt()
           local gcl = buf:readUInt()
           local gch = buf:readUInt()
           data.startTime = i64_ax(gch, gcl)
           gcl = buf:readUInt()
           gch = buf:readUInt()
           data.endTime = i64_ax(gch, gcl)
           data.bMatch = buf:readBool()
           data.bRecon = buf:readBool()
           data.fightLordInfoUrl = buf:readStringUShort()
           data.challengeGameName = buf:readStringUShort()
           data.gameNoticeInfoUrl = buf:readStringUShort()
           data.fightPhoneLordInfoUrl = buf:readStringUShort()

            self.data = data
       end
       function self.procs.proc_GC_CHALLENGE_INFO_P(socket, buf)
           local ack = wnet.GC_CHALLENGE_INFO_P.new()
           ack:bufferOut(buf)

           cc.dataMgr.challengeInfo = ack.data
           if display:getRunningScene().root then
               display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "GC_CHALLENGE_INFO_P", data = ack.data })
           end
       end
       ----------------------------------------挑战赛 止---------------------------

        local str = string.format("socket data status: %s, data:%s", __event.name, ByteArray.toString(__event.data))
       -- print(str)
        table.insert(self.dataQueue, __event.data)
        --coroutine.resume(self.doMsgProc)
        --local msgProc = procs["proc_" .. (cc.protocolNumber:getProtocolName(pack.opCode) or "")]
        --if pack.opCode ~= 11027 then
        --    print("proc_" .. (cc.protocolNumber:getProtocolName(pack.opCode) or pack.opCode))
        --end
        --print("proc_" ..  pack.opCode)
    end

    _socket.eventProtocol:addEventListener(socketTCP.EVENT_CONNECTED, onConnected)
    _socket.eventProtocol:addEventListener(socketTCP.EVENT_CLOSE, onClose)
    _socket.eventProtocol:addEventListener(socketTCP.EVENT_CLOSED, onClosed)
    _socket.eventProtocol:addEventListener(socketTCP.EVENT_CONNECT_FAILURE, onConnectFailed)
    _socket.eventProtocol:addEventListener(socketTCP.EVENT_DATA, onData)

    local function _doMsgProc()

        if #self.dataQueue > 0 then
            --print("dataQueue " .. #self.dataQueue)
        end
        table.foreach(self.dataQueue, function(i, v)
            if cc.sceneTransFini == true then
                self.dataQueue[i] = nil
                local buffer = ByteArray.new():writeString(v):setPos(1)
                local pack = packBody.new(buffer:readUInt(), buffer:readUInt(), buffer:readUShort(), buffer:readUInt(), buffer:readUInt())
                --print("ftest msgHandler _doMsgProc code="..pack.opCode)

                if pack.opCode ~= 11027 then
                    print("lobby proc_" .. (cc.protocolNumber:getProtocolName(pack.opCode) or pack.opCode))
                end

                local bProced = false
               
                if not bProced then
                   -- dump(wrapRoom)
                    if wrapRoom and wrapRoom.wrapRoomMsgHandler then
                        bProced = wrapRoom.wrapRoomMsgHandler:procMsgs(_socket, buffer, pack.opCode)
                    end
                end

                if not bProced then
                    bProced = app.individualLogic:procMsgs(_socket, buffer, pack.opCode)
                end

                if not bProced then --task
                    bProced = app.taskMsgHandler:procMsgs(_socket, buffer, pack.opCode)
                end

                if not bProced then
                    bProced = app.cofferLogic:procMsgs(_socket, buffer, pack.opCode)
                end

                if not bProced then
                    bProced = app.phoneLogic:procMsgs(_socket, buffer, pack.opCode)
                end

                if not bProced then
                    bProced = app.bulletinLogic:procMsgs(_socket, buffer, pack.opCode)
                end

                if not bProced then
                    bProced = app.signInLogic:procMsgs(_socket, buffer, pack.opCode)
                end

               

                if not bProced then
                    bProced = app.shopLogic:procMsgs(_socket, buffer, pack.opCode)
                end

                if not bProced then
                    bProced = app.benefitLogic:procMsgs(_socket, buffer, pack.opCode)
                end

                if not bProced then
                    for k,v in pairs(self.shareMsgObj) do
                        if not bProced and v~=nil and v.procMsgs~=nil then
                            bProced = v:procMsgs(_socket, buffer, pack.opCode)
                        else
                            break
                        end
                    end
                end

                


                if bProced then
                    --self.dataQueue[i] = nil
                    return
                end
                --]]

				local msgProc
                if pack.opCode >= cc.protocolNumber.PROTOCOL_GAMESERVER and pack.opCode <= cc.protocolNumber.PROTOCOL_GAMECLIENT then
					msgProc = self.procs["proc_mini_game_msg"]
				else
					msgProc = self.procs["proc_" .. (cc.protocolNumber:getProtocolName(pack.opCode) or "")]
				end

				if msgProc ~= nil then
                    msgProc(_socket, buffer, pack.opCode)
                    msgProc = nil
                end
                --self.dataQueue[i] = nil
            end
        end)
    end

    self.tickScheduler = scheduler.scheduleGlobal(_doMsgProc, 0.1)
   

    --cc.showLoading()
    _socket:connect()
end

function MsgHandler:connectToLobby(ip, port)
    ip = ip or cc.dataMgr.lobbyLoginData.ip
    port = port or cc.dataMgr.lobbyLoginData.port
    --print("connect lobby ip:"..ip.." port:"..port)
    self.socketLobby = socketTCP.new(ip, port, false)
    self:connect("lobby")
end

function MsgHandler:disconnectFromLobby()
    if self.socketLobby then
      --  print("disconnectFromLobby")
        self.socketLobby:disconnect()
        self.socketLobby:close()
        self.socketLobby = nil
    end
end

function MsgHandler:connectToLogin()
    self.socketLogin = socketTCP.new(clientConfig.serverAddress, clientConfig.serverPort, clientConfig.retryConnectWhenFailure)
    self:connect("login")
end

function MsgHandler:connectToGame(ip, port)
    self.socketGame = socketTCP.new(ip, port, false)
    self:connect("game")
end

function MsgHandler:disconnectFromLogin()
    if self.socketLogin then
        self.socketLogin:disconnect()
        self.socketLogin:close()
        self.socketLogin = nil
    end
end

function MsgHandler:disconnectFromGame()
    if self.socketGame then
        print("disconnectFromGame")
        self.socketGame:disconnect()
        self.socketGame:close()
        self.socketGame = nil
    end
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function MsgHandler:setPlayingScene(scene)
    self.playingScene = scene
end

-------------------------------------------------------------------------------
---------------------------- protocol proc ------------------------------------
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
---------------------------- protocol proc end --------------------------------
-------------------------------------------------------------------------------

return MsgHandler