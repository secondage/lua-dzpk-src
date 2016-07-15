--
-- Author: ChenShao
-- Date: 2015-08-20 09:42:36
--
local LotteryDrawCtrlLayer = class("LotteryDrawCtrlLayer")
local httpUtils = require("app.func.HttpUtils")
local inputUtil = require("app.func.InputUtil")

local drawStrUrl_small = urls.drawStrUrl_small
local drawRunUrl_small = urls.drawRunUrl_small
local drawMyAwardUrl_small = urls.drawMyAwardUrl_small

local drawStrUrl = urls.drawStrUrl
local drawRunUrl = urls.drawRunUrl
local drawMyAwardUrl = urls.drawMyAwardUrl

local confirmAddressUrl = urls.confirmAddressUrl
local confirmAddressUrl_Small = urls.confirmAddressUrl_Small

local updateAddressUrl = urls.updateAddressUrl
local updateAddressUrl_Small = urls.updateAddressUrl_Small

local json = require("framework.json")
local inputLimit = require("app.func.InputUtil")

local iconv = require "iconv"
local encoding = iconv.new("gbk", "utf-8") -- utf8-->gbk for URL or Webapi



local _isSmall = false

local awardData = {
	[1] = 0,
	[2] = 288,
	[3] = 216,
	[4] = 144,
	[5] = 72,
	[6] = 36,
	[7] = 108,
	[8] = 180,
	[9] = 252,
	[10] = 324
}

local function isSmall()
	return _isSmall
end

local function updateYuanBao(self)
	if cc.dataMgr.userInfoMore.ingot then
		self.txtYuanBao:setString("元宝:" ..cc.dataMgr.userInfoMore.ingot.l)
	end
end

local function decode(str)
	local s = string.gsub(str, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
	return s
end

local function encode(str)
	--return encoding:iconv(str)
	local s = string.gsub(str, "([^%w%.%-])", function(c) return string.format("%%%02X", string.byte(c)) end)
	return string.gsub(s, " ", "+")
end

local function getPngVersionLocal()
	if _isSmall then
		return  cc.UserDefault:getInstance():getStringForKey("drawPngVersion_small", 1)
	end
	return cc.UserDefault:getInstance():getStringForKey("drawPngVersion", 1)
end

local function updateAwardListUI(self, myInfo)
	self.listViewDrawHistory:removeAllItems()
	local lastlogs = myInfo.LastLogs
	if #lastlogs > 0 then self.listViewDrawHistory:show() end
	for i = 1, #lastlogs do
		local itemClone = self.txtDrawHistoryItem:clone()
		local nickName = inputUtil.getReducedString(lastlogs[i].NickName, 10, "..")
		itemClone:show():setString(nickName .."抽中" ..lastlogs[i].AwardName)
		self.listViewDrawHistory:pushBackCustomItem(itemClone)
	end
end

function LotteryDrawCtrlLayer:procLayAddressInfo()
	local imgAddressbg = self.layAddressInput:getChildByName("Image_addressinfo")
	imgAddressbg:setTouchEnabled(true)
	local tfNameTmp = imgAddressbg:getChildByName("TextField_name"):hide()
	tfName = app.EditBoxFactory:createEditBoxByImage(tfNameTmp, "请输入联系人")
	self.tfName = tfName

	local tfTelTmp = imgAddressbg:getChildByName("TextField_tel"):hide()
	tfTel = app.EditBoxFactory:createEditBoxByImage(tfTelTmp, "请输入电话")
	self.tfTel = tfTel
	tfTel:setInputMode(2)
	tfTel:setMaxLength(11)

	local txtAddress = imgAddressbg:getChildByName("TextField_addressShow")
	txtAddress:setColor(display.COLOR_BLACK)
	self.txtAddress = txtAddress
	local tfAddressTmp = imgAddressbg:getChildByName("TextField_addressInput")
	tfAddress = app.EditBoxFactory:createEditBoxByImage(tfAddressTmp, "请输入收货地址", nil, 46)
	self.tfAddress = tfAddress

	local tfPostTmp = imgAddressbg:getChildByName("TextField_tel_1")
	tfPost = app.EditBoxFactory:createEditBoxByImage(tfPostTmp, "请输入邮编")
	self.tfPost = tfPost
	tfPost:setInputMode(2)
	tfPost:setMaxLength(6)

	local imgTel = self.layTelInput:getChildByName("Image_tel")
	local tfTel_ = imgTel:getChildByName("TextField_tel")
	tfTel_:setMaxLength(11)
	tfTel_:setColor(cc.c4b(0, 0, 0, 255))
	self.tfTel_ = tfTel_
end

function LotteryDrawCtrlLayer:setAddreddInfo(myInfo)
	
	local imgAddressbg = self.layAddressInput:getChildByName("Image_addressinfo")
	imgAddressbg:setTouchEnabled(true)
	--[[local tfNameTmp = imgAddressbg:getChildByName("TextField_name"):hide()
	tfName = app.EditBoxFactory:createEditBoxByImage(tfNameTmp, "请输入联系人")
	self.tfName = tfName]]

	tfName = self.tfName

	--[[local tfTelTmp = imgAddressbg:getChildByName("TextField_tel"):hide()
	tfTel = app.EditBoxFactory:createEditBoxByImage(tfTelTmp, "请输入电话")
	self.tfTel = tfTel
	tfTel:setInputMode(2)
	tfTel:setMaxLength(11)]]

	tfTel = self.tfTel

	--[[local txtAddress = imgAddressbg:getChildByName("TextField_addressShow")
	txtAddress:setColor(display.COLOR_BLACK)
	local tfAddressTmp = imgAddressbg:getChildByName("TextField_addressInput")
	tfAddress = app.EditBoxFactory:createEditBoxByImage(tfAddressTmp, "请输入收货地址")
	self.tfAddress = tfAddress]]

	txtAddress = self.txtAddress
	tfAddress = self.tfAddress

	tfAddress:registerScriptEditBoxHandler(function(name, sender)
		print("name = " ..name)
		if name == "began" then
			self.username = ""
		elseif name == "changed" then
			local txt =  sender:getString()
			txtAddress:setString(txt)
		elseif name == "ended" then
			
		end
	end)

	--[[local tfPostTmp = imgAddressbg:getChildByName("TextField_tel_1")
	tfPost = app.EditBoxFactory:createEditBoxByImage(tfPostTmp, "请输入邮编")
	self.tfPost = tfPost
	tfPost:setInputMode(2)
	tfPost:setMaxLength(6)]]
	tfPost = self.tfPost



	--[[local btnClose = imgAddressbg:getChildByName("Button_close")
	btnClose:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			self.layAddressInput:hide()
		end
	end)]]

	--[[local imgTel = self.layTelInput:getChildByName("Image_tel")
	local tfTel_ = imgTel:getChildByName("TextField_tel")
	tfTel_:setMaxLength(11)
	tfTel_:setColor(cc.c4b(0, 0, 0, 255))
	self.tfTel_ = tfTel_]]

	local imgTel = self.layTelInput:getChildByName("Image_tel")
	tfTel_ = self.tfTel_

	local btnClose_ = imgTel:getChildByName("Button_close")
	btnClose_:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			self.layTelInput:hide()
		end
	end)

	if myInfo then 
		tfName:setString(myInfo.ContactName)
		tfTel:setString(myInfo.ContactTel)
		txtAddress:setString(myInfo.PostAddress)
		tfAddress:setString(myInfo.PostAddress)
		tfPost:setString(myInfo.PostCode)
		tfTel_:setString(myInfo.ContactTel)
	end

	self.awardType = 3
	self.logId = 0

	local function btnOKEvt(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()

			local srtUrl = ""
			if self.logId ~= 0 then --抽奖后确认信息
				if isSmall() then
					srtUrl = confirmAddressUrl_Small
				else
					srtUrl = confirmAddressUrl
				end
			else --修改信息
				if isSmall() then
					srtUrl = updateAddressUrl_Small
				else
					srtUrl = updateAddressUrl
				end
			end

			local url = ""
			if self.awardType == 1 then
				local strTel = tfTel_:getString()
				if strTel == "" then
					app.toast.show("联系号码不能为空")
					return
				end

				url = srtUrl .."?ContactTel=" ..encode(strTel) 
							 .."&UserId=" ..encode(cc.dataMgr.lobbyLoginData.userID)
							

				if self.logId ~= 0 then
					url = url .."&logId=" ..encode(self.logId)
				else
					url = url
				end
			else
				local strName = tfName:getString()
				local strTel = tfTel:getString()
				local strAddredd = txtAddress:getString()
				local strPost = tfPost:getString()
				if strName == "" or strTel =="" or strAddredd == "" or strPost == "" then
					app.toast.show("信息填写不完整")
					return
				end

				local inputCheck = require("app.func.InputCheck")
				if not inputCheck.checkIsNumberOnly(strTel) then
					app.toast.show("手机号填写不正确")
					return
				end
				if string.len(strTel) ~= 11 then
					app.toast.show("手机号填写不正确")
					return
				end

				if not inputCheck.checkIsNumberOnly(strPost) then
					app.toast.show("邮编填写不正确")
					return
				end
				if string.len(strPost) ~= 6 then
					app.toast.show("邮编填写不正确")
					return
				end
	 
				url = srtUrl .."?UserId=" ..encode(cc.dataMgr.lobbyLoginData.userID)
							 .."&ContactName=" ..encode(strName)
							 .."&ContactTel=" ..encode(strTel)
							 .."&PostAddress=" ..encode(strAddredd)
							 .."&PostCode=" ..encode(strPost)
			end

			if self.logId ~= 0 then
				url = url .."&logId=" ..encode(self.logId)
			else
				url = url
			end
			print("url = " ..url)

			httpUtils.reqHttp(url, function(ret, response)
				if self.isExitLayer then return end
				if ret then
					print("response" ..response)
					local info = json.decode(response)
					if info.IsSuccessed == true then
						
						if self.logId ~= 0 then
							app.toast.show("领取成功")
							--self.layAddressInput:hide()
							self.layTelInput:hide()
							self:reqMyAward()
						else
							app.toast.show("个人信息修改成功")
						end
					else
						app.toast.show(info.Message)
					end
					
					


				end
			end, true)
		end
	end

	local btnOK = imgAddressbg:getChildByName("Button_23")
	btnOK:setPressedActionEnabled(true)
	local btnOK_ = imgTel:getChildByName("Button_23")
	btnOK_:setPressedActionEnabled(true)

	btnOK:addTouchEventListener(btnOKEvt)
	btnOK_:addTouchEventListener(btnOKEvt)
end

local function reqAwardList(self)
	local strUrl = drawStrUrl
	if _isSmall then
		strUrl = drawStrUrl_small
	end

	httpUtils.reqHttp(strUrl ..encode(cc.dataMgr.lobbyLoginData.userID), function(ret, response)
		if self.isExitLayer then return end
		if ret then
			local myInfo = json.decode(response)
			--dump(myInfo)
			updateAwardListUI(self, myInfo)
		end
	end, true)

end

local function readInfoFromServer(self, callSwitchResult)
	app.holdOn.show("正在读取抽奖信息...")
	local strUrl = drawStrUrl
	local fileName = "Show.png"
	local strPngVersion = "drawPngVersion"

	if _isSmall then
		strUrl = drawStrUrl_small
		fileName = "Show_small.png"
		strPngVersion = "drawPngVersion_small"
	end
	
	strUrl = strUrl ..encode(cc.dataMgr.lobbyLoginData.userID)
	print("draw url = " ..strUrl)
	httpUtils.reqHttp(strUrl, function(ret, response)
		app.holdOn.hide()
		if self.isExitLayer then return end
		if ret then
			local myInfo = json.decode(response)
			--dump(myInfo)
			updateAwardListUI(self, myInfo)
			self:setAddreddInfo(myInfo.Address, _isSmall)

			local btnDrawImageUrl = myInfo.ButtionImageUrl
			local wheelImageUrl = myInfo.WheelImageUrl

			if btnDrawImageUrl == nil or wheelImageUrl == nil then
				return
			end

			local s, e = string.find(btnDrawImageUrl , "md5=")
			local btnDrawImageName = string.sub(btnDrawImageUrl, e + 1) ..".png"
			local btnDrawImageFilePath = cc.FileUtils:getInstance():getWritablePath() ..btnDrawImageName

			local s1, e1 = string.find(wheelImageUrl , "md5=")
			local wheelImageName = string.sub(wheelImageUrl, e1 + 1) ..".png"
			local wheelImageFilePath = cc.FileUtils:getInstance():getWritablePath() ..wheelImageName

			local function downloadGoodsPhoto(downloadUrl, filePath, callback)
				print("downloadUrl = " ..downloadUrl)
				httpUtils.reqHttp(downloadUrl, function(ret, response)
					if self.isExitLayer then return end
					if ret then
						if string.len(response) < 100 then
							callback(1) --没有对应文件
							return
						end
						
						local file = io.open(filePath, "wb+")
						if file then
							file:write(response)
							file:close()
							callback(0)
						else
							print("no file")
							callback(1)
						end
					else
						print("no 回复")
						callback(1)
					end
				end)
			end

			if cc.FileUtils:getInstance():isFileExist(btnDrawImageFilePath) then
				self.btnDraw:loadTextures(btnDrawImageFilePath, btnDrawImageFilePath, "")
				self.targetTextures[#self.targetTextures + 1] = btnDrawImageFilePath
				self.btnDraw:show()
				if callSwitchResult then
					callSwitchResult(true)
				end
			else
				downloadGoodsPhoto(btnDrawImageUrl, btnDrawImageFilePath, function(isSuccess)
					if isSuccess == 0 then
						self.btnDraw:loadTextures(btnDrawImageFilePath, btnDrawImageFilePath, "")
						self.targetTextures[#self.targetTextures + 1] = btnDrawImageFilePath
						self.btnDraw:show()
						if callSwitchResult then
							callSwitchResult(true)
						end
					end
				end)	
			end

			if cc.FileUtils:getInstance():isFileExist(wheelImageFilePath) then
				self.imgTray:loadTexture(wheelImageFilePath)
				self.targetTextures[#self.targetTextures + 1] = wheelImageFilePath
				self.imgTray:show()
				if callSwitchResult then
					callSwitchResult(true)
				end
			else
				downloadGoodsPhoto(wheelImageUrl, wheelImageFilePath, function(isSuccess)
					if isSuccess == 0 then
						self.imgTray:loadTexture(wheelImageFilePath)
						self.targetTextures[#self.targetTextures + 1] = wheelImageFilePath
						self.imgTray:show()
						if callSwitchResult then
							callSwitchResult(true)
						end
					end
				end)
			end
		end
	end, true)
end

local function banBtn(btn)
	btn:setTouchEnabled(false)
	--btn:setBright(false)
end

local function pickBtn(btn)
	btn:setTouchEnabled(true)
	btn:setBright(true)
end

local function lotterTrayAction(self, drawRet)
	banBtn(self.btnDraw)
	banBtn(self.btnToBigTray)
	banBtn(self.btnToSmallTray)

	if cc.dataMgr.userInfoMore.ingot then
		cc.dataMgr.userInfoMore.ingot.l = drawRet.yuanbao
	end
	local afterStopFunc = cc.CallFunc:create(function()
		app.holdOn.hide()
		updateYuanBao(self)
		app.toast.show("恭喜您获得 " ..drawRet.awardName)
		reqAwardList(self)
		self.logId = drawRet.logId
		if drawRet.awardCategoryId == 1 then --话费
			self.layTelInput:show()
			self.awardType = 1
		elseif drawRet.awardCategoryId == 2 then  --实物
			self.layAddressInput:show()
			self.btnReturnHall:hide()
			self.btnReturn:show()
			self.awardType = 2
		end
	end)

	app.holdOn.show("抽奖中...")
	self.imgTray:setRotation(0)
	local action = cc.EaseExponentialOut:create(cc.RotateBy:create(5, awardData[drawRet.level] + 1800))
	self.imgTray:runAction(cc.Sequence:create(action, cc.CallFunc:create(function()
			local delayTime = cc.DelayTime:create(1.5)
			local callfc = cc.CallFunc:create(function()
				pickBtn(self.btnDraw)
				pickBtn(self.btnToBigTray)
				pickBtn(self.btnToSmallTray)
			end)
			self.lotteryLayer:runAction(cc.Sequence:create(delayTime, callfc))
		end), afterStopFunc))
end

function LotteryDrawCtrlLayer:updateMyAwardListUI(info)
	self.layMyAwardList:show()
	self.checkBoxMyAward:setSelected(true)
	self.checkBoxMyAward:setTouchEnabled(false)
	self.checkBoxMyInfo:setSelected(false)
	self.checkBoxMyInfo:setTouchEnabled(true)
	local layAwardItem = self.layMyAwardList:getChildByName("Panel_item"):hide()

	if #info == 0 then
		app.toast.show("您还未有获奖记录")
		return
	end

	--[[local btnClose = self.layMyAwardList:getChildByName("Image_bg"):getChildByName("Button_close")
	btnClose:addTouchEventListener(function (obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			self.layMyAwardList:hide()
		end
	end)]]
	local listViewMyAward = self.layMyAwardList:getChildByName("Image_bg"):getChildByName("ListView_myAwardList")
	listViewMyAward:removeAllItems()
	--local layAwardItem = self.layMyAwardList:getChildByName("Panel_item"):hide()

	for i = 1, #info do
		local itemClone = layAwardItem:clone():show()
		local txtTime = itemClone:getChildByName("Text_time")
		txtTime:setString(info[i].HandleTime)
		local txtAward = itemClone:getChildByName("Text_award")
		txtAward:setString(info[i].AwardName)

		local btnOK = itemClone:getChildByName("Text_state")
		btnOK:setTouchEnabled(true)
		btnOK:addTouchEventListener(function(obj, type)
			if type == 2 then
				app.audioPlayer:playClickBtnEffect()
				local srtUrl = confirmAddressUrl
				if _isSmall then
					srtUrl = confirmAddressUrl_Small
				end

				self.logId = info[i].Id
				local url = ""
				print("info[i].AwardCategoryId = " ..info[i].AwardCategoryId)
				if info[i].AwardCategoryId == 1 then
					self.layTelInput:show()
					self.awardType = 1
				elseif info[i].AwardCategoryId == 2 then
					self.layAddressInput:show()
					self.awardType = 2
				end		
			end
		end)

		self:setBtnsState(info[i].State, btnOK)

		listViewMyAward:pushBackCustomItem(itemClone)
	end
end

--设置发放 未发放 领取
function LotteryDrawCtrlLayer:setBtnsState(state, btnOK)
	if state == 2 then --
		btnOK:setString("已发放")
		btnOK:setColor(display.COLOR_BLACK)
		banBtn(btnOK)
	elseif state == 1 then --
		btnOK:setString("未发放")
		btnOK:setColor(display.COLOR_BLACK)
		banBtn(btnOK)
	elseif state == 0 then --
		btnOK:setString("未领取")
		btnOK:setColor(display.COLOR_BLUE)
		pickBtn(btnOK)
	end
end

function LotteryDrawCtrlLayer:reqMyAward()
	local url = drawMyAwardUrl
	if isSmall() then
		url = drawMyAwardUrl_small
	end
	print("url = " ..url)
	app.holdOn.show("正在获取已抽取的信息")
	httpUtils.reqHttp(url ..encode(cc.dataMgr.lobbyLoginData.userID), function(ret, response)
		if self.isExitLayer then return end
		app.holdOn.hide()
		if ret then
			local info = json.decode(response)
			print("my award")
			--dump(info)
			self.layAddressInput:hide()
			self:updateMyAwardListUI(info)
		end
	end, true)
end

local function procUI(self)

	self.layAddressInput = self.lotteryLayer:getChildByName("Panel_addressinfo"):hide()
	self.layAddressInput:setLocalZOrder(100)
	self.layAddressInput:setTouchEnabled(false)
	self.layTelInput = self.lotteryLayer:getChildByName("Panel_tel"):hide()
	self.layAddressInput:setLocalZOrder(100)
	self.layMyAwardList = self.lotteryLayer:getChildByName("Panel_myAwardList"):hide()
	self.layAddressInput:setLocalZOrder(50)
	self.layMyAwardList:setTouchEnabled(false)

	self:procLayAddressInfo()

	local layTelInput = self.layAddressInput:getChildByName("Image_telphone"):hide()


	self.layLottery = self.lotteryLayer:getChildByName("Panel_lottery"):show()
	self.layLottery:setTouchEnabled(false)
	self.imgLottery = self.layLottery:getChildByName("Image_backGound"):show()

	self.imgTray = self.imgLottery:getChildByName("Image_turntable"):hide()
	self.imgTray:ignoreContentAdaptWithSize(true)

	self.btnDraw = self.imgLottery:getChildByName("Button_draw"):hide()
	self.btnDraw:ignoreContentAdaptWithSize(true)
	self.btnDraw:addTouchEventListener(function (obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			print("start draw")
			app.holdOn.show("运气筹集中...")
			banBtn(self.btnDraw)
			local url = drawRunUrl ..encode(cc.dataMgr.lobbyLoginData.userID)
			if isSmall() then
				url = drawRunUrl_small ..encode(cc.dataMgr.lobbyLoginData.userID)
			end
			print("url = " ..url)
			httpUtils.reqHttp(url, function(ret, response)
				if self.isExitLayer then return end
				pickBtn(self.btnDraw)
				app.holdOn.hide()
				if ret then
					local info = json.decode(response)
					--dump(info)
					if info.IsSuccessed then
						lotterTrayAction(self, info.AppendData)
						
						app.shopLogic:upDateCurrencyInfo()

					else
						--app.toast.show(info.Message)
						app.msgBox.showMsgBox(info.Message)
					end
					
				end
			end, true)
		end
	end)


	

	--[[local function reqMyAward()
		local url = drawMyAwardUrl
		if isSmall() then
			url = drawMyAwardUrl_small
		end
		print("url = " ..url)
		app.holdOn.show("正在获取已抽取的信息")
		httpUtils.reqHttp(url ..encode(cc.dataMgr.lobbyLoginData.userID), function(ret, response)
			if self.isExitLayer then return end
			app.holdOn.hide()
			if ret then
				local info = json.decode(response)
				print("my award")
				--dump(info)
				self.layAddressInput:hide()
				self:updateMyAwardListUI(info)
			end
		end, true)
	end]]

	local imgBigTrayTitle = self.imgLottery:getChildByName("Image_big_title"):show()
	local imgSmallTrayTitle = self.imgLottery:getChildByName("Image_small_title"):hide()

	local btnToBigTray = self.imgLottery:getChildByName("Button_tobig"):hide()--切换到大转盘
	local btnToSmallTray = self.imgLottery:getChildByName("Button_tosmall"):show()--切换到小转盘
	self.btnToBigTray = btnToBigTray
	self.btnToBigTray.userdata = imgSmallTrayTitle
	self.btnToSmallTray = btnToSmallTray
	self.btnToSmallTray.userdata = imgBigTrayTitle
	btnToBigTray:addTouchEventListener(function (obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			_isSmall = false
			readInfoFromServer(self, function(result)
				if self.isExitLayer then return end
				btnToBigTray:hide()
				btnToBigTray.userdata:hide()
				btnToSmallTray:show()
				btnToSmallTray.userdata:show()
			end)	
		end
	end)
	btnToSmallTray:addTouchEventListener(function (obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			_isSmall = true
			readInfoFromServer(self, function(result)
				if self.isExitLayer then return end
				btnToSmallTray:hide()
				btnToSmallTray.userdata:hide()
				btnToBigTray:show()
				btnToBigTray.userdata:show()
			end)	
		end
	end)

	self.txtYuanBao = self.imgLottery:getChildByName("Image_yuanbaobg"):getChildByName("Text_myYuanbao"):show()

	--dump(cc.dataMgr.userInfoMore.ingot)
	updateYuanBao(self)
	

	self.txtDrawHistoryItem = self.imgLottery:getChildByName("Text_historyitem"):hide()

	self.listViewDrawHistory = self.imgLottery:getChildByName("ListView_drawhistory"):hide()
	self.listViewDrawHistory:setItemsMargin(10)

	local checkBoxLottery = self.lotteryLayer:getChildByName("CheckBox_lottery")
	local checkBoxMyAward = self.lotteryLayer:getChildByName("CheckBox_myAward")
	local checkBoxMyInfo = self.lotteryLayer:getChildByName("CheckBox_myInfo")
	checkBoxLottery:setSelected(true)
	checkBoxLottery:setTouchEnabled(false)
	checkBoxMyAward:setSelected(false)
	checkBoxMyInfo:setSelected(false)
	checkBoxMyAward.userdata = self.layMyAwardList
	checkBoxMyInfo.userdata = self.layAddressInput
	self.checkBoxMyAward = checkBoxMyAward
	self.checkBoxMyInfo = checkBoxMyInfo

	local imgTitle = self.lotteryLayer:getChildByName("Image_1")
	imgTitle:setTouchEnabled(true)

	local function checkBoxEvt(obj, type)
		print("11111111111")
		app.audioPlayer:playClickBtnEffect()
		if obj == checkBoxLottery then
			checkBoxLottery:setSelected(true)
			checkBoxLottery:setTouchEnabled(false)
			
			checkBoxMyAward:setSelected(false)
			checkBoxMyAward:setTouchEnabled(true)
			checkBoxMyAward.userdata:setVisible(false)
			
			checkBoxMyInfo:setTouchEnabled(false)
			checkBoxMyInfo:setTouchEnabled(true)
			checkBoxMyInfo.userdata:setVisible(false)
		elseif obj == checkBoxMyAward then
			checkBoxLottery:setSelected(false)
			checkBoxLottery:setTouchEnabled(true)
			
			checkBoxMyAward:setSelected(true)
			checkBoxMyAward:setTouchEnabled(false)
			checkBoxMyAward.userdata:setVisible(true)

			checkBoxMyInfo:setSelected(false)
			checkBoxMyInfo:setTouchEnabled(true)
			checkBoxMyInfo.userdata:setVisible(false)
			self:reqMyAward()
		elseif obj == checkBoxMyInfo then
			checkBoxLottery:setSelected(false)
			checkBoxLottery:setTouchEnabled(true)
			checkBoxMyAward:setSelected(false)
			checkBoxMyAward:setTouchEnabled(true)
			checkBoxMyInfo:setSelected(true)
			checkBoxMyInfo:setTouchEnabled(false)
			checkBoxMyAward.userdata:setVisible(false)
			checkBoxMyInfo.userdata:setVisible(true)
		end
		--self.btnReturnHall:hide()
		--self.btnReturn:show()
	end
	checkBoxLottery:addEventListener(checkBoxEvt)
	checkBoxMyAward:addEventListener(checkBoxEvt)
	checkBoxMyInfo:addEventListener(checkBoxEvt)
		
	self.btnReturnHall = self.lotteryLayer:getChildByName("Button_returnHall")
	self.btnReturnHall:setPressedActionEnabled(true)
	self.btnReturnHall:show()
	self.btnReturnHall:addTouchEventListener(function (obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			self.lotteryLayer:removeSelf()
			app.hallScene.lotteryLayer = nil

			app.hallScene:showHallUI()
		end
	end)

	self.btnReturn = self.lotteryLayer:getChildByName("Button_return")
	self.btnReturn:setPressedActionEnabled(true)
	self.btnReturn:hide()
	self.btnReturn:addTouchEventListener(function (obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			self.btnReturnHall:show()
			self.btnReturn:hide()

			checkBoxMyAward:setSelected(false)
			checkBoxMyInfo:setSelected(false)
			checkBoxMyAward.userdata:setVisible(false)
			checkBoxMyInfo.userdata:setVisible(false)
			checkBoxMyAward:setTouchEnabled(true)
			checkBoxMyInfo:setTouchEnabled(true)
		end
	end)
end


function LotteryDrawCtrlLayer:createLayer()
	self.lotteryLayer = cc.CSLoader:createNode("Layers/LotteryDrawLayer.csb")
	procUI(self)
	_isSmall = false
	self.isBtnOkJumpToUserInfo = false
	readInfoFromServer(self)

	self.targetTextures = {}
	self:addTextures()

	self.isExitLayer = false
	self.lotteryLayer:onNodeEvent("exit", function()
		print("<------exit self.lotteryLayer")
		self.isExitLayer = true
		self:removeUnusedTextures()
	end)
	return self.lotteryLayer
end

function LotteryDrawCtrlLayer:addTextures()
	self.targetTextures[#self.targetTextures + 1] = "Resources/newResources/Lottery/small_tray.png"
	self.targetTextures[#self.targetTextures + 1] = "Resources/newResources/Lottery/big_tray.png"
	self.targetTextures[#self.targetTextures + 1] = "Resources/newResources/Lottery/pingtai.png"
	self.targetTextures[#self.targetTextures + 1] = "Resources/newResources/Lottery/girl.png"
	self.targetTextures[#self.targetTextures + 1] = "Resources/newResources/Lottery/waikuang.png"
end

function LotteryDrawCtrlLayer:removeUnusedTextures()
	for _, strTexture in pairs(self.targetTextures) do
		cc.Director:getInstance():getTextureCache():removeTextureForKey(strTexture)
	end
end

return LotteryDrawCtrlLayer