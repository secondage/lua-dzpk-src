--
-- Author: ChenShao
-- Date: 2015-12-17 16:15:52
--
wrapRoom = {}

local wrap = {}

function wrap.init()
	wrapRoom = {}

	local path = "wrapRoom.src."
	wrapRoom.wrapRoomMsgHandler = require(path .."wrapRoomMsgHandler").new()
	wrapRoom.wrapRoomMsgSender = require(path .."wrapRoomMsgSender").new()
	wrapRoom.wrapRoomViewCtrller = require(path .."wrapRoomViewCtrller").new()
	wrapRoom.wrapRoomLogic = require(path .."wrapRoomLogic").new()
	wrapRoom.wrapRoomStruct = require(path .."wrapRoomStruct")
end

return wrap
