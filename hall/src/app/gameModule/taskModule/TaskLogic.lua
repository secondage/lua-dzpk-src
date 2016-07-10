--
-- Author: ChenShao
-- Date: 2015-09-14 10:32:59
--
local TaskLogic = class("TaskLogic")

local json = require("framework.json")
local httpUtils = require("app.func.HttpUtils")


function TaskLogic:ctor()
	self.allTaskListInfo = {}
	self.curTaskListInfo = {}
	self.yuanbaoTaskId = -1

	self.checkVersion = {}--标识是否检测过版本号，检测过第二次，则不需要http检测版本号
end

function TaskLogic:initData()
	self.allTaskListInfo = {}
	self.curTaskListInfo = {}
	self.yuanbaoTaskId = -1

	self:readTaskJson()
end

function TaskLogic:clearData()
	self:initData()
end

function TaskLogic:setCurTaskListInfo(data)
	--dump(data)
	if self.curTaskListInfo == nil then return end
	for _, val in pairs(data) do
		if self:getTaskTypeByTaskId(val.taskId) == 0 then
			self.curTaskListInfo[val.taskId] = val
		elseif self:getTaskTypeByTaskId(val.taskId) == 2 then --断线重连 元宝任务 跟着这消息一起过来
			self.yuanbaoTaskId = val.taskId
			print("self.yuanbaoTaskId = " ..self.yuanbaoTaskId)
		end
	end
end

function TaskLogic:updateCurTaskProcess(taskId, curProcess, taskStatus)
	print("updateCurTaskProcess")
	local taskInfo = self.curTaskListInfo[taskId]
	if taskInfo then
		taskInfo.taskCurProcess = curProcess
		taskInfo.taskStatus = taskStatus
	end
	--dump(self.curTaskListInfo)
end

function TaskLogic:addCurTaskListInfo(taskId)
	self.curTaskListInfo[taskId] = {taskStatus = 0, taskCurProcess = 0}
end

function TaskLogic:getTaskTypeByTaskId(taskId)

	local data = self.allTaskListInfo[taskId]
	if data then
		return data.taskType
	end
	return 0
end

--若已下载从已下载读 若后面读取taskversion发现需要从新更新，更新后再读一次
function TaskLogic:readTaskJson()
	
	--if cc.FileUtils:getInstance():isFileExist(cc.dataMgr.playingGame .."/res/" ..cc.dataMgr.playingGame .."_task.json") then
		self:readTaskListFormFile(cc.dataMgr.playingGame .."/res/" ..cc.dataMgr.playingGame .."_task.json")
	--end

	return -1
end


function TaskLogic:downloadTaskJson()--无用

	--local fileName = cc.dataMgr.playingGame .."_task.json"
	--local filePath = cc.FileUtils:getInstance():getWritablePath() ..fileName

	local ret = self:readTaskJson()
	if ret == -1 then
		return
	end

	local serverVersion = self.checkVersion[cc.dataMgr.playingGame] or 0
	local localVersion = tonumber(cc.UserDefault:getInstance():getStringForKey(cc.dataMgr.playingGame .."_task_version", "0"))

	if serverVersion > localVersion then
		local urljson = urls.taskJson ..fileName
		print("urljson = " ..urljson)
	
		httpUtils.reqHttp(urljson, function(ret, response)
			if ret then
				local info = json.decode(response)
				--dump(info)
				if not checktable(info) then
					return
				end

				local file = io.open(filePath, "w+")
				if file then
					file:write(response)
					file:close()

					print("<--read server json")
					self:readTaskListFormFile(filePath)
					cc.UserDefault:getInstance():setStringForKey(cc.dataMgr.playingGame .."_task_version", tostring(serverVersion))
				else
					print("can not open " ..fileName)
				end
			end
		end)
	else
		print("无需下载任务文件")
	end
end

function TaskLogic:readTaskListFormFile(fileName)
	local taskFileData = cc.FileUtils:getInstance():getStringFromFile(fileName)
	local allTaskListInfo = json.decode(taskFileData)
	if allTaskListInfo == nil then
		return
	end
	if not checktable(allTaskListInfo) then
		return
	end

	self.allTaskListInfo = {}
	for _, val in pairs(allTaskListInfo) do
		self.allTaskListInfo[val.taskId] = val
	end
end

function TaskLogic:getTaskInfoByTaskId(taskId)
	return self.allTaskListInfo[taskId]
end

function TaskLogic:getYuanBaoNumByTaskId(taskId)
	local taskInfo = self.allTaskListInfo[taskId]
	if taskInfo then
		return taskInfo.currencyNum
	end
end

function TaskLogic:getTaskContentByTaskId(taskId)
	local taskInfo = self.allTaskListInfo[taskId]
	if taskInfo then
		return taskInfo.taskText
	end
end

function TaskLogic:sendReqFinishTask(taskId)
	local req = wnet.CG_TASK_GETAWARD.new(cc.protocolNumber.CG_TASK_GETAWARD_REQ_P, cc.dataMgr.lobbyLoginData.userID)
	cc.msgHandler.socketGame:send(req:bufferIn(cc.dataMgr.lobbyLoginData.userID, taskId):getPack())
end

return TaskLogic