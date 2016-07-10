--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/8/14
-- Time: 13:48
-- To change this template use File | Settings | File Templates.
--
require "framework.utils.bit"
local packBody = require "data.packBody"
local IndividualLogic = class("IndividualLogic")

function IndividualLogic:ctor()
    self.individualProcs = {}

    --会员开通或延期
    function self.individualProcs.proc_SC_VIP_PAY_P(buf)
        local data = wnet.SC_VIP_PAY.new()
        data:bufferOut(buf)
        local userData = cc.dataMgr.lobbyUserData.lobbyUser
        if data.ret == 0 then
            local vipData = data.vipData
            userData.vipExp = vipData.vipExp
            userData.vipBegin = vipData.vipBegin
            userData.vipEnd = vipData.vipEnd
            userData.vipLevel = vipData.vipLevel
            userData.vipUp = vipData.vipUp

            userData.gameCurrency = data.money
            userData.goldCurrency = data.gold

            cc.dataMgr.bVip = true
        end
        printf("SC_VIP_PAY_P result:"..data.ret)
        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "SC_VIP_PAY_P", data = data })
        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "USERDATA_CHANGED", data = data })
    end

    --修改密码
    function self.individualProcs.proc_SC_CHANGE_PASSWD_P(buf)
        local data = wnet.SC_CHANGE_PASSWD.new()
        data:bufferOut(buf)
        printf("SC_CHANGE_PASSWD result:"..data.ret)
        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "SC_CHANGE_PASSWD_P", data = data })
    end

    --创建二级密码
    function self.individualProcs.proc_SC_CREATE_SEPASSWD_P(buf)
        local data = wnet.SC_CREATE_SEPASSWD.new()
        data:bufferOut(buf)
        printf("SC_CREATE_SEPASSWD result:"..data.ret)
        if data.ret == 0 then
            cc.dataMgr.lobbyUserData.lobbyUser.isHaveAdvPasswd = 1
        end
        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "SC_CREATE_SEPASSWD_P", data = data })
    end

    --修改二级密码
    function self.individualProcs.proc_SC_CHANGE_SEPWD_P(buf)
        local data = wnet.SC_CHANGE_SEPWD.new()
        data:bufferOut(buf)
        printf("SC_CHANGE_SEPWD result:"..data.ret)
        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "SC_CHANGE_SEPWD_P", data = data })
    end

    --修改性别、头像、昵称
    function self.individualProcs.proc_SC_CHANGE_NICKNAME_P(buf)
        local userData = cc.dataMgr.lobbyUserData.lobbyUser
        local data = wnet.SC_CHANGE_NICKNAME.new()
        data:bufferOut(buf)
        printf("SC_CHANGE_NICKNAME result:"..data.ret)
        if data.ret == wnet.eChangeNickName_Result.eChangeNickName_Ok then
            userData.icon = data.icon
            userData.gender = data.gender
            if data.nickName ~= "" then
                userData.strNickNamebuf = data.nickName
            end
        end
        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "SC_CHANGE_NICKNAME_P", data = data })
        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "USERDATA_CHANGED", data = data })
    end

    --低保信息
    function self.individualProcs.proc_GC_GETBASELIVEING_ACK_P(buf)
        local data = wnet.GC_GETBASELIVEING_ACK.new()
        data:bufferOut(buf)
        cc.dataMgr.baseLivingData = data
        if app.isAccessAppleStore ~= 0 then
            app.baseLivingProtocol:dispatchEvent({ name = "GC_GETBASELIVEING_ACK_P", data = data })
        end
    end

    --领取低保结果
    function self.individualProcs.proc_GC_GETBASELIVINGCURRENCY_ACK_P(buf)
        local data = wnet.GC_GETBASELIVINGCURRENCY_ACK.new()
        data:bufferOut(buf)
        local userData = cc.dataMgr.lobbyUserData.lobbyUser
        userData.gameCurrency = data.totalCurrency
        app.baseLivingProtocol:dispatchEvent({ name = "GC_GETBASELIVINGCURRENCY_ACK_P", data = data })
        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "USERDATA_CHANGED", data = data })
    end

    --玩家代币信息
    function self.individualProcs.proc_SC_LOGIN_TOKEN_P(buf)
        local data = wnet.SC_LOGIN_TOKEN.new()
        data:bufferOut(buf)
        if cc.dataMgr.userInfoMore == nil then cc.dataMgr.userInfoMore = {} end
        local userInfoMore = cc.dataMgr.userInfoMore
        userInfoMore.ingot = data.yuanbao
        print("cc.dataMgr.userInfoMore")
    end

    --游戏豆更新
    function self.individualProcs.proc_GC_TASK_UPDATE_GAMECURRENCY_P(buf)
        local data = wnet.TASK_UPDATE_GAMECURRENCY.new()
        data:bufferOut(buf)
        local userData = cc.dataMgr.lobbyUserData.lobbyUser
        userData.gameCurrency = data.gameCurrency
        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "USERDATA_CHANGED", data = data })
        print("gameCurrency updated:"..data.gameCurrency.l)
    end

    --更新元宝
    function self.individualProcs.proc_GC_TASK_UPDATE_YUANBAO_P(buf)
        local data = wnet.TASK_UPDATE_YUANBAO.new()
        data:bufferOut(buf)
        local userInfoMore = cc.dataMgr.userInfoMore
        userInfoMore.ingot = data.yuanBaoNum
        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "USERDATA_CHANGED", data = data })
        print("ingot updated:"..data.yuanBaoNum.l)
    end

    --绑定状态
    function self.individualProcs.proc_SC_TRAIL_TRANSFER_P(buf)
        local data = wnet.SC_TRAIL_TRANSFER.new()
        data:bufferOut(buf)

        if data.transferResult == 0 and clientConfig.regPresent then
            self:reqRegForPresent(cc.dataMgr.lobbyLoginData.userID)
        end

        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "SC_TRAIL_TRANSFER_P", data = data })
    end

end

function IndividualLogic:procMsgs(socket, buf, opCode)
    local msgProc = self.individualProcs["proc_" .. (cc.protocolNumber:getProtocolName(opCode) or "")]

    if msgProc ~= nil then
        print("This is a individual message.\n")
        print("proc_" .. (cc.protocolNumber:getProtocolName(opCode) or ""))
        msgProc(buf)
        return true
    else
        return false
    end
end

--开通vip或者续费
function IndividualLogic:reqVipPay(month, payType, opType, sePasswd)
    local md5 = MD5:create()
    sePasswd = md5:GetDiyMD5(sePasswd)
    local data = wnet.CS_VIP_PAY.new(cc.protocolNumber.CS_VIP_PAY_P, cc.dataMgr.lobbyLoginData.userID);
    local pack = data:bufferIn(month, payType, opType, sePasswd):getPack()
    IndividualLogic:sendReqLobby(pack)
end

--修改密码
function IndividualLogic:reqChangePsw(oldPsw, newPsw)
    local md5 = MD5:create()
    local oldPswMD5 = md5:ComplexMD5(oldPsw)
    local newPswMD5 = md5:ComplexMD5(newPsw)
    local data = wnet.CS_CHANGE_PASSWD.new(cc.protocolNumber.CS_CHANGE_PASSWD_P, cc.dataMgr.lobbyLoginData.userID)
    local pack = data:bufferIn(oldPswMD5, newPswMD5):getPack()
    IndividualLogic:sendReqLobby(pack)
end

--创建二级密码
function IndividualLogic:reqCreateSepsw(sePass, cardType, card, ask, asw)
    local md5 = MD5:create()
    sePass = md5:GetDiyMD5(sePass)
    local data = wnet.CS_CREATE_SEPASSWD.new(cc.protocolNumber.CS_CREATE_SEPASSWD_P, cc.dataMgr.lobbyLoginData.userID)
    local pack = data:bufferIn(sePass, cardType, card, ask, asw):getPack()
    IndividualLogic:sendReqLobby(pack)
end

--修改二级密码
function IndividualLogic:reqChangeSepsw(sePass, cardType, card, ask, asw)
    local md5 = MD5:create()
    sePass = md5:GetDiyMD5(sePass)
    local data = wnet.CS_CHANGE_SEPWD.new(cc.protocolNumber.CS_CHANGE_SEPWD_P, cc.dataMgr.lobbyLoginData.userID)
    local pack = data:bufferIn(sePass, cardType, card, ask, asw):getPack()
    IndividualLogic:sendReqLobby(pack)
end

--修改昵称、性别、头像
function IndividualLogic:reqChangeBasicInfo(gender, nickName, icon)
    local data = wnet.CS_CHANGE_NICKNAME.new(cc.protocolNumber.PL_PHONE_CS_CHANGE_NICKNAME_P, cc.dataMgr.lobbyLoginData.userID)
    local pack = data:bufferIn(gender, nickName, icon):getPack()
    IndividualLogic:sendReqLobby(pack)
end

--请求领取低保奖励
function IndividualLogic:reqGetBaseLiving()
    local data = packBody.new(cc.protocolNumber.CG_GETBASELIVINGCURRENCY_REQ_P, cc.dataMgr.lobbyLoginData.userID, 0, 0, 0)
    local pack = data:bufferIn():getPack()
    IndividualLogic:sendReqGame(pack)
end

--请求绑定账号
function IndividualLogic:reqAccountBind(account, psw, nickName)
    local md5 = MD5:create()
    psw = md5:ComplexMD5(psw)
    local userData = cc.dataMgr.lobbyUserData.lobbyUser
    local device = require("framework.device")
    local bindData = {
        strAccount = account,
        strNickName = nickName,
        strPasswd = psw,
        strRealName = "",
        strIDCard = "",
        strPhone = "",
        strEmail = "",
        strValid = "",
        gender = userData.gender,
        icon = userData.icon,
        strIP = "",
        strMac = device.getOpenUDID()
    }
    local data = wnet.CS_TRAIL_TRANSFER.new(cc.protocolNumber.CS_TRAIL_TRANSFER_P, cc.dataMgr.lobbyLoginData.userID, 0, 0, 0)
    local pack = data:bufferIn(bindData):getPack()
    IndividualLogic:sendReqLobby(pack)
end

function IndividualLogic:reqRegForPresent(userId)
    local data = wnet.PL_PHONE_CL_REGSUCESS.new(cc.protocolNumber.PL_PHONE_CL_REGSUCESS_REQ_P, userId, 0, 0, 0)
    local pack = data:bufferIn(userId, -1):getPack()
    if cc.msgHandler.socketLobby ~= nil then
        IndividualLogic:sendReqLobby(pack)
    elseif cc.msgHandler.socketLogin ~= nil then
        IndividualLogic:sendReqLogin(pack)
    end
end

function IndividualLogic:sendReqLobby(pack)
    cc.msgHandler.socketLobby:send(pack)
end

function IndividualLogic:sendReqLogin(pack)
    cc.msgHandler.socketLogin:send(pack)
end

function IndividualLogic:sendReqGame(pack)
    cc.msgHandler.socketGame:send(pack)
end


return IndividualLogic

