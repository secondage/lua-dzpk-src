--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/8/20
-- Time: 14:37
-- To change this template use File | Settings | File Templates.
--

local BulletinLogic = class("BulletinLogic")
local htmlParser = require("hall.logic.HtmlSimpleParser")

function BulletinLogic:procMsgs(socket, buf, opCode)
    local msgProc = self.bulletinProcs["proc_" .. (cc.protocolNumber:getProtocolName(opCode) or "")]

    if msgProc ~= nil then
        printf("This is a bulletin message.\n")
        msgProc(buf)
        return true
    else
        return false
    end
end

function BulletinLogic:ctor()
    self.bulletinList = {}
    self.bulletinProcs = {}

    function self.bulletinProcs.proc_FC_BULLETIN_INFO_P(buf)
        local data = wnet.BROADCAST_BULLETIN.new()
        data:bufferOut(buf)
        self:insertNewBulletin(data)
        print("proc_FC_BULLETIN_INFO_P:"..data.text)
        --app.bulletinProtocol:dispatchEvent({ name = "FC_BULLETIN_INFO_P", data = {} })
        --display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "FC_BULLETIN_INFO_P", data = {} })
    end
end

function BulletinLogic:insertNewBulletin(data)
    if self.bulletinList == nil then return end
    local count = 1
    for i = 1, #(self.bulletinList) do
        if self.bulletinList[i].pType < data.pType then
            break
        end
        count = count + 1
    end
    print("count"..count)
    table.insert(self.bulletinList, count, data)
    print("bulletinList size:"..#self.bulletinList)
    --直到列表中的所有消息都播放完，每两秒发送一次播放通知。跑马灯在播放过程中不会重复处理该通知
    local scheduler = require("framework.scheduler")
    local function dispatchBulletinEvent()
        if #self.bulletinList > 0 then
            app.bulletinProtocol:dispatchEvent({ name = "FC_BULLETIN_INFO_P", data = {} })
        else
            if self.tickScheduler ~= nil then
                scheduler.unscheduleGlobal(self.tickScheduler)
                self.tickScheduler = nil
                print("bulletin scheduler stopped")
            end
        end
    end
    if self.tickScheduler == nil then
        dispatchBulletinEvent()
        self.tickScheduler = scheduler.scheduleGlobal(dispatchBulletinEvent, 2)
    end
end

function BulletinLogic:getNextBulletinText()
    local strText = ""
    if self.bulletinList[#(self.bulletinList)] ~= nil then
        strText = self.bulletinList[#(self.bulletinList)].text
    end
    return strText
end

function BulletinLogic:removeHandledBulletin()
    table.remove(self.bulletinList)
end

function BulletinLogic:ClearBulletinList()
    self.bulletinList = {}
end

return BulletinLogic