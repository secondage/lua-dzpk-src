--
-- Author: ChenShao
-- Date: 2015-11-27 09:16:24
--
local resHelper = {}

local _bLoadSpriteFrames = false 
local _bLoadAudio = false

function resHelper.loadSpriteFrames()
	
	if _bLoadSpriteFrames then
		return 
	end

	print("加载dzpk资源")
	_bLoadSpriteFrames = true

	local packName = "dzpk/res/"
	display.loadSpriteFrames(packName .."chip.plist", packName .."chip.png")
	display.loadSpriteFrames(packName .."poke.plist", packName .."poke.png")
	display.loadSpriteFrames(packName .."showType.plist", packName .."showType.png")
	packName = "dzpk/res/animations/"
	display.loadSpriteFrames(packName .."dealOpenCards.plist", packName .."dealOpenCards.png")
	display.loadSpriteFrames(packName .."endOpenCards.plist", packName .."endOpenCards.png")
	display.loadSpriteFrames(packName .."Four.plist", packName .."Four.png")
	display.loadSpriteFrames(packName .."GodSameLoong.plist", packName .."GodSameLoong.png")
	display.loadSpriteFrames(packName .."goldFrame1.plist", packName .."goldFrame1.png")
	display.loadSpriteFrames(packName .."goldFrame2.plist", packName .."goldFrame2.png")
	display.loadSpriteFrames(packName .."publicOpenCards.plist", packName .."publicOpenCards.png")
	display.loadSpriteFrames(packName .."SameColor.plist", packName .."SameColor.png")
	display.loadSpriteFrames(packName .."SameLoong.plist", packName .."SameLoong.png")
	display.loadSpriteFrames(packName .."ThreeTwo.plist", packName .."ThreeTwo.png")
	display.loadSpriteFrames(packName .."AllIn.plist", packName .."AllIn.png")
	display.loadSpriteFrames(packName .."Chip.plist", packName .."Chip.png")
end

function resHelper.removeSpriteFrames( )

	_bLoadSpriteFrames = false

	print("移除dzpk资源")
	local packName = "dzpk/res/"
	display.removeSpriteFrames(packName .."chip.plist", packName .."chip.png")
	display.removeSpriteFrames(packName .."poke.plist", packName .."poke.png")
	display.removeSpriteFrames(packName .."showType.plist", packName .."showType.png")
	packName = "dzpk/res/animations/"
	display.removeSpriteFrames(packName .."dealOpenCards.plist", packName .."dealOpenCards.png")
	display.removeSpriteFrames(packName .."endOpenCards.plist", packName .."endOpenCards.png")
	display.removeSpriteFrames(packName .."Four.plist", packName .."Four.png")
	display.removeSpriteFrames(packName .."GodSameLoong.plist", packName .."GodSameLoong.png")
	display.removeSpriteFrames(packName .."goldFrame1.plist", packName .."goldFrame1.png")
	display.removeSpriteFrames(packName .."goldFrame2.plist", packName .."goldFrame2.png")
	display.removeSpriteFrames(packName .."publicOpenCards.plist", packName .."publicOpenCards.png")
	display.removeSpriteFrames(packName .."SameColor.plist", packName .."SameColor.png")
	display.removeSpriteFrames(packName .."SameLoong.plist", packName .."SameLoong.png")
	display.removeSpriteFrames(packName .."ThreeTwo.plist", packName .."ThreeTwo.png")
	display.removeSpriteFrames(packName .."AllIn.plist", packName .."AllIn.png")
	display.removeSpriteFrames(packName .."Chip.plist", packName .."Chip.png")
end

function resHelper.loadAudio()

	if _bLoadAudio then
		return 
	end

	_bLoadAudio = true

	app.gameAudioPlayer = require("dzpk.src.GameAudioPlayer")
	app.gameAudioPlayer.loadAllEffects()
end

function resHelper.removeAudio()
	_bLoadAudio = false
	app.gameAudioPlayer = require("dzpk.src.GameAudioPlayer")
	app.gameAudioPlayer.unloadAllEffects()
end

return resHelper