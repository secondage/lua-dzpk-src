local GameViewController = class("GameViewController")

local scheduler = require("framework.scheduler")
local _miniGameMsgHandler = nil
local _gamePublic = nil
local _attribute = require("dzpk.src.Attribute")
local function findWidget(name)
	return app.seekChildByName(app.gameResNode, name)
end

local function createFrameAnimation(parent, name, num, playTime)
	local frames = display.newFrames(name.. "_%02d.png", 0, num, false)
	local animation, firstFrame = display.newAnimation(frames, playTime / num)
	display.setAnimationCache(name .."Animation", animation)
	firstFrame:addTo(parent)
	firstFrame:hide()
	return firstFrame
end

function GameViewController:ctor()
	_gamePublic = app.gamePublic
	self:initBtns()
	self:initSprite()
	self:initAnimation()
	self.percent = 0
end

local _timerHandler = nil

function GameViewController:removeAllScheduler()
	if _timerHandler then
		scheduler.unscheduleGlobal(_timerHandler)
	end
end

local function SendOpAck(op, ext, serialTick)
	app.miniGameMsgHandler:sendOpAck(op, ext, serialTick)
end

function GameViewController:initAnimation()
	self.AllInFrame = createFrameAnimation(self.jiaZhuSlider, "ALL IN", 10, 1.6)
	local imgAllInShow = self.jiaZhuSlider:getChildByName("Image_show_all_in")
	local x, y = imgAllInShow:getPosition()
	self.AllInFrame:pos(x, y)

	self.chipImg = findWidget("Image_show_chip"):hide()
	self.chipFrame = createFrameAnimation(self.chipImg, "chip", 10, 1.6)
	--x, y = chipImg:getPosition()
	self.chipFrame:pos(13, 13)
end

function GameViewController:initBtns()
	local btnLeave = findWidget("Button_back")
	self.clickBtnLeave = false
	btnLeave:addTouchEventListener(function (sender, eventType)
		if eventType == 2 then
			app.audioPlayer:playClickBtnEffect()

			if app.bGaming == true and not cc.dataMgr.isWatcher and app.gameLayer.isSelfInGaming then
				app.toast.show("很抱歉,游戏中不能退出")
			else
				if not self.isExiting then
					print("<=== 123123123")
					app.holdOn.show("请稍后...")
					self.isExiting = true
					cc.lobbyController:sendLeaveTableReq()
					app.sceneSwitcher:enterScene("RoomScene") --leave table处理
					--app.exitGameSceneSkip()
					self.clickBtnLeave = true
				end
			end
		end
	end)

	local btnSet = findWidget("Button_game_set")
	btnSet:addTouchEventListener(function (sender, eventType)
		if eventType == 2 then
			app.audioPlayer:playClickBtnEffect()
			app.popLayer.show(app.gameLayer.settingLayer)
		end
	end)

	local btnPaiXing = findWidget("Button_pai_xing")
	local function OnbtnPaiXing(sender, eventType)
		if eventType == 2 then
			app.audioPlayer:playClickBtnEffect()
			self.ImgPaixing:setVisible(not self.ImgPaixing:isVisible())
			local layRoof = findWidget("Node_back_ground"):getChildByName("Panel_roof"):show()
		end
	end
	btnPaiXing:addTouchEventListener(OnbtnPaiXing)

	local btnAddChip = findWidget("Button_add_self_chip")
	if cc.dataMgr.isWatcher then
		btnAddChip:hide()
	end
	local function OnbtnAddChip(sender, eventType)
		if eventType == 2 then
			app.audioPlayer:playClickBtnEffect()
			local addChipLayer = require(app.codeSrc .."AddChipLayer")
		--print("AAAAAAAAAAAAAAapp.gameLayer.baseBet=".. app.gameLayer.baseBet)
			addChipLayer:onSetBet(app.gameLayer.baseBet)
			addChipLayer:showAddChip()
			local layRoof = findWidget("Node_back_ground"):getChildByName("Panel_roof"):show()
		end
	end
	btnAddChip:addTouchEventListener(OnbtnAddChip)

	self.preinstallNode = findWidget("Node_preinstall"):hide()

	local function doSelect(obj, type, index)		-- index 预设下标 0：看或弃， 1：跟任何
		local children = self.preinstallNode:getChildren()
		for _, child in pairs(children) do
			child:setSelected(false)
		end
		for i =0, 1 do
			app.gameLayer.bPreinstall[i] = false
		end
		if type == 1 then
			obj:setSelected(false)
			app.gameLayer.bPreinstall[index] = false
		elseif type == 0 then
			obj:setSelected(true)
			app.gameLayer.bPreinstall[index] = true
		end
		app.audioPlayer:playClickBtnEffect()
	end

	self.CheckAutoKanQi = self.preinstallNode:getChildByName("CheckBox_kan_or_qi")
	self.CheckAutoKanQi:setSelected(false)
	self.CheckAutoKanQi:addEventListener(function (obj, type)
		print("checkAutokanqi, type = ".. type)
		doSelect(obj, type, 0)
	end)

	self.CheckAutoGenRenYi = self.preinstallNode:getChildByName("CheckBox_gen_ren_yi")
	self.CheckAutoGenRenYi:setSelected(false)
	self.CheckAutoGenRenYi:addEventListener(function (obj, type)
		doSelect(obj, type, 1)
	end)
	self.operateNode = findWidget("Node_operate"):hide()
	self.operateNode:retain()
	self.operateNode:removeFromParent()
	--self.operateNode:setLocalZOrder(2)
	self.btnQiPai = self.operateNode:getChildByName("Button_qi_pai"):hide()
	local function OnbtnQipai(sender, eventType)
		if eventType == 2 then
			app.audioPlayer:playClickBtnEffect()
			self:OnBtnQiPai()
		end
	end
	self.btnQiPai:addTouchEventListener(OnbtnQipai)

	self.btnGenzhu = self.operateNode:getChildByName("Button_gen_zhu"):hide()
	local function OnbtnGenzhu(sender, eventType)
		if eventType == 2 then
			app.audioPlayer:playClickBtnEffect()
			self:OnBtnGenZhu()
		end
	end
	self.btnGenzhu:addTouchEventListener(OnbtnGenzhu)

	self.btnJiazhu = self.operateNode:getChildByName("Button_jia_zhu"):hide()
	self.btnJiaZhuNum = self.operateNode:getChildByName("Button_jiazhu_num"):hide()
	local FntJiaZhuNum = self.btnJiaZhuNum:getChildByName("BitmapFontLabel_add_num")
	local function OnbtnJiazhuNum(sender, eventType)
		if eventType == 2 then
			app.audioPlayer:playClickBtnEffect()
			self:OnBtnJiaZhu()
		end
	end
	self.btnJiaZhuNum:addTouchEventListener(OnbtnJiazhuNum)

	local function OnbtnJiazhu(sender, eventType)
		if eventType == 2 then
			app.audioPlayer:playClickBtnEffect()
			print("app.gameLayer.tablePlayer[0].playCurrency = " ..app.gameLayer.tablePlayer[0].playCurrency ..",app.gameLayer.tablePlayer[0].bet = ".. app.gameLayer.tablePlayer[0].bet.. ",app.gameLayer.tablePlayer[0].curBet = ".. app.gameLayer.tablePlayer[0].curBet.. ",app.gameLayer.curBet = ".. app.gameLayer.curBet)
			if app.gameLayer.maxBetValue <= app.gameLayer.baseBet then
				print("app.gameLayer.maxBetValue = ".. app.gameLayer.maxBetValue)
				self.btnAllIn:show()
			else
				local layRoof = findWidget("Node_back_ground"):getChildByName("Panel_roof"):show()
				self.jiaZhuSlider:show()
				self.btnJiaZhuNum:show()
				FntJiaZhuNum:setString(string.format("%d", app.gameLayer.baseBet))
				self.jiaZhuSlider:getChildByName("Button_jia_zhu"):setPosition(cc.p(78.5, 53))

			end
			self.btnJiazhu:hide()
		end
	end
	self.btnJiazhu:addTouchEventListener(OnbtnJiazhu)

	self.btnRangPai = self.operateNode:getChildByName("Button_rang_pai"):hide()
	self.btnRangPai:addTouchEventListener(function (obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			self:OnBtnRangPai()
		end
	end)
	self.btnAllIn = self.operateNode:getChildByName("Button_all_in"):hide()
	self.btnAllIn:addTouchEventListener(function (obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			self:OnBtnAllIn()
		end
	end)

	self.quickJiaZhuNode = findWidget("Node_jia_zhu_jetton"):hide()
	self.quickJiaZhuBtn = {}
	local function onBtnQuickJiaZhu(addBet)
		app.audioPlayer:playClickBtnEffect()
		app.gameLayer.addBetValue = addBet
		self:OnBtnJiaZhu()
	end

	self.quickJiaZhuBtn[0] = self.quickJiaZhuNode:getChildByName("Button_onefold"):show()
	self.quickJiaZhuBtn[0]:addTouchEventListener(function (obj, type)
		if type == 2 then
			onBtnQuickJiaZhu(app.gameLayer.baseBet)
		end
	end)
	self.quickJiaZhuBtn[1] = self.quickJiaZhuNode:getChildByName("Button_fivefold"):show()
	self.quickJiaZhuBtn[1]:addTouchEventListener(function (obj, type)
		if type == 2 then
			onBtnQuickJiaZhu(5 * app.gameLayer.baseBet)
		end
	end)
	self.quickJiaZhuBtn[2] = self.quickJiaZhuNode:getChildByName("Button_tenfold"):show()
	self.quickJiaZhuBtn[2]:addTouchEventListener(function (obj, type)
		if type == 2 then
			onBtnQuickJiaZhu(10 * app.gameLayer.baseBet)
		end
	end)
	self.quickJiaZhuBtn[3] = self.quickJiaZhuNode:getChildByName("Button_hundredfold"):show()
	self.quickJiaZhuBtn[3]:addTouchEventListener(function (obj, type)
		if type == 2 then
			onBtnQuickJiaZhu(100 * app.gameLayer.baseBet)
		end
	end)
end

function GameViewController:OnBtnRangPai()
	local op = _gamePublic.eOp_Type.eOp_PassBet
	SendOpAck(op)
	self:OnOperCompleted()
end

function GameViewController:OnBtnQiPai()
	local op = _gamePublic.eOp_Type.eOp_Giveup
	SendOpAck(op)
	self:OnOperCompleted()
end

function GameViewController:OnBtnGenZhu()
	local op = _gamePublic.eOp_Type.eOp_FollowBet
	SendOpAck(op)
	self:OnOperCompleted()
end

function GameViewController:OnBtnAllIn()
	local op = _gamePublic.eOp_Type.eOp_Suoha
	SendOpAck(op)
	self:OnOperCompleted()
end

function GameViewController:OnBtnJiaZhu()
	local op = _gamePublic.eOp_Type.eOp_AddBet
	local ext = app.gameLayer.addBetValue
	SendOpAck(op, ext)
	self:OnOperCompleted()
end

function GameViewController:initSprite()
	self.waitUser = findWidget("Image_wait_user")
	self.waitUser:hide()

	self.ImgPaixing = findWidget("Image_pai_xing_frame"):hide()
	self.ImgPaixing:retain()
	self.ImgPaixing:removeFromParent()
	self.ImgPaixing:addTo(app.gameResNode, 12)
	local layRoof = findWidget("Node_back_ground"):getChildByName("Panel_roof"):hide()
	local function onCloseEvt(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			local btnBack = findWidget("Button_back"):show()
			layRoof:hide()
			self.ImgPaixing:hide()
			app.gameLayer.userInfoLayer:hide()

			self.AllInFrame:hide()
			self.AllInFrame:stopAllActions()
			self.jiaZhuSlider:hide()
			self.btnJiaZhuNum:hide()
			self.btnAllIn:hide()
			self.btnJiazhu:show()
		end
	end
	layRoof:addTouchEventListener(onCloseEvt)

	self.waitStart = findWidget("Image_wait_start"):hide()
	self.countDownStartRound = findWidget("BitmapFontLabel_count_down_start_round")

	self:initJiaZhuSlider()

	self.textChipNum = findWidget("Text_table_chip_num"):show()
	self.textChipNum:setString("pool: 0")

	self.imgBetFrame = findWidget("Image_dizhu"):hide()

	self.chipPoolFrame = {}
	self.chipPoolFrame[0] = findWidget("Image_chip_pool_frame")
	for i = 1, 8 do
		self.chipPoolFrame[i] = self.chipPoolFrame[0]:clone()
		self.chipPoolFrame[i]:addTo(app.runningScene.tableBg)
	end
	for i = 0, 8 do
		self.chipPoolFrame[i]:setPosition(_attribute.ChipPoolPos[i].x, _attribute.ChipPoolPos[i].y)
		self.chipPoolFrame[i]:hide()
		if app.test then
			self.chipPoolFrame[i]:show()
		end
	end


	self.selfTotalBet = findWidget("Text_total_bet"):hide()
	self.selfTotalBet:setString("已押注:0")

	self.EndTypeImg = {}			-- 结算显示牌型

	self.showTalkFrame = {}
	local tmpTmg = findWidget("Image_show_talk"):hide()
	--
	for i = 0, 8 do
		self.showTalkFrame[i] = tmpTmg:clone():hide()
	end

	self.chatNode = findWidget("Node_chat"):show()

	local btnChat = self.chatNode:getChildByName("Button_chat")
	if cc.dataMgr.isWatcher then
		btnChat:hide()
	end

	btnChat:addTouchEventListener(function (obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			app.popLayer.show(app.gameLayer.chatLayer)
		end
	end)
end

-- 初始化加注滑动条
function GameViewController:initJiaZhuSlider()
	local FntJiaZhuNum = self.btnJiaZhuNum:getChildByName("BitmapFontLabel_add_num")

	self.jiaZhuSlider = self.operateNode:getChildByName("Image_jia_zhu"):hide()
	self.jiaZhuSlider:setTouchEnabled(true)
	local function onjiaZhuSlider(obj, type)
		if type == 2 then
			local pos = obj:getTouchEndPosition()--dump(pos)
			local localPos = obj:convertToNodeSpace(pos) --dump(localPos)
			local spBtn = self.jiaZhuSlider:getChildByName("Button_jia_zhu")
			local beginPosX, beginPosY = spBtn:getPosition()
			local endPosY
			if localPos.y > 328 then
				endPosY = 328
			elseif localPos.y < 53 then
				endPosY = 53
			else
				endPosY = localPos.y
			end
			spBtn:setPosition(beginPosX, endPosY)
			self.percent = (endPosY - 53) / (328 - 53)
			local imgAllInNormal = self.jiaZhuSlider:getChildByName("Image_normal")
			local imgAllInShow = self.jiaZhuSlider:getChildByName("Image_show_all_in")
			if self.percent == 1 then
				imgAllInNormal:hide()
				imgAllInShow:show()
				self.AllInFrame:stopAllActions()
				self.AllInFrame:playAnimationForever(display.getAnimationCache("ALL INAnimation"))
				self.btnAllIn:show()
				self.btnJiaZhuNum:hide()
			else
				imgAllInNormal:show()
				imgAllInShow:hide()
				self.AllInFrame:hide()
				self.AllInFrame:stopAllActions()
				self.btnAllIn:hide()
				self.btnJiaZhuNum:show()
			end
			local curAdd = (app.gameLayer.maxBetValue - app.gameLayer.baseBet) * self.percent + app.gameLayer.baseBet
			curAdd = curAdd - curAdd % 1
			FntJiaZhuNum:setString(string.format("%d", curAdd))
			app.gameLayer.addBetValue = curAdd
		end
	end
	self.jiaZhuSlider:addTouchEventListener(onjiaZhuSlider)

	local btnSilder = self.jiaZhuSlider:getChildByName("Button_jia_zhu")
	btnSilder:setPosition(cc.p(78.5, 53))
	self.percent = 0
	local function OnbtnSilder(sender, eventType)
		--if eventType == 0 then
		--elseif eventType == 1 then
			local pos = btnSilder:getTouchMovePosition()--dump(pos)
			local localPos = self.jiaZhuSlider:convertToNodeSpace(pos) --dump(localPos)
			local beginPosX, beginPosY = btnSilder:getPosition()
			local endPosY
			if localPos.y > 328 then
				endPosY = 328
			elseif localPos.y < 53 then
				endPosY = 53
			else
				endPosY = localPos.y
			end
			btnSilder:setPosition(beginPosX, endPosY)
			self.percent = (endPosY - 53) / (328 - 53)
			local imgAllInNormal = self.jiaZhuSlider:getChildByName("Image_normal")
			local imgAllInShow = self.jiaZhuSlider:getChildByName("Image_show_all_in")
			if self.percent == 1 then
				imgAllInNormal:hide()
				imgAllInShow:show()
				self.btnAllIn:show()
				self.btnJiaZhuNum:hide()
				self.AllInFrame:stopAllActions()
				self.AllInFrame:playAnimationForever(display.getAnimationCache("ALL INAnimation"))
			else
				imgAllInNormal:show()
				imgAllInShow:hide()
				self.btnAllIn:hide()
				self.btnJiaZhuNum:show()
				self.AllInFrame:hide()
				self.AllInFrame:stopAllActions()
			end
			local curAdd = (app.gameLayer.maxBetValue - app.gameLayer.baseBet) * self.percent + app.gameLayer.baseBet
			curAdd = curAdd - curAdd % 1
			FntJiaZhuNum:setString(string.format("%d", curAdd))
			app.gameLayer.addBetValue = curAdd
		--elseif eventType == 2 then

		--end
	end
	btnSilder:addTouchEventListener(OnbtnSilder)
	local imgAllInNormal = self.jiaZhuSlider:getChildByName("Image_normal"):show()
	local imgAllInShow = self.jiaZhuSlider:getChildByName("Image_show_all_in"):hide()
end

function GameViewController:showQuickJiaZhu(bet, maxAddChip)
	local function showNum(bet)
		local strBet
		if bet < 1000 then
			strBet = tostring(bet)
		elseif bet < 10000 then
			strBet = string.format("%dK", bet / 1000)
		elseif bet < 10000000 then
			strBet = string.format("%dW", bet / 10000)
		else
			strBet = string.format("%dKW", bet / 10000000)
		end
		return strBet
	end


	self.quickJiaZhuNode:show()
	for i = 0, 3 do
		local fntStr = self.quickJiaZhuBtn[i]:getChildByName("Text_value"):show()
		if i == 0 then
			fntStr:setString(showNum(bet))
		elseif i == 1 then
			fntStr:setString(showNum( 5 * bet))
		elseif i == 2 then
			fntStr:setString(showNum( 10 * bet))
		elseif i == 3 then
			fntStr:setString(showNum( 100 * bet))
		end
		self.quickJiaZhuBtn[i]:setEnabled(false)
		self.quickJiaZhuBtn[i]:setOpacity(100)
	end

	if maxAddChip > bet then
		self.quickJiaZhuBtn[0]:setEnabled(true)
		self.quickJiaZhuBtn[0]:setOpacity(255)
		if maxAddChip > 5 * bet then
			self.quickJiaZhuBtn[1]:setEnabled(true)
			self.quickJiaZhuBtn[1]:setOpacity(255)
			if maxAddChip > 10 * bet then
				self.quickJiaZhuBtn[2]:setEnabled(true)
				self.quickJiaZhuBtn[2]:setOpacity(255)
				if maxAddChip > 100 * bet then
					self.quickJiaZhuBtn[3]:setEnabled(true)
					self.quickJiaZhuBtn[3]:setOpacity(255)
				end
			end
		end
	end
end

local function S2CChair(chairid)
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

function GameViewController:showOpBtn(op)
	if cc.dataMgr.isWatcher then
		self.operateNode:hide()
		self.preinstallNode:hide()
		return
	end

	if not app.gameLayer.isSelfInGaming then
		self.operateNode:hide()
		self.preinstallNode:hide()
		return
	end

	if op == 0 then
		self.operateNode:hide()
		if app.gameLayer.isAllIn or app.gameLayer.isGiveUp then
			self.preinstallNode:hide()
		else
			self.preinstallNode:show()
		end
	else
		app.gameLayer.addBetValue = app.gameLayer.baseBet
		app.gameLayer.maxBetValue = app.gameLayer.tablePlayer[0].playCurrency - (app.gameLayer.tablePlayer[0].bet - app.gameLayer.tablePlayer[0].curBet + app.gameLayer.curBet)

		self:showQuickJiaZhu(app.gameLayer.baseBet, app.gameLayer.maxBetValue)

		self.operateNode:show()
		self.preinstallNode:hide()

		self.btnGenzhu:setVisible(_gamePublic:_and(op, _gamePublic.eOp_Type.eOp_FollowBet) > 0)
		self.btnQiPai:setVisible(_gamePublic:_and(op, _gamePublic.eOp_Type.eOp_Giveup) > 0)
		self.btnRangPai:setVisible(_gamePublic:_and(op, _gamePublic.eOp_Type.eOp_PassBet) > 0)

		if _gamePublic:_and(op, _gamePublic.eOp_Type.eOp_Suoha) > 0
				and  _gamePublic:_and(op, _gamePublic.eOp_Type.eOp_AddBet) == 0
		then
			self.btnAllIn:show()
			self.btnJiazhu:hide()

			for i = 0, 3 do
				self.quickJiaZhuBtn[i]:setEnabled(false)
				self.quickJiaZhuBtn[i]:setOpacity(100)
			end
		else
			self.btnAllIn:hide()
			self.btnJiazhu:show()
		end


		if app.gameLayer.isAllIn
				and _gamePublic:_and(op, _gamePublic.eOp_Type.eOp_PassBet) == 0
				and _gamePublic:_and(op, _gamePublic.eOp_Type.eOp_AddBet) == 0
				and _gamePublic:_and(op, _gamePublic.eOp_Type.eOp_Suoha) >  0
		then			             -- 已 Allin
			self:OnBtnAllIn()
			return
		end

		if app.gameLayer.bPreinstall[0] then	-- 看  或  弃
			if _gamePublic:_and(op, _gamePublic.eOp_Type.eOp_PassBet) > 0 then
				self:OnBtnRangPai()
			elseif _gamePublic:_and(op, _gamePublic.eOp_Type.eOp_Giveup) > 0 then
				self:OnBtnQiPai()
			end
			app.gameLayer.bPreinstall[0] = false
		end
		if app.gameLayer.bPreinstall[1] then 	-- 跟任何
			if app.gameLayer.lastAllGiveUp then
				app.gameLayer.bPreinstall[1] = false
			elseif app.gameLayer.lastAllPass then
				self:OnBtnRangPai()
				app.gameLayer.bPreinstall[1] = false
			else
				if _gamePublic:_and(op, _gamePublic.eOp_Type.eOp_FollowBet) > 0 then
					self:OnBtnGenZhu()
					app.gameLayer.bPreinstall[1] = false
				elseif _gamePublic:_and(op, _gamePublic.eOp_Type.eOp_PassBet) > 0 then
					self:OnBtnRangPai()
					app.gameLayer.bPreinstall[1] = false
				elseif _gamePublic:_and(op, _gamePublic.eOp_Type.eOp_Suoha) > 0 then
					self:OnBtnAllIn()
					app.gameLayer.bPreinstall[1] = false
				end
			end
		end
	end
end

-- 操作完成之后
function GameViewController:OnOperCompleted()
	self.operateNode:hide()

	self.jiaZhuSlider:hide()
	self.AllInFrame:hide()
	self.AllInFrame:stopAllActions()
	self.btnJiaZhuNum:hide()
	self.quickJiaZhuNode:hide()
	self.btnJiazhu:show()
	self.preinstallNode:getChildByName("CheckBox_kan_or_qi"):setSelected(false)
	self.preinstallNode:getChildByName("CheckBox_gen_ren_yi"):setSelected(false)

	local imgAllInNormal = self.jiaZhuSlider:getChildByName("Image_normal"):show()
	local imgAllInShow = self.jiaZhuSlider:getChildByName("Image_show_all_in"):hide()

	local layRoof = findWidget("Node_back_ground"):getChildByName("Panel_roof"):hide()
	if self.ImgPaixing:isVisible() then
		layRoof:show()
	end

	if app.gameLayer.userInfoLayer:isVisible() then
		layRoof:show()
	end
end

function GameViewController:procUI( )	
	self:procBtns()
	self:procUserInfo()
end


function GameViewController:procUserInfo()
	
end

function GameViewController:resetUIAfterStart()

end

function GameViewController:resetUIAfterOver()
	self.btnChange:show()
	self.btnLeave:show()
	self.btnReady:show()

end

function GameViewController:procBtns()
	self:procBtnReady()
	self:procBtnChange()
	self:procBtnLeave()
	--self:procBtnOp()
	self:procBtnSet()
end

function GameViewController:procBtnReady()
	local btnReady = findWidget("Button_ready"):show()
	btnReady:setLocalZOrder(11)
	if app.isTest then
		btnReady:hide()
	end
	if cc.dataMgr.isBroken then
		btnReady:hide()
	end
	btnReady:setPressedActionEnabled(true)
	local function onBtnReady(object, event)
		if event == cc.EventCode.ENDED then
			app.audioPlayer:playClickBtnEffect()
			app.holdOn.show("正在准备中...", 1)
       	    cc.lobbyController:sendHandUpReq()
			app.gameLayer.cardsLayer:removeAllCards()
			app.gameLayer.cardsTouchLayer:show()
		end
	end
	btnReady:addTouchEventListener(onBtnReady)
	self.btnReady = btnReady
end

function GameViewController:procBtnChange()
	local btnChange = findWidget("Button_change_table"):show()
	btnChange:setLocalZOrder(11)
	if app.isTest then
		btnChange:hide()
	end
	if cc.dataMgr.isBroken then
		btnChange:hide()
	end
	btnChange:setPressedActionEnabled(true)
	local function onBtnChange(object, event)
		if event == cc.EventCode.ENDED then
			app.audioPlayer:playClickBtnEffect()
			-- 离开桌子
			cc.lobbyController:sendLeaveTableReq()
			--app.exitGameSceneSkip()
			app.sceneSwitcher:enterScene("RoomScene")

			-- 快速加入
			--app.toast.show("正在查询最佳桌子...", 0.5)
			cc.lobbyController:sendFastJoinReq()
		end
	end
	btnChange:addTouchEventListener(onBtnChange)
	self.btnChange = btnChange
end

function GameViewController:procBtnLeave()
 	local leavebtn = findWidget("Button_leave_table"):show()
	leavebtn:setLocalZOrder(11)
	if app.isTest then
		leavebtn:hide()
	end
	if cc.dataMgr.isBroken then
		leavebtn:hide()
	end
   	local function onBtnleave(object, event)
       	if event == cc.EventCode.ENDED then
			app.audioPlayer:playClickBtnEffect()
       		if app.bGaming then
       			app.toast.show("很抱歉,游戏中不能退出")
       		else
       			print("<==== onBtnleave")
       			cc.lobbyController:sendLeaveTableReq()
            	app.sceneSwitcher:enterScene("RoomScene")
				--app.exitGameSceneSkip()
       		end
        end
    end
	leavebtn:addTouchEventListener(onBtnleave)
    self.btnLeave = leavebtn
end

function GameViewController:getTime()
	local tm = os.date("*t")
	local strTime = string.format("%02d:%02d:%02d", tm.hour, tm.min, tm.sec)
	self.timeshow:setString(strTime)
end

function GameViewController:procBtnSet()
	--local nodeSet = findWidget("ProjectNode_Set"):show():setLocalZOrder(50)
	local btnOpen = findWidget("Button_func_key"):show()
	local imgSetBg = findWidget("Image_function_key_click"):hide()
	self.btnPopOut = btnOpen
	self.btnPopIn = imgSetBg
	btnOpen:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			imgSetBg:show()
			btnOpen:hide()
		end
	end)

	local btnPopIn = imgSetBg:getChildByName("Image_PopIn"):show()
	btnPopIn:setTouchEnabled(true)
	btnPopIn:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			imgSetBg:hide()
			btnOpen:show()
		end
	end)

	local btnChat = imgSetBg:getChildByName("Button_chat"):hide()
	btnChat:setPressedActionEnabled(true)
	btnChat:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			if not cc.dataMgr.isWatcher then
				app.gameLayer.chatLayer:show()
			end
		end
	end)

	local btnSetting = imgSetBg:getChildByName("Button_set")
	btnSetting:setPressedActionEnabled(true)
	btnSetting:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			app.gameLayer.settingLayer:show()
		end
	end)

	local btnTrust = imgSetBg:getChildByName("Button_truste")
	btnTrust:setPressedActionEnabled(true)
	btnTrust:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			if app.bGaming and not cc.dataMgr.isWatcher then
					app.gameLayer:OnTruste()
			end
		end
	end)

	local btnleave = imgSetBg:getChildByName("Button_leave")
	btnleave:setPressedActionEnabled(true)
	btnleave:addTouchEventListener(function (object, event)
		if event == cc.EventCode.ENDED then
			app.audioPlayer:playClickBtnEffect()
			if app.bGaming == true and not cc.dataMgr.isWatcher then
				app.toast.show("很抱歉,游戏中不能退出")
			else
				print("<=== 123123")
				cc.lobbyController:sendLeaveTableReq()
				app.sceneSwitcher:enterScene("RoomScene")
				--app.exitGameSceneSkip()
			end
		end
	end)
end

function GameViewController:setBet(data)
	self.bet = data
	self.betNum:setString(string.format("%d", self.bet))
end

return GameViewController