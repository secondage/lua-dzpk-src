--
-- Author: ChenShao
-- Date: 2015-08-22 11:14:09
--
local SignCtrlLayer = class("SignCtrlLayer")

local function procUI(self)
	local btnExit = self.signLayer:getChildByName("Button_btnExit")
	btnExit:addTouchEventListener(function(obj, type)
		if type == 2 then
			self.signLayer:hide()
		end
	end)
end

function SignCtrlLayer:createLayer()
	self.signLayer = cc.CSLoader:createNode("Layers/RankLayer.csb")

	procUI(self)
	return self.signLayer
end

return SignCtrlLayer