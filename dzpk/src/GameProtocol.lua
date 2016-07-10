--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/11/6
-- Time: 9:59
-- To change this template use File | Settings | File Templates.
--
local GameProtocol = class("GameProtocol")
local packBody = require"data.packBody"
local _gamePublic = require(app.codeSrc .. "GamePublic")

function GameProtocol:ctor()
    -----------------------------------------------------------------------------------
    self.SC_POKE_OP_REQ = class("SC_POKE_OP_REQ", packBody)
    function self.SC_POKE_OP_REQ:ctor(code, uid, pnum, mapid, syncid)
        self.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
        self.name = "SC_POKE_OP_REQ"
    end
    function self.SC_POKE_OP_REQ:bufferOut(buf)
        self.chair = buf:readChar()
        self.first = buf:readChar()
        self.op = buf:readInt()
        self.roundMax = buf:readInt()
        self.round = buf:readInt()
        self.serialTick = buf:readInt()
    end
    -----------------------------------------------------------------------------------

    -----------------------------------------------------------------------------------
    self.SC_POKE_OP_NOT = class("SC_POKE_OP_NOT", packBody)
    function self.SC_POKE_OP_NOT:ctor(code, uid, pnum, mapid, syncid)
        self.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
        self.name = "SC_POKE_OP_NOT"
    end
    function self.SC_POKE_OP_NOT:bufferOut(buf)
        self.chair = buf:readChar()
        self.op = buf:readInt()
        self.ext = buf:readInt()
        self.bet = buf:readInt()
        self.curBet = buf:readInt()
        self.totalBet = buf:readInt()
    end
    -----------------------------------------------------------------------------------

    -----------------------------------------------------------------------------------
    self.SC_POKE_HAND_NOT = class("SC_POKE_HAND_NOT", packBody)
    function self.SC_POKE_HAND_NOT:ctor(code, uid, pnum, mapid, syncid)
        self.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
        self.name = "SC_POKE_HAND_NOT"
    end
    function self.SC_POKE_HAND_NOT:bufferOut(buf)
        self.chair = buf:readChar()
        self.handCards = {}
        local handSize = buf:readShort()
        for i = 0, handSize - 1 do
            self.handCards[i] = _gamePublic.stCard:new()
            self.handCards[i].par = buf:readChar()
            self.handCards[i].color = buf:readChar()
        end
        self.oldHandCards = {}
        local oldHandSize = buf:readShort()
        for i = 0, oldHandSize - 1 do
            self.oldHandCards[i] = _gamePublic.stCard:new()
            self.oldHandCards[i].par = buf:readChar()
            self.oldHandCards[i].color = buf:readChar()
        end
    end
    -----------------------------------------------------------------------------------

    -----------------------------------------------------------------------------------
    self.SC_POKE_DEAL = class("SC_POKE_DEAL", packBody)
    function self.SC_POKE_DEAL:ctor(code, uid, pnum, mapid, syncid)
        self.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
        self.name = "SC_POKE_DEAL"
    end
    function self.SC_POKE_DEAL:bufferOut(buf)
        self.round = buf:readInt()
        print("self.round =" .. self.round)
        self.cards = {}
        local cardsSize = buf:readShort()
        for i = 0, cardsSize - 1 do
            self.cards[i] = _gamePublic.stCard:new()
            self.cards[i].par = buf:readChar()
            self.cards[i].color = buf:readChar()
            print("self.cards[i].par = ".. self.cards[i].par.. ",self.cards[i].color=".. self.cards[i].color)
        end
        self.chair = buf:readChar()
        print("self.chair=" .. self.chair)
        self.allChairs = {}
        local chairSize = buf:readShort()
        for i = 0, chairSize - 1 do
            self.allChairs[i] = buf:readChar()
        end
    end
    -----------------------------------------------------------------------------------

    -----------------------------------------------------------------------------------
    self.SC_GAME_RESULT = class("SC_GAME_RESULT", packBody)
    function self.SC_GAME_RESULT:ctor(code, uid, pnum, mapid, syncid)
        self.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
        self.name = "SC_GAME_RESULT"
    end
    function self.SC_GAME_RESULT:bufferOut(buf)
        self.overA = buf:readInt()
        self.OrderList = {}
        local size = buf:readShort()
        for i = 0, size - 1 do
            local key = buf:readByte()
            local value = {}
            local len = buf:readShort()
            for j = 0, len - 1 do
                value[j] = buf:readChar()
            end
            self.OrderList[key] = value
        end
        self.Result = {}
        local resultSize = buf:readShort()
        for i = 0, resultSize - 1 do
            self.Result[i] = {}
            self.Result[i].chair = buf:readChar()
            self.Result[i].score = buf:readInt()
            self.Result[i].order = buf:readInt()
            self.Result[i].totalMoney = buf:readInt()
            self.Result[i].cards = {}
            local cardsSize = buf:readShort()
            for j = 0, cardsSize - 1 do
                self.Result[i].cards[j] = _gamePublic.stCard:new()
                self.Result[i].cards[j].par = buf:readChar()
                self.Result[i].cards[j].color = buf:readChar()
            end
            self.Result[i].cardType = _gamePublic.stCardType:new()
            self.Result[i].cardType.type = buf:readChar()
            self.Result[i].cardType.par = buf:readInt()
            self.Result[i].cardType.num = buf:readChar()
            self.Result[i].oldhand = {}
            local size = buf:readShort()
            for j = 0, size - 1 do
                self.Result[i].oldhand[j] = _gamePublic.stCard:new()
                self.Result[i].oldhand[j].par = buf:readChar()
                self.Result[i].oldhand[j].color = buf:readChar()
            end
        end
    end
    -----------------------------------------------------------------------------------

    -----------------------------------------------------------------------------------
    self.SC_INIT_DATA = class("SC_INIT_DATA", packBody)
    function self.SC_INIT_DATA:ctor(code, uid, pnum, mapid, syncid)
        self.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
        self.name = "SC_INIT_DATA"
    end
    function self.SC_INIT_DATA:bufferOut(buf)
        self.bet = buf:readInt()
        self.curBet = buf:readInt()
        self.totalBet = buf:readInt()
        self.banker = buf:readChar()
        self.smallChair = buf:readChar()
        self.bigChair = buf:readChar()
        self.data = {}
        local dataSize = buf:readShort()
        for i = 0, dataSize - 1 do
            self.data[i] = _gamePublic.stInitData:new()
            self.data[i].chair = buf:readChar()
            self.data[i].bet = buf:readInt()
            self.data[i].status = buf:readInt()
            self.data[i].handCards = {}
            local cardSize = buf:readShort()
            for j = 0, cardSize - 1 do
                self.data[i].handCards[j] = _gamePublic.stCard:new()
                self.data[i].handCards[j].par = buf:readChar()
                self.data[i].handCards[j].color = buf:readChar()
            end
        end
        self.TableCards = {}
        local cardsSize = buf:readShort()
        for i = 0, cardsSize - 1 do
            self.TableCards[i] = _gamePublic.stCard:new()
            self.TableCards[i].par = buf:readChar()
            self.TableCards[i].color = buf:readChar()
        end
        self.SplitBet = {}
        local mSize = buf:readShort()
        for i = 0, mSize - 1 do
            local key = buf:readByte()
            local value = buf:readInt()
            self.SplitBet[key] = value
        end
    end
    -----------------------------------------------------------------------------------

    -----------------------------------------------------------------------------------
    self.SC_BET = class("SC_BET", packBody)
    function self.SC_BET:ctor(code, uid, pnum, mapid, syncid)
        self.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
        self.name = "SC_BET"
    end
    function self.SC_BET:bufferOut(buf)
        self.bet = buf:readInt()
        self.banker = buf:readChar()
        self.smallChair = buf:readChar()
        self.bigChair = buf:readChar()
    end
    -----------------------------------------------------------------------------------

    -----------------------------------------------------------------------------------
    self.SC_SPLIT_BET_DATA = class("SC_SPLIT_BET_DATA", packBody)
    function self.SC_SPLIT_BET_DATA:ctor(code, uid, pnum, mapid, syncid)
        self.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
        self.name = "SC_SPLIT_BET_DATA"
    end
    function self.SC_SPLIT_BET_DATA:bufferOut(buf)
        self.SplitBet = {}
        local mSize = buf:readShort()
        for i = 0, mSize - 1 do
            local key = buf:readByte()
            local value = buf:readInt()
            self.SplitBet[key] = value
        end
    end
    -----------------------------------------------------------------------------------

    -----------------------------------------------------------------------------------
    self.CS_POKE_OP_ACK = class("CS_POKE_OP_ACK", packBody)
    function self.CS_POKE_OP_ACK:ctor(code, uid, pnum, mapid, syncid)
        self.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
        self.name = "CS_POKE_OP_ACK"
    end
    function self.CS_POKE_OP_ACK:bufferIn(ack)
        local buf = self.super.bufferIn(self)
        buf:writeInt(ack.op)
        buf:writeInt(ack.ext)
        buf:writeInt(ack.serialTick)
        return buf
    end
    -----------------------------------------------------------------------------------

    -----------------------------------------------------------------------------------
    self.CS_SELCARDS = class("CS_SELCARDS", packBody)
    function self.CS_SELCARDS:ctor(code, uid, pnum, mapid, syncid)
        self.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
        self.name = "CS_SELCARDS"
    end
    function self.CS_SELCARDS:bufferIn(ack)
        local buf = self.super.bufferIn(self)
        local cardsCount = table.nums(ack.cards)
        buf:writeShort(cardsCount)
        for i = 0, cardsCount - 1 do
            buf:writeChar(ack.cards[i].par)
            buf:writeChar(ack.cards[i].color)
        end
        return buf
    end
    -----------------------------------------------------------------------------------
end

return GameProtocol
