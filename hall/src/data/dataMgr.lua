local dataMgr = class("dataMgr")
function dataMgr:ctor()
	self.userList = {} --gameserver里玩家列表,初始化后不再维护
	self.gameData = {}
	self.startReqTableID = 0
	self.numReqTable = 24
	self.lastNumReqTable = 0
	self.tables = {} --table控件列表
	self.userTable = {}  --gameserver上玩家关系表
	self.tableUsers = {} --table里玩家列表
	self.selectedChairID = -1
	self.selectedTableID = -1
	self.tablePlyNum = 0
	self.playingGame = ""
	self.isWatcher = false  --是否为旁观
	self.isBroken = false
	self.selectServerID = -1
	self.selectGameID = -1
	self.selectRoomID = -1
	self.gamingState = false --是否正在游戏中
	self.baseLivingData = {}
	self.guestLogin = false --是否是游客登陆
	self.lobbyLoginData = {}
	self.userInfoMore = {}
	self.gameName = "" --小游戏名字
	self.gameLists = {}
	self.isChangeAccLogin = false --是否为切换账号登录
	self.selectGameType = -1 --选择游戏场次类型0 为游戏豆场 1 积分场
	self.isRoomBackToHall = false
	self.moneyLimit = 0
	self.isCommonLogin = false --是否为正常登录，hallscene 再次登陆标识
	self.lastSelectGameId = 0 --上一次选择玩的小游戏
	self.bFirstLogin = true
	self.bHallShowChannel = false  
	self.bVip = false
	self.tableStatusList = {}
	self.isReLogin = false
	self.reconnected = false

	--[[
        -- 数组benefitConfigData，benefitTaskList，benefitLockedTaskList元素字段
        --	taskId
        --	nextTaskId
        --	lastTaskId
        -- 	award
        --	taskText 数组
        --	taskType （值为share，invite，newbie）
        --	taskStatus
        --	taskCurProcess
        --	taskNumber
    --]]
	self.benefitConfigData = {}
	self.benefitTaskList = {}
	self.benefitLockedTaskList = {}
	self.invitingRecord = {}

	self.selectRoonName = "" --房间名

	self.hallClearObj = {}			-- hallScene中每个游戏需要清理的对象,需实现onExit 方法
	self.withoutRoomScene = false	-- 是否跳过room scene
	self.withoutLobbyScene = true	-- 是否跳过lobby scene
	self.useRandMatch = false		-- 是否使用循环赛
	self.randMatch = {}				-- 比赛信息

	self.castMultSetInfo = {}		-- 底注设置功能数据
	self.castMultSetInfo.useCastMultSet = false		-- 是否使用底注设置标识

	self.tableBetInfoInRoom ={}			-- 房间里桌子的底注信息
	self.guiderFlag = {}			--新手指引标志
	self.selectTableIDNow = -1		-- 点击桌子id
end

function dataMgr:clear()
	self.benefitConfigData = {}
	self.benefitTaskList = {}
	self.benefitLockedTaskList = {}
	self.invitingRecord = {}
	self.guiderFlag = {}
	self.reconnected = false
end

return dataMgr