--
-- Author: ChenShao
-- Date: 2015-08-17 17:09:06
--
--local ReminderPoint = require("hall.view.ReminderPoint")
local inputUtil = require("app.func.InputUtil")

local HallScene = class("HallScene", cc.load("mvc").ViewBase)

HallScene.RESOURCE_FILENAME = "LobbyScene/LobbyScene.csb"


local function createLayer(layerName)
	local ctrl = require("app.views.layers." ..layerName)
	return ctrl:createLayer(), ctrl
end

local function _procBigNumber(num)
    --get
    if num <= 100000 then
        return tostring(num)
    elseif num <= 1000000 then
        local _b = num / 1000
        local s = string.format("%.2f万", _b)
        return s
    elseif num <= 100000000 then
        local _b = math.floor(num / 1000)
        return _b .. "万"
    else
        local _b = math.floor(num / 1000000)
        local s = string.format("%.2f亿", _b)
        return s
    end
end

local function updateUserInfo(self)
	local userData = cc.dataMgr.lobbyUserData.lobbyUser
	self.labelNickName:setString(inputUtil.getReducedString(userData.strNickNamebuf, 16, ".."))
	self.labelBean:setString(_procBigNumber(i64_toInt(userData.gameCurrency)))
	local fn = "avatar/" .. userData.icon .. ".jpg"
	print("hall:"..fn)
	self.imgAvatar:loadTexture(fn, ccui.TextureResType.localType)
	--local vipLevel = userData.vipLevel
	--print("vipLevel = " ..vipLevel)
	--[[
	if vipLevel <= 0 then
		local strImgPath = "Resources/newResources/Vip/touxiangkuang-hui.png"
		print("strImgPath"..strImgPath)
		self.imgAvatarBorder:loadTexture(strImgPath, 1)
		self.imgVipStateEnabled:setVisible(false)
		self.imgVipStateDisabled:setVisible(true)
		self.lableVipLevelEnabled:setVisible(false)
		self.lableVipLevelDisabled:setVisible(true)
		self.lableVipLevelDisabled:setString(-vipLevel)
		cc.dataMgr.bVip = false
	else
		local strImgPath = "Resources/newResources/Vip/touxiangkuang-jin.png"
		print("strImgPath"..strImgPath)
		self.imgAvatarBorder:loadTexture(strImgPath, 1)
		self.imgVipStateEnabled:setVisible(true)
		self.imgVipStateDisabled:setVisible(false)
		self.lableVipLevelEnabled:setVisible(true)
		self.lableVipLevelEnabled:setString(vipLevel)
		self.lableVipLevelDisabled:setVisible(false)
		cc.dataMgr.bVip = true
	end
	]]
end

local function procUserInfo(self)
	local nodeUserInfo = self:getResourceNode():getChildByName("Node_userInfo")
	self.nodeUserInfo = nodeUserInfo

	self.labelNickName = nodeUserInfo:getChildByName("Text_nicekName")
	self.labelBean = nodeUserInfo:getChildByName("BitmapFontLabel_bean")
	self.imgAvatar = nodeUserInfo:getChildByName("ImageAvatar")
	--[[
	self.imgAvatarBorder = layAvatar:getChildByName("Image_avatarBorder"):removeSelf()
	self.imgVipStateEnabled = layAvatar:getChildByName("Image_vipState_enabled"):removeSelf()
	self.imgVipStateDisabled = layAvatar:getChildByName("Image_vipState_disabled"):removeSelf()
	self.lableVipLevelEnabled = layAvatar:getChildByName("BitmapFontLabel_vipLevel_enabled"):removeSelf()
	self.lableVipLevelDisabled = layAvatar:getChildByName("BitmapFontLabel_vipLevel_disabled"):removeSelf()
	]]
--[[
	local _img = nodeUserInfo:getChildByName("ImageAvatarBG"):getChildByName("ImageAvatar")
	self.imgAvatar = _img:clone()
	self.imgAvatar:setPosition(cc.p(0, 0))
	_img:setVisible(false)
	local imgbg = nodeUserInfo:getChildByName("ImageAvatarBG")

	self.clip = cc.ClippingNode:create()
	self.clip:setAlphaThreshold(0.05)
	local size = imgbg:getContentSize()
	self.clip:setPosition(cc.p(size.width / 2, size.height / 2))
	self.clip:addChild(self.imgAvatar)
	local stencil = cc.Sprite:create("avatar/stencil.png")
	stencil:setScale(0.93)
	self.clip:setStencil(stencil)
	imgbg:addChild(self.clip, 1)
--]]
	updateUserInfo(self)
end

local function showAllBtns(self)
	for i = 1,  #self.downBtns do
		self.downBtns[i]:show()
	end
	for i = 1,  #self.upBtns do
		self.upBtns[i]:show()
	end
end

local function hideAllBtns(self)
	for i = 1,  #self.downBtns do
		self.downBtns[i]:hide()
	end
	for i = 1,  #self.upBtns do
		self.upBtns[i]:hide()
	end
end

local function playShowBtnAnimation(self)
	for i = 1,  #self.downBtns do
		local btn = self.downBtns[i]
		btn:show()
		btn:setPositionY(btn:getPositionY() - btn:getContentSize().height)
		--[[
		local moveBy = cc.MoveBy:create(0.3 * (i - 1), cc.p(0, btn:getContentSize().height))
		btn:runAction(moveBy)
		--]]
		---[[
		local delay = cc.DelayTime:create(0.1 * (i - 1))
		local moveBy = cc.MoveBy:create(0.3, cc.p(0, btn:getContentSize().height))
		local moveBy_easeBackOut = cc.EaseBackOut:create(moveBy)
		local action = cc.Sequence:create(delay, moveBy_easeBackOut)
		btn:runAction(action)
		--]]
	end
	for i = 1,  #self.upBtns do
		local btn = self.upBtns[i]
		btn:show()
		btn:setPositionY(btn:getPositionY() + btn:getContentSize().height)
		--[[
		local moveBy = cc.MoveBy:create(0.3 * (i - 1), cc.p(0, -btn:getContentSize().height))
		btn:runAction(moveBy)
		--]]
		---[[
		local delay = cc.DelayTime:create(0.1 * (i - 1))
		local moveBy = cc.MoveBy:create(0.3, cc.p(0, -btn:getContentSize().height))
		local moveBy_easeBackOut = cc.EaseBackOut:create(moveBy)
		local action = cc.Sequence:create(delay, moveBy_easeBackOut)
		btn:runAction(action)
		--]]
	end
end

local function initGameListGuide(self)
	--游戏列表指引
	local bGuide = cc.dataMgr.guiderFlag["newbie_guide"]
	if bGuide then
		local guideLayer = require("hall.view.GameListGuideLayer").create()
		self:addChild(guideLayer.root, 120)
		self.gameListGuideLayer = guideLayer
		if self.gameListGuideLayer ~= nil then
			self:updateGameListUI()
		end
	end
end

local function playShowGameListAnimation(self)
	---[[
	--房间列表显示时不显示游戏列表
	if self.gameListLayer ~= nil and (self.channelListLayer == nil or not self.channelListLayer:isVisible()) then
		self.gameListLayer:setPositionX(self.gameListLayer:getPositionX() - self.gameListLayer:getContentSize().width)
		self.gameListLayer:setVisible(true)
		local moveBy = cc.MoveBy:create(0.3, cc.p(self.gameListLayer:getContentSize().width, self.gameListLayer:getPositionY()))
		local moveBy_easeBackOut = cc.EaseBackOut:create(moveBy)
		local delay = cc.DelayTime:create(0.6)
		local funcFinal = cc.CallFunc:create(function()
			initGameListGuide(self)
		end)
		self.gameListLayer:runAction(cc.Sequence:create(delay, moveBy_easeBackOut, funcFinal))
	end
	--]]
end

local function playEnterSceneAnimation(self)
	--按钮出现的动画
	--playShowBtnAnimation(self)
	--游戏列表出现的动画
	playShowGameListAnimation(self)
	--暂停协议处理
	g_pauseMsgHandlerForAWhile(1)
end

local function procBtns(self)
	local nodeBtns = self:getResourceNode():getChildByName("Node_btns")--:hide()

	local btnSet = nodeBtns:getChildByName("Button_btnSet")
	btnSet:setPressedActionEnabled(true)
	btnSet:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			if self.settinglayer == nil  then
				self.settinglayer, self.settinglayerCtrl = createLayer("SettingLayer")
				self.settinglayer:addTo(self, 20):hide()
			end
			app.popLayer.showEx(self.settinglayer:getChildByName("Panel_root"))
			self.settinglayer:setVisible(true)
			self.nPopLayers = self.nPopLayers + 1

		end
	end)
	--[[
	self.upBtns = {}
	self.downBtns = {}

	--商城按钮
	local btnShop = nodeBtns:getChildByName("Button_btnShop"):hide()
	btnShop:setPressedActionEnabled(true)
	btnShop:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			self.layShop:setVisible(true)
			--hideAllBtns(self)

			self:hideHallUI()
		end
	end)
	--ReminderPoint.new():init(btnShop, "shop", self)
	if app.isAccessAndroidStore == 0 then
		btnShop:hide()
		self.downBtns[#self.downBtns] = nil
	end

	local action = cc.CSLoader:createTimeline("hall/HallScene.csb")
    self:runAction(action)
	action:gotoFrameAndPlay(0)

	--会员按钮
	local btnVip = nodeBtns:getChildByName("Button_btnVip")
	btnVip:setPressedActionEnabled(true)
	btnVip:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			self.layVip:setVisible(true)
			self:hideHallUI()
		end
	end)
	self.downBtns[#self.downBtns + 1] = btnVip
	if app.isAccessAppleStore == 0 then
		btnVip:hide()
		self.downBtns[#self.downBtns] = nil
	end

	--福利中心按钮
	local btnBenefit = nodeBtns:getChildByName("Button_btnAward")
	btnBenefit:setPressedActionEnabled(true)
	btnBenefit:addTouchEventListener(function(obj, type)
		if type == 2 then
			--require("hall.view.BenefitGuideLayer").new():show(self)
			app.audioPlayer:playClickBtnEffect()
			self.layBenefit:setVisible(true)

			self:hideHallUI()
		end
	end)
	ReminderPoint.new():init(btnBenefit, "benefit", self)
	self.btnBenefit = btnBenefit
	self.downBtns[#self.downBtns + 1] = btnBenefit
	if app.isAccessAppleStore == 0 then
		btnBenefit:hide()
		self.downBtns[#self.downBtns] = nil
	end

	--兑换按钮
	local btnExChange = nodeBtns:getChildByName("Button_btnExchange")
	btnExChange:setPressedActionEnabled(true)
	btnExChange:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			self:showExchangeLayer()
			self:hideHallUI()
		end
	end)
	self.downBtns[#self.downBtns + 1] = btnExChange
	if app.isAccessAppleStore == 0 then
		btnExChange:hide()
		self.downBtns[#self.downBtns] = nil

		--btnShop:setPosition(cc.p(btnExChange:getPositionX(), btnExChange:getPositionY()))
	end

	--排行按钮
	local btRank = nodeBtns:getChildByName("Button_btnRank"):hide()
	btRank:setPressedActionEnabled(true)
	btRank:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			if self.rankLayer == nil  then
				self.rankLayer, self.rankLayerCtrl = createLayer("RankLayer")
				self.rankLayer:addTo(self, 20):hide()
			end
			app.holdOn.show("正在获取排行信息...", 0)
			cc.lobbyController:sendUserRankReq()
			self.nPopLayers = self.nPopLayers + 1
		end
	end)
	--self.downBtns[#self.downBtns + 1] = btRank

	--好友按钮
	local btnFriend = nodeBtns:getChildByName("Button_btnFriend"):hide()
	btnFriend:setPressedActionEnabled(true)
	btnFriend:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			self.nPopLayers = self.nPopLayers + 1
		end
	end)
	--self.downBtns[#self.downBtns + 1] = btnFriend

	--设置按钮
	local btnSet = nodeBtns:getChildByName("Button_btnSet")
	btnSet:setPressedActionEnabled(true)
	btnSet:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			if self.settinglayer == nil  then
				self.settinglayer, self.settinglayerCtrl = createLayer("SettingLayer")
				self.settinglayer:addTo(self, 20):hide()
			end
			app.popLayer.showEx(self.settinglayer:getChildByName("Panel_root"))
			self.settinglayer:setVisible(true)
			self.nPopLayers = self.nPopLayers + 1

		end
	end)
	self.upBtns[#self.upBtns + 1] = btnSet

	--消息按钮
	local btnMessage = nodeBtns:getChildByName("Button_btnMessage"):hide()
	btnMessage:setPressedActionEnabled(true)
	btnMessage:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
		end
	end)
	--self.upBtns[#self.upBtns + 1] = btnMessage

	--任务按钮
	local btnTask = nodeBtns:getChildByName("Button_btnTask"):hide()
	btnTask:setPressedActionEnabled(true)
	btnTask:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			if app.taskLayerCtrller then
				app.taskLayerCtrller:updateTaskListUI()
				app.taskLayerCtrller.taskLayer:show()
			end
		end
	end)
	--self.upBtns[#self.upBtns + 1] = btnTask

	--抽奖按钮
	local btnLottery = nodeBtns:getChildByName("Button_btnLottery")
	btnLottery:setPressedActionEnabled(true)
	btnLottery:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			self:showLotteryLayer()

			self:hideHallUI()
		end
	end)
	self.upBtns[#self.upBtns + 1] = btnLottery
	if app.isAccessAppleStore == 0 then
		btnLottery:hide()
		self.upBtns[#self.upBtns] = nil
	end
	
	--保险箱按钮
	local btnCoffer = nodeBtns:getChildByName("Button_coffer")
	btnCoffer:setPressedActionEnabled(true)
	btnCoffer:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			self.layCoffer:setVisible(true)
		end
	end)
	self.upBtns[#self.upBtns + 1] = btnCoffer
	if app.isAccessAppleStore == 0 then
		btnCoffer:hide()
		self.upBtns[#self.upBtns] = nil
	end

	--首充奖励
	local nodeRechargeAward = nodeBtns:getChildByName("Node_rechargeAward")
	local btnRechargeAward = nodeRechargeAward:getChildByName("Button_rechargeAward")
	btnRechargeAward:setPressedActionEnabled(true)
	btnRechargeAward:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			--添加首冲奖励界面并显示
			if self.layRechargeAward == nil then
				self.layRechargeAward = require("hall.view.RechargeAwardLayer").create()
				self:addChild(self.layRechargeAward.root, 25)
			end
			self.layRechargeAward:setVisible(true)
			self.nPopLayers = self.nPopLayers + 1
		end
	end)
	nodeRechargeAward:hide()
	ReminderPoint.new():init(btnRechargeAward, "rechargeAward", self)
	self.nodeRechargeAward = nodeRechargeAward

	if app.isAccessAndroidStore ==0 then
		btnRechargeAward:setVisible(false)
		nodeRechargeAward:setVisible(false)
	end

	local nodeUserInfo = self:getResourceNode():getChildByName("Node_userInfo")

	--头像
	local imgAvatar = nodeUserInfo:getChildByName("ImageAvatarBG"):getChildByName("ImageAvatar")
	imgAvatar:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			self.layIndividual:setVisible(true)
		end
	end)
	if app.isAccessAppleStore == 0 then
		imgAvatar:setTouchEnabled(false)
	end

	--充值按钮
	local btnRecharge =nodeUserInfo:getChildByName("Button_recharge"):hide()
	btnRecharge:setPressedActionEnabled(true)
	btnRecharge:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			self.layShop:setVisible(true)
			self:hideHallUI()
		end
	end)
	if app.isAccessAndroidStore ==0 then
		btnRecharge:setVisible(false)
	end

	--隐藏按钮
	print("hide all the buttons")
	hideAllBtns(self)
	--]]
end

local function listenConnectEvent(self)
	self.eventProtocol:addEventListener("PL_PHONE_SC_GAMELIST_ACK_P", function() --获取房间列表回复
		print("··PL_PHONE_SC_GAMELIST_ACK_P·")	
		--//----------------------------------------------

		print("#cc.dataMgr.gameList.vecGameInfo = " ..#cc.dataMgr.gameList.vecGameInfo)
		if cc.dataMgr.isBroken then --断线重连
			app.holdOn.show("Geting Room Info...", 0, self)
			for i = 0, #cc.dataMgr.gameList.vecGameInfo - 1 do
				local v = cc.dataMgr.gameList.vecGameInfo[i + 1]
				if  cc.dataMgr.selectServerID == v.svrInfo.srvID then
					cc.dataMgr.selectedGameSrv = table.deepcopy(v.svrInfo)
					cc.dataMgr.selectedGameInfo = table.deepcopy(v.gameInfo)
	
					cc.dataMgr.maxTableCount = v.gameInfo.tableNum
					cc.dataMgr.tablePlyNum = v.gameInfo.tablePlyNum
					cc.dataMgr.gameName = v.gameInfo.gameName
					cc.dataMgr.selectGameType = v.gameInfo.gameType

					if v.rmInfo[cc.dataMgr.selectRoomID + 1] ~= nil then
						cc.dataMgr.selectedGameInfo.onLineNum = v.rmInfo[cc.dataMgr.selectRoomID + 1].userNum
					end

					--断线重连从数据库获取游戏名
					local db = require("app.func.GameDB")
					--cc.dataMgr.playingGame = "ccmj"
					cc.dataMgr.playingGame = db.getGameNameByGameID(cc.dataMgr.selectGameID)

					app.taskLogic:initData()

					cc.msgHandler:connectToGame(v.svrInfo.srvIP, v.svrInfo.srvPort)
					break
				end	
			end
			
			return
		end

	
		cc.hideLoading()
		self:showChannelLayer()
	
	end)

	self.eventProtocol:addEventListener("GAME_SRV_CONNECTED", function() --连接lobby服务器
		print("ftest game srv connected gameType="..cc.dataMgr.selectedGameInfo.gameType)	-- PL_PHONE_SC_GAMELIST_ACK_P/SC_GAMELIST_ACK_P 游戏列表消息

		cc.lobbyController:sendGameLoginReq()
	end)
	
	self.eventProtocol:addEventListener("PL_PHONE_GC_LOGIN_ACK_P", function(event) --请求登陆lobby服务器回复
		print("<===PL_PHONE_GC_LOGIN_ACK_P")
		if event.data.bRet == wnet.EGameResult.EGAME_RESULT_OK then
			self.channelListLayer = nil
			self.channelListLayerCtrl = nil
	
			if app.funcPublic.isRoundGame() or app.funcPublic.isQuickGame() then
				cc.dataMgr.withoutRoomScene = true
				app.sceneSwitcher:enterScene("GameScene")
			else
				app.sceneSwitcher:enterScene("RoomScene")
			end
		else
			print("login game server failed. " .. event.data.bRet)
		end
	end)
end

local function listenEvent(self)	
	self.eventProtocol:addEventListener("PL_PHONE_LC_USERRANK_ACK_P", function(event) --获取玩家排行信息
		print("---get user rank info")
		--app.holdOn.hide()
		self.rankLayer:setVisible(true)
		self.rankLayerCtrl:updateUI(event.data)
	end)

	self.eventProtocol:addEventListener("PL_PHONE_LC_SELFUSERRANK_ACK_P", function(event) --获取玩家自己排行信息
		--app.holdOn.hide()
		self.rankLayerCtrl:updateMyItem(event.data)
		print("---get my rank info")
	end)

	self.eventProtocol:addEventListener("USERDATA_CHANGED", function() --个人信息变动
		print("USERDATA_CHANGED")
		updateUserInfo(self)
		self.layIndividual:fillDataToUI()
		self.layCoffer:fillDataToUI()
	end)

	self.eventProtocol:addEventListener("BENEFIT_GUIDE", function() --新手礼包提醒
		if not cc.UserDefault:getInstance():getBoolForKey("benefit_guide_"..cc.dataMgr.lobbyLoginData.userID, false) then
			if not self.bGuidShown then
				self.bGuidShown = true
				self:hideAllPopLayers()
				require("hall.view.BenefitGuideLayer").new():show(self)
			end
		end
	end)
	if app.isAccessAndroidStore ~= 0 then
		self.eventProtocol:addEventListener("PL_PHONE_LC_GETRECHARGEAWARDINFO_ACK_P", function() --首冲奖励
			print("event PL_PHONE_LC_GETRECHARGEAWARDINFO_ACK_P")
			local awardConfig = cc.dataMgr.rechargeAwardConfig
			if awardConfig == nil or awardConfig.bStartRechargeAward == 0 then return end
			local awardInfoList = awardConfig.rechargeAwardInfo
			local awardInfo = cc.dataMgr.rechargeAwardInfo
			if awardInfo == nil then return end

			local awardData
			for i = 1, #awardInfoList do
				local data = awardInfoList[i]
				if data.order == awardInfo.awardOrder then
					awardData = data
					break
				end
			end
			self.nodeRechargeAward:setVisible(awardData ~= nil)
		end)
	end

end

function HallScene:hideHallUI()
	hideAllBtns(self)
	self.nodeUserInfo:hide()

	if self.channelListLayer then
		self.channelListLayer:hide()
	end
	if self.gameListLayer then
		self.gameListLayer:hide()
	end
	if self.nodeRechargeAward then
		self.nodeRechargeAward:setVisible(false)
	end

	self.nPopLayers = self.nPopLayers + 1
end

function HallScene:showHallUI()
	if self.bTransFinished then
		showAllBtns(self)
	end
	self.nodeUserInfo:show()

	if self.inGameListUI == 1 then
		if self.gameListLayer and self.bTransFinished then
			self.gameListLayer:show()
		end
	else
		if self.channelListLayer then
			self.channelListLayer:show()
		end
	end
	if self.nodeRechargeAward then
--		self.nodeRechargeAward:setVisible(true)
	end
	if self.nPopLayers > 0 then
		self.nPopLayers = self.nPopLayers - 1
	else
		self.nPopLayers = 0
	end
end

function HallScene:hideNodeUserInfoUI()
	if self.nodeUserInfo then
		self.nodeUserInfo:getChildByName("ImageAvatar"):hide()
	end
end

function HallScene:backToGameListLayer()
	self:showGameListLayer()
	if self.nodeUserInfo then
		self.nodeUserInfo:getChildByName("ImageAvatar"):show()
	end
	self.inGameListUI = 1
	--[[2016.2.1 策划要求，大厅中跑马灯没有内容的时候隐藏
	if app.layBulletin ~= nil then
		app.layBulletin:setRemain(true)
	end
	--]]
end

function HallScene:showChannelLayer()
	if self.channelListLayer == nil then
		self.channelListLayer, self.channelListLayerCtrl = createLayer("ChannelListLayer")
   		self.channelListLayer:addTo(self, 10)
	end
	self.channelListLayer:show()
	self.channelListLayerCtrl:updateRoomList()
	self.gameListLayer:hide()
	self:hideNodeUserInfoUI()
	self.inGameListUI = 2
	--[[2016.2.1 策划要求，大厅中跑马灯没有内容的时候隐藏
	if app.layBulletin ~= nil then
		app.layBulletin:setRemain(false)
	end
	--]]
end

function HallScene:backToChannelLayer()
	self.roomLayer:hide()
	self.channelListLayer:show()
end

function HallScene:showGameListLayer()
	if self.gameListLayer ~= nil and self.bTransFinished then
		self.gameListLayer:show()
	end
	if self.channelListLayer ~= nil then
		self.channelListLayer:hide()
	end
	self.inGameListUI = 1
end

function HallScene:updateGameListUI()
	if self.gameListLayerCtrl~= nil then
		self.gameListLayerCtrl:updateGameListUI()
	end
end

function HallScene:showExchangeLayer()
	if self.exchangeLayer == nil then
		self.exchangeLayer = createLayer("ExchangeLayer")
		self.exchangeLayer:addTo(self, 20)
	end
	app.popLayer.showEx(self.exchangeLayer)
	self.exchangeLayer:setVisible(true)
end

function HallScene:showLotteryLayer()
	if self.lotteryLayer == nil  then
		self.lotteryLayer, self.lotteryLayerCtrl = createLayer("LotteryDrawLayer")
		self.lotteryLayer:addTo(self, 20)
	end
	app.popLayer.showEx(self.lotteryLayer)
	self.lotteryLayer:setVisible(true)
end

function HallScene:initView()

	if self.bInitView then
		return
	end

	print("<===HallScene:initView()")

	self.bInitView = true

	procUserInfo(self)

	--[[
	self.layIndividual = require("hall.view.IndividualLayer").new()
	self.laySignIn = require("hall.view.SignInLayer").new()
	self.layChangePsw = require("hall.view.ChangePswLayer").new()
	self.laySecondPsw = require("hall.view.SecondPswLayer").new()
	self.layPhoneBind = require("hall.view.PhoneBindLayer").new()
	self.layAvatarSel = require("hall.view.AvatarSelectLayer").new()
	self.layCoffer = require("hall.view.CofferLayer").new()
	self.layShop = require("hall.view.ShopLayer").new()
	self.layBenefit = require("hall.view.BenefitLayer").new()
	self.layVip = require("hall.view.VipLayer").new()
	--]]
	--[[2016.2.1 策划要求，大厅中跑马灯没有内容的时候隐藏
	if app.layBulletin == nil then
		local layBulletin = require("hall.view.BulletinLayer").new()
		layBulletin:init(self, true, 19, 500)
		app.layBulletin = layBulletin
	end
	--]]
	--[[
	--初始化个人信息
	self.layIndividual:init(self)
	self.layChangePsw:init(self)
	self.laySecondPsw:init(self)
	self.layPhoneBind:init(self)
	if app.sceneSwitcher.viewFlag == 1 then
		self.layPhoneBind:setVisible(true)
	end
	self.layAvatarSel:init(self)

	--初始化保险箱
	self.layCoffer:init(self)

	--初始化签到
	self.laySignIn:init(self)

	--初始化商城
	self.layShop:init(self)

	--初始化福利中心
	self.layBenefit:init(self)

	--初始化会员
	self.layVip:init(self, self)
	]]--
	--listenEvent(self)
end

function HallScene:onCreate()
	self.bTransFinished = false
	self.nPopLayers = 0
    print("---------HallScene:onCreate()")
   	cc.msgHandler:setPlayingScene(self)
	self.eventProtocol = require("framework.components.behavior.EventProtocol").new()

	cc.dataMgr.guiderFlag["newbie_guide"] = cc.UserDefault:getInstance():getBoolForKey("newbie_guide", true) and app.isAccessAppleStore ~= 0
	app.hallScene = self
	app.hallResNode = self:getResourceNode()
	self.name = "HallScene"
	app.runningScene = self


	local nodeUserInfo = self:getResourceNode():getChildByName("Node_userInfo")
	self.labelNickName = nodeUserInfo:getChildByName("Text_nicekName")
	self.labelBean = nodeUserInfo:getChildByName("BitmapFontLabel_bean")

	--头像
	self.imgAvatar = nodeUserInfo:getChildByName("ImageAvatar")


	self.inGameListUI = 1 --在选择游戏界面1 在选择房间界面为2

	self.bInitView = false

   	procBtns(self)

   	if cc.dataMgr.isCommonLogin then
		--self:initView()
	end
	
	listenConnectEvent(self)

    --选择游戏layer
    self.gameListLayer, self.gameListLayerCtrl = createLayer("GameListLayer")
	self.gameListLayer:addTo(self, 10):hide()
    --选择场次layer		
    self.channelListLayer, self.channelListLayerCtrl = nil, nil 
    --房间layer
    self.roomLayer, self.roomLayerCtrl = nil, nil 
    
    --弹出层 等玩家点击按钮后再初始化
   	self.settinglayer = nil
 	self.rankLayer = nil
   	self.lotteryLayer = nil

   	self.exchangeLayer = nil

	--注册按键消息
	self:registerKey()

	if cc.dataMgr.isRoomBackToHall then
		self:initView()
		self:showChannelLayer()

	end

	if cc.dataMgr.bHallShowChannel then
		cc.dataMgr.bHallShowChannel = false
		self:initView()
	end

	if app.sceneSwitcher.viewFlag ~= nil then
		--需要打开对应界面
		self:initView()
	end

	local bGuiderFlag = false
	for key, value in pairs(cc.dataMgr.guiderFlag) do
		if value then
			bGuiderFlag = true
			break
		end
	end

	

	-- 清理原有游戏对象
	for k,v in pairs(cc.dataMgr.hallClearObj) do
		if v and v.onExit then
			v:onExit()
		end
		cc.dataMgr.hallClearObj[k] = nil
	end
end

function HallScene:onEnter_()
	print("---------HallScene:onEnter_()")

	--app.shopLogic:reqGetOderInfoAliPay(1)

	cc.dataMgr.withoutRoomScene = false
	cc.dataMgr.castMultSetInfo.useCastMultSet = false
	app.castMultSet = nil
	cc.dataMgr.castMultSet = {}
	if cc.dataMgr.randMatch then
		cc.dataMgr.randMatch.matchInfo = nil
	end
end

function HallScene:onEnterTransitionFinish_()
	print("---------HallScene:onEnterTransitionFinish_()")
	--if app.isAccessAppleStore == 1 then
		playEnterSceneAnimation(self)
	--end

	if (not cc.dataMgr.isCommonLogin and not cc.dataMgr.isRoomBackToHall and cc.dataMgr.bFirstLogin) or cc.dataMgr.isReLogin then
		if cc.dataMgr.isReLogin then
			cc.dataMgr.reconnected = true
		end
		cc.dataMgr.isReLogin = false
		cc.dataMgr.bFirstLogin = false
		app.holdOn.showEx("Loging...", {
			delayTime = 0,
			parent = self,
			listener = function()
				app.msgBox.showMsgBoxEx({strMsg = "Connect failed,check network setup", funcOk = function()
					app.sceneSwitcher:enterScene("LoginScene")
				end, isHideX = true})
			end
		})
		
		local loginViewCtrller = require("app.ViewController.LoginViewCtrller").new()
		loginViewCtrller:startConnect()
	else
		self:initView()
	end

	if not bGuiderFlag then
		self:createPublicNoticeLayer()
	end
	
	cc.dataMgr.isRoomBackToHall = false
	cc.sceneTransFini = true
	self.bTransFinished = true
end

function HallScene:onExit_()
	print("---------HallScene:onExit_()")
	app.holdOn.hide()
	if self.layPhoneBind ~= nil then
		self.layPhoneBind:stopTimer()
	end
	app.shopLogic:stopTimer()
	self.eventProtocol:removeAllEventListeners()
	self.gameListLayerCtrl.gameAddLayerCtrller = nil
	
end

function HallScene:registerKey()
	local keyListener = cc.EventListenerKeyboard:create()
	local function onKeyRelease(code, event)
		print("EVENT_KEYBOARD_PRESSED, code:"..code)
		if code == cc.KeyCode.KEY_BACK or code == cc.KeyCode.KEY_BACKSPACE then

			--新手指引期间禁用
			for key, value in pairs(cc.dataMgr.guiderFlag) do
				if value then
					return
				end
			end

			if app.isDownloading then return end
			if self.nPopLayers < 0 then self.nPopLayers = 0 end
			if app.holdOn.holdOnLayer ~= nil then
				--app.holdOn:hide()
			elseif app.msgBox.root ~= nil then
				app.msgBox.hide()
			elseif self.nPopLayers > 0 then
				self:hideAllPopLayers()
			elseif self.channelListLayer ~= nil then
				self:backToGameListLayer()
				self.channelListLayer:removeFromParent()
				self.channelListLayer = nil
			else
				if not cc.sceneTransFini then return end
				local function onButtonClicked(event)
					app.audioPlayer:playClickBtnEffect()

					cc.msgHandler:disconnectFromLobby()
					cc.dataMgr.isChangeAccLogin = true
					app.sceneSwitcher:enterScene("LoginScene")
				end
				app.msgBox.showMsgBoxTwoBtn("Back to Main menu?", onButtonClicked)
			end
		end
	end
	keyListener:registerScriptHandler(onKeyRelease, cc.Handler.EVENT_KEYBOARD_RELEASED)
	local eventDispatch = self:getEventDispatcher()
	eventDispatch:addEventListenerWithSceneGraphPriority(keyListener, self)
end

function HallScene:hideAllPopLayers()
	self.layIndividual:setVisible(false)
	self.layChangePsw:setVisible(false)
	self.laySecondPsw:setVisible(false)
	self.layPhoneBind:setVisible(false)
	self.layAvatarSel:setVisible(false)
	self.layCoffer:setVisible(false)
	self.laySignIn:setVisible(false)
	self.layShop:setVisible(false)
	self.layBenefit:setVisible(false)
	self.layVip:setVisible(false)

	local gameAddCtr = self.gameListLayerCtrl.gameAddLayerCtrller
	if gameAddCtr ~= nil then
		local gameAddLayer = gameAddCtr.gameAddLayer
		if gameAddLayer ~= nil then
			gameAddLayer:hide()
		end
	end

	if self.roomLayer ~= nil then
		self.roomLayer:hide()
	end
	if self.settinglayer ~= nil then
		self.settinglayer:hide()
	end
	if self.rankLayer ~= nil then
		self.rankLayer:hide()
	end
	if self.lotteryLayer ~= nil then
		self.lotteryLayer:removeSelf()
		self.lotteryLayer = nil
	end
	if self.bindAccountLayer ~= nil then
		self.bindAccountLayer:removeFromParent()
		self.bindAccountLayer = nil
	end
	if self.exchangeLayer ~= nil then
		self.exchangeLayer:removeSelf()
		self.exchangeLayer = nil
	end

	if self.layRechargeAward ~= nil then
		self.layRechargeAward:setVisible(false)
	end

	self:showHallUI()
	self.nPopLayers = 0
end

function HallScene:createPublicNoticeLayer()
	if g_Platform_Win32 then
		return
	end
	if app.isAccessAppleStore == 0 then
		return
	end
	if not cc.dataMgr.bFirstLogin then
		return
	end
	local tm = os.date("*t")
	local timeNow = tm.year ..tm.month ..tm.day
	local savedTime = cc.UserDefault:getInstance():getStringForKey("savedTime", "")

	print("timeNow = " ..timeNow)
	print("savedTime = " ..savedTime)
	if timeNow ~= savedTime then
		local publicNoticeLayerCtrller = require("app.views.layers.PublicNoticeLayer").new()
		publicNoticeLayer = publicNoticeLayerCtrller:createLayer()
		publicNoticeLayerCtrller:initWebView(urls.publicNoticeUrl)
		display:getRunningScene():addChild(publicNoticeLayer, 500)
		cc.UserDefault:getInstance():setStringForKey("savedTime", timeNow)
	end
end

return HallScene