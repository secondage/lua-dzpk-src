local GameLayer = class("GameLayer",function()
    return cc.Layer:create()
end)

local scheduler = require("framework.scheduler")
local _attribute = require("dzpk.src.Attribute")
local _clockBorderRender = require("dzpk.src.ClockBorderRender")
local function S2CChair(chairid)
	if chairid < 0 then return -1 end

	local diff = chairid - cc.dataMgr.selectedChairID
	local pos = -1
	if diff == 0 then  pos = 0
	elseif diff == 1 or diff == -8 then pos = 1
	elseif diff == 2 or diff == -7 then pos = 2
	elseif diff == 3 or diff == -6 then pos = 3
	elseif diff == 4 or diff == -5 then pos = 4
	elseif diff == 5 or diff == -4 then pos = 5
	elseif diff == 6 or diff == -3 then pos = 6
	elseif diff == 7 or diff == -2 then pos = 7
	elseif diff == 8 or diff == -1 then pos = 8 end
	return pos
end

local function createBalanceCardFrameAnimation(parent, name, num, playTime, chair)
	local frames = display.newFrames(name.. "_%d.png", 0, num, false)
	local animation, firstFrame = display.newAnimation(frames, playTime / num)
	display.setAnimationCache(name .."Animation".. chair, animation)
	firstFrame:addTo(parent)
	firstFrame:hide()
	return firstFrame
end

local function createOpenCardsAnimation(self, name, num, playTime, index)
	local frames = display.newFrames(name.. "_%d.png", 0, num, false)
	local animation, firstFrame = display.newAnimation(frames, playTime / num)
	display.setAnimationCache(name ..index .. "Animation", animation)
	firstFrame:addTo(self)
	firstFrame:hide()
	return firstFrame
end

local _gamePublic = app.gamePublic

function GameLayer:ctor()
	print("GameLayer:ctor()")
	self.eventProtocol = require("framework.components.behavior.EventProtocol").new()
	self:listenEvent()

	if not app.test then
		self.bringBetLayer = self:createBringBetLayer():addTo(self, 30):hide()	-- 带入游戏豆设置层
	end

	if not app.test then
		self.addChipLayer = self:createAddChipLayer():addTo(self, 30):hide()	-- 补充筹码层
	end

	self.cardsLayer = self:createCardsLayers():addTo(self, 10) 		--添加手牌层

	self.chipMoveLayer = self:createChipMoveLayer():addTo(self, 11) 		--添加筹码层

	--聊天层
	----[[
	if not cc.dataMgr.isWatcher then
		self.chatLayer, self.chatLayerCtrl = self:createChatLayer()
		self.chatLayer:addTo(app.gameResNode, 60):hide()
	end--]]

	--设置层
	self.settingLayer = self:createSettingLayer():addTo(app.gameResNode, 60):hide()

	--详细信息层
	self.userInfoLayer = self:createUserInfoLayer():addTo(self, 12):hide()

	--特效层
	self.specialEffectLayer = self:createSpecialEffectLayer():addTo(self, 14):hide()
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(true)
	listener:registerScriptHandler(function (touch, event)
		 if self.specialEffectLayer:isVisible() then return true else return false end
	end, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(function (touch, event) end, cc.Handler.EVENT_TOUCH_MOVED)
	listener:registerScriptHandler(function (touch, event) end, cc.Handler.EVENT_TOUCH_ENDED)
	local eventDispatcher = self:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.specialEffectLayer)

	--任务层
	--if app.taskLayerCtrller and not cc.dataMgr.isWatcher then
	--	self.taskLayer = app.taskLayerCtrller:createLayer("paoyao/res/TaskLayer.csb"):addTo(app.gameResNode, 60)
	--	app.taskLayerCtrller:procGameTaskUI(app.seekChildByName(app.gameResNode, "Image_table_back"))
	--	app.taskLayerCtrller:updateTaskListUI()
	--end

	self.tablePlayer = {}
	for i = 0, _gamePublic.c_tablePlyNum - 1 do
		self.tablePlayer[i] = {}
		self.tablePlayer[i].playCurrency = 0 -- 携带的筹码用于游戏
	end

	self:initData()

	-- 创建获胜动画框
	self:createUserBalanceAnimation()

	-- 创建桌面动画框
	self:createPublicOpenCardsAnimation()

	if app.test then
		self:schedulerOp(0)

		-- 后续
		for i = 0, 4 do
			local card = _gamePublic.stCard:new()
			card:assignFromstCard({par = 5, color = 2})
			self.showPublicCards[self.showPublicCardsCount] = true
			local spCard = self.cardsLayer:drawOneCard(card, _attribute.PublicCardsPos[self.showPublicCardsCount], 0.85):hide()
			spCard:setScaleX(0.8)
			self.publicCards[self.showPublicCardsCount] = card
			self.showPublicCardsCount = self.showPublicCardsCount + 1
			local actionDelay = cc.DelayTime:create(i * 0.5)
			local callFun = cc.CallFunc:create(function ()
				spCard:show()
				app.gameAudioPlayer.playOpenCardEffect()
			end)
			spCard:runAction(cc.Sequence:create(actionDelay, callFun, nil))
			self.cardsLayer:insertPublicCardToTable(spCard)

		end

		local function onKeyReleased(keyCode)
			if keyCode == cc.KeyCode.KEY_F1 then
				self.specialEffectLayer:show()
				for i = 0, 8 do
					self.specialEffectLayer:setWinUserByChair(i)
				end
				self.specialEffectLayer:setUserStencil()
				--self.specialEffectLayer:clearUserStencil()
				self.specialEffectLayer:playAnimation( _gamePublic.eCards_Type.eType_ThreeTwo)
				self.specialEffectLayer:drawPublicCards()
				local FrameText = "goldFrame1"
				--self.userBalanceFrame[0].frame1:playAnimationForever(display.getAnimationCache(FrameText.. "Animation" .. 0))
				--self.userBalanceFrame[1].frame1:playAnimationForever(display.getAnimationCache(FrameText.. "Animation" .. 1))
				dump(self.OtherOpenCardsFrame)
				self.OtherOpenCardsFrame[1][0]:playAnimationOnce(display.getAnimationCache("endOpenCards" .. 1 * 10 + 0 .. "Animation"), {--[[hide = 1, onComplete = complete]]})
			elseif keyCode == cc.KeyCode.KEY_F2 then
				self.specialEffectLayer:show()
				for i = 0, 8 do
					self.specialEffectLayer:setWinUserByChair(i)
				end
				self.specialEffectLayer:setUserStencil()
				--self.specialEffectLayer:clearUserStencil()
				self.specialEffectLayer:playAnimation( _gamePublic.eCards_Type.eType_Four)
				local FrameText = "goldFrame2"
				self.userBalanceFrame[2].frame2:playAnimationForever(display.getAnimationCache(FrameText.. "Animation" .. 2))
				self.userBalanceFrame[3].frame2:playAnimationForever(display.getAnimationCache(FrameText.. "Animation" .. 3))
			elseif keyCode == cc.KeyCode.KEY_F3 then
				self.specialEffectLayer:show()
				for i = 0, 8 do
					self.specialEffectLayer:setWinUserByChair(i)
				end
				self.specialEffectLayer:setUserStencil()
				--self.specialEffectLayer:clearUserStencil()
				self.specialEffectLayer:playAnimation( _gamePublic.eCards_Type.eType_SameLoong)
			elseif keyCode == cc.KeyCode.KEY_F4 then
				self.specialEffectLayer:show()
				for i = 0, 8 do
					self.specialEffectLayer:setWinUserByChair(i)
				end
				self.specialEffectLayer:setUserStencil()
				--self.specialEffectLayer:clearUserStencil()
				self.specialEffectLayer:playAnimation( _gamePublic.eCards_Type.eType_GodSameLoong)
			elseif keyCode == cc.KeyCode.KEY_F6 then
				self.specialEffectLayer:show()
				for i = 0, 8 do
					self.specialEffectLayer:setWinUserByChair(i)
				end
				self.specialEffectLayer:setUserStencil()
				--self.specialEffectLayer:clearUserStencil()
				self.specialEffectLayer:playAnimation( _gamePublic.eCards_Type.eType_SameColor)
			end
		end

		local listener = cc.EventListenerKeyboard:create()
		listener:registerScriptHandler(onKeyReleased, cc.Handler.EVENT_KEYBOARD_RELEASED )

		local eventDispatcher = self:getEventDispatcher()
		eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

		for i = 0, 8 do
			app.gameViewController.showTalkFrame[i]:show()
		end
	end
end

function GameLayer:createUserBalanceAnimation()
	self.userBalanceFrame = {}
	for i = 0,  _gamePublic.c_tablePlyNum - 1 do
		self.userBalanceFrame[i] = {}
		local FrameText
		FrameText = "goldFrame1"
		self.userBalanceFrame[i].frame1 = createBalanceCardFrameAnimation(self, FrameText, 10, 1, i)
		:pos(_attribute.gameUserPos[i].x, _attribute.gameUserPos[i].y)
		FrameText = "goldFrame2"
		self.userBalanceFrame[i].frame2 = createBalanceCardFrameAnimation(self, FrameText, 10, 1, i)
		:pos(_attribute.gameUserPos[i].x, _attribute.gameUserPos[i].y)
	end
end

function GameLayer:createSelfOpenCardsAnimation()
	print"GameLayer:createSelfOpenCardsAnimation()"
	self.selfOpenCardsFrame = {}
	self.selfOpenCardsFrame[0] = createOpenCardsAnimation(self, "dealOpenCards", 5, 0.4, 0)
	local endPosX, endPosY = app.runningScene:GetCardPos(0, 0)
	self.selfOpenCardsFrame[0]:pos(endPosX, endPosY)
	self.selfOpenCardsFrame[1] = createOpenCardsAnimation(self, "dealOpenCards", 5, 0.4, 1)
	endPosX, endPosY = app.runningScene:GetCardPos(0, 1)
	self.selfOpenCardsFrame[1]:pos(endPosX, endPosY)
end

function GameLayer:createOtherOpenCardsAnimation()
	self.OtherOpenCardsFrame = {}
	for i = 1,  _gamePublic.c_tablePlyNum - 1 do
		self.OtherOpenCardsFrame[i] = {}
		self.OtherOpenCardsFrame[i][0] = createOpenCardsAnimation(self, "endOpenCards", 9, 0.72, i * 10 + 0)
		local endPosX, endPosY = app.runningScene:GetCardPos(i, 0)
		self.OtherOpenCardsFrame[i][0]:pos(endPosX - 2, endPosY + 2)
		self.OtherOpenCardsFrame[i][1] = createOpenCardsAnimation(self, "endOpenCards", 9, 0.72, i * 10 + 1)
		endPosX, endPosY = app.runningScene:GetCardPos(i, 1)
		self.OtherOpenCardsFrame[i][1]:pos(endPosX - 2, endPosY + 2)
	end
end

function GameLayer:createPublicOpenCardsAnimation()
	self.publicOpenCardsFrame = {}
	for i = 0, 4 do
		self.publicOpenCardsFrame[i] = createOpenCardsAnimation(self, "publicOpenCards", 5, 0.4, i)
		self.publicOpenCardsFrame[i]:pos(_attribute.PublicCardsPos[i].x, _attribute.PublicCardsPos[i].y)
	end
end

function GameLayer:initData()
	self.bAutoBringBet = false
	self.bankerChair = -1

	for i = 0, _gamePublic.c_tablePlyNum - 1 do
		self.tablePlayer[i].nCurBet = 0					-- 本轮下注数
		self.tablePlayer[i].curBet = 0
		self.tablePlayer[i].bet = 0
		self.tablePlayer[i].oper = 0
		--self.tablePlayer[i].chipAnimateDelayTime = 0	-- 筹码动画运行时间
		self.tablePlayer[i].endScore = 0				-- 结算得分
		self.tablePlayer[i].isAllIn = false				-- 是否allin
		self.tablePlayer[i].nTotalBet = 0 -- 本局下注总数
	end

	--self.waitingMs = -1
	self.round = 0
	self.maxRound = 0
	self.curBet = 0
	self.totalBet = 0
	self.showPublicCards = {}
	for i = 0, 4 do
		self.showPublicCards[i] = false
	end
	self.showPublicCardsCount = 0

	self.lastUserOp = 0
	self.bPreinstall = {}		-- 预设 下标 0：看或弃， 1：跟注， 2：跟任何
	for i =0, 1 do
		self.bPreinstall[i] = false
	end

	self.addBetValue = 0

	self.isAllIn = false		-- 自己是否Allin
	self.isGiveUp = false		-- 自己是否弃牌
	self.lastAllGiveUp = true	-- 前面的玩家都弃牌
	self.lastAllPass = true	-- 前面的玩家都让牌

	self.betCount = 0

	self.endType = -1

	self.maxBetValue = 0				-- 加注框最大可以加注

	self.splitBet = {}				-- 保存每个筹码池的数据

	self.chipPoolInfo = {}
	for i = 0, 9 do
		self.chipPoolInfo[i] = {}
		self.chipPoolInfo[i].value = 0
	end
	self.OpTime = 0

	self.allBalanceUser = {}			-- 保存所有结算玩家的座位号
	self.betPoolWinUser = {}			-- 保存筹码池赢家座位号

	self.oldHandCards = {}
	for i = 0, _gamePublic.c_tablePlyNum - 1 do
		self.oldHandCards[i] = {}
	end
	self.publicCards = {}

	app.bGaming = false		--

	self.ChairIdInGaming = {}			-- 正在游戏中的玩家
end

function GameLayer:createBringBetLayer()
	return require(app.codeSrc .."BringBetUI"):createBringBetUI()
end

function GameLayer:createAddChipLayer()
	return require(app.codeSrc .."AddChipLayer"):createAddChipLayer()
end

function GameLayer:createUserInfoLayer()
	return require(app.codeSrc .."UserInfoLayer"):new():createUserInfoLayer()
end

function GameLayer:createChipMoveLayer()
	return require(app.codeSrc .."ChipMoveLayer").new()
end

function GameLayer:createSettingLayer()
	return require("publiclayers.SettingLayer"):createLayer("setting.csb")
end

function GameLayer:createChatLayer()
	local chatLayerCtrl = require("publiclayers.ChatLayer")
	return chatLayerCtrl:createLayer(app.codeRes .. "ChatLayer.csb", app.gameViewController.showTalkFrame), chatLayerCtrl
end

function GameLayer:createTestLayer()
    return require(app.codeSrc .."Test").new()
end

function GameLayer:createSpecialEffectLayer() --吃碰杠按钮 以及其他特效
	return  require(app.codeSrc .."SpecialEffectLayer").new():createSpecialEffectLayer()
end

function GameLayer:createCardsLayers()
	return require(app.codeSrc .."CardsLayer").new()
end

function GameLayer:createCardsTouchLayers()
	return require(app.codeSrc .."CardsTouchLayer").new()
end

function GameLayer:createResultLayer()
	local resultLayerCtrl = require(app.codeSrc .."ResultLayer")
	return resultLayerCtrl:createLayer(), resultLayerCtrl
end

---------------------------处理model通知过来的事件 start---------------------------
function GameLayer:listenEvent() --监听小游戏内部协议
	print("GameLayer:listenEvent()")
    self.eventProtocol:addEventListener("SC_POKE_DEAL", handler(self, GameLayer.onSC_POKE_DEAL))
	self.eventProtocol:addEventListener("SC_POKE_OP_NOT", handler(self, GameLayer.onSC_POKE_OP_NOT))
	self.eventProtocol:addEventListener("SC_INIT_DATA", handler(self, GameLayer.onSC_INIT_DATA))
    self.eventProtocol:addEventListener("SC_GAME_RESULT", handler(self, GameLayer.onSC_GAME_RESULT))
    self.eventProtocol:addEventListener("SC_BET", handler(self, GameLayer.onSC_BET))
	self.eventProtocol:addEventListener("SC_POKE_OP_REQ", handler(self, GameLayer.onSC_POKE_OP_REQ))
	self.eventProtocol:addEventListener("SC_SPLIT_BET_DATA", handler(self, GameLayer.onSC_SPLIT_BET_DATA))
	self.eventProtocol:addEventListener("SC_POKE_HAND_NOT", handler(self, GameLayer.onSC_POKE_HAND_NOT))
    self.eventProtocol:addEventListener("GC_GAME_START_P", handler(self, GameLayer.onGC_GAME_START_P))
end

function GameLayer:onGC_GAME_START_P()--游戏开始表现
	--重置UI表现
    app.gameViewController:resetUIAfterStart()
    cc.dataMgr.gamingState = true
end

function GameLayer:onStartGame()
	-- 清除牌型，显示昵称
	for i = 0, _gamePublic.c_tablePlyNum - 1 do
		if app.gameViewController.EndTypeImg ~= nil and  app.gameViewController.EndTypeImg[i] ~= nil then
			app.gameViewController.EndTypeImg[i]:removeSelf()
			app.gameViewController.EndTypeImg[i] = nil
		end

		local _userlayer = app.runningScene.gameUsersUI[i]
		local _userPanel = _userlayer:getChildByName("Panel_user_info")
		local _name = _userPanel:getChildByName("Text_name")
		_name:show()
		local _status = _userPanel:getChildByName("Image_status")
		_status:hide()

		-- 清除结算分数
		if app.runningScene.winFrame ~= nil and app.runningScene.winFrame[i] ~= nil then
			app.runningScene.winFrame[i]:hide()
		end
		if app.runningScene.loseFrame ~= nil and app.runningScene.loseFrame[i] ~= nil then
			app.runningScene.loseFrame[i]:hide()
		end

		self.userBalanceFrame[i].frame1:stopAllActions()
		:hide()
		self.userBalanceFrame[i].frame2:stopAllActions()
		:hide()
	end
	app.gameViewController.EndTypeImg = {}
	app.bGaming = true
	if app.runningScene.StartRoundHandler then scheduler.unscheduleGlobal(app.runningScene.StartRoundHandler) app.runningScene.StartRoundHandler = nil end
	app.gameViewController.waitStart:hide()

	-- 清除上一轮所有扑克
	app.gameLayer.cardsLayer:removeAllCards()
end

function GameLayer:onSC_POKE_DEAL(event)
	print"GameLayer:onSC_POKE_DEAL"

	local data = event.data
	--StopAllClock();

	if data.round ~= 1 and self.round == data.round - 1 then
		self:OnBetRoundEnd()
	end
	if self.round ~= data.round then
		for i = 0, _gamePublic.c_tablePlyNum - 1 do
			self.tablePlayer[i].curBet = 0
		end
	end
	self.round = data.round

	if self.round == 1 then
		--第一轮
		local chair = S2CChair(data.chair)

		local mapIndexChair = {}
		local m = 0
		for i = 0, _gamePublic.c_tablePlyNum - 1 do
			if app.runningScene.tableUsersByChair ~= nil and app.runningScene.tableUsersByChair[i] ~= nil then
				mapIndexChair[i] = m
				m = m + 1
			end
		end

		for i = 0, table.nums(data.allChairs) - 1 do
			local ch = S2CChair(data.allChairs[i])
			self.ChairIdInGaming[table.nums(self.ChairIdInGaming)] = ch
			local beginPos = {x = 568, y = 500}
			if ch ~= chair and app.runningScene.tableUsersByChair ~= nil and app.runningScene.tableUsersByChair[ch] ~= nil then
				local card = _gamePublic.stCard:new()
				card.par = 0
				card.color = 0
				local spCard = self.cardsLayer:drawOneCard(card, beginPos, 0.8)
				spCard:setScaleX(0.75)
				spCard:setOpacity(0)

				local actionDelay = cc.DelayTime:create(((i * table.nums(mapIndexChair) + mapIndexChair[ch]) * 30)/ 1000)
				local endPosX, endPosY = app.runningScene:GetCardPos(ch, 0)
				local moveAction = cc.MoveTo:create(0.5, cc.p(endPosX, endPosY))
				--local scaleAction = cc.ScaleTo:create(0.5, 0.75)
				local fadeAction = cc.FadeTo:create(0.5, 255)
				local spawnAction = cc.Spawn:create(moveAction, fadeAction)
				local callFun = cc.CallFunc:create(function ()
					-- 播放音效
					app.gameAudioPlayer.playDealcardEffect()

					-- 缩小到右下角
					local ScaleAction = cc.ScaleTo:create(0.4, 0.3)
					local MoveAction = cc.MoveTo:create(0.4, cc.p(endPosX + 40, endPosY - 30))
					local SpawnAction = cc.Spawn:create(ScaleAction, MoveAction)
					spCard:runAction(SpawnAction)
				end)
				spCard:runAction(cc.Sequence:create(actionDelay, spawnAction, callFun, nil))
				self.cardsLayer:insertHandCardToTable(ch, spCard)


				-- 第二张手牌
				local spCard2 = self.cardsLayer:drawOneCard(card, beginPos, 0.8)
				spCard2:setScaleX(0.75)
				spCard2:setOpacity(0)
				local actionDelay2 = cc.DelayTime:create(((i * table.nums(mapIndexChair) + mapIndexChair[ch]) * 30 + 60)/ 1000)
				local endPosX2, endPosY2 = app.runningScene:GetCardPos(ch, 1)
				local moveAction2 = cc.MoveTo:create(0.5, cc.p(endPosX2, endPosY2))
				--local scaleAction2 = cc.ScaleTo:create(0.5, 0.75)
				local fadeAction2 = cc.FadeTo:create(0.5, 255)
				local spawnAction2 = cc.Spawn:create(moveAction2, fadeAction2)
				local callFun2 = cc.CallFunc:create(function ()
					-- 播放音效
					app.gameAudioPlayer.playDealcardEffect()

					-- 缩小到右下角
					local ScaleAction = cc.ScaleTo:create(0.4, 0.3)
					local MoveAction = cc.MoveTo:create(0.4, cc.p(endPosX2 + 25, endPosY2 - 30))
					local SpawnAction = cc.Spawn:create(ScaleAction, MoveAction)
					spCard2:runAction(SpawnAction)
				end)
				spCard2:runAction(cc.Sequence:create(actionDelay2, spawnAction2, callFun2, nil))
				self.cardsLayer:insertHandCardToTable(ch, spCard2)
			else
				for j = 0, table.nums(data.cards) - 1 do
					local card = _gamePublic.stCard:new()
					card.par = 0
					card.color = 0
					local spCard = self.cardsLayer:drawOneCard(card, beginPos, 0.8)
					spCard:setScaleX(0.75)
					spCard:setOpacity(0)
					local actionDelay = cc.DelayTime:create(((i * table.nums(mapIndexChair) + mapIndexChair[chair]) * 30 + j * 60)/ 1000)
					local endPosX, endPosY = app.runningScene:GetCardPos(chair, j)
					local moveAction = cc.MoveTo:create(0.5, cc.p(endPosX, endPosY))
					local fadeAction = cc.FadeTo:create(0.5, 255)
					local spawnAction = cc.Spawn:create(moveAction, fadeAction)
					local callFun = cc.CallFunc:create(function ()
						-- 播放音效
						app.gameAudioPlayer.playDealcardEffect()

						local function complete()
							local openCard = _gamePublic.stCard:new()
							openCard:assignFromstCard(data.cards[j])
							local spOpenCard = self.cardsLayer:drawOneCard(openCard, {x = endPosX, y = endPosY}, 0.8)
							spOpenCard:setScaleX(0.75)
							self.cardsLayer:insertHandCardToTable(chair, spOpenCard)
						end
						self.selfOpenCardsFrame[j]:playAnimationOnce(display.getAnimationCache("dealOpenCards" .. j .. "Animation"), {hide = 1, onComplete = complete})
						spCard:removeSelf()
					end)
					spCard:runAction(cc.Sequence:create(actionDelay, spawnAction, callFun, nil))
				end
			end
		end

		-- 判断自己是否在游戏中
		self.isSelfInGaming = false
		--dump(self.ChairIdInGaming)
		for i = 0, table.nums(self.ChairIdInGaming) - 1 do
			if self.ChairIdInGaming[i] == 0 then
				self.isSelfInGaming = true
			end
		end

		-- 显示桌子信息
		----[[
		app.gameViewController.imgBetFrame:show()
		app.gameViewController.imgBetFrame:getChildByName("BitmapFontLabel_dizhu_num"):setString(string.format("bet: %d", self.baseBet))
		--]]
		-- 显示庄家
		if _gamePublic:valid_chair(self.bankerChair) then
			if app.runningScene.gameUsersUI ~= nil and app.runningScene.gameUsersUI[self.bankerChair] ~= nil then
				local _userlayer = app.runningScene.gameUsersUI[self.bankerChair]
				_userlayer:getChildByName("Panel_user_info"):getChildByName("Image_banker"):show()
			end
		end
	else
		-- 后续桌面扑克
		local tableDelay = cc.DelayTime:create(1)
		local tableFunc = cc.CallFunc:create(function ()
			for i = 0, table.nums(data.cards) - 1 do
				local card = _gamePublic.stCard:new()
				card:assignFromstCard(data.cards[i])
				self.showPublicCards[self.showPublicCardsCount] = true
				local spCard = self.cardsLayer:drawOneCard(card, _attribute.PublicCardsPos[self.showPublicCardsCount], 0.85):hide()
				spCard:setScaleX(0.8)
				self.publicCards[self.showPublicCardsCount] = card
				local actionDelay = cc.DelayTime:create(i * 0.5)
				local count = self.showPublicCardsCount
				local callFun = cc.CallFunc:create(function ()
					app.gameAudioPlayer.playOpenCardEffect()
					local function complete()
						spCard:show()
					end
					print("后续桌面扑克:self.showPublicCardsCount = " .. self.showPublicCardsCount)
					self.publicOpenCardsFrame[count]:playAnimationOnce(display.getAnimationCache("publicOpenCards" .. count .. "Animation"), {hide = 1, onComplete = complete})
				end)
				spCard:runAction(cc.Sequence:create(actionDelay, callFun, nil))
				self.cardsLayer:insertPublicCardToTable(spCard)
				self.showPublicCardsCount = self.showPublicCardsCount + 1
			end
		end)
		self:runAction(cc.Sequence:create(tableDelay, tableFunc, nil))
	end
	self.curBet = 0
end

function GameLayer:onSC_POKE_OP_NOT(event)
	local data = event.data
	--dump(data)
	self:unSchedulerOp()
	self.curBet = data.curBet
	self.totalBet= data.totalBet
	local op = data.op
	local chair = S2CChair(data.chair)
	if not _gamePublic:valid_chair(chair) then
		return
	end

	if not cc.dataMgr.isWatcher then
		if chair == 0 then				-- 标记自已上一轮Allin情况
			if _gamePublic:_and(op, _gamePublic.eOp_Type.eOp_Suoha) > 0 then
				self.isAllIn = true
			end
		else							-- 标记上家弃牌、让牌情况
			if _gamePublic:_and(op, _gamePublic.eOp_Type.eOp_Giveup) == 0 then
				self.lastAllGiveUp = false
			end
			if _gamePublic:_and(op, _gamePublic.eOp_Type.eOp_PassBet) == 0 then
				self.lastAllPass = false
			end
		end
		app.gameViewController:showOpBtn(0)
	end

	if chair == 0 then
		app.gameViewController:OnOperCompleted()
	end

	app.gameViewController.textChipNum:setString(string.format("pool: %d", self.totalBet))

	-- 绘制动画
	self.betCount = self.betCount + 1
	self:OnStakeNotify(chair, data.op, data.bet, self.betCount)
	local _userlayer = app.runningScene.gameUsersUI[chair]
	if app.runningScene.gameUsersUI == nil or app.runningScene.gameUsersUI[chair] == nil then
		return
	end
	local PanelUserInfo = _userlayer:getChildByName("Panel_user_info")
	local selfChipFrame = PanelUserInfo:getChildByName("Image_weight_frame")
	local chipNum = selfChipFrame:getChildByName("BitmapFontLabel_jiazhu_num")
	local imgGiveUp = _userlayer:getChildByName("Image_qi_pai")
	local res = _gamePublic:_or(_gamePublic.eOp_Type.eOp_AddBet, _gamePublic.eOp_Type.eOp_FollowBet)
	res = _gamePublic:_or(res, _gamePublic.eOp_Type.eOp_Suoha)
	print("gamelayer op not res = " ..res)
	if _gamePublic:_and(op, res) > 0 then
		self.tablePlayer[chair].bet = data.bet
		self.tablePlayer[chair].curBet = data.curBet

		if data.curBet > 0 then
			-- 播放音效
			app.gameAudioPlayer.playBetEffect()
			local tmpNode = nil
			local color = nil
			tmpNode, color =  self.chipMoveLayer:renderOneChipMove(data.curBet, _attribute.gameUserPos[chair], app.runningScene.gameUserCurBetPos[chair])
			local delay = cc.DelayTime:create(0.3)
			local callFunc = cc.CallFunc:create(function ()
				chipNum:setString(string.format("%d", data.curBet))
				selfChipFrame:show()

				--dump(self.chipMoveLayer.userChipList)

				-- 删除飞行的临时筹码
				self.chipMoveLayer:removeChipArrayNode(tmpNode)

				-- 删除原筹码框中的筹码
				self.chipMoveLayer:removeChipArrayByChair(chair)

				-- 创建新的筹码
				self.chipMoveLayer:createOneChipForChair(chair, color, app.runningScene.gameUserCurBetPos[chair])
			end)
			self.chipMoveLayer:runAction(cc.Sequence:create(delay, callFunc, nil))
		end

		if cc.dataMgr.isWatcher then
			--self.tablePlayer[chair].curBet = 0
			self.tablePlayer[chair].nTotalBet = data.bet
		end
	elseif _gamePublic:_and(op, _gamePublic.eOp_Type.eOp_Giveup) > 0 then
		imgGiveUp:show()

		-- 隐藏思考中，显示昵称
		local _userPanel = _userlayer:getChildByName("Panel_user_info")
		local _name = _userPanel:getChildByName("Text_name")
		_name:show()
		local _status = _userPanel:getChildByName("Image_status")
		_status:hide()

		-- 隐藏个人特效
		self.userBalanceFrame[chair].frame1:stopAllActions()
		:hide()
		self.userBalanceFrame[chair].frame2:stopAllActions()
		:hide()

		if chair ~= 0 then
			local cardsArray = self.cardsLayer.handCardsList[chair]
			if cardsArray then
				for i = 0, table.nums(cardsArray) - 1 do
					if cardsArray[i] then
						self.cardsLayer:setPokeColor(cardsArray[i], cc.c3b(0x55, 0x55, 0x55))

						-- 弃牌动画
						local moveAction = cc.MoveTo:create(0.4, cc.p(568, 350))
						local scaleAction = cc.ScaleTo:create(0.4, 0.3)
						local fadeAction = cc.FadeTo:create(0.4, 0)
						local spawnAction = cc.Spawn:create(moveAction, scaleAction, fadeAction)
						cardsArray[i]:runAction(spawnAction)
					end
				end
				local delay = cc.DelayTime:create(0.3 + 0.05)
				local callFunc = cc.CallFunc:create(function ()
					self.cardsLayer:removeHandCards(chair)
				end)
				self:runAction(cc.Sequence:create(delay, callFunc, nil))
			end
		else
			imgGiveUp:hide()
			self.spSelfGiveUp:show()
			--[[local cardsArray = self.cardsLayer.handCardsList[chair]
			if cardsArray then
				for i = 0, table.nums(cardsArray) - 1 do
					if cardsArray[i] then
						self.cardsLayer:setPokeColor(cardsArray[i], cc.c3b(0x55, 0x55, 0x55))
					end
				end
			end
			--]]
			local card = _gamePublic.stCard:new()
			card.par = 0
			card.color = 0
			for i = 0, 1 do
				local spCard = self.cardsLayer:drawOneCard(card, _attribute.gameUserPos[chair], 0.8)
				local moveAction = cc.MoveTo:create(0.4, cc.p(568, 350))
				local scaleAction = cc.ScaleTo:create(0.4, 0.3)
				local fadeAction = cc.FadeTo:create(0.4, 0)
				local spawnAction = cc.Spawn:create(moveAction, scaleAction, fadeAction)
				local callFunc = cc.CallFunc:create(function ()
					spCard:removeSelf()
				end)
				spCard:runAction(spawnAction)
			end

			app.bGaming = false

			self.isGiveUp = true
		end
	else
		if cc.dataMgr.isWatcher then
			--self.tablePlayer[chair].curBet = 0
			self.tablePlayer[chair].nTotalBet = data.bet
		end
	end

	if chair == 0 then
		app.gameViewController.selfTotalBet:setString("已押注:" .. self.tablePlayer[0].nTotalBet)
		:show()
	end
end

function GameLayer:onSC_INIT_DATA(event)
	print"GameLayer:onSC_INIT_DATA"
	app.runningScene.initGameStateUI(3)
	local data = event.data
	--dump(data)
	app.bGaming = true
	-- 设置庄家
	local bankerChair = S2CChair(data.banker)
	if app.runningScene.gameUsersUI == nil then
		return
	end
	local _userlayer = app.runningScene.gameUsersUI[bankerChair]
	if _userlayer == nil then
		return
	end
	_userlayer:getChildByName("Panel_user_info"):getChildByName("Image_banker"):show()

	-- 设置bet
	self.baseBet = data.bet
	self.curBet = data.curBet
	self.totalBet = data.totalBet

	-- 显示大小盲注信息
	----[[
	app.gameViewController.imgBetFrame:show()
	app.gameViewController.imgBetFrame:getChildByName("BitmapFontLabel_dizhu_num"):setString(string.format("bet: %d", self.baseBet))
	--]]
	-- 设置数据
	for i = 0, table.nums(data.data) - 1 do
		local chairID = S2CChair(data.data[i].chair)
		self.ChairIdInGaming[table.nums(self.ChairIdInGaming)] = chairID
		self:OnInitUserData(chairID, data.data[i])
	end

	-- 判断自己是否在游戏中
	self.isSelfInGaming = false
	for i = 0, table.nums(self.ChairIdInGaming) - 1 do
		if self.ChairIdInGaming[i] == 0 then
			self.isSelfInGaming = true
		end
	end

	-- 桌面的牌
	for i = 0, table.nums(data.TableCards) - 1 do
		local spCard = self.cardsLayer:drawOneCard(data.TableCards[i], _attribute.PublicCardsPos[i], 0.85):show()
		spCard:setScaleX(0.8)
		self.cardsLayer:insertPublicCardToTable(spCard)
		self.publicCards[i] = data.TableCards[i]

		-- 播放音效
		app.gameAudioPlayer.playOpenCardEffect()
	end
	self.showPublicCardsCount = table.nums(data.TableCards)


	-- 分池
	for i = 0, 9 do
		self.splitBet[i] = 0
		if data.SplitBet[i] ~= nil then
			self.splitBet[i] = data.SplitBet[i]
		end
	end
	for i = 0, 9 do
		if self.splitBet[i] > 0 then
			local endPos = {x = _attribute.ChipPoolPos[i].x - 55, y = _attribute.ChipPoolPos[i].y }
			-- 创建新的筹码
			self.chipMoveLayer:createChipsForPoolIndex(i, endPos)
			--self.chipPoolInfo[i].node = self.chipMoveLayer:createChipArray(self.splitBet[i], endPos)
			self.chipPoolInfo[i].value = self.splitBet[i]
			app.gameViewController.chipPoolFrame[i]:show()
			local num = app.gameViewController.chipPoolFrame[i]:getChildByName("BitmapFontLabel_chip_num")
			num:setString(string.format("%d", self.splitBet[i]))
		end
	end

	-- 隐藏等待开始显示
	app.gameViewController.waitStart:hide()
	app.gameViewController.chipImg:hide()
	app.gameViewController.chipFrame:hide()
	app.gameViewController.chipFrame:stopAllActions()
end

function GameLayer:OnInitUserData(chair, userdata)
	self.tablePlayer[chair].nCurBet = userdata.bet
	self.tablePlayer[chair].nTotalBet = userdata.bet
	if userdata.status == 2 then
		self.tablePlayer[chair].oper = _gamePublic.eOp_Type.eOp_Giveup
	else
		self.tablePlayer[chair].oper = _gamePublic.eOp_Type.eOp_FollowBet
	end
	self:OnInitHandCadrs(chair, userdata.handCards)
end

function GameLayer:OnInitHandCadrs(chair, handCards)
	app.pokePlay[chair].hand = {}
	for i = 0, table.nums(handCards) - 1 do
		app.pokePlay[chair].hand[i] = handCards[i]
		local pos = {}
		pos.x, pos.y = app.runningScene:GetCardPos(chair, i)
		if pos.x == nil or pos.y == nil then
			return
		end
		local spCard
		if chair ~= 0 then
			if i == 0 then
				pos.x = pos.x + 40
				pos.y = pos.y - 30
			elseif i == 1 then
				pos.x = pos.x + 25
				pos.y = pos.y - 30
			end
			if table.nums(handCards) > 1 and _gamePublic:_and(self.tablePlayer[chair].oper, _gamePublic.eOp_Type.eOp_Giveup) > 0 then

			else
				spCard = self.cardsLayer:drawOneCard( handCards[i], pos, 0.3)
			end
		else
			if table.nums(handCards) > 1 and _gamePublic:_and(self.tablePlayer[chair].oper, _gamePublic.eOp_Type.eOp_Giveup) > 0 then

			else
				spCard = self.cardsLayer:drawOneCard( handCards[i], pos, 0.8)
				spCard:setScaleX(0.75)
			end
		end

		if table.nums(handCards) > 1 and _gamePublic:_and(self.tablePlayer[chair].oper, _gamePublic.eOp_Type.eOp_Giveup) > 0 then
			self.cardsLayer:setPokeColor(spCard, cc.c3b(0x55, 0x55, 0x55))

			local _userlayer = app.runningScene.gameUsersUI[chair]
			local imgGiveUp = _userlayer:getChildByName("Image_qi_pai")
			imgGiveUp:show()
			if chair == 0 then
				imgGiveUp:hide()
				self.spSelfGiveUp:show()
			end
		end
		self.cardsLayer:insertHandCardToTable(chair, spCard)
	end
	app.pokePlay[chair]:CaclType()
end

function GameLayer:onSC_GAME_RESULT(event)
	app.runningScene.initGameStateUI(4)
	print"GameLayer:onSC_GAME_RESULT"
	local data = event.data
	--dump(data)
	--self.waitingMs = -1


	--筹码合并
	--local roundEndTime = self:OnBetRoundEnd()
	self:OnBetRoundEnd()

	--结束操作
	app.gameViewController:OnOperCompleted()

	-- 隐藏扑克操作按钮
	app.gameViewController.operateNode:hide()
	app.gameViewController.preinstallNode:hide()

	self.endType = data.overA

	--清除手牌
	--self.cardsLayer:removeAllCards()

	self.showPublicCardsCount = 0

	app.gameViewController.imgBetFrame:hide()
	for k, v in pairs(data.Result) do
		local chair = S2CChair(v.chair)
		if _gamePublic:valid_chair(chair) then
			self.allBalanceUser[table.nums(self.allBalanceUser)] = chair
			self.tablePlayer[chair].endScore = v.score
		end
	end


	for i = 0, 9 do
		if data.OrderList[i] ~= nil then
			local winUserChair = {}
			for j = 0, table.nums(data.OrderList[i]) - 1 do
				winUserChair[j] = S2CChair(data.OrderList[i][j])
			end
			self:AddBetPoolWinUser(i, winUserChair)
		end
	end

	-- 先画出特效层扑克
	self.specialEffectLayer:clearPublicCards()
	self.specialEffectLayer:drawPublicCards()

	local delayAction = cc.DelayTime:create(1.5)
	local callFunc = cc.CallFunc:create(function ()
		self:playBetWinUserAnimation()

		self:playPokeTypeAnimation()
	end)
	self:runAction(cc.Sequence:create(delayAction, callFunc, nil))
end

function GameLayer:playPokeTypeAnimation()
	-- 播放牌型特效
	if app.pokePlay[self.allBalanceUser[0]] == nil then
		return
	end
	local maxType = app.pokePlay[self.allBalanceUser[0]].outType.type
	for i = 0, table.nums(self.allBalanceUser) - 1 do
		local chair = self.allBalanceUser[i]
		local userType = app.pokePlay[chair].outType.type
		if userType > maxType then
			maxType = userType
		end
	end

	if maxType >= _gamePublic.eCards_Type.eType_SameColor and maxType <= _gamePublic.eCards_Type.eType_GodSameLoong then
		self.specialEffectLayer:show()
		for i = 0, table.nums(self.allBalanceUser) - 1 do
			local chair = self.allBalanceUser[i]
			local userType = app.pokePlay[chair].outType.type
			if userType == maxType then
				self.specialEffectLayer:setWinUserByChair(chair)
			end
		end
		self.specialEffectLayer:setUserStencil()
		self.specialEffectLayer:playAnimation(maxType)
		local delay = cc.DelayTime:create(1.5)
		local func = cc.CallFunc:create(function ()
			self.specialEffectLayer:hide()
			self.specialEffectLayer:clearUserStencil()
			self.specialEffectLayer:clearPublicCards()
		end)
		self:runAction(cc.Sequence:create(delay, func, nil))
	end
end

function GameLayer:onSC_BET( event )
    print("GameLayer:onSC_BET")
    local data = event.data
    print("bet = " ..data.bet)
	require(app.codeSrc .."BringBetUI"):onSetBet(data.bet)
	self.baseBet = data.bet
	self.bankerChair = S2CChair(data.banker)
end

function GameLayer:onSC_POKE_OP_REQ(event)
	-- 清除游戏卡时，显示的上一轮多余结算资源
	for i = 0, _gamePublic.c_tablePlyNum - 1 do
		if app.gameViewController.EndTypeImg ~= nil and  app.gameViewController.EndTypeImg[i] ~= nil then
			app.gameViewController.EndTypeImg[i]:removeSelf()
			app.gameViewController.EndTypeImg[i] = nil
		end

		-- 清除结算分数
		if app.runningScene.winFrame ~= nil and app.runningScene.winFrame[i] ~= nil and app.runningScene.winFrame[i]:isVisible() then
			app.runningScene.winFrame[i]:hide()
		end
		if app.runningScene.loseFrame ~= nil and app.runningScene.loseFrame[i] ~= nil and app.runningScene.loseFrame[i]:isVisible() then
			app.runningScene.loseFrame[i]:hide()
		end

		if self.userBalanceFrame[i].frame1:isVisible() then
			self.userBalanceFrame[i].frame1:stopAllActions()
			:hide()
		end
		if self.userBalanceFrame[i].frame2:isVisible() then
			self.userBalanceFrame[i].frame2:stopAllActions()
			:hide()
		end
	end

	local data = event.data
	if self.round ~= data.round then
		for i = 0, _gamePublic.c_tablePlyNum - 1 do
			self.tablePlayer[i].curBet = 0
		end
	end
	self.round = data.round
	self.maxRound = data.roundMax

	local chair = S2CChair(data.chair)
	if _gamePublic:_and(data.op, _gamePublic.eOp_Type.eOp_Open) > 0 then
		if data.chair == -1 then
			self:OnBetRoundEnd()
			return
		end
	end
	if  not cc.dataMgr.isWatcher then
		if chair == 0 then
			--dump(data)
			if _gamePublic:_and(data.op, _gamePublic.eOp_Type.eOp_Open) > 0 then
				self:OnBetRoundEnd()
				return
			end
			app.gameViewController:showOpBtn(data.op) -- 显示操作按钮
		else
			app.gameViewController:showOpBtn(0)
		end
	end

	if not self.tablePlayer[chair].isAllIn then
		self:schedulerOp(chair)
		self.lastUserOp = data.op

		-- 隐藏昵称，显示思考中
		if app.runningScene.gameUsersUI == nil then return end
		local _userlayer = app.runningScene.gameUsersUI[chair]
		if _userlayer == nil then return end
		local _userPanel = _userlayer:getChildByName("Panel_user_info")
		local _name = _userPanel:getChildByName("Text_name")
		_name:hide()
		local _status = _userPanel:getChildByName("Image_status")
		_status:show()
		_status:loadTexture(app.codeRes .."status/thinking.png")
		local rdSize = _status:getVirtualRendererSize()
		_status:setContentSize(rdSize)
	end
end

function GameLayer:onSC_SPLIT_BET_DATA(event)
	print"onSC_SPLIT_BET_DATA"
	local data = event.data
	self.lastAllPass = true
	self.lastAllGiveUp = true

	for i = 0, 9 do
		self.splitBet[i] = 0
	end

	for k, v in pairs(data.SplitBet) do
		self.splitBet[k] = v
	end

	--dump(self.splitBet)
end

function GameLayer:onSC_POKE_HAND_NOT(event)
	print"GameLayer:onSC_POKE_HAND_NOT"
	local data = event.data
	--dump(data)
	local chair = S2CChair(data.chair)
	if _gamePublic:valid_chair(chair) then
		self:OnCardsNotify(chair, data.handCards, data.oldHandCards)
	end
end

function GameLayer:OnCardsNotify(chair, handCards, oldHandsCards)
	app.pokePlay[chair].hand = {}

	for i = 0, table.nums(handCards) - 1 do
		app.pokePlay[chair].hand[i] = handCards[i]
	end
	app.pokePlay[chair]:CaclType()

	if chair ~= 0 then
		local cardsArray = self.cardsLayer.handCardsList[chair]
		if cardsArray then
			for i = 0, table.nums(cardsArray) - 1 do
				local spCard = cardsArray[i]
				if spCard then
					local pos = {}
					pos.x, pos.y = app.runningScene:GetCardPos(chair, i)
					if pos.x == nil or pos.y == nil then
						return
					end

					local function complete()
						local spOpenCard = self.cardsLayer:drawOneCard(oldHandsCards[i], pos, 0.8)
						spOpenCard:setScaleX(0.75)
						self.cardsLayer:insertHandCardToTable(chair, spOpenCard)
					end

					-- 放大扑克,然后播放转牌动画
					local endPosX, endPosY = app.runningScene:GetCardPos(chair, i)
					local ScaleAction = cc.ScaleTo:create(0.2, 0.75)
					local MoveAction = cc.MoveTo:create(0.2, cc.p(endPosX, endPosY))
					local SpawnAction = cc.Spawn:create(ScaleAction, MoveAction)
					local CallFunc = cc.CallFunc:create(function ()
						self.OtherOpenCardsFrame[chair][i]:playAnimationOnce(display.getAnimationCache("endOpenCards" .. chair * 10 + i .. "Animation"), {hide = 1, onComplete = complete})
						spCard:removeSelf()
						self.cardsLayer.handCardsList[chair][i] = nil
					end)
					spCard:runAction(cc.Sequence:create(SpawnAction, CallFunc, nil))
				end
			end
		end
	else
		self.cardsLayer:removeHandCards(chair)
		for i = 0, table.nums(oldHandsCards) - 1 do
			local pos = {}
			pos.x, pos.y = app.runningScene:GetCardPos(chair, i)
			if pos.x == nil or pos.y == nil then
				return
			end

			local spOpenCard = self.cardsLayer:drawOneCard(oldHandsCards[i], pos, 0.8)
			spOpenCard:setScaleX(0.75)
			self.cardsLayer:insertHandCardToTable(chair, spOpenCard)
		end
	end
	self.oldHandCards[chair] = oldHandsCards

	local userType = app.pokePlay[chair].outType.type
	if app.runningScene.gameUserCurBetPos ~= nil then
		local x, y = _attribute.gameUserPos[chair].x, _attribute.gameUserPos[chair].y + 67
		app.gameViewController.EndTypeImg[chair] = display.newSprite(_attribute.EndTypeRes[userType], x, y)
		app.gameViewController.EndTypeImg[chair]:addTo(self)
		app.gameViewController.EndTypeImg[chair]:hide()
	end
end

function GameLayer:AddBetPoolWinUser(PoolIndex, winChair)
	self.betPoolWinUser[table.nums(self.betPoolWinUser)] = { poolIndex = PoolIndex, winUser = table.deepcopy(winChair)}
end

function GameLayer:playBetWinUserAnimation()
	if self.endAnimationHandle then scheduler.unscheduleGlobal(self.endAnimationHandle) self.endAnimationHandle = nil end

	--dump(self.betPoolWinUser)

	if self.betPoolWinUser ~= nil and table.nums(self.betPoolWinUser) == 0 then
		--显示输的玩家的分数
		for i = 0, table.nums(self.allBalanceUser) - 1 do
			local chair = self.allBalanceUser[i]
			local frame
			if self.tablePlayer[chair].endScore < 0 then
				self:OnBalance(chair, self.endType)

				local loseNum = frame:getChildByName("BitmapFontLabel_lose_num")
				loseNum:setString("-" .. math.abs(self.tablePlayer[chair].endScore))
			elseif self.tablePlayer[chair].endScore > 0 then
				local loseNum = frame:getChildByName("BitmapFontLabel_win_num")
				loseNum:setString("+" .. math.abs(self.tablePlayer[chair].endScore))
			end
			if app.runningScene.winFrame ~= nil and app.runningScene.winFrame[chair] ~= nil then
				frame = app.runningScene.winFrame[chair]
				local count = table.nums(self.ChairIdInGaming)
				local isEndUser = false
				for p = 0, count - 1 do
					if self.ChairIdInGaming[p] == chair then
						isEndUser = true
						break
					end
				end
				if isEndUser then
					frame:show()
				end
			end
		end

		self:onGameEnd()
		return
	end

	local winCell = self.betPoolWinUser[0]
	local winUser = winCell.winUser
	-- 显示牌型
	for i = 0, table.nums(winUser) - 1 do
		self:OnBalance(winUser[i], self.endType)
	end

	-- 桌面的牌暗显
	local winCards =  app.pokePlay[winUser[0]].hand
	--dump(winCards)
	for i = 0, table.nums(self.publicCards) - 1 do
		local spCard = self.cardsLayer.publicCardsList[i]
		local spCardCopy = self.specialEffectLayer.publicCardsList[i]
		local b = false
		for j = 0, table.nums(winCards) - 1 do
			if winCards[j]:equal(self.publicCards[i]) then
				b = true
			end
		end
		if b then
			self.cardsLayer:setPokeColor(spCard, cc.c3b(0xff, 0xff, 0xff))
		else
			self.cardsLayer:setPokeColor(spCard, cc.c3b(0x55, 0x55, 0x55))
		end
		if b and spCardCopy then
			self.cardsLayer:setPokeColor(spCardCopy, cc.c3b(0xff, 0xff, 0xff))
		else
			self.cardsLayer:setPokeColor(spCardCopy, cc.c3b(0x55, 0x55, 0x55))
		end
	end

	-- 恢复手牌亮显
	for i = 0, table.nums(self.allBalanceUser) - 1 do
		local chair = self.allBalanceUser[i]
		for j = 0, table.nums(self.cardsLayer.handCardsList[chair]) - 1 do
			local spCard = self.cardsLayer.handCardsList[chair][j]
			self.cardsLayer:setPokeColor(spCard, cc.c3b(0xff, 0xff, 0xff))
		end
	end

	-- 各自的手牌暗显
	for i = 0, table.nums(winUser) - 1 do
		local winHandCards = app.pokePlay[winUser[i]].hand
		--dump(winHandCards)
		for j = 0, table.nums(self.oldHandCards[winUser[i]]) - 1 do
			local spCard = self.cardsLayer.handCardsList[winUser[i]][j]
			local b = false
			for k = 0, table.nums(winHandCards) - 1 do
				if winHandCards[k]:equal(self.oldHandCards[winUser[i]][j]) then
					b = true
				end
			end
			if b then
				self.cardsLayer:setPokeColor(spCard, cc.c3b(0xff, 0xff, 0xff))
			else
				self.cardsLayer:setPokeColor(spCard, cc.c3b(0x55, 0x55, 0x55))
			end
		end
	end

	-- 筹码飞行
	local pool = winCell.poolIndex
	self.chipMoveLayer:removeChipArrayByPoolIndex(pool)
	for j = 0, table.nums(winUser) - 1 do
		local pos = {x = _attribute.ChipPoolPos[pool].x - 55, y = _attribute.ChipPoolPos[pool].y }
		local tmpNode = self.chipMoveLayer:createChipArray(self.chipPoolInfo[pool].value / table.nums(winUser), pos)
		self.chipMoveLayer:moveChipArray(tmpNode, _attribute.gameUserPos[winUser[j]])

		-- 隐藏分池
		app.gameViewController.chipPoolFrame[pool]:hide()

		-- 飞行之后删除筹码
		local delay = cc.DelayTime:create(0.5)
		local func = cc.CallFunc:create(function ()
			self.chipMoveLayer:removeChipArrayNode(tmpNode)

		end)
		self:runAction(cc.Sequence:create(delay, func, nil))
	end

	-- 播放音效
	app.gameAudioPlayer.playBalanceChipsEffect()

	for i = 1, table.nums(self.betPoolWinUser) - 1 do
		self.betPoolWinUser[i - 1].poolIndex = self.betPoolWinUser[i].poolIndex
		self.betPoolWinUser[i - 1].winUser = table.deepcopy(self.betPoolWinUser[i].winUser)
	end
	self.betPoolWinUser[table.nums(self.betPoolWinUser) - 1] = nil

	if table.nums(self.betPoolWinUser) ~= 0 then
		self.endAnimationHandle = scheduler.scheduleGlobal(handler(self, GameLayer.playBetWinUserAnimation), 1)
	else
		--显示输的玩家的分数
		for i = 0, table.nums(self.allBalanceUser) - 1 do
			local chair = self.allBalanceUser[i]
			local frame
			if self.tablePlayer[chair].endScore < 0 then
				self:OnBalance(chair, self.endType)

				if app.runningScene.winFrame ~= nil and app.runningScene.winFrame[chair] ~= nil then
					frame = app.runningScene.loseFrame[chair]
					local loseNum = frame:getChildByName("BitmapFontLabel_lose_num")
					loseNum:setString("-" .. math.abs(self.tablePlayer[chair].endScore))
				end
			elseif self.tablePlayer[chair].endScore > 0 then
				if app.runningScene.winFrame ~= nil and app.runningScene.winFrame[chair] ~= nil then
					frame = app.runningScene.winFrame[chair]
					local loseNum = frame:getChildByName("BitmapFontLabel_win_num")
					loseNum:setString("+" .. math.abs(self.tablePlayer[chair].endScore))
				end
			end
			if frame ~= nil then
				local count = table.nums(self.ChairIdInGaming)
				local isEndUser = false
				for p = 0, count - 1 do
					if self.ChairIdInGaming[p] == chair then
						isEndUser = true
						break
					end
				end
				if isEndUser then
					frame:show()
				end
			end
		end

		self:onGameEnd()
		return
	end
end

function GameLayer:onGameEnd()
	local delayAction = cc.DelayTime:create(0.5)
	local callFunc = cc.CallFunc:create(function ()
		if not cc.dataMgr.isWatcher then
			if self.isSelfInGaming then
				if cc.dataMgr.tableUsers[cc.dataMgr.lobbyUserData.lobbyUser.userID].playCurrency < self.baseBet then
					if i64_toInt(cc.dataMgr.lobbyUserData.lobbyUser.gameCurrency) < self:GetMinBringBet() then
						app.msgBox.showMsgBox("游戏豆不足，离开房间", function ()
							cc.lobbyController:sendLeaveTableReq()
							app.sceneSwitcher:enterScene("RoomScene")
							--app.exitGameSceneSkip()
						end)
					else
						require(app.codeSrc .."BringBetUI"):showBringBetUI()
					end
				end
			end

			app.bGaming = false
			self:restartGame()
		else
			cc.lobbyController:sendLeaveTableReq()
			app.sceneSwitcher:enterScene("RoomScene")
			--app.exitGameSceneSkip()
		end
	end)
	self:runAction(cc.Sequence:create(delayAction, callFunc, nil))
end

function GameLayer:OnBalance(chair, endType)
	if chair == 0 then
		-- 播放结算音效
		app.gameAudioPlayer.playEndEffect(self.tablePlayer[chair].endScore)
	end

	if endType == 0 then
		if self.tablePlayer[chair].endScore <= 0 then
			if _gamePublic:_and(self.tablePlayer[chair].oper, _gamePublic.eOp_Type.eOp_Giveup) == 0 then
				if app.gameViewController.EndTypeImg[chair] ~= nil then
					app.gameViewController.EndTypeImg[chair]:show()

					-- 隐藏昵称
					if app.runningScene.gameUsersUI == nil then return end
					local _userlayer = app.runningScene.gameUsersUI[chair]
					if _userlayer == nil then return end
					local _userPanel = _userlayer:getChildByName("Panel_user_info")
					local _name = _userPanel:getChildByName("Text_name")
					_name:hide()
					local _status = _userPanel:getChildByName("Image_status")
					_status:hide()
				end
			end
		else
			local userType = app.pokePlay[chair].outType.type
			if app.gameViewController.EndTypeImg[chair] ~= nil then
				app.gameViewController.EndTypeImg[chair]:show()

				-- 隐藏昵称
				if app.runningScene.gameUsersUI == nil then return end
				local _userlayer = app.runningScene.gameUsersUI[chair]
				if _userlayer == nil then return end
				local _userPanel = _userlayer:getChildByName("Panel_user_info")
				local _name = _userPanel:getChildByName("Text_name")
				_name:hide()
				local _status = _userPanel:getChildByName("Image_status")
				_status:hide()
			end
			if userType == _gamePublic.eCards_Type.eType_SingleLoong then
			elseif userType == _gamePublic.eCards_Type.eType_SameColor then
			elseif userType == _gamePublic.eCards_Type.eType_ThreeTwo then
			elseif userType == _gamePublic.eCards_Type.eType_Four then
			elseif userType == _gamePublic.eCards_Type.eType_SameLoong then
			elseif userType == _gamePublic.eCards_Type.eType_GodSameLoong then
			else

			end
		end
	end

	if self.tablePlayer[chair].endScore > 0 then
		local FrameText
		if _gamePublic:_and(self.tablePlayer[chair].oper, _gamePublic.eOp_Type.eOp_Giveup) == 0 then
			local userType = app.pokePlay[chair].outType.type
			if userType >= _gamePublic.eCards_Type.eType_SameColor then
				FrameText = "goldFrame1"
			else
				FrameText = "goldFrame2"
			end
		else
			FrameText = "goldFrame2"
		end
		if FrameText == "goldFrame1" then
			self.userBalanceFrame[chair].frame1:playAnimationForever(display.getAnimationCache(FrameText.. "Animation" .. chair))
		else
			self.userBalanceFrame[chair].frame2:playAnimationForever(display.getAnimationCache(FrameText.. "Animation" .. chair))
		end
	end
end

function GameLayer:OnBetRoundEnd()
	-- 隐藏状态，显示昵称
	for i = 0, _gamePublic.c_tablePlyNum - 1 do
		if not self.tablePlayer[i].isAllIn then
			if app.runningScene.gameUsersUI == nil then return end
			local _userlayer = app.runningScene.gameUsersUI[i]
			if _userlayer == nil then
				return
			end

			local _userPanel = _userlayer:getChildByName("Panel_user_info")
			local _name = _userPanel:getChildByName("Text_name")
			_name:show()
			local _status = _userPanel:getChildByName("Image_status")
			_status:hide()
		end
	end

	--计算等待的最长时间
	local maxTime = 0.3

	-- 移动个人筹码到中间位置
	--dump(self.nodeChip)
	--dump(self.tablePlayer)
	for i = 0, _gamePublic.c_tablePlyNum - 1 do
		--dump(self.tablePlayer[i])
		--if self.tablePlayer[i].curBet ~= 0 then
			local actionDelay = cc.DelayTime:create(maxTime)
			local callFun = cc.CallFunc:create(function ()
				if self.chipMoveLayer.userChipList[i] ~= nil then
					self.chipMoveLayer:moveChipArrayByChair(i, _attribute.RoundEndPos)
					if app.runningScene.gameUsersUI == nil then return end
					local _userlayer = app.runningScene.gameUsersUI[i]

					--隐藏数字显示
					local PanelUserInfo = _userlayer:getChildByName("Panel_user_info")
					PanelUserInfo:getChildByName("Image_weight_frame"):hide()

					-- 移动完成之后删除玩家的筹码
					local actionDelay2 = cc.DelayTime:create(0.5 + 0.05)
					local callFun2 = cc.CallFunc:create(function ()
						self.chipMoveLayer:removeChipArrayByChair(i)
						-- 播放音效
						app.gameAudioPlayer.playRoundCollectionChipsEffect()
					end)
					self.chipMoveLayer:runAction(cc.Sequence:create(actionDelay2, callFun2, nil))
				end
			end)
			self.chipMoveLayer:runAction(cc.Sequence:create(actionDelay, callFun, nil))
		--end
	end

	-- 清除多余的桌面筹码
	local Delay = cc.DelayTime:create(maxTime + 0.5 + 0.05)
	local callFun = cc.CallFunc:create(function ()
		for i = 0, _gamePublic.c_tablePlyNum - 1 do
			if self.chipMoveLayer.userChipList[i] then
				self.chipMoveLayer:removeChipArrayByChair(i)
			end
		end
	end)
	self.chipMoveLayer:runAction(cc.Sequence:create(Delay, callFun, nil))

	-- 计算分池数量
	local splitBetCount = 0
	for i = 0, 9 do
		if self.splitBet[i] <= 0 then
			splitBetCount = i
			break
		end
	end

	-- 创建分池筹码
	for i = 0, splitBetCount - 1 do
		--print("table.nums(self.chipPoolInfo)=".. table.nums(self.chipPoolInfo) ..",self.splitBet[i]=".. self.splitBet[i] ..",self.chipPoolInfo[i].value=".. self.chipPoolInfo[i].value)
		if table.nums(self.chipPoolInfo) <= i or self.splitBet[i] > self.chipPoolInfo[i].value then
			local actionDelay = cc.DelayTime:create(maxTime + 0.5 + 0.05)
			local callFun = cc.CallFunc:create(function ()
				local endPos = {x = _attribute.ChipPoolPos[i].x - 55, y = _attribute.ChipPoolPos[i].y }
				local tmpChipNode = self.chipMoveLayer:createMoveChipArray(_attribute.RoundEndPos)
				self.chipMoveLayer:moveChipArray(tmpChipNode, endPos)

				-- 移动完成之后删除临时筹码，创建分池筹码
				local actionDelay2 = cc.DelayTime:create(0.3 + 0.05)
				local callFun2 = cc.CallFunc:create(function ()
					self.chipMoveLayer:removeChipArrayNode(tmpChipNode)

					-- 删除原筹码
					self.chipMoveLayer:removeChipArrayByPoolIndex(i)

					-- 创建新的筹码
					self.chipMoveLayer:createChipsForPoolIndex(i, endPos)

					self.chipPoolInfo[i].value = self.splitBet[i]
					app.gameViewController.chipPoolFrame[i]:show()
					local num = app.gameViewController.chipPoolFrame[i]:getChildByName("BitmapFontLabel_chip_num")
					num:setString(string.format("%d", self.splitBet[i]))
				end)
				self.chipMoveLayer:runAction(cc.Sequence:create(actionDelay2, callFun2, nil))
			end)
			self.chipMoveLayer:runAction(cc.Sequence:create(actionDelay, callFun, nil))
		end
	end
end

function GameLayer:schedulerOp(chair)
	self.timeNode = cc.GLNode:create()
	self.timeNode:addTo(self, 10)

	-- 创建一个圆角矩形
	local rect = {x = _attribute.gameUserPos[chair].x - 57, y = _attribute.gameUserPos[chair].y + 82, width = 114, height = 164 }
	--local node = cc.DrawNode:create()
	--_clockBorderRender:drawNodeRoundRect(node, rect, 2, 10, cc.c4f(1, 0, 1, 0.5))
	local color = {
		r = 0,
		g = 255,
		b = 0,
		a = 255
	}
	--_clockBorderRender:drawNodeRoundRectEx(node, rect, 2, 10, color)
	--_clockBorderRender:drawCountDownRoundRect(self.timeNode, rect, 10, color, 15, 15)
	self.OpTime = 14
	self.totalTime = 14

	local count = false
	self.OpHandler = scheduler.scheduleGlobal(function ()
		self.OpTime = self.OpTime - 0.1
		if self.OpTime > 0.9 and self.OpTime <= 1 and not count then
			print"playTimeoutTipEffect"
			app.gameAudioPlayer.playTimeoutTipEffect()
			count = true
		end
		--local rect = {x = 568, y = 320, width = 118, height = 168 }
		local color = {}
		if self.OpTime / self.totalTime >= 0.5 then
			color.r = 255 - (self.OpTime - self.totalTime / 2 ) / (self.totalTime / 2) * 255
			color.g = 255
			color.b = 0
			color.a = 255
		else
			color.r = 255
			color.g = 255 - 255 * (self.totalTime / 2 - self.OpTime) / (self.totalTime / 2)
			color.b = 0
			color.a = 255
		end

		_clockBorderRender:drawCountDownRoundRect(self.timeNode, rect, 10, color, self.OpTime, self.totalTime)


		if self.OpTime <= 0  then
			self:unSchedulerOp()
		end
	end, 0.1)
end

function GameLayer:unSchedulerOp()
	if self.OpHandler then scheduler.unscheduleGlobal(self.OpHandler) end
	if self.timeNode then
		self.timeNode:removeSelf()
		self.timeNode = nil
	end
end

function GameLayer:restartGame()
	for i = 0, 8 do
		app.gameViewController.chipPoolFrame[i]:hide()
	end
	self.chipMoveLayer:removeAllChip()
	self:initData()
	for i = 0, _gamePublic.c_tablePlyNum - 1 do
		if app.runningScene.gameUsersUI ~= nil and app.runningScene.gameUsersUI[i] ~= nil then
			if app.runningScene.gameUsersUI == nil then return end
			local _userlayer = app.runningScene.gameUsersUI[i]
			_userlayer:getChildByName("Image_qi_pai"):hide()
			_userlayer:getChildByName("Panel_user_info"):getChildByName("Image_banker"):hide()

			self.spSelfGiveUp:hide()

			-- 清除上一轮Allin标示
			local _userPanel = _userlayer:getChildByName("Panel_user_info")
			--[[
			local _name = _userPanel:getChildByName("Text_name")
			_name:show()

			local _status = _userPanel:getChildByName("Image_status")
			_status:hide()
			--]]
		end
	end

	for i = 0, _gamePublic.c_tablePlyNum - 1 do
		app.pokePlay[i]:InitPoke()
	end

	app.gameViewController.textChipNum:setString("pool: 0")
	app.gameViewController.selfTotalBet:setString("beted: 0")
	:hide()
end

function GameLayer:GetMinBringBet()
	return cc.dataMgr.bringLeastTimes * self.baseBet
end

function GameLayer:GetMaxBringBet()
	if self.baseBet >= 100000 then
		return cc.dataMgr.tenThousandBringMostTimes * self.baseBet
	end
	return cc.dataMgr.bringMostTimes * self.baseBet
end

function GameLayer:OnStakeNotify(chair, oper, stake, betSeq)
	betSeq = betSeq or 0

	if _gamePublic:_and(oper, _gamePublic:_or(_gamePublic.eOp_Type.eOp_PassBet, _gamePublic.eOp_Type.eOp_Giveup)) == 0 then
		self.tablePlayer[chair].nTotalBet = self.tablePlayer[chair].nTotalBet + stake - self.tablePlayer[chair].nCurBet
		self.tablePlayer[chair].nCurBet = stake
	end

	local res = _gamePublic:_or(_gamePublic.eOp_Type.eOp_PassBet, _gamePublic.eOp_Type.eOp_Suoha)
	res = _gamePublic:_or(res, _gamePublic.eOp_Type.eOp_Giveup)
	if _gamePublic:_and(oper, res) > 0 then
		self.tablePlayer[chair].oper = _gamePublic:_or(self.tablePlayer[chair].oper, oper)
	end

	-- 隐藏昵称，显示操作
	if not self.tablePlayer[chair].isAllIn and _gamePublic:_and(oper, _gamePublic.eOp_Type.eOp_Giveup) == 0 then
		if app.runningScene.gameUsersUI == nil then return end
		local _userlayer = app.runningScene.gameUsersUI[chair]
		if _userlayer == nil then return end
		local _userPanel = _userlayer:getChildByName("Panel_user_info")
		local _name = _userPanel:getChildByName("Text_name")
		_name:hide()
		local _status = _userPanel:getChildByName("Image_status")
		_status:show()
		local ResPath = app.codeRes .."status/"
		local ResName
		if oper == _gamePublic.eOp_Type.eOp_FollowBet then
			ResName = "gengzhu.png"
		elseif oper == _gamePublic.eOp_Type.eOp_AddBet then
			ResName = "jiazhu.png"
		elseif oper == _gamePublic.eOp_Type.eOp_Suoha then
			ResName = "all_in.png"
		elseif oper == _gamePublic.eOp_Type.eOp_PassBet then
			ResName = "rangpai.png"
		end
		ResPath = ResPath .. ResName
		_status:loadTexture(ResPath)
		local rdSize = _status:getVirtualRendererSize()
		_status:setContentSize(rdSize)
	end

	if not self.tablePlayer[chair].isAllIn then
		if betSeq > 2 then
			if app.runningScene.tableUsersByChair == nil then return end
			local user = app.runningScene.tableUsersByChair[chair]
			if user then
				local sex = user.userData.gender
				if oper == _gamePublic.eOp_Type.eOp_PassBet then
					sex = 0
				end
				app.gameAudioPlayer.playOpAudio(oper, sex)
			end
		end
	end

	if _gamePublic:_and(oper, _gamePublic.eOp_Type.eOp_Suoha) > 0 then
		self.tablePlayer[chair].isAllIn = true
	end
end



---------------------------处理model通知过来的事件 end---------------------------
function GameLayer:onEnter()
	print("GameLayer:onEnter()")
	app.gameViewController.clickBtnLeave = false
end


function GameLayer:onExit()
	print("GameLayer:onExit()")
	--self.specialEffectLayer:onExit()
	self.eventProtocol:removeAllEventListeners()
	self:stopAllActions()
	self:unSchedulerOp()
	require("dzpk.src.BringBetUI"):hideBringBetUI()
	if self.endAnimationHandle then scheduler.unscheduleGlobal(self.endAnimationHandle) self.endAnimationHandle = nil end
end

return GameLayer