--
-- Author: ChenShao
-- Date: 2015-11-18 17:05:19
--
function applicationDidEnterBackground()
	print("<------进入后台")

end

function applicationWillEnterForeground()
	print("<------回到前台")

	if g_Platform_Win32 then
		return
	end

	if app.miniGameMsgHandler then
		--app.miniGameMsgHandler:sendInitDataReq()
	end

	if app.runningScene ~= nil then
		if app.runningScene.eventProtocol ~= nil then
			app.runningScene.eventProtocol:dispatchEvent({ name = "ON_RESUME"})
		end
	end
end