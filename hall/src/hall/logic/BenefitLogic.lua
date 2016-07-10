--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/9/2
-- Time: 10:06
-- To change this template use File | Settings | File Templates.
--
local strBenefitConfigUrl = "http://www.flgame.net:85/benefit.json"
if clientConfig.platform == "FL_GAME_DEBUG" or clientConfig.platform == "FL_GAME_RELEASE" then
    strBenefitConfigUrl = clientConfig.homePage..":85/benefit.json"
else
    strBenefitConfigUrl = clientConfig.homePage..":84/benefit.json"
end

local network = require "framework.network"
local json = require "framework.json"
local packBody = require "data.packBody"

local BenefitLogic = class("BenefitLogic")

function BenefitLogic:ctor()
    self.benefitProcs = {}
    bGuidShown = false

    self.taskInfoList = {}

    function self.benefitProcs.proc_LC_TASK_TASKINFOLIST_ACK_P(buf)
        if app.isAccessAppleStore == 0 then
            return
        end
        print("proc_LC_TASK_TASKINFOLIST_ACK_P")
        local data = wnet.GC_TASK_TASKINFOLIST.new()
        data:bufferOut(buf)
        for i = 1, #data.singleTaskInfo do
            local taskInfo = data.singleTaskInfo[i]
            self.taskInfoList[taskInfo.taskId] = taskInfo
        end
        self:initTaskList()
        if clientConfig.regPresent then
            self:reqRegPresentTask()
        end
    end

    function self.benefitProcs.proc_LC_TASK_WRITETASKOPERINFO_ACK_P(buf)
        local data = wnet.GC_TASK_WRITETASKOPERINFO.new()
        data:bufferOut(buf)
        local benefitTaskList = cc.dataMgr.benefitTaskList
        local taskInfo = benefitTaskList[data.taskId]
        if taskInfo ~= nil and data.taskType == nil and taskInfo.taskStatus == 1 then
            self:reqGetBenefitAward(taskInfo.taskId)
            return
        end

        if benefitTaskList[data.taskId] == nil then return end

        benefitTaskList[data.taskId].taskCurProcess = data.taskCurProcess
        benefitTaskList[data.taskId].taskStatus = data.taskStatus

        app.reminderLogic:upDateBenefitReminder()

        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "TASK_INFO_UPDATED", data = data })
    end

    function self.benefitProcs.proc_LC_TASK_GETAWARD_ACK_P(buf)
        local data = wnet.GC_TASK_GETAWARD.new()
        data:bufferOut(buf)
        local benefitTaskList = cc.dataMgr.benefitTaskList
        if data.nResult == 1 then
            local taskInfo = benefitTaskList[data.taskId]
            if taskInfo ~= nil and taskInfo.cyclical then
                taskInfo.taskCurProcess = 0
                taskInfo.taskStatus = 0
            else
                benefitTaskList[data.taskId] = nil
            end
        end

        app.reminderLogic:upDateBenefitReminder()

        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "LC_TASK_GETAWARD_ACK_P", data = data })
    end

    function self.benefitProcs.proc_LC_TASK_NEWTASK_ACK_P(buf)
        local data = wnet.GC_NEWTASK_INFO.new()
        data:bufferOut(buf)
        local benefitTaskList = cc.dataMgr.benefitTaskList
        local taskConfig = cc.dataMgr.benefitConfigData
        local taskData = taskConfig[data.taskId]
        local lockedTaskList = cc.dataMgr.benefitLockedTaskList
        lockedTaskList[data.taskId] = nil
        benefitTaskList[data.taskId] = taskData or {}

        benefitTaskList[data.taskId].taskCurProcess = 0
        benefitTaskList[data.taskId].taskStatus = 0

        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "TASK_INFO_UPDATED", data = data })
    end

    function self.benefitProcs.proc_LC_GET_INVITERECORD_ACK_P(buf)
        local data = wnet.LC_GET_INVITERECORD_VEC.new()
        data:bufferOut(buf)
        local invitingRecord = cc.dataMgr.invitingRecord
        for i = 1, #data.inviteRecord do
            invitingRecord[#invitingRecord + 1] = data.inviteRecord[i]
        end
        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "LC_GET_INVITERECORD_ACK_P", data = data })
    end

    function self.benefitProcs.proc_DC_GET_INVITETASK_STATUS_ACK_P(buf)
        local data = wnet.DC_GET_INVITETASK_STATUS.new()
        data:bufferOut(buf)
        local benefitTaskList = cc.dataMgr.benefitTaskList
        for i = 1, #data.inviteTaskStatusInfo do
            benefitTaskList[data.inviteTaskStatusInfo[i].taskId].taskCurProcess = 0
            benefitTaskList[data.inviteTaskStatusInfo[i].taskId].taskStatus = data.inviteTaskStatusInfo[i].finished
        end
        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "TASK_INFO_UPDATED", data = data })
        app.reminderLogic:upDateBenefitReminder()
    end
end

function BenefitLogic:initTaskList()
    local benefitData = cc.dataMgr.benefitConfigData
    if next(benefitData) == nil then
        print("benefit config not initialnized")
        return
    end
    local benefitTaskList = cc.dataMgr.benefitTaskList
    local lockedTaskList = cc.dataMgr.benefitLockedTaskList
    local bGuid = false
    local bGuidShown = cc.UserDefault:getInstance():getBoolForKey("benefit_guide_"..cc.dataMgr.lobbyLoginData.userID, false)
    local bShow = false
    local keyWords = {}
    for key, value in pairs(self.taskInfoList) do
        local taskInfo = value
        print("taskID:"..taskInfo.taskId)
        --app.toast.show(i.."taskID:"..taskInfo.taskId)
        local taskData = benefitData[taskInfo.taskId]
        if taskData ~= nil and taskData.award == "" then
            if taskInfo.taskStatus == 1 then
                self:reqGetBenefitAward(taskInfo.taskId)
            end
        elseif taskInfo.taskStatus ~= 0 and taskInfo.taskStatus ~= 1 then
            --do nothing
        elseif taskData ~= nil then
            if string.find(taskData.taskText[1], "话费礼包") ~= nil and taskInfo.taskStatus ~= 1 and
                    not cc.dataMgr.guestLogin then
                --话费礼包只在正式账号登录可领奖时才显示
                --do nothing
            else
                benefitTaskList[taskInfo.taskId] = taskData
                benefitTaskList[taskInfo.taskId].taskStatus = taskInfo.taskStatus
                benefitTaskList[taskInfo.taskId].taskCurProcess = taskInfo.taskCurProcess
                benefitTaskList[taskInfo.taskId].vecAwardShop = taskInfo.vecAwardShop
                benefitTaskList[taskInfo.taskId].vecCurrencyInfo = taskInfo.vecCurrencyInfo
                local nextId = benefitTaskList[taskInfo.taskId].nextTaskId
                while benefitData[nextId] ~= nil do
                    lockedTaskList[nextId] = benefitData[nextId]
                    nextId = benefitData[nextId].nextTaskId
                end
                if string.find(taskData.taskText[1], "新手礼包1") ~= nil then
                    bGuid = true
                end
                if string.find(taskData.taskText[2], "分享") ~= nil and taskInfo.taskStatus == 0 then
                    bShow = true
                    keyWords[#keyWords + 1] = "分享"
                end
            end
        end
    end
    app.reminderLogic:upDateBenefitReminder()

    if not cc.dataMgr.reconnected then
        if bShow and (not bGuid or bGuidShown) and display:getRunningScene().root and not cc.dataMgr.guiderFlag["newbie_guide"] then
            display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "SHOW_BENEFIT_TASK", data = keyWords })
        end
        if bGuid then
            cc.dataMgr.guiderFlag["benefit_guide"] = bGuid and not cc.UserDefault:getInstance():getBoolForKey("benefit_guide_"..cc.dataMgr.lobbyLoginData.userID, false)
            if not cc.dataMgr.guiderFlag["newbie_guide"] then
                display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "BENEFIT_GUIDE" })
            end
        end
    end
    --display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "BENEFIT_GUIDE" })
    self.taskInfoList = {}
end

function BenefitLogic:procMsgs(socket, buf, opCode)
    local msgProc = self.benefitProcs["proc_" .. (cc.protocolNumber:getProtocolName(opCode) or "")]

    if msgProc ~= nil then
        printf("This is a benefit message.\n")
        msgProc(buf)
        return true
    else
        return false
    end
end

function BenefitLogic:sendReqLobby(pack)
    cc.msgHandler.socketLobby:send(pack)
end

function BenefitLogic:reqGetInvitingRecord()
    cc.dataMgr.invitingRecord = {}
    local data = packBody.new(cc.protocolNumber.CL_GET_INVITERECORD_REQ_P, cc.dataMgr.lobbyLoginData.userID, 0, 0, 0)
    local pack = data:bufferIn():getPack()
    self:sendReqLobby(pack)
end

function BenefitLogic:reqGetInvitingProgress()
    local benefitTaskList = cc.dataMgr.benefitTaskList or {}
    local inviteTaskId = {}
    for key, value in pairs(benefitTaskList) do
        if value.taskType == "invite" then
            inviteTaskId[#inviteTaskId + 1] = value.taskId
        end
    end
    local data = wnet.CL_GET_INVITETASK_STATUS.new(cc.protocolNumber.CL_GET_INVITETASK_STATUS_REQ_P, cc.dataMgr.lobbyLoginData.userID)
    local pack = data:bufferIn(inviteTaskId):getPack()
    self:sendReqLobby(pack)
end

function BenefitLogic:reqGetBenefitAward(taskId)
    local data = wnet.CG_TASK_GETAWARD.new(cc.protocolNumber.CL_TASK_GETAWARD_REQ_P, cc.dataMgr.lobbyLoginData.userID, 0, 0, 0)
    local pack = data:bufferIn(cc.dataMgr.lobbyLoginData.userID, taskId):getPack()
    self:sendReqLobby(pack)
end

function BenefitLogic:reqWeChatShare()
    local data = packBody.new(cc.protocolNumber.CL_WECHATSHARE_REQ_P, cc.dataMgr.lobbyLoginData.userID)
    local pack = data:bufferIn():getPack()
    self:sendReqLobby(pack)
end

function BenefitLogic:reqAppStorMark()
    local data = packBody.new(cc.protocolNumber.PL_PHONE_CL_JUDGEFINISHEDTASK_REQ_P, cc.dataMgr.lobbyLoginData.userID)
    local pack = data:bufferIn():getPack()
    self:sendReqLobby(pack)
end

function BenefitLogic:reqRegPresentTask()
    local data = wnet.PL_PHONE_CL_REGSUCESS.new(cc.protocolNumber.PL_PHONE_CL_LOGINSUCESS_FINISHEDTASK_REQ_P, cc.dataMgr.lobbyLoginData.userID)
    local pack = data:bufferIn(cc.dataMgr.lobbyLoginData.userID, -1):getPack()
    self:sendReqLobby(pack)
end

function BenefitLogic:reqGetBenefitListConfig()
    print("reqGetBenefitListConfig")

    local function rebuildBenefitData(data)
        local ret = {}
        ret.taskId = data.taskId
        ret.nextTaskId = data.nextTaskId
        ret.taskNumber = data.taskNumber
        ret.icon = data.icon
        ret.tagImg = data.tagImg
        local strAward = ""..data.currencyNum
        if data.currencyType == 0 then
            ret.award = strAward.."游戏豆"
        elseif data.currencyType == 1 then
            ret.award = strAward.."风雷币"
        elseif data.currencyType == 2 then
            ret.award = strAward.."元宝"
        elseif data.currencyType == 3 then
            ret.award = strAward.."元话费"
        elseif data.currencyType == 4 then
            ret.award = ""
        end

        ret.cyclical = data.taskType == 3

        --根据文字描述拆分出标题、描述、详细描述，区分类型
        local strTask = data.taskText
        ret.taskText = {}
        local i = 0
        while strTask ~= nil do
            local iBegin, iEnd = strTask.find(strTask, "_")
            i = i + 1
            if iBegin ~= nil then
                ret.taskText[i] = string.sub(strTask, 1, iBegin - 1)
                strTask = string.sub(strTask, iEnd + 1, -1)
            else
                ret.taskText[i] = strTask
                strTask = nil
            end
        end
        if ret.taskText[1] ~= nil then
            if string.find(ret.taskText[1], "分享") ~= nil then
                ret.taskType = "share"
            elseif string.find(ret.taskText[1], "邀请") ~= nil then
                ret.taskType = "invite"
            elseif string.find(ret.taskText[1], "新手") ~= nil then
                ret.taskType = "newbie"
            elseif string.find(ret.taskText[1], "评价") ~= nil then
                ret.taskType = "mark"
            end
        end
        return ret
    end

    local function getLastTaskID(dataList)
        for key, value in pairs(dataList) do
            if value.nextTaskId ~= nil then
                print("task:"..value.nextTaskId.." lastTask:"..value.taskId)
                dataList[value.nextTaskId].lastTaskId = value.taskId
            end
        end
    end

    local function onBenefitConfigReceived(event)
        if event == nil then
            printf("event is nil")
            return
        end

       -- printf("event.name :"..event.name)
        local ok = (event.name == "completed")
        local request = event.request

        if not ok then
            -- 请求失败，显示错误代码和错误消息
         --   print(request:getErrorCode(), request:getErrorMessage())
            return
        end

        local code = request:getResponseStatusCode()
        if code ~= 200 then
            -- 请求结束，但没有返回 200 响应代码
          --  print(code)
            return
        end

        -- 请求成功，显示服务端返回的内容
        local strResponse = request:getResponseString()
        --print(strResponse)
        --local data = cc.dataMgr.benefitData
        local netData  = json.decode(strResponse) or {}
        local benefitData = {}
        for key, value in pairs(netData) do
            benefitData[value.taskId] = rebuildBenefitData(value)
        end
        getLastTaskID(benefitData)
        --[[
        for key, value in pairs(benefitData) do
            print(key.."------------------------")
            print(value.lastTaskId)
            print(value.award)
            print(value.taskType)
            print(value.icon)
            for i = 1, #value.taskText do
                print(value.taskText[i])
            end
            print("------------------------------")
        end
        --]]
        cc.dataMgr.benefitConfigData = benefitData

        self:initTaskList()
    end

    local request = network.createHTTPRequest(onBenefitConfigReceived, strBenefitConfigUrl, "GET")
    request:start()
   -- app.holdOn.hide()
    print("http request send")
end

return BenefitLogic

