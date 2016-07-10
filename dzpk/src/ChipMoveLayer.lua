--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/12/8
-- Time: 15:43
-- To change this template use File | Settings | File Templates.
--
local ChipMoveLayer = class("ChipMoveLayer",function()
    return display.newLayer()
end)

local _attribute = require("dzpk.src.Attribute")

local intival = 5                                    -- 重叠的间距
local chipValue =
{
    1,
    5,
    10,
    50,
    100,
    500,
    1000,
    5000,
    10000,
    50000,
    100000,
    500000,
    1000000,
    5000000,
    10000000,
    50000000
}

function ChipMoveLayer.Int2Chip(chipNum)
    local chip = {}
    local chipTmp = chipNum
    for i = 16, 1, -1 do
        if chipTmp / chipValue[i] >= 1 then
            chip[i] = chipTmp / chipValue[i] - chipTmp / chipValue[i] % 1
            chipTmp = chipTmp - chip[i] * chipValue[i]
        end
    end
    return chip
end

function ChipMoveLayer:ctor()
    self.userChipList = {}
    self.poolChipList = {}
end

function ChipMoveLayer:createChipArray(chipNum, pos)
    local node = cc.Node:create()
    local chip = self.Int2Chip(chipNum)
    local chipCount = 0
    local tmpPosY = 0
    for i = 16, 1, -1 do
        if chip[i] ~= nil and chip[i] > 0 then
            --for j = 1 , chip[i] do
                -- 创建筹码
                local spChip = display.newSprite(_attribute.chipRes[16 - i + 1], 0, tmpPosY):show()
                spChip:addTo(node)
                chipCount = chipCount + 1
                tmpPosY = 0 + chipCount * intival
                if chipCount == 6 then          -- 设置筹码不超过6个
                    break
                end
            --end
        end
    end
    node:addTo(self)
    node:setPosition(pos.x, pos.y)
    return node
end

function ChipMoveLayer:createMoveChipArray(pos)
    local node = cc.Node:create()
    -- 随机2 到 4 个筹码
    local chipCount = math.random(2, 4)
    local tmpPosY = 0
    for i = 0, chipCount - 1 do
        local color = math.random(1, 16)
        -- 创建筹码
        local spChip = display.newSprite(_attribute.chipRes[color], 0, tmpPosY):show()
        spChip:addTo(node)
        tmpPosY = 0 + i * intival
    end
    node:addTo(self)
    node:setPosition(pos.x, pos.y)
    return node
end

function ChipMoveLayer:createOneChip(color, pos)
    local node = cc.Node:create()

    -- 创建筹码
    local spChip = display.newSprite(_attribute.chipRes[color], 0, 0):show()
    spChip:addTo(node)

    node:addTo(self)
    node:setPosition(pos.x, pos.y)
    return node
end

function ChipMoveLayer:createOneChipForChair(chair, color, pos)
    local node = cc.Node:create()

    -- 创建筹码
    local spChip = display.newSprite(_attribute.chipRes[color], 0, 0):show()
    spChip:addTo(node)

    node:addTo(self)
    node:setPosition(pos.x, pos.y)

    self.userChipList[chair] = node
end

function ChipMoveLayer:createChipsForPoolIndex(index, pos)
    local node = cc.Node:create()
    -- 随机3 到 6 个筹码
    local chipCount = math.random(3, 6)
    local tmpPosY = 0
    for i = 0, chipCount - 1 do
        local color = math.random(1, 16)
        -- 创建筹码
        local spChip = display.newSprite(_attribute.chipRes[color], 0, tmpPosY):show()
        spChip:addTo(node)
        tmpPosY = 0 + i * intival
    end
    node:addTo(self)
    node:setPosition(pos.x, pos.y)

    self.poolChipList[index] = node
end

function ChipMoveLayer:createChipArrayByCountRange(chipNum, pos, minCount, maxCount)
    local node = cc.Node:create()
    local chip = self.Int2Chip(chipNum)
    local colorArray = {}
    for i = 16, 1, -1 do
        if chip[i] ~= nil and chip[i] > 0 then
            colorArray[table.nums(colorArray)] = i
        end
    end

    local tmpPosY = 0
    -- 随机颜色minCount - maxCount 个筹码
    local chipCount = math.random(minCount, maxCount)
    for i = 0, chipCount - 1 do

        local color = colorArray[table.nums(colorArray) - (i + 1)]
        -- 创建筹码
        local spChip = display.newSprite(_attribute.chipRes[color], 0, tmpPosY):show()
        spChip:addTo(node)
        tmpPosY = 0 + i * intival
    end
    node:addTo(self)
    node:setPosition(pos.x, pos.y)
    return node
end

function ChipMoveLayer:moveChipArray(node, endPos)
    -- 移动筹码
    local actionMove = cc.MoveTo:create(0.3, endPos)
    node:runAction(actionMove)
end

function ChipMoveLayer:moveChipArrayByChair(chair, endPos)
    -- 移动筹码
    local chip = self.userChipList[chair]
    if chip ~= nil then
        local actionMove = cc.MoveTo:create(0.3, endPos)
        chip:runAction(actionMove)
    end
end

function ChipMoveLayer:removeChipArrayNode(node)
    if node then
        node:removeSelf()
        node = nil
    end
end

function ChipMoveLayer:removeChipArrayByChair(chairID)
    local chip = self.userChipList[chairID]
    if chip ~= nil then
        chip:removeSelf()
    end
    self.userChipList[chairID] = nil
end

function ChipMoveLayer:removeChipArrayByPoolIndex(index)
    local chip = self.poolChipList[index]
    if chip ~= nil then
        chip:removeSelf()
    end
    self.poolChipList[index] = nil
end

local tagSpChip = 666

function ChipMoveLayer:renderOneToOneMoveChipArray(chipNum, beginPos, endPos)
    local node = cc.Node:create()
    local chip = self.Int2Chip(chipNum)
    local chipCount = 0
    local intival = 5
    local tmpPos = {x = endPos.x, y = endPos.y }
    -- 按筹码大小画筹码
    for i = 16, 1, -1 do
        if chip[i] ~= nil and chip[i] > 0 then
            for j = 1 , chip[i] do
                -- 创建筹码
                local spChip = display.newSprite(_attribute.chipRes[16 - i + 1], beginPos.x, beginPos.y):show()
                spChip:addTo(node)

                -- 移动筹码
                local actionDelay = cc.DelayTime:create(chipCount * 100 / 1000)
                local actionMove = cc.MoveTo:create(0.3, cc.p(tmpPos.x, tmpPos.y))
                spChip:runAction(cc.Sequence:create(actionDelay, actionMove, nil))

                chipCount = chipCount + 1
                tmpPos.y = endPos.y + chipCount * intival
            end
        end
    end

    node:addTo(self)
    return node, (chipCount * 100 / 1000 + 0.3)
end

function ChipMoveLayer:renderOneChipMove(chipNum, beginPos, endPos)
    local node = cc.Node:create()
    local chip = self.Int2Chip(chipNum)
    local color = math.random(1, 16)

    -- 创建筹码
    local spChip = display.newSprite(_attribute.chipRes[color], beginPos.x, beginPos.y):show()
    spChip:addTo(node)

    -- 移动筹码
    local actionMove = cc.MoveTo:create(0.3, cc.p(endPos.x, endPos.y))
    spChip:runAction(actionMove)

    node:addTo(self)
    return node, color
end

function ChipMoveLayer:moveOneToOneChipArray(node, endPos)
    if node then
        local actionMove = cc.MoveTo:create(0.5, endPos)
        for _,child in pairs(node:getChildren()) do
            child:runAction(actionMove:clone())
        end
    end
end

function ChipMoveLayer:removeAllChip()
    print"removeAllChip"
    self:removeAllChildren()
    self.userChipList = {}
    self.poolChipList = {}
end
return ChipMoveLayer
