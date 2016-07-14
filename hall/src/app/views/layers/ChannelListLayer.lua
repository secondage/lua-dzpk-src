--
-- Author: ChenShao
-- Date: 2015-08-20 15:24:55
--
local ChannelListLayer = class("ChannelListLayer")

local channelRes = {
	["gaofen"]  = "hall_gaofen.png",
	["gaoshou"] = "hall_gaoshou.png",
	["jifen"]   = "hall_jifen.png",
	["ziyou"]   = "hall_ziyou.png",
	["anyao"]   = "hall_anyao.png",
	["mingyao"]   = "hall_mingyao.png"
}

local channelRes_ = {
	["matchroom"]  = "matchroom.png",
	["fastroom"]  = "fastroom.png",
	["moneyroom"] = "moneyroom.png",
	["scoreroom"]   = "scoreroom.png",
	["wraproom"]   = "wraproom.png",
	["challengeroom"]   = "challengeroom.png",
	["roundroom"]   = "roundroom.png",
	["weekroom"]   = "weekroom.png",
	["anyaoroom"]   = "hall_anyao.png",
	["mingyaoroom"]   = "hall_mingyao.png",
}

local channelBtn = {
	["gaofen"]  = { "hall_gaofen_btn1.png", "hall_gaofen_btn2.png"},
	["gaoshou"] = { "hall_gaoshou_btn1.png", "hall_gaoshou_btn2.png"},
	["jifen"]   = {"hall_jifen_btn1.png", "hall_jifen_btn2.png"},
	["ziyou"]   = {"hall_ziyou_btn1.png", "hall_ziyou_btn2.png"},
	["anyao"]   = {"hall_jifen_btn1.png", "hall_jifen_btn2.png"},
	["mingyao"]   = {"hall_ziyou_btn1.png", "hall_ziyou_btn2.png"}
}
--[[
local roomState = {
	["lianghao"] = "hall_lianghao.png",
	["yongji"] 	 = "hall_yongji.png",
	["huobao"]   = "hall_huobao.png"
}]]

local CALC_A = 0.8
local MENU_SCALE = 0.3
local ITEM_Opacity = 0.8
local ANIMATION_DURATION = 0.2
local ITEM_SIZE_SCALE = 1 / 4

local _index = 0
local _lastIndex = 0
local _selectedItem = nil
local _menuLayerSize = {}
local _roomItems = {}
local _menuLayer = nil

local function reset()
	_index = 0
	_lastIndex = 0
	_selectedItem = nil
	_menuLayerSize = {}
	_roomItems = {}
	_menuLayer = nil
end

local function abs(num)
	return math.abs(num)
end

local function setIndex(index)
	_lastIndex = _index  
    _index = index  
end

local function calcOpacity(index, scale)
	return (scale * index / (abs(index) + 1.5)) * (scale * index / (abs(index) + 1.5)) * (scale * index / (abs(index) + 1.5))
end

local function calcFunction(index, scale)
	return scale * index / (abs(index) + CALC_A) 
end

local function getCurrentItem()
	if #_roomItems == 0  then
        return nil
    end
    return _roomItems[_index + 1]
end


local function updatePosition(self)

	for i = 1, #_roomItems do
		local item = _roomItems[i]
		local k = i - 1
		local x = calcFunction(k - _index, _menuLayerSize.width / 2)
		item:setPosition(cc.p(_menuLayerSize.width / 2 + x, _menuLayerSize.height / 2))
		item:setLocalZOrder(-abs((k - _index)))
		item:setScale(1 - abs(calcFunction(k - _index, MENU_SCALE)))
		item:setOpacity(255 * (1 - abs(calcOpacity(k - _index, ITEM_Opacity))))
				
		if x == 0 then
			item:getChildByName("Panel_mark"):hide()
		end
	end
end

local _actionEndCallBack = nil
local scheduler = require("framework.scheduler")
local function updatePositionWithAnimation()
	_menuLayer.userdata = {touchEnable = false}
	for _, item in pairs(_roomItems) do
		item:stopAllActions()
		item:getChildByName("Panel_mark"):show()
	end

	for i = 1, #_roomItems do
		local item = _roomItems[i]
		local lastItem = _roomItems[i - 1]
		local nextItem = _roomItems[i + 1]
		local k = i - 1
		item:setLocalZOrder(-abs((k - _index)))
		local x = calcFunction(k - _index, _menuLayerSize.width / 2)
		local moveTo = cc.MoveTo:create(ANIMATION_DURATION, cc.p(_menuLayerSize.width / 2 + x, _menuLayerSize.height / 2))
		item:runAction(moveTo)
		local scaleTo = cc.ScaleTo:create(ANIMATION_DURATION, (1 - abs(calcFunction(k - _index, MENU_SCALE)))) 
		item:runAction(scaleTo)
		local fadeTo = cc.FadeTo:create(ANIMATION_DURATION, 255 * (1 - abs(calcOpacity(k - _index, ITEM_Opacity))))
		item:runAction(fadeTo)

		if x == 0 then
			item:getChildByName("Panel_mark"):hide()
		end
	end



	local function actionEndCallBack()
		_menuLayer.userdata = {touchEnable = true}

	end
	if _actionEndCallBack then
		scheduler.unscheduleGlobal(_actionEndCallBack)
	end
	_actionEndCallBack = scheduler.performWithDelayGlobal(actionEndCallBack, ANIMATION_DURATION)
end

local function getChannelRes(v)
	if string.find(v.gameInfo.chanelName, "高分", 1) then
		--print("---高分")
		return channelRes["gaofen"], channelBtn["gaofen"] 
	elseif string.find(v.gameInfo.chanelName, "高手", 1) then
	--	print("---高手")
		return channelRes["gaoshou"], channelBtn["gaoshou"] 
	elseif string.find(v.gameInfo.chanelName, "积分", 1) then
		--print("---积分")
		return channelRes["jifen"], channelBtn["jifen"] 
	elseif string.find(v.gameInfo.chanelName, "暗幺", 1) then
		return channelRes["anyao"], channelBtn["anyao"] 
	elseif string.find(v.gameInfo.chanelName, "明幺", 1) then
		return channelRes["mingyao"], channelBtn["mingyao"] 
	else
		--print("---自由")
		return channelRes["ziyou"], channelBtn["ziyou"] 
	end
end

local function getChannelRes_(chanelName)


	return channelRes_["matchroom"]
	--[[
	if string.find(chanelName, "匹配", 1) then
		return channelRes_["matchroom"]
	elseif string.find(chanelName, "包房", 1) then
		return channelRes_["wraproom"]
	elseif string.find(chanelName, "快速", 1) then
		return channelRes_["fastroom"]
	elseif string.find(chanelName, "游戏豆", 1) then
		return channelRes_["moneyroom"]
	elseif string.find(chanelName, "积分", 1) then
		return channelRes_["scoreroom"]
	elseif string.find(chanelName, "挑战", 1) then
		return channelRes_["challengeroom"]
	elseif string.find(chanelName, "周赛", 1) then
		return channelRes_["moneyroom"]
	elseif string.find(chanelName, "循环", 1) then
		return channelRes_["roundroom"]
	elseif string.find(chanelName, "暗幺", 1) then
		return channelRes_["anyaoroom"]
	elseif string.find(chanelName, "明幺", 1) then
		return channelRes_["mingyaoroom"]
	else
		return channelRes_["matchroom"]
	end
	]]
end

local function getRoomStateRes(online)
	if online < 100 then
		return roomState["lianghao"]
	elseif online < 200 then
		return roomState["yongji"]
	else
		return roomState["huobao"]
	end
end

local function createRooms(self, channelProtopyte, data)
	if cc.dataMgr.gameList == nil then 
		return {} 
	end

	--local roomListView = channelProtopyte:getChildByName("ListView_room")
	--roomListView:setItemsMargin(20)
	--local btnRoom = channelProtopyte:getChildByName("Image_channel"):hide()

	local channelItems = {}


	--dump(cc.dataMgr.gameList.vecGameInfo)
	for i = 0, #cc.dataMgr.gameList.vecGameInfo - 1 do
		local v = cc.dataMgr.gameList.vecGameInfo[i + 1]
		local channelClone = channelProtopyte:clone()
		channelClone:setCascadeOpacityEnabled(true)
		channelClone:setTouchEnabled(true)

		print("v.gameInfo.chanelName = " ..v.gameInfo.chanelName)
		local channelRes = getChannelRes_(v.gameInfo.chanelName)
		print("channelRes = " ..channelRes)
		channelClone:loadTexture(channelRes)

		--dump(v)
		local vr = v.rmInfo
		print("vr = " ..#vr)
		--if #vr == 1 then 
			local rmInfo = vr[1]
			local onlineCount = rmInfo.userNum
			local atlasOnlineCount = channelClone:getChildByName("AtlasLabel_zaixianrenshu")
			atlasOnlineCount:setString(tostring(onlineCount))

			local atlasDifen = channelClone:getChildByName("AtlasLabel_difen")
			atlasDifen:setString(tostring(v.gameInfo.moneyLimit.l))
			
			channelItems[#channelItems + 1] = channelClone

			channelClone.userdata = vr
			local layTouch = channelClone:getChildByName("Panel_touch")
			layTouch:addTouchEventListener(function(object, type)
				if type == 2 then

					print("<========")
					app.audioPlayer:playClickBtnEffect()
					
					local v = cc.dataMgr.gameList.vecGameInfo[i + 1]
					cc.dataMgr.moneyLimit = v.gameInfo.moneyLimit.l

					cc.dataMgr.selectedGameInfo = table.deepcopy(v.gameInfo)
					cc.dataMgr.selectedGameSrv = table.deepcopy(v.svrInfo)
					cc.dataMgr.selectedGameRoom = table.deepcopy(object.userdata)
					cc.dataMgr.selectRoomID = 0
					cc.dataMgr.maxTableCount = v.gameInfo.tableNum
					cc.dataMgr.tablePlyNum = v.gameInfo.tablePlyNum
					cc.dataMgr.gameName = v.gameInfo.gameName
					cc.dataMgr.selectGameType = v.gameInfo.gameType
					print("selectGameTypes = " ..cc.dataMgr.selectGameType)
				
					cc.dataMgr.selectedGameInfo.onLineNum = vr.userNum

					cc.dataMgr.selectRoonName = v.gameInfo.chanelName

					app.holdOn.show("Waiting for room info...")
					cc.msgHandler:connectToGame(v.svrInfo.srvIP, v.svrInfo.srvPort)
	
				end
			end)
		--end
	end

	--[[
	for i = 0, #cc.dataMgr.gameList.vecGameInfo - 1 do
		local v = cc.dataMgr.gameList.vecGameInfo[i + 1]
		local channelClone = channelProtopyte:clone()
		channelClone:setCascadeOpacityEnabled(true)

		--加载场次资源
		local channelRes, channelBtn = getChannelRes(v)
		channelClone:loadTexture(channelRes, 1)
		btnRoom:loadTextures(channelBtn[1], channelBtn[2], "", 1)
		
		local onlineCount = 0
		--

		local roomListViewClone = channelClone:getChildByName("ListView_room")

		channelItems[#channelItems + 1] = channelClone
		for ir = 0, #v.rmInfo - 1 do
			local vr = v.rmInfo[ir + 1]
			local btnRoomClone = btnRoom:clone():show()
			btnRoomClone:setCascadeOpacityEnabled(true)
			local mutiply = UTF82Mutiple(vr.szRoomName)
			print("mutiply_size = " ..string.len(mutiply))
			if string.len(mutiply) >= 14 then
				btnRoomClone:setTitleFontSize(btnRoomClone:getTitleFontSize() * 0.6)
			elseif string.len(mutiply) >= 10 then
				btnRoomClone:setTitleFontSize(btnRoomClone:getTitleFontSize() * 0.8)
			end
			btnRoomClone:setTitleText(vr.szRoomName)
			roomListViewClone:pushBackCustomItem(btnRoomClone)
			btnRoomClone.userdata = vr
			onlineCount = onlineCount + vr.userNum

			local imgRoomState = btnRoomClone:getChildByName("Image_state")

			imgRoomState:loadTexture(getRoomStateRes(vr.userNum), 1)

			btnRoomClone:addTouchEventListener(function(object, type)
				if type == 2 then
					app.audioPlayer:playClickBtnEffect()
					
					local v = cc.dataMgr.gameList.vecGameInfo[i + 1]

					cc.dataMgr.selectedGameInfo = table.deepcopy(v.gameInfo)
					cc.dataMgr.selectedGameSrv = table.deepcopy(v.svrInfo)
					cc.dataMgr.selectedGameRoom = table.deepcopy(object.userdata)
					cc.dataMgr.selectRoomID = cc.dataMgr.selectedGameRoom.roomID
					cc.dataMgr.maxTableCount = v.gameInfo.tableNum
					cc.dataMgr.tablePlyNum = v.gameInfo.tablePlyNum
					cc.dataMgr.gameName = v.gameInfo.gameName
					cc.dataMgr.selectGameType = v.gameInfo.gameType
					print("selectGameTypes = " ..cc.dataMgr.selectGameType)
					cc.dataMgr.moneyLimit = v.gameInfo.moneyLimit.l

					cc.dataMgr.selectedGameInfo.onLineNum = vr.userNum
					--dump(cc.dataMgr.selectedGameInfo)
					--print("c.dataMgr.gameName = " ..cc.dataMgr.gameName)
		
					print("v.gameInfo.tablePlyNum = " ..v.gameInfo.tablePlyNum)
					print(v.svrInfo.srvIP)
					print(object.userdata.szRoomName)
					cc.dataMgr.selectRoonName = object.userdata.szRoomName

					app.holdOn.show("正在获取房间内信息...")
					cc.msgHandler:connectToGame(v.svrInfo.srvIP, v.svrInfo.srvPort)
				end
			end)
		end

		local fontOnline = channelClone:getChildByName("BitmapFontLabel_online")
		fontOnline:setString(tostring(onlineCount))

		local fontDifen = channelClone:getChildByName("BitmapFontLabel_1")
		fontDifen:setString(tostring(i64_toInt(v.gameInfo.moneyLimit)))
	end
	]]

	return channelItems
end


local function procUI(self)
	local btnExit = self.channelListLayer:getChildByName("Button_btnExit")
	btnExit:setPressedActionEnabled(true)
	btnExit:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			cc.dataMgr.withoutRoomScene = false			-- 是否跳过roomScene 的参数还原
			app.hallScene:backToGameListLayer()
			self.channelListLayer:removeChildByTag(100)
			self.channelListLayer:removeFromParent()
			app.hallScene.channelListLayer = nil
		end
	end)
end

function ChannelListLayer:createMenuLayer()
	print("ChannelListLayer:createMenuLayer")
	local menuLayer = display.newLayer():addTo(self.channelListLayer)
	menuLayer:setTag(100)
	_menuLayer = menuLayer
	_menuLayerSize = {width = display.width, height = display.height * 0.8}
	menuLayer:setContentSize(cc.size(_menuLayerSize.width, _menuLayerSize.height))
	menuLayer:setAnchorPoint(cc.p(0.5, 0.5))
	menuLayer:ignoreAnchorPointForPosition(false)
	menuLayer:setPosition(display.cx, display.cy)

	local touchLayer = display.newLayer():addTo(self.channelListLayer)
	touchLayer:setContentSize(cc.size(_menuLayerSize.width, _menuLayerSize.height))
	touchLayer:setAnchorPoint(cc.p(0.5, 0.5))
	touchLayer:ignoreAnchorPointForPosition(false)
	touchLayer:setPosition(display.cx, display.cy)
	
	local channelProtopyte = self.channelListLayer:getChildByName("Image_channel"):hide()
	self.channelProtopyteSize = channelProtopyte:getContentSize()

	local function onTouchBegan(touch, event)
		if _menuLayer.userdata and _menuLayer.userdata.touchEnable == false then return false end
		if not self.channelListLayer:isVisible() then return false end

		for _, item in pairs(_roomItems) do
			item:stopAllActions()
		end

       if cc.rectContainsPoint(_menuLayer:getBoundingBox(), cc.p(touch:getLocation().x, touch:getLocation().y)) then
       		return true
       	end

       	return false
	end

	local function onTouchMoved(touch, event)
		local xDelta = touch:getDelta().x
		_lastIndex = _index
		_index = _index - xDelta / (_menuLayerSize.width * ITEM_SIZE_SCALE)
		updatePosition(self)


		self.isDrag = true

	end

	local function onTouchEnded(touch, event)
		print("onTouchEnded")

		local touchLocation = touch:getLocation()
		local xDelta = touch:getLocation().x - touch:getStartLocation().x
		
		--[[if math.abs(xDelta) < 100 then
			if touchLocation.x > (_menuLayerSize.width / 2 + self.channelProtopyteSize.width / 2) then
				_index = _index + 1
				if _index >= #_roomItems - 1 then
        			_index = #_roomItems - 1
        		end
        		updatePositionWithAnimation()
        		return
        	elseif touchLocation.x < (_menuLayerSize.width / 2 - self.channelProtopyteSize.width / 2) then
         		_index = _index - 1
        		if _index <= 0 then
        			_index = 0
        		end
        		print("_index = " .._index)
        		updatePositionWithAnimation()
        		return
        	end     	
		end
]]
		local function rectify(forward)
			local index = _index
			if index <= 0 then
        		index = 0
        	elseif index >= #_roomItems - 1 then
        		index = #_roomItems - 1
        	end
			
    		index = math.modf(index + (forward and 0.4 or 0.6))
    		setIndex(math.modf(index))
		end

		rectify((xDelta > 0) or false)
		print("_index = " .._index)
        updatePositionWithAnimation()
	end

	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED )
	listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED )
	local eventDispatcher = menuLayer:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, touchLayer)
end

function ChannelListLayer:createLayer()
	self.channelListLayer = cc.CSLoader:createNode("Layers/ChannelListLayer.csb")
	self.isDrag = false
	procUI(self)
	return self.channelListLayer
end

function ChannelListLayer:updateRoomList()
	reset()
	self:createMenuLayer()

	local channelProtopyte = self.channelListLayer:getChildByName("Image_channel"):hide()
	
	self.channelProtopyteSize = channelProtopyte:getContentSize()
	_roomItems = createRooms(self, channelProtopyte)
	for i = 1, #_roomItems do
		local item = _roomItems[i]:show()
		_menuLayer:addChild(item)
	end
	updatePosition(self)
end

return ChannelListLayer