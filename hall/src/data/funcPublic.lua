--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2016/1/6
-- Time: 11:38
-- To change this template use File | Settings | File Templates.
--

local funcPublic = {}

function funcPublic.isMoneyGame(gameType)
    gameType = gameType or cc.dataMgr.selectGameType
    return gameType == 0 or gameType == 3 or gameType == 7 or gameType == 8 or gameType == 10 or gameType == 12
end

function funcPublic.isScoreGame(gameType)
    gameType = gameType or cc.dataMgr.selectGameType
    return gameType == 1 or gameType == 4 or gameType == 9 or gameType == 11
end

function funcPublic.isQuickGame(gameType)
	
    gameType = gameType or cc.dataMgr.selectGameType
    return gameType == 10 or gameType == 11
end

function funcPublic.isChanllengeGame(gameType)
	gameType = gameType or cc.dataMgr.selectGameType
	return gameType == 7
end

function funcPublic.isRoundGame(gameType)
	gameType = gameType or cc.dataMgr.selectGameType
	return gameType == 8
end

function funcPublic.isWrapGame(gameType)
	gameType = gameType or cc.dataMgr.selectGameType
	return gameType == 12
end





return funcPublic
