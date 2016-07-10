--
-- Author: ChenShao
-- Date: 2015-08-17 11:34:45
--
local gamedb = {}

local sqlite3 = require("lsqlite3")


function gamedb.createTable()
	local dbpath = cc.FileUtils:getInstance():getWritablePath() .."user.db"
	local db = sqlite3.open(dbpath)

	db:exec(
		"CREATE TABLE IF NOT EXISTS existGame" .. 
		"(" ..
		"id INTEGER PRIMARY KEY AUTOINCREMENT," ..
		"gameID INTEGER," .. 
		"gameName TEXT," ..
		"gameName_ZH TEXT," ..
		"isShowing BOOL," .. -- 是否在游戏列表 UI 表现
		"isDownloaded BOOL" ..
		")" --是否下载了
	)
	db:exec("create unique index uk_existGame on existGame (gameID)")
end

function gamedb.deleteTable()
	local dbpath = cc.FileUtils:getInstance():getWritablePath() .."user.db"
	local db = sqlite3.open(dbpath)
	local sql = "DELETE TABLE existGame"
	db:exec(sql)
	db:close()
end

local function closeDB(db)
	db:close()
end

function gamedb.readGameInfo()
	local dbpath = cc.FileUtils:getInstance():getWritablePath() .."user.db"
	local db = sqlite3.open(dbpath)

	local gameInfo = {}
	for row in db:nrows("SELECT * FROM existGame") do
		if row.isShowing == 1 then
			gameInfo[#gameInfo + 1] = {gameId = row.gameID, gameName = row.gameName, gameName_ZH = row.gameName_ZH, isShowing = row.isShowing, isDownloaded = row.isDownloaded}
		end
	end
	closeDB(db)

	return gameInfo
end

function gamedb.updateDownloadState(gameID)
	local dbpath = cc.FileUtils:getInstance():getWritablePath() .."user.db"
	local db = sqlite3.open(dbpath)

	local sql = "UPDATE existGame set isDownloaded = 1 where gameID = " ..gameID
	print("sql = " ..sql)
	local ret = db:exec(sql)

	closeDB(db)
	print("更改状态 ret = " ..ret)
	return ret
end


function gamedb.checkIsDownloaded(gameID)
	local dbpath = cc.FileUtils:getInstance():getWritablePath() .."user.db"
	local db = sqlite3.open(dbpath)

	local sql =  "SELECT * FROM existGame WHERE gameID = " ..gameID
	print("sql = " ..sql)
	

	local isDownloaded = 0	 --重未安装
	for row in db:nrows(sql) do
		if row.isDownloaded == 0 then
			isDownloaded = 1 -- 预置  未安装
		else
			isDownloaded = 2 --已安装
		end
	end
	closeDB(db)
	return isDownloaded
end

function gamedb.updateShowingState(gameID, state)
	local dbpath = cc.FileUtils:getInstance():getWritablePath() .."user.db"
	local db = sqlite3.open(dbpath)

	local sql = "UPDATE existGame set isShowing = " ..state .." where gameID = " ..gameID
	print("sql = " ..sql)
	local ret = db:exec(sql)

	closeDB(db)
	print("更改状态 ret = " ..ret)
	return ret
end

function gamedb.getGameNameByGameID(gameID)
	local dbpath = cc.FileUtils:getInstance():getWritablePath() .."user.db"
	local db = sqlite3.open(dbpath)

	local sql =  "SELECT gameName FROM existGame WHERE gameID = " ..gameID
	print("sql = " ..sql)
	
	local gameName = ""
	for row in db:nrows(sql) do
		gameName = row.gameName
	end

	closeDB(db)
	return gameName
end
--[[
function gamedb.updateVersion(gameID, version)
	print("<---gamedb.updateVersion")
	local dbpath = cc.FileUtils:getInstance():getWritablePath() .."user.db"
	local db = sqlite3.open(dbpath)

	local sql = "UPDATE existGame set version = " ..version .." where gameID = " ..gameID
	print("sql = " ..sql)
	local ret = db:exec(sql)

	closeDB(db)
	print("更改状态 ret = " ..ret)
	return ret
end ]]

function gamedb.addNewGame(gameID, gameName, gameNameZH, isShowing, isDownloaded)
	local dbpath = cc.FileUtils:getInstance():getWritablePath() .."user.db"
	local db = sqlite3.open(dbpath)

	local id = "NULL"
	--local sql = string.format(formatstring, ···)
	local sql = "INSERT INTO existGame VALUES (" 
		..id .."," 
		..gameID ..",'" 
		..gameName .."','"
		..gameNameZH .."'," 
		..isShowing ..","
		..isDownloaded  ..")"
	
	print("sql = " ..sql)
	local ret = db:exec(sql)
	print("addNewGame ret = " ..ret)

	closeDB(db)
end

function gamedb.deleteGame(gameID)
	local dbpath = cc.FileUtils:getInstance():getWritablePath() .."user.db"
	local db = sqlite3.open(dbpath)

	local sql = "DELETE FROM existGame WHERE gameID = " ..gameID
	print("sql = " ..sql)
	local ret = db:exec(sql)

	closeDB(db)

	if ret == 0 then 
		print("delete successful") 
		return 0
	end

	return - 1
end

return gamedb