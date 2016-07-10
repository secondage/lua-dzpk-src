--
-- Author: ChenShao
-- Date: 2015-09-21 14:14:35
--
local soundType = ""
local targetPlatform = cc.Application:getInstance():getTargetPlatform()

if cc.PLATFORM_OS_ANDROID == targetPlatform then
	soundType = ".ogg"
elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) then
	soundType = ".mp3"
else
	soundType = ".mp3"
end

return soundType