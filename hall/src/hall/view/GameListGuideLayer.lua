--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/12/24
-- Time: 10:55
-- To change this template use File | Settings | File Templates.
--

local GameListGuideLayer = class("GameListGuideLayer")

function GameListGuideLayer.create()
    local layer = GameListGuideLayer.new()
    layer.root = cc.CSLoader:createNode("Layers/GameListGuideLayer.csb")
    layer:init()
    return layer
end

function GameListGuideLayer:init()
    self:initView()
    self:showScrollGuide()
end

function GameListGuideLayer:initView()
    local panelRoot = self.root:getChildByName("Panel_guidRoot")
    self.panelLeft = panelRoot:getChildByName("Panel_left")
    self.panelRight = panelRoot:getChildByName("Panel_right")
    self.panelTop = panelRoot:getChildByName("Panel_top")
    self.panelBottom = panelRoot:getChildByName("Panel_bottom")
    self.nodeGuideScan = panelRoot:getChildByName("Node_guideScan")
    self.nodeGuideScan:setVisible(false)
    self.nodeGuideAddGame = panelRoot:getChildByName("Node_guideAddGame")
    self.nodeGuideAddGame:setVisible(false)
    self.nodeGuideCloseAddGame = panelRoot:getChildByName("Node_guideCloseAddGame")
    self.nodeGuideCloseAddGame:setVisible(false)
    self.imgFinger = panelRoot:getChildByName("Image_finger")
    self.imgFinger:setVisible(false)
    self.imgClick = panelRoot:getChildByName("Image_click")
    self.imgClick:setVisible(false)
end

function GameListGuideLayer:setAvailableArea(point, size)
    local posTop = cc.p(0, point.y + size.height)
    local sizeTop = cc.size(1136, 640 - posTop.y)
    self.panelTop:setPosition(posTop.x, posTop.y)
    self.panelTop:setContentSize(sizeTop)

    local sizeBottom = cc.size(1136, point.y)
    self.panelBottom:setContentSize(sizeBottom)

    local posLeft = cc.p(0, point.y)
    local sizeLeft = cc.size(point.x, size.height)
    self.panelLeft:setPosition(posLeft.x, posLeft.y)
    self.panelLeft:setContentSize(sizeLeft)

    local posRight = cc.p(point.x + size.width, point.y)
    local sizeRight = cc.size(1136 - point.x - size.width, size.height)
    self.panelRight:setPosition(posRight.x, posRight.y)
    self.panelRight:setContentSize(sizeRight)
end

function GameListGuideLayer:showScrollGuide()
    self.nodeGuideScan:setVisible(true)
    self.nodeGuideAddGame:setVisible(false)
    --local textGuid = self.nodeGuideScan:getChildByName("Text_content")
    --local imgSeepchBubble = self.nodeGuideScan:getChildByName("Image_speechBubble")
    --local imgGuider = self.nodeGuideScan:getChildByName("Image_guider")
    local point = cc.p(0, 160)
    local size = cc.size(1136, 280)
    self:setAvailableArea(point, size)

    local imgFinger = self.imgFinger
    local positionStart = cc.p(800, 320)
    local positionEnd = cc.p(568, 320)
    imgFinger:setVisible(true)
    imgFinger:stopAllActions()
    imgFinger:setPosition(positionStart.x, positionStart.y)
    local moveTo = cc.MoveTo:create(0.7, positionEnd)
    local delay = cc.DelayTime:create(0.5)
    local funcNext = cc.CallFunc:create(function()
        imgFinger:setPosition(positionStart.x, positionStart.y)
    end)
    local sequence = cc.Sequence:create(moveTo, delay, funcNext)
    local action = cc.RepeatForever:create(sequence)
    imgFinger:runAction(action)
end

function GameListGuideLayer:showAddGameGuide(point, size)
    self.nodeGuideScan:setVisible(false)
    self.nodeGuideAddGame:setVisible(true)
    local textGuid = self.nodeGuideAddGame:getChildByName("Text_content")
    local imgSeepchBubble = self.nodeGuideAddGame:getChildByName("Image_speechBubble")
    local imgGuider = self.nodeGuideAddGame:getChildByName("Image_guider")
    self:setAvailableArea(point, size)
    local imgFinger = self.imgFinger
    local imgClick = self.imgClick
    imgFinger:stopAllActions()
    imgFinger:setPosition(point.x + size.width / 2 + 50, point.y + size.height / 2 + 50)
    imgClick:stopAllActions()
    imgClick:setPosition(point.x + size.width / 2 + 50, point.y + size.height / 2 + 50)
    local funcFirst = cc.CallFunc:create(function()
        imgFinger:setVisible(true)
        imgClick:setVisible(false)
    end)
    local delay1 = cc.DelayTime:create(0.5)
    local funcNext = cc.CallFunc:create(function()
        imgFinger:setVisible(false)
        imgClick:setVisible(true)
    end)
    local delay2 = cc.DelayTime:create(0.5)
    local sequence = cc.Sequence:create(funcFirst, delay1, funcNext, delay2)
    local action = cc.RepeatForever:create(sequence)
    imgClick:runAction(action)
    if point.x + size.width / 2 < 568 then
        --文字和图片放到右边
        imgGuider:setPositionX(point.x + size.width + imgGuider:getContentSize().width / 2 + 200)
        imgGuider:setFlippedX(false)
        local posXGuider = imgGuider:getPositionX()
        imgSeepchBubble:setPositionX(posXGuider - imgSeepchBubble:getContentSize().width / 2)
        imgSeepchBubble:setFlippedX(true)
        local posXBubble = imgSeepchBubble:getPositionX()
        textGuid:setPositionX(posXBubble)
    else
        --文字和图片放到左边
        imgGuider:setPositionX(point.x - imgGuider:getContentSize().width / 2 - 200)
        imgGuider:setFlippedX(true)
        local posXGuider = imgGuider:getPositionX()
        imgSeepchBubble:setPositionX(posXGuider + imgSeepchBubble:getContentSize().width / 2)
        imgSeepchBubble:setFlippedX(false)
        local posXBubble = imgSeepchBubble:getPositionX()
        textGuid:setPositionX(posXBubble)
    end
end

function GameListGuideLayer:showCloseAddGameGuide(btnClose)
    self.nodeGuideAddGame:setVisible(false)
    self.nodeGuideCloseAddGame:setVisible(true)
    local pos = btnClose:getParent():convertToWorldSpace(cc.p(btnClose:getPosition()))
    local size = btnClose:getContentSize()
    --pos.y = pos.y - size.height
    self:setAvailableArea(cc.p(pos.x - size.width / 2, pos.y - size.height / 2), size)
    --pos.x = pos.x + size.width
    local sizeFinger = self.imgFinger:getContentSize()
    self.imgFinger:setPosition(pos.x + sizeFinger.width / 2, pos.y - sizeFinger.height / 2)
    local sizeClick = self.imgClick:getContentSize()
    self.imgClick:setPosition(pos.x + sizeClick.width / 2, pos.y - sizeClick.height / 2)
end

return GameListGuideLayer
