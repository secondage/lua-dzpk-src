--
-- Author: ChenShao
-- Date: 2015-08-19 15:34:37
--
local audioPlayer = class("audioPlayer")

local audio = require("cocos.framework.audio")

local soundType = require("app.func.AudioDefine")

local path = ""
local targetPlatform = cc.Application:getInstance():getTargetPlatform()
if cc.PLATFORM_OS_ANDROID == targetPlatform then
	path = "audio_android/" 
elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) then
	path = "audio_ios/" 
else
	path = "audio_ios/"
end

local EFFECT_CLICKBTN = path .."clickbtn" ..soundType
local MUSIC_HALL = path .."hallmusic" ..soundType

function audioPlayer:preloadAllGameMusic()--所有手机上安装的小游戏


    self:preloadMusic("dzpk".."/res/gamingmusic" ..soundType)
end

function audioPlayer:playGamingMusic()
	print("music = " ..cc.dataMgr.playingGame .."/res/gamingmusic" ..soundType)
	if cc.UserDefault:getInstance():getBoolForKey("isMusic", true) then
		self:playMusic(cc.dataMgr.playingGame .."/res/gamingmusic" ..soundType)
	end
end

function audioPlayer:preloadMusic(fileName)
	print("preloadMusic music name = " ..fileName)
	audio.preloadMusic(fileName)
end

function audioPlayer:isMusicPlaying()
	return audio.isMusicPlaying()
end

function audioPlayer:playMusic(filename)
	print("music name = " ..filename)
	audio.playMusic(filename, true)
end

function audioPlayer:stopMusic()
	audio.pauseMusic()
end

function audioPlayer:setMusicVolume(volume)
	audio.setMusicVolume(volume)
end

function audioPlayer:getMusicVolume()
	return audio.getMusicVolume()
end

function audioPlayer:preloadEffects(fileName)
	--print("preloadEffects, fileName:"..fileName)
	audio.preloadSound(fileName)
end

function audioPlayer:stopAllEffects()
	audio.stopAllSounds()
end

function audioPlayer:playEffect(filename)
	if not cc.UserDefault:getInstance():getBoolForKey("isEffect", true) then
		return
	end
	audio.playSound(filename, false)
end

function audioPlayer:setEffectsVolume(volume)
	audio.setSoundsVolume(volume)
end

function audioPlayer:getEffectsVolume()
	return audio.getSoundsVolume()
end

function audioPlayer:loadAudio()
	self:preloadEffects(EFFECT_CLICKBTN)

	self:preloadMusic(MUSIC_HALL)
	self:preloadAllGameMusic()

	self:preloadEffects(path.."coin_drop"..soundType)
	self:preloadEffects(path.."fenglei_logo"..soundType)

	local musicVolume = cc.UserDefault:getInstance():getFloatForKey("musicVolume", 0.6)
	local effectVolume = cc.UserDefault:getInstance():getFloatForKey("effectVolume", 1)

	self:setMusicVolume(musicVolume)
	self:setEffectsVolume(effectVolume)
	
end

function audioPlayer:playClickBtnEffect()
	if cc.UserDefault:getInstance():getBoolForKey("isEffect", true) then
		self:playEffect(EFFECT_CLICKBTN)	
	end
end

function audioPlayer:playHallMusic()
	if cc.UserDefault:getInstance():getBoolForKey("isMusic", true) then
		self:playMusic(MUSIC_HALL)	
	end
end

function audioPlayer:unloadSound(filename)
	audio.unloadSound(filename)
end

function audioPlayer:playEffectByName(name)
	local fileName = path..name..soundType
	self:playEffect(fileName)
end

return audioPlayer