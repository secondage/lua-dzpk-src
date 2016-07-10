--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/10/13
-- Time: 13:36
-- To change this template use File | Settings | File Templates.
--
local BulletinLayer = class("BulletinLayer")
local htmlParser = require("hall.logic.HtmlSimpleParser")

function BulletinLayer:init(currScene, bRemain, zOrder, positionY)
--[[
    local data1 = {}
    data1.pType = 1;
    --data1.text = "<b><c #0000FF00>挑战赛播报</c></b><c #00FF0000>   哈利路亚！！</c>   <c #FF0000FFFF>come on !!</c>"
    data1.text = "<c #00FF0000><b>风雷游戏港式五张防作弊房间火爆上限！50万游戏豆入桌、一键匹配机制，敬请体验！</b></c>"
    app.bulletinLogic:insertNewBulletin(data1)
--    local data2 = {}
--    data2.pType = 3;
--    data2.text = "Priority : 3; order : 2; 1234567890qwertyuiopasdfghjklzxcvbnm";
--    app.bulletinLogic:insertNewBulletin(data2)
--    local data3 = {}
--    data3.pType = 2;
--    data3.text = "Priority : 2; order : 3; 1234567890qwertyuiopasdfghjklzxcvbnm";
--    app.bulletinLogic:insertNewBulletin(data3)
--    local data4 = {}
--    data4.pType = 5;
--    data4.text = "Priority : 5; order : 4; 1234567890qwertyuiopasdfghjklzxcvbnm";
--    local data5 = {}
--    app.bulletinLogic:insertNewBulletin(data4)
--    data5.pType = 4;
--    data5.text = "Priority : 4; order : 5; 1234567890qwertyuiopasdfghjklzxcvbnm";
--    app.bulletinLogic:insertNewBulletin(data5)
--    local data6 = {}
--    data6.pType = 2;
--    data6.text = "Priority : 2; order : 6; 1234567890qwertyuiopasdfghjklzxcvbnm";
--    app.bulletinLogic:insertNewBulletin(data6)
--]]

    if currScene == nil or currScene.eventProtocol == nil then
        return
    end

    if bRemain == nil then
        bRemain = false
    end

    self.currScene = currScene
    self.bRemain = bRemain
    self.root = cc.CSLoader:createNode("Layers/BulletinLayer.csb")

    if zOrder == nil then
        zOrder = 2000
    end
    self.currScene:addChild(self.root, zOrder)

    self:initWidgets()

    if positionY ~= nil then
        self.nodeText:setPositionY(positionY)
    end

    --self:listenEvent()
    self:setVisible(self.bRemain)
    self.bRunningAnim = false
    self:startAnim()
end

function BulletinLayer:initWidgets()
    self.nodeText = self.root:getChildByName("Node_text")
    self.layText = self.nodeText:getChildByName("Panel_text")
    self.labelBulletin = self.layText:getChildByName("Text_bulletin")
    self.labelBulletin:setString("")
    --self.imgLaba = self.nodeText:getChildByName("Image_laba")
    --self.imgLaba:setVisible(self.bRemain)
end
--[[
function BulletinLayer:listenEvent()
    self.currScene.eventProtocol:addEventListener("FC_BULLETIN_INFO_P", function(event)
        print("event FC_BULLETIN_INFO_P")
        self:startAnim()
    end)
end
--]]
function BulletinLayer:setVisible(bShow)
    self.nodeText:setVisible(bShow)
    --self.imgLaba:setVisible(self.bRemain)
end

function BulletinLayer:hide()
    self.nodeText:setVisible(false)
    --self.imgLaba:setVisible(self.bRemain)
end

local function startFoldAnim(self)
    print("startFoldAnim")
    local animScale = cc.ScaleTo:create(0.2, 1, 0, 1)
    local funcNext = cc.CallFunc:create(function ()
        app.bulletinLogic:removeHandledBulletin()
        self.bRunningAnim = false
        self.layText:setScaleY(1)
        self:setVisible(false)
        local delay = cc.DelayTime:create(1)
        local funcAgain = cc.CallFunc:create(function ()
            self:startAnim()
        end)
        local sequnece = cc.Sequence:create(delay, funcAgain)
        self.root:runAction(sequnece)
    end)
    local sequnece = cc.Sequence:create(animScale, funcNext)
    self.layText:runAction(sequnece)
end

local function startRunningAnim(self)
    if self.bRemain then
        self.bRunningAnim = true
    end
    print("startRunningAnim")
    local length = self.labelBulletin:getContentSize().width
    local size = self.layText:getContentSize()
    print("position, x:"..size.width.."  y:"..size.height / 2)
    self.labelBulletin:setPosition(size.width, size.height / 2)
    self.labelBulletin:setVisible(true)
    local timeFast = size.width / 1000
    local timeSlow = length / 100
    local animMoveFast = cc.MoveTo:create(timeFast, cc.p(size.width / 2, size.height / 2))
    local animMoveSlow = cc.MoveTo:create(timeSlow, cc.p(-length, size.height / 2))

    local funcNext
    funcNext = cc.CallFunc:create(function ()
        if self.bRemain then
            app.bulletinLogic:removeHandledBulletin()
            self.bRunningAnim = false
            local delay = cc.DelayTime:create(1)
            local funcAgain = cc.CallFunc:create(function ()
                self:startAnim()
            end)
            local sequnece = cc.Sequence:create(delay, funcAgain)
            self.root:runAction(sequnece)
        else
            startFoldAnim(self)
        end
    end)
    local sequnece = cc.Sequence:create(animMoveFast, animMoveSlow, funcNext)

    self.labelBulletin:runAction(sequnece)
end

local function startUnfoldAnim(self)
    print("startUnfoldAnim")
    self.labelBulletin:setVisible(false)
    local timeScaleX = self.layText:getContentSize().width / 1750
    local animScaleX = cc.ScaleTo:create(timeScaleX, 1, 0.1, 1)
    local animScaleY = cc.ScaleTo:create(0.2, 1, 1, 1)
    local funcNext = cc.CallFunc:create(function()
        --self.imgLaba:setVisible(true)
        startRunningAnim(self)
    end)

    local sequnece = cc.Sequence:create(animScaleX, animScaleY, funcNext)
    self.layText:runAction(sequnece)
end

function BulletinLayer:startAnim()
    if self.bRunningAnim then
        return
    end

    local strText = app.bulletinLogic:getNextBulletinText()
    if strText == "" then
        return
    end

    print("bulletin startAnim, text:"..strText)

    local htmlElementList = htmlParser.parsHtmlString(strText)
    strText = ""
    for i = 1, #htmlElementList do
        local element = htmlElementList[i]
        strText = strText..element.content
    end
    print("after parse:"..strText)

    self.bRunningAnim = true
    self.labelBulletin:setString(strText)
    --播放
    self:setVisible(true)
    if self.bRemain then
        startRunningAnim(self)
    else
        --self.imgLaba:setVisible(false)
        self.layText:setScaleX(0)
        self.layText:setScaleY(0.1)
        startUnfoldAnim(self)
    end
end

function BulletinLayer:removeFromParent()
    self.root:removeFromParent()
    self.bRemain = false
end

function BulletinLayer:setRemain(bRemain)
    self.bRemain = bRemain
    if not self.bRunningAnim then
        self:setVisible(bRemain)
    end
end

function BulletinLayer.initListener()
    app.bulletinProtocol:removeEventListenersByEvent("FC_BULLETIN_INFO_P")
    app.bulletinProtocol:addEventListener("FC_BULLETIN_INFO_P", function(event)
        print("event FC_BULLETIN_INFO_P")
        if app.layBulletin == nil then
            local scene = display:getRunningScene().root
            if scene == nil then print("scene is nil") return end
            --2016.2.1 策划要求，大厅中跑马灯没有内容的时候隐藏
            --if scene.name == "HallScene" then print(scene.name.." bulletin will init latter") return end
            local layBulletin = require("hall.view.BulletinLayer").new()
            layBulletin:init(scene, false, 19, 500)
            layBulletin.root:setName("layBulletin")
            app.layBulletin = layBulletin
        end
        app.layBulletin:startAnim()
    end)
end

return BulletinLayer

