--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/11/6
-- Time: 9:16
-- To change this template use File | Settings | File Templates.
--
local gamePublic = {}

-- 1,2,3,4,5,6,7,8,9,10,J(11),Q(12),K(13),sJoke(16),bJoke(17)
gamePublic.eCardPar =
{
    eParHanafuda = 0,
    ePar0 = 0,
    eParAce	= 1,
    ePar2 = 2,
    ePar3 = 3,
    ePar4 = 4,
    ePar5 = 5,
    ePar6 = 6,
    ePar7 = 7,
    ePar8 = 8,
    ePar9 = 9,
    ePar10 = 10,
    eParJack = 11,
    eParQueen = 12,
    eParKing = 13,
    eParAceB = 14,
    ePar2B = 15,
    eParSJoker	= 16,
    eParBJoker	= 17,
    eParMax = 18
}

gamePublic.eTimer_GameEvent =
{
    eTimerEvent_PokeOp = 100,
    eTimerEvent_Deal   = 101,
    eTimerEvent_Sel = 102,
}

gamePublic.eTimer_ExpTime =
{
    eTimerExp_PokeOp  = 16000,
    eTimerExp_Deal    = 2000,
    eTimerExp_Sel = 1000,
}

gamePublic.eTimer_ExpTimeClient =
{
    eTimerExpClient_PokeOp = 15,
    eTimerExpClient_Deal = 2,
    eTimerExpClient_Sel = 3,
}

gamePublic.c_tablePlyNum = 9
gamePublic.c_invalidPar = 17
gamePublic.c_invalidColor = 4
gamePublic.c_jokePar = 16
gamePublic.c_tenPar  = 10
gamePublic.c_cardsAll = 52
gamePublic.c_threePar = 3
gamePublic.c_JPar = 11
gamePublic.c_APar = 14
gamePublic.c_cardsOut = 22

function gamePublic:valid_par(par)
    return par >= 0 and par < self.c_invalidPar
end

function gamePublic:valid_color(color)
    return color >= 0 and color < self.c_invalidColor
end

function gamePublic:valid_card(par, color)
    return self:valid_par(par) and self:valid_color(color)
end

function gamePublic:valid_chair(chair)
    return chair >= 0 and chair < self.c_tablePlyNum
end

function gamePublic.self_chair(chair)
    return chair == 0
end

function gamePublic.itopoke(par)
    if par < 11 then
        local str = string.format("%d", par)
        return str
    elseif par == 11 then
        return "J"
    elseif par == 12 then
        return "Q"
    elseif par == 13 then
        return "K"
    elseif par == 14 then
        return "A"
    end
end

gamePublic.stCard = class("stCard")
function gamePublic.stCard:ctor()
    self.par = gamePublic.c_invalidPar
    self.color = gamePublic.c_invalidColor
end

function gamePublic.stCard:assign(cardPar, cardColor)
    self.par = cardPar
    self.color = cardColor
end

function gamePublic.stCard:assignFromstCard(res)
    self.par = res.par
    self.color = res.color
end

function gamePublic.stCard:equal(res)
    return self.par == res.par and self.color == res.color
end

function gamePublic.stCard:Valid()
    return gamePublic.valid_card(self.par, self.color)
end

function gamePublic.stCard:lesser(res)
    return self.par < res.par
end

function gamePublic:ten_card(res)
    return res.par == self.c_tenPar and res.color % 2 == 1
end

function gamePublic:joke_card(res)
    return res.par == self.c_jokePar
end

function gamePublic:sort_color(res)
    if self:joke_card(res) then
        return res.color
    else
        return 4 - res.color
    end
end

function gamePublic.score_card(card)
    if card.par == 5 then
        return 5
    elseif card.par == 10 then
        return 10
    elseif card.par == 13 then
        return 10
    else
        return 0
    end
end

gamePublic.eCards_Type =
{
    eType_Pass   = 0,
    eType_Single = 1,
    eType_Double = 2,
    eType_DoubleTwo = 3,
    eType_Three = 4,
    eType_SingleLoong = 5,
    eType_SameColor = 6,
    eType_ThreeTwo = 7,
    eType_Four = 8,
    eType_SameLoong = 9,
    eType_GodSameLoong = 10,
    eType_Num = 11,
}

gamePublic.eOp_Type =
{
    eOp_PassBet = 1,
    eOp_AddBet = 2,
    eOp_FollowBet = 4,
    eOp_Suoha = 8,
    eOp_Giveup = 16,
    eOp_Open = 32,
}

gamePublic.eOp_Status =
{
    eOps_Pass = 1,
    eOps_Giveup = 2,
    eOps_SuoHa = 4,
}

gamePublic.eLogicUser_Status =
{
    eLogicStatus_Null = 0,
    eLogicStatus_Cur = 1,
    eLogicStatus_Next = 2,
    eLogicStatus_Giveup = 3,
    eLogicStatus_Run = 4,
    eLogicStatus_Num = 5,
}

gamePublic.stCardType = class("stCardType")
function gamePublic.stCardType:ctor()
    self.type = 0
    self.par = 0
    self.num = 0
end

function gamePublic.stCardType:assign(res)
    self.type = res.type
    self.par = res.par
    self.num = res.num
end

function gamePublic.stCardType:greater(res)
    --同类牌比面值
    if self.type == res.type then
        return self.par > res.par
    else
        return self.type > res.type
    end
end

function gamePublic.stCardType:equal(res)
    return self.type == res.type and self.par == res.par
end

--牌类型，sJoke-2, bJoke-1, 方块3, 枚花2, 红桃1, 黑桃0，
gamePublic.eCardColor =
{
    eCardSJoker			= -2,
    eCardBJoker			= -1,
    eCardSpade = 0,--黑桃
    eCardHeart = 1, --红桃
    eCardClub = 2,--梅花
    eCardDiamond = 3,--方块
    eCardMax = 4,
    eCardBlackHanafuda = 4,--黑花牌
    eCardRedHanafuda = 5,--红花牌
}

gamePublic.stInitData = class("stInitData")
function gamePublic.stInitData:ctor()
    self.chair = -1
    self.bet = -1
    self.status = -1
    self.handCards = {}
end

function gamePublic.stInitData:assign(res)
    self.chair = res.chair
    self.bet = res.bet
    self.status = res.status
    self.handCards = table.deepcopy(res.handCards)
end

local data6 = {}
for i = 1, 6 do
    data6[i] = 2 ^ (6 - i)
end

function gamePublic:d2b(arg)
    local tr = {}
    for i = 1, 6 do
        if arg >= data6[i] then
            tr[i] = 1
            arg = arg - data6[i]
        else
            tr[i] = 0
        end
    end
    return tr
end

function gamePublic:b2d(arg)
    local nr = 0
    for i = 1, 6 do
        if arg[i] == 1 then
            nr = nr + 2 ^ (6 - i)
        end
    end
    return nr
end

function gamePublic:_and(a, b)
    local op1 = self:d2b(a)
    local op2 = self:d2b(b)
    local r = {}
    for i = 1, 6 do
        if op1[i] == 1 and op2[i] == 1 then
            r[i] = 1
        else
            r[i] = 0
        end
    end
    return self:b2d(r)
end

function gamePublic:_or(a, b)
    local op1 = self:d2b(a)
    local op2 = self:d2b(b)
    local r = {}
    for i = 1, 6 do
        if op1[i] == 1 or op2[i] == 1 then
            r[i] = 1
        else
            r[i] = 0
        end
    end
    return self:b2d(r)
end
return gamePublic

