--------
----存储 服务器发来的游戏数据, 以及数据加工
----------

local GameModel = class("GameModel")

local _mahjOP = nil
local _gamePublic = nil
function GameModel:ctor()
    print("GameModel:ctor()")
    self.SC_POKE_DEAL = {}
    self.SC_POKE_OP_NOT = {}
    self.SC_POKE_OP_REQ = {}
    self.SC_GAME_RESULT = {}
    self.SC_INIT_DATA = {}
    self.SC_BET = {}
    self.SC_SPLIT_BET_DATA = {}
    self.SC_POKE_HAND_NOT = {}
    _gamePublic = app.gamePublic

end

function GameModel:resetData()

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

-----------------------------------------------------
function GameModel:setSC_POKE_DEAL(ack)
    self.SC_POKE_DEAL = ack
    app.gameLayer.eventProtocol:dispatchEvent({ name = "SC_POKE_DEAL", data = ack })
end
-----------------------------------------------------

-----------------------------------------------------
function GameModel:setSC_POKE_OP_NOT(ack)
    self.SC_POKE_OP_NOT = ack
   -- dump(ack)
    local chair = S2CChair(ack.chair)
    if _gamePublic:valid_chair(chair) == true then
        app.gameLayer.eventProtocol:dispatchEvent({ name = "SC_POKE_OP_NOT", data = ack })
    end
end
-----------------------------------------------------

-----------------------------------------------------
function GameModel:setSC_POKE_DEAL( ack )
    self.SC_POKE_DEAL = ack
    ----如需要进行数据加工后，再转发
    app.gameLayer.eventProtocol:dispatchEvent({ name = "SC_POKE_DEAL", data = ack })
end
-----------------------------------------------------
-----------------------------------------------------
function GameModel:setSC_INIT_DATA(ack)
    self.SC_INIT_DATA = ack
    app.gameLayer.eventProtocol:dispatchEvent({ name = "SC_INIT_DATA", data = ack })
end

function GameModel:setSC_GAME_RESULT(ack)
    self.SC_GAME_RESULT = ack
    app.gameLayer.eventProtocol:dispatchEvent({ name = "SC_GAME_RESULT", data = ack })
end

function GameModel:setSC_BET(ack)
    self.SC_BET = ack
   -- dump(ack)
    app.gameLayer.eventProtocol:dispatchEvent({ name = "SC_BET", data = ack })
end

function GameModel:setSC_POKE_OP_REQ(ack)
    self.SC_POKE_OP_REQ = ack
    app.gameLayer.eventProtocol:dispatchEvent({ name = "SC_POKE_OP_REQ", data = ack })
end

function GameModel:setSC_SPLIT_BET_DATA(ack)
    self.SC_SPLIT_BET_DATA = ack
    
    app.gameLayer.eventProtocol:dispatchEvent({ name = "SC_SPLIT_BET_DATA", data = ack })
end

function GameModel:setSC_POKE_HAND_NOT(ack)
    self.SC_POKE_HAND_NOT = ack
    app.gameLayer.eventProtocol:dispatchEvent({ name = "SC_POKE_HAND_NOT", data = ack })
end
-- -------------------------------------------------------------------------------
-- test
function GameModel:test_SC_POKE_DEAL()
    local ack = {}
    ack.round = 1
    ack.chair = 0
    ack.cards = {}
    local card = {par = 5, color = 2 }

    for i = 0, 1 do
        ack.cards[i] = card
    end

    ack.allChairs = {}
    ack.allChairs[0] = 0
    ack.allChairs[1] = 1
    self.SC_POKE_DEAL = ack
    app.gameLayer.eventProtocol:dispatchEvent({ name = "SC_POKE_DEAL", data = ack })
end

function GameModel:test_SC_POKE_OP_NOT()
    local ack = {}
    ack.chair = -1
    ack.handCards = {}
    local card = {par = 5, color = 2 }

    for i = 1, 27 do
        ack.handCards[i] = card
    end

    local card2 = {par = 5, color = 3 }
    ack.outCards = {}
    for i = 1, 5 do
        ack.outCards[i] = card2
    end

    ack.cardType = _gamePublic.stCardType:new()
    ack.cardType.type = 1
    ack.cardType.par = 1
    ack.cardType.num = 1

    self.SC_POKE_OP_NOT = ack
    app.gameLayer.eventProtocol:dispatchEvent({ name = "SC_POKE_OP_NOT", data = ack })
end

function GameModel:test_SC_GAME_RESULT()
    local ack = {}
    ack.overA = 2
    ack.snowType = 4
    ack.Result = {}
    for i = 0, 3 do
        ack.Result[i] = {}
        ack.Result[i].chair = i
        ack.Result[i].score = 30
        ack.Result[i].money = 50
        ack.Result[i].ten = 2
        ack.Result[i].order = i
        ack.Result[i].catchScore = 70
    end
    self.SC_GAME_RESULT = ack
    app.gameLayer.eventProtocol:dispatchEvent({ name = "SC_GAME_RESULT", data = ack })
end
return GameModel