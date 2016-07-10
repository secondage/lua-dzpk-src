--
-- Author: ChenShao
-- Date: 2015-08-17 17:26:36
--
local GameListLayer = class("GameListLayer")
local httpUtils = require("app.func.HttpUtils")
local json = require("framework.json")
local _gamedb = require("app.func.GameDB")
local scheduler = require("framework.scheduler")

local function createPaintAnimation(self, name, num)

	if not app.bLoadPaint then
		app.bLoadPaint = true
		display.loadSpriteFrames("publicui/paintAnimation.plist", "publicui/paintAnimation.png")
	end

	local frames = display.newFrames(name.. "%d.png", 1, num, false)
	local animation, firstFrame = display.newAnimation(frames, 2 / num)
	display.setAnimationCache(name .."Animation", animation)
	return firstFrame
end

local function playPaintAnimation(self, pos)
	self.paintFirstFrame:pos(cc.p(pos.x, pos.y + 10))
			:playAnimationForever(display.getAnimationCache("paintAnimation"))
end

local function readHotFromServer(self, gamename)
	
	local versionUrl = urls.minigameHot ..gamename .."_hot.json"
	print("versionUrl = " ..versionUrl)
	httpUtils.reqHttp(versionUrl, function(ret, response)	
		--app.holdOn.hide()
		if ret then
			app.isHotChecked = true
			print("<readHotFromServer---response = " ..response)
			local info = json.decode(response)
			if info and checktable(info) then
				if info.hot == 1 then
					self:showPaint(gamename)
					app.hot[gamename] = 1 
				end
			end
		else
			print("server no " ..gamename .."_hot.json")
		end
	end)
end

local function procLayRoof(self)
	self.layRoof = self.gameListlayer:getChildByName("Panel_roof")
	self.layRoof:hide()

	self.layRoof:addTouchEventListener(function(obj, type)
		if type == 2 then
			self.layRoof:hide()
			self:hideAllDeleteBtns()
		end
	end)
end

function GameListLayer:createLayer()
	self.gameListlayer = cc.CSLoader:createNode("Layers/GameListLayer.csb")

	self.tblDeleteBtns = {}
	self.tblGames = {}

	app.isCheckedUpdate = app.isCheckedUpdate or {}
	app.isHotChecked = app.isHotChecked or false
	app.hot = app.hot or {}

	self.layDownload = nil
	self.node_rooms = nil
    self.lvRooms = nil
    self.btnProtopyte = nil
    self.channelItem = {}

    self.insertIndex = 0
	self:updateGameListUI()

	self.gameAddLayer = nil  

	
	procLayRoof(self)
	
	self.isEdit = false

	return self.gameListlayer
end

function GameListLayer:updateUI()

end

function GameListLayer:downLoadingUI(gamename, onResult, strZipUrl)
	local layDownloadCtrller = require("app.views.layers.DownLoadLayer").new()
	self.layDownload = layDownloadCtrller:createLayer(2):addTo(self.gameListlayer, 100)


	layDownloadCtrller:startDownload(gamename, onResult, strZipUrl)
end

function GameListLayer:showPaint(gameName)
	local btn = self.channelItem[gameName]

	if btn and btn:getChildByTag(100) == nil then
		self.paintFirstFrame = createPaintAnimation(self, "paint", 20)
		playPaintAnimation(self, {x = btn:getContentSize().width / 2, y = btn:getContentSize().height / 2})
		self.paintFirstFrame:addTo(btn):show()
		self.paintFirstFrame:setTag(100)
	end
end

local function showSingleGame(self, gameID, gameName, index, gameName_ZH)
	local btn = self.btnProtopyte:clone():show() 
	self.channelItem[gameName] = btn
	
	self.lvRooms:insertCustomItem(btn, index)
	self.insertIndex = self.insertIndex + 1
	local imgIcon = btn:getChildByName("Image_gameName"):getChildByName("Image_iconName")

	local personIconName = gameName .."/res/iconname.png"
	if cc.FileUtils:getInstance():isFileExist(personIconName) then
		imgIcon:loadTexture(personIconName)
	else
		imgIcon:loadTexture("games/" ..gameName .."_iconname.png")
	end
	imgIcon:hide()

	imgIcon:ignoreContentAdaptWithSize(true)
	btn.userdata = {gameID = gameID, gameName = gameName}
	btn:setName(gameName)
	btn:addTouchEventListener(handler(self, GameListLayer.onBtnEvt))

	local imgDecorate = btn:getChildByName("Image_decorate")
	imgDecorate:ignoreContentAdaptWithSize(true)

	local personDecorate = gameName .."/res/decorate.png"
	if cc.FileUtils:getInstance():isFileExist(personDecorate) then
		imgDecorate:loadTexture(personDecorate)
	else
		if g_isMahj(gameName) then
			imgDecorate:loadTexture("games/mj_decorate.png")
		else
			if cc.FileUtils:getInstance():isFileExist("games/" ..gameName .."_decorate.png") then
				imgDecorate:loadTexture("games/" ..gameName .."_decorate.png")
			else
				imgDecorate:loadTexture("games/threeone_decorate.png")
			end
		end
	end

	local btnDelete = btn:getChildByName("Button_btnDelete")
	btnDelete:setPressedActionEnabled(true)
	btnDelete:hide()
	btnDelete.gameId = gameID
	btnDelete.gameName = gameName
	btnDelete:addTouchEventListener(handler(self, GameListLayer.onBtnDeleteEvt))
	self.tblDeleteBtns[#self.tblDeleteBtns + 1] = btnDelete

	if not app.isHotChecked then
		readHotFromServer(self, gameName)
	else
		for name, _ in pairs(app.hot) do
    		self:showPaint(name)
    	end
	end	
end

function GameListLayer:showAllDeleteBtns()
	
	for _, gameName in pairs(self.tblGames) do
		local btn = self.lvRooms:getChildByName(gameName)
		if btn then
			btn:getChildByName("Button_btnDelete"):show()
			self:shockAction(btn)
		end
	end

	self.isEdit = true
end

function GameListLayer:hideAllDeleteBtns()

	for _, gameName in pairs(self.tblGames) do
		local btn = self.lvRooms:getChildByName(gameName)
		if btn then
			btn:getChildByName("Button_btnDelete"):hide()
			btn:stopAllActions()
			btn:setRotation(0)
		end
	end

	self.isEdit = false

end

function GameListLayer:getLocalGameVersion()
	return tonumber(cc.UserDefault:getInstance():getStringForKey(cc.dataMgr.playingGame .."_version", "1"))
end

function GameListLayer:getServerGameVerion()
	app.holdOn.show("正在检测游戏最新信息...")
	httpUtils.reqHttp(urls.minigameDownloadurl ..cc.dataMgr.playingGame .."_version", function(ret, response)
		app.holdOn.hide()
		if ret then
			print("server game version = " ..response)
			return tonumber(response)
		else
			return 0
		end
	end)
end

function GameListLayer:downloadMahjRes(gameName)
	if g_isMahj(gameName) then
		local function onResult(ret)--回调
			print("<--------onResult = " ..ret)
			if ret == 0 then --成功
				--app.toast.show("下载成功")	
				self.layDownload:hide()
				--app.isCheckedUpdate[cc.dataMgr.playingGame] = true 

				coroutine.resume(self.co)
			elseif ret == 1 then
				print("<--- 不需要更新")
				
				self.layDownload:hide()
				--app.isCheckedUpdate[cc.dataMgr.playingGame] = true 

				coroutine.resume(self.co)
			elseif ret == 2 then
				app.toast.show("网络错误")
			elseif ret == 3 then
				--app.isCheckedUpdate[cc.dataMgr.playingGame] = true 
				self.layDownload:show()

			elseif ret == 4 then
				app.toast.show("下载失败")
				self.layDownload:hide()
			elseif ret == 6 then
				coroutine.resume(self.co)
			end
		end	

		local function isMahjResExist()
			if cc.FileUtils:getInstance():isDirectoryExist("src/mahjres") or 
				cc.FileUtils:getInstance():isDirectoryExist(g_writablePath .."/update/mahjres") then

				print("isMahjResExist = true")
				return true
			end
			print("isMahjResExist = false")
			return false
		end

		local strZipUrl = ""
		if isMahjResExist() then
			strZipUrl = urls.updateZipDownloadurl
		else
			strZipUrl = urls.fullZipDownloadurl
		end
		self:downLoadingUI("mahjres", onResult, strZipUrl)
		self.layDownload:hide()

		return true
	else
		return false
	end
end

local function getGameDownLoadUrl(gameId)
	
	local function isExist()
		local ret =  _gamedb.checkIsDownloaded(gameId)
		if ret == 0 or ret == 1 then
			return false 
		else
			return true
		end
	end

	local strZipUrl = ""
	local bExist
	if isExist() then
		strZipUrl = urls.updateZipDownloadurl
		bExist = true
	else
		strZipUrl = urls.fullZipDownloadurl
		bExist = false
	end

	return strZipUrl, bExist
end

function GameListLayer:checkUpdateGame(gameId, funcEnterRoom)
	print("GameListLayer:checkUpdateGame")
	local function checkUpdateGame(strZipUrl, bExist)
		local function onResult(ret)--回调
			app.holdOn.hide()
			print("<--------GameListLayer:checkUpdateGame onResult")
			if ret == 0 then --成功
			--	app.toast.show("下载成功")	
				self.layDownload:hide()
				app.isCheckedUpdate[cc.dataMgr.playingGame] = true 
				_gamedb.updateDownloadState(gameId)
				funcEnterRoom()
			elseif ret == 1 then
				print("<--- 不需要更新小游戏")
				funcEnterRoom()
				self.layDownload:hide()
				app.isCheckedUpdate[cc.dataMgr.playingGame] = true 
			elseif ret == 2 then
				funcEnterRoom()
			elseif ret == 3 then
				app.holdOn.hide()
				app.isCheckedUpdate[cc.dataMgr.playingGame] = true 
				self.layDownload:show()
			elseif ret == 4 then
				app.toast.show("下载失败")
				self.layDownload:hide()
			elseif ret == 6 then
				if not bExist then
					app.toast.show("敬请期待")
				else
					funcEnterRoom()
				end
				self.layDownload:hide()
			end
		end

		print("strZipUrl = " ..strZipUrl)
		self:downLoadingUI(cc.dataMgr.playingGame, onResult, strZipUrl)
		self.layDownload:hide()
	end
	
	local strZipUrl, bExist = getGameDownLoadUrl(gameId)
	checkUpdateGame(strZipUrl, bExist)
end
	
local _scheduleDelete = nil
local _time = 0

local function unScheduleDeleteFunc(bResetTime)
	if _scheduleDelete then
         scheduler.unscheduleGlobal(_scheduleDelete)
         _scheduleDelete = nil

        if bResetTime then
    		_time = 0
    	end
    end
end

function GameListLayer:shockAction(sprite)
	sprite:runAction(cc.RepeatForever:create(
		cc.Sequence:create(
			cc.RotateTo:create(0.15, -3),
			cc.RotateTo:create(0.15, 3)
		)
	))
end

function GameListLayer:onBtnEvt(sender, eventType)
	local bGuide = cc.dataMgr.guiderFlag["newbie_guide"]
	if bGuide then return end
	if eventType == 0 then

		local btnDdelete = sender:getChildByName("Button_btnDelete")
		_scheduleDelete = scheduler.performWithDelayGlobal(function()
			print("btnDdelete:show()")
			
			self:showAllDeleteBtns()
			self.layRoof:show()
			unScheduleDeleteFunc(true)
			_time = 1
		end, 1)
	elseif eventType == 1 then
	elseif eventType == 2 then
		app.audioPlayer:playClickBtnEffect()
		unScheduleDeleteFunc()
		if _time == 1 then
			_time = 0
			return
		end

		if self.isEdit then
			return
		end

		app.holdOn.show("加载中...")
		banBtn(sender)--防止连续多次点击
		local delayTime = cc.DelayTime:create(1)
		local fc = cc.CallFunc:create(function()
			pickBtn(sender)--防止连续多次点击
		end)
		self.gameListlayer:runAction(cc.Sequence:create(delayTime, fc))
		
		local userdata = sender.userdata
		cc.dataMgr.playingGame = userdata.gameName
		local gameId = userdata.gameID

		local function enterRoom()
			local p = require(cc.dataMgr.playingGame ..".src.CustomLayer")
			if p:playCustomEvent(gameId) == 1 then
				app.holdOn.show("正在获取房间列表信息...")
			end
		end

		if app.isAccessAppleStore == 0 then
			app.isCheckedUpdate[cc.dataMgr.playingGame] = true
		end

		--[[ --test
		if g_Platform_Win32 then
			app.isCheckedUpdate[cc.dataMgr.playingGame] = true 
		end
		--]]
		------- 
		if app.isCheckedUpdate[cc.dataMgr.playingGame] == true then
			enterRoom()
			return
		end

		print(app.isDownloading)
		if app.isDownloading == false then

			self:checkUpdateGame(gameId, enterRoom)
			--[[
			self.co = coroutine.create(function()
				if self:downloadMahjRes(cc.dataMgr.playingGame) then
					coroutine.yield()
				end
				self:checkUpdateGame(gameId, enterRoom)
			end)
			coroutine.resume(self.co)]]
		end
	else
		 unScheduleDeleteFunc(true)
		 
	end
end

function GameListLayer:onBtnDeleteEvt(sender, eventType)
	if eventType == 2 then
		app.audioPlayer:playClickBtnEffect()
		print("delete game")
		local userdata = sender:getParent().userdata
		local index = self.lvRooms:getCurSelectedIndex()
		print("select index" ..index)
		self.insertIndex = self.insertIndex - 1
	--	self.lvRooms:removeItem(index)

		local bSuccess = false
		if _gamedb.deleteGame(sender.gameId, 0) == 0 then
			print("sender.gameName = " ..sender.gameName)
			
			if cc.FileUtils:getInstance():removeDirectory("src/" ..sender.gameName .."/") then
				print("文件夹删除成功")
				bSuccess = true
			end

			if cc.FileUtils:getInstance():removeDirectory(g_writablePath .."/update/" ..sender.gameName .."/") then
				print("文件夹删除成功")
				bSuccess = true
			end
		end

		if bSuccess then
			app.toast.show("删除成功")
			self.lvRooms:removeItem(index)
			self.lvRooms:refreshView()
			cc.UserDefault:getInstance():setStringForKey(sender.gameName .."_version", "0")

			table.remove(self.tblDeleteBtns, index + 1)
		end
	end
end

function GameListLayer:updateGameListUI()
	self:showGameList()

	local delayTime = cc.DelayTime:create(0.1)
	local callfc = cc.CallFunc:create(function()
		self.lvRooms:refreshView()
		self.innerWidth = self.lvRooms:getInnerContainerSize().width
		local lvWidth = self.lvRooms:getContentSize().width
		print("innerWidth = " ..self.innerWidth)

		if self.innerWidth == lvWidth then
			self.leftTag:hide()
			self.rightTag:hide()
		else 
			self.leftTag:hide()
			self.rightTag:show()
		end
	end)
	self.lvRooms:runAction(cc.Sequence:create(delayTime, callfc))


end

function GameListLayer:getInnerPx()
	local inner = self.lvRooms:getInnerContainer()
	local pX = inner:getPositionX()
	

	return pX
end



function GameListLayer:showGameList()
	self.lvRooms = self.gameListlayer:getChildByName("ListView_3"):hide()
	self.lvRooms:setItemsMargin(50)
	self.lvRooms:removeAllItems()
	self.btnProtopyte = self.gameListlayer:getChildByName("Button_room"):hide()

	self.leftTag = self.gameListlayer:getChildByName("Image_left"):hide()
	self.rightTag = self.gameListlayer:getChildByName("Image_right"):hide()

	--self.btnProtopyte:setPressedActionEnabled(true)
	local lvWidth = self.lvRooms:getContentSize().width
	--添加新游戏
	local btnAdd = self.btnProtopyte:clone():show()

	local bGuide = cc.dataMgr.guiderFlag["newbie_guide"]
	local function showGuide()
		self.lvRooms:setDirection(0)
		self.lvRooms:jumpToRight()
		local innerContainer = self.lvRooms:getInnerContainer()
		local posXContainer, posYContainer = innerContainer:getPosition()
		print("posContainer:"..posXContainer.." "..posYContainer)
		local posXButton, posYButton = btnAdd:getPosition()
		print("posButton:"..posXButton.." "..posYButton)
		local posXList, posYList = self.lvRooms:getPosition()
		print("posList:"..posXList.." "..posYList)
		local size = btnAdd:getContentSize()
		local point = cc.p(posXList + posXContainer + posXButton - size.width / 2, posYList + posYContainer + posYButton - size.height / 2)
		app.hallScene.gameListGuideLayer:showAddGameGuide(point, size)
	end
	self.lvRooms:addScrollViewEventListener(function(sender, eventType)
		if eventType == 3 then
			if bGuide and app.hallScene.gameListGuideLayer ~= nil then
				print("SCROLL_TO_RIGHT")
				showGuide()
			end
		end
		unScheduleDeleteFunc(true)
		local pXB = self:getInnerPx()
		local pXE = pXB + lvWidth
		if self.innerWidth == lvWidth then
			self.leftTag:hide()
			self.rightTag:hide()
		else
			if pXB <= -200 then
				self.leftTag:show()
			else
				self.leftTag:hide()
			end

			if pXE >= 960 then
				self.rightTag:show()
			else
				self.rightTag:hide()
			end
		end
	end)
	

    self.insertIndex = 0
   -- local gameInfo = _gamedb.readGameInfo()
    print("<---gameInfo")
    --dump(gameInfo)
   	
   	--[[
   	self.channelItem = {}
   	for i = #gameInfo, 1, -1 do
    	local game = gameInfo[i]
		showSingleGame(self, game.gameId, game.gameName, self.insertIndex, game.gameName_ZH)
		self.tblGames[#self.tblGames + 1] = game.gameName
		app.isCheckedUpdate[cc.dataMgr.playingGame] = false
    end
    ]]

    cc.dataMgr.playingGame = "dzpk"
    print("self.lvRooms:getChildrenCount() = " ..self.lvRooms:getChildrenCount())


    local btnEnter = ccui.Button:create("enterroomt.png", "enterroomt.png", "")
    btnEnter:setScale(0.5)
    btnEnter:setPressedActionEnabled(true)
    btnEnter:addTo(self.gameListlayer)
    btnEnter:pos(display.cx, display.cy)
    btnEnter:addTouchEventListener(function(obj, type)
    	if type == 2 then
    		local function enterRoom()
			local p = require("dzpk.src.CustomLayer")
			if p:playCustomEvent(90) == 1 then
				app.holdOn.show("正在获取房间列表信息...")
			end
		end

		if app.isAccessAppleStore == 0 then
			app.isCheckedUpdate[cc.dataMgr.playingGame] = true
		end

		if app.isCheckedUpdate[cc.dataMgr.playingGame] == true then
			enterRoom()
			return
		end
    	end
    end)


	self.lvRooms:insertCustomItem(btnAdd, self.insertIndex)
	self.insertIndex = self.insertIndex + 1
	btnAdd:getChildByName("Button_btnDelete"):hide()
	local imgIcon = btnAdd:getChildByName("Image_gameName"):getChildByName("Image_iconName")
	imgIcon:loadTexture("games/addgame.png")
	imgIcon:ignoreContentAdaptWithSize(true)

	local imgDecorate = btnAdd:getChildByName("Image_decorate")
	imgDecorate:ignoreContentAdaptWithSize(true)
	imgDecorate:loadTexture("games/addDecorate.png")

	local function onBtnAddEvt(sender, eventType)
		if eventType == 2 then
			app.audioPlayer:playClickBtnEffect()
			--addNewGame(self, 888, "bfmj")
			if self.gameAddLayer == nil  then
				self.gameAddLayerCtrller = require("app.views.layers.GameAddLayer").new()
				self.gameAddLayer = self.gameAddLayerCtrller:createLayer()
				self.gameAddLayer:addTo(self.gameListlayer:getParent(), 100)
			end
			--self.gameAddLayer:show()
			self.gameAddLayerCtrller:showLayer()
			app.hallScene.nPopLayers = app.hallScene.nPopLayers + 1

			self.lvRooms:setDirection(2)
			bGuide = false
			--[[
			cc.dataMgr.guiderFlag["newbie_guide"] = false
			cc.UserDefault:getInstance():setBoolForKey("newbie_guide", false)
			if app.hallScene.gameListGuideLayer ~= nil then
				app.hallScene.gameListGuideLayer.root:removeSelf()
				app.hallScene.gameListGuideLayer = nil
			end
			--]]
		end
	end
	btnAdd:addTouchEventListener(onBtnAddEvt)

	if app.isAccessAppleStore == 0 then
		btnAdd:hide()
	end

	if bGuide and app.hallScene.gameListGuideLayer ~= nil then
		local innerContainer = self.lvRooms:getInnerContainer()
		--强制刷新，不然btnAdd的位置和容器大小不正确
		self.lvRooms:forceDoLayout()
		print("gamelistsize:"..innerContainer:getContentSize().width.." "..self.lvRooms:getContentSize().width)
		if innerContainer:getContentSize().width <= self.lvRooms:getContentSize().width then
			showGuide()
		end
	end
end


return GameListLayer