--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/10/29
-- Time: 16:58
-- To change this template use File | Settings | File Templates.
--
local BenefitGuideLayer = class("BenefitGuideLayer")

function BenefitGuideLayer:ctor()
    self.root = cc.CSLoader:createNode("Layers/BenefitGuideLayer.csb")
    self:initWidgets()
end

function BenefitGuideLayer:playSpotAnim()
    local imgPresentBox = self.layRoot:getChildByName("Image_presentBox")
    local size = imgPresentBox:getContentSize()
    local posXCenter, posYCenter = imgPresentBox:getPosition()
    local spSpots = {}
    local posXDest, posYDest = app.hallScene.btnBenefit:getPosition()
    for i = 1, 5 do
        local sp = display.newSprite("#Resources/newResources/benefit/spot.png")
        spSpots[i] = sp
        local posX = posXCenter + math.random(-size.width, size.width) / 2
        local posY = posYCenter + math.random(-size.height, size.height) / 2
        sp:setPosition(posX, posY)

        local posXCtrl1 = posXCenter + math.random(-size.width, size.width) / 2
        local posYCtrl1 = posYCenter + math.random(-size.height, size.height) / 2
        local posXCtrl2 = posXCenter + math.random(-size.width, size.width) / 2
        local posYCtrl2 = posYCenter + math.random(-size.height, size.height) / 2

        local scaleUp = cc.ScaleTo:create(0.5, 2.0)
        local config = {
            cc.p(posXCtrl1, posYCtrl1),
            cc.p(posXCtrl2, posYCtrl2),
            cc.p(posXDest, posYDest),
        }
        local bezierTo = cc.BezierTo:create(0.25 + 0.1 * i, config)
        local fcFinal = cc.CallFunc:create(function()
            app.hallScene.btnBenefit:setScale(1.5)
            local scaleDown = cc.ScaleTo:create(0.1, 1)
            app.hallScene.btnBenefit:runAction(scaleDown)
            sp:removeFromParent()
        end)
        local sequence = cc.Sequence:create(scaleUp, bezierTo, fcFinal)
        sp:runAction(sequence)

        self.root:addChild(sp)
    end
end

function BenefitGuideLayer:initWidgets()
    local layRoot = self.root:getChildByName("Panel_root")
    self.layRoot = layRoot
    --self.layRoof = self.root:getChildByName("Panel_roof")
    local btnClickToGet = layRoot:getChildByName("Button_clickToGet")
    btnClickToGet:addTouchEventListener(function(obj, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            cc.UserDefault:getInstance():setBoolForKey("benefit_guide_"..cc.dataMgr.lobbyLoginData.userID, true)
            cc.dataMgr.guiderFlag["benefit_guide"] = false
            local fadeOut = cc.FadeTo:create(0.5, 0)
            self:playSpotAnim()
            local funcFinal = cc.CallFunc:create(function()
                self.root:removeFromParent()
                app.runningScene.eventProtocol:dispatchEvent({ name = "SHOW_BENEFIT_TASK", data = {"新手礼包1"} })
            end)
            local delay = cc.DelayTime:create(0.75)
            self.layRoot:runAction(cc.Sequence:create(fadeOut, delay, funcFinal))
        end
    end)
end

function BenefitGuideLayer:playGeneralAnim()
    local imgPresentBox = self.layRoot:getChildByName("Image_presentBox")
    local moveDown = cc.MoveBy:create(0.7, cc.p(0, -50))
    local moveUp = cc.MoveBy:create(0.7, cc.p(0, 50))
    local sequence = cc.Sequence:create(moveDown, moveUp)
    local animMove = cc.RepeatForever:create(sequence)
    imgPresentBox:runAction(animMove)
    local imgArrow = self.layRoot:getChildByName("Image_arrow")
    local fadeDown = cc.FadeTo:create(0.7, 20)
    local fadeUp = cc.FadeTo:create(0.7, 255)
    local sequence = cc.Sequence:create(fadeDown, fadeUp)
    local animFade = cc.RepeatForever:create(sequence)
    imgArrow:runAction(animFade)
end

function BenefitGuideLayer:show(scene)
    if scene == nil then
        if app.hallScene ~= nil then
            app.hallScene:addChild(self.root,100)
        end
    else
        scene:addChild(self.root,100)
    end
    app.hallScene.laySignIn:setVisible(false)
    self:playGeneralAnim()
end

return BenefitGuideLayer

