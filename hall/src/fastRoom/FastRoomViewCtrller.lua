--
-- Author: ChenShao
-- Date: 2015-12-22 15:18:11
--
local FastRoomViewCtrller = class("FastRoomViewCtrller")

local function isFastRoom()
	if cc.dataMgr.selectedGameInfo.gameType == 10 or cc.dataMgr.selectedGameInfo.gameType == 11 then
		return true
	end
	return false
end

local function procBtnChangeTable(self)
	local btnChangeTable = self.layRoot:getChildByName("Button_change_table")
	btnChangeTable:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()

			cc.lobbyController:sendLeaveTableReq()
			cc.lobbyController:sendFastJoinReq()

			self:hide()
			
			if self.funcBtnChangeTable then
				self.funcBtnChangeTable()
			end
		end
	end)
end

function FastRoomViewCtrller:addBtnChangeTableEvt(func)
	self.funcBtnChangeTable = func
end

local function procBtnContinue(self)
	local btnContinue = self.layRoot:getChildByName("Button_continue")
	btnContinue:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()

			cc.lobbyController:sendHandUpReq()

			self:hide()

			if self.funcBtnContinue then
				self.funcBtnContinue()
			end
		end
	end)
end

function FastRoomViewCtrller:addBtnContinueEvt(func)
	self.funcBtnContinue = func
end

local function procUI(self)
	if display.getRunningScene():getChildByName("Node_fastRoom") then
		self.layRoot = display.getRunningScene():getChildByName("Node_fastRoom")
	else
		local layParent = app.runningScene:getResourceNode()
		self.layRoot = layParent:getChildByName("Node_fastRoom"):hide()
	end
	--local layParent = app.runningScene:getResourceNode()
	--self.layRoot = layParent:getChildByName("Node_fastRoom"):hide()
	--self.layRoot:setLocalZOrder(150) --在结算层之上

	procBtnChangeTable(self)
	procBtnContinue(self)
end

function FastRoomViewCtrller:exitEvt()
	self.layRoot:onNodeEvent("exit", function()
		print("<------exit self.FastRoomViewCtrller")
		
		self.funcBtnChangeTable = nil
		self.funcBtnContinue = nil
	end)
end

function FastRoomViewCtrller:show()
	self.layRoot:show()
end

function FastRoomViewCtrller:hide()
	self.layRoot:hide()
end

function FastRoomViewCtrller:ctor()
	

	procUI(self)

	self.funcBtnChangeTable = nil
	self.funcBtnContinue = nil

	self:exitEvt()
end

return FastRoomViewCtrller