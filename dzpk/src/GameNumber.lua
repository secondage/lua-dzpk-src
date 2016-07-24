--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/11/6
-- Time: 9:12
-- To change this template use File | Settings | File Templates.
--

local GameNumber = class("GameNumber")
function GameNumber:ctor()
    self.gameNumber = {
        "SC_POKE_OP_REQ_P",
        "SC_POKE_OP_NOT_P",
        "SC_POKE_HAND_NOT_P",
        "SC_POKE_DEAL_P",
        "SC_GAME_RESULT_P",
        "SC_INIT_DATA_P",
        "SC_BET_P",
        "SC_SPLIT_BET_P",
    }
    self.gameNumberReq = {
        "CS_POKE_OP_ACK_P",
        "CS_SELCARDS_P",
    }
end

function GameNumber:appendMiniGameProNumberReq(target, startCodeReq)
    local i = startCodeReq
    local function incr(name)
        i = i + 1
        target.protcolNameOfMiniGame[i] = name
        return i
    end

    target.CS_POKE_OP_ACK_P = incr(self.gameNumberReq[1])
    target.CS_SELCARDS_P = incr(self.gameNumberReq[2])
    return i - startCodeReq
end

function GameNumber:appendMiniGameProNumber(target, startCode)
    local i = startCode
    local function incr(name)
        i = i + 1
        target.protcolNameOfMiniGame[i] = name
        return i
    end

    target.SC_POKE_OP_REQ_P = incr(self.gameNumber[1])
    target.SC_POKE_OP_NOT_P = incr(self.gameNumber[2])
    target.SC_POKE_HAND_NOT_P = incr(self.gameNumber[3])
    target.SC_POKE_DEAL_P = incr(self.gameNumber[4])
    target.SC_GAME_RESULT_P = incr(self.gameNumber[5])
    target.SC_INIT_DATA_P = incr(self.gameNumber[6])
    target.SC_BET_P = incr(self.gameNumber[7])
    target.SC_SPLIT_BET_P = incr(self.gameNumber[8])


    return i - startCode
end

return GameNumber

