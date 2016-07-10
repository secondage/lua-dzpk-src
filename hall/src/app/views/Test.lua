local Test = class("Test", function()
	return display.newLayer()
end)

function Test:ctor()
	print("Test:ctor()")

	local function onKeyReleased(keyCode)
        if keyCode == cc.KeyCode.KEY_F1 then 
           -- local device = require("framework.device")
          --  local strMac = device.getOpenUDID()
           -- print("strMac = " ..strMac)
			app.toast.show("不满足其它玩家的最大断线率要求")
        end
	end

    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )

    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

return Test