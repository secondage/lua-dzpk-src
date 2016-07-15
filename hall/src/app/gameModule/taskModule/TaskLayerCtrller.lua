--
-- Author: ChenShao
-- Date: 2015-09-10 09:40:08
--
local TaskLayerCtrller = class("TaskLayerCtrller")
local scheduler = require("framework.scheduler")

function TaskLayerCtrller:procGameTaskUI(parent)
	print("TaskLayerCtrller:procGameTaskU")
	self.NodeTask =  parent:getChildByName("Node_task"):show()

	if self.NodeTask == nil then print("no task res") return end  --说明该小游戏没有任务

	self.btnBoxOn = self.NodeTask:getChildByName("Button_btnBox_on"):show()
	self.btnBoxOff = self.NodeTask:getChildByName("Button_btnBox_off"):hide()

	self.btnBoxOn:setPressedActionEnabled(true)
	self.btnBoxOff:setPressedActionEnabled(true)

	local function onBtnBoxEvt(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			self:updateTaskListUI()
			self.taskImgBg:show()
			self.taskImgBg.userdata:show()

			app.popLayer.show(self.taskLayer)
			--self.taskLayer:show()
		end
	end
	self.btnBoxOn:addTouchEventListener(onBtnBoxEvt)
	self.btnBoxOff:addTouchEventListener(onBtnBoxEvt)

	self.imgDesc = self.NodeTask:getChildByName("Image_des"):hide()
	self.txtGoal = self.imgDesc:getChildByName("Text_goal"):hide()
	self.txtAward = self.imgDesc:getChildByName("Text_awad"):hide()

	self.boxBlink = self.NodeTask:getChildByName("Image_blink")
	if self.boxBlink then
		self.boxBlink:hide()
	end
end

function TaskLayerCtrller:boxBlinkFunc(isOnShow)
	if self.boxBlink then
		self.boxBlink:stopAllActions()
		self.boxBlink:hide()
		if isOnShow then
			local act = cc.Blink:create(50, 100)
			self.boxBlink:runAction(cc.RepeatForever:create(act))
		end
	end
end

function TaskLayerCtrller:updateBoxUI(isOnShow, isHide)
	if app.runningScene.name == "GameScene" then
		self.btnBoxOn:setVisible(isOnShow)
		self.btnBoxOff:setVisible(not isOnShow)

		self:boxBlinkFunc(isOnShow)

		if isHide then
			self.btnBoxOn:setVisible(false)
			self.btnBoxOff:setVisible(false)
			if self.boxBlink then
				self.boxBlink:setVisible(false)
			end
		end
	end
end

function TaskLayerCtrller:hideGameTask()
	self.imgDesc:hide()
end

local function procUI(self)
	self.layToast = self.taskLayer:getChildByName("Panel_toast"):hide()

	local layRoof = self.taskLayer:getChildByName("Panel_roof")

	local function onCloseEvt(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			--self.taskLayer:hide()
			self.taskImgBg:hide()
			self.taskImgBg.userdata:hide()
			if app.runningScene.name == "RoomScene" then
				app.runningScene.nPopLayers = app.runningScene.nPopLayers - 1
			end
		end
	end
	layRoof:addTouchEventListener(onCloseEvt)
	layRoof:hide()

	self.taskImgBg = self.taskLayer:getChildByName("Image_taskbg"):hide()
	self.taskImgBg.userdata = layRoof
	self.imgItem = self.taskLayer:getChildByName("Image_item"):hide()

	local btnClose = self.taskImgBg:getChildByName("Button_3")
	if btnClose then
		btnClose:addTouchEventListener(onCloseEvt)
		btnClose:setPressedActionEnabled(true)
	end
	
end 

local function listenEvent(self)

	self.eventProtocol = require("framework.components.behavior.EventProtocol").new()

	self.eventProtocol:addEventListener("GC_TASK_TASKINFOLIST_ACK_P", function(event) --获取任务列表事件
		print("evt_GC_TASK_TASKINFOLIST_ACK_P")

		if app.runningScene.name == "RoomScene" or app.runningScene.name == "GameScene" then
			self:updateTaskListUI() 
		end
	end)

	self.eventProtocol:addEventListener("Evt_Finish_Task", function(event) --完成任务提示
		print("Evt_Finish_Task")
		if app.runningScene.name == "RoomScene" or app.runningScene.name == "GameScene" then
			local taskId = event.data
			self:showGetAwardToast(taskId)
		end
	end)

	self.eventProtocol:addEventListener("Evt_Update_GameTask", function(event) --获取元宝任务
		print("Evt_Update_GameTask")
		if app.runningScene.name == "RoomScene" or app.runningScene.name == "GameScene" then
			local taskId = event.data
			if taskId == -1 then
				self.imgDesc:hide()
				return
			end
			self.imgDesc:show()
			print("taskId = " ..taskId)
			app.taskLogic:getTaskContentByTaskId(taskId)
			self.txtGoal:show():setString("目标:" ..app.taskLogic:getTaskContentByTaskId(taskId))
			self.txtAward:show():setString("奖励:" ..app.taskLogic:getYuanBaoNumByTaskId(taskId) .."元宝")
		end
	end)
end

function TaskLayerCtrller:updateTaskListUI()
	self:updateBoxUI(false)
	
	local listViewTask = self.taskImgBg:getChildByName("ListView_tasklist"):show()
	listViewTask:removeAllItems()

	local taskListInfo = app.taskLogic.curTaskListInfo

	if taskListInfo == nil then
		return "no task"
	end
	if taskListInfo and table.nums(taskListInfo) <= 0 then
		self:updateBoxUI(false, 1)
		return "no task"
	end

	for taskId, data in pairs(taskListInfo) do
		local itemClone = self.imgItem:clone():show()
		local txtTaskGoal = itemClone:getChildByName("Text_taskGoal")

		local taskInfo = app.taskLogic:getTaskInfoByTaskId(taskId)
		if taskInfo then
			txtTaskGoal:setString(taskInfo.taskText)

			local fontYuanBaoNum = itemClone:getChildByName("BitmapFontLabel_awardNum")
			fontYuanBaoNum:setString(taskInfo.currencyNum)
			listViewTask:pushBackCustomItem(itemClone)

			local btnFinish = itemClone:getChildByName("Button_btnFinish")
			btnFinish:addTouchEventListener(function(obj, type)
				if type == 2 then
					app.audioPlayer:playClickBtnEffect()
					app.taskLogic:sendReqFinishTask(taskId)
				end
			end)
			local taskStatus = data.taskStatus
			print("taskStatus = " ..taskStatus)
			if taskStatus == wnet.Task_Operator_Status.Task_Operator_Status_End then --完成
				btnFinish:setTitleText("完成")
				btnFinish:setTouchEnabled(true)
				self:updateBoxUI(true)
			else
				local process = data.taskCurProcess .."/" ..taskInfo.taskNumber
				btnFinish:setTitleText(process)
				btnFinish:setTouchEnabled(false)
			end
		end
	end
end

function TaskLayerCtrller:showGetAwardToast(taskId)
	self.layToast:show()
	local txtYuanBao = self.layToast:getChildByName("Image_toastbg"):getChildByName("Text_yuanbaonum"):show()
	local yuanBaoNum = app.taskLogic:getYuanBaoNumByTaskId(taskId)
	print("yuanBaoNum = " ..yuanBaoNum)
	txtYuanBao:setString(yuanBaoNum)

	scheduler.performWithDelayGlobal(function()
		self.layToast:hide()
	end, 3)
	self:playCaiDai()
end

function TaskLayerCtrller:playCaiDai()
	for i = 1, 6 do
		local caidai = cc.ParticleSystemQuad:create("publicui/zhixue_" ..i ..".plist")
		if caidai then
			caidai:show()
			caidai:setPosition(cc.p(display.width / 2 + 100, display.height))
			caidai:addTo(self.taskLayer)
			caidai:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create(function()
				caidai:removeFromParent()
			end)))
		end
	end
end

function TaskLayerCtrller:ctor()
	
end

function TaskLayerCtrller:createLayer(pathRes)
	pathRes = pathRes or "Layers/TaskLayer.csb"
	self.taskLayer = cc.CSLoader:createNode(pathRes):show()

	self.taskLayer:setAnchorPoint(cc.p(0.5, 0.5))
	self.taskLayer:ignoreAnchorPointForPosition(false)
	self.taskLayer:setPosition(display.cx, display.cy)

	procUI(self)
	listenEvent(self)

	local testLayer = require("app.gameModule.taskModule.test").new():addTo(self.taskLayer)

	return self.taskLayer 
end

return TaskLayerCtrller