--
-- Author: ChenShao
-- Date: 2015-12-17 16:14:20
--
local WrapRoomMsgSender = class("WrapRoomMsgSender")

function WrapRoomMsgSender:ctor()
	
	--self.gameSocket = cc.msgHandler.socketGame
end

function WrapRoomMsgSender:sendGETCREATEROOMINFOREQ(tableId)
	print("cc.protocolNumber.CG_GETCREATEROOMINFO_REQ_P = " ..cc.protocolNumber.CG_GETCREATEROOMINFO_REQ_P)
	print("tableId = " ..tableId)
	local req = wrapRoom.wrapRoomStruct.CG_GETCREATEROOMINFOREQ.new(cc.protocolNumber.CG_GETCREATEROOMINFO_REQ_P, cc.dataMgr.lobbyLoginData.userID)
    cc.msgHandler.socketGame:send(req:bufferIn(tableId - 1):getPack())
end

function WrapRoomMsgSender:sendCREATEROOMREQ(nBet, strPasswd, bWatch)
	local req = wrapRoom.wrapRoomStruct.CG_CREATEROOMREQ.new(cc.protocolNumber.CG_CREATEROOMINFO_REQ_P, cc.dataMgr.lobbyLoginData.userID)
    cc.msgHandler.socketGame:send(req:bufferIn(nBet, strPasswd, bWatch):getPack())
end


return WrapRoomMsgSender