--
-- Author: ChenShao
-- Date: 2015-08-22 13:54:07
--
local holdOn = {}
local scheduler = require("framework.scheduler")

holdOn.holdOnLayer = nil
local defTime = 10
if g_Platform_Win32 then
	defTime = 5
end
local _time = 20 --test
local _coutTime = 0
local _handler = nil

function holdOn.showEx(text, args) --辰少推荐写法
	local args = args or {}

	local delayTime = args.delayTime or 0
	local parent = args.parent or display:getRunningScene()
	local listener = args.listener
	_time = args.time or defTime  --个人感觉此参数无用

	holdOn.show(text, delayTime, parent, listener)
end

function holdOn.show(text, delayTime, parent, listener)
	parent = parent or display:getRunningScene()
	if holdOn.holdOnLayer then
		holdOn.holdOnLayer:hide()
	end
	holdOn.holdOnLayer = cc.CSLoader:createNode("Layers/HoldOnLayer.csb"):hide():addTo(parent, 2000)--:retain()

	delayTime = delayTime or 0
	holdOn.holdOnLayer:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime), cc.CallFunc:create(function()
		if holdOn.holdOnLayer then
			holdOn.holdOnLayer:show()
		end
	end)))

	holdOn.holdOnLayer:onNodeEvent("exit", function()
		if holdOn.holdOnLayer then
			--holdOn.holdOnLayer:release()
			holdOn.holdOnLayer = nil
		end

		if _handler then 
			scheduler.unscheduleGlobal(_handler)
			--scheduler.unscheduleGlobal(barHandler) 
		end
	end)
	local content = holdOn.holdOnLayer:getChildByName("toastbg"):getChildByName("Text_content")
	content:setString(text)

	_coutTime = 0
	if _handler then scheduler.unscheduleGlobal(_handler) end
	_handler = scheduler.scheduleGlobal(function (dt)
		if 	_coutTime >= _time then
			holdOn.hide()
			
			scheduler.unscheduleGlobal(_handler)
			--scheduler.unscheduleGlobal(barHandler) 
			
			if listener then
				listener()
			else
				app.toast.show("time out, try again!")
			end
		end
		_coutTime = _coutTime + 1
		print("_coutTime = " .._coutTime)
		
	end , 1)
end

function holdOn.hide()
	if holdOn.holdOnLayer ~= nil then
		holdOn.holdOnLayer:hide()
		holdOn.holdOnLayer:stopAllActions()
		holdOn.holdOnLayer = nil
		--holdOn.holdOnLayer:removeSelf()
		if _handler then scheduler.unscheduleGlobal(_handler) end
	end
end

return holdOn