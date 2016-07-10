--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/8/26
-- Time: 9:17
-- To change this template use File | Settings | File Templates.
--

local packBady = require "data.packBody"

local SignInLogic = class("SignInLogic")

function SignInLogic:ctor()
    self.signInProcs = {}

    --初始化签到信息
    function self.signInProcs.proc_PL_PHONE_LC_INISIGNININFO_ACK_P(buf)
        if app.isAccessAppleStore == 0 then
            return
        end
        local data = wnet.PL_PHONE_LC_INISIGNININFO.new()
        data:bufferOut(buf)
        cc.dataMgr.signInData = data
        app.reminderLogic:upDateBenefitReminder()
        if not cc.dataMgr.reconnected then
            display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "PL_PHONE_LC_INISIGNININFO_ACK_P", data = data })
        end
    end

    --签到结果
    function self.signInProcs.proc_PL_PHONE_LC_SIGNIN_ACK_P(buf)
        local data = wnet.PL_PHONE_LC_SIGNIN.new()
        data:bufferOut(buf)
        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "PL_PHONE_LC_SIGNIN_ACK_P", data = data })
        if data.signResult == 0 then
            local signInData = cc.dataMgr.signInData
            signInData.signInDay = signInData.signInDay + 1
            signInData.bSignIn = 1
            local userData = cc.dataMgr.lobbyUserData.lobbyUser
            local vipData = data.vipData
            if vipData.vipLevel ~= 0 then
                userData.vipExp = vipData.vipExp
                userData.vipBegin = vipData.vipBegin
                userData.vipEnd = vipData.vipEnd
                userData.vipLevel = vipData.vipLevel
                userData.vipUp = vipData.vipUp
            end
        end
        app.reminderLogic:upDateBenefitReminder()
        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "SIGN_IN_UPDATE" })
        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "USERDATA_CHANGED"})
    end
end

function SignInLogic:procMsgs(socket, buf, opCode)
    local msgProc = self.signInProcs["proc_" .. (cc.protocolNumber:getProtocolName(opCode) or "")]

    if msgProc ~= nil then
        printf("This is a sign_in message.\n")
        msgProc(buf)
        return true
    else
        return false
    end
end

function SignInLogic:reqSignIn()
    local data = packBady.new(cc.protocolNumber.PL_PHONE_CL_SIGNIN_REQ_P, cc.dataMgr.lobbyLoginData.userID)
    local pack = data:bufferIn():getPack()
    SignInLogic:sendReqLobby(pack)
end

function SignInLogic:sendReqLobby(pack)
    cc.msgHandler.socketLobby:send(pack)
end

return SignInLogic

