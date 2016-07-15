--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/10/16
-- Time: 15:24
-- To change this template use File | Settings | File Templates.
--

local CardsLayer = class("CardsLayer",function()
    return display.newLayer()
end)
local Attribute = require(app.codeSrc .. "Attribute")
local GamePublic = require(app.codeSrc .. "GamePublic")
local PokePlay = require(app.codeSrc .. "PokePlay")

function CardsLayer:ctor()
    print"CardLayer:ctor()"
    self.handCardsList = {[0] = {}, [1] = {}, [2] = {}, [3] = {}, [4] = {},[5] = {},[6] = {},[7] = {},[8] = {}, }
    self.publicCardsList = {}
    app.pokePlay = {}
    for i = 0, GamePublic.c_tablePlyNum - 1 do
        app.pokePlay[i] = PokePlay:new()
        app.pokePlay[i]:InitPoke()
    end
end

function CardsLayer:drawOneCard(card, pos, scale)
    if card.par == 0 and card.color == 0 then
        local spBack = display.newSprite(Attribute.OtherCardRes.CardBack, pos.x, pos.y)
        spBack:addTo(self)
        spBack:setLocalZOrder(20)
        if scale ~= nil then
            spBack:setScale(scale)
        end
     --   spBack:setTag(tag)
     --   if zorder ~= nil then spBack:setLocalZOrder(zorder) end
        return spBack
    else
        local spFace = display.newSprite(Attribute.OtherCardRes.CardFace, pos.x, pos.y):show()
        spFace:addTo(self)
        spFace:setLocalZOrder(20)
      --  spFace:setTag(tag)
      --  if zorder ~= nil then spFace:setLocalZOrder(zorder) end
        --颜色
        local color = ""
        if card.color == 0 or card.color == 2 then
            color = "b"
        else
            color = "r"
        end

        --牌值
        local par = ""
        if card.par == 16 then
            local str = string.format("#%s-joker.png", color)
            local spPar = display.newSprite(str)
            spPar:setPosition(10, spFace:getContentSize().height / 2 + 17)
            spPar:addTo(spFace)
            spPar:setTag(0)
        else
            --print("card.par = " .. card.par )
            par = GamePublic.itopoke(card.par)
            local str = string.format("#%s-%s.png", color, par)
            local spPar =  display.newSprite(str)
            spPar:setPosition(18, spFace:getContentSize().height - 23)
            spPar:addTo(spFace)
            spPar:setTag(0)
        end

        --花色
        if card.par ~= 16 then
            local spPokeType = display.newSprite(Attribute.CardTypes[card.color].Small)
            spPokeType:setPosition(18, spFace:getContentSize().height - 55)
            spPokeType:addTo(spFace)
            spPokeType:setTag(1)
        end

        --牌面图片
        local img = ""
        if card.par == 11 or card.par == 12 or card.par == 13 then
            img = GamePublic.itopoke(card.par)
            local str = string.format("#%s-%s-image.png", color, img)
            local spImage = display.newSprite(str)
            spImage:setPosition(spFace:getContentSize().width/2 + 7, spFace:getContentSize().height/2 - 8)
            spImage:addTo(spFace)
            spImage:setTag(2)
        elseif card.par == 16 then
            local str = string.format( "#%s-joker-image.png", color)
            local spImage = display.newSprite(str)
            spImage:setPosition(spFace:getContentSize().width/2 + 1, spFace:getContentSize().height/2 - 2)
            spImage:addTo(spFace)
            spImage:setTag(2)
        else
            local spImage = display.newSprite(Attribute.CardTypes[card.color].Normal)
            spImage:setPosition(spFace:getContentSize().width/2 + 3, spFace:getContentSize().height/2 - 20)
            spImage:addTo(spFace)
            spImage:setTag(2)
        end
        if scale ~= nil then
            spFace:setScale(scale)
        end
        return spFace
    end
end

function CardsLayer:drawOneCardEx(card, pos, scale, parent)
    if card.par == 0 and card.color == 0 then
        local spBack = display.newSprite(Attribute.OtherCardRes.CardBack, pos.x, pos.y)
        spBack:addTo(parent)
        spBack:setLocalZOrder(20)
        if scale ~= nil then
            spBack:setScale(scale)
        end
        --   spBack:setTag(tag)
        --   if zorder ~= nil then spBack:setLocalZOrder(zorder) end
        return spBack
    else
        local spFace = display.newSprite(Attribute.OtherCardRes.CardFace, pos.x, pos.y):show()
        spFace:addTo(parent)
        spFace:setLocalZOrder(20)
        --  spFace:setTag(tag)
        --  if zorder ~= nil then spFace:setLocalZOrder(zorder) end
        --颜色
        local color = ""
        if card.color == 0 or card.color == 2 then
            color = "b"
        else
            color = "r"
        end

        --牌值
        local par = ""
        if card.par == 16 then
            local str = string.format("#%s-joker.png", color)
            local spPar = display.newSprite(str)
            spPar:setPosition(10, spFace:getContentSize().height / 2 + 17)
            spPar:addTo(spFace)
            spPar:setTag(0)
        else
            --print("card.par = " .. card.par )
            par = GamePublic.itopoke(card.par)
            local str = string.format("#%s-%s.png", color, par)
            local spPar =  display.newSprite(str)
            spPar:setPosition(18, spFace:getContentSize().height - 23)
            spPar:addTo(spFace)
            spPar:setTag(0)
        end

        --花色
        if card.par ~= 16 then
            local spPokeType = display.newSprite(Attribute.CardTypes[card.color].Small)
            spPokeType:setPosition(18, spFace:getContentSize().height - 55)
            spPokeType:addTo(spFace)
            spPokeType:setTag(1)
        end

        --牌面图片
        local img = ""
        if card.par == 11 or card.par == 12 or card.par == 13 then
            img = GamePublic.itopoke(card.par)
            local str = string.format("#%s-%s-image.png", color, img)
            local spImage = display.newSprite(str)
            spImage:setPosition(spFace:getContentSize().width/2 + 7, spFace:getContentSize().height/2 - 8)
            spImage:addTo(spFace)
            spImage:setTag(2)
        elseif card.par == 16 then
            local str = string.format( "#%s-joker-image.png", color)
            local spImage = display.newSprite(str)
            spImage:setPosition(spFace:getContentSize().width/2 + 1, spFace:getContentSize().height/2 - 2)
            spImage:addTo(spFace)
            spImage:setTag(2)
        else
            local spImage = display.newSprite(Attribute.CardTypes[card.color].Normal)
            spImage:setPosition(spFace:getContentSize().width/2 + 3, spFace:getContentSize().height/2 - 20)
            spImage:addTo(spFace)
            spImage:setTag(2)
        end
        if scale ~= nil then
            spFace:setScale(scale)
        end
        return spFace
    end
end

--[[function CardsLayer:drawCardsArray(cards, beginPos, offset, scale)
    --dump(cards)
    local pos = {}
    pos.x = beginPos.x
    pos.y = beginPos.y
    local Tag = 0
    for _, card in pairs(cards) do
        local spCard = self:drawOneCard(card, pos, scale)
        --print("draw one card.......................................................")
        for i = 0, GamePublic.c_tablePlyNum - 1 do
            self:insertHandCardToTable(i, spCard)
        end
        pos.x = pos.x + offset.x
        pos.y = pos.y - offset.y
        Tag = Tag + 1
    end
end--]]

function CardsLayer:insertHandCardToTable(chairID, sp)
    self.handCardsList[chairID][table.nums(self.handCardsList[chairID])] = sp
    --table.insert(self.handCardsList[chairID], sp)
end

function CardsLayer:insertPublicCardToTable(sp)
    self.publicCardsList[table.nums(self.publicCardsList)] = sp
end

--[[function CardsLayer:drawHandCards(chairID, handCards, scale, off)
    self:removeHandCards(chairID)
    local pos = {}
    pos.x, pos.y = app.runningScene.gameUsersUI[chairID]:getPosition()
    local offset = 20
    self:drawCardsArray(handCards, pos, offset, scale)
end--]]

function CardsLayer:removeHandCards(chairID)
    local cards = self.handCardsList[chairID]
    if cards ~= nil or #cards > 0 then
        for _, card in pairs(cards) do
            card:removeSelf()
        end
    end
    self.handCardsList[chairID] = {}
end

function CardsLayer:removeAllCards()
    self:removeAllChildren()
    self.handCardsList = {[0] = {}, [1] = {}, [2] = {}, [3] = {}, [4] = {},[5] = {},[6] = {},[7] = {},[8] = {}, }
    self.publicCardsList = {}
end

function CardsLayer:setPokeColor(spCard, color)
    if spCard then
        spCard:setColor(color)
        for tagchild = 0, 2 do
            local spChild = spCard:getChildByTag(tagchild)
            if spChild then
                spChild:setColor(color)
            end
        end
    end
end

return CardsLayer