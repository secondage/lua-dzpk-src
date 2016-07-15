--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/9/24
-- Time: 17:05
-- To change this template use File | Settings | File Templates.
--
local ReminderLogic = class("ReminderPonitLogic")

function ReminderLogic:upDateBenefitReminder()
    --签到
    local signInData = cc.dataMgr.signInData
    if signInData == nil then return end

    local bRemindSignIn = signInData.bSignIn == 0

    --任务
    local taskList = cc.dataMgr.benefitTaskList
    if taskList == nil then return end
    local bRemindTask = false
    for key, value in pairs(taskList) do
        if value.taskStatus == 1 then
            print("taskId = "..value.taskId)
            bRemindTask = true
            break
        end
    end

    --首冲奖励
    local awardInfo = cc.dataMgr.rechargeAwardInfo
    local bRemindRechargeAward = false
    if awardInfo ~= nil then
        bRemindRechargeAward = awardInfo.bCanGetAward ~= 0
    end

    if display:getRunningScene().root then
        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "UPDATE_REMINDER_POINT", data = {name = "benefit", bShow = bRemindTask or bRemindSignIn} })
        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "UPDATE_REMINDER_POINT", data = {name = "benefit_signIn", bShow = bRemindSignIn} })
        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "UPDATE_REMINDER_POINT", data = {name = "benefit_task", bShow = bRemindTask} })
        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "UPDATE_REMINDER_POINT", data = {name = "shop", bShow = bRemindRechargeAward} })
        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "UPDATE_REMINDER_POINT", data = {name = "rechargeAward", bShow = bRemindRechargeAward} })
    end
end

return ReminderLogic
