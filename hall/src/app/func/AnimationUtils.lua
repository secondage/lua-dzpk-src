--
-- Author: ChenShao
-- Date: 2015-10-08 09:12:03
--
local animationUtils = {}

function animationUtils.createAnimation(preName, counts, animationName, time)
	local frames = display.newFrames(preName.. "%d.png", 1, counts, false)
	local animation, firstFrame = display.newAnimation(frames, time)
	display.setAnimationCache(animationName, animation)
	return firstFrame
end

function animationUtils.playAnimationByName(firstFrame, animationName, pos, args)

	args = args or {}
	if args.isForever then
		firstFrame:pos(cc.p(pos.x, pos.y))
				:playAnimationForever(display.getAnimationCache(animationName), {})
	else
		firstFrame:pos(cc.p(pos.x, pos.y))
				:playAnimationOnce(display.getAnimationCache(animationName),
					{	hide = args.hide, 
						removeSelf = args.removeSelf,
						delay = args.delay
					})
	end
end

function animationUtils.removeAnimationCacheByName(animationName)
	display.removeAnimationCache(animationName)
end

return animationUtils