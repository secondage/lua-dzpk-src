--
-- Author: ChenShao
-- Date: 2015-12-17 16:11:41
--
local WrapRoomViewCtrller = class("WrapRoomViewCtrller")

local function procBtbnClose(self)
	local btnClose = self.imgBg:getChildByName("Button_close")
	btnClose:setPressedActionEnabled(true)
	btnClose:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			self:hide()
			self.lsView:hide()
		end
	end)	
end


local _nBet = 0
local _strPwd = ""
local _nWatch = false

local function proBetList(self)
	self.lsView = self.imgBg:getChildByName("ListView_bet_list")
	self.lsView:hide()

	local txtBet = self.imgBg:getChildByName("Text_bet")

	local function selectBet(obj, type)
		if type == 2 then
			_nBet =  tonumber(obj:getString())
			self.lsView:hide()
			txtBet:setString(_nBet)
			txtBet:show()
		end
	end

	for i = 1, #self.betlist do
		local txtBetClone = txtBet:clone():show()
		txtBetClone:setString(self.betlist[i])
		txtBetClone:setTouchEnabled(true)
		txtBetClone:addTouchEventListener(selectBet)
		self.lsView:pushBackCustomItem(txtBetClone)
	end

end

local function procBetImg(self)
	local imgBet = self.imgBg:getChildByName("Image_set_bet")
	imgBet:setTouchEnabled(true)

	imgBet:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			self.lsView:show()
		end
	end)
end

local function procSetPwd(self)
	local nodePwd = self.imgBg:getChildByName("Node_pwd")
	local checkBoxPwdYes = nodePwd:getChildByName("CheckBox_yes")
	local checkBoxPwdNo = nodePwd:getChildByName("CheckBox_no")
	checkBoxPwdYes:setSelected(false)
	checkBoxPwdNo:setSelected(true)


	local inputPwdTmp = nodePwd:getChildByName("Image_set_pwd"):hide()
	local inputPwd = app.EditBoxFactory:createEditBoxByImage(inputPwdTmp, "请输入密码"):hide()
	self.inputPwd = inputPwd
	inputPwd:registerScriptEditBoxHandler(function(name, sender)
		print("name = " ..name)
		if name == "began" then
			inputPwd:setString("")
		elseif name == "changed" then
			
		elseif name == "ended" then
			_strPwd = inputPwd:getString()
		end
	end)

	local function checkBoxEvt(obj, type)
		app.audioPlayer:playClickBtnEffect()
		if obj == checkBoxPwdYes then
			checkBoxPwdYes:setSelected(true)
			checkBoxPwdNo:setSelected(false)

			self.nodeWatch:setPositionY(self.nodeWatch.posY - 50)
			inputPwd:show()
		else
			checkBoxPwdYes:setSelected(false)
			checkBoxPwdNo:setSelected(true)

			self.nodeWatch:setPositionY(self.nodeWatch.posY)
			inputPwd:hide()
		end
	end

	checkBoxPwdYes:addEventListener(checkBoxEvt)
	checkBoxPwdNo:addEventListener(checkBoxEvt)
end

local function procWatch(self)
	
	local nodeWatch = self.imgBg:getChildByName("Node_watch")
	self.nodeWatch = nodeWatch
	self.nodeWatch.posY = nodeWatch:getPositionY()


	local checkBoxWatchYes = nodeWatch:getChildByName("CheckBox_yes")
	local checkBoxWatchNo = nodeWatch:getChildByName("CheckBox_no")
	checkBoxWatchYes:setSelected(false)
	checkBoxWatchNo:setSelected(true)

	local function checkBoxEvt(obj, type)
		app.audioPlayer:playClickBtnEffect()
		if obj == checkBoxWatchYes then
			checkBoxWatchYes:setSelected(true)
			checkBoxWatchNo:setSelected(false)
			_nWatch = true
	
		else
			checkBoxWatchYes:setSelected(false)
			checkBoxWatchNo:setSelected(true)
			_nWatch = false
		end
	end

	checkBoxWatchYes:addEventListener(checkBoxEvt)
	checkBoxWatchNo:addEventListener(checkBoxEvt)
end

local function proBtnOK(self)
	local btnOK = self.imgBg:getChildByName("Button_OK")
	btnOK:setPressedActionEnabled(true)
	btnOK:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			if _nBet <= 0 then
				app.toast.show("Please setup ante")
				return
			end
			wrapRoom.wrapRoomMsgSender:sendCREATEROOMREQ(_nBet, _strPwd, _nWatch)
		end
	end)
end

local function procUI(self)
	self.layRoof = self.wrapRoomLayer:getChildByName("Panel_bet_set")
	self.imgBg = self.wrapRoomLayer:getChildByName("Image_bet_set_bg")
	self.imgBg:setTouchEnabled(true)
	self.imgBg:addTouchEventListener(function(obj, type)
		if type == 2 then
			if self.lsView:isVisible() then
				app.audioPlayer:playClickBtnEffect()
				self.lsView:hide()
			end
		end
	end)

	procBtbnClose(self)
	procBetImg(self)
	proBetList(self)
	procSetPwd(self)
	procWatch(self)
	proBtnOK(self)
end

local function initData(self)
	_nBet = 0
	_strPwd = ""
	_nWatch = false
end

local function clearUI(self)
	local txtBet = self.imgBg:getChildByName("Text_bet")
	txtBet:setString("Please setup ante")

	local nodePwd = self.imgBg:getChildByName("Node_pwd")
	nodePwd:getChildByName("CheckBox_yes"):setSelected(false)
	nodePwd:getChildByName("CheckBox_no"):setSelected(true)

	self.nodeWatch:getChildByName("CheckBox_yes"):setSelected(false)
	self.nodeWatch:getChildByName("CheckBox_no"):setSelected(true)
	self.nodeWatch:setPositionY(self.nodeWatch.posY)
	self.inputPwd:hide()
	self.inputPwd:setString("")
end

local function initBetlistData(self)
	local myMoney = cc.dataMgr.lobbyUserData.lobbyUser.gameCurrency.l
	print("<===myMoney = " ..myMoney)
	self.betlist = {}
	local maxBet = (myMoney - 1) / 50
	print("maxBet = " ..maxBet)
	local count = 0
	local ret = maxBet / 10
	while ret >= 1 do
		count = count + 1
		ret = ret / 10
	end
	print("count = " ..count)
	if count >= 5 then
		count = 5
	end
	print("count = " ..count)

	for i = 1, count do
		self.betlist[#self.betlist + 1] = math.pow(10, i)
	end
end

function WrapRoomViewCtrller:createLayer()
	self.wrapRoomLayer = cc.CSLoader:createNode("Layers/WrapRoomLayer.csb")

	initBetlistData(self)
	procUI(self)

	return self.wrapRoomLayer
end

function WrapRoomViewCtrller:show()
	self.layRoof:show()
	self.wrapRoomLayer:show()

	initData(self)
	clearUI(self)
end

function WrapRoomViewCtrller:hide()
	self.layRoof:hide()
	self.wrapRoomLayer:hide()
end

return WrapRoomViewCtrller