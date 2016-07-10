--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/10/15
-- Time: 14:50
-- To change this template use File | Settings | File Templates.
--

local gameAudioPlayer = {}

local soundType = require("app.func.AudioDefine")
local cardsType = require(cc.dataMgr.playingGame ..".src.GamePublic").eCards_Type

local path = ""
local targetPlatform = cc.Application:getInstance():getTargetPlatform()
if cc.PLATFORM_OS_ANDROID == targetPlatform then
    path = "audio_android/"
elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) then
    path = "audio_ios/"
else
    path = "audio_ios/"
end

local effectOper = {
    "oper_1_0",
    "oper_2_0",
    "oper_2_1",
    "oper_4_0",
    "oper_4_1",
    "oper_8_0",
    "oper_8_1",
    "oper_16_0",
    "oper_16_1",
}

local effectOther = {
    "balance_chips",
    "bet",
    "dealcard",
    "opencard",
    "round_collection_chips",
    "start",
    "timeout_tip",
    "win",
    "lose",
}

local allEffectRes = {}

function gameAudioPlayer.loadAllEffects()

    for _, val in pairs(effectOper) do
        app.audioPlayer:preloadEffects(val ..soundType)
        allEffectRes[#allEffectRes + 1] = val ..soundType
    end

    for _, val in pairs(effectOther) do
        app.audioPlayer:preloadEffects(val ..soundType)
        allEffectRes[#allEffectRes + 1] = val ..soundType
    end

    app.audioPlayer:setEffectsVolume(1)
    app.audioPlayer:setMusicVolume(1)
end

function gameAudioPlayer.unloadAllEffects()
    for _, val in pairs(allEffectRes) do
        app.audioPlayer:unloadSound(val)
    end
end

function gameAudioPlayer.playOpAudio(oper, sex)
    print("play op audio oper = ".. oper .. ", sex = " .. sex)
    if not cc.UserDefault:getInstance():getBoolForKey("isEffect", true) then
        return
    end

    local audio = path ..string.format("oper_%d_%d", oper, sex) ..soundType
    app.audioPlayer:playEffect(audio)
end

function gameAudioPlayer.playEndEffect(res)
    if not cc.UserDefault:getInstance():getBoolForKey("isEffect", true) then
        return
    end
    if res > 0 then
        app.audioPlayer:playEffect(path .. "win" ..soundType)
    else
        app.audioPlayer:playEffect(path .. "lose" ..soundType)
    end
end

function gameAudioPlayer.playDealCardsEffect()
    if not cc.UserDefault:getInstance():getBoolForKey("isEffect", true) then
        return
    end
    app.audioPlayer:playEffect(path .. "dealcards" ..soundType)
end

function gameAudioPlayer.playBalanceChipsEffect()
    if not cc.UserDefault:getInstance():getBoolForKey("isEffect", true) then
        return
    end
    app.audioPlayer:playEffect(path .. "balance_chips" ..soundType)
end

function gameAudioPlayer.playBetEffect()
    if not cc.UserDefault:getInstance():getBoolForKey("isEffect", true) then
        return
    end
    app.audioPlayer:playEffect(path .. "bet" ..soundType)
end

function gameAudioPlayer.playDealcardEffect()
    if not cc.UserDefault:getInstance():getBoolForKey("isEffect", true) then
        return
    end
    app.audioPlayer:playEffect(path .. "dealcard" ..soundType)
end

function gameAudioPlayer.playOpenCardEffect()
    if not cc.UserDefault:getInstance():getBoolForKey("isEffect", true) then
        return
    end
    app.audioPlayer:playEffect(path .. "opencard" ..soundType)
end

function gameAudioPlayer.playRoundCollectionChipsEffect()
    if not cc.UserDefault:getInstance():getBoolForKey("isEffect", true) then
        return
    end
    app.audioPlayer:playEffect(path .. "round_collection_chips" ..soundType)
end

function gameAudioPlayer.playStartEffect()
    if not cc.UserDefault:getInstance():getBoolForKey("isEffect", true) then
        return
    end
    app.audioPlayer:playEffect(path .. "start" ..soundType)
end

function gameAudioPlayer.playTimeoutTipEffect()
    if not cc.UserDefault:getInstance():getBoolForKey("isEffect", true) then
        return
    end

    app.audioPlayer:playEffect(path .. "timeout_tip" ..soundType)
end

return gameAudioPlayer