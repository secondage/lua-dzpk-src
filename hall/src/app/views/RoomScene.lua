require "data.protocolPublic"

local RoomScene = class("RoomScene", cc.load("mvc").ViewBase)

RoomScene.RESOURCE_FILENAME = "hall/RoomScene.csb"
local RoomSceneEvents = {}
RoomScene.RESOURCE_BINDING = RoomSceneEvents
local inputUtil = require("app.func.InputUtil")
local _rowNum = 3 --每排的桌子数
function RoomScene:onCreate()
	self.name = "RoomScene"
	app.runningScene = self
	self.nPopLayers = 0
	printf("resource node = %s", tostring(self:getResourceNode()))
	self.eventProtocol = require("framework.components.behavior.EventProtocol").new()
	cc.msgHandler:setPlayingScene(self)
	
	cc.dataMgr.userList = {}
	cc.dataMgr.tables = {} --UI
	cc.dataMgr.userTable = {}
	self.totalTableCount = 1
	self.tablesInited = false
	cc.dataMgr.lastNumReqTable = 0
	cc.dataMgr.startReqTableID = 0
	self.tableUserStart = 0
	self.tableUserEnd = 0

	self.bCanClick = false --禁止玩家操作阶段
	--[[
	enum ETableStatus
	{
		ETABLE_STATUS_NULL = 0,                    //为空桌子状态
		ETABLE_STATUS_WAIT,                        //为开始游戏，等待状态
		ETABLE_STATUS_WAITLOCK,                    //锁桌子等待状态
		ETABLE_STATUS_GAMING,                      //游戏状态
		ETABLE_STATUS_GAMINGLOCK,                  //锁桌游戏状态
	};]]

--	cc.dataMgr.tableStatus = {} --key tableid vaule 桌子状态

	self.rowClone = {}

	self.roomLayer = self:getResourceNode():getChildByName("Proj_roomLayer"):show()

	if cc.dataMgr.tablePlyNum > 5 then
		_rowNum = 2
	else
		_rowNum = 3
	end
	
	--任务
	self.taskLayer = app.taskLayerCtrller:createLayer():addTo(self:getResourceNode(), 10)
	local btnTask = self:getResourceNode():getChildByName("Button_btnTask")
	btnTask:setVisible(false)
	btnTask:setPressedActionEnabled(true)
	btnTask:addTouchEventListener(function(obj, type)
		if type == 2 then
			if not self.bCanClick then
				return
			end
			app.audioPlayer:playClickBtnEffect()
			if app.taskLayerCtrller:updateTaskListUI() == "no task" then
				app.toast.show("今日任务已全部完成")
			else
				--self.taskLayer:show()
				local imgbg = self.taskLayer:getChildByName("Image_taskbg"):show()
				imgbg.userdata:show()
				app.popLayer.show(imgbg)
				self.nPopLayers = self.nPopLayers + 1
			end
		end
	end)
	if app.funcPublic.isChanllengeGame() then
		btnTask:setVisible(false)
	end

	self.settinglayer = nil
	local btnSetting = self:getResourceNode():getChildByName("Button_btnSetting")
	btnSetting:setPressedActionEnabled(true)
	btnSetting:addTouchEventListener(function(obj, type)
		if type == 2 then
			if not self.bCanClick then
				return
			end
			app.audioPlayer:playClickBtnEffect()

			if self.settinglayer == nil  then
				self.settinglayer = require("app.views.layers.SettingLayer"):createLayer()
				self.settinglayer:addTo(self:getResourceNode(), 20):hide()
			end
			app.popLayer.showEx(self.settinglayer:getChildByName("Panel_root"))
			self.settinglayer:setVisible(true)
			self.nPopLayers = self.nPopLayers + 1
		end
	end)	
	-----

	self.isBackToHallScene = false
	local btnExit = self:getResourceNode():getChildByName("Button_btnExit")
	btnExit:setPressedActionEnabled(true)
	self.btnExit = btnExit
	btnExit:addTouchEventListener(function(obj, type)
		if type == 2 then
		
			app.audioPlayer:playClickBtnEffect()
			if app.runningScene.name ~= "RoomScene" then return end
			cc.dataMgr.isRoomBackToHall = true
			cc.msgHandler:disconnectFromGame()
			app.sceneSwitcher:enterScene("HallScene")
			self.isBackToHallScene = true
		end
	end)

	local btnFastJoin = self.roomLayer:getChildByName("Button_kuaisukaishi")
	btnFastJoin:setVisible(false)
	btnFastJoin:setPressedActionEnabled(true)
	btnFastJoin:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			app.holdOn.show("Search table...")
			cc.lobbyController:sendFastJoinReq()
		end
	end)

	if app.funcPublic.isWrapGame() then
		btnFastJoin:hide()
	end
	--self:fillTable(cc.dataMgr.selectedGameInfo.tableNum)

	if cc.dataMgr.castMultSetInfo.useCastMultSet == true then
		app.castMultSet = require("hall/src/hall/view/CastMultipleSet.lua").new()
		app.castMultSet:init(self:getResourceNode(),cc.dataMgr.castMultSet.beiShuInfo or cc.dataMgr.castMultSetInfo.castMultInfo,true)
		self:getResourceNode():addChild(app.castMultSet)
	end

	app.setBetLayerDZPK = nil
	cc.dataMgr.tableBetInfoInRoom = {}

	self:showMyLocation()

	if self:initWrapRoom() then
		btnTask:hide()
	end
end

function RoomScene:initWrapRoom()
	
	if app.funcPublic.isWrapGame() then
		self.bWapRoom = true
		require("wrapRoom.src.init").init() --require 文件中的代码 只会执行一次


		local wrapRoomLayer = wrapRoom.wrapRoomViewCtrller:createLayer()
		wrapRoomLayer:addTo(self:getResourceNode(), 10)
		wrapRoom.wrapRoomViewCtrller:hide()

		self.eventProtocol:addEventListener("GC_CREATEROOMINFO_ACK_P", function()
			coroutine.resume(self.co)
		end)

		return true
	end

	return false
end

function RoomScene:showMyLocation()
	local txtMyPath = self:getResourceNode():getChildByName("Text_myPath"):hide()
	txtMyPath:setFontSize(15)
	local strMyPath = ""
	if cc.dataMgr.selectedGameInfo then
		local info = cc.dataMgr.selectedGameInfo
		strMyPath = info.typeName .. "->" ..info.gameName .. "->" ..info.chanelName --.."->" ..cc.dataMgr.selectRoonName
		if cc.dataMgr.selectedGameInfo.onLineNum then
			--if cc.dataMgr.selectedGameInfo.onLineNum < 20 then
			--	cc.dataMgr.selectedGameInfo.onLineNum = 20
			--end
			strMyPath = strMyPath .."(" ..cc.dataMgr.selectedGameInfo.onLineNum .."/" ..info.roomMaxNum ..")"
		end
	end
	
	txtMyPath:setString(strMyPath)
end

function RoomScene:onEnterTransitionFinish_()

	self:fillTable(cc.dataMgr.selectedGameInfo.tableNum)
	g_addLayBulletin(self)

	
	if cc.dataMgr.isBroken then
		app.holdOn.show("Waiting for enter table...", 0.5, self:getResourceNode())
	end
end

function RoomScene:onEnter_()
	cc.lobbyController:sendTableInfoReq(cc.dataMgr.numReqTable)
	-- 如果进入挑战赛房间，初始化挑战赛模块
	if app.funcPublic.isChanllengeGame() then
		if app.challenge == nil then
			app.challenge = require("match/src/Challenge").new()
		end
		app.challenge:setChallengeState(1,{root = self:getResourceNode(),eventProtocol = self.eventProtocol})
	end

	self:procTableList()
	self:listenEvent()
	self:updateUserInfoUI()
	app.audioPlayer:playGamingMusic()
	self:registerKey()
end

local function _procBigNumber(num)
    --get
    if num <= 100000 then
        return tostring(num)
    elseif num <= 1000000 then
        local _b = num / 1000
        local s = string.format("%.2fK", _b)
        return s
    elseif num <= 100000000 then
        local _b = math.floor(num / 1000)
        return _b .. "K"
    else
        local _b = math.floor(num / 1000000)
        local s = string.format("%.2fM", _b)
        return s
    end
end

function RoomScene:updateUserInfoUI()
	local layUserInfo = self.roomLayer:getChildByName("Panel_1")
--[[local _img = layUserInfo:getChildByName("ImageAvatar")
	local img = _img:clone()
	img:setPosition(cc.p(0, 0))
	_img:setVisible(false)
	local fn = "avatar/" .. cc.dataMgr.lobbyUserData.lobbyUser.icon .. ".jpg"
	img:loadTexture(fn, ccui.TextureResType.localType)
	local imgbg = layUserInfo:getChildByName("Image_touxiangkuang")
	local clip = cc.ClippingNode:create()
	clip:setAlphaThreshold(0.05)
	local size = imgbg:getContentSize()
	clip:setPosition(cc.p(size.width / 2, size.height / 2))
	clip:addChild(img)
	local stencil = cc.Sprite:create("avatar/stencil.png")
	stencil:setScale(0.93)
	clip:setStencil(stencil)
	imgbg:addChild(clip, 1)]]--

	local txtNickName = layUserInfo:getChildByName("Text_1")
	
	local strNickName = inputUtil.pick_Input_Counts(cc.dataMgr.lobbyUserData.lobbyUser.strNickNamebuf, 16)
	txtNickName:setString(strNickName)

	local labelBean = layUserInfo:getChildByName("BitmapFontLabel_2")
	labelBean:setString(_procBigNumber(cc.dataMgr.lobbyUserData.lobbyUser.gameCurrency.l))

	local imgGameName = self.roomLayer:getChildByName("Image_gamename"):hide()
	imgGameName:loadTexture(cc.dataMgr.playingGame .."/res/gamename.png")
	print("<--" ..cc.dataMgr.playingGame .."/res/gamename.png")
end

function RoomScene:procTableList()
	local tableListView = self.roomLayer:getChildByName("ListView_Tables")
	local scroll = self.roomLayer:getChildByName("SliderTables")
	scroll:setTouchEnabled(false)
	local function _scroll(object, event)
		if event == ccui.ScrollviewEventType.scrolling then
			local posx, posy = object:getInnerContainer():getPosition()
			local size = object:getInnerContainer():getContentSize()
			scroll:setPercent((1.0 - (-posy / size.height)) * 100)
		end
	end

	tableListView:addScrollViewEventListener(_scroll)
end

function RoomScene:onExit_()
	self.eventProtocol:removeAllEventListeners()

	for _, val in pairs(self.rowClone) do
		if val then
			val:release()
		end 
	end

	if self.isBackToHallScene then
		app.audioPlayer:playHallMusic()
	end

	if app.castMultSet and cc.dataMgr.castMultSetInfo.useCastMultSet == true then
		app.castMultSet:onExit()
	end
end

--- 挑战赛信息响应
function RoomScene:onGC_CHALLENGE_INFO_P(event)
	local data = event.data
	--app.challenge:initScene(1,self:getResourceNode(),self.eventProtocol)
end

function RoomScene:listenEvent()
	self.eventProtocol:addEventListener("GC_ROOM_USERLIST_P", handler(self, RoomScene.onGC_ROOM_USERLIST_P))
	self.eventProtocol:addEventListener("GC_TABLE_STATSLIST_P", handler(self, RoomScene.onGC_TABLE_STATSLIST_P))
	self.eventProtocol:addEventListener("GC_TABLE_STATUS_UP_P", handler(self, RoomScene.onGC_TABLE_STATUS_UP_P))
	self.eventProtocol:addEventListener("GC_ENTERTABLE_P", handler(self, RoomScene.onGC_ENTERTABLE_P))
	self.eventProtocol:addEventListener("GC_LEAVETABLE_P", handler(self, RoomScene.onGC_LEAVETABLE_P))
	self.eventProtocol:addEventListener("GC_GAMEUSER_UP_P", handler(self, RoomScene.onGC_GAMEUSER_UP_P))
	self.eventProtocol:addEventListener("GC_ENTERTABLE_ACK_P", handler(self, RoomScene.onGC_ENTERTABLE_ACK_P))
	self.eventProtocol:addEventListener("GC_GETBETSETINFO_ACK_P", handler(self, RoomScene.onGC_GETBETSETINFO_ACK_P))
	self.eventProtocol:addEventListener("GC_TABLESETBET_INFO_ACK_P", handler(self, RoomScene.onGC_TABLESETBET_INFO_ACK_P))
	self.eventProtocol:addEventListener("GC_NOCHEAT_MATCH_INFO_ACK_P", handler(self, RoomScene.onGC_NOCHEAT_MATCH_INFO_ACK_P))
	self.eventProtocol:addEventListener("GC_CHALLENGE_INFO_P", handler(self, RoomScene.onGC_CHALLENGE_INFO_P))

	self.eventProtocol:addEventListener("Evt_Update_User_Status", handler(self, RoomScene.onUpdateUserStatus))

	self.eventProtocol:addEventListener("USERDATA_CHANGED", handler(self, RoomScene.updateUserInfoUI))
	self.eventProtocol:addEventListener("GC_GETSHOWSETBETINFO_ACK_P", handler(self, RoomScene.onGC_GETSHOWSETBETINFO_ACK_P))
end

function RoomScene:onUpdateUserStatus(event)
	print("onUpdateUserStatus")
	local data = event.data
	local userdata = cc.dataMgr.userTable[data.userID]
	if userdata == nil then 
		return 
	end
	local tableID = userdata.gameData.tableID
	local chairID = userdata.gameData.chairID
	cc.dataMgr.userTable[data.userID].gameData.userStatus=data.value
	local userStatus = data.value
	local layTable = cc.dataMgr.tables[tableID + 1]
	local imgTable = layTable:getChildByName("ImageTable")

	--imgTable:getChildByName("ImageVS_ready"):hide()
	--imgTable:getChildByName("ImageVS_go"):hide()

	print("imgTable.userCount = " ..imgTable.userCount)
	if imgTable.userCount > 0 then
	--	imgTable:getChildByName("ImageVS_ready"):show()
	end

	if userStatus == 4 then --准备
		local imgChair = imgTable:getChildByName("ImageSeat" .. (chairID + 1))
		imgChair:getChildByName("ImageOK"):show()

		--imgTable:getChildByName("ImageVS_ready"):show()
		--imgTable:getChildByName("ImageVS_go"):hide()
	elseif userStatus == 5 or userStatus == 7 then --游戏

		for i = 1, cc.dataMgr.tablePlyNum do
			imgTable:getChildByName("ImageSeat" ..i):getChildByName("ImageOK"):hide()
		end
		--imgTable:getChildByName("ImageVS_ready"):hide()
	--	imgTable:getChildByName("ImageVS_go"):show()

	else
		--imgTable:getChildByName("ImageVS_ready"):show()
		--imgTable:getChildByName("ImageVS_go"):hide()
	end
end

function RoomScene:dealWapRoomChair(imgTable)

	print("imgTable.userCount = " ..imgTable.userCount)
	if imgTable.userCount > 0 then
		imgTable.bOpen = true
	else
		imgTable.bOpen = false
	end
	
	if imgTable.bOpen then
		for i = 1, cc.dataMgr.tablePlyNum do
			print("i = " ..i)
			local imgChair = imgTable:getChildByName("ImageSeat" ..i)
			if imgChair.bHaveUser == false then
				imgChair:loadTexture("Resources/newResources/Room/touxiangkuang.png", 1)
			end
		end
	else
		for i = 1, cc.dataMgr.tablePlyNum do
			print("no i = " ..i)
			local imgChair = imgTable:getChildByName("ImageSeat" ..i)
			imgChair:loadTexture("wrapRoom/res/table_nopeople.png")
		end
	end
end

local function enterTableReq(tableId, chairId, strPwd)
	cc.showLoading("Waiting for enter table")
	cc.lobbyController:sendLoginTableReq(tableId - 1, chairId - 1, strPwd)
end

function RoomScene:showPwdInputMsg(imgChair)
	local tableId = imgChair.tableID
	local chairId = imgChair.chairID

	print("tableId = " ..tableId)

	if cc.dataMgr.tableStatusList[tableId] then
		if cc.dataMgr.tableStatusList[tableId] == 2 or cc.dataMgr.tableStatusList[tableId] == 4 then
			print("<===========" ..cc.dataMgr.tableStatusList[tableId])
			local inputMsg = require("app.func.InputMsgBoxLayer")
			local function btnOKEvt(inputText)
				print("inputText = " ..inputText)
				enterTableReq(tableId, chairId, inputText)
			end

			inputMsg.show({text = "Password:", holdText = "Password", funcOK = btnOKEvt})

			return true
		end
	end

	return false
end

function RoomScene:dealWapRoom(imgTable)
	

	if not wrapRoom.wrapRoomLogic:isOpenTable(imgTable.index) then
		wrapRoom.wrapRoomMsgSender:sendGETCREATEROOMINFOREQ(imgTable.index)
		return false
	end

	return true
end

function RoomScene:fillTable(count)
	self.co = nil
	self.__fillTable = coroutine.create(function()
		local tableListView = self.roomLayer:getChildByName("ListView_Tables")
		local scroll = self.roomLayer:getChildByName("SliderTables")
		print("TableLineTmp_chair_" ..cc.dataMgr.tablePlyNum)
		local _rowTmp = self.roomLayer:getChildByName("TableLineTmp_chair_9"):hide()
		local _newrow = _rowTmp:clone():show()
		_newrow:retain()
		self.rowClone[#self.rowClone + 1] = _newrow
		for i = 1, _rowNum do
			 _rowTmp:getChildByName("PanelTable" ..i):hide()
		end
		local _row = 0
		local _col = 0
		local _send = 0
		_newrow:setName("tableLine" .. _col)
		local function onChairTouched(object, event)
			if event == cc.EventCode.ENDED then
				cc.dataMgr.selectTableIDNow = object.tableID
				if not self.bCanClick then
					return
				end

				app.audioPlayer:playClickBtnEffect()

				self.co = coroutine.create(function()
					if self.bWapRoom then
						if not self:dealWapRoom(object:getParent()) then
							coroutine.yield()
						end
					end

					print("cc.dataMgr.castMultSet.beiShuInfo.gameCurrencyLimit = " ..cc.dataMgr.castMultSet.beiShuInfo.gameCurrencyLimit)
					if cc.dataMgr.playingGame == "dzpk" --then
							and (cc.dataMgr.tableBetInfoInRoom[object.tableID] == nil or cc.dataMgr.tableBetInfoInRoom[object.tableID] == 0)
						and cc.dataMgr.castMultSet and cc.dataMgr.castMultSet.beiShuInfo
							and (cc.dataMgr.castMultSet.beiShuInfo.gameCurrencyLimit == 0 or cc.dataMgr.castMultSet.beiShuInfo.gameCurrencyLimit == 1) then
						app.setBetLayerDZPK = require("dzpk.src.SetBetLayer").new()
						app.setBetLayerDZPK:createSetBetLayer(self:getResourceNode())
						app.setBetLayerDZPK:showSetBetUI()
						app.setBetLayerDZPK:setSeatInfo(object.tableID - 1, object.chairID - 1)
					else
						local table = cc.dataMgr.tables[object.tableID]
						local bHave = false
						if table ~= nil then
							if table.userList ~= nil then
								for i,v in pairs(table.userList) do
									if v ~= nil then
										bHave = true
										break
									end
								end
							else
								bHave = false
							end
							if not bHave and cc.dataMgr.castMultSet and cc.dataMgr.castMultSet.beiShuInfo
									and (cc.dataMgr.castMultSet.beiShuInfo.gameCurrencyLimit ~= nil or cc.dataMgr.castMultSet.beiShuInfo.gameCurrencyLimit ~= 0) then
								cc.dataMgr.tableBetInfoInRoom[object.tableID] = cc.dataMgr.castMultSet.beiShuInfo.nBet
							end
						end

						enterTableReq(object.tableID, object.chairID)
						--[[
						if cc.dataMgr.playingGame == "dzpk" and cc.dataMgr.tableBetInfoInRoom[object.tableID] == nil then
							--print"点击了一下座位，底注消息还未接受"
						else

							if not self:showPwdInputMsg(object) then
								enterTableReq(object.tableID, object.chairID)
							end	
						end
						--]]
					end
				end)
				coroutine.resume(self.co)
				
			end
		end

		local function showSingleTable(i, row)
			local layTable = _newrow:getChildByName("PanelTable" ..i):show()
				layTable:setVisible(true)
				local imgTable = layTable:getChildByName("ImageTable")
				imgTable:getChildByName("NumTableIdx"):setString(tostring(self.totalTableCount))
				imgTable:getChildByName("ImageVS_ready"):hide()
				imgTable:getChildByName("ImageVS_go"):hide()
				imgTable.index = self.totalTableCount
				imgTable.userCount = 0
				imgTable.bOpen = false


				
				table.insert(cc.dataMgr.tables, layTable)
				for ci = 1, cc.dataMgr.tablePlyNum, 1 do
					local _userC = layTable:getChildByName("ImageTable"):getChildByName("ImageSeat" .. ci)
					_userC.chairID = ci
					_userC.tableID = self.totalTableCount
					_userC:addTouchEventListener(onChairTouched)
					if self.bWapRoom then
						_userC:loadTexture("wrapRoom/res/table_nopeople.png")--wraproom
					end
					_userC.bHaveUser = false --wraproom
				end
			self.totalTableCount = self.totalTableCount + 1
		end

		for i = 1, count, 1 do
			showSingleTable(_row + 1, _row)
			_row = _row + 1

			if _row == _rowNum then
				_row = 0
				print("insert table line")
				tableListView:insertCustomItem(_newrow, _col)
				local size = tableListView:getInnerContainer():getContentSize()
				local fsize = tableListView:getContentSize()
				if size.height > 0 and size.height < 100000 then
					scroll:setPercent((fsize.height / size.height) * 100)
				end
				_col = _col + 1
				local _rowTmp =  self.roomLayer:getChildByName("TableLineTmp_chair_9"):hide()
				--local _rowTmp =  self.roomLayer:getChildByName("TableLineTmp_chair_" ..cc.dataMgr.tablePlyNum):hide()
				_newrow = _rowTmp:clone():show()
				_newrow:retain()
				self.rowClone[#self.rowClone + 1] = _newrow
				_newrow:setName("tableLine" .. _col)
				coroutine.yield()
				_send = _send + 1
				if _send > cc.dataMgr.numReqTable then
					cc.lobbyController:sendTableInfoReq(cc.dataMgr.numReqTable)
				end
			end
		end
		if _row ~= 0 then
			tableListView:insertCustomItem(_newrow, _col)
			local size = tableListView:getInnerContainer():getContentSize()
			local fsize = tableListView:getContentSize()
			if size.height > 0 and size.height < 100000 then
				scroll:setPercent((fsize.height / size.height) * 100)
			end
		end
	end)

	local function resume()
		coroutine.resume(self.__fillTable)
	end

	local function hide()
		local tableListView = self.roomLayer:getChildByName("ListView_Tables")
		local scroll = self.roomLayer:getChildByName("SliderTables")
		tableListView:jumpToTop()
		local size = tableListView:getInnerContainer():getContentSize()
		local fsize = tableListView:getContentSize()
		if size.height > 0 and size.height < 100000 then
			scroll:setPercent((fsize.height / size.height) * 100)
		end
		cc.hideLoading()
		self.tablesInited = true
		cc.lobbyController:sendTableInfoReq(cc.dataMgr.numReqTable)
	end

	local _a = cc.Sequence:create(cc.DelayTime:create(0.05), cc.CallFunc:create(resume, { 0 }), nil)
	local _rep = cc.Repeat:create(_a, (count / 3) + 1)
	banBtn(self.btnExit)
	local _b = cc.Sequence:create(_rep, cc.CallFunc:create(hide, { 0 }), cc.CallFunc:create(function()
			pickBtn(self.btnExit)		
			cc.sceneTransFini = true
			self.bCanClick = true
		end))
	self:stopAllActions()
	self:runAction(_b)
end

function RoomScene:dealTableImageVS(imgTable)
	imgTable:getChildByName("ImageVS_ready"):hide()
	imgTable:getChildByName("ImageVS_go"):hide()
	if imgTable.userCount > 0 then
		imgTable:getChildByName("ImageVS_ready"):show()
	else
		imgTable:getChildByName("ImageVS_ready"):hide()
	end
end

function RoomScene:changeSeatUI(user, tableid, chairid, clean)
	if user.gameData.userStatus == 6 then
		return
	end
	local table = cc.dataMgr.tables[tableid + 1]
	if table ~= nil then
		-- 修改桌子的座位上的userID记录，并修改相应UI
		if cc.dataMgr.castMultSetInfo.useCastMultSet==true then
			if table.userList==nil then
				table.userList= {}
			end
			if clean then
				table.userList[chairid] = nil
			else
				table.userList[chairid] = user.userData.userID
			end
			local isHave = false
			for k,v in pairs(table.userList) do
				if v~=nil then
					isHave = true
					break
				end
			end
			if isHave==false then
				app.castMultSet:addTableSign(tableid + 1,0)
			end
		end

		local imgTable = table:getChildByName("ImageTable")

		self:updateImgLock(imgTable)

		if clean == false then
			imgTable.userCount = imgTable.userCount + 1
			local _userC = imgTable:getChildByName("ImageSeat" .. (chairid + 1))
			local _textN = _userC:getChildByName("TextName")

			local strNickName = inputUtil.pick_Input_Counts(user.userData.strNickName, 6)
			_textN:setString(strNickName)
			_textN:setVisible(true)
			local _ok = _userC:getChildByName("ImageOK")
			if user.gameData.userStatus == wnet.EUserStatus.EGAME_STATUS_READY then
				_ok:setVisible(true)
			else
				_ok:setVisible(false)
			end

			if user.gameData.userStatus == wnet.EUserStatus.EGAME_STATUS_GAMEING or 
					user.gameData.userStatus == wnet.EUserStatus.EGAME_STATUS_BOKEN then
				--table:getChildByName("ImageTable"):getChildByName("ImageSai"):show()
				imgTable:getChildByName("ImageVS_ready"):hide()
				imgTable:getChildByName("ImageVS_go"):show()
				_ok:setVisible(false)
			else
				imgTable:getChildByName("ImageVS_ready"):show()
				imgTable:getChildByName("ImageVS_go"):hide()
			end
			_userC.bHaveUser = true--waproom
			

			local _ava = _userC:getChildByName("ImageAvatar")
			local _icon = user.userData.icon
			if _icon > 10 then
				_icon = 0
			end
			local fn = "avatar/" .. _icon .. ".jpg"
			_ava:setVisible(true)
			_ava:loadTexture(fn, ccui.TextureResType.localType)

		else
			imgTable.userCount = imgTable.userCount - 1
			local _userC = imgTable:getChildByName("ImageSeat" .. (chairid + 1))
			local _textN = _userC:getChildByName("TextName")
			_textN:setString("")
			_textN:setVisible(false)
			local _ok = _userC:getChildByName("ImageOK")
			_ok:setVisible(false)
			local _ava = _userC:getChildByName("ImageAvatar")
			_ava:setVisible(false)

			_userC.bHaveUser = false--waproom
		end
		self:dealTableImageVS(imgTable)

		if self.bWapRoom then
			self:dealWapRoomChair(imgTable) --waproom
		end

	else
		print("changeSeatUI " .. tableid .. " " .. chairid)
	end
end

function RoomScene:fillTableUser()
	if cc.dataMgr.userList and cc.dataMgr.userList.userList then
		local userCount = #cc.dataMgr.userList.userList - 1
		self.tableUserEnd = userCount
		for i = self.tableUserStart, self.tableUserEnd, 1 do
			local v = cc.dataMgr.userList.userList[i + 1]
			--建立user table
			if v.gameData.userStatus ~= 6  then
				cc.dataMgr.userTable[v.userData.userID] = v
				self:changeSeatUI(v, v.gameData.tableID, v.gameData.chairID, false)
			end
		end
		self.tableUserStart = self.tableUserEnd
	end
end

function RoomScene:onGC_ROOM_USERLIST_P(event)
	
end

function RoomScene:onGC_TABLE_STATSLIST_P(event)

	if not cc.dataMgr.isBroken then
		self:fillTableUser()
		
		print("self.bCanClick")
	end
	--self:stopAllActions()
	--[[
	local flag = false
	local function resume()
		if self.tablesInited and not flag then
			flag = true
			self:fillTableUser()
			self:stopAllActions()
		end
	end

	local _a = cc.Sequence:create(cc.DelayTime:create(0.05), cc.CallFunc:create(resume))
	local _rep = cc.RepeatForever:create(_a)]]
	--self:runAction(_rep)
end

local function showImgLock(imgTable)
	local imgLock = imgTable:getChildByName("locak")

	if imgLock == nil then
		imgLock = ccui.ImageView:create("wrapRoom/res/lock.png")
		imgLock:setName("locak")
		imgLock:setPosition(cc.p(imgLock:getContentSize().width / 2, imgLock:getContentSize().height / 2))
		imgTable:addChild(imgLock)
	end

	imgLock:show()
end

local function hideImgLock(imgTable)
	local imgLock = imgTable:getChildByName("locak")

	if imgLock then
		imgLock:hide()
	end
end

function RoomScene:updateImgLock(imgTable)
	local tableId = imgTable.index
	print("tableId = " ..tableId)
	print("cc.dataMgr.tableStatusList[tableId] = " ..cc.dataMgr.tableStatusList[tableId])
	if cc.dataMgr.tableStatusList[tableId] then
		if cc.dataMgr.tableStatusList[tableId] == 2 or cc.dataMgr.tableStatusList[tableId] == 4 then
			showImgLock(imgTable)
		else
			hideImgLock(imgTable)
		end
	end
end

function RoomScene:onGC_TABLE_STATUS_UP_P(event)
	local tableId = event.data.tableID + 1
	local layTable = cc.dataMgr.tables[tableId]
	if layTable == nil then
		return
	end
	local imgTable = layTable:getChildByName("ImageTable")

	local imgReady = imgTable:getChildByName("ImageVS_ready"):hide()
	local imgGo = imgTable:getChildByName("ImageVS_go"):hide()

	local status = event.data.status
	if status == 1 or status == 2 then
		imgReady:show()
	elseif status == 3 or status == 4 then
		imgGo:show()
	end

	if self.bWapRoom then
		self:updateImgLock(imgTable)
	end

end

function RoomScene:onGC_ENTERTABLE_P(event)
	--already exist in userlist?
	local v = cc.dataMgr.userTable[event.data.gameUser.userData.userID]
	if v == nil then
		cc.dataMgr.userTable[event.data.gameUser.userData.userID] = event.data.gameUser
		--table.insert(cc.dataMgr.userList.userList, event.data.gameUser)
	else
		cc.dataMgr.userTable[event.data.gameUser.userData.userID] = table.deepcopy(event.data.gameUser)
	end
	self:changeSeatUI(event.data.gameUser, event.data.tableID, event.data.chairID, false)

	-- 自定义底注桌子标识
	if event.data.setBet then
		if app.castMultSet and event.data.setBet>0 then
			app.castMultSet:addTableSign(event.data.tableID + 1,event.data.setBet)
		end
	end
end

function RoomScene:onGC_LEAVETABLE_P(event)
	--already exist in userlist?
	local v = cc.dataMgr.userTable[event.data.userID]
	if v == nil then
		print("onGC_LEAVETABLE_P error " .. event.data.userID)
	else
		print("onGC_LEAVETABLE_P "..v.gameData.tableID.." " .. v.gameData.chairID)
		cc.dataMgr.userTable[event.data.userID] = nil
		self:changeSeatUI(v, v.gameData.tableID, v.gameData.chairID, true)
	end
end

function RoomScene:onGC_GAMEUSER_UP_P(event)

end

function RoomScene:onGC_ENTERTABLE_ACK_P(event)
	cc.hideLoading()
	local ret = event.data.result
	if ret == wnet.EnterTable_Result.EnterTable_OK then
		app.sceneSwitcher:enterScene("GameScene")
		cc.dataMgr.isWatcher = false
	elseif ret == wnet.EnterTable_Result.EnterTable_OB then
		cc.dataMgr.isWatcher = true
		app.sceneSwitcher:enterScene("GameScene")
		--app.toast.show("手机玩家不支持旁观")
	elseif ret == wnet.EnterTable_Result.EnterTable_BeOccupyeed then
		app.toast.show("The position has been to sit")
	elseif ret == wnet.EnterTable_Result.EnterTable_MoneyLimit then
		app.toast.show("Don't have enough chips")
	elseif ret == wnet.EnterTable_Result.EnterTable_WrongPasswd then
		app.toast.show("Password wrong")
	elseif ret == wnet.EnterTable_Result.EnterTable_ForbidMinWin then
		app.toast.show("min win")
	elseif ret == wnet.EnterTable_Result.EnterTable_ForbidMaxDisc then
		app.toast.show("max disc")
	elseif ret == wnet.EnterTable_Result.EnterTable_ForbidMaxDelay then
		app.toast.show("max delay")
	elseif ret == wnet.EnterTable_Result.EnterTable_ForbidMinScore then
		app.toast.show("min score")
	elseif ret == wnet.EnterTable_Result.EnterTable_ForbidIp then
		app.toast.show("same ip")
	elseif ret == wnet.EnterTable_Result.EnterTable_GameFix then
		app.toast.show("Game fixing")
	elseif ret == wnet.EnterTable_Result.EnterTable_Busy then
		app.toast.show("System busy")
	elseif ret == wnet.EnterTable_Result.EnterTable_GainOver then
		app.toast.show("Gain over today")
	elseif ret == wnet.EnterTable_Result.EnterTable_NoTrail then
		app.toast.show("Trail player")
	elseif ret == wnet.EnterTable_Result.EnterTable_Gaming then
		app.toast.show("Gameing is on air")
	elseif ret == wnet.EnterTable_Result.EnterTable_WatchNumLimit then
		app.toast.show("Mobile player not watch")
	elseif ret == wnet.EnterTable_Result.EnterTable_ScoreLimit then
		app.toast.show("Don't have enough score")
	elseif ret == wnet.EnterTable_Result.EnterTalbe_ForbidSetCustomMinScore then
		if event.data.minGameCurrency then
			app.toast.show("Chips limit to" ..event.data.minGameCurrency .."so enter failed!")
		end
	elseif ret == wnet.EnterTable_Result.EnterTable_RoomExists then
		app.toast.show("Room exist")
	end

	if ret ~= wnet.EnterTable_Result.EnterTable_OK and ret ~= wnet.EnterTable_Result.EnterTable_OB then
		cc.dataMgr.selectedTableID = -1
	end
end

--- 设置底注消息，初始化设置底注模块
function RoomScene:onGC_GETBETSETINFO_ACK_P(event)
	app.castMultSet = require("hall/src/hall/view/CastMultipleSet.lua").new()
	app.castMultSet:init(self:getResourceNode(),event.data,true)
	self:getResourceNode():addChild(app.castMultSet)
end

function RoomScene:onGC_TABLESETBET_INFO_ACK_P(event)
	if app.castMultSet == nil then
		return
	end
	for i=1,#(event.data.tableSetBetInfoList) do
		if cc.dataMgr.tables[event.data.tableSetBetInfoList[i].tableId + 1]~=nil then
			app.castMultSet:addTableSign(event.data.tableSetBetInfoList[i].tableId + 1,event.data.tableSetBetInfoList[i].nBet)
		end
	end
end

function RoomScene:onGC_NOCHEAT_MATCH_INFO_ACK_P(event)
	if (cc.dataMgr.randMatch.matchInfo.matchType==1) or (cc.dataMgr.randMatch.matchInfo.matchType==2) then
		cc.dataMgr.withoutRoomScene = true
		cc.dataMgr.useRandMatch = true
		app.sceneSwitcher:enterScene("GameScene")
	end
end

-- 返回是否显示设置底注信息	 0 显示 1 不显示
function RoomScene:onGC_GETSHOWSETBETINFO_ACK_P(event)
	print"RoomScene:onGC_GETSHOWSETBETINFO_ACK_P"
	app.holdOn.hide()
	local data = event.data
	if data.nResult == 0 then
		app.setBetLayerDZPK = require("dzpk.src.SetBetLayer").new()
		app.setBetLayerDZPK:createSetBetLayer(self:getResourceNode())
		app.setBetLayerDZPK:showSetBetUI()
		app.setBetLayerDZPK:setSeatInfo(data.tableId, data.chairId)
	elseif data.nResult == 1 then
		local table = cc.dataMgr.tables[data.tableId + 1]
		local bHave = false
		if table ~= nil then
			if table.userList ~= nil then
				for i,v in pairs(table.userList) do
					if v ~= nil then
						bHave = true
						break
					end
				end
			else
				bHave = false
			end
			if not bHave and cc.dataMgr.castMultSet and cc.dataMgr.castMultSet.beiShuInfo
					and (cc.dataMgr.castMultSet.beiShuInfo.gameCurrencyLimit ~= nil or cc.dataMgr.castMultSet.beiShuInfo.gameCurrencyLimit ~= 0) then
				cc.dataMgr.tableBetInfoInRoom[data.tableId + 1] = cc.dataMgr.castMultSet.beiShuInfo.nBet
			end
		end

		if cc.dataMgr.playingGame == "dzpk" and cc.dataMgr.tableBetInfoInRoom[data.tableId + 1] == nil then
			--print"点击了一下座位，底注消息还未接受"
		else
			cc.showLoading("Waiting for enter table")
			cc.lobbyController:sendLoginTableReq(data.tableId, data.chairId)
		end
	end
end

function RoomScene:registerKey()
	local keyListener = cc.EventListenerKeyboard:create()
	local function onKeyRelease(code, event)

		print("EVENT_KEYBOARD_PRESSED, code:"..code)
		if code == cc.KeyCode.KEY_BACK or code == cc.KeyCode.KEY_BACKSPACE then
			if app.holdOn.holdOnLayer ~= nil then
				--app.holdOn:hide()
			elseif app.msgBox.root ~= nil then
				app.msgBox.hide()
			elseif self.nPopLayers > 0 then
				if self.taskLayer ~= nil then
					local imgbg = self.taskLayer:getChildByName("Image_taskbg"):show()
					imgbg.userdata:hide()
					imgbg:hide()
				end
				if self.settinglayer ~= nil then
					self.settinglayer:setVisible(false)
				end
				self.nPopLayers = 0
			else
				if not cc.sceneTransFini then return end
				if app.runningScene.name ~= "RoomScene" then return end
				cc.dataMgr.isRoomBackToHall = true
				cc.msgHandler:disconnectFromGame()
				app.sceneSwitcher:enterScene("HallScene")
				self.isBackToHallScene = true
		
			end
		elseif code == cc.KeyCode.KEY_F1 then
			local data = {}
			data.nResult = 0
			data.dayGetTimes = 3
			data.getTimes = 1
			data.dayGetCurrency = 1000
			data.showGetCurrencyOne = 1800
			data.showGetCurrencyTwo = 3000
			cc.dataMgr.baseLivingData = data
			app.baseLivingProtocol:dispatchEvent({ name = "GC_GETBASELIVEING_ACK_P", data = data })
		end
	end
	keyListener:registerScriptHandler(onKeyRelease, cc.Handler.EVENT_KEYBOARD_RELEASED)
	local eventDispatch = self:getEventDispatcher()
	eventDispatch:addEventListenerWithSceneGraphPriority(keyListener, self)
end

return RoomScene
