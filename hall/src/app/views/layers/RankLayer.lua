  --
-- Author: ChenShao
-- Date: 2015-08-20 10:34:10
--
local RankCtrlLayer = class("RankCtrlLayer")

local function procUI(self)
	local btnExit = self.rankLayer:getChildByName("Button_btnExit")
	btnExit:addTouchEventListener(function(obj, type)
		if type == 2 then
			self.rankLayer:getParent().rankLayer = nil
			self.rankLayer:removeSelf()
		end
	end)

	local imgRankBg = self.rankLayer:getChildByName("Image_rankBg")

	local nodeRich = imgRankBg:getChildByName("Node_rich"):show()
	local nodeGain = imgRankBg:getChildByName("Node_gain"):hide()
	local nodeHonor = imgRankBg:getChildByName("Node_honor"):hide()

	self.listViewRich = nodeRich:getChildByName("ListView_rich")
	self.listViewGain = nodeGain:getChildByName("ListView_gain")
	self.listViewHonor = nodeHonor:getChildByName("ListView_honor")
	
	local function typeGroup()
		local groupNode = imgRankBg:getChildByName("Node_group")

		local groupCheckBox = {}
		local checkBoxRich = groupNode:getChildByName("CheckBox_richRank")
		groupCheckBox[#groupCheckBox + 1] = checkBoxRich
		checkBoxRich:setSelected(true)
		checkBoxRich:setEnabled(false)
		checkBoxRich.userdata = nodeRich

		local checkBoxGain = groupNode:getChildByName("CheckBox_gainRank")
		groupCheckBox[#groupCheckBox + 1] = checkBoxGain
		checkBoxGain:setSelected(false)
		checkBoxGain.userdata = nodeGain

		local checkBoxHonor = groupNode:getChildByName("CheckBox_honorRank")
		groupCheckBox[#groupCheckBox + 1] = checkBoxHonor
		checkBoxHonor:setSelected(false)
		checkBoxHonor.userdata = nodeHonor

		local function onCheckBoxEvt(obj, type)
			for _, box in pairs(groupCheckBox) do
				box:setSelected(false)
				box:setEnabled(true)
				box.userdata:hide()
			end
			obj:setSelected(true)
			obj.userdata:show()
			obj:setEnabled(false)
		end
		checkBoxRich:addEventListener(onCheckBoxEvt)
		checkBoxGain:addEventListener(onCheckBoxEvt)
		checkBoxHonor:addEventListener(onCheckBoxEvt)
	end

	typeGroup()
	
	self.myItemRich = nodeRich:getChildByName("Panel_myRank"):hide()
	self.myItemGain = nodeGain:getChildByName("Panel_myRank"):hide()
	self.myItemHonor = nodeHonor:getChildByName("Panel_myRank"):hide()
end

function RankCtrlLayer:createLayer()
	self.rankLayer = cc.CSLoader:createNode("Layers/RankLayer.csb")
	
	self.listViewRich = nil 
	self.listViewGain = nil 
	self.listViewHonor = nil
	procUI(self)

	return self.rankLayer
end

function RankCtrlLayer:updateUI(data)
	local tmpItem = self.rankLayer:getChildByName("Panel_tmpItem")

	local function getValue(listView, rankData, i)
		local value = 0
		if listView == self.listViewRich then 
			value = "当前财富" ..rankData.totalGameCurrency
		elseif listView == self.listViewGain then
			value = "当前盈利" ..rankData.gainGameCurrency
		else
			value = "当前荣誉" ..rankData.honor
		end
		return value
	end

	local function updateList(listView, rankData)
		listView:removeAllItems()
		for i = 1, #rankData do
			local itemClone = tmpItem:clone()
			local txtRanking = itemClone:getChildByName("Text_ranking")
			txtRanking:setString(rankData[i].nRank)
			local imgHead = itemClone:getChildByName("Image_head")
			local txtNickName = itemClone:getChildByName("TextField_nickName")
			txtNickName:setString(rankData[i].nNickName)
			local txtUserID = itemClone:getChildByName("Text_userid")
			txtUserID:setString(rankData[i].userId)
			local txtValue = itemClone:getChildByName("Text_value")
			txtValue:setString(getValue(listView, rankData[i], i))
			listView:pushBackCustomItem(itemClone)
		end
	end

	updateList(self.listViewRich, data.rickRank)
	updateList(self.listViewGain, data.gainRank)
	updateList(self.listViewHonor, data.honorRank)
end

function RankCtrlLayer:updateMyItem(data)
	self.myItemRich:show()
	self.myItemGain:show()
	self.myItemHonor:show()

	local function updatePublic(myItem)
		local imghead = myItem:getChildByName("Image_head")
		local txtNickName = myItem:getChildByName("TextField_nickName")
		txtNickName:setString(cc.dataMgr.lobbyUserData.lobbyUser.strNickNamebuf)
	end

	updatePublic(self.myItemRich)
	local txtRichValue = self.myItemRich:getChildByName("Text_value")
	txtRichValue:setString("当前财富" ..data.totalGameCurrency)
	local txtRickRanking = self.myItemRich:getChildByName("Text_ranking")
	txtRickRanking:setString("当前排名" ..data.richRank)
	if txtRickRanking > 999 then txtRickRanking:setString("未入榜") end

	updatePublic(self.myItemGain)
	local txtGainValue = self.myItemGain:getChildByName("Text_value")
	txtGainValue:setString("当前盈利" ..data.gainGameCurrency)
	local txtGainRanking = self.myItemGain:getChildByName("Text_ranking")
	txtGainRanking:setString("当前排名" ..data.gainRank)
	if txtGainRanking > 999 then txtRickRanking:setString("未入榜") end

	updatePublic(self.myItemHonor)
	local txtHonorValue = self.myItemHonor:getChildByName("Text_value")
	txtHonorValue:setString("当前荣誉" ..data.honor)
	local txtHonorRanking = self.myItemHonor:getChildByName("Text_ranking")
	txtHonorRanking:setString("当前排名" ..data.honorRank)
	if txtHonorRanking > 999 then txtRickRanking:setString("未入榜") end

end

return RankCtrlLayer