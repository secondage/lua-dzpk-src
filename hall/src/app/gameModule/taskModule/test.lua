--
-- Author: ChenShao
-- Date: 2015-09-14 17:17:06
--
local Test = class("Test", function()
	return display.newLayer()
end)

function Test:ctor()
	print("Test:ctor()")

   
   --[[ local isFlag = true
	local function onKeyReleased(keyCode)
        if keyCode == cc.KeyCode.KEY_F1 then
        	local ack = {}
        	ack.taskId = 20100701
			--app.taskLayerCtrller.eventProtocol:dispatchEvent({ name = "Evt_Finish_Task", data = ack.taskId}) --任务完成祝贺
        end
	end

    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )

    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)]]
end

return Test