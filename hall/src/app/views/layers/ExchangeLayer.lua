--
-- Author: ChenShao
-- Date: 2015-10-27 13:50:26
--
local ExchangeLayerCtrller = class("ExchangeLayerCtrller")
local httpUtils = require("app.func.HttpUtils")
local iconv = require "iconv"
local encoding = iconv.new("gbk", "utf-8") -- utf8-->gbk for URL or Webapi
local json = require("framework.json")
local scheduler = require("framework.scheduler")
local inputUtil = require("app.func.InputUtil")

local _onceReqCount = 3

local function encode(str)
	local targetPlatform = cc.Application:getInstance():getTargetPlatform()
	if cc.PLATFORM_OS_ANDROID == PLATFORM_OS_WINDOWS then
		return str
	else
		local s = string.gsub(str, "([^%w%.%-])", function(c) return string.format("%%%02X", string.byte(c)) end)
		return string.gsub(s, " ", "+")
	end	
end

local function showGoodsDetail(self, data)
	if data.Quantity <= 0 then
		app.toast.show("抱歉,该商品已兑换完")
		return
	end

	self.imgGoodsDetail:show()
	app.popLayer.show(self.imgGoodsDetail)
	self.touchLayer:hide()

	--dump(data)
	--[[
	data.Summary = "阿斯蒂芬\n" ..
			"阿斯顿发阿斯顿发斯蒂芬阿斯顿发阿斯顿发斯芬阿斯顿发\n阿斯顿发斯蒂芬阿斯顿发阿斯顿发斯蒂芬阿斯顿发阿斯顿\n" ..
			"阿斯顿发阿斯顿发斯蒂芬阿斯顿发阿斯顿发斯芬阿斯顿发\n阿斯顿发斯蒂芬阿斯顿发阿斯顿发斯蒂芬阿斯顿发阿斯顿\n" ..
			"阿斯顿发阿斯顿发斯蒂芬阿斯顿发阿斯顿发斯芬阿斯顿发\n阿斯顿发斯蒂芬阿斯顿发阿斯顿发斯蒂芬阿斯顿发阿斯顿\n" ..
			"阿斯顿发阿斯顿发斯蒂芬阿斯顿发阿斯顿发斯芬阿斯顿发\n阿斯顿发斯蒂芬阿斯顿发阿斯顿发斯蒂芬阿斯顿发阿斯顿\n" ..
			"阿斯顿发阿斯顿发斯蒂芬阿斯顿发阿斯顿发斯芬阿斯顿发\n阿斯顿发斯蒂芬阿斯顿发阿斯顿发斯蒂芬阿斯顿发阿斯顿\n" ..
			"阿斯顿发阿斯顿发斯蒂芬阿斯顿发阿斯顿发斯芬阿斯顿发\n阿斯顿发斯蒂芬阿斯顿发阿斯顿发斯蒂芬阿斯顿发阿斯顿\n" ..
			"阿斯顿发阿斯顿发斯蒂芬阿斯顿发阿斯顿发斯芬阿斯顿发\n阿斯顿发斯蒂芬阿斯顿发阿斯顿发斯蒂芬阿斯顿发阿斯顿\n" ..
			"阿斯顿发阿斯顿发斯蒂芬阿斯顿发阿斯顿发斯芬阿斯顿发\n阿斯顿发斯蒂芬阿斯顿发阿斯顿发斯蒂芬阿斯顿发阿斯顿\n" ..
			"阿斯顿发阿斯顿发斯蒂芬阿斯顿发阿斯顿发斯芬阿斯顿发\n阿斯顿发斯蒂芬阿斯顿发阿斯顿发斯蒂芬阿斯顿发阿斯顿\n" ..
			"阿斯顿发阿斯顿发斯蒂芬阿斯顿发阿斯顿发斯芬阿斯顿发\n阿斯顿发斯蒂芬阿斯顿发阿斯顿发斯蒂芬阿斯顿发阿斯顿"--]]
	local txtSummary = self.imgGoodsDetail:getChildByName("ListView_goods_summary"):getChildByName("Text_goods_summary")
	txtSummary:setString(data.Summary)

	local btnExchange = self.imgGoodsDetail:getChildByName("Button_exchange_again")
	btnExchange.userdata = {id = data.Id, ExchangePrice = data.ExchangePrice, CategoryId = data.CategoryId}

	local txtPs = self.imgGoodsDetail:getChildByName("Image_36_0"):hide()
	if data.CategoryId == 1 then --话费
		txtPs:show()
	end
end

local function downloadGoodsPhoto(self, downloadUrl, filePath, callback)

	downloadUrl = self.imgDownloadRoot ..downloadUrl
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

local function updateYuanBao(self)
	if cc.dataMgr.userInfoMore.ingot then
		self.txtYuanBao:setString("元宝:" ..cc.dataMgr.userInfoMore.ingot.l)
	end
end

local function updateDirection(self)
	print("self.curPage = " ..self.curPage)
	if self.curPage == 1 then
		self.upDirection:hide()
	elseif self.curPage > 1 then
		self.upDirection:show()
	end

	if self.curPage == self.pageCount then
		self.downDirection:hide()
	elseif self.curPage < self.pageCount then
		self.downDirection:show()
	end
end

local function convertFileName(fileName)
	local s, e = string.find(fileName , "/")
	return string.sub(fileName, s + 1, -1)
end

local function initGoodsItem(self, imgGoodsItem, data)
	imgGoodsItem:setName(data.Name)

	local goodsName = imgGoodsItem:getChildByName("Text_exchange_goods")
	local strName = inputUtil.getReducedString(data.Name, 12, "..")
	goodsName:setString(strName)

	local yuanbaoNeeded = imgGoodsItem:getChildByName("Text_exchange_need_yuanbao")
	yuanbaoNeeded:setString(data.ExchangePrice)

	local imgGoodsPhoto = imgGoodsItem:getChildByName("Image_goods_photo")

	convertFileName(data.SImg)
	local fileName = cc.FileUtils:getInstance():getWritablePath() ..convertFileName(data.SImg)
	if cc.FileUtils:getInstance():isFileExist(fileName) then
		print("read local photo")
		imgGoodsPhoto:loadTexture(fileName)
		self.targetTextures[#self.targetTextures + 1] = fileName
	else
		print("down load file =" ..fileName)
		local function callback(ret)
			if ret == 0 then
				print("下载photo")
				--print("fileName = " ..fileName)
				if  self.layGoods:getChildByName(data.Name) then
					imgGoodsPhoto:loadTexture(fileName)
					self.targetTextures[#self.targetTextures + 1] = fileName
				end
			else
				print("下载photo 无响应")
			end
		end
		downloadGoodsPhoto(self, data.SImg, fileName, callback)
	end

	local btnGoToDetail = imgGoodsItem:getChildByName("Button_exchange")
	btnGoToDetail:show()
	btnGoToDetail:setPressedActionEnabled(true)
	btnGoToDetail.userdata = data.Id
	btnGoToDetail:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			app.holdOn.show("正在获取商品详情...", 0.5)
			local url = urls.exchangeReqGoodsDetail ..obj.userdata
			print("url = " ..url)
			httpUtils.reqHttp(url, function(ret, response)
				if self.isExitLayer then return end
				if ret then
					app.holdOn.hide()
					local info = json.decode(response)
					--dump(info)

					showGoodsDetail(self, info.data)
				end
			end, true)
		end
	end)

end

local function removeOldGoods(self)
	for i = 1, 4 do
		self.layGoods:removeChildByTag(i)
	end
end

local function updateGoodsListView(self, data)
	local goodsNum = #data
	print("<---goodsNum = " ..goodsNum)

	
	removeOldGoods(self)
	for i = 1, goodsNum do
		local imgGoodsItemClone = self.imgGoodsItem:clone():show()

		initGoodsItem(self, imgGoodsItemClone, data[i])
		imgGoodsItemClone:addTo(self.layGoods)
		imgGoodsItemClone:setTag(i)
		imgGoodsItemClone:setPosition(self.ccpGoodsItem[i].x, self.ccpGoodsItem[i].y)
	end
	pickBtn(self.downDirection)
	pickBtn(self.upDirection)
end

local function reqExchangeGoodsList(self, page, pagesize)

	--已经请求过的页面，直接从内存中获取
	print("req page = " ..page)
	if self.goodsListReqed[page] then
		print("<--- read page local")
		self.curPage = page
		updateDirection(self)
		local data = self.goodsListReqed[page]
		updateGoodsListView(self, data)
		app.holdOn.hide()
		return
	end

	print("<--- read page server")
	app.holdOn.show("正在读取商品列表...")
	local url = urls.exchangeReqGoodsList .."page=" ..page .."&pagesize=" ..pagesize
	--url = "http://www.flgame-debug.net/Service/Exchange/Award?awardId=48473619-80fd-4d49-956d-ddaed091f3e2&TargetType=navTab"
	print("url = " ..url)
	httpUtils.reqHttp(url, function(ret, response)
		if self.isExitLayer then return end		
		if ret then
			app.holdOn.hide()
			local info = json.decode(response)
			--dump(info)
			--dump(info.data.Data)

			self.imgDownloadRoot = info.resourceBaseUrl
			self.pageCount = info.data.PageCount
			self.curPage = info.data.CurrentPageIndex
		
			self.goodsListReqed[self.curPage] = info.data.Data

			--dump(self.goodsListReqed)
			updateDirection(self)
			updateGoodsListView(self, info.data.Data)
		end
	end)
end

local function reqExchangeGoodsListOfOnce(self)
	reqExchangeGoodsList(self, self.reqPageIndex, _onceReqCount) 
end

local _gotoSelfLayer = 0 --地址 --1 电话
local function reqExchangeGoods(self, args, btnExchange)

	if args.exchangePrice > cc.dataMgr.userInfoMore.ingot.l then
		pickBtn(btnExchange)
		app.toast.show("您的元宝不足,无法兑换")
		return
	end

	local userid = cc.dataMgr.lobbyLoginData.userID
	local AwardId = args.goodsid
	local ContactName = self.nodeSelfInfoCtrller.tfName:getString()
	local ContactTel = self.nodeSelfInfoCtrller.tfTel:getString()
	local PostAddress = self.nodeSelfInfoCtrller.txtAddress:getString()
	local PostCode = self.nodeSelfInfoCtrller.tfPost:getString()



	if args.categoryId == 1 and ContactTel == "" then
		app.msgBox.showMsgBox("请前往个人信息界面填写手机号")
		self.imgGoodsDetail:hide()
		_gotoSelfLayer = 1
		return
	end

	if args.categoryId == 2 and PostAddress == "" then
		app.msgBox.showMsgBox("请前往个人信息界面完善并确认信息")
		self.imgGoodsDetail:hide()
		_gotoSelfLayer = 0
		return
	end

	local url = urls.reqExchageGoods .."?UserId=" ..userid
									.."&AwardId=" ..AwardId


	if args.categoryId == 1 then
		url = url .."&ContactTel=" ..ContactTel
	elseif args.categoryId == 2 then
		url = url .."&ContactName=" ..ContactName
			  .."&ContactTel=" ..ContactTel
			  .."&PostAddress=" ..PostAddress
			  .."&PostCode=" ..PostCode
	end



	print("url = " ..url)
	app.holdOn.show("兑换中...")
	httpUtils.reqHttp(url, function(ret, response)
		if self.isExitLayer then return end
		app.holdOn.hide()
		pickBtn(btnExchange)
		if ret then
			local info = json.decode(response)
			--dump(info)
			if info.IsSuccessed then
				cc.dataMgr.userInfoMore.ingot.l = cc.dataMgr.userInfoMore.ingot.l - args.exchangePrice
				app.shopLogic:upDateCurrencyInfo()
				updateYuanBao(self)
				self.imgGoodsDetail:hide()
				self.touchLayer:show()
			end
			app.msgBox.showMsgBox(info.Message)
			--app.toast.show(info.Message)
		end
	end, true)
end

local function procLayRecord(self)
	local nodeExchangeRecord = self.exchangeLayer:getChildByName("Node_exchange_record")
	local imgExchangeRecord = nodeExchangeRecord:getChildByName("Image_record_bg")
	local listViewRecord = imgExchangeRecord:getChildByName("ListView_record")
	self.listViewRecord = listViewRecord

	local layExchangeRecordItem = imgExchangeRecord:getChildByName("Panel_exchage_record_item"):hide()
	self.layExchangeRecordItem = layExchangeRecordItem

	local nodeExchangeCode = self.exchangeLayer:getChildByName("Node_exchange_code")
	local imgExchangeCode = nodeExchangeCode:getChildByName("Image_exchange_code")
	local listViewCode= imgExchangeCode:getChildByName("ListView_code")
	self.listViewCode = listViewCode

	local layExchangeCodeItem = imgExchangeCode:getChildByName("Panel_exchage_code_item"):hide()
	self.layExchangeCodeItem = layExchangeCodeItem
end

local function updateCodeUI(self, data)
	self.listViewCode:removeAllItems()

	for i = 1, #data do
		if data[i].State ~= -1 and data[i].Code ~= "" then
			local layExchangeCodeClone = self.layExchangeCodeItem:clone():show()
			local txtAward = layExchangeCodeClone:getChildByName("Text_award")
			local txtTime = layExchangeCodeClone:getChildByName("Text_time")
			local txtCode = layExchangeCodeClone:getChildByName("Text_code")

			txtAward:setString(data[i].AwardName)
			txtTime:setString(data[i].ExchangeTime)
			txtCode:setString(data[i].Code)

			self.listViewCode:insertCustomItem(layExchangeCodeClone, 0)
			--self.listViewCode:pushBackCustomItem(layExchangeCodeClone)
		end
	end
	scheduler.performWithDelayGlobal(function()
		if self.isExitLayer then return end
		self.listViewCode:jumpToTop()
	end, 0.1)
end

local function updateRecordUI(self, data)
	self.listViewRecord:removeAllItems()
	self.listViewRecord:show()

	for i = 1, #data do
		if data[i].State ~= -1 then
			local layExchangeRecordClone = self.layExchangeRecordItem:clone():show()
			local txtAward = layExchangeRecordClone:getChildByName("Text_award")
			local txtTime = layExchangeRecordClone:getChildByName("Text_time")
			local txtYuanBao = layExchangeRecordClone:getChildByName("Text_yuanbao")

			txtAward:setString(data[i].AwardName)
			txtTime:setString(data[i].ExchangeTime)
			txtYuanBao:setString(data[i].ExchangePrice)

			self.listViewRecord:insertCustomItem(layExchangeRecordClone, 0)
		end
		--self.listViewRecord:pushBackCustomItem(layExchangeRecordClone)
	end

	scheduler.performWithDelayGlobal(function()
		if self.isExitLayer then return end
		self.listViewRecord:jumpToTop()
	end, 0.1)
end

local function reqGetExchangeRecord(self)
	local url = urls.reqExchangeRecord ..cc.dataMgr.lobbyLoginData.userID
	print("reqGetExchangeRecord url = " ..url)
	httpUtils.reqHttp(url, function(ret, response)
		if self.isExitLayer then return end
		if ret then
			app.holdOn.hide()
			local info = json.decode(response)
			--dump(info)
			if #info == 0 then
				app.toast.show("暂无兑奖记录")
			else
				updateRecordUI(self, info)
				updateCodeUI(self, info)
			end		
		end
	end, true)
end

local function procLayUI(self)
	local nodeExchangeAward = self.exchangeLayer:getChildByName("Node_exchange_award"):show()
	local nodeExchangeRecord = self.exchangeLayer:getChildByName("Node_exchange_record"):hide()
	local nodeExchangeCode = self.exchangeLayer:getChildByName("Node_exchange_code"):hide()
	
	local nodeSelfInfoCtrller = require("app.views.layers.UserAddressInfoLayer")
	local nodeSelfInfo = nodeSelfInfoCtrller:createLayer()
	self.nodeSelfInfoCtrller = nodeSelfInfoCtrller

	nodeSelfInfo:addTo(self.exchangeLayer, 10)
	--self.exchangeLayer:getChildByName("Node_self_info"):hide()


	local checkBoxExchangeAward = self.exchangeLayer:getChildByName("CheckBox_exchange_award")
	--checkBoxExchangeAward.userdata = nodeExchangeAward
	local checkBoxExchangeRecord = self.exchangeLayer:getChildByName("CheckBox_exchange_record")
	--checkBoxExchangeRecord.userdata = nodeExchangeRecord
	local checkBoxExchangeCode = self.exchangeLayer:getChildByName("CheckBox_exchange_code")
	--checkBoxExchangeCode.userdata = nodeExchangeCode
	local checkBoxSelfInfo = self.exchangeLayer:getChildByName("CheckBox_self_info")
	--checkBoxSelfInfo.userdata = nodeSelfInfo

	--[[local groupCheckBox = {}
	groupCheckBox[#groupCheckBox + 1] = checkBoxExchangeAward
	groupCheckBox[#groupCheckBox + 1] = checkBoxExchangeRecord
	groupCheckBox[#groupCheckBox + 1] = checkBoxExchangeCode
	groupCheckBox[#groupCheckBox + 1] = checkBoxSelfInfo

	local function setCheckBoxSelected(obj)
		for _, checkbox in pairs(groupCheckBox) do
			checkbox:setSelected(false)
			checkbox:setEnabled(true)
			checkbox.userdata:hide()
		end

		obj:setSelected(true)
		obj:setEnabled(false)
		obj.userdata:show()
	
	end

	setCheckBoxSelected(checkBoxExchangeAward)]]

	local function checkBoxEvt(obj, type)
		print("type =" ..type)
		app.audioPlayer:playClickBtnEffect()
		--setCheckBoxSelected(obj)
		
		if type == 0 then
			self.touchLayer:hide()
			if obj == checkBoxExchangeRecord or obj == checkBoxExchangeCode then
				app.holdOn.showEx("正在获取兑换信息...", {delayTime = 0.5, listener = function()
					app.toast.show("连接超时")
					--setCheckBoxSelected(checkBoxExchangeAward)
				end})
				reqGetExchangeRecord(self)
				
			elseif obj == checkBoxSelfInfo then				
				nodeSelfInfoCtrller:showLayer(_gotoSelfLayer)
			elseif obj == checkBoxExchangeAward then
				self.touchLayer:show()
			end
		end

	
	end
	--[[for _, checkbox in pairs(groupCheckBox) do
		checkbox:addEventListener(checkBoxEvt)
	end]]

	local groupBox = require("app.func.GroupBox").new({
		{checkBox = checkBoxExchangeAward, node = nodeExchangeAward, callBack = checkBoxEvt },
		{checkBox = checkBoxExchangeRecord, node = nodeExchangeRecord, callBack = checkBoxEvt },
		{checkBox = checkBoxExchangeCode, node = nodeExchangeCode, callBack = checkBoxEvt },
		{checkBox = checkBoxSelfInfo, node = nodeSelfInfo, callBack = checkBoxEvt }
	})
end

local function procUI(self)
	local btnReturnHall = self.exchangeLayer:getChildByName("Button_returnHall")
	btnReturnHall:setPressedActionEnabled(true)
	btnReturnHall:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			self.exchangeLayer:removeSelf()
			if app.hallScene then
				app.hallScene.exchangeLayer = nil
				app.hallScene:showHallUI()
			end
		end
	end)

	procLayUI(self)
	procLayRecord(self)

	local nodeExchangeAward = self.exchangeLayer:getChildByName("Node_exchange_award")

	self.txtYuanBao = nodeExchangeAward:getChildByName("Image_yuanbao_bg"):getChildByName("Text_myYuanbao")
	updateYuanBao(self)

	self.layGoods = nodeExchangeAward:getChildByName("Panel_goods_item")
	
	self.imgGoodsItem = self.layGoods:getChildByName("Image_goods_item"):hide()

	self.imgGoodsDetail = nodeExchangeAward:getChildByName("Image_goods_detail"):hide()

	self.listViewGoodsDetail = self.imgGoodsDetail:getChildByName("ListView_goods_summary")
	--self.listViewGoodsDetail:pushBackDefaultItem()

	local btnCloseDetail = self.imgGoodsDetail:getChildByName("Button_close")
	btnCloseDetail:setPressedActionEnabled(true)
	btnCloseDetail:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			self.imgGoodsDetail:hide()
			self.touchLayer:show()
		end
	end)

	local btnExchange = self.imgGoodsDetail:getChildByName("Button_exchange_again")
	btnExchange:setPressedActionEnabled(true)
	btnExchange:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			local goodsid = obj.userdata.id
			local  exchangePrice = obj.userdata.ExchangePrice
			local categoryId = obj.userdata.CategoryId
			banBtn(btnExchange)
			reqExchangeGoods(self, {goodsid = goodsid, exchangePrice = exchangePrice, categoryId = categoryId}, btnExchange)
		end
	end)

	self.upDirection = nodeExchangeAward:getChildByName("Image_up"):hide()
	self.upDirection:setTouchEnabled(true)
	self.upDirection:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()	
			self:changePage(0)
		end
	end)
	self.downDirection = nodeExchangeAward:getChildByName("Image_down"):hide()
	self.downDirection:setTouchEnabled(true)
	self.downDirection:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			self:changePage(1)
		end
	end)

	local ccpImgGoodsItemX_1, ccpImgGoodsItemY_1 = self.layGoods:getChildByName("Image_goods_item"):hide():getPosition()
	local ccpImgGoodsItemX_2, ccpImgGoodsItemY_2 = self.layGoods:getChildByName("Image_goods_item_1"):hide():getPosition()
	local ccpImgGoodsItemX_3, ccpImgGoodsItemY_3= self.layGoods:getChildByName("Image_goods_item_2"):hide():getPosition()
	--local ccpImgGoodsItemX_4, ccpImgGoodsItemY_4 = self.layGoods:getChildByName("Image_goods_item_3"):hide():getPosition()

	--dump(ccpImgGoodsItem_1)

	self.ccpGoodsItem = {
		[1] = {x = ccpImgGoodsItemX_1, y = ccpImgGoodsItemY_1},
		[2] = {x = ccpImgGoodsItemX_2, y = ccpImgGoodsItemY_2},
		[3] = {x = ccpImgGoodsItemX_3, y = ccpImgGoodsItemY_3},
		--[4] = {x = ccpImgGoodsItemX_4, y = ccpImgGoodsItemY_4},
	}
end

function ExchangeLayerCtrller:changePage(type) --0 向上翻页
	--app.holdOn.show("加载中...")
	if type == 0 then
		banBtn(self.downDirection)
		banBtn(self.upDirection)
		print("req last page goods")
		self.reqPageIndex = self.reqPageIndex - 1
		reqExchangeGoodsListOfOnce(self)
	else
		banBtn(self.downDirection)
		banBtn(self.upDirection)
		print("req next page goods")
		self.reqPageIndex = self.reqPageIndex + 1
		reqExchangeGoodsListOfOnce(self)
	end
end

function ExchangeLayerCtrller:createTouchLayer()
	local touchLayer = display.newLayer():addTo(self.layGoods, 100)
	self.touchLayer = touchLayer
	touchLayer:setContentSize(cc.size(self.layGoods:getContentSize().width, self.layGoods:getContentSize().height))

	local function onTouchBegan(touch, event)
		if not self.touchLayer:isVisible() then
			return false
		end

		local locationInNode = touchLayer:convertToNodeSpace(touch:getLocation())
		if cc.rectContainsPoint(touchLayer:getBoundingBox(), locationInNode) then
			
			return true
		end
		return false
	end

	local function onTouchMoved(touch, event)

	end

	local function onTouchEnded(touch, event)

		local startTouchLocationX = touch:getStartLocation().x
		local endTouchLocationX = touch:getLocation().x

		if startTouchLocationX - endTouchLocationX > 50 then 
			if self.downDirection:isVisible() then
				app.audioPlayer:playClickBtnEffect()
				self:changePage(1)
			end
		elseif startTouchLocationX - endTouchLocationX < -50 then
			if self.upDirection:isVisible() then
				app.audioPlayer:playClickBtnEffect()
				self:changePage(0)
			end
		end
	end

	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED )
	listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED )
	local eventDispatcher = touchLayer:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, touchLayer)
end

function ExchangeLayerCtrller:createLayer()
	self.exchangeLayer = cc.CSLoader:createNode("Layers/ExchangeLayer.csb")


	self.targetTextures = {}
	self:addTextures()

	self.isExitLayer = false
	self.exchangeLayer:onNodeEvent("exit", function()
		print("<------exit self.exchangeLayer")
		self.isExitLayer = true
		self:removeUnusedTextures()
	end)

	procUI(self)
	self:createTouchLayer()
	self.goodsListReqed = {}  --保存已经请求过的页数  

	self.imgDownloadRoot = ""

	self.reqPageIndex = 1 --请求成功后+1
	reqExchangeGoodsListOfOnce(self)
	self.nodeSelfInfoCtrller:reqGetUserAddressInfo() --同时请求个人信息数据


	return self.exchangeLayer
end

function ExchangeLayerCtrller:addTextures()

end

function ExchangeLayerCtrller:removeUnusedTextures()
	for _, strTexture in pairs(self.targetTextures) do
		cc.Director:getInstance():getTextureCache():removeTextureForKey(strTexture)
	end
end


return ExchangeLayerCtrller