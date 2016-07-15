--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/11/10
-- Time: 10:00
-- To change this template use File | Settings | File Templates.
--

local castMultipleSetLogic = class("CastMultipleSetLogic")

local packBody = require "data.packBody"
local _gamedb = require("app/func/GameDB")
local iconv = require "iconv"
local encoding = iconv.new("utf-8", "GB18030") --多字节 -->utf8  接受服务器带中文字字段
local decoding = iconv.new("GB18030", "utf-8") --utf8 -->多字节 发送到服务器 带中文字字段

function castMultipleSetLogic:ctor()
    self._socketGame = cc.msgHandler.socketGame
    self.msgCode = {}
    ----------------------------------------------------------------------------
    self.msgCode["CG_SETBET_REQ_P"] = 13102
    self.msgCode["GC_SETBET_ACK_P"] = 13103
    self.msgCode["GC_ENTERTABLE_ACK_P"] = 13033
    self.msgCode["GC_ENTERTABLE_P"] = 13035
    self.msgCode["GC_TABLESETBET_INFO_ACK_P"] = 13104
    -----------------------------------------------------------------------------
    ------------------------------------------------------------------------------
    -- 接收消息部分
    self.GC_SETBET_ACK_P = class("GC_SETBET_ACK_P", packBody)
    function self.GC_SETBET_ACK_P:ctor(code, uid, pnum, mapid, syncid)
        self.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
        self.name = "GC_SETBET_ACK_P"
    end
    function self.GC_SETBET_ACK_P:bufferOut(buf)
        local data = {}
        data.nResult = buf:readInt()
        data.nBet = buf:readInt()
        data.gamecurrencyLimit = buf:readInt()
        return data
    end
    ----------------
    -- 请求消息部分
    self.CG_SETBET_REQ_P = class("CG_SETBET_REQ_P", packBody)
    function self.CG_SETBET_REQ_P:ctor(code, uid, pnum, mapid, syncid)
        self.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
        self.name = "CG_SETBET_REQ_P"
    end
    function self.CG_SETBET_REQ_P:bufferIn(bet,Currency)
        local buf = self.super.bufferIn(self)
        buf:writeInt(cc.dataMgr.lobbyUserData.lobbyUser.userID)
        buf:writeShort((_gamedb.readGameInfo())[1].gameId)
        buf:writeInt(bet)
        buf:writeInt(Currency)
        buf:writeBool(false)
        return buf
    end
    ---------------
    self.GC_ENTERTABLE_ACK = class("GC_ENTERTABLE_ACK", packBody)
    function self.GC_ENTERTABLE_ACK:ctor(code, uid, pnum, mapid, syncid)
        self.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
        self.name = "GC_ENTERTABLE_ACK"
    end
    function self.GC_ENTERTABLE_ACK:bufferOut(buf)
        local data = {}
        data.EnterTable_Result = buf:readInt()
        data.forbidID = buf:readInt()
        data.lineUpTime = buf:readInt()
        data.minGameCurrency = buf:readInt()
        return data
    end
    ----------------
    self.GC_ENTERTABLE_P = class("GC_ENTERTABLE_P", packBody)
    function self.GC_ENTERTABLE_P:ctor(code, uid, pnum, mapid, syncid)
        self.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
        self.name = "GC_ENTERTABLE_P"
    end
    function self.GC_ENTERTABLE_P:bufferOut(buf)
        local data = {}
        data.gameUser = {}
        data.gameUser.userData = {}
        data.gameUser.userData.userID = buf:readInt()
        data.gameUser.userData.ident = buf:readInt()
        data.gameUser.userData.gmPur = buf:readInt()
        data.gameUser.userData.icon = buf:readShort()
        data.gameUser.userData.gender = buf:readChar()
        data.gameUser.userData.vipExp = buf:readInt()
        data.gameUser.userData.vipBegin = buf:readInt()
        data.gameUser.userData.vipEnd = buf:readInt()
        data.gameUser.userData.vipLevel = buf:readChar()
        data.gameUser.userData.honor = buf:readInt()
        data.gameUser.userData.honorLevel = buf:readChar()
        local gcl = buf:readUInt()
        local gch = buf:readUInt()
        data.gameUser.userData.gameCurrency = i64_ax(gch, gcl)
        data.gameUser.userData.strNickName = encoding:iconv(buf:readStringUShort())

        data.gameUser.gameData = {}
        data.gameUser.gameData.userStatus = buf:readInt()
        data.gameUser.gameData.tableID = buf:readChar()
        data.gameUser.gameData.chairID = buf:readChar()
        data.gameUser.gameData.nScore = buf:readInt()
        data.gameUser.gameData.nWin = buf:readInt()
        data.gameUser.gameData.nLose = buf:readInt()
        data.gameUser.gameData.nDraw = buf:readInt()
        data.gameUser.gameData.nDisc = buf:readInt()

        data.tableID = buf:readChar()
        data.chairID = buf:readChar()
        data.isOB = buf:readChar()
        data.setBet = buf:readInt()

        return data
    end
    ----------------
    self.GC_TABLESETBET_INFO_ACK_P = class("GC_TABLESETBET_INFO_ACK_P", packBody)
    function self.GC_TABLESETBET_INFO_ACK_P:ctor(code, uid, pnum, mapid, syncid)
        self.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
        self.name = "GC_TABLESETBET_INFO_ACK_P"
    end
    function self.GC_TABLESETBET_INFO_ACK_P:bufferOut(buf)
        local data = {}
        data.tableSetBetInfoList = {}
        local len = buf:readShort()
        for i=1,len do
            data.tableSetBetInfoList[i] = {}
            data.tableSetBetInfoList[i].tableId = buf:readChar()
            data.tableSetBetInfoList[i].nBet = buf:readInt()
        end
        return data
    end
    ----------------

    -- 将底注设置消息循环加入msgHandler消息循环中
    cc.msgHandler.shareMsgObj["castMultipleSetLogic"] = self
end

-- 自定义底注消息派发
function castMultipleSetLogic:procMsgs(_socket, buffer, opCode)
    print("ftest castMultipleSetLogic:procMsgs opCode="..opCode)
    if opCode == self.msgCode["GC_SETBET_ACK_P"] then
        local ack = self.GC_SETBET_ACK_P.new()
        local data = ack:bufferOut(buffer)
        app.holdOn.hide()
        app.castMultSet:respSastSet(data)
        return true
    elseif opCode == self.msgCode["GC_TABLESETBET_INFO_ACK_P"] then
        local ack = self.GC_TABLESETBET_INFO_ACK_P.new()
        local data = ack:bufferOut(buffer)
        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "GC_TABLESETBET_INFO_ACK_P", data = data })
        return true

    end

    return false
end

function castMultipleSetLogic:sendCastSetReq(bet,currency)
    print("<===bet = " ..bet)
    print("<===currency = " ..currency)

    if currency == 0 then
        currency = bet * 50 + 1
    end

    local req = self.CG_SETBET_REQ_P.new(self.msgCode["CG_SETBET_REQ_P"],cc.dataMgr.lobbyLoginData.userID)
    cc.msgHandler.socketGame:send(req:bufferIn(bet, currency):getPack())
end

function castMultipleSetLogic:onExit()
    cc.msgHandler.shareMsgObj["castMultipleSetLogic"] = nil
end

return castMultipleSetLogic