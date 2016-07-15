--
-- Author: ChenShao
-- Date: 2015-09-10 09:30:22
--
local TaskMsgHandler = class("TaskMsgHandler")

function TaskMsgHandler:ctor()
	self.msgs = {}

	function self.msgs.proc_GC_TASK_TASKINFOLIST_ACK_P(buf)
		print("<---proc_GC_TASK_TASKINFOLIST_ACK_P")
		local ack = wnet.GC_TASK_TASKINFOLIST.new()
		ack:bufferOut(buf)

		--dump(ack)
		
	
		app.taskLogic:setCurTaskListInfo(ack.singleTaskInfo)
		if app.taskLayerCtrller.eventProtocol == nil then return end
		app.taskLayerCtrller.eventProtocol:dispatchEvent({ name = "GC_TASK_TASKINFOLIST_ACK_P"})
	end

	function self.msgs.proc_GC_TASK_WRITETASKOPERINFO_ACK_P(buf)
		print("<---proc_GC_TASK_WRITETASKOPERINFO_ACK_P")
		local ack = wnet.GC_TASK_WRITETASKOPERINFO.new()
		ack:bufferOut(buf)
		--dump(ack)
		--if ack.taskStatus == 0 then
		--if ack.taskStatus == wnet.Task_Operator_Status.Task_Operator_Status_End then
			app.taskLogic:updateCurTaskProcess(ack.taskId, ack.taskCurProcess, ack.taskStatus)
			app.taskLayerCtrller.eventProtocol:dispatchEvent({ name = "GC_TASK_TASKINFOLIST_ACK_P"})
		--end
	end

	function self.msgs.proc_GC_TASK_GETAWARD_ACK_P(buf)
		print("<---proc_GC_TASK_GETAWARD_ACK_P")
		local ack = wnet.GC_TASK_GETAWARD.new()
		ack:bufferOut(buf)
		if ack.nResult == wnet.Task_Operator_GetAwardResult.Task_Operator_GetAwardResult_Sucess then
			app.taskLogic.curTaskListInfo[ack.taskId] = nil
			app.taskLayerCtrller.eventProtocol:dispatchEvent({ name = "GC_TASK_TASKINFOLIST_ACK_P"})

			app.taskLayerCtrller.eventProtocol:dispatchEvent({ name = "Evt_Finish_Task", data = ack.taskId}) --任务完成祝贺
		end

		app.taskLayerCtrller.eventProtocol:dispatchEvent({ name = "GC_TASK_GETAWARD_ACK_P", data = ack })
	end

	function self.msgs.proc_GC_TASK_NEWTASK_ACK_P(buf)
		print("<---proc_GC_TASK_NEWTASK_ACK_P")
		local ack = wnet.GC_NEWTASK_INFO.new()
		ack:bufferOut(buf)

		local taskType = app.taskLogic:getTaskTypeByTaskId(ack.taskId)
		if taskType == 0 then --列表任务
			app.taskLogic:addCurTaskListInfo(ack.taskId)
			app.taskLayerCtrller.eventProtocol:dispatchEvent({ name = "GC_TASK_TASKINFOLIST_ACK_P"})

		elseif taskType == 2 then --元宝任务
			app.taskLogic.yuanbaoTaskId = ack.taskId
			app.taskLayerCtrller.eventProtocol:dispatchEvent({ name = "Evt_Update_GameTask", data = ack.taskId})
		end
	end

	function self.msgs.proc_GC_TASK_UPDATE_YUANBAO_P(buf) --该协议已经在IndividualLogic处理
		local ack = wnet.TASK_UPDATE_YUANBAO.new()
		ack:bufferOut(buf)
		cc.dataMgr.userInfoMore.ingot = ack.yuanBaoNum
	end
end

function TaskMsgHandler:procMsgs(socket, buf, opCode)
	--if app.taskLayerCtrller.eventProtocol == nil then return end

	local msgProc = self.msgs["proc_" .. (cc.protocolNumber:getProtocolName(opCode) or "")]

	if msgProc ~= nil then
        msgProc(buf)
        return true
    end
    
    return false
end


return TaskMsgHandler