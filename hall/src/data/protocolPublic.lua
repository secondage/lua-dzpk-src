require "framework.utils.ByteArray"

local packBody = require "data.packBody"
require "framework.utils.BigNumber"
local iconv = require "iconv"
local encoding = iconv.new("utf-8", "GB18030") --多字节 -->utf8  接受服务器带中文字字段
local decoding = iconv.new("GB18030", "utf-8") --utf8 -->多字节 发送到服务器 带中文字字段
require "framework.utils.bit"

--[[
local function UTF82Mutiple(str)
	if str == "" then return str end
	return decoding:iconv(str)
end

local function Mutiple2UTF8(str)
	if str == "" then return str end
	return encoding:iconv(str)
end
]]
cc.MAX_IP_LENGTH = 16 --ip地址长度

wnet = {}

------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.heartBeatCheck = class("heartBeatCheck", packBody)
function wnet.heartBeatCheck:ctor(code, uid, pnum, mapid, syncid)
	wnet.heartBeatCheck.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "heartBeatCheck"
end
function wnet.heartBeatCheck:bufferIn()
	local buf = wnet.lobbyLoginReq.super.bufferIn(self)
	return buf
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.lobbyLoginAck = class("lobbyLoginAck", packBody)
function wnet.lobbyLoginAck:ctor(code, uid, pnum, mapid, syncid)
	wnet.lobbyLoginAck.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "lobbyLoginAck"
end

wnet.ELoginResult = {}
wnet.ELoginResult.ELOGIN_RESULT_OK = 0                          --登陆成功
wnet.ELoginResult.ELOGIN_RESULT_WRONGVALID = 1                  --验证码错误
wnet.ELoginResult.ELOGIN_RESULT_NONAME = 2                      --用户不存在
wnet.ELoginResult.ELOGIN_RESULT_WRONGPASSWD = 3                 --密码错误
wnet.ELoginResult.ELOGIN_RESULT_BINDING = 4                     --帐号绑定在其它机器登陆
wnet.ELoginResult.ELOGIN_RESULT_FORBID = 5                      --帐号被禁用
wnet.ELoginResult.ELOGIN_RESULT_ICE = 6                         --帐号被封冻
wnet.ELoginResult.ELOGIN_RESULT_LOST = 7                        --帐号失效
wnet.ELoginResult.ELOGIN_RESULT_RELOGIN = 8                     --帐号已经登陆
wnet.ELoginResult.ELOGIN_RESULT_BUSY = 9                        --系统繁忙
wnet.ELoginResult.ELOGIN_RESULT_WRONGDYNPWD = 10                --动态密码错误

function wnet.lobbyLoginAck:bufferOut(buf)
	self.loginRet = buf:readUInt()
	self.userID = buf:readInt()
	self.passCode = buf:readStringUShort()
	self.serverID = buf:readInt()
	self.ip = buf:readStringUShort()
	self.port = buf:readUShort()
	self.lastIP = buf:readStringUShort()
	self.lastTime = buf:readInt()
	self.curIP = buf:readStringUShort()
	self.curTime = buf:readInt()
	self.startTime = buf:readChar()
end

function wnet.lobbyLoginAck:toString()
	return self.name .. " " .. string.format("loginRet:%d, userID:%d, passCode:%s, serverID:%d, ip:%s, port:%d",
		self.loginRet, self.userID, self.passCode,
		self.serverID, self.ip, self.port)
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.lobbyLoginReq = class("lobbyLoginReq", packBody)
function wnet.lobbyLoginReq:ctor(code, uid, pnum, mapid, syncid)
	wnet.lobbyLoginReq.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end

function wnet.lobbyLoginReq:bufferIn(name, pwd, ip, vcode, mac, gate)
	assert(name or pwd, "Username and Password are necessary!")
	local buf = wnet.lobbyLoginReq.super.bufferIn(self)
	buf:writeStringUShort(decoding:iconv(name)):writeStringUShort(pwd):writeStringUShort(ip or ""):writeStringUShort(vcode or ""):writeStringUShort(mac or ""):writeStringUShort(gate or 0)
	return buf
end

------------------------------------------------------------------------------
----------------------手机注册相关结构体 start--------------------------------
wnet.CL_REG_REQ = class("CL_REG_REQ", packBody)
function wnet.CL_REG_REQ:ctor(code, uid, pnum, mapid, syncid)  
	wnet.CL_REG_REQ.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function wnet.CL_REG_REQ:bufferIn(data)
	local buf = wnet.CL_REG_REQ.super.bufferIn(self)
	buf:writeStringUShort(data.strAccount or ""):writeStringUShort(data.strNickName or "")
	   :writeStringUShort(data.strPasswd or ""):writeStringUShort(data.strRealName or "")
	   :writeStringUShort(data.strIDCard or ""):writeStringUShort(data.strPhone or "")
	   :writeStringUShort(data.strEmail or ""):writeStringUShort(data.strValid or "")
	   :writeChar(gender or 1):writeShort(icon or 1)
	   :writeStringUShort(data.strIP or ""):writeStringUShort(data.strMac or "")
	   :writeChar(phoneReg or 1)
	return buf
end

wnet.LC_REG_ACK = class("LC_REG_ACK", packBody)
function wnet.LC_REG_ACK:ctor(code, uid, pnum, mapid, syncid)  
	wnet.LC_REG_ACK.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function wnet.LC_REG_ACK:bufferOut(buf)
	self.ret = buf:readUInt()
	self.uerID = buf:readUInt()
	self.leftTime = buf:readChar()
end
----------------------手机注册相关结构体 end--------------------------------
------------------------------------------------------------------------------
wnet.PL_PHONE_CS_GAMELIST_REQ = class("PL_PHONE_CS_GAMELIST_REQ", packBody)
function wnet.PL_PHONE_CS_GAMELIST_REQ:ctor(code, uid, pnum, mapid, syncid)
	wnet.PL_PHONE_CS_GAMELIST_REQ.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end

function wnet.PL_PHONE_CS_GAMELIST_REQ:bufferIn(gameid)
	local buf = wnet.PL_PHONE_CS_GAMELIST_REQ.super.bufferIn(self)
	buf:writeShort(gameid)
	return buf
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.PL_PHONE_CS_USERLOGIN_REQ = class("PL_PHONE_CS_USERLOGIN_REQ", packBody)
function wnet.PL_PHONE_CS_USERLOGIN_REQ:ctor(code, uid, pnum, mapid, syncid)
	wnet.PL_PHONE_CS_USERLOGIN_REQ.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end

function wnet.PL_PHONE_CS_USERLOGIN_REQ:bufferIn(userid, passcode, mac, validate, loginMachineType)
	local buf = wnet.PL_PHONE_CS_USERLOGIN_REQ.super.bufferIn(self)
	buf:writeInt(userid):writeStringUShort(passcode):writeStringUShort(mac or ""):writeStringUShort(validate or ""):writeByte(loginMachineType or 0)
	return buf
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
local lobbyUser = class("lobbyUser")
function lobbyUser:ctor(code, uid, pnum, mapid, syncid)
end

wnet.User_IDENT = {}
wnet.User_IDENT[0] = "UIDENT_NORMAL" --普通用户
wnet.User_IDENT[1] = "UIDENT_JUNIORGM" --初级客服
wnet.User_IDENT[2] = "UIDENT_MIDDLEGM" --中级客服
wnet.User_IDENT[3] = "UIDENT_SENIORGM" --高级客服
wnet.User_IDENT[10] = "UIDENT_TRIAL" --试玩用户
wnet.User_IDENT[11] = "UIDENT_REFEREE" --裁判用户

function lobbyUser:bufferOut(buf)
	self.userID = buf:readUInt() --用户ID
	self.ident = buf:readUInt() --用户身份
	self.gmPur = buf:readUInt() --如果是GM,GM权限
	self.icon = buf:readUShort() --ICON
	self.gender = buf:readChar() --性别
	self.vipExp = buf:readUInt() --vip经验，以天为单位
	self.vipBegin = buf:readUInt() --vip最后一次续费时间
	self.vipEnd = buf:readUInt() --vip还有多久到期
	self.vipLevel = buf:readChar() --vip等级, 0为非会员
	self.vipUp = buf:readUInt() --vip还有多少天升级
	self.cofferEnd = buf:readUInt() --保险箱结束时间
	self.cofferstate = buf:readChar() --保险箱状态, 0是为开通，1是已开通但过期， 2是开通没过期
	self.honor = buf:readUInt() --声望
	self.honorLevel = buf:readChar() --声望等级
	local gch = buf:readUInt()
	local gcl = buf:readUInt()
	self.gameCurrency = i64(gch, gcl) --游戏豆
	local cch = buf:readUInt()
	local ccl = buf:readUInt()
	self.cofferCurrency = i64(cch, ccl) --保险箱里的游戏豆
	self.goldCurrency = tonumber(buf:readFloat()) --风雷币
	self.isHaveAdvPasswd = buf:readChar() --是否应有二级密码
	self.strNickNamebuf = encoding:iconv(buf:readStringUShort()) --昵称
end

wnet.ELobbyResult = {}
wnet.ELobbyResult[0] = "ELOBBY_RESULT_OK" --登陆成功
wnet.ELobbyResult[1] = "ELOBBY_RESULT_RELOGIN" --帐号已经登陆
wnet.ELobbyResult[2] = "ELOBBY_RESULT_PUNISH" --违反用户条例
wnet.ELobbyResult[3] = "ELOBBY_RESULT_BUSY" --系统繁忙
wnet.ELobbyResult[4] = "ELOBBY_RESULT_WRONGVALIDATE" --错误的验证码

wnet.SC_USERLOGIN_ACK = class("SC_USERLOGIN_ACK", lobbyUser)
function wnet.SC_USERLOGIN_ACK:ctor(code, uid, pnum, mapid, syncid)
	wnet.SC_USERLOGIN_ACK.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "SC_USERLOGIN_ACK"
	self.lobbyUser = lobbyUser.new()
end

function wnet.SC_USERLOGIN_ACK:bufferOut(buf)
	self.userID = buf:readUInt()
	self.lobbyResult = buf:readUInt()
	self.lobbyUser:bufferOut(buf)
end

function wnet.SC_USERLOGIN_ACK:toString()
	return self.name .. " " .. string.format("lobbyResult:%d, userID:%d, icon:%d, gender:%d, gameCurrency:%s, is:%d",
		self.lobbyResult, self.userID, self.lobbyUser.icon, self.lobbyUser.gender,
		i64_toString(self.lobbyUser.gameCurrency), self.lobbyUser.isHaveAdvPasswd) .. self.lobbyUser.strNickNamebuf
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
local serverInfo = class("ServerInfo")
function serverInfo:ctor()
end

function serverInfo:bufferOut(buf)
	self.srvIP = buf:readBuf(cc.MAX_IP_LENGTH)
	--print("self.srvIP "..self.srvIP)
	self.srvPort = buf:readUShort()
	self.srvID = buf:readInt()
	--print("self.srvID "..self.srvID)
	self.gateType = buf:readInt()
	--print("self.gateType "..self.gateType)
end

local gameInfo = class("GameInfo")
function gameInfo:ctor()
end

--游戏类型
wnet.Game_Type = {}
wnet.Game_Type[0] = "GameType_Currency" --游戏豆场
wnet.Game_Type[1] = "GameType_Score" --积分场
wnet.Game_Type[2] = "GameType_Train" --训练场
wnet.Game_Type[3] = "GameType_NoCheat" --防作弊场
wnet.Game_Type[4] = "GameType_NoCheatScore" --积分防作弊场
wnet.Game_Type[5] = "GameType_Match" --比赛场
wnet.Game_Type[6] = "GameType_Fossick" --淘金场
wnet.Game_Type[7] = "GameType_Fightlord_Challenge" --斗地主挑战赛
wnet.Game_Type[8] = "GameType_NewNoCheatCurrency" --新增加的防作弊游戏豆场
wnet.Game_Type[9] = "GameType_NewNoCheatScore" --新增加的防作弊积分场

--开始类型
wnet.Start_Type = {}
wnet.Start_Type[0] = "StartType_All" --全部坐满
wnet.Start_Type[1] = "StartType_Some"

function gameInfo:bufferOut(buf)
	self.gameID = buf:readShort()
	self.gameType = buf:readInt()
	self.typeName = encoding:iconv(buf:readStringUShort())
	self.gameName = encoding:iconv(buf:readStringUShort())
	self.chanelName = encoding:iconv(buf:readStringUShort())
	self.appName = encoding:iconv(buf:readStringUShort())
	self.roomMaxNum = buf:readShort()
	self.tableNum = buf:readShort()
	self.tablePlyNum = buf:readShort()
	self.reConn = buf:readChar()
	local gch = buf:readUInt()
	local gcl = buf:readUInt()
	self.moneyLimit = i64(gch, gcl)
	self.startType = buf:readInt()
	self.hancUpNum = buf:readChar()
	self.sortID = buf:readShort()
	self.tax = buf:readInt()
	self.onlineGive = buf:readInt()
	self.version = buf:readInt()
	self.downUrl = encoding:iconv(buf:readStringUShort())
	self.rightUrl = encoding:iconv(buf:readStringUShort())
	self.gameChanel = buf:readInt()
	self.nGameBet = buf:readInt()
end

local roomInfo = class("RoomInfo")
function roomInfo:ctor()
end

function roomInfo:bufferOut(buf)
	self.roomID = buf:readChar()
	self.szRoomName = encoding:iconv(buf:readStringUShort())
	print("self.szRoomName "..self.szRoomName)
	self.userNum = buf:readInt()
	self.roomIcon = encoding:iconv(buf:readStringUShort())
end

local gameTotalInfo = class("GameTotalInfo")
function gameTotalInfo:ctor()
end

function gameTotalInfo:bufferOut(buf)
	self.svrInfo = serverInfo.new()
	self.svrInfo:bufferOut(buf)

	self.gameInfo = gameInfo.new()
	self.gameInfo:bufferOut(buf)

	self.rmInfo = {}
	local _c = buf:readShort()
	for i = 1, _c, 1 do
		local _rmi = roomInfo.new()
		_rmi:bufferOut(buf)
		table.insert(self.rmInfo, _rmi)
	end
end

wnet.SC_GAMELIST_ACK = class("SC_GAMELIST_ACK", packBody)
function wnet.SC_GAMELIST_ACK:ctor(code, uid, pnum, mapid, syncid)
	self.name = "SC_GAMELIST_ACK"
	wnet.SC_GAMELIST_ACK.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end

function wnet.SC_GAMELIST_ACK:bufferOut(buf)
	self.vecGameInfo = {}
	local _c = buf:readShort()
	print("SC_GAMELIST_ACK ".._c)
	for i = 1, _c, 1 do
		local _gi = gameTotalInfo.new()
		_gi:bufferOut(buf)
		table.insert(self.vecGameInfo, _gi)
	end
end

function wnet.SC_GAMELIST_ACK:toString()
	print("gameList size is " .. #self.vecGameInfo)
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.CG_LOGIN_REQ = class("CG_LOGIN_REQ", packBody)
function wnet.CG_LOGIN_REQ:ctor(code, uid, pnum, mapid, syncid)
	self.name = "CG_LOGIN_REQ"
	wnet.CG_LOGIN_REQ.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end

function wnet.CG_LOGIN_REQ:bufferIn(roomid, passcode, mac)
	local buf = wnet.CG_LOGIN_REQ.super.bufferIn(self)
	buf:writeChar(roomid):writeStringUShort(passcode):writeStringUShort(mac or "")
	return buf
end

wnet.CL_TRAIL_LOGIN_REQ = class("CL_TRAIL_LOGIN_REQ", packBody)
function wnet.CL_TRAIL_LOGIN_REQ:ctor(code, uid, pnum, mapid, syncid)
	self.name = "CL_TRAIL_LOGIN_REQ"
	wnet.CL_TRAIL_LOGIN_REQ.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function wnet.CL_TRAIL_LOGIN_REQ:bufferIn(strTrailKey, strIP, gateType)
	local buf = wnet.CL_TRAIL_LOGIN_REQ.super.bufferIn(self)
	buf:writeStringUShort(strTrailKey or ""):writeStringUShort(strIP or ""):writeInt(gateType or 0)
	return buf
end

wnet.LC_TRAIL_LOGIN_ACK = class("LC_TRAIL_LOGIN_ACK", packBody)
function wnet.LC_TRAIL_LOGIN_ACK:ctor(code, uid, pnum, mapid, syncid)
	self.name = "LC_TRAIL_LOGIN_ACK"
	wnet.LC_TRAIL_LOGIN_ACK.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function wnet.LC_TRAIL_LOGIN_ACK:bufferOut(buf)
	self.loginRet = buf:readInt()
	self.userID = buf:readInt()
	self.strPassCode = buf:readStringUShort()
	self.serverID = buf:readInt()
	self.strIP = buf:readStringUShort()
	self.wPort = buf:readShort()
	self.lastLoginIP = buf:readStringUShort()
	self.lastLoginTime = buf:readInt()
	self.curLoginIP = buf:readStringUShort()
	self.curLoginTime = buf:readInt()
	self.leftTrailTime = buf:readInt()
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
local stUserData = class("stUserData")
function stUserData:ctor()
end

--用户身份
wnet.User_IDENT = {}
wnet.User_IDENT.UIDENT_NORMAL = 0                  --普通用户
wnet.User_IDENT.UIDENT_JUNIORGM = 1                    --初级客服
wnet.User_IDENT.UIDENT_MIDDLEGM = 2                    --中级客服
wnet.User_IDENT.UIDENT_SENIORGM = 3                    --高级客服
wnet.User_IDENT.UIDENT_TRIAL = 10                  --试玩用户
wnet.User_IDENT.UIDENT_REFEREE = 11                --裁判用户
wnet.User_IDENT.UIDENT_NUM = 12


function stUserData:bufferOut(buf)
	self.userID = buf:readInt()
	self.ident = buf:readInt()
	self.gmPur = buf:readInt()
	self.icon = buf:readShort()
	self.gender = buf:readChar()
	self.vipExp = buf:readInt()
	self.vipBegin = buf:readInt()
	self.vipEnd = buf:readInt()
	self.vipLevel = buf:readChar()
	self.honor = buf:readInt()
	self.honorLevel = buf:readChar()
	local gch = buf:readUInt()
	local gcl = buf:readUInt()
	self.gameCurrency = i64(gch, gcl)
	--print("i64 "..i64_toInt(self.gameCurrency))
	self.strNickName = encoding:iconv(buf:readStringUShort())
end


local stGameData = class("stGameData")
function stGameData:ctor()
end

wnet.EUserStatus = {}
wnet.EUserStatus.EGAME_STATUS_NULL = 0
wnet.EUserStatus.EGAME_STATUS_LOADING = 1
wnet.EUserStatus.EGAME_STATUS_ROOM = 2
wnet.EUserStatus.EGAME_STATUS_TABLE = 3
wnet.EUserStatus.EGAME_STATUS_READY = 4
wnet.EUserStatus.EGAME_STATUS_GAMEING = 5
wnet.EUserStatus.EGAME_STATUS_WATCH = 6
wnet.EUserStatus.EGAME_STATUS_BOKEN = 7
wnet.EUserStatus.EGAME_STATUS_BOKENTIMEOUT = 8
wnet.EUserStatus.EGAME_STATUS_WAITING = 9
wnet.EUserStatus.EGAME_STATUS_RUNBYNOBROKEN = 10
wnet.EUserStatus.EGAME_STATUS_MATCH = 11


function stGameData:bufferOut(buf)
	self.userStatus = buf:readInt()
	self.tableID = buf:readChar()
	self.chairID = buf:readChar()
	self.nScore = buf:readInt()
	self.nWin = buf:readInt()
	self.nLose = buf:readInt()
	self.nDraw = buf:readInt()
	self.nDisc = buf:readInt()
end


wnet.EGameResult = {}
wnet.EGameResult.EGAME_RESULT_OK = 0                          --登陆成功
wnet.EGameResult.EGAME_RESULT_RELOGIN = 1                     --重复登录
wnet.EGameResult.EGAME_RESULT_NUMOVER = 2                     --房间已满
wnet.EGameResult.EGAME_RESULT_ILLEGAL =3                      --非法登陆
wnet.EGameResult.EGAME_RESULT_PUNISH = 4                      --违反用户条例，暂时不能进入
wnet.EGameResult.EGAME_RESULT_WAIT = 5                        --游戏维护, 稍后进入
wnet.EGameResult.EGAME_RESULT_BUSY = 6                        --系统繁忙
wnet.EGameResult.EGAME_RESULT_NOTRAIL = 7                     --试玩玩家不能进入


wnet.PL_PHONE_GC_LOGIN_ACK = class("PL_PHONE_GC_LOGIN_ACK", packBody)
function wnet.PL_PHONE_GC_LOGIN_ACK:ctor(code, uid, pnum, mapid, syncid)
	self.name = "PL_PHONE_GC_LOGIN_ACK"
	wnet.PL_PHONE_GC_LOGIN_ACK.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end

function wnet.PL_PHONE_GC_LOGIN_ACK:bufferOut(buf)
	self.bRet = buf:readInt()
	self.userID = buf:readInt()
	self.gameData = stGameData.new()
	self.gameData:bufferOut(buf)
	self.svrID = buf:readInt()
	self.roomID = buf:readChar()
end

function wnet.PL_PHONE_GC_LOGIN_ACK:toString()
	return self.name .. " " .. string.format("bRet:%d, svrID:%d, roomID:%d",
		self.bRet, self.svrID, self.roomID)
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.PL_PHONE_CG_ROOM_USERLIST = class("PL_PHONE_CG_ROOM_USERLIST", packBody)
function wnet.PL_PHONE_CG_ROOM_USERLIST:ctor(code, uid, pnum, mapid, syncid)
	self.name = "PL_PHONE_CG_ROOM_USERLIST"
	wnet.PL_PHONE_CG_ROOM_USERLIST.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end

function wnet.PL_PHONE_CG_ROOM_USERLIST:bufferIn(start, count)
	local buf = wnet.PL_PHONE_CG_ROOM_USERLIST.super.bufferIn(self)
	buf:writeInt(start):writeInt(count)
	return buf
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.BROKEN_GAME_LIST = class("BROKEN_GAME_LIST", packBody)
function wnet.BROKEN_GAME_LIST:ctor(code, uid, pnum, mapid, syncid)
	self.name = "BROKEN_GAME_LIST"
	wnet.BROKEN_GAME_LIST.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function wnet.BROKEN_GAME_LIST:bufferOut(buf)
	self.vList = {}
	local vListSize = buf:readShort()
	print("vListSize = " ..vListSize)
	for i = 1, vListSize do
		local tmp = {}
		tmp.gameId = buf:readShort()
		tmp.srvId = buf:readInt()
		tmp.roomId = buf:readChar()
		self.vList[#self.vList + 1] = tmp
	end
end
------------------------------------------------------------------------------
local stGameUser = class("stGameUser")
function stGameUser:ctor()
	self.userData = stUserData.new()
	self.gameData = stGameData.new()
end

function stGameUser:bufferOut(buf)
	self.userData:bufferOut(buf)
	self.gameData:bufferOut(buf)
end

wnet.GC_ROOM_USERLIST = class("GC_ROOM_USERLIST", packBody)
function wnet.GC_ROOM_USERLIST:ctor(code, uid, pnum, mapid, syncid)
	self.name = "GC_ROOM_USERLIST"
	wnet.GC_ROOM_USERLIST.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end

function wnet.GC_ROOM_USERLIST:bufferOut(buf)
	self.roomID = buf:readChar()
	local _c = buf:readShort()
	self.userList = {}
	for i = 1, _c, 1 do
		local _gi = stGameUser.new()
		_gi:bufferOut(buf)
		table.insert(self.userList, _gi)
	end
end

function wnet.GC_ROOM_USERLIST:toString()
	print("userList size is " .. #self.userList)
end

------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.ETableStatus = {}
wnet.ETableStatus.ETABLE_STATUS_NULL = 0                    --为空桌子状态
wnet.ETableStatus.ETABLE_STATUS_WAIT = 1                        --为开始游戏，等待状态
wnet.ETableStatus.ETABLE_STATUS_WAITLOCK = 2                    --锁桌子等待状态
wnet.ETableStatus.ETABLE_STATUS_GAMING = 3                      --游戏状态
wnet.ETableStatus.ETABLE_STATUS_GAMINGLOCK = 4                  --锁桌游戏状态

local stTableStatus = class("stTableStatus")
function stTableStatus:ctor()
end

function stTableStatus:bufferOut(buf)
	self.tableID = buf:readChar()
	self.status = buf:readChar()
end

wnet.GC_TABLE_STATUSLIST = class("GC_TABLE_STATUSLIST", packBody)
function wnet.GC_TABLE_STATUSLIST:ctor(code, uid, pnum, mapid, syncid)
	self.name = "GC_TABLE_STATUSLIST"
	wnet.GC_TABLE_STATUSLIST.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end

function wnet.GC_TABLE_STATUSLIST:bufferOut(buf)
	local _c = buf:readShort()
	self.statusList = {}
	for i = 1, _c, 1 do
		local _ti = stTableStatus.new()
		_ti:bufferOut(buf)
		table.insert(self.statusList, _ti)
	end
end

function wnet.GC_TABLE_STATUSLIST:toString()
	print("table status List size is " .. #self.statusList)
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.GC_TABLE_STATUS_UP = class("GC_TABLE_STATUS_UP", packBody)
function wnet.GC_TABLE_STATUS_UP:ctor(code, uid, pnum, mapid, syncid)
	self.name = "GC_TABLE_STATUS_UP"
	wnet.GC_TABLE_STATUSLIST.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function wnet.GC_TABLE_STATUS_UP:bufferOut(buf)
	self.tableID = buf:readChar()
	self.status = buf:readInt()
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.PL_PHONE_GC_ENTERTABLE = class("PL_PHONE_GC_ENTERTABLE", packBody)
function wnet.PL_PHONE_GC_ENTERTABLE:ctor(code, uid, pnum, mapid, syncid)
	self.name = "PL_PHONE_GC_ENTERTABLE"
	wnet.PL_PHONE_GC_ENTERTABLE.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function wnet.PL_PHONE_GC_ENTERTABLE:bufferOut(buf)
	self.gameUser = stGameUser.new()
	self.gameUser:bufferOut(buf)
	self.tableID = buf:readChar()
	self.chairID = buf:readChar()
	self.isOB = buf:readChar()
	self.setBet = buf:readInt()
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.GC_LEAVETABLE = class("GC_LEAVETABLE", packBody)
function wnet.GC_LEAVETABLE:ctor(code, uid, pnum, mapid, syncid)
	self.name = "GC_LEAVETABLE"
	wnet.GC_LEAVETABLE.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function wnet.GC_LEAVETABLE:bufferOut(buf)
	self.userID = buf:readInt()
	self.isOB = buf:readChar()
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------

wnet.Attr_Entry = {}
wnet.Attr_Entry.eAttrEntry_Null = 0
wnet.Attr_Entry.eAttrEntry_Money = 1                         --更新游戏豆
wnet.Attr_Entry.eAttrEntry_Score = 2                         --更新积分
wnet.Attr_Entry.eAttrEntry_Status = 3                        --更新状态
wnet.Attr_Entry.eAttrEntry_Win = 4                           --更新赢局
wnet.Attr_Entry.eAttrEntry_Lose = 5                          --更新输局
wnet.Attr_Entry.eAttrEntry_Draw = 6                          --更新平局
wnet.Attr_Entry.eAttrEntry_Disc = 7                          --更新断线
wnet.Attr_Entry.eAttrEntry_Train = 8                         --更新练习币
wnet.Attr_Entry.eAtrrEntry_GameMoney = 9					 --类似于德州扑克更新小游戏内携带的游戏豆
wnet.Attr_Entry.eAttrEntry_Num = 10

local stAttr = class("stAttr")
function stAttr:ctor()

end

function stAttr:bufferOut(buf)
	self.attrEntry = buf:readChar()
	self.attrValue = buf:readInt()
end

wnet.GC_GAMEUSER_UP = class("GC_GAMEUSER_UP", packBody)
function wnet.GC_GAMEUSER_UP:ctor(code, uid, pnum, mapid, syncid)
	self.name = "GC_GAMEUSER_UP"
	wnet.GC_GAMEUSER_UP.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function wnet.GC_GAMEUSER_UP:bufferOut(buf)
	self.userID = buf:readInt()
	local _c = buf:readShort()
	self.attrList = {}
	for i = 1, _c, 1 do
		local _ti = stAttr.new()
		_ti:bufferOut(buf)
		table.insert(self.attrList, _ti)
	end
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.EnterTable_Result = {}
wnet.EnterTable_Result.EnterTable_OK = 0                           --加入成功
wnet.EnterTable_Result.EnterTable_OB = 1                           --旁观加入
wnet.EnterTable_Result.EnterTable_Wait = 2                         --排队中
wnet.EnterTable_Result.EnterTable_BeOccupyeed = 3                      --已经有人，且游戏未开始，不能旁观
wnet.EnterTable_Result.EnterTable_MoneyLimit = 4                       --游戏豆不足
wnet.EnterTable_Result.EnterTable_WrongPasswd = 5                      --错误的密码
wnet.EnterTable_Result.EnterTable_ForbidMinWin = 6                     --不满足其它玩家的最小胜率要求
wnet.EnterTable_Result.EnterTable_ForbidMaxDisc = 7                    --不满足其它玩家的最大断线率要求
wnet.EnterTable_Result.EnterTable_ForbidMaxDelay = 8                   --不满足其它玩家的最大延迟要求
wnet.EnterTable_Result.EnterTable_ForbidMinScore = 9                   --不满足其它玩家的最小积分或者游戏豆要求
wnet.EnterTable_Result.EnterTable_ForbidIp = 10                         --不满足其它的玩家的同ip限制要求
wnet.EnterTable_Result.EnterTable_GameFix = 11                          --游戏维护，暂时不能进入（一般是在解散房间后3分钟内无法入座）
wnet.EnterTable_Result.EnterTable_Busy = 12                             --未知原因
wnet.EnterTable_Result.EnterTable_GainOver = 13                         --输过上限， 当天不能继续游戏
wnet.EnterTable_Result.EnterTable_NoTrail = 14                          --试玩玩家不能加入游戏豆类游戏
wnet.EnterTable_Result.EnterTable_Gaming = 15                           --游戏正在进行，不能加入
wnet.EnterTable_Result.EnterTable_WatchNumLimit = 16                    --旁观人数已到上限
wnet.EnterTable_Result.EnterTable_ScoreLimit = 17                       --积分不足
wnet.EnterTable_Result.EnterTable_UnForbidBlock = 18                   --不满足其它会员玩家的不和不受欢迎的用户玩要求不能加入          
wnet.EnterTable_Result.EnterTable_CanForbidBlock = 19              --不满足其它会员玩家的不和不受欢迎的用户玩要求可以加入
wnet.EnterTable_Result.EnterTable_VipUnForbidBlock = 20              --根据会员等级比较不满足其它会员玩家的不和不受欢迎的用户玩要求不能加入
wnet.EnterTable_Result.EnterTable_ReEnterTable = 21                    --重复入桌
wnet.EnterTable_Result.EnterTalbe_ForbidSetCustomMinScore = 22         --不满足其它玩家的设置底注游戏豆要求
wnet.EnterTable_Result.EnterTable_RoomExists = 23         --房间已经存在

wnet.CG_ENTERTABLE_REQ = class("CG_ENTERTABLE_REQ", packBody)
function wnet.CG_ENTERTABLE_REQ:ctor(code, uid, pnum, mapid, syncid)
	self.name = "CG_ENTERTABLE_REQ"
	wnet.CG_ENTERTABLE_REQ.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end

function wnet.CG_ENTERTABLE_REQ:bufferIn(tableid, chairid, password)
	local buf = wnet.CG_ENTERTABLE_REQ.super.bufferIn(self)
	buf:writeChar(tableid):writeChar(chairid):writeStringUShort(password or "")
	return buf
end

wnet.GC_ENTERTABLE_ACK = class("GC_ENTERTABLE_ACK", packBody)
function wnet.GC_ENTERTABLE_ACK:ctor(code, uid, pnum, mapid, syncid)
	self.name = "GC_ENTERTABLE_ACK"
	wnet.GC_ENTERTABLE_ACK.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end

function wnet.GC_ENTERTABLE_ACK:bufferOut(buf)
	self.result = buf:readInt()
	self.forbidID = buf:readInt()
	self.lineUpTime = buf:readInt()
	self.minGameCurrency = buf:readInt()
end

wnet.CG_LEAVETABLE_REQ = class("CG_LEAVETABLE_REQ", packBody)
function wnet.CG_LEAVETABLE_REQ:ctor(code, uid, pnum, mapid, syncid)
	self.name = "CG_ENTERTABLE_REQ"
	wnet.CG_LEAVETABLE_REQ.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end

function wnet.CG_LEAVETABLE_REQ:bufferIn()
	local buf = wnet.CG_LEAVETABLE_REQ.super.bufferIn(self)
	return buf
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.CG_HANDUP = class("CG_HANDUP", packBody)
function wnet.CG_HANDUP:ctor(code, uid, pnum, mapid, syncid)
	wnet.CG_HANDUP.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "CG_HANDUP"
end
function wnet.CG_HANDUP:bufferIn()
	local buf = wnet.CG_HANDUP.super.bufferIn(self)
	return buf
end

wnet.GC_HANDUP = class("GC_HANDUP", packBody)
function wnet.GC_HANDUP:ctor(code, uid, pnum, mapid, syncid)
	wnet.GC_HANDUP.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "GC_HANDUP"
end
function wnet.GC_HANDUP:bufferOut(buf)
	self.chairID = buf:readChar()
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.GC_STARTTIMER = class("GC_STARTTIMER", packBody)
function wnet.GC_STARTTIMER:ctor(code, uid, pnum, mapid, syncid)
	wnet.GC_STARTTIMER.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "GC_STARTTIMER"
end
function wnet.GC_STARTTIMER:bufferOut(buf)
	self.timeEvent = buf:readInt()
	self.timeSec = buf:readInt()
	self.chairID = buf:readChar()
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.GC_TABLE_USERLIST = class("GC_TABLE_USERLIST", packBody)
function wnet.GC_TABLE_USERLIST:ctor(code, uid, pnum, mapid, syncid)
	wnet.GC_TABLE_USERLIST.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "GC_TABLE_USERLIST"
end
function wnet.GC_TABLE_USERLIST:bufferOut(buf)
	local _c = buf:readShort()
	self.userList = {}
	for i = 1, _c, 1 do
		local _ti = stGameUser.new()
		_ti:bufferOut(buf)
		table.insert(self.userList, _ti)
	end
end
------------------------------------------------------------------------------


----------------------------个人中心 起----------------------------------------
------------------------------------------------------------------------------
wnet.VipOp_Result = {}
wnet.VipOp_Result.VipResult_OK = 0
wnet.VipOp_Result.VipResult_LessMoney = 1
wnet.VipOp_Result.VipResult_LessGold = 2
wnet.VipOp_Result.VipResult_MoneyLock = 3
wnet.VipOp_Result.VipResult_WrongSePass = 4

wnet.CS_VIP_PAY = class("CS_VIP_PAY", packBody)
function wnet.CS_VIP_PAY:ctor(code, uid, pnum, mapid, syncid)
	wnet.CS_VIP_PAY.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "CS_VIP_PAY"
end
function wnet.CS_VIP_PAY:bufferIn(month, payType, opType, szSePasswd)
	local buf = wnet.CS_VIP_PAY.super.bufferIn(self)
	buf:writeChar(month):writeChar(payType):writeChar(opType):writeStringUShort(szSePasswd or "")
	return buf
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.stVipData = class("stVipData")
function wnet.stVipData:ctor()
end
function wnet.stVipData:bufferOut(buf)
	self.vipExp = buf:readInt()
	self.vipBegin = buf:readInt()
	self.vipEnd = buf:readInt()
	self.vipLevel = buf:readChar()
	self.vipUp = buf:readInt()
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.VipOp_Result = {}
wnet.VipOp_Result.VipResult_OK = 0
wnet.VipOp_Result.VipResult_LessMoney = 1
wnet.VipOp_Result.VipResult_LessGold = 2
wnet.VipOp_Result.VipResult_MoneyLock = 3
wnet.VipOp_Result.VipResult_WrongSePass = 4

wnet.SC_VIP_PAY = class("SC_VIP_PAY", packBody)
function wnet.SC_VIP_PAY:ctor(code, uid, pnum, mapid, syncid)
	wnet.SC_VIP_PAY.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "SC_VIP_PAY"
	self.vipData = wnet.stVipData.new()
end
function wnet.SC_VIP_PAY:bufferOut(buf)
	self.ret = buf:readChar()
	local mch = buf:readUInt()
	local mcl = buf:readUInt()
	self.money = i64(mch, mcl) --游戏豆
	self.gold = buf:readFloat()	--风雷/福乐 币
	self.vipData:bufferOut(buf)
	self.month = buf:readChar()
	self.payType = buf:readChar()
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.CS_CHANGE_PASSWD = class("CS_CHANGE_PASSWD", packBody)
function wnet.CS_CHANGE_PASSWD:ctor(code, uid, pnum, mapid, syncid)
	wnet.CS_CHANGE_PASSWD.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "CS_CHANGE_PASSWD"
end
function wnet.CS_CHANGE_PASSWD:bufferIn(old, newPass)
	local buf = wnet.CS_CHANGE_PASSWD.super.bufferIn(self)
	buf:writeStringUShort(old or ""):writeStringUShort(newPass or "")
	return buf
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.SC_CHANGE_PASSWD = class("SC_CHANGE_PASSWD", packBody)
function wnet.SC_CHANGE_PASSWD:ctor(code, uid, pnum, mapid, syncid)
	wnet.SC_CHANGE_PASSWD.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "SC_CHANGE_PASSWD"
end
function wnet.SC_CHANGE_PASSWD:bufferOut(buf)
	self.ret = buf:readChar()
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.CS_CREATE_SEPASSWD = class("CS_CREATE_SEPASSWD", packBody)
function wnet.CS_CREATE_SEPASSWD:ctor(code, uid, pnum, mapid, syncid)
	wnet.CS_CREATE_SEPASSWD.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "CS_CREATE_SEPASSWD"
end
function wnet.CS_CREATE_SEPASSWD:bufferIn(sePass, cardType, card, ask, asw)
	local buf = wnet.CS_CREATE_SEPASSWD.super.bufferIn(self)
	buf:writeStringUShort(sePass or ""):writeStringUShort(decoding:iconv(cardType) or "")
	buf:writeStringUShort(decoding:iconv(card) or ""):writeStringUShort(decoding:iconv(ask) or ""):writeStringUShort(decoding:iconv(asw) or "")
	return buf
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.SC_CREATE_SEPASSWD = class("SC_CREATE_SEPASSWD", packBody)
function wnet.SC_CREATE_SEPASSWD:ctor(code, uid, pnum, mapid, syncid)
	wnet.SC_CREATE_SEPASSWD.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "SC_CREATE_SEPASSWD"
end
function wnet.SC_CREATE_SEPASSWD:bufferOut(buf)
	self.ret = buf:readChar()
	self.awardCurrency = buf:readInt()
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.CS_CHANGE_SEPWD = class("CS_CHANGE_SEPWD", packBody)
function wnet.CS_CHANGE_SEPWD:ctor(code, uid, pnum, mapid, syncid)
	wnet.CS_CHANGE_SEPWD.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "CS_CHANGE_SEPWD"
end
function wnet.CS_CHANGE_SEPWD:bufferIn(sePass, cardType, card, ask, asw)
	local buf = wnet.CS_CHANGE_SEPWD.super.bufferIn(self)
	buf:writeStringUShort(""):writeStringUShort(sePass or ""):writeStringUShort(decoding:iconv(cardType) or "")
	buf:writeStringUShort(decoding:iconv(card) or ""):writeStringUShort(decoding:iconv(ask) or ""):writeStringUShort(decoding:iconv(asw) or "")
	return buf
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.SC_CHANGE_SEPWD = class("SC_CHANGE_SEPWD", packBody)
function wnet.SC_CHANGE_SEPWD:ctor(code, uid, pnum, mapid, syncid)
	wnet.SC_CHANGE_SEPWD.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "SC_CHANGE_SEPWD"
end
function wnet.SC_CHANGE_SEPWD:bufferOut(buf)
	self.ret = buf:readChar()
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.CS_CHANGE_NICKNAME = class("CS_CHANGE_NICKNAME", packBody)
function wnet.CS_CHANGE_NICKNAME:ctor(code, uid, pnum, mapid, syncid)
	wnet.CS_CHANGE_NICKNAME.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "CS_CHANGE_NICKNAME"
end
function wnet.CS_CHANGE_NICKNAME:bufferIn(gender, nickName, icon)
	local buf = wnet.CS_CHANGE_NICKNAME.super.bufferIn(self)
	buf:writeChar(gender):writeStringUShort(decoding:iconv(nickName) or ""):writeShort(icon)
	return buf
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.eChangeNickName_Result = {}
wnet.eChangeNickName_Result.eChangeNickName_Ok = 0         	--修改昵称成功
wnet.eChangeNickName_Result.eChangeNickName_Exists = 1     	--昵称已经存在
wnet.eChangeNickName_Result.eChangeNickName_Forbid = 2     	--名字非法
wnet.eChangeNickName_Result.eChangeNickName_Num = 3

wnet.SC_CHANGE_NICKNAME = class("SC_CHANGE_NICKNAME", packBody)
function wnet.SC_CHANGE_NICKNAME:ctor(code, uid, pnum, mapid, syncid)
	wnet.SC_CHANGE_NICKNAME.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "SC_CHANGE_NICKNAME"
end
function wnet.SC_CHANGE_NICKNAME:bufferOut(buf)
	self.ret = buf:readChar()
	self.gender = buf:readChar()
	self.nickName = encoding:iconv(buf:readStringUShort())
	self.icon = buf:readShort()
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.stPhoneBindInfo = class("stPhoneBindInfo")
function wnet.stPhoneBindInfo:ctor()
	self.userID = 0
	self.status = -1
end
function wnet.stPhoneBindInfo:bufferOut(buf)
	self.userID = buf:readInt()
	self.strPhone = encoding:iconv(buf:readStringUShort())
	self.status = buf:readInt()
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.LC_PHONECODE_GET_VALIDATECODE_REQ = class("LC_PHONECODE_GET_VALIDATECODE_REQ", packBody)
function wnet.LC_PHONECODE_GET_VALIDATECODE_REQ:ctor(code, uid, pnum, mapid, syncid)
	wnet.LC_PHONECODE_GET_VALIDATECODE_REQ.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "LC_PHONECODE_GET_VALIDATECODE_REQ"
end
function wnet.LC_PHONECODE_GET_VALIDATECODE_REQ:bufferIn(strPhone, smsOperType,startTimes)
	local buf = wnet.LC_PHONECODE_GET_VALIDATECODE_REQ.super.bufferIn(self)
	buf:writeStringUShort(strPhone or ""):writeInt(smsOperType):writeChar(startTimes)
	return buf
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.Phone_GetValidateCode_Result = {}
wnet.Phone_GetValidateCode_Result.Phone_GetValidateCode_Result_Ok = 0    --成功
wnet.Phone_GetValidateCode_Result.Phone_GetValidateCode_Result_Fail = 1    --失败
wnet.Phone_GetValidateCode_Result.Phone_GetValidateCode_Result_FullTimes = 2    --获取次数已满
wnet.Phone_GetValidateCode_Result.Phone_GetValidateCode_Result_Busy = 3    --系统繁忙
wnet.Phone_GetValidateCode_Result.Phone_GetValidateCode_Result_TenThreeTime = 4    --十分钟内超过三次
wnet.Phone_GetValidateCode_Result.Phone_GetValidateCode_Result_OutBindLimit = 5    --超过绑定上限
wnet.Phone_GetValidateCode_Result.Phone_GetValidateCode_Result_Binded = 6    --已经被绑定
wnet.Phone_GetValidateCode_Result.Phone_GetValidateCode_Result_DayBinded = 7    --该用户当天已经绑定
wnet.Phone_GetValidateCode_Result.Phone_GetValidateCode_Result_OnlyAccount = 8    --一个手机号只能绑定一个账号
wnet.Phone_GetValidateCode_Result.Phone_GetValidateCode_Result_DayBindOnePhone = 9    --一个用户当天只能绑定一个手机号
wnet.Phone_GetValidateCode_Result.Phone_GetValidateCode_Result_TimeLimit = 10    --没有超过24小时，不能解除绑定
wnet.Phone_GetValidateCode_Result.Phone_GetValidateCode_Result_Other = 11    --其它原因

wnet.Sms_Operator_Type = {}
wnet.Sms_Operator_Type.Sms_Operator_Type_None = 0    --无操作
wnet.Sms_Operator_Type.Sms_Operator_Type_GetValidateCode = 1    --注册获取验证码
wnet.Sms_Operator_Type.Sms_Operator_Type_BindPhoneCode = 2    --绑定手机号获取验证码
wnet.Sms_Operator_Type.Sms_Operator_Type_RemoveBindPhoneCode = 3    --解除绑定手机号获取验证码
wnet.Sms_Operator_Type.Sms_Operator_Type_SetPhoneCodeLogin = 4    --设置手机号登陆获取验证码
wnet.Sms_Operator_Type.Sms_Operator_Type_CancelLoginValiCode = 5    --取消设置登录需要手机验证码
wnet.Sms_Operator_Type.Sms_Operator_Type_UserPhoneValiCodeLogin = 6    --使用手机验证码登陆
wnet.Sms_Operator_Type.Sms_Operator_Type_InviteReg = 7    --邀请注册

wnet.LC_PHONECODE_GET_VALIDATECODE_ACK = class("SC_PHONE_VALID", packBody)
function wnet.LC_PHONECODE_GET_VALIDATECODE_ACK:ctor(code, uid, pnum, mapid, syncid)
	wnet.LC_PHONECODE_GET_VALIDATECODE_ACK.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "LC_PHONECODE_GET_VALIDATECODE_ACK"
end
function wnet.LC_PHONECODE_GET_VALIDATECODE_ACK:bufferOut(buf)
	self.strCode = encoding:iconv(buf:readStringUShort())
	self.validCode = buf:readUInt()
	self.nResult = buf:readInt()
	self.smsOperType = buf:readInt()
	self.endTime = buf:readUInt()
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.CS_PHONE_BIND = class("CS_PHONE_BIND", packBody)
function wnet.CS_PHONE_BIND:ctor(code, uid, pnum, mapid, syncid)
	wnet.CS_PHONE_BIND.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "CS_PHONE_BIND"
end
function wnet.CS_PHONE_BIND:bufferIn(strPhone, strValid)
	local buf = wnet.CS_PHONE_BIND.super.bufferIn(self)
	buf:writeStringUShort(strPhone or ""):writeStringUShort(strValid or "")
	return buf
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.ePhoneBind_Result = {}
wnet.ePhoneBind_Result.ePhoneBind_Ok = 0
wnet.ePhoneBind_Result.ePhoneBind_WrongValid = 1
wnet.ePhoneBind_Result.ePhoneBind_Num = 2

wnet.SC_PHONE_BIND = class("SC_PHONE_BIND", packBody)
function wnet.SC_PHONE_BIND:ctor(code, uid, pnum, mapid, syncid)
	wnet.SC_PHONE_BIND.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "SC_PHONE_BIND"
end
function wnet.SC_PHONE_BIND:bufferOut(buf)
	self.ret = buf:readChar()
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.CS_PHONE_UNBIND = class("CS_PHONE_UNBIND", packBody)
function wnet.CS_PHONE_UNBIND:ctor(code, uid, pnum, mapid, syncid)
	wnet.CS_PHONE_UNBIND.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "CS_PHONE_UNBIND"
end
function wnet.CS_PHONE_UNBIND:bufferIn(strValid)
	local buf = wnet.CS_PHONE_UNBIND.super.bufferIn(self)
	buf:writeStringUShort(strValid or "")
	return buf
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.ePhoneUnBind_Result = {}
wnet.ePhoneUnBind_Result.ePhoneUnBind_Ok = 0
wnet.ePhoneUnBind_Result.ePhoneUnBind_WrongValid = 1
wnet.ePhoneUnBind_Result.ePhoneUnBind_Num = 2

wnet.SC_PHONE_UNBIND = class("SC_PHONE_UNBIND", packBody)
function wnet.SC_PHONE_UNBIND:ctor(code, uid, pnum, mapid, syncid)
	wnet.SC_PHONE_UNBIND.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "SC_PHONE_UNBIND"
end
function wnet.SC_PHONE_UNBIND:bufferOut(buf)
	self.ret = buf:readChar()
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.Phone_CheckUser_BindPhone_Result = {}
wnet.Phone_CheckUser_BindPhone_Result.Phone_CheckUser_BindPhone_Result_UnBind = 0--未绑定
wnet.Phone_CheckUser_BindPhone_Result.Phone_CheckUser_BindPhone_Result_Binded = 1--已经绑定
wnet.Phone_CheckUser_BindPhone_Result.Phone_CheckUser_BindPhone_Result_UsePhoneCodeLogin = bit.blshift(1, 1)--使用手机号登录
wnet.Phone_CheckUser_BindPhone_Result.Phone_CheckUser_BindPhone_Result_UserPhoneValLogin = bit.blshift(1, 2)--使用手机验证码登录

wnet.SC_GETPHONECODEBIND_RESULT = class("SC_GETPHONECODEBIND_RESULT", packBody)
function wnet.SC_GETPHONECODEBIND_RESULT:ctor(code, uid, pnum, mapid, syncid)
	wnet.SC_GETPHONECODEBIND_RESULT.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "SC_GETPHONECODEBIND_RESULT"
end
function wnet.SC_GETPHONECODEBIND_RESULT:bufferOut(buf)
	self.nResult = buf:readInt()
	self.strCode = buf:readStringUShort()
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.CL_CHECK_PHONECODE = class("CL_CHECK_PHONECODE", packBody)
function wnet.CL_CHECK_PHONECODE:ctor(code, uid, pnum, mapid, syncid)
	wnet.CL_CHECK_PHONECODE.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "CL_CHECK_PHONECODE"
end
function wnet.CL_CHECK_PHONECODE:bufferIn(strPhone)
	local buf = wnet.CL_CHECK_PHONECODE.super.bufferIn(self)
	buf:writeStringUShort(strPhone or "")
	return buf
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.Phone_Reg_CheckPhoneCode_Result = {}
wnet.Phone_Reg_CheckPhoneCode_Result.Phone_Reg_CheckPhoneCode_Result_Ok = 0    --成功
wnet.Phone_Reg_CheckPhoneCode_Result.Phone_Reg_CheckPhoneCode_Result_RePhoneCode = 1    --电话号码重复
wnet.Phone_Reg_CheckPhoneCode_Result.Phone_Reg_CheckPhoneCode_Result_Used = 2    --手机号码已经被使用
wnet.Phone_Reg_CheckPhoneCode_Result.Phone_Reg_CheckPhoneCode_Result_Other = 3    --其它原因失败

wnet.LC_CHECK_PHONECODE = class("LC_CHECK_PHONECODE", packBody)
function wnet.LC_CHECK_PHONECODE:ctor(code, uid, pnum, mapid, syncid)
	wnet.LC_CHECK_PHONECODE.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "LC_CHECK_PHONECODE"
end
function wnet.LC_CHECK_PHONECODE:bufferOut(buf)
	self.strCode = encoding:iconv(buf:readStringUShort())
	self.nResult = buf:readInt()
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.CL_CHECK_PHONEVALIDATECODE_REQ = class("CL_CHECK_PHONEVALIDATECODE_REQ", packBody)
function wnet.CL_CHECK_PHONEVALIDATECODE_REQ:ctor(code, uid, pnum, mapid, syncid)
	wnet.CL_CHECK_PHONEVALIDATECODE_REQ.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "CL_CHECK_PHONEVALIDATECODE_REQ"
end
function wnet.CL_CHECK_PHONEVALIDATECODE_REQ:bufferIn(strCode, validCode, smsOperType)
	local buf = wnet.CL_CHECK_PHONEVALIDATECODE_REQ.super.bufferIn(self)
	buf:writeStringUShort(strCode or ""):writeUInt(validCode):writeInt(smsOperType)
	return buf
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.Phone_CheckPhoneValidateCode_Result = {}
wnet.Phone_CheckPhoneValidateCode_Result.Phone_CheckPhoneValidateCode_Result_Ok = 0--成功
wnet.Phone_CheckPhoneValidateCode_Result.Phone_CheckPhoneValidateCode_Result_Error = 1--失败
wnet.Phone_CheckPhoneValidateCode_Result.Phone_CheckPhoneValidateCode_Result_DisValidate = 2--已过有效期
wnet.Phone_CheckPhoneValidateCode_Result.Phone_CheckPhoneValidateCode_Result_Other = 3--其它原因

wnet.LC_CHECK_PHONEVALIDATECODE_ACK = class("LC_CHECK_PHONEVALIDATECODE_ACK", packBody)
function wnet.LC_CHECK_PHONEVALIDATECODE_ACK:ctor(code, uid, pnum, mapid, syncid)
	wnet.LC_CHECK_PHONEVALIDATECODE_ACK.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "LC_CHECK_PHONEVALIDATECODE_ACK"
end
function wnet.LC_CHECK_PHONEVALIDATECODE_ACK:bufferOut(buf)
	self.strCode = encoding:iconv(buf:readStringUShort())
	self.valideCode = encoding:iconv(buf:readStringUShort())
	self.nResult = buf:readInt()
	self.autoAccount = encoding:iconv(buf:readStringUShort())
	self.phoneReg = buf:readChar()
	self.smsOperType = buf:readInt()
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.Phone_Bind_Result = {}
wnet.Phone_Bind_Result.Phone_Bind_Result_Ok = 0--成功
wnet.Phone_Bind_Result.Phone_Bind_Result_Fail = 1--失败
wnet.Phone_Bind_Result.Phone_Bind_Result_Binded = 2--已经被绑定
wnet.Phone_Bind_Result.Phone_Bind_Result_UnGetAward = 3--绑定成功但是不能获取奖励（非第一次绑定）
wnet.Phone_Bind_Result.Phone_Bind_Result_DayBinded = 4--该用户当天已经绑定
wnet.Phone_Bind_Result.Phone_Bind_Result_OnlyAccount = 5--一个手机号只能绑定一个账号
wnet.Phone_Bind_Result.Phone_Bind_Result_DayBindOnePhone = 6--一个用户当天只能绑定一个手机号

wnet.SC_PHONECODEBIND_ACK = class("SC_PHONECODEBIND_ACK", packBody)
function wnet.SC_PHONECODEBIND_ACK:ctor(code, uid, pnum, mapid, syncid)
	wnet.SC_PHONECODEBIND_ACK.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "SC_PHONECODEBIND_ACK"
end
function wnet.SC_PHONECODEBIND_ACK:bufferOut(buf)
	self.nResult = buf:readInt()
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.SC_BIND_GETAWARD_ACK = class("SC_BIND_GETAWARD_ACK", packBody)
function wnet.SC_BIND_GETAWARD_ACK:ctor(code, uid, pnum, mapid, syncid)
	wnet.SC_BIND_GETAWARD_ACK.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "SC_PHONECODEBIND_ACK"
end
function wnet.SC_BIND_GETAWARD_ACK:bufferOut(buf)
	self.nResult = buf:readInt()
	local ach = buf:readUInt()
	local acl = buf:readUInt()
	self.awardGameCurrency = i64(ach, acl) --游戏豆
	local tch = buf:readUInt()
	local tcl = buf:readUInt()
	self.totalGameCurrency = i64(tch, tcl)
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.Phone_SetPhone_Login_Result = {}
wnet.Phone_SetPhone_Login_Result.Phone_SetPhone_Login_Result_Ok = 0        --成功
wnet.Phone_SetPhone_Login_Result.Phone_SetPhone_Login_Result_Fail = 1        --失败
wnet.Phone_SetPhone_Login_Result.Phone_SetPhone_Login_Result_SetEd = 2        --已经设置过使用手机登录

wnet.SC_SETUSEPHONELOGIN_ACK = class("SC_SETUSEPHONELOGIN_ACK", packBody)
function wnet.SC_SETUSEPHONELOGIN_ACK:ctor(code, uid, pnum, mapid, syncid)
	wnet.SC_SETUSEPHONELOGIN_ACK.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "SC_SETUSEPHONELOGIN_ACK"
end
function wnet.SC_SETUSEPHONELOGIN_ACK:bufferOut(buf)
	self.nResult = buf:readInt()
	self.strCode = encoding:iconv(buf:readStringUShort())
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.Phone_Operateor_Result = {}
wnet.Phone_Operateor_Result.Phone_Operateor_Result_Ok = 0        --成功
wnet.Phone_Operateor_Result.Phone_Operateor_Result_Fail = 1        --失败

wnet.SC_CACELUSERPHONELOGIN_ACK = class("SC_CACELUSERPHONELOGIN_ACK", packBody)
function wnet.SC_CACELUSERPHONELOGIN_ACK:ctor(code, uid, pnum, mapid, syncid)
	wnet.SC_CACELUSERPHONELOGIN_ACK.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "SC_CACELUSERPHONELOGIN_ACK"
end
function wnet.SC_CACELUSERPHONELOGIN_ACK:bufferOut(buf)
	self.nResult = buf:readInt()
	self.strCode = encoding:iconv(buf:readStringUShort())
	self.userId = buf:readInt()
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.SC_LOGIN_TOKEN = class("SC_LOGIN_TOKEN", packBody)
function wnet.SC_LOGIN_TOKEN:ctor(code, uid, pnum, mapid, syncid)
	wnet.SC_LOGIN_TOKEN.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "SC_LOGIN_TOKEN"
end
function wnet.SC_LOGIN_TOKEN:bufferOut(buf)
	local ych = buf:readUInt()
	local ycl = buf:readUInt()
	self.yuanbao = i64(ych, ycl)
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.CS_TRAIL_TRANSFER = class("CS_TRAIL_TRANSFER", packBody)
function wnet.CS_TRAIL_TRANSFER:ctor(code, uid, pnum, mapid, syncid)
	wnet.CS_TRAIL_TRANSFER.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "CS_TRAIL_TRANSFER"
end
function wnet.CS_TRAIL_TRANSFER:bufferIn(data)
	local buf = wnet.CS_TRAIL_TRANSFER.super.bufferIn(self)
	buf:writeStringUShort(data.strAccount):writeStringUShort(data.strNickName):writeStringUShort(data.strPasswd)
	buf:writeStringUShort(data.strRealName):writeStringUShort(data.strIDCard):writeStringUShort(data.strPhone)
	buf:writeStringUShort(data.strEmail):writeStringUShort(data.strValid):writeChar(data.gender)
	buf:writeShort(data.icon):writeStringUShort(data.strIP):writeStringUShort(data.strMac)
	return buf
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.SC_TRAIL_TRANSFER = class("SC_TRAIL_TRANSFER", packBody)
function wnet.SC_TRAIL_TRANSFER:ctor(code, uid, pnum, mapid, syncid)
	wnet.SC_TRAIL_TRANSFER.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "SC_TRAIL_TRANSFER"
end
function wnet.SC_TRAIL_TRANSFER:bufferOut(buf)
	self.transferResult = buf:readInt()
	self.leftTime = buf:readChar()
end
------------------------------------------------------------------------------
----------------------------个人中心 止----------------------------------------
------------------------------保险箱 起----------------------------------------
------------------------------------------------------------------------------
wnet.stBankData = class("stBankData", packBody)
function wnet.stBankData:ctor(code, uid, pnum, mapid, syncid)
	wnet.stBankData.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "stBankData"
end
function wnet.stBankData:bufferOut(buf)
	self.userID = buf:readInt()				--用户ID
	self.cofferEnd = buf:readInt()			--保险箱结束时间
	self.cofferState = buf:readChar()		--保险箱状态, 0是为开通，1是已开通但过期， 2是开通没过期
	local gch = buf:readUInt()
	local gcl = buf:readUInt()
	self.gameCurrency = i64(gch, gcl)		--游戏豆
	local cch = buf:readUInt()
	local ccl = buf:readUInt()
	self.cofferCurrency = i64(cch, ccl) 	--保险箱里的游戏豆
	self.goldCurrency = buf:readFloat()  	--风雷币
	self.isHaveAdvPasswd = buf:readChar()	--是否应有二级密码
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.CS_COFFER_OP_REQ = class("CS_COFFER_OP_REQ", packBody)
function wnet.CS_COFFER_OP_REQ:ctor(code, uid, pnum, mapid, syncid)
	wnet.CS_COFFER_OP_REQ.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "CS_COFFER_OP_REQ"
end
function wnet.CS_COFFER_OP_REQ:bufferIn(opType, money, strSecondPasswd)
	local buf = wnet.CS_COFFER_OP_REQ.super.bufferIn(self)
	buf:writeChar(opType)				--0是存，1是取, 2是过期取出
	local tmpMoney = i64(money)
	buf:writeUInt(tmpMoney.l)
	buf:writeUInt(tmpMoney.h)
	buf:writeStringUShort(strSecondPasswd or "")
	return buf
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.SC_COFFER_OP_ACK = class("SC_COFFER_OP_ACK", packBody)
function wnet.SC_COFFER_OP_ACK:ctor(code, uid, pnum, mapid, syncid)
	wnet.SC_COFFER_OP_ACK.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "SC_COFFER_OP_ACK"
end
function wnet.SC_COFFER_OP_ACK:bufferOut(buf)
	self.cRet = buf:readChar()
	self.opType = buf:readChar()    --0是存，1是取, 2是过期取出
	local gch = buf:readUInt()
	local gcl = buf:readUInt()
	self.gameCurrency = i64(gch, gcl)		--游戏豆
	local cch = buf:readUInt()
	local ccl = buf:readUInt()
	self.cofferCurrency = i64(cch, ccl) 	--保险箱里的游戏豆
	self.change = buf:readInt()
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.CS_COFFER_RENEWALS_REQ = class("CS_COFFER_RENEWALS_REQ", packBody)
function wnet.CS_COFFER_RENEWALS_REQ:ctor(code, uid, pnum, mapid, syncid)
	wnet.CS_COFFER_RENEWALS_REQ.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "CS_COFFER_RENEWALS_REQ"
end
function wnet.CS_COFFER_RENEWALS_REQ:bufferIn(cMonth, cPayType, strSecondPasswd)
	local buf = wnet.CS_COFFER_RENEWALS_REQ.super.bufferIn(self)
	buf:writeChar(cMonth)
	buf:writeChar(cPayType)                  --0是游戏豆支付，1是风雷币支付
	buf:writeStringUShort(strSecondPasswd or "")
	return buf
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.SC_COFFER_RENEWALS_ACK = class("SC_COFFER_RENEWALS_ACK", packBody)
function wnet.SC_COFFER_RENEWALS_ACK:ctor(code, uid, pnum, mapid, syncid)
	wnet.SC_COFFER_RENEWALS_ACK.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "SC_COFFER_RENEWALS_ACK"
end
function wnet.SC_COFFER_RENEWALS_ACK:bufferOut(buf)
	self.cRet = buf:readChar()
	local gch = buf:readUInt()
	local gcl = buf:readUInt()
	self.gameCurrency = i64(gch, gcl)		--游戏豆
	self.goldCurrency = buf:readFloat() 	--风雷币
	self.cofferEnd = buf:readInt()
	self.cMonth = buf:readChar()
	self.cPayType = buf:readChar()          --0是游戏豆支付，1是风雷币支付
	self.awardCurrency = buf:readInt()      --奖励游戏豆
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.GC_GETBASELIVEING_ACK = class("GC_GETBASELIVEING_ACK", packBody)
function wnet.GC_GETBASELIVEING_ACK:ctor(code, uid, pnum, mapid, syncid)
	wnet.GC_GETBASELIVEING_ACK.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "GC_GETBASELIVEING_ACK"
end
function wnet.GC_GETBASELIVEING_ACK:bufferOut(buf)
	self.srvId = buf:readInt()
	self.userId = buf:readInt()
	self.nResult = buf:readInt()
	self.showGetCurrencyOne = buf:readInt()           --显示领取的游戏豆
	self.showGetCurrencyTwo = buf:readInt()           --显示领取的游戏豆
	self.dayGetCurrency = buf:readInt()           --当天领取游戏豆数量
	self.dayGetTimes = buf:readInt()           --当天领取次数
	self.getTimes = buf:readInt()           --已经领取的次数
	self.connIndex = buf:readUInt()         --连接索引
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.GC_GETBASELIVINGCURRENCY_ACK = class("GC_GETBASELIVINGCURRENCY_ACK", packBody)
function wnet.GC_GETBASELIVINGCURRENCY_ACK:ctor(code, uid, pnum, mapid, syncid)
	wnet.GC_GETBASELIVINGCURRENCY_ACK.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "GC_GETBASELIVINGCURRENCY_ACK"
end
function wnet.GC_GETBASELIVINGCURRENCY_ACK:bufferOut(buf)
	self.srvId = buf:readInt()
	self.userId = buf:readInt()
	self.nResult = buf:readInt()
	local gch = buf:readUInt()
	local gcl = buf:readUInt()
	self.totalCurrency = i64(gch, gcl)
	self.addCurrency = buf:readInt()
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.PL_PHONE_CL_CHECKSECONDPASSWORD = class("PL_PHONE_CL_CHECKSECONDPASSWORD", packBody)
function wnet.PL_PHONE_CL_CHECKSECONDPASSWORD:ctor(code, uid, pnum, mapid, syncid)
	wnet.PL_PHONE_CL_CHECKSECONDPASSWORD.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "PL_PHONE_CL_CHECKSECONDPASSWORD"
end
function wnet.PL_PHONE_CL_CHECKSECONDPASSWORD:bufferIn(strSecondPasswd)
	local buf = wnet.PL_PHONE_CL_CHECKSECONDPASSWORD.super.bufferIn(self)
	buf:writeStringUShort(strSecondPasswd or "")
	return buf
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.PL_PHONE_LC_CHECKSECONDPASSWORD = class("PL_PHONE_LC_CHECKSECONDPASSWORD", packBody)
function wnet.PL_PHONE_LC_CHECKSECONDPASSWORD:ctor(code, uid, pnum, mapid, syncid)
	wnet.PL_PHONE_LC_CHECKSECONDPASSWORD.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "PL_PHONE_LC_CHECKSECONDPASSWORD"
end
function wnet.PL_PHONE_LC_CHECKSECONDPASSWORD:bufferOut(buf)
	self.nRet = buf:readInt()
end
------------------------------------------------------------------------------
------------------------------保险箱 止----------------------------------------
-----------------------------系统广播 起---------------------------------------
------------------------------------------------------------------------------
wnet.BROADCAST_BULLETIN = class("BROADCAST_BULLETIN", packBody)
function wnet.BROADCAST_BULLETIN:ctor(code, uid, pnum, mapid, syncid)
	wnet.BROADCAST_BULLETIN.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "BROADCAST_BULLETIN"
end
function wnet.BROADCAST_BULLETIN:bufferOut(buf)
	self.pType = buf:readInt()
	self.showType = buf:readInt()
	self.text = encoding:iconv(buf:readStringUShort())
end
------------------------------------------------------------------------------
-----------------------------系统广播 止---------------------------------------

wnet.CG_FAST_JOIN_GAME_REQ_P = class("CG_FAST_JOIN_GAME_REQ_P", packBody)
function wnet.CG_FAST_JOIN_GAME_REQ_P:ctor(code, uid, pnum, mapid, syncid)
	wnet.PL_PHONE_CL_USERRANK_REQ_P.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "CG_FAST_JOIN_GAME_REQ_P"
end


-----------------------------排行榜 start--------------------------------------
wnet.PL_PHONE_CL_USERRANK_REQ_P = class("PL_PHONE_CL_USERRANK_REQ_P", packBody)
function wnet.BROADCAST_BULLETIN:ctor(code, uid, pnum, mapid, syncid)
	wnet.PL_PHONE_CL_USERRANK_REQ_P.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "PL_PHONE_CL_USERRANK_REQ_P"
end

wnet.PL_PHONE_LC_USERRANK_ACK_P = class("PL_PHONE_LC_USERRANK_ACK_P", packBody)
function wnet.PL_PHONE_LC_USERRANK_ACK_P:ctor(code, uid, pnum, mapid, syncid)
	wnet.PL_PHONE_LC_USERRANK_ACK_P.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "PL_PHONE_LC_USERRANK_ACK_P"
end
local function bufferOutRankData(rank, buf)
	local rankSize = buf:readShort()
	for i = 1, rankSize do
		local tmp = {}
		tmp.userId = buf:readInt()
		tmp.nRank = buf:readInt()
		tmp.icon = buf:readShort()
		tmp.nNickName = Mutiple2UTF8(buf:readStringUShort())
		local tch = buf:readUInt()
		local tcl = buf:readUInt()
		tmp.totalGameCurrency = i64_toInt(i64(tch, tcl)) --用户总游戏豆
		local gch = buf:readUInt()
		local gcl = buf:readUInt()
		tmp.gainGameCurrency = i64_toInt(i64(gch, gcl)) --用户盈利游戏豆
		tmp.honor = buf:readInt()
		rank[#rank + 1] = tmp
	end
	return buf
end
function wnet.PL_PHONE_LC_USERRANK_ACK_P:bufferOut(buf)
	self.rickRank = {}
	buf = bufferOutRankData(self.rickRank, buf)
	self.gainRank = {}
	buf = bufferOutRankData(self.gainRank, buf)
	self.honorRank = {}
	buf = bufferOutRankData(self.honorRank, buf)
	return buf
end

wnet.PL_PHONE_LC_SELFUSERRANK_ACK_P = class("PL_PHONE_LC_SELFUSERRANK_ACK_P", packBody)
function wnet.PL_PHONE_LC_SELFUSERRANK_ACK_P:ctor(code, uid, pnum, mapid, syncid)
	wnet.PL_PHONE_LC_SELFUSERRANK_ACK_P.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "PL_PHONE_LC_SELFUSERRANK_ACK_P"
end
function wnet.PL_PHONE_LC_SELFUSERRANK_ACK_P:bufferOut(buf)
	self.richRank = buf:readInt()
	local tch = buf:readUInt()
	local tcl = buf:readUInt()
	self.totalGameCurrency = i64_toInt(i64(tch, tcl)) --用户总游戏豆
	self.gainRank = buf:readInt()
	local gch = buf:readUInt()
	local gcl = buf:readUInt()
	self.gainGameCurrency = i64_toInt(i64(gch, gcl)) --用户盈利游戏豆
	self.honorRank = buf:readInt()
	self.honor = buf:readInt()
	return buf
end
-----------------------------排行榜 end-----------------------------------------
-------------------------------签到 起-----------------------------------------
------------------------------------------------------------------------------
wnet.SIGNIN_DAYAWARDINFO = class("SIGNIN_DAYAWARDINFO", packBody)
function wnet.SIGNIN_DAYAWARDINFO:ctor(code, uid, pnum, mapid, syncid)
	wnet.SIGNIN_DAYAWARDINFO.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "SIGNIN_DAYAWARDINFO"
end
function wnet.SIGNIN_DAYAWARDINFO:bufferOut(buf)
	self.day = buf:readInt()
	self.odds = buf:readInt()
	self.awardGameCurrency = buf:readInt()
	self.awardIngore = buf:readInt()
	self.awardVipDays = buf:readInt()
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.SIGNIN_AWARDINFO = class("SIGNIN_AWARDINFO", packBody)
function wnet.SIGNIN_AWARDINFO:ctor(code, uid, pnum, mapid, syncid)
	wnet.SIGNIN_AWARDINFO.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "SIGNIN_AWARDINFO"
end
function wnet.SIGNIN_AWARDINFO:bufferOut(buf)
	self.vipRate = buf:readInt()
	local size = buf:readShort()
	self.awardInfo = {}
	for i = 1, size do
		local tmp = wnet.SIGNIN_DAYAWARDINFO.new()
		tmp:bufferOut(buf)
		self.awardInfo[i] = tmp
	end
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.PL_PHONE_LC_INISIGNININFO = class("PL_PHONE_LC_INISIGNININFO", packBody)
function wnet.PL_PHONE_LC_INISIGNININFO:ctor(code, uid, pnum, mapid, syncid)
	wnet.PL_PHONE_LC_INISIGNININFO.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "PL_PHONE_LC_INISIGNININFO"
	self.signInAwardInfo = wnet.SIGNIN_AWARDINFO.new()
end
function wnet.PL_PHONE_LC_INISIGNININFO:bufferOut(buf)
	self.signInDay = buf:readInt()
	self.bSignIn = buf:readChar()
	self.signInAwardInfo:bufferOut(buf)
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.PL_PHONE_LC_SIGNIN = class("PL_PHONE_LC_SIGNIN", packBody)
function wnet.PL_PHONE_LC_SIGNIN:ctor(code, uid, pnum, mapid, syncid)
	wnet.PL_PHONE_LC_SIGNIN.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "PL_PHONE_LC_SIGNIN"
	self.vipData = wnet.stVipData.new()
end
function wnet.PL_PHONE_LC_SIGNIN:bufferOut(buf)
	self.signResult = buf:readInt()
	self.awardDouble = buf:readChar()
	self.vipData:bufferOut(buf)
end
------------------------------------------------------------------------------
-------------------------------签到 止-----------------------------------------

-------------------------------任务 起-----------------------------------------
------------------------------------------------------------------------------
wnet.Task_Operator_Status = {}
wnet.Task_Operator_Status.Task_Operator_Status_Process = 0
wnet.Task_Operator_Status.Task_Operator_Status_End = 1
wnet.Task_Operator_Status.Task_Operator_Status_GetAward = 2
wnet.Task_Operator_Status.Task_Operator_Status_Other = 3

wnet.Task_Operator_GetAwardResult = {}
wnet.Task_Operator_GetAwardResult.Task_Operator_GetAwardResult_Fail = 0
wnet.Task_Operator_GetAwardResult.Task_Operator_GetAwardResult_Sucess = 1
wnet.Task_Operator_GetAwardResult.Task_Operator_GetAwardResult_PackFill = 2
wnet.Task_Operator_GetAwardResult.Task_Operator_GetAwardResult_NumError = 3
wnet.Task_Operator_GetAwardResult.Task_Operator_GetAwardResult_YuanBaoLimit = 4
wnet.Task_Operator_GetAwardResult.Task_Operator_GetAwardResult_UnBindPhone = 5

wnet.TASK_AWARDITEMINFO = class("TASK_AWARDITEMINFO", packBody)
function wnet.TASK_AWARDITEMINFO:ctor(code, uid, pnum, mapid, syncid)
	wnet.TASK_AWARDITEMINFO.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "TASK_AWARDITEMINFO"
end
function wnet.TASK_AWARDITEMINFO:bufferOut(buf)
	self.awardShopId = buf:readInt()
	self.awardShopNum = buf:readInt()
	self.templateId = buf:readInt()
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.TASK_AWARDCURRENCYINFO = class("GC_SINGLETASK_INFO", packBody)
function wnet.TASK_AWARDCURRENCYINFO:ctor(code, uid, pnum, mapid, syncid)
	wnet.TASK_AWARDCURRENCYINFO.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "TASK_AWARDCURRENCYINFO"
end
function wnet.TASK_AWARDCURRENCYINFO:bufferOut(buf)
	self.currencyType = buf:readShort()
	self.currencyNum = buf:readInt()
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.GC_SINGLETASK_INFO = class("GC_SINGLETASK_INFO", packBody)
function wnet.GC_SINGLETASK_INFO:ctor(code, uid, pnum, mapid, syncid)
	wnet.GC_SINGLETASK_INFO.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "GC_SINGLETASK_INFO"
	self.vecAwardShop = wnet.TASK_AWARDITEMINFO.new()
	self.vecCurrencyInfo = wnet.TASK_AWARDCURRENCYINFO.new()
end
function wnet.GC_SINGLETASK_INFO:bufferOut(buf)
	self.taskId = buf:readInt()
	self.taskStatus = buf:readInt()
	self.taskCurProcess = buf:readInt()
	self.vecAwardShop:bufferOut(buf)
	self.vecCurrencyInfo:bufferOut(buf)
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.GC_TASK_TASKINFOLIST = class("GC_TASK_TASKINFOLIST", packBody)
function wnet.GC_TASK_TASKINFOLIST:ctor(code, uid, pnum, mapid, syncid)
	wnet.GC_TASK_TASKINFOLIST.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "GC_TASK_TASKINFOLIST"
	self.singleTaskInfo = {}
end
function wnet.GC_TASK_TASKINFOLIST:bufferOut(buf)
	self.srvId = buf:readInt()
	local size = buf:readShort()
	for i = 1, size do
		local singleTaskInfo = wnet.GC_SINGLETASK_INFO.new()
		singleTaskInfo:bufferOut(buf)
		self.singleTaskInfo[i] = singleTaskInfo
	end
	self.bSendFinished = buf:readChar()
	self.taskConfigFile = buf:readStringUShort()
	self.taskVersion = buf:readInt()
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.CL_GET_INVITETASK_STATUS = class("CL_GET_INVITETASK_STATUS", packBody)
function wnet.CL_GET_INVITETASK_STATUS:ctor(code, uid, pnum, mapid, syncid)
	wnet.CL_GET_INVITETASK_STATUS.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "CL_GET_INVITETASK_STATUS"
end
function wnet.CL_GET_INVITETASK_STATUS:bufferIn(vecTaskId)
	local buf = wnet.CL_GET_INVITETASK_STATUS.super.bufferIn(self)
	buf:writeShort(#vecTaskId)
	for i = 1, #vecTaskId do
		buf:writeInt(vecTaskId[i])
	end
	return buf
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.LC_GET_INVITERECORD = class("LC_GET_INVITERECORD", packBody)
function wnet.LC_GET_INVITERECORD:ctor(code, uid, pnum, mapid, syncid)
	wnet.LC_GET_INVITERECORD.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "LC_GET_INVITERECORD"
end
function wnet.LC_GET_INVITERECORD:bufferOut(buf)
	self.inviteuserid = buf:readInt()
	self.invitedatetime = buf:readInt()
	self.finished = buf:readChar()
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.LC_GET_INVITERECORD_VEC = class("LC_GET_INVITERECORD_VEC", packBody)
function wnet.LC_GET_INVITERECORD_VEC:ctor(code, uid, pnum, mapid, syncid)
	wnet.LC_GET_INVITERECORD_VEC.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "LC_GET_INVITERECORD_VEC"
	self.inviteRecord = {}
end
function wnet.LC_GET_INVITERECORD_VEC:bufferOut(buf)
	local size = buf:readShort()
	for i = 1, size do
		local inviteRecord = wnet.LC_GET_INVITERECORD.new()
		inviteRecord:bufferOut(buf)
		self.inviteRecord[i] = inviteRecord
	end
	self.bSendFinished = buf:readChar()
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.GC_TASK_WRITETASKOPERINFO = class("GC_TASK_WRITETASKOPERINFO", packBody)
function wnet.GC_TASK_WRITETASKOPERINFO:ctor(code, uid, pnum, mapid, syncid)
	wnet.GC_TASK_WRITETASKOPERINFO.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "GC_TASK_WRITETASKOPERINFO"
	self.vecAwardShop = wnet.TASK_AWARDITEMINFO.new()
	self.vecCurrencyInfo = wnet.TASK_AWARDCURRENCYINFO.new()
end
function wnet.GC_TASK_WRITETASKOPERINFO:bufferOut(buf)
	self.gameId = buf:readShort()           --游戏ID
	self.taskId = buf:readInt()           --任务ID
	self.srvId = buf:readInt()           --服务器ID
	self.taskStatus = buf:readInt()           --任务状态
	self.taskCurProcess = buf:readInt()          --任务当前进度
	self.userId = buf:readInt()           --用户ID
	self.vecAwardShop:bufferOut(buf)          --奖励的物品信息
	self.vecCurrencyInfo:bufferOut(buf)           --奖励的代币信息
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.CG_TASK_GETAWARD = class("CG_TASK_GETAWARD", packBody)
function wnet.CG_TASK_GETAWARD:ctor(code, uid, pnum, mapid, syncid)
	wnet.CG_TASK_GETAWARD.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "CG_TASK_GETAWARD"
end
function wnet.CG_TASK_GETAWARD:bufferIn(userId, taskId)
	local buf = wnet.CG_TASK_GETAWARD.super.bufferIn(self)
	buf:writeInt(userId):writeInt(taskId)
	return buf
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.GC_TASK_GETAWARD = class("GC_TASK_GETAWARD", packBody)
function wnet.GC_TASK_GETAWARD:ctor(code, uid, pnum, mapid, syncid)
	wnet.GC_TASK_GETAWARD.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "GC_TASK_GETAWARD"
end
function wnet.GC_TASK_GETAWARD:bufferOut(buf)
	self.srvId = buf:readShort()
	self.taskId = buf:readInt()
	self.templateId = buf:readInt()
	self.nResult = buf:readInt()
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.GC_NEWTASK_INFO = class("GC_NEWTASK_INFO", packBody)
function wnet.GC_NEWTASK_INFO:ctor(code, uid, pnum, mapid, syncid)
	wnet.GC_NEWTASK_INFO.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "GC_NEWTASK_INFO"
end
function wnet.GC_NEWTASK_INFO:bufferOut(buf)
	self.srvId = buf:readInt()
	self.taskId = buf:readInt()
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.INVITETASK_STATUS_INFO = class("INVITETASK_STATUS_INFO", packBody)
function wnet.INVITETASK_STATUS_INFO:ctor(code, uid, pnum, mapid, syncid)
	wnet.INVITETASK_STATUS_INFO.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "INVITETASK_STATUS_INFO"
end
function wnet.INVITETASK_STATUS_INFO:bufferOut(buf)
	self.taskId = buf:readInt()
	self.finished = buf:readInt()
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.DC_GET_INVITETASK_STATUS = class("DC_GET_INVITETASK_STATUS", packBody)
function wnet.DC_GET_INVITETASK_STATUS:ctor(code, uid, pnum, mapid, syncid)
	wnet.DC_GET_INVITETASK_STATUS.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "DC_GET_INVITETASK_STATUS"
	self.inviteTaskStatusInfo = {}
end
function wnet.DC_GET_INVITETASK_STATUS:bufferOut(buf)
	local size = buf:readShort()
	for i = 1, size do
		local inviteTaskStatusInfo = wnet.INVITETASK_STATUS_INFO.new()
		inviteTaskStatusInfo:bufferOut(buf)
		self.inviteTaskStatusInfo[i] = inviteTaskStatusInfo
	end
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.TASK_UPDATE_GAMECURRENCY = class("TASK_UPDATE_GAMECURRENCY", packBody)
function wnet.TASK_UPDATE_GAMECURRENCY:ctor(code, uid, pnum, mapid, syncid)
	wnet.TASK_UPDATE_GAMECURRENCY.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "TASK_UPDATE_GAMECURRENCY"
end
function wnet.TASK_UPDATE_GAMECURRENCY:bufferOut(buf)
	self.srvID = buf:readInt()
	local gch = buf:readUInt()
	local gcl = buf:readUInt()
	self.gameCurrency = i64(gch, gcl)
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.TASK_UPDATE_YUANBAO = class("TASK_UPDATE_YUANBAO", packBody)
function wnet.TASK_UPDATE_YUANBAO:ctor(code, uid, pnum, mapid, syncid)
	wnet.TASK_UPDATE_YUANBAO.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "TASK_UPDATE_YUANBAO"
end
function wnet.TASK_UPDATE_YUANBAO:bufferOut(buf)
	self.srvID = buf:readInt()
	local gch = buf:readUInt()
	local gcl = buf:readUInt()
	self.yuanBaoNum = i64(gch, gcl)
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------
wnet.PL_PHONE_CL_REGSUCESS = class("PL_PHONE_CL_REGSUCESS", packBody)
function wnet.PL_PHONE_CL_REGSUCESS:ctor(code, uid, pnum, mapid, syncid)
	wnet.PL_PHONE_CL_REGSUCESS.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "PL_PHONE_CL_REGSUCESS"
end
function wnet.PL_PHONE_CL_REGSUCESS:bufferIn(userId, gameId)
	local buf = wnet.PL_PHONE_CL_REGSUCESS.super.bufferIn(self)
	buf:writeInt(userId):writeShort(gameId)
	return buf
end
------------------------------------------------------------------------------
-------------------------------任务 止-----------------------------------------


-------------------------------聊天 始---------------------------------------
wnet.CHAT_MSG = class("CHAT_MSG", packBody)
function wnet.CHAT_MSG:ctor(code, uid, pnum, mapid, syncid)
	self.name = "CHAT_MSG"
	wnet.CHAT_MSG.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function wnet.CHAT_MSG:bufferOut(buf)
	self.srcID = buf:readInt()
	self.desID = buf:readInt()
	self.strMsg = Mutiple2UTF8(buf:readStringUShort())
	self.textColor = buf:readInt()
end
function wnet.CHAT_MSG:bufferIn(data)
	local buf = wnet.CHAT_MSG.super.bufferIn(self)
	buf:writeInt(data.srcID or 0)
		:writeInt(data.desID or 0)
		:writeStringUShort(UTF82Mutiple(data.strMsg or ""))
		:writeInt(data.textColor or 1111111111111111)
	return buf
end

wnet.EChatFail_Reason = {}
wnet.EChatFail_Reason.EChatFail_Success 	 	= 0 --聊天成功，客户端不需要显示
wnet.EChatFail_Reason.EChatFail_TimeLimit		= 1 --聊天过快
wnet.EChatFail_Reason.EChatFail_TextFilter 	 	= 2 --聊天内容有非法内容
wnet.EChatFail_Reason.EChatFail_TextLengthOver  = 3 --聊天内容超长
wnet.EChatFail_Reason.EChatFail_HonorLess 		= 4 --声望不足
wnet.EChatFail_Reason.EChatFail_ForbidChat 		= 5 --因违反用户条例，被禁言
wnet.EChatFail_Reason.EChatFail_NoWatch 		= 6 --旁观不能聊天
wnet.EChatFail_Reason.EChatFail_Num  			= 7

wnet.CHAT_FAIL = class("CHAT_FAIL", packBody)
function wnet.CHAT_FAIL:ctor(code, uid, pnum, mapid, syncid)
	self.name = "CHAT_FAIL"
	wnet.CHAT_FAIL.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function wnet.CHAT_FAIL:bufferOut(buf)
	self.failReason = buf:readInt()
end
-------------------------------聊天 止---------------------------------------
-------------------------------充值 起---------------------------------------
----------------------------------------------------------------------------
wnet.PL_PHONE_RECHARGEAWARDTYPE = class("PL_PHONE_RECHARGEAWARDTYPE", packBody)
function wnet.PL_PHONE_RECHARGEAWARDTYPE:ctor(code, uid, pnum, mapid, syncid)
	wnet.PL_PHONE_RECHARGEAWARDTYPE.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "PL_PHONE_RECHARGEAWARDTYPE"
end
function wnet.PL_PHONE_RECHARGEAWARDTYPE:bufferOut(buf)
	-- awardType 1.游戏豆 2.元宝 3.VIP天数
	self.awardType = buf:readShort()
	self.awardNum = buf:readInt()
end
----------------------------------------------------------------------------
----------------------------------------------------------------------------
wnet.PL_PHONE_RECHAREAWARDINFO = class("PL_PHONE_RECHAREAWARDINFO", packBody)
function wnet.PL_PHONE_RECHAREAWARDINFO:ctor(code, uid, pnum, mapid, syncid)
	wnet.PL_PHONE_RECHAREAWARDINFO.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "PL_PHONE_RECHAREAWARDINFO"
	self.awardTypeInfo = {}
end
function wnet.PL_PHONE_RECHAREAWARDINFO:bufferOut(buf)
	self.order = buf:readShort()
	self.rechargeMoney = buf:readFloat()
	self.awardIcon = buf:readStringUShort()
	local size = buf:readUShort()
	--print("awardTypeInfo size:"..size)
	for i = 1, size do
		local awardTypeInfo = wnet.PL_PHONE_RECHARGEAWARDTYPE.new()
		awardTypeInfo:bufferOut(buf)
		self.awardTypeInfo[i] = awardTypeInfo
	end
end
----------------------------------------------------------------------------
----------------------------------------------------------------------------
wnet.PL_LC_SHOWFIRSTINFO = class("PL_LC_SHOWFIRSTINFO", packBody)
function wnet.PL_LC_SHOWFIRSTINFO:ctor(code, uid, pnum, mapid, syncid)
	wnet.PL_LC_SHOWFIRSTINFO.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "PL_LC_SHOWFIRSTINFO"
	self.rechargeAwardInfo = {}
end
function wnet.PL_LC_SHOWFIRSTINFO:bufferOut(buf)
	self.bStartRechargeAward = buf:readChar()
	local size = buf:readUShort()
	for i = 1, size do
		local rechargeAwardInfo = wnet.PL_PHONE_RECHAREAWARDINFO.new()
		rechargeAwardInfo:bufferOut(buf)
		self.rechargeAwardInfo[i] = rechargeAwardInfo
	end
end
----------------------------------------------------------------------------
----------------------------------------------------------------------------
wnet.PL_PHONE_LC_GETRECHARGEAWARDINFO = class("PL_PHONE_LC_GETRECHARGEAWARDINFO", packBody)
function wnet.PL_PHONE_LC_GETRECHARGEAWARDINFO:ctor(code, uid, pnum, mapid, syncid)
	wnet.PL_PHONE_LC_GETRECHARGEAWARDINFO.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "PL_PHONE_LC_GETRECHARGEAWARDINFO"
	self.rechargeAwardInfo = {}
end
function wnet.PL_PHONE_LC_GETRECHARGEAWARDINFO:bufferOut(buf)
	self.awardOrder = buf:readShort()
	self.bCanGetAward = buf:readChar()
end
----------------------------------------------------------------------------
----------------------------------------------------------------------------
wnet.PL_PHONE_CL_GETRECHARGEAWARD = class("PL_PHONE_CL_GETRECHARGEAWARD", packBody)
function wnet.PL_PHONE_CL_GETRECHARGEAWARD:ctor(code, uid, pnum, mapid, syncid)
	wnet.PL_PHONE_CL_GETRECHARGEAWARD.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "PL_PHONE_CL_GETRECHARGEAWARD"
end
function wnet.PL_PHONE_CL_GETRECHARGEAWARD:bufferIn(awardOrder)
	local buf = wnet.PL_PHONE_CL_GETRECHARGEAWARD.super.bufferIn(self)
	buf:writeShort(awardOrder)
	return buf
end
----------------------------------------------------------------------------
----------------------------------------------------------------------------
wnet.PL_PHONE_LC_GETRECHARGEAWARD = class("PL_PHONE_LC_GETRECHARGEAWARD", packBody)
function wnet.PL_PHONE_LC_GETRECHARGEAWARD:ctor(code, uid, pnum, mapid, syncid)
	wnet.PL_PHONE_LC_GETRECHARGEAWARD.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "PL_PHONE_LC_GETRECHARGEAWARD"
	self.vipData = wnet.stVipData.new()
end
function wnet.PL_PHONE_LC_GETRECHARGEAWARD:bufferOut(buf)
	self.nResult = buf:readInt()
	local tch = buf:readUInt()
	local tcl = buf:readUInt()
	self.totalGameCurrency = i64(tch, tcl)
	self.awardGameCurrency = buf:readInt()
	local tyh = buf:readUInt()
	local tyl = buf:readUInt()
	self.totalYuanBao = i64(tyh, tyl)
	self.awardYuanBao = buf:readUInt()
	self.vipData:bufferOut(buf)
end
----------------------------------------------------------------------------
----------------------------------------------------------------------------
wnet.PL_PHONE_IOS_SINGLE_RECHARGEINFO = class("PL_PHONE_IOS_SINGLE_RECHARGEINFO", packBody)
function wnet.PL_PHONE_IOS_SINGLE_RECHARGEINFO:ctor(code, uid, pnum, mapid, syncid)
	wnet.PL_PHONE_IOS_SINGLE_RECHARGEINFO.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "PL_PHONE_IOS_SINGLE_RECHARGEINFO"
end
function wnet.PL_PHONE_IOS_SINGLE_RECHARGEINFO:bufferOut(buf)
	self.productId = buf:readStringUShort()
	self.productType = buf:readInt()
	self.productPrice = buf:readFloat()
	self.productNum = buf:readInt()
	self.productIcon = buf:readStringUShort()
end
----------------------------------------------------------------------------
----------------------------------------------------------------------------
wnet.PL_PHONE_IOS_RECHARGEINFO = class("PL_PHONE_IOS_RECHARGEINFO", packBody)
function wnet.PL_PHONE_IOS_RECHARGEINFO:ctor(code, uid, pnum, mapid, syncid)
	wnet.PL_PHONE_IOS_RECHARGEINFO.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "PL_PHONE_IOS_RECHARGEINFO"
	self.iosRechargeInfo = {}
end
function wnet.PL_PHONE_IOS_RECHARGEINFO:bufferOut(buf)
	local size = buf:readUShort()
	print("size:"..size)
	for i = 1, size do
		local iosRechargeInfo = wnet.PL_PHONE_IOS_SINGLE_RECHARGEINFO.new()
		iosRechargeInfo:bufferOut(buf)
		self.iosRechargeInfo[i] = iosRechargeInfo
	end
end
----------------------------------------------------------------------------
----------------------------------------------------------------------------
wnet.PL_PHONE_IOS_RECHARGE = class("PL_PHONE_IOS_RECHARGE", packBody)
function wnet.PL_PHONE_IOS_RECHARGE:ctor(code, uid, pnum, mapid, syncid)
	wnet.PL_PHONE_IOS_RECHARGE.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "PL_PHONE_IOS_RECHARGE"
end
function wnet.PL_PHONE_IOS_RECHARGE:bufferIn(userId, transActionId, recevieData)
	local buf = wnet.PL_PHONE_IOS_RECHARGE.super.bufferIn(self)
	buf:writeInt(userId):writeStringUShort(transActionId):writeStringUShort(recevieData)
	return buf
end
----------------------------------------------------------------------------
----------------------------------------------------------------------------
wnet.PL_PHONE_IOS_RECHARGE_ACK = class("PL_PHONE_IOS_RECHARGE_ACK", packBody)
function wnet.PL_PHONE_IOS_RECHARGE_ACK:ctor(code, uid, pnum, mapid, syncid)
	wnet.PL_PHONE_IOS_RECHARGE_ACK.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "PL_PHONE_IOS_RECHARGE_ACK"
end
function wnet.PL_PHONE_IOS_RECHARGE_ACK:bufferOut(buf)
	self.nRet = buf:readInt()
	self.transactionId = buf:readStringUShort()
	self.payType = buf:readInt()
	self.rechargeNum = buf:readInt()
	local gch = buf:readInt()
	local gcl = buf:readInt()
	self.totalGameCurrency = i64(gch, gcl)
	self.totalGoldCurrency = buf:readFloat()
end
----------------------------------------------------------------------------
-------------------------------充值 止---------------------------------------

------------------------------德州扑克补充协议-------------------------------
----------------------------------------------------------------------------------------------------------------
wnet.CG_GETSHOWSETBETINFO = class("CG_GETSHOWSETBETINFO", packBody)
function wnet.CG_GETSHOWSETBETINFO:ctor(code, uid, pnum, mapid, syncid)
	wnet.CG_GETSHOWSETBETINFO.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "CG_GETSHOWSETBETINFO"
end
function wnet.CG_GETSHOWSETBETINFO:bufferIn(tableId)
	local buf = wnet.CG_GETSHOWSETBETINFO.super.bufferIn(self)
	buf:writeChar(tableId)
	return buf
end
----------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------
wnet.GC_GETSHOWSETBETINFO = class("GC_GETSHOWSETBETINFO", packBody)
function wnet.GC_GETSHOWSETBETINFO:ctor(code, uid, pnum, mapid, syncid)
	wnet.GC_GETSHOWSETBETINFO.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "GC_GETSHOWSETBETINFO"
end
function wnet.GC_GETSHOWSETBETINFO:bufferOut(buf)
	self.nResult = buf:readByte()
	self.tableId = buf:readChar()
	self.chairId = buf:readChar()
end
------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------
wnet.CG_CHECKBET = class("CG_CHECKBET", packBody)
function wnet.CG_CHECKBET:ctor(code, uid, pnum, mapid, syncid)
	wnet.CG_CHECKBET.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "CG_CHECKBET"
end
function wnet.CG_CHECKBET:bufferIn(nBet)
	local buf = wnet.CG_CHECKBET.super.bufferIn(self)
	buf:writeInt(nBet)
	return buf
end
----------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------
wnet.GC_CHECKBET_ACK = class("GC_CHECKBET_ACK", packBody)
function wnet.GC_CHECKBET_ACK:ctor(code, uid, pnum, mapid, syncid)
	wnet.GC_CHECKBET_ACK.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "GC_CHECKBET_ACK"
end
function wnet.GC_CHECKBET_ACK:bufferOut(buf)
	self.nResult = buf:readByte()
end
------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------
wnet.GC_BRINGGAMECURRENCY_INFO = class("GC_BRINGGAMECURRENCY_INFO", packBody)
function wnet.GC_BRINGGAMECURRENCY_INFO:ctor(code, uid, pnum, mapid, syncid)
	wnet.GC_BRINGGAMECURRENCY_INFO.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "GC_BRINGGAMECURRENCY_INFO"
end
function wnet.GC_BRINGGAMECURRENCY_INFO:bufferOut(buf)
	self.bStart = buf:readBool()
	self.betInfo = {}
	local len = buf:readShort()
	for i = 0, len - 1 do
		local key = buf:readInt()
		local value = buf:readInt()
		self.betInfo[key] = value
	end
	self.bringLeastTimes = buf:readInt()
	self.bringMostTimes = buf:readInt()
	self.tenThousandBringMostTimes = buf:readInt()
end
----------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------
wnet.CG_SETCURRENTTABLE_USERINFO = class("CG_SETCURRENTTABLE_USERINFO", packBody)
function wnet.CG_SETCURRENTTABLE_USERINFO:ctor(code, uid, pnum, mapid, syncid)
	wnet.CG_SETCURRENTTABLE_USERINFO.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "CG_SETCURRENTTABLE_USERINFO"
end
function wnet.CG_SETCURRENTTABLE_USERINFO:bufferIn(bringGameCurrency, bAutoBuy)
	local buf = wnet.CG_SETCURRENTTABLE_USERINFO.super.bufferIn(self)
	buf:writeUInt(bringGameCurrency.l)
	buf:writeUInt(bringGameCurrency.h)
	buf:writeBool(bAutoBuy)
	return buf
end
----------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------
wnet.CG_SUPPLYGAMECURRENCY = class("CG_SUPPLYGAMECURRENCY", packBody)
function wnet.CG_SUPPLYGAMECURRENCY:ctor(code, uid, pnum, mapid, syncid)
	wnet.CG_SUPPLYGAMECURRENCY.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "CG_SUPPLYGAMECURRENCY"
end
function wnet.CG_SUPPLYGAMECURRENCY:bufferIn(supplyGameCurrency, bAutoBuy)
	local buf = wnet.CG_SUPPLYGAMECURRENCY.super.bufferIn(self)
	buf:writeInt(supplyGameCurrency)
	buf:writeBool(bAutoBuy)
	return buf
end
----------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------
wnet.GC_DZ_STARTTIMER = class("GC_DZ_STARTTIMER", packBody)
function wnet.GC_DZ_STARTTIMER:ctor(code, uid, pnum, mapid, syncid)
	wnet.GC_DZ_STARTTIMER.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "GC_DZ_STARTTIMER"
end
function wnet.GC_DZ_STARTTIMER:bufferOut(buf)
	self.timerSec = buf:readInt()
end
------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------
wnet.GC_TABLEUSERBRINGGAMECURRENCY = class("GC_TABLEUSERBRINGGAMECURRENCY", packBody)
function wnet.GC_TABLEUSERBRINGGAMECURRENCY:ctor(code, uid, pnum, mapid, syncid)
	wnet.GC_TABLEUSERBRINGGAMECURRENCY.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "GC_TABLEUSERBRINGGAMECURRENCY"
end
function wnet.GC_TABLEUSERBRINGGAMECURRENCY:bufferOut(buf)
	self.tableUserBringGameCurrency = {}
	local len = buf:readShort()
	for i = 0, len - 1 do
		self.tableUserBringGameCurrency[i] = {}
		self.tableUserBringGameCurrency[i].userId = buf:readInt()
		local gcl = buf:readUInt()
		local gch = buf:readUInt()
		self.tableUserBringGameCurrency[i].bringGameCurrecny = i64_ax(gch, gcl)
	end
end
------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------
wnet.GC_SUPPLYINFO = class("GC_SUPPLYINFO", packBody)
function wnet.GC_SUPPLYINFO:ctor(code, uid, pnum, mapid, syncid)
	wnet.GC_SUPPLYINFO.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "GC_SUPPLYINFO"
end
function wnet.GC_SUPPLYINFO:bufferOut(buf)
	self.supplyResultInfo = buf:readStringUShort()
end
------------------------------------------------------------------------------------------------------------------
---------------------------------------------补充协议 止----------------------------------------------------------

-----------------------------------------------主动获取游戏数据----------------------------------------------------
wnet.CS_GETINITDATA_REQ = class("CS_GETINITDATA_REQ", packBody)
function wnet.CS_GETINITDATA_REQ:ctor(code, uid, pnum, mapid, syncid)
	wnet.CS_GETINITDATA_REQ.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "CS_GETINITDATA_REQ"
end
------------------------------------------------------------------------------------------------------------------



--------------------------------中国象棋协议退出-------------------------------------

wnet.GC_AGREELEAVE_ACK= class("GC_AGREELEAVE_ACK", packBody)
function wnet.GC_AGREELEAVE_ACK:ctor(code, uid, pnum, mapid, syncid)
	wnet.GC_AGREELEAVE_ACK.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "GC_AGREELEAVE_ACK"
end
function wnet.GC_AGREELEAVE_ACK:bufferOut(buf)
	self.cRet=buf:readChar()
	self.rejectID=buf:readInt()
end

wnet.GC_AGREELEAVE_ASK= class("GC_AGREELEAVE_ASK", packBody)
function wnet.GC_AGREELEAVE_ASK:ctor(code, uid, pnum, mapid, syncid)
	wnet.GC_AGREELEAVE_ASK.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
	self.name = "GC_AGREELEAVE_ASK"
end
function wnet.GC_AGREELEAVE_ASK:bufferOut(buf)
	self.reqID=buf:readInt()
	self.strArgu=buf:readStringUShort()
end
-----------------------------------完-------------------------------------------