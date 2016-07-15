--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/9/14
-- Time: 14:18
-- To change this template use File | Settings | File Templates.
--
local ReminderPoint = require("hall.view.ReminderPoint")

local BenefitLayer = class("BenefitLayer")

function BenefitLayer:init(currScene)

    self.layTask = require("hall.view.BenefitTaskLayer").new()
    self.laySignIn = require("hall.view.SignInLayer").new()
    self.layBaseLiving = require("hall.view.BenefitBaseLivingLayer").new()

    print("-------------BenefitLayer:init")

    app.benefitLogic:reqGetBenefitListConfig()

    self.root = cc.CSLoader:createNode("Layers/BenefitLayer.csb")
    self.currScene = currScene
    self.currScene:addChild(self.root, 20)
    self:initWidgets()
    self:setVisible(false)

    self.layTask:init(currScene, self.root)
    self.layTask:setVisible(true)
    self.laySignIn:init(currScene, self.root)
    self.layBaseLiving:init(currScene, self.root)

    self:listenEvent()
end

function BenefitLayer:listenEvent()
    --福利中心任务列表
    self.currScene.eventProtocol:addEventListener("SHOW_BENEFIT_TASK", function(event)
        print("event SHOW_BENEFIT_TASK")
        app.hallScene:hideHallUI()
        self:setVisible(true)
        self.layTask:setVisible(true, event.data)
    end)
end

function BenefitLayer:initWidgets()
    local layRoot = self.root:getChildByName("Panel_benefit")

    --任务
    self.checkTask = ccui.Helper:seekWidgetByName(layRoot, "CheckBox_benefitTask")
    self.checkTask:addEventListener(function(obj, type)
        app.audioPlayer:playClickBtnEffect()
        self:switchLayer(1)
    end)
    ReminderPoint.new():init(self.checkTask, "benefit_task", self.currScene)

    --签到
    self.checkSignIn = ccui.Helper:seekWidgetByName(layRoot, "CheckBox_signIn")
    self.checkSignIn:addEventListener(function(obj, type)
        app.audioPlayer:playClickBtnEffect()
        self:switchLayer(2)
    end)
    ReminderPoint.new():init(self.checkSignIn, "benefit_signIn", self.currScene)

    --低保
    self.checkBaseLiving = ccui.Helper:seekWidgetByName(layRoot, "CheckBox_baseLiving")
    self.checkBaseLiving:addEventListener(function(obj, type)
        app.audioPlayer:playClickBtnEffect()
        self:switchLayer(3)
    end)

    local btnReturnHall = ccui.Helper:seekWidgetByName(layRoot, "Button_returnHall")
    --btnReturn:setPressedActionEnabled(true)
    btnReturnHall:addTouchEventListener(function(obj, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            self:setVisible(false)
        end
    end)

end

function BenefitLayer:switchLayer(flag)
    print("BenefitLayer:switchLayer, flag:"..flag)
    self.layTask:setVisible(flag == 1)
    self.checkTask:setSelected(flag == 1)
    self.laySignIn:setVisible(flag == 2)
    self.checkSignIn:setSelected(flag == 2)
    self.layBaseLiving:setVisible(flag == 3)
    self.checkBaseLiving:setSelected(flag == 3)
end

function BenefitLayer:setVisible(bShow)
    if bShow then
        if not self.root:isVisible() then
            app.popLayer.showEx(self.root)
        end
        self:switchLayer(1)
    else
        app.hallScene:showHallUI()
    end
    self.root:setVisible(bShow)
end

return BenefitLayer