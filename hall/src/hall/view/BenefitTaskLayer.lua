--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/9/11
-- Time: 11:38
-- To change this template use File | Settings | File Templates.
--
local ToastLayer = require("app.func.ToastLayer")
local BenefitTaskLayer = class("BenefitTaskLayer")
local targetPlatform = cc.Application:getInstance():getTargetPlatform()

function BenefitTaskLayer:init(currScene, parentLayer)
    print("init benefit task layer")
    self.currScene = currScene
    self.root = cc.CSLoader:createNode("Layers/BenefitTaskLayer.csb")
    parentLayer:addChild(self.root, 20)

    self:initWidgets()
    self:listenEvent()
    self:setVisible(false)
end

function BenefitTaskLayer:initWidgets()
    self.layTask = self.root:getChildByName("Panel_task")
    local layTask = self.layTask
    self.nodeTaskList = layTask:getChildByName("Node_taskList")
    self.nodeRecord = layTask:getChildByName("Node_invitingRecord")
    self.nodeRecord:setVisible(false)
    self.taskItem = self.nodeTaskList:getChildByName("Panel_taskItem")
    self.taskItem:setVisible(false)

    local btnReturn = self.nodeRecord:getChildByName("Button_return")
    --btnReturn:setPressedActionEnabled(true)
    btnReturn:addTouchEventListener(function(obj, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()

            self.nodeRecord:setVisible(false)
            self.nodeTaskList:setVisible(true)
        end
    end)
end

function BenefitTaskLayer:listenEvent()
    self.currScene.eventProtocol:addEventListener("TASK_INFO_UPDATED", function(event) --邀请任务进度
        print("TASK_INFO_UPDATED")
        self:fillDataToTaskList()
    end)

    self.currScene.eventProtocol:addEventListener("LC_GET_INVITERECORD_ACK_P", function(event) --邀请记录
        print("inviting record")
        self:fillDataToRecordList()
    end)

    self.currScene.eventProtocol:addEventListener("LC_TASK_GETAWARD_ACK_P", function(event) --领奖结果
        print("benefit get award result")
        local ret = event.data.nResult
        if ret == 1 then
            local taskData = cc.dataMgr.benefitConfigData[event.data.taskId]
            if taskData ~= nil and taskData.award ~= nil then
                if taskData.award ~= "" then
                    ToastLayer.show("获得奖励:"..taskData.award)
                end
                if string.find(taskData.award, "话费") ~= nil then
                    local function funcOk()
                        if targetPlatform ~= cc.PLATFORM_OS_WINDOWS then
                            local bridge = require("app.func.Bridge")
                            local bWeChatApiUseable = bridge.isWeChatInstalled() and bridge.isWeChatAPISupported()
                            if bWeChatApiUseable then
                                local bridge = require("app.func.Bridge")
                                local strTitle = "玩风雷游戏！赚话费！和家人朋友分享乐趣！"
                                local strContent = "玩风雷游戏！赚话费！和家人朋友分享乐趣！"
                                local strUrl = clientConfig.homePage.."/m/home"
                                bridge.shareToWeChat(1, strTitle, strContent, strUrl)
                            else
                                app.toast.show("抱歉，请先安装最新版本微信")
                            end
                        end
                    end
                    app.msgBox.showMsgBoxTwoBtn("话费将于次日到账，快将这个消息告诉你的好友吧！", funcOk)
                end
            end
        else
            ToastLayer.show("领取奖励失败")
        end
        self:fillDataToTaskList()
    end)

    self.currScene.eventProtocol:addEventListener("SHARE_TO_WECHAT_RESULT", function(event) --分享（邀请）发送结果
        local delay = cc.DelayTime:create(1);
        local function showResult()
            local data = event.data
            if data.result == "success" then
                if data.type == 0 then
                    ToastLayer.show("发送成功")
                elseif data.type == 1 then
                    ToastLayer.show("分享成功")
                    app.benefitLogic:reqWeChatShare()
                end
            else
                if data.type == 0 then
                    ToastLayer.show("发送失败")
                elseif data.type == 1 then
                    ToastLayer.show("分享失败")
                end
            end
            self:fillDataToTaskList()
        end
        if targetPlatform == cc.PLATFORM_OS_ANDROID then
            local fc = cc.CallFunc:create(showResult)
            self.root:runAction(cc.Sequence:create(delay, fc))
        else
            showResult()
        end
    end)

    self.currScene.eventProtocol:addEventListener("ON_RESUME", function(event) --后台唤醒
        if self.bOpenAppStore then
            app.benefitLogic:reqAppStorMark()
            self.bOpenAppStore = false
        end
    end)
end

function BenefitTaskLayer:setVisible(bShow, keywords)
    if bShow then
        if next(cc.dataMgr.benefitConfigData) == nil then
            print("config data is not inited")
            --app.holdOn.show("正在获取配置信息，请稍候……")
            app.benefitLogic:reqGetBenefitListConfig()
        end
        self.nodeTaskList:setVisible(true)
        self.nodeRecord:setVisible(false)
        if keywords == nil then
            keywords = {"分享"}
        end
        self:fillDataToUI(keywords)
    end

    self.root:setVisible(bShow)
end

function BenefitTaskLayer:fillDataToUI(keywords)
    self:fillDataToTaskList(keywords)
    self:fillDataToRecordList()
end

function BenefitTaskLayer:fillDataToRecordList()
    local invitingRecord = cc.dataMgr.invitingRecord
    local layRecord = self.nodeRecord:getChildByName("Panel_invitingRecord")
    local listRecord = layRecord:getChildByName("ListView_record")
    listRecord:removeAllItems()
    local listItem = layRecord:getChildByName("Panel_recordItem")
    listItem:setVisible(false)
    for i = 1, #invitingRecord do
        local item = listItem:clone()
        item:setVisible(true)
        local data = invitingRecord[i]

        local labelDate = item:getChildByName("Text_date")
        local date = os.date("*t", data.invitedatetime)
        local strDate = date.year.."年"..date.month.."月"..date.day.."日"
        labelDate:setString(strDate)
        local labelUserId = item:getChildByName("Text_account")
        labelUserId:setString(data.inviteuserid)
        local labelProcess = item:getChildByName("Text_process")
        local strStatus = "进行中"
        if data.finished ~= 0 then strStatus = "已完成" end
        labelProcess:setString(strStatus)
        listRecord:insertCustomItem(item, i - 1)
    end
end

function BenefitTaskLayer:fillDataToTaskList(keywords)
    print("fillDataToTaskList")
    local listTask = self.nodeTaskList:getChildByName("ListView_task")
    listTask:removeAllItems()
    local benefitTaskList = cc.dataMgr.benefitTaskList
    local lockedTaskList = cc.dataMgr.benefitLockedTaskList
    local count = 0
    for key, value in pairs(benefitTaskList) do
        count = count + 1
        self:initTaskItem(count, value, false, keywords)
    end

    local function pairsByKeys(t)
        local a = {}
        for n in pairs(t) do
            a[#a+1] = n
        end
        table.sort(a)
        local i = 0
        return function ()
            i = i + 1
            return a[i], t[a[i]]
        end
    end
    for key, value in pairsByKeys(lockedTaskList) do
        if value ~= nil then
            count = count + 1
            self:initTaskItem(count, value, true, keywords)
        end
    end
end

function BenefitTaskLayer:initTaskItem(index, taskInfo, bLocked, keywords)
    print("initTaskItem, index:"..index.." taskId:"..taskInfo.taskId)
    local listTask = self.nodeTaskList:getChildByName("ListView_task")
    local taskItem = self.taskItem:clone()
    local layBase = taskItem:getChildByName("Panel_baseInfo")
    local layExpand = taskItem:getChildByName("Panel_externInfo")
    local sizeBase = layBase:getContentSize()
    local sizeExpand = layExpand:getContentSize()
    local size = taskItem:getContentSize()
    --print("size.height:"..size.height.." sizeBase.height"..sizeBase.height)
    size.height = sizeBase.height
    layBase:setPosition(0, 0)
    taskItem:setContentSize(size)
    layExpand:setVisible(false)

    --图标
    local imgIcon = layBase:getChildByName("Image_icon")
    --print("icon:"..taskInfo.icon)
    if taskInfo.icon ~= nil then
        local strPath = "Resources/Benefit/"..taskInfo.icon
        local sp = cc.SpriteFrameCache:getInstance():getSpriteFrame(strPath)
        if sp ~= nil then
            imgIcon:loadTexture(strPath, 1)
        end
    end
    local imgTag = imgIcon:getChildByName("Image_tag")
    if taskInfo.tagImg ~= nil then
        local strPath = "Resources/Benefit/"..taskInfo.tagImg
        local sp = cc.SpriteFrameCache:getInstance():getSpriteFrame(strPath)
        if sp ~= nil then
            imgTag:loadTexture(strPath, 1)
        end
    else
        imgTag:setVisible(false)
    end
    local imgLock = imgIcon:getChildByName("Image_lock")
    imgLock:setVisible(bLocked)
    local imgTips = imgLock:getChildByName("Image_lockInfo")
    local function taskLocked(obj, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            imgTips:setVisible(not imgTips:isVisible())
            local delay = cc.DelayTime:create(5)
            local function fcHide()
                imgTips:setVisible(false)
            end
            imgTips:stopAllActions()
            imgTips:runAction(cc.Sequence:create(delay, cc.CallFunc:create(fcHide, {0}), nil))
        end
    end
    if bLocked then
        imgTips:setVisible(false)
        imgLock:addTouchEventListener(taskLocked)

        local labelTips = imgTips:getChildByName("Text_lockInfo")
        local lastInfo = cc.dataMgr.benefitConfigData[taskInfo.lastTaskId]
        labelTips:setString("完成"..lastInfo.taskText[1].."后解锁")
    end

    --任务名称
    local labelTaskName = layBase:getChildByName("Text_title")
    labelTaskName:setString(taskInfo.taskText[1])
    --任务内容
    local labelTaskContent = layBase:getChildByName("Text_content")
    labelTaskContent:setString(taskInfo.taskText[2])
    --任务奖励
    local labelAward = layBase:getChildByName("Text_award")
    labelAward:setString(taskInfo.award)
    --任务进度
    local labelProgress = layBase:getChildByName("Text_progress")
    if string.find(taskInfo.taskText[2], "邀请") ~= nil or string.find(taskInfo.taskText[1], "话费礼包") then
        if taskInfo.taskStatus == 0 or taskInfo.taskStatus == nil then
            labelProgress:setString("进行中")
        else
            labelProgress:setString("已完成")
        end
    else
        if taskInfo.taskCurProcess == nil then
            labelProgress:setString("0/"..taskInfo.taskNumber)
        else
            labelProgress:setString(taskInfo.taskCurProcess.."/"..taskInfo.taskNumber)
        end
    end
    --去完成按钮
    local btnGoto = layBase:getChildByName("Button_goToFinish")
    btnGoto:setPressedActionEnabled(true)
    btnGoto:setVisible(taskInfo.taskStatus == 0)
    local function gotoFinish(type)
        if type == 1 then
            --打开第一个游戏
            local _gamedb = require("app.func.GameDB")
            local gameInfo = _gamedb.readGameInfo()
            if #gameInfo == 0 then
                app.toast.show("尚未添加游戏")
                return
            end

            local game
            for i = 1, #gameInfo do
                local info = gameInfo[i]
                local isGameDownLoaded = _gamedb.checkIsDownloaded(info.gameId)
                if isGameDownLoaded == 2 then
                    game = info
                    break
                end
            end

            if game == nil then
                app.toast.show("请至少先安装一款游戏")
                return
            end

            local p = require(game.gameName..".src.CustomLayer").new()
            app.hallScene:hideAllPopLayers()
            if p:playCustomEvent(game.gameId) == 1 then
                app.holdOn.show("正在获取房间列表信息...", 0.5)
            end
        elseif type == 2 then
            if targetPlatform ~= cc.PLATFORM_OS_WINDOWS then
                local bridge = require("app.func.Bridge")
                local bWeChatApiUseable = bridge.isWeChatInstalled() and bridge.isWeChatAPISupported()
                if bWeChatApiUseable then
                    local bridge = require("app.func.Bridge")
                    local strTitle = "风雷游戏"
                    local strContent = "玩风雷游戏！赚话费！和家人朋友分享乐趣！"
                    local strUrl = clientConfig.homePage.."/m/Common/WechatInvite?inviteUserId="..cc.dataMgr.lobbyLoginData.userID.."&appName=phonehall2d"
                    bridge.shareToWeChat(0, strTitle, strContent, strUrl)
                else
                    app.toast.show("抱歉，请先安装最新版本微信")
                end
            end
        elseif type == 3 then
            if targetPlatform ~= cc.PLATFORM_OS_WINDOWS then
                local bridge = require("app.func.Bridge")
                local bWeChatApiUseable = bridge.isWeChatInstalled() and bridge.isWeChatAPISupported()
                if bWeChatApiUseable then
                    local bridge = require("app.func.Bridge")
                    local strTitle = "【风雷】游戏，咱东北人的特色棋牌，玩游戏！赚话费！和家人朋友分享乐趣！"
                    local strContent = "【风雷】游戏，咱东北人的特色棋牌，玩游戏！赚话费！和家人朋友分享乐趣！"
                    local strUrl = clientConfig.homePage.."/m/home"
                    bridge.shareToWeChat(1, strTitle, strContent, strUrl)
                else
                    app.toast.show("抱歉，请先安装最新版本微信")
                end
            else
                local data = {}
                data.type = 1
                data.result = "success"
                display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "SHARE_TO_WECHAT_RESULT", data = data })
            end
        elseif type == 4 then
            if targetPlatform ~= cc.PLATFORM_OS_WINDOWS then
                local bridge = require("app.func.Bridge")
                local strUrl = "itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id="..clientConfig.appStoreId
                bridge.openAppStore(strUrl)
                self.bOpenAppStore = true
            end
        elseif type == 5 then
            if cc.dataMgr.guestLogin then
                app.hallScene:hideAllPopLayers()
                local bindCtr = require("hall.view.AccountBindLayer")
                local bindAccountLayer = bindCtr:createLayer()
                self.currScene:addChild(bindAccountLayer, 20)
                app.hallScene.nPopLayers = app.hallScene.nPopLayers + 1
                self.currScene.bindAccountLayer = bindAccountLayer
            end
        end
    end
    if bLocked then
        btnGoto:addTouchEventListener(taskLocked)
    else
        btnGoto:addTouchEventListener(function(obj, type)
            if type == 2 then
                app.audioPlayer:playClickBtnEffect()
                if string.find(taskInfo.taskText[2], "完成") ~= nil then
                    gotoFinish(1)
                elseif string.find(taskInfo.taskText[1], "邀请") ~= nil then
                    gotoFinish(2)
                elseif string.find(taskInfo.taskText[2], "分享") ~= nil then
                    gotoFinish(3)
                elseif string.find(taskInfo.taskText[1], "评价") ~= nil then
                    gotoFinish(4)
                elseif string.find(taskInfo.taskText[1], "话费礼包") ~= nil then
                    gotoFinish(5)
                end
            end
        end)
    end

    local btnGetAward = layBase:getChildByName("Button_getAward")
    btnGetAward:setPressedActionEnabled(true)
    btnGetAward:setVisible(taskInfo.taskStatus == 1)
    local userInfoMore = cc.dataMgr.userInfoMore
    btnGetAward:addTouchEventListener(function(obj, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            if userInfoMore == nil then return end
            if userInfoMore.phoneBindState == 0 then
                local function funcOk()
                    app.hallScene:hideAllPopLayers()
                    self.currScene.layPhoneBind:setVisible(true)
                end
                app.msgBox.showMsgBoxTwoBtn("请先绑定手机号再进行此操作（首次绑定手机号可立即获得大量游戏豆奖励）。", funcOk, nil, "福利中心", "去绑定", "取消")
                return
            end

            app.benefitLogic:reqGetBenefitAward(taskInfo.taskId)
        end
    end)
    if taskInfo.taskStatus == 1 and userInfoMore.phoneBindState ~= 0 then
        app.benefitLogic:reqGetBenefitAward(taskInfo.taskId)
    end
    local imgAwardGot = layBase:getChildByName("Image_awardGot")
    imgAwardGot:setVisible(taskInfo.taskStatus == 2)
    local imgArrowDown = layBase:getChildByName("Image_arrowDown")
    imgArrowDown:setVisible(false)

    --任务详细描述
    local labelDetail = layExpand:getChildByName("Text_detail")
    labelDetail:setString(taskInfo.taskText[3])

    --边框
    local imgBorder = taskItem:getChildByName("Image_border")
    imgBorder:setContentSize(taskItem:getContentSize())
    imgBorder:setVisible(false)
    local function startBorderAnim()
        imgBorder:stopAllActions()
        local fadeOut = cc.FadeTo:create(0.5, 20)
        local fadeIn = cc.FadeTo:create(0.5, 255)
        local anim = cc.RepeatForever:create(cc.Sequence:create(fadeOut, fadeIn))
        imgBorder:runAction(anim)
    end
    if keywords ~= nil then
        local bFound = fasle
        for i = 1, #keywords do
            if string.find(taskInfo.taskText[1], keywords[i]) ~= nil then
                bFound = true
                break
            end
        end
        if bFound and taskInfo.taskCurProcess == 0 then
            imgBorder:setVisible(true)
            startBorderAnim()
        end
    end
    if string.find(taskInfo.taskText[2], "邀请") ~= nil then
        imgArrowDown:setVisible(true)
        taskItem:addTouchEventListener(function(obj, type)
            if type == 2 then
                app.audioPlayer:playClickBtnEffect()
                --local strPath = "Resources/newResources/Fuli/lingjiangkuang2.png"
                if layExpand:isVisible() then
                    imgArrowDown:setVisible(true)
                    layExpand:setVisible(false)
                    size.height = sizeBase.height
                    layBase:setPosition(0, 0)
                    --strPath = "Resources/newResources/Fuli/lingjiangkuang2.png"
                else
                    imgArrowDown:setVisible(false)
                    layExpand:setVisible(true)
                    size.height = sizeBase.height + sizeExpand.height
                    layBase:setPosition(0, sizeExpand.height)
                    --strPath = "Resources/newResources/Fuli/bangdingkuang.png"
                end
                print("height:"..size.height.."width:"..size.width)
                taskItem:setContentSize(size)
                taskItem:retain()
                listTask:removeItem(index - 1)
                listTask:insertCustomItem(taskItem, index - 1)
                if imgBorder:isVisible() then
                    imgBorder:setContentSize(size)
                    startBorderAnim()
                end
            end
        end)

        local btnViewRecord = layExpand:getChildByName("Button_viewRecord")
        btnViewRecord:setPressedActionEnabled(true)
        btnViewRecord:addTouchEventListener(function(obj, type)
            if type == 2 then
                app.audioPlayer:playClickBtnEffect()
                app.benefitLogic:reqGetInvitingRecord()
                self.nodeRecord:setVisible(true)
                self.nodeTaskList:setVisible(false)
            end
        end)
    end

    taskItem:setVisible(true)
    listTask:insertCustomItem(taskItem, index - 1)
end

return BenefitTaskLayer

