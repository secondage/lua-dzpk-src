--
-- Author: ChenShao
-- Date: 2015-12-17 15:41:13
--
local wrapRoomStruct = {}

local packBody = require "data.packBody"

--[[
wrapRoomStruct.TTTTTTTT = class("TTTTTTTT", packBody)
function wrapRoomStruct.TTTTTTTT:ctor(code, uid, pnum, mapid, syncid)
	wrapRoomStruct.TTTTTTTT.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function wrapRoomStruct.TTTTTTTT:bufferOut(buf)

end
function wrapRoomStruct.TTTTTTTT:bufferIn()
	local buf = wrapRoomStruct.TTTTTTTT.super.bufferIn(self)
	return buf
end
]]

wrapRoomStruct.CG_GETCREATEROOMINFOREQ = class("CG_GETCREATEROOMINFOREQ", packBody) 
function wrapRoomStruct.CG_GETCREATEROOMINFOREQ:ctor(code, uid, pnum, mapid, syncid)
	wrapRoomStruct.CG_GETCREATEROOMINFOREQ.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function wrapRoomStruct.CG_GETCREATEROOMINFOREQ:bufferIn(tableId)
	local buf = wrapRoomStruct.CG_GETCREATEROOMINFOREQ.super.bufferIn(self)
	buf:writeChar(tableId)
	return buf
end

wrapRoomStruct.GC_GETCREATEROOMINFOACK = class("GC_GETCREATEROOMINFOACK", packBody)
function wrapRoomStruct.GC_GETCREATEROOMINFOACK:ctor(code, uid, pnum, mapid, syncid)
	wrapRoomStruct.GC_GETCREATEROOMINFOACK.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function wrapRoomStruct.GC_GETCREATEROOMINFOACK:bufferOut(buf)
	self.nResult = buf:readUByte()
	self.tableId = buf:readChar()
	self.chairId = buf:readChar()
end

wrapRoomStruct.CG_CREATEROOMREQ = class("CG_CREATEROOMREQ", packBody)
function wrapRoomStruct.CG_CREATEROOMREQ:ctor(code, uid, pnum, mapid, syncid)
	wrapRoomStruct.CG_CREATEROOMREQ.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function wrapRoomStruct.CG_CREATEROOMREQ:bufferIn(nBet, strPasswd, bWatch)
	local buf = wrapRoomStruct.CG_CREATEROOMREQ.super.bufferIn(self)
	buf:writeInt(nBet or 0)
	buf:writeStringUShort(strPasswd or "")
	if bWatch == nil then
		bWatch = true
	end
	buf:writeBool(bWatch)
	return buf
end

wrapRoomStruct.GC_CREATEROOMACK = class("GC_CREATEROOMACK", packBody)
function wrapRoomStruct.GC_CREATEROOMACK:ctor(code, uid, pnum, mapid, syncid)
	wrapRoomStruct.GC_CREATEROOMACK.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function wrapRoomStruct.GC_CREATEROOMACK:bufferOut(buf)
	self.bResult = buf:readBool()
end

wrapRoomStruct.stTableMaster = class("stTableMaster", packBody)
function wrapRoomStruct.stTableMaster:ctor(code, uid, pnum, mapid, syncid)
	wrapRoomStruct.stTableMaster.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function wrapRoomStruct.stTableMaster:bufferOut(buf)
	self.tableId = buf:readChar()
	self.userId = buf:readInt()
end

wrapRoomStruct.GC_TABLEMASTER_INFO = class("GC_TABLEMASTER_INFO", packBody)
function wrapRoomStruct.GC_TABLEMASTER_INFO:ctor(code, uid, pnum, mapid, syncid)
	wrapRoomStruct.GC_TABLEMASTER_INFO.super.ctor(self, code, uid or 0, pnum or 0, mapid or 0, syncid or 0)
end
function wrapRoomStruct.GC_TABLEMASTER_INFO:bufferOut(buf)
	self.tableMasterList = {}
	for i = 1, buf:readShort() do
		local stTableMaster = wrapRoomStruct.stTableMaster.new()
		stTableMaster:bufferOut(buf)
		self.tableMasterList[#self.tableMasterList + 1] = stTableMaster
	end
end

return wrapRoomStruct