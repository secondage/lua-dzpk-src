--
-- Author: ChenShao
-- Date: 2015-12-18 14:48:00
--
local WrapRoomLogic = class("WrapRoomLogic")

function WrapRoomLogic:ctor()
	self.tblOpenTable = {} --保存 已经有房主的桌子 key tableid 和 value userid
end


function WrapRoomLogic:addOpenTable(tableId, userId)
	self.tblOpenTable[tableId + 1] = userId
end

function WrapRoomLogic:removeOpenTable(tableId)
	self.tblOpenTable[tableId + 1] = nil
end

function WrapRoomLogic:updateOpenTable(tableId, userId)
	if userId == 0 then
		self:removeOpenTable(tableId)
	else
		self:addOpenTable(tableId, userId)
	end
end

function WrapRoomLogic:isOpenTable(tableId)
	local is = false
	--dump(self.tblOpenTable)
	if self.tblOpenTable[tableId] then
		is = true
	end
	return is
end

function WrapRoomLogic:proc_GC_TABLEMASTER_INFO_P(data)
	self.tblOpenTable = {}
	for i = 1, #data.tableMasterList do
		self:updateOpenTable(data.tableMasterList[i].tableId, data.tableMasterList[i].userId)
	end
end

function WrapRoomLogic:proc_GC_ROOMS_MASTER_P(data)
	self:updateOpenTable(data.tableId, data.userId)
end

function WrapRoomLogic:proc_GC_GETCREATEROOMINFO_ACK_P(data)
	if data.nResult == 0 then --成功
		wrapRoom.wrapRoomViewCtrller:show()
	else--保留	
		app.toast.show("Unknown error:" ..data.nResult)
	end
end

function WrapRoomLogic:proc_GC_CREATEROOMINFO_ACK_P(data)
	if data.bResult == true then
		wrapRoom.wrapRoomViewCtrller:hide()
		display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "GC_CREATEROOMINFO_ACK_P"})
	end
end


return WrapRoomLogic