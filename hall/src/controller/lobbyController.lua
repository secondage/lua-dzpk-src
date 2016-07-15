 require "data.msgHandler"
require "loading"

local lobbyController = class("LobbyController")
function lobbyController:ctor()
	

	self.name = "lobbyController"
end

function lobbyController:login(username, pssword)
	self._socketLogin = cc.msgHandler.socketLogin

	if self._socketLogin then
		assert(self._socketLogin, self.name .. " need a socket instance.")
		local req = wnet.lobbyLoginReq.new(cc.protocolNumber.PL_PHONE_CL_LOGIN_REQ_P)
		self._socketLogin:send(req:bufferIn(username, pssword):getPack())
	end
end

function lobbyController:verifyPhoneNumber(strPhone)
	self._socketLogin = cc.msgHandler.socketLogin
	if self._socketLogin then
		local req = wnet.CL_CHECK_PHONECODE.new(cc.protocolNumber.CL_PHONE_CHECK_PHONECODE_P)
		self._socketLogin:send(req:bufferIn(strPhone):getPack())
	end
end

function lobbyController:checkPhoneAuth(strPhone)
	self._socketLogin = cc.msgHandler.socketLogin
	if self._socketLogin then
		local req = wnet.LC_PHONECODE_GET_VALIDATECODE_REQ.new(cc.protocolNumber.CL_PHONECODE_GET_VALIDATECODE_REQ_P)
		self._socketLogin:send(req:bufferIn(strPhone, 1, 0):getPack())
	end
end 

function lobbyController:verifyValidCode(strPhone, strCode)
	self._socketLogin = cc.msgHandler.socketLogin
	if self._socketLogin then
		local req = wnet.CL_CHECK_PHONEVALIDATECODE_REQ.new(cc.protocolNumber.CL_CHECK_PHONEVALIDATECODE_REQ_P)
		self._socketLogin:send(req:bufferIn(strPhone, strCode, 1):getPack())
	end
end

function lobbyController:sendRegReq(data)
	self._socketLogin = cc.msgHandler.socketLogin
	if self._socketLogin then
		local req = wnet.CL_REG_REQ.new(cc.protocolNumber.CL_PHONE_NOPHONECODE_REG_REQ_P)
		self._socketLogin:send(req:bufferIn(data):getPack())
	end
end

function lobbyController:sendUserRankReq()
	if self._socketLobby then
		local req = wnet.PL_PHONE_CL_USERRANK_REQ_P.new(cc.protocolNumber.PL_PHONE_CL_USERRANK_REQ_P)
		self._socketLobby:send(req:bufferIn():getPack())
	end
end

function lobbyController:sendUserLoginReq()
	self._socketLobby = cc.msgHandler.socketLobby
	if self._socketLobby then
		local req = wnet.PL_PHONE_CS_USERLOGIN_REQ.new(cc.protocolNumber.PL_PHONE_CS_USERLOGIN_REQ_P, cc.dataMgr.lobbyLoginData.userID)
		local targetPlatform = cc.Application:getInstance():getTargetPlatform()
		local platForm = 0
		if targetPlatform == cc.PLATFORM_OS_WINDOWS then
			platForm = 0
		elseif targetPlatform == cc.PLATFORM_OS_ANDROID then
			platForm = 1
		elseif targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD then
			platForm = 2
		end

		self._socketLobby:send(req:bufferIn(cc.dataMgr.lobbyLoginData.userID, cc.dataMgr.lobbyLoginData.passCode, "", "", platForm):getPack())
	end
end

function lobbyController:sendGameLoginReq()
	self._socketGame = cc.msgHandler.socketGame
	if self._socketGame then
		local req = wnet.CG_LOGIN_REQ.new(cc.protocolNumber.PL_PHONE_CG_LOGIN_REQ_P, cc.dataMgr.lobbyLoginData.userID)
		self._socketGame:send(req:bufferIn(cc.dataMgr.selectRoomID, cc.dataMgr.lobbyLoginData.passCode):getPack())
	end
end

function lobbyController:sendTableInfoReq(count)
	self._socketGame = cc.msgHandler.socketGame
	if self._socketGame then
		if cc.dataMgr.startReqTableID < cc.dataMgr.selectedGameInfo.tableNum then
			local _start = cc.dataMgr.startReqTableID
			local _count = count
			if _start + count > cc.dataMgr.selectedGameInfo.tableNum then
				_count = cc.dataMgr.selectedGameInfo.tableNum - _start
			end
			--print("count is " .. _count)
			cc.dataMgr.startReqTableID = cc.dataMgr.startReqTableID + _count
			cc.dataMgr.lastNumReqTable = _count
			print("table req : start is " .. _start .. " number is " .. cc.dataMgr.selectedGameInfo.tableNum)
			local req = wnet.PL_PHONE_CG_ROOM_USERLIST.new(cc.protocolNumber.PL_PHONE_CG_ROOM_USERLIST_P, cc.dataMgr.lobbyLoginData.userID)
			self._socketGame:send(req:bufferIn(_start, _count - 1):getPack())
		else
			print("too big ".. cc.dataMgr.startReqTableID)
		end
	end
end

function lobbyController:sendGameListReq(gameID)
	if self._socketLobby then
		local req = wnet.PL_PHONE_CS_GAMELIST_REQ.new(cc.protocolNumber.PL_PHONE_CS_GAMELIST_REQ_P, cc.dataMgr.lobbyLoginData.userID)
		self._socketLobby:send(req:bufferIn(gameID):getPack())
	end
end

function lobbyController:sendLoginTableReq(tableid, chairid, password)
	if self._socketGame then
		cc.dataMgr.selectedTableID = tableid
		cc.dataMgr.selectedChairID = chairid
		local req = wnet.CG_ENTERTABLE_REQ.new(cc.protocolNumber.CG_ENTERTABLE_REQ_P, cc.dataMgr.lobbyLoginData.userID)
		self._socketGame:send(req:bufferIn(tableid, chairid, password or ""):getPack())
	end
end

function lobbyController:sendHandUpReq(tableid, chairid, password)
	if self._socketGame then
		local req = wnet.CG_HANDUP.new(cc.protocolNumber.CG_HANDUP_P, cc.dataMgr.lobbyLoginData.userID)
		self._socketGame:send(req:bufferIn():getPack())
	end
end

function lobbyController:sendLeaveTableReq()
	if self._socketGame then
		local req = wnet.CG_LEAVETABLE_REQ.new(cc.protocolNumber.CG_LEAVETABLE_REQ_P, cc.dataMgr.lobbyLoginData.userID)
		self._socketGame:send(req:bufferIn():getPack())
	end
end

function lobbyController:sendFastJoinReq()
	if self._socketGame then
		local req = wnet.CG_FAST_JOIN_GAME_REQ_P.new(cc.protocolNumber.CG_FAST_JOIN_GAME_REQ_P, cc.dataMgr.lobbyLoginData.userID)
		self._socketGame:send(req:bufferIn():getPack())
	end
end

return lobbyController