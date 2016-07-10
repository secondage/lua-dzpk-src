--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/12/9
-- Time: 13:23
-- To change this template use File | Settings | File Templates.
--

local KeyEventRegister = class("KeyEventRegister")

function KeyEventRegister.registerKeyEvent(root, eventMap)
    local keyListener = cc.EventListenerKeyboard:create()
    local function onKeyRelease(code, event)
        print("onKeyRelease, code:"..code)
        local func = eventMap[code]
        if type(func) == "function" then
            func()
        end
    end
    keyListener:registerScriptHandler(onKeyRelease, cc.Handler.EVENT_KEYBOARD_RELEASED)
    local eventDispatch = root:getEventDispatcher()
    eventDispatch:addEventListenerWithSceneGraphPriority(keyListener, root)
end

return KeyEventRegister

