--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/8/19
-- Time: 15:06
-- To change this template use File | Settings | File Templates.
--
require "framework.utils.bit"
local packBody = require "data.packBody"
local PhoneLogic = class("PhoneLogic")

function PhoneLogic:ctor()
    self.phoneProcs = {}

    --获取验证码
    function self.phoneProcs.proc_LC_PHONECODE_GET_VALIDATECODE_ACK_P(buf)
        local data = wnet.LC_PHONECODE_GET_VALIDATECODE_ACK.new();
        data:bufferOut(buf)
        printf("LC_PHONECODE_GET_VALIDATECODE_ACK_P result:"..data.nResult)
        printf("LC_PHONECODE_GET_VALIDATECODE_ACK_P valideCode:"..data.validCode)
        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "LC_PHONECODE_GET_VALIDATECODE_ACK_P", data = data })

    end

    --绑定手机号
    function self.phoneProcs.proc_SC_PHONECODEBIND_ACK_P(buf)
        local data = wnet.SC_PHONECODEBIND_ACK.new();
        data:bufferOut(buf)
        printf("SC_PHONE_BIND result:"..data.nResult)
        if data.nResult == wnet.Phone_Bind_Result.Phone_Bind_Result_Ok then
            PhoneLogic:reqPhoneCodeBindGetAward()
        end

        PhoneLogic:reqPhoneCodeBindResult()

        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "SC_PHONECODEBIND_ACK_P", data = data })

    end

    --解绑手机号
    function self.phoneProcs.proc_SC_REMOVEPHONEBIND_ACK_P(buf)
        local data = wnet.SC_PHONE_UNBIND.new()
        data:bufferOut(buf)
        printf("SC_PHONE_UNBIND result:"..data.ret)
        if data.ret == 0 then
            PhoneLogic:reqPhoneCodeBindResult()
        end

        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "SC_REMOVEPHONEBIND_ACK_P", data = data })

    end

    --绑定手机号检查手机号结果
    function self.phoneProcs.proc_SC_PHONEBIND_CHECK_PHONECODE_P(buf)
        local data = wnet.LC_CHECK_PHONECODE.new()
        data:bufferOut(buf)
        printf("LC_CHECK_PHONECODE result:"..data.nResult)
        if data.nResult == wnet.Phone_Reg_CheckPhoneCode_Result.Phone_Reg_CheckPhoneCode_Result_Ok then
            PhoneLogic:reqGetValidCode(data.strCode, wnet.Sms_Operator_Type.Sms_Operator_Type_BindPhoneCode, 1)
        else
            display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "SC_PHONEBIND_CHECK_PHONECODE_P", data = data })
        end

    end

    --手机号绑定状态
    function self.phoneProcs.proc_SC_GETPHONECODEBIND_RESULT_ACK_P(buf)
        local data = wnet.SC_GETPHONECODEBIND_RESULT.new()
        data:bufferOut(buf)
        printf("SC_GETPHONECODEBIND_RESULT nResult:"..data.nResult)
        printf("SC_GETPHONECODEBIND_RESULT strCode:"..data.strCode)
        if cc.dataMgr.userInfoMore == nil then cc.dataMgr.userInfoMore = {} end
        local userInfoMore = cc.dataMgr.userInfoMore
        userInfoMore.phoneBindState = data.nResult
        if bit.bor(data.nResult, wnet.Phone_CheckUser_BindPhone_Result.Phone_CheckUser_BindPhone_Result_Binded) ~= 0 then
            userInfoMore.strBindingPhone = data.strCode
        end

        print("cc.dataMgr.userInfoMore")
        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "SC_GETPHONECODEBIND_RESULT_ACK_P"})
        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "USERDATA_CHANGED", data = data })
    end

    --检查验证码
    function self.phoneProcs.proc_LC_CHECK_PHONEVALIDATECODE_ACK_P(buf)
        local data = wnet.LC_CHECK_PHONEVALIDATECODE_ACK.new()
        data:bufferOut(buf)
        print("LC_CHECK_PHONEVALIDATECODE_ACK nResult:"..data.nResult)
        print("LC_CHECK_PHONEVALIDATECODE_ACK smsOperType:"..data.smsOperType)
        if data.nResult == wnet.Phone_CheckPhoneValidateCode_Result.Phone_CheckPhoneValidateCode_Result_Ok then
            if data.smsOperType == wnet.Sms_Operator_Type.Sms_Operator_Type_BindPhoneCode then
                print("reqPhoneVind:"..data.strCode)
                PhoneLogic:reqPhoneBind(data.strCode)
            elseif data.smsOperType == wnet.Sms_Operator_Type.Sms_Operator_Type_RemoveBindPhoneCode then
                print("reqRemovePhoneBind:"..data.strCode)
                PhoneLogic:reqRemovePhoneBind(data.strCode)
            end
        else
            display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "LC_CHECK_PHONEVALIDATECODE_ACK_P", data = data })
        end
         display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "LC_CHECK_PHONEVALIDATECODE_ACK", data = data })
    end

    --领取绑定手机号奖励
    function self.phoneProcs.proc_SC_BIND_GETAWARD_ACK_P(buf)
        local data = wnet.SC_BIND_GETAWARD_ACK.new()
        data:bufferOut(buf)
        printf("SC_BIND_GETAWARD_ACK nResult:"..data.nResult)
        if data.nResult == 0 then
            local userData = cc.dataMgr.lobbyUserData.lobbyUser
            userData.gameCurrency = data.totalGameCurrency
        end

        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "SC_BIND_GETAWARD_ACK_P", data = data })
        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "USERDATA_CHANGED", data = data })

    end

    --开通手机号登录
    function self.phoneProcs.proc_SC_SETUSEPHONELOGIN_ACK_P(buf)
        local data = wnet.SC_SETUSEPHONELOGIN_ACK.new()
        data:bufferOut(buf)
        printf("SC_SETUSEPHONELOGIN_ACK nResult:"..data.nResult)
        if data.nResult == 0 then
            PhoneLogic:reqPhoneCodeBindResult()
        end
    end

    --取消手机号登录
    function self.phoneProcs.proc_SC_CACELUSERPHONELOGIN_ACK_P(buf)
        local data = wnet.SC_CACELUSERPHONELOGIN_ACK.new()
        data:bufferOut(buf)
        printf("SC_CACELUSERPHONELOGIN_ACK nResult:"..data.nResult)
        if data.nResult == 0 then
            PhoneLogic:reqPhoneCodeBindResult()
        end
    end
end

function PhoneLogic:procMsgs(socket, buf, opCode)
    local msgProc = self.phoneProcs["proc_" .. (cc.protocolNumber:getProtocolName(opCode) or "")]

    if msgProc ~= nil then
        printf("This is a individual message.\n")
        msgProc(buf)
        return true
    else
        return false
    end
end

--请求短信验证码
function PhoneLogic:reqGetValidCode(strPhone, smsOperType, startTimes)
    local data = wnet.LC_PHONECODE_GET_VALIDATECODE_REQ.new(cc.protocolNumber.CL_PHONECODE_GET_VALIDATECODE_REQ_P, cc.dataMgr.lobbyLoginData.userID)
    local pack = data:bufferIn(strPhone, smsOperType, startTimes):getPack()
    print("reqGetValidCode:"..strPhone.." "..smsOperType.." "..startTimes.." "..cc.protocolNumber.CL_PHONECODE_GET_VALIDATECODE_REQ_P)
    PhoneLogic:sendReqLobby(pack)
end

--绑定手机号
function PhoneLogic:reqPhoneBind(strPhone)
    local data = wnet.CL_CHECK_PHONECODE.new(cc.protocolNumber.CS_PHONECODEBIND_REQ_P, cc.dataMgr.lobbyLoginData.userID)
    local pack = data:bufferIn(strPhone):getPack()
    PhoneLogic:sendReqLobby(pack)
end

--解除手机号绑定
function PhoneLogic:reqRemovePhoneBind(strPhone)
    local data = wnet.CL_CHECK_PHONECODE.new(cc.protocolNumber.CS_REMOVEPHONEBIND_REQ_P, cc.dataMgr.lobbyLoginData.userID)
    local pack = data:bufferIn(strPhone):getPack()
    PhoneLogic:sendReqLobby(pack)
end

--绑定手机号检查手机号
function PhoneLogic:reqPhoneBindCheckPhonecode(strPhone)
    local data = wnet.CL_CHECK_PHONECODE.new(cc.protocolNumber.CS_PHONEBIND_CHECK_PHONECODE_P, cc.dataMgr.lobbyLoginData.userID)
    local pack = data:bufferIn(strPhone):getPack()
    PhoneLogic:sendReqLobby(pack)
end

--获取手机号绑定状态
function PhoneLogic:reqPhoneCodeBindResult()
    local data = packBody.new(cc.protocolNumber.CS_GETPHONECODEBIND_RESULT_REQ_P, cc.dataMgr.lobbyLoginData.userID, 0, 0, 0)
    local pack = data:bufferIn():getPack()
    PhoneLogic:sendReqLobby(pack)
end

--检查验证码
function PhoneLogic:reqCheckPhoneValidCode(strCode, validCode, smsOperType)
    local data = wnet.CL_CHECK_PHONEVALIDATECODE_REQ.new(cc.protocolNumber.CL_CHECK_PHONEVALIDATECODE_REQ_P, cc.dataMgr.lobbyLoginData.userID)
    local pack = data:bufferIn(strCode, validCode, smsOperType):getPack()
    PhoneLogic:sendReqLobby(pack)
end

--领取绑定手机号绑定
function PhoneLogic:reqPhoneCodeBindGetAward()
    local data = packBody.new(cc.protocolNumber.CS_BIND_GETAWARD_REQ_P, cc.dataMgr.lobbyLoginData.userID, 0, 0, 0)
    local pack = data:bufferIn():getPack()
    PhoneLogic:sendReqLobby(pack)
end

--开通手机号登录
function PhoneLogic:reqSetUsePhoneLogin()
    local userInfoMore = cc.dataMgr.userInfoMore
    local data = wnet.CL_CHECK_PHONECODE.new(cc.protocolNumber.CS_SETUSEPHONELOGIN_REQ_P, cc.dataMgr.lobbyLoginData.userID)
    local pack = data:bufferIn(userInfoMore.strBindingPhone):getPack()
    PhoneLogic:sendReqLobby(pack)
end

--取消手机号登录
function PhoneLogic:reqCancelUsePhoneLogin()
    local userInfoMore = cc.dataMgr.userInfoMore
    local data = wnet.CL_CHECK_PHONECODE.new(cc.protocolNumber.CS_CACELUSERPHONELOGIN_REQ_P, cc.dataMgr.lobbyLoginData.userID)
    local pack = data:bufferIn(userInfoMore.strBindingPhone):getPack()
    PhoneLogic:sendReqLobby(pack)
end

function PhoneLogic:sendReqLobby(pack)
    cc.msgHandler.socketLobby:send(pack)
end

return PhoneLogic