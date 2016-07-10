--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/9/14
-- Time: 10:29
-- To change this template use File | Settings | File Templates.
--

local BenefitBaseLivingLayer = class("BenefitBaseLivingLayer")

function BenefitBaseLivingLayer:init(currScene, parentLayer)
    print("init benefit base living layer")
    self.currScene = currScene
    self.root = cc.CSLoader:createNode("Layers/BenefitBaseLivingLayer.csb")
    parentLayer:addChild(self.root, 20)

    self:initWidgets()
    self:setVisible(false)
end

function BenefitBaseLivingLayer:initWidgets()
    local layBaseLiving = self.root:getChildByName("Panel_baseLiving")
    self.btnBindPhone = layBaseLiving:getChildByName("Button_bindPhone")
    self.btnBindPhone:setPressedActionEnabled(true)

end

function BenefitBaseLivingLayer:setVisible(bShow)
    if bShow then self:fillDataToUI() end
    self.root:setVisible(bShow)
end

function BenefitBaseLivingLayer:fillDataToUI()
    local userInfoMore = cc.dataMgr.userInfoMore
    if userInfoMore.phoneBindState == 0 then
        self.btnBindPhone:setVisible(true)
        self.btnBindPhone:addTouchEventListener(function(obj, type)
            if type == 2 then
                app.audioPlayer:playClickBtnEffect()
                self.currScene.layPhoneBind:setVisible(true, self.currScene.layBenefit)
            end
        end)
    else
        self.btnBindPhone:setVisible(false)
    end
end

return BenefitBaseLivingLayer