--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/12/30
-- Time: 15:35
-- To change this template use File | Settings | File Templates.
--

local SpecialEffectLayer = class("SpecialEffectLayer", function()
    return display.newLayer()
end)
local _attribute = require("dzpk.src.Attribute")
local _clockBorderRender = require("dzpk.src.ClockBorderRender")
local _gamePublic = nil

local function createEndAnimation(self, name, num, playTime)
    local frames = display.newFrames(name.. "_%d.png", 0, num, false)
    local animation, firstFrame = display.newAnimation(frames, playTime / num)
    display.setAnimationCache(name .."Animation", animation)
    firstFrame:addTo(self)
    firstFrame:hide()
    return firstFrame
end

function SpecialEffectLayer:ctor()
    _gamePublic = require(app.codeSrc .."GamePublic")
    self.userEmptyNodeList = {}
    self.publicCardsList = {}
end

function SpecialEffectLayer:createSpecialEffectLayer()
    self.clip = cc.ClippingNode:create()
    self.clip:setInverted(true)
    self.clip:setAlphaThreshold(0)
    self.clip:addTo(self)
    local colorLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 150))
    colorLayer:addTo(self.clip)

    self.endAnimation = {}
    self.endAnimation.Four = createEndAnimation(self, "Four", 10, 1.5)
    self.endAnimation.GodSameLoong = createEndAnimation(self, "GodSameLoong", 11, 1.5)
    self.endAnimation.SameColor = createEndAnimation(self, "SameColor", 11, 1.5)
    self.endAnimation.SameLoong = createEndAnimation(self, "SameLoong", 11, 1.5)
    self.endAnimation.ThreeTwo = createEndAnimation(self, "ThreeTwo", 12, 1.5)
    return self
end

function SpecialEffectLayer:setWinUserByChair(chair)
    local drawNode = cc.DrawNode:create()
    local orgin = _attribute.gameUserPos[chair]
   -- local rect = {x = orgin.x - 59, y = orgin.y + 84, width = 118, height = 168 }
    local rect = {x = orgin.x - 64, y = orgin.y + 90, width = 128, height = 178 }
    _clockBorderRender:drawNodeRoundRect(drawNode, rect, 2, 10, cc.c4f(1, 0, 1, 0.5), cc.c4f(1, 0, 1, 0.5))

    self.userEmptyNodeList[chair] = drawNode
end

function SpecialEffectLayer:setUserStencil()
    self.node = cc.Node:create()
    for i = 0, 8 do
        if self.userEmptyNodeList[i] ~= nil then
            self.userEmptyNodeList[i]:addTo(self.node)
        end
    end

    --[[local drawNode = cc.DrawNode:create()
    local orgin = {x = 345, y = 300}
    local des = {x = 789, y = 404}
    drawNode:drawSolidRect(orgin, des, cc.c4b(0, 0, 255, 200))
    drawNode:addTo(self.node)--]]

    self.clip:setStencil(self.node)
end

function SpecialEffectLayer:clearUserStencil()
    if self.node ~= nil then
        self.node:removeAllChildren()
    end
    self.node = nil
    self.userEmptyNodeList = {}
end

function SpecialEffectLayer:playAnimation(type)
    print"SpecialEffectLayer:playAnimation"
    if type == _gamePublic.eCards_Type.eType_ThreeTwo then
        self.endAnimation.ThreeTwo:pos(568, 380)
        :playAnimationOnce(display.getAnimationCache("ThreeTwoAnimation"), {hide = 1})
    elseif type == _gamePublic.eCards_Type.eType_Four then
        self.endAnimation.Four:pos(568, 380)
        :playAnimationOnce(display.getAnimationCache("FourAnimation"), {hide = 1})
    elseif type == _gamePublic.eCards_Type.eType_SameLoong then
        self.endAnimation.SameLoong:pos(568, 380)
        :playAnimationOnce(display.getAnimationCache("SameLoongAnimation"), {hide = 1})
    elseif type == _gamePublic.eCards_Type.eType_GodSameLoong then
        self.endAnimation.GodSameLoong:pos(568, 380)
        :playAnimationOnce(display.getAnimationCache("GodSameLoongAnimation"), {hide = 1})
    elseif type == _gamePublic.eCards_Type.eType_SameColor then
        self.endAnimation.SameColor:pos(568, 380)
        :playAnimationOnce(display.getAnimationCache("SameColorAnimation"), {hide = 1})
    end
end

function SpecialEffectLayer:drawPublicCards()
    for i = 0, table.nums(app.gameLayer.publicCards) - 1 do
        local card = app.gameLayer.publicCards[i]
        local spCard = app.gameLayer.cardsLayer:drawOneCardEx(card, _attribute.PublicCardsPos[i], 0.87, self)
        spCard:setScaleX(0.82)
        self.publicCardsList[i] = spCard
    end
end

function SpecialEffectLayer:clearPublicCards()
    for i = 0, table.nums(self.publicCardsList) - 1 do
        local spCard = self.publicCardsList[i]
        if spCard then
            spCard:removeSelf()
        end
    end
    self.publicCardsList = {}
end

return SpecialEffectLayer
