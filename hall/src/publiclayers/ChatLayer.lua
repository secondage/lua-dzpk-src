--
-- Author: ChenShao
-- Date: 2015-08-31 09:50:14
--
local ChatLayerCtrl = class("ChatLayerCtrl")

local lang = {
	[0] = "你是MM还是GG",
	[1] = "快点吧,我等的花儿都谢了",
	[2] = "不要吵不要吵,专心玩游戏吧",
	[3] = "怎么又断线了,网络怎么这么差",
	[4] = "你的牌打得也太好了",
	[5] = "和你合作真是太愉快了",
	[6] = "快交个朋友吧,能告诉我你的联络方式么",
	[7] = "不要走,决战到天亮",
	[8] = "下次再玩吧,我要走了",
	[9] = "再见了,我会想念大家的"
}

local function sendMsgToServer(strMsg)
	local req = wnet.CHAT_MSG.new(cc.protocolNumber.CG_TABLECHAT_P, cc.dataMgr.lobbyLoginData.userID)
	cc.msgHandler.socketGame:send(req:bufferIn({srcID = cc.dataMgr.lobbyLoginData.userID, strMsg = strMsg}):getPack())
end

local function procUI(self)
	local root = self.chatLayer:getChildByName("Panel_root"):show()
	root:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			self.chatLayer:hide()
		end
	end)

	local imgChatBg = self.chatLayer:getChildByName("Image_chatbg"):show()
	imgChatBg:setTouchEnabled(true)
	local nodeLang = imgChatBg:getChildByName("Node_commonLanguage"):hide()
	local listViewLang = nodeLang:getChildByName("ListView_lang"):show():setClippingEnabled(true)
	local nodeExp = imgChatBg:getChildByName("Node_expression"):hide()
	local listViewExp = nodeExp:getChildByName("ListView_expression"):show():setClippingEnabled(true)
	local nodeHistory = imgChatBg:getChildByName("Node_history"):hide()
	self.listViewHistory = nodeHistory:getChildByName("ListView_history"):show():setClippingEnabled(true)

	local nodeSelectType = imgChatBg:getChildByName("Node_selectType")
	local checkBoxLang = nodeSelectType:getChildByName("CheckBox_commonLanguage")
	checkBoxLang.userdata = nodeLang
	local checkBoxExp = nodeSelectType:getChildByName("CheckBox_expression")
	checkBoxExp.userdata = nodeExp
	local checkBoxHistory = nodeSelectType:getChildByName("CheckBox_history")
	checkBoxHistory.userdata = nodeHistory
	--checkBoxHistory:hide() --暂时屏蔽

		
	local function setSelected(checkBox)
		local children = nodeSelectType:getChildren()
		for _, child in pairs(children) do
			child:setSelected(false)
			child.userdata:hide()
		end
		checkBox:setSelected(true)
		checkBox.userdata:show()
	end

	setSelected(checkBoxLang)

	checkBoxLang:addEventListener(function (obj, type)
		app.audioPlayer:playClickBtnEffect()
		setSelected(obj)
	end)
	checkBoxExp:addEventListener(function (obj, type)
		app.audioPlayer:playClickBtnEffect()
		setSelected(obj)
	end)
	checkBoxHistory:addEventListener(function (obj, type)
		app.audioPlayer:playClickBtnEffect()
		setSelected(obj)
	end)

	local function procLangUI()--初始化常用语界面
		local item = nodeLang:getChildByName("Panel_item"):hide()
		for i = 0, #lang - 1 do
			local itemClone = item:clone():show()
			local txt = itemClone:getChildByName("Text_lang"):show()
			txt:setString(lang[i])
			txt:setTouchEnabled(true)
			--txt:setColor(display.COLOR_WHITE)

			local imgSelected = itemClone:getChildByName("Image_selected"):hide()
			listViewLang:pushBackCustomItem(itemClone)

			txt:addTouchEventListener(function(obj, type)
				if type == 0 then
					imgSelected:show()
				elseif type == 3 then
					imgSelected:hide()
				elseif type == 2 then
					app.audioPlayer:playClickBtnEffect()
					imgSelected:hide()
					self.chatLayer:hide()
					print("chat msg = " ..txt:getString())
					print("UTF82Mutiple(txt:getString()) = " ..UTF82Mutiple(txt:getString()))
					sendMsgToServer(txt:getString())
				end
			end)
		end
	end
	procLangUI()

	local chatInputBg = imgChatBg:getChildByName("TextField_chatInput"):hide()
	local chatInput = app.EditBoxFactory:createEditBoxByImage(chatInputBg, "请输入聊天内容", "editboxbg0.png", 50)
	chatInput:setFontColor(cc.c4b(255, 255, 255, 255))
	chatInput:registerScriptEditBoxHandler(function(name, sender)
		if name == "began" then
			sender:setString("")
		end
	end)
	chatInput:setOpacity(0)
	self.chatInput = chatInput

	local btnSend = imgChatBg:getChildByName("Button_send") --发送按钮
	btnSend:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()

			local strMsg = chatInput:getString()

			if string.len(strMsg) == 0 then
				app.toast.show("聊天内容不能为空")
				return
			end

			sendMsgToServer(strMsg)
			self.chatLayer:hide()
		end
	end)

	local function procExpressionUI()--初始化表情界面
		local item = nodeExp:getChildByName("Panel_item"):hide()
		for _, btn in pairs(item:getChildren()) do
			btn:hide()
		end
		local count = 0
		local isFlag = true
		while isFlag do
			local itemClone = item:clone():show()
			for i = 1, 7 do
				local strRes = ""
				if count < 10 then 
					strRes = "#0" ..count ..".png"
				else
					strRes = "#" ..count ..".png"
				end

				if cc.SpriteFrameCache:getInstance():getSpriteFrame(strRes) then	
					local btnExp = itemClone:getChildByName("Button_btnExpression" ..i):show()
					btnExp:setPressedActionEnabled(true)
					if count < 10 then 
						btnExp.userdata = "$0" ..count
					else
						btnExp.userdata = "$" ..count
					end
					btnExp:loadTextures(strRes, strRes, "", 1)
					count = count + 1
					btnExp:addTouchEventListener(function(obj, type)
						if type == 2 then
							app.audioPlayer:playClickBtnEffect()
							sendMsgToServer(obj.userdata)
							self.chatLayer:hide()
						end
					end)
				else
					isFlag = false
				end
			end
			listViewExp:pushBackCustomItem(itemClone)
		end
	end
	procExpressionUI()
end

local function S2CChair_2(chairid)

end

local function S2CChair_3(chairid)
	local diff = chairid - cc.dataMgr.selectedChairID
	local pos = -1
	if diff == 0 then  pos = 0
	elseif diff == 1 or diff == -2 then pos = 1
	else pos = 2 end
	return pos
end

local function S2CChair_4(chairid)
	local diff = chairid - cc.dataMgr.selectedChairID
    local pos = -1
    if diff == 0 then  pos = 0
    elseif diff == 1 or diff == -3 then pos = 1
    elseif diff == 2 or diff == -2 then pos = 2
    else pos = 3 end
    return pos
end

local function S2CChair_5(chairid)

end

local function S2CChair_9(chairid)
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

local function S2CChair(chairid)
	if cc.dataMgr.tablePlyNum == 2 then
		return S2CChair_2(chairid)
	elseif cc.dataMgr.tablePlyNum == 3 then
		return S2CChair_3(chairid)
   	elseif cc.dataMgr.tablePlyNum == 4 then
    	return S2CChair_4(chairid)
    elseif cc.dataMgr.tablePlyNum == 5 then
    	return S2CChair_5(chairid)
   	elseif cc.dataMgr.tablePlyNum == 9 then
		return S2CChair_9(chairid)
    end
end

local function findUserDataById(userID)
	--dump(cc.dataMgr.tableUsers)
	if cc.dataMgr.tableUsers[userID] == nil then
		return nil
	end
	
	for i, k in pairs(cc.dataMgr.tableUsers) do
		if i == userID then
			return k
		end
	end

	return nil
end

local function showChatMsg(self, data)

	local srcID = data.srcID
	local strMsg = data.strMsg
	local userInfo = findUserDataById(srcID)
	if userInfo == nil then
		return
	end
	local chair = S2CChair(userInfo.gameData.chairID)
	print("strMsg = " ..strMsg.."chair = "..chair)
	--if chair == 0 then return end

	local imgChatMsgBg = self.chatMsgUI[chair]:show()

	local delay = cc.DelayTime:create(3)
	local callfc = cc.CallFunc:create(function()
		imgChatMsgBg:hide()
	end)
	imgChatMsgBg:runAction(cc.Sequence:create({delay, callfc}))


	local first = string.sub(strMsg, 1, 1)
	if first == "!" and string.len(strMsg) >= 2 then --为表情
		strMsg = "#" ..string.sub(strMsg, 2) ..".png"
		print("strMsg = " ..strMsg)
		local expFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(strMsg)
		if expFrame then
			imgChatMsgBg:show()
			imgChatMsgBg.msgExp:show():loadTexture(strMsg, 1)
			imgChatMsgBg.msgTxt:hide()
		else
			imgChatMsgBg:hide()
		end
	else --文字
		if #self.chatHistory >= 15 then
			table.remove(self.chatHistory, 1)
		end
		local nickName = userInfo.userData.strNickName
		local record = {}
		record.nickName = nickName
		record.msg = strMsg
		self.chatHistory[#self.chatHistory + 1] = record
		imgChatMsgBg:show()
		imgChatMsgBg.msgExp:hide()
		imgChatMsgBg.msgTxt:show():setString(strMsg)
	end
end

local function updateChatHistory(self)
	self.listViewHistory:removeAllItems()
	for i = 1, #self.chatHistory do
		local strMsg = self.chatHistory[i]
		local text = ccui.Text:create()
		--label:setAnchorPoint(0, 0.5)
		text:setFontSize(20)
		local record = self.chatHistory[i]
		text:setString(record.nickName..":"..record.msg)
		self.listViewHistory:pushBackCustomItem(text)
	end
end

local function listenEvent(self)
	self.chatLayer.eventProtocol:addEventListener("GC_TABLECHAT_P", function(event) --聊天成功
		self.chatInput:setString("")
		showChatMsg(self, event.data)
		updateChatHistory(self)
	end)

	self.chatLayer.eventProtocol:addEventListener("GC_TABLE_CHATFAIL_P", function(event) --聊天失败
		local data = event.data
		if data.failReason == wnet.EChatFail_Reason.EChatFail_TimeLimit then
			app.toast.show("聊天过快")
		elseif data.failReason == wnet.EChatFail_Reason.EChatFail_TextFilter then
			app.toast.show("聊天内容有非法内容")
		elseif data.failReason == wnet.EChatFail_Reason.EChatFail_TextLengthOver then
			app.toast.show("聊天内容超长")
		elseif data.failReason == wnet.EChatFail_Reason.EChatFail_HonorLess then
			app.toast.show("声望不足")
		elseif data.failReason == wnet.EChatFail_Reason.EChatFail_ForbidChat then
			app.toast.show("因违反用户条例，被禁言")
		elseif data.failReason == wnet.EChatFail_Reason.EChatFail_NoWatch then
			app.toast.show("旁观不能聊天")
		end
	end)
end

local function procChatMsgUI(self)
	local nodeGameUser = app.gameResNode:getChildByName("Node_gameUser")
	self.chatMsgUI = {}
	for i = 0, cc.dataMgr.tablePlyNum - 1 do
		print("i = " ..i)
		local chatMsgUI = nodeGameUser:getChildByName("GameUser" ..i)
				:getChildByName("Panel")
				:getChildByName("Image_chatMsgBg"):hide()
		chatMsgUI.msgExp = chatMsgUI:getChildByName("Image_msgExpression"):hide()
		chatMsgUI.msgTxt = chatMsgUI:getChildByName("Text_msgTxt"):hide()
		
		self.chatMsgUI[i] = chatMsgUI
	end
end

function ChatLayerCtrl:createLayer(pathRes, msgUI)
	self.chatLayer = cc.CSLoader:createNode(pathRes)

	self.chatLayer:setAnchorPoint(cc.p(0.5, 0.5))
	self.chatLayer:ignoreAnchorPointForPosition(false)
	self.chatLayer:setPosition(display.cx, display.cy)

	self.chatLayer.eventProtocol = require("framework.components.behavior.EventProtocol").new()

	self.chatHistory = {}

	procUI(self)
	if msgUI == nil then
		procChatMsgUI(self)
	else
		self:initChatMsgUI(msgUI)
	end
	listenEvent(self)

	return self.chatLayer
end

--根据自己画布initChatMsgUI
function ChatLayerCtrl:initChatMsgUI(msgUI)
	self.chatMsgUI = msgUI
	for i = 0, cc.dataMgr.tablePlyNum - 1 do
		local chatMsgUI = self.chatMsgUI[i]
		if chatMsgUI ~= nil then
			chatMsgUI:hide()
			chatMsgUI.msgExp = chatMsgUI:getChildByName("Image_msgExpression"):hide()
			chatMsgUI.msgTxt = chatMsgUI:getChildByName("Text_msgTxt"):hide()
		end
	end
end

return ChatLayerCtrl