--
-- Author: ChenShao
-- Date: 2015-08-28 16:26:14
--

local CustomLayer = class("CustomLayer", function()
	return display.newLayer()
end)

function CustomLayer:ctor()

end

function CustomLayer:playCustomEvent(gameId) --返回1 游戏存在 0 表示 内存中已缓存

	print("cc.dataMgr.playingGame = " ..cc.dataMgr.playingGame)
	local ret = 1
	cc.dataMgr.gameList = cc.dataMgr.gameLists[cc.dataMgr.playingGame]
	if not cc.dataMgr.gameList then
		if clientConfig.platform == "INNER" then

			cc.lobbyController:sendGameListReq(gameId)
		else
			cc.lobbyController:sendGameListReq(gameId)
		end
	else
		display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "PL_PHONE_SC_GAMELIST_ACK_P" })
		ret =  0
	end


	app.taskLogic:initData()


	if cc.dataMgr.lastSelectGameId ~=0 and cc.dataMgr.lastSelectGameId ~= gameId then
		local dbHelper = require("app.func.GameDB")
		local lastSelectGame = dbHelper.getGameNameByGameID(cc.dataMgr.lastSelectGameId)
		print("上次玩的游戏是 = " ..lastSelectGame)

		if lastSelectGame ~= "" then
			local resHelper = require(lastSelectGame .."/src/ResHelper")
			resHelper.removeSpriteFrames()
			resHelper.removeAudio()
		end
	end

	cc.dataMgr.lastSelectGameId = gameId

	return ret
end

return CustomLayer