--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/8/18
-- Time: 15:18
-- To change this template use File | Settings | File Templates.
--

local packBody = require "data.packBody"
local CofferLogic = class("CofferLogic")

function CofferLogic:procMsgs(socket, buf, opCode)
    local msgProc = self.cofferProcs["proc_" .. (cc.protocolNumber:getProtocolName(opCode) or "")]

    if msgProc ~= nil then
        printf("This is a coffer message.\n")
        msgProc(buf)
        return true
    else
        return false
    end
end

function CofferLogic:sendReqLobby(pack)
    cc.msgHandler.socketLobby:send(pack)
end

function CofferLogic:ctor()
    self.cofferProcs = {}

    --保险箱数据
    function self.cofferProcs.proc_SC_BACKDATA_ACK_P(buf)
        local data = wnet.stBankData.new()
        data:bufferOut(buf)
        local userData = cc.dataMgr.lobbyUserData.lobbyUser
        userData.cofferEnd = data.cofferEnd
        userData.cofferstate = data.cofferState
        userData.gameCurrency = data.gameCurrency
        userData.cofferCurrency = data.cofferCurrency
        userData.goldCurrency = data.goldCurrency
        userData.isHaveAdvPasswd = data.isHaveAdvPasswd

        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "USERDATA_CHANGED", data = data })

    end

    --保险箱操作结果
    function self.cofferProcs.proc_SC_COFFER_OP_ACK_P(buf)
        local data = wnet.SC_COFFER_OP_ACK.new()
        data:bufferOut(buf)

        if data.cRet == 0 then
            CofferLogic:reqGetBankData()
        end

        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "SC_COFFER_OP_ACK_P", data = data })

    end

    --保险箱续费结果
    function self.cofferProcs.proc_SC_COFFER_RENEWALS_ACK_P(buf)
        local data = wnet.SC_COFFER_RENEWALS_ACK.new()
        data:bufferOut(buf)

        if data.cRet == 0 then
            CofferLogic:reqGetBankData()
        end
        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "SC_COFFER_RENEWALS_ACK_P", data = data })

    end

    --二级密码验证结果
    function self.cofferProcs.proc_PL_PHONE_LC_CHECKSECONDPASSWORD_ACK_P(buf)
        local data = wnet.PL_PHONE_LC_CHECKSECONDPASSWORD.new()
        data:bufferOut(buf)
        print("proc_PL_PHONE_LC_CHECKSECONDPASSWORD_ACK_P, result = "..data.nRet)
        if data.nRet == 0 then
            CofferLogic:reqGetBankData()
        end
        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "PL_PHONE_LC_CHECKSECONDPASSWORD_ACK_P", data = data })
    end
end

function CofferLogic:reqGetBankData()
    local data = packBody.new(cc.protocolNumber.CS_BANKDATA_REQ_P, cc.dataMgr.lobbyLoginData.userID, 0, 0, 0)
    local pack = data:bufferIn():getPack()
    CofferLogic:sendReqLobby(pack)
end

function CofferLogic:reqCofferOp(opType, money, strSecondPasswd)
    local md5 = MD5:create()
    strSecondPasswd = md5:GetDiyMD5(strSecondPasswd)
    local data = wnet.CS_COFFER_OP_REQ.new(cc.protocolNumber.CS_COFFER_OP_REQ_P, cc.dataMgr.lobbyLoginData.userID)
    local pack = data:bufferIn(opType, money, strSecondPasswd):getPack()
    CofferLogic:sendReqLobby(pack)
end

function CofferLogic:reqCofferRenewals(cMonth, cPayType, strSecondPasswd)
    local md5 = MD5:create()
    strSecondPasswd = md5:GetDiyMD5(strSecondPasswd)
    local data = wnet.CS_COFFER_RENEWALS_REQ.new(cc.protocolNumber.CS_COFFER_RENEWALS_REQ_P, cc.dataMgr.lobbyLoginData.userID)
    local pack = data:bufferIn(cMonth, cPayType, strSecondPasswd):getPack()
    CofferLogic:sendReqLobby(pack)
end

function CofferLogic:reqCheckSePsw(strSePsw)
    local md5 = MD5:create()
    strSePsw = md5:GetDiyMD5(strSePsw)
    local data = wnet.PL_PHONE_CL_CHECKSECONDPASSWORD.new(cc.protocolNumber.PL_PHONE_CL_CHECKSECONDPASSWORD_REQ_P, cc.dataMgr.lobbyLoginData.userID)
    local pack = data:bufferIn(strSePsw):getPack()
    CofferLogic:sendReqLobby(pack)
end

return CofferLogic

