require "data.protocolPublic"

local LobbyScene = class("LobbyScene", cc.load("mvc").ViewBase)


LobbyScene.RESOURCE_FILENAME = "hall/LobbyScene.csb"
local LobbySceneEvents = {}
LobbyScene.RESOURCE_BINDING = LobbySceneEvents
function LobbyScene:onCreate()
	self.name = "LobbyScene"
	app.runningScene = self
	printf("resource node = %s", tostring(self:getResourceNode()))
	self.eventProtocol = require("framework.components.behavior.EventProtocol").new()
	cc.msgHandler:setPlayingScene(self)
	cc.dataMgr.gameData = {}
end


function LobbyScene:onEnter_()
	self:fillTitleBar()
	self:listenEvent()
	cc.sceneTransFini = true
	cc.dataMgr.castMultSetInfo.useCastMultSet = false
	
	self:onPL_PHONE_SC_GAMELIST_ACK_P() --从房间退出后立即显示房间列表
end

function LobbyScene:onExit_()
	self.eventProtocol:removeAllEventListeners()
end

function LobbyScene:listenEvent()
	self.eventProtocol:addEventListener("PL_PHONE_SC_GAMELIST_ACK_P", handler(self, LobbyScene.onPL_PHONE_SC_GAMELIST_ACK_P))
	self.eventProtocol:addEventListener("GAME_SRV_CONNECTED", handler(self, LobbyScene.onGAME_SRV_CONNECTED))
	self.eventProtocol:addEventListener("PL_PHONE_GC_LOGIN_ACK_P", handler(self, LobbyScene.onPL_PHONE_GC_LOGIN_ACK_P))
end

function LobbyScene:fillTitleBar()
	--cc.hideLoading()
	local titlebar = self:getResourceNode():getChildByName("TitleBar")
	local label = titlebar:getChildByName("ImageGBBG"):getChildByName("TextGB")
	label:setString(i64_toInt(cc.dataMgr.lobbyUserData.lobbyUser.gameCurrency))
	local labelname = titlebar:getChildByName("TextName")
	labelname:setString(cc.dataMgr.lobbyUserData.lobbyUser.strNickNamebuf)
	--avatar image
	local _img = titlebar:getChildByName("ImageAvatarBG"):getChildByName("ImageAvatar")
	local img = _img:clone()
	img:setPosition(cc.p(0, 0))
	_img:setVisible(false)
	local fn = "avatar/" .. cc.dataMgr.lobbyUserData.lobbyUser.icon .. ".jpg"
	print(fn)
	img:loadTexture(fn, ccui.TextureResType.localType)
	local imgbg = titlebar:getChildByName("ImageAvatarBG")
	local clip = cc.ClippingNode:create()
	clip:setAlphaThreshold(0.05)
	local size = imgbg:getContentSize()
	clip:setPosition(cc.p(size.width / 2, size.height / 2))
	clip:addChild(img)
	local stencil = cc.Sprite:create("avatar/stencil.png")
	stencil:setScale(0.93)
	clip:setStencil(stencil)
	imgbg:addChild(clip, 1)
	--imgbg:loadTexture(nil, 0)
end

function LobbyScene:onPL_PHONE_SC_GAMELIST_ACK_P()
	app.holdOn.hide()
	if cc.dataMgr.gameList == nil then return end

	self.addGameChannel = coroutine.create(function()
		local gameListView = self:getResourceNode():getChildByName("GameListBG"):getChildByName("GameList")
		for i = 0, #cc.dataMgr.gameList.vecGameInfo - 1, 1 do
			local v = cc.dataMgr.gameList.vecGameInfo[i + 1]
			--new temp
			local tmp = self:getResourceNode():getChildByName("ChannelTmp")
			local rmtmp = self:getResourceNode():getChildByName("RoomTmp")
			local new = tmp:clone()
			local name = new:getChildByName("TextChannel")
			name:setString(v.gameInfo.chanelName)
			for ir = 0, #v.rmInfo - 1, 1 do
				local vr = v.rmInfo[ir + 1]
				local newrm = rmtmp:clone()
				local namerm = newrm:getChildByName("TextRoom")
				namerm:setString(vr.szRoomName..":"..vr.userNum)
				local btnrm = newrm:getChildByName("ButtonRoom")
				btnrm.userdata = vr
				local function onBtnRoom(object, event)
					if event == cc.EventCode.ENDED then
						cc.showLoading()
						local v = cc.dataMgr.gameList.vecGameInfo[i + 1]
						cc.dataMgr.selectedGameSrv = table.deepcopy(v.svrInfo)
						cc.dataMgr.selectedGameInfo = table.deepcopy(v.gameInfo)
						cc.dataMgr.selectedGameRoom = table.deepcopy(object.userdata)
						cc.dataMgr.maxTableCount = v.gameInfo
						print(v.svrInfo.srvIP)
						print(object.userdata.szRoomName)
						cc.msgHandler:connectToGame(v.svrInfo.srvIP, v.svrInfo.srvPort)
					end
				end

				btnrm:addTouchEventListener(onBtnRoom)
				local list = new:getChildByName("ListViewRoom")
				list:insertCustomItem(newrm, ir)
				--coroutine.yield()
			end
			--gameListView:addPage(new)
			print("insert")
			gameListView:insertCustomItem(new, i)
			coroutine.yield()
		end
	end)

	local function resume()
		coroutine.resume(self.addGameChannel)
	end

	local function hide()
		cc.hideLoading()
	end

	local _a = cc.Sequence:create(cc.DelayTime:create(0.05), cc.CallFunc:create(resume, { 0 }), nil)
	local _rep = cc.Repeat:create(_a, #cc.dataMgr.gameList.vecGameInfo)
	local _b = cc.Sequence:create(_rep, cc.CallFunc:create(hide, { 0 }), nil)
	self:stopAllActions()
	self:runAction(_b)
	print("-get game list")
end


function LobbyScene:onGAME_SRV_CONNECTED()
	print("game srv connected..")
	app.holdOn.hide()
	cc.lobbyController:sendGameLoginReq()
end

function LobbyScene:onPL_PHONE_GC_LOGIN_ACK_P(event)
	app.holdOn.hide()
	if event.data.bRet == wnet.EGameResult.EGAME_RESULT_OK then
		if app.funcPublic.isRoundGame() then
			cc.dataMgr.withoutRoomScene = true
			app.sceneSwitcher:enterScene("GameScene")
		else
			app.sceneSwitcher:enterScene("RoomScene")
		end
	else
		print("login game server failed. " .. event.data.bRet)
	end
end

return LobbyScene
