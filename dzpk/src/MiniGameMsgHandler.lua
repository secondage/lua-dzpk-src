--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/10/14
-- Time: 18:19
-- To change this template use File | Settings | File Templates.
--
local MiniGameMsgHandler = class("MiniGameMsgHandler")

function MiniGameMsgHandler:ctor()
    self.miniGameProcs = {}
    self.socketGame = cc.msgHandler.socketGame
    local gameProtocol = app.gameProtocol
    local gameModel = app.gameModel

    function self.miniGameProcs.proc_SC_BET_P( opCode, buf ) --赔率
    print("self.miniGameProcs.proc_SC_BET_P.opCode = " ..opCode)
    local ack = gameProtocol.SC_BET.new()
    ack:bufferOut(buf)
    gameModel:setSC_BET(ack)
    end

    function self.miniGameProcs.proc_SC_POKE_DEAL_P( opCode, buf ) --发牌
    print("self.miniGameProcs.proc_SC_POKE_DEAL_P.opCode = " ..opCode)
    local ack = gameProtocol.SC_POKE_DEAL.new()
    ack:bufferOut(buf)
    gameModel:setSC_POKE_DEAL(ack)   ---将服务器发来的数据存储在model中，加工后进行转发
    end

    function self.miniGameProcs.proc_SC_INIT_DATA_P( opCode, buf ) --断线重连
    print("self.miniGameProcs.proc_SC_SC_INIT_DATA_P.opCode = " ..opCode)
    local ack = gameProtocol.SC_INIT_DATA.new()
    ack:bufferOut(buf)
    --dump(ack)
    gameModel:setSC_INIT_DATA(ack)
    end

    function self.miniGameProcs.proc_SC_GAME_RESULT_P( opCode, buf ) --结算
    print("self.miniGameProcs.proc_SC_GAME_RESULT_P.opCode = " ..opCode)
    local ack = gameProtocol.SC_GAME_RESULT.new()
    ack:bufferOut(buf)

    gameModel:setSC_GAME_RESULT(ack)
    end

    function self.miniGameProcs.proc_SC_POKE_OP_NOT_P( opCode, buf ) --显示操作
    print("self.miniGameProcs.proc_SC_POKE_OP_NOT_P.opCode = " ..opCode)
    local ack = gameProtocol.SC_POKE_OP_NOT.new()
    ack:bufferOut(buf)
    gameModel:setSC_POKE_OP_NOT(ack)
    end

    function self.miniGameProcs.proc_SC_POKE_OP_REQ_P( opCode, buf ) --提示操作
    print("self.miniGameProcs.proc_SC_POKE_OP_REQ_P.opCode = " ..opCode)
    local ack = gameProtocol.SC_POKE_OP_REQ.new()
    ack:bufferOut(buf)
    gameModel:setSC_POKE_OP_REQ(ack)
    end

    function self.miniGameProcs.proc_SC_SPLIT_BET_P( opCode, buf ) --提示操作
    print("self.miniGameProcs.proc_SC_SPLIT_BET_P.opCode = " ..opCode)
    local ack = gameProtocol.SC_SPLIT_BET_DATA.new()
    ack:bufferOut(buf)
    gameModel:setSC_SPLIT_BET_DATA(ack)
    end

    function self.miniGameProcs.proc_SC_POKE_HAND_NOT_P(opCode, buf ) --显示手牌
    print("self.miniGameProcs.proc_SC_POKE_HAND_NOT_P.opCode = " ..opCode)
    local ack = gameProtocol.SC_POKE_HAND_NOT.new()
    ack:bufferOut(buf)
    gameModel:setSC_POKE_HAND_NOT(ack)
    end
end

function MiniGameMsgHandler:procMsgs(socket, buf, opCode)
    local msgProc = self.miniGameProcs["proc_" .. (cc.protocolNumber:getProtocolNameOfMiniGame(opCode) or "")]
    print("self.miniGameProcs.opCode = " ..cc.protocolNumber:getProtocolNameOfMiniGame(opCode))

    if msgProc ~= nil then
        msgProc(opCode, buf)
    end
end

function MiniGameMsgHandler:sendOpAck(op, ext, serialTick)
    local ack = {}
    ack.op = op
    ack.ext = ext or 0
    ack.serialTick = serialTick or 0
    --dump(ack)
    local req = app.gameProtocol.CS_POKE_OP_ACK.new(cc.protocolNumber.CS_POKE_OP_ACK_P, cc.dataMgr.lobbyLoginData.userID)
    cc.msgHandler.socketGame:send(req:bufferIn(ack):getPack())
end
return MiniGameMsgHandler