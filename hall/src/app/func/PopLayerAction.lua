--
-- Author: ChenShao
-- Date: 2015-12-03 14:19:15
--
local popLayerAction = {}

function popLayerAction.show(lay)

	if lay == nil then
		return
	end
	lay:setScale(0)
	lay:show()

	local scaleTo = cc.ScaleTo:create(0.3, 1)

	local scaleTo_EaseOut = cc.EaseBackOut:create(scaleTo)

--	lay:stopAllActions() 加上这句话 有时会造成 弹出时略卡顿现象
	lay:runAction(scaleTo_EaseOut)
end

function popLayerAction.showEx(lay)
	if lay == nil or lay:getScale() < 1 then
		return
	end
	lay:setScale(0)
	lay:show()

	local scaleTo = cc.ScaleTo:create(0.3, 1)
	local scaleTo_EaseOut = cc.EaseBackOut:create(scaleTo)

	local posOld = cc.p(lay:getPosition())
	local anchorOld = lay:getAnchorPoint()
	lay:setAnchorPoint(cc.p(0.5, 0.5))
	local size = lay:getContentSize()
	lay:setPosition(posOld.x + size.width * (0.5 - anchorOld.x), posOld.y + size.height * (0.5 - anchorOld.y))
	local funcFinal = cc.CallFunc:create(function()
		lay:setPosition(posOld)
		lay:setAnchorPoint(anchorOld)
	end)

	local action = cc.Sequence:create(scaleTo_EaseOut, funcFinal)

	--	lay:stopAllActions() 加上这句话 有时会造成 弹出时略卡顿现象
	g_pauseMsgHandlerForAWhile(0.5)
	lay:runAction(action)
end


return popLayerAction