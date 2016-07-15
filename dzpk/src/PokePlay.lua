--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/11/7
-- Time: 14:17
-- To change this template use File | Settings | File Templates.
--
local CPokePlay = class("CPokePlay")
local _gamePublic = require(app.codeSrc .. "GamePublic")

function CPokePlay:ctor()
    self.hand = {}
    self.out = {}
end

function CPokePlay:InitPoke()
    self.hand = {}
    self.out = {}
    self.outType = _gamePublic.stCardType:new()
    self.oldHand = {}
    self.cardsTable = {}
end

function CPokePlay:InitGame()
end

function CPokePlay:ScanCards(cards)
    self.cardsTable = {}
    for i = 0, _gamePublic.c_invalidPar - 1 do
        self.cardsTable[i] = 0
    end
    for i = 0, table.nums(cards) - 1 do
        local par = cards[i].par
        if _gamePublic:valid_par(par) then
            self.cardsTable[par] = self.cardsTable[par] + 1
        end
    end
    self.scan = cards
    self:ColorSort()
end

function CPokePlay:CaclType(cards)
    self.outType.type = _gamePublic.eCards_Type.eType_Pass
    if cards == nil then
        if table.nums(self.hand) ~= 5 then
            return
        end
        self:ScanCards(self.hand)
    else
        self:ScanCards(cards)
    end

    local par = self:CheckSameLoong()
    if par > 0 then
        self.outType.type = _gamePublic.eCards_Type.eType_SameLoong;
    else
        par = self:CheckFour()
        if par > 0 then
            self.outType.type = _gamePublic.eCards_Type.eType_Four
        else
            par = self:CheckThreeTwo()
            if par > 0 then
                self.outType.type = _gamePublic.eCards_Type.eType_ThreeTwo
            else
                par = self:CheckSameColor()
                if par > 0 then
                    self.outType.type = _gamePublic.eCards_Type.eType_SameColor
                else
                    par = self:CheckSingleLoong()
                    if par > 0 then
                        self.outType.type = _gamePublic.eCards_Type.eType_SingleLoong
                    else
                        par = self:CheckThree()
                        if par > 0 then
                            self.outType.type = _gamePublic.eCards_Type.eType_Three
                        else
                            par = self:CheckDoubleTwo()
                            if par > 0 then
                                self.outType.type = _gamePublic.eCards_Type.eType_DoubleTwo
                            else
                                par = self:CheckDouble()
                                if par > 0 then
                                    self.outType.type = _gamePublic.eCards_Type.eType_Double
                                else
                                    par = self:CheckSingle()
                                    if par > 0 then
                                        self.outType.type = _gamePublic.eCards_Type.eType_Single
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    self.outType.par = par
    return
end

function CPokePlay:CaclPartType()
   local cards = self.hand
   local cardsNum = table.nums(cards)
   if cardsNum > 0 then
        if cardsNum == 1 then
            cards = {}
        else
            for i = 0, cardsNum - 2 do
                cards[i]:assignFromstCard(cards[i + 1])
            end
            cards[cardsNum - 1] = nil
        end
   end
   self:ScanCards(cards)

   local par = 0
   local par = self:CheckSameLoong()
   if par > 0 then
       self.partType.type = _gamePublic.eCards_Type.eType_SameLoong;
   else
       par = self:CheckFour()
       if par > 0 then
           self.partType.type = _gamePublic.eCards_Type.eType_Four
       else
           par = self:CheckThreeTwo()
           if par > 0 then
               self.partType.type = _gamePublic.eCards_Type.eType_ThreeTwo
           else
               par = self:CheckSameColor()
               if par > 0 then
                   self.partType.type = _gamePublic.eCards_Type.eType_SameColor
               else
                   par = self:CheckSingleLoong()
                   if par > 0 then
                       self.partType.type = _gamePublic.eCards_Type.eType_SingleLoong
                   else
                       par = self:CheckThree()
                       if par > 0 then
                           self.partType.type = _gamePublic.eCards_Type.eType_Three
                       else
                           par = self:CheckDoubleTwo()
                           if par > 0 then
                               self.partType.type = _gamePublic.eCards_Type.eType_DoubleTwo
                           else
                               par = self:CheckDouble()
                               if par > 0 then
                                   self.partType.type = _gamePublic.eCards_Type.eType_Double
                               else
                                   par = self:CheckSingle()
                                   if par > 0 then
                                       self.partType.type = _gamePublic.eCards_Type.eType_Single
                                   end
                               end
                           end
                       end
                   end
               end
           end
       end
   end
   self.partType.par = par
   return
end

function CPokePlay:CheckSameLoong()
    local par = 0
    if table.nums(self.scan) == 5 then
        if self:CheckSameColor() > 0 and self:CheckSingleLoong() > 0 then
            par = self.scan[4].par
        end
    end
    return par
end

function CPokePlay:CheckFour()
    local par = 0
    for i = 2, 14 do
        if self.cardsTable[i] == 4 then
            par = i
            break
        end
    end
    return par
end

function CPokePlay:CheckThreeTwo()
    local par = 0
    local three, two = -1, -1
    for i = 2, 14 do
        if self.cardsTable[i] == 3 then
            three = i
        elseif self.cardsTable[i] == 2 then
            two = i
        end
    end
    if three > 0 and two > 0 then
        par = three * 100 + two
    end
    return par
end

function CPokePlay:CheckSameColor()
    local par = 0
    if table.nums(self.scan) == 5 then
        for i = 1, table.nums(self.scan) - 1 do
            if self.scan[i].color ~= self.scan[0].color then
                return par
            end
        end
        par = self.scan[0].par * 100000000 +
                self.scan[1].par * 1000000 +
                self.scan[2].par * 10000 +
                self.scan[3].par * 100 +
                self.scan[4].par;
    end
    return par
end

function CPokePlay:CheckSingleLoong()
    local par = 0

    if table.nums(self.scan) == 5 then
        if self.scan[0].par == self.scan[1].par + 1 and
                self.scan[0].par == self.scan[2].par + 2 and
                self.scan[0].par == self.scan[3].par + 3 and
                self.scan[0].par == self.scan[4].par + 4 then
            par = self.scan[0].par
        elseif self.scan[0].par == 14 and
                self.scan[1].par == 5 and
                self.scan[2].par == 4 and
                self.scan[3].par == 3 and
                self.scan[4].par == 2 then
            par = 1
        end
    end
    return par
end

function CPokePlay:CheckThree()
    local par = 0
    local three = -1
    local ones = {}
    ones[0] = 0
    ones[1] = 0
    for i = 2, 14 do
        if self.cardsTable[i] == 3 then
            three = i
        elseif self.cardsTable[i] == 1 then
            if ones[0]  <= 0 then
                ones[0] = i
            else
                ones[1] = i
            end
        end
    end
    if three> 0 then
        par = three * 10000 + ones[1] * 100 + ones[0]
    end
    return par
end

function CPokePlay:CheckDoubleTwo()
    local par = 0
    local two1, two2, one = -1, -1, 0
    for i = 14, 2, -1 do
        if self.cardsTable[i] == 2 then
            if two1 == -1 then
                two1 = i
            elseif two2 == -1 then
                two2 = i
            end
        elseif self.cardsTable[i] == 1 then
            one = i
        end
    end
    if two1 > 0 and two2 > 0 then
        for i = 0, table.nums(self.scan) - 1 do
            if self.scan[i].par == two1 then
                par = self.scan[i].par * 10000 + two2 * 100 + one
                break
            end
        end
    end
    return par
end

function CPokePlay:CheckDouble()
    local par = 0
    local two = -1
    local ones = {}
    for i = 0, 2 do
        ones[i] = 0
    end
    for i = 2, 14 do
        if self.cardsTable[i] == 2 then
            two = i
        elseif self.cardsTable[i] == 1 then
            if ones[0]  <= 0 then
                ones[0] = i
            elseif ones[1] <= 0 then
                ones[1] = i
            else
                ones[2] = i
            end
        end
    end

    if two> 0 then
        par = two * 1000000 + ones[2] * 10000 + ones[1] * 100 + ones[0]
    end

    return par
end

function CPokePlay:CheckSingle()
    local par = 0

    local base = 1
    for i = table.nums(self.scan) - 1, 0, -1 do
        par = par + self.scan[i].par * base
        base = base * 100
    end

    return par
end

function CPokePlay:ColorSort()
    if table.nums(self.scan) <= 1 then
        return true
    end

    --将牌排序
    local tmp = _gamePublic.stCard:new()
    for i = 0, table.nums(self.scan) - 1 do --整理牌的算法
        for j= i + 1, table.nums(self.scan) - 1 do
            local ipar = self.scan[i].par * 4 + (4 - self.scan[i].color)
            local jpar = self.scan[j].par * 4 + (4 - self.scan[j].color)
            if ipar < jpar then
                tmp:assignFromstCard(self.scan[i])
                self.scan[i]:assignFromstCard(self.scan[j])
                self.scan[j]:assignFromstCard(tmp)
            end
        end
    end

    return true
end

function CPokePlay:Compare(right)
    if self.outType > right.outType then
        return 1
    elseif self.outType == right.outType then
        return 0
    end
    return -1
end

function CPokePlay:TypeSort()
    if table.nums(self.hand) <= 1 then
        return true
    end
    local tmp = _gamePublic.stCard:new()
    local nCardCount = {}
    for i = 0, _gamePublic.c_invalidPar - 1 do
        nCardCount[i] = 0
    end
    for i = 0, table.nums(self.hand) - 1 do
        local par = self.hand[i].par
        if _gamePublic:valid_par(par) then
            nCardCount[par]  = nCardCount[par] + 1
        end
    end

    if nCardCount[_gamePublic.c_jokePar] == 2 then
        nCardCount[_gamePublic.c_jokePar] = 5
    end

    for i = 0, table.nums(self.hand) - 1 do  --整理牌的算法
        for j= i + 1, table.nums(self.scan) - 1 do
            local ipar = self.hand[i].par * 4 + self.hand[i].color + nCardCount[self.hand[i].par] * 200
            if _gamePublic:joke_card(self.hand[i]) then
                ipar = 17 * 4 + self.hand[i].color + nCardCount[self.hand[i].par] * 200
            end
            local jpar = self.hand[j].par * 4 + self.hand[j].color + nCardCount[self.hand[j].par] * 200
            if _gamePublic:joke_card(self.hand[j]) then
                jpar = 17 * 4 + self.hand[j].color + nCardCount[self.hand[j].par] * 200
            end
            if ipar < jpar then
                tmp:assignFromstCard(self.scan[i])
                self.scan[i]:assignFromstCard(self.scan[j])
                self.scan[j]:assignFromstCard(tmp)
            end
        end
    end
    return true
end

return CPokePlay