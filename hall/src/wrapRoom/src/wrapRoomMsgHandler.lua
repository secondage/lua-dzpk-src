--
-- Author: ChenShao
-- Date: 2015-12-17 16:04:09
--
local WrapRoomMsgHandler = class("WrapRoomMsgHandler")

function WrapRoomMsgHandler:ctor()
	--self.msgs = {}
end

function WrapRoomMsgHandler:proc_GC_GETCREATEROOMINFO_ACK_P(buf)
	print("proc_GC_GETCREATEROOMINFO_ACK_P")

	local ack = wrapRoom.wrapRoomStruct.GC_GETCREATEROOMINFOACK.new()
	ack:bufferOut(buf)
	--dump(ack)
	wrapRoom.wrapRoomLogic:proc_GC_GETCREATEROOMINFO_ACK_P(ack)
end

function WrapRoomMsgHandler:proc_GC_CREATEROOMINFO_ACK_P(buf)
	print("proc_GC_CREATEROOMINFO_ACK_P")
	local ack = wrapRoom.wrapRoomStruct.GC_CREATEROOMACK.new()
	ack:bufferOut(buf)
	--dump(ack)
	wrapRoom.wrapRoomLogic:proc_GC_CREATEROOMINFO_ACK_P(ack)
end

function WrapRoomMsgHandler:proc_GC_TABLEMASTER_INFO_P(buf)
	print("proc_GC_TABLEMASTER_INFO_P")
	local ack = wrapRoom.wrapRoomStruct.GC_TABLEMASTER_INFO.new()
	ack:bufferOut(buf)
	--dump(ack)

	wrapRoom.wrapRoomLogic:proc_GC_TABLEMASTER_INFO_P(ack)
end

function WrapRoomMsgHandler:proc_GC_ROOMS_MASTER_P(buf)
	print("proc_GC_ROOMS_MASTER_P")
	local ack = wrapRoom.wrapRoomStruct.stTableMaster.new()
	ack:bufferOut(buf)
	--dump(ack)
	wrapRoom.wrapRoomLogic:proc_GC_ROOMS_MASTER_P(ack)
end

function WrapRoomMsgHandler:procMsgs(socket, buf, opCode)
	local msgProc = self["proc_" .. (cc.protocolNumber:getProtocolName(opCode) or "")]

	if msgProc ~= nil then
        msgProc(self, buf)
        return true
    end
    
    return false

end

return WrapRoomMsgHandler