--
-- Author: ChenShao
-- Date: 2015-09-08 16:01:06
--
local GameAddLayerCtrller = class("GameAddLayerCtrller")
local json = require("framework.json")
local network = require("framework.network")
local httpUtils = require("app.func.HttpUtils")

local _data = {
	["mahj"] = {
		
	},
	["poker"] = {
		
	},
	["other"] = {
		
	}
}

local _imagePath = ""

local gamedb = require("app.func.GameDB")

local function procUI(self)

	self.gameAddLayer:getChildByName("Panel_item"):hide()

	local btnExit = self.gameAddLayer:getChildByName("Button_exit")
	btnExit:setPressedActionEnabled(true)
	btnExit:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			--self.gameAddLayer:hide()
			self.gameAddLayer:removeSelf()
			app.runningScene.gameListLayerCtrl.gameAddLayer = nil
			app.hallScene.nPopLayers = app.hallScene.nPopLayers - 1
			--结束游戏列表新手引导
			cc.dataMgr.guiderFlag["newbie_guide"] = false
			cc.UserDefault:getInstance():setBoolForKey("newbie_guide", false)
			if app.hallScene.gameListGuideLayer ~= nil then
				app.hallScene.gameListGuideLayer.root:removeSelf()
				app.hallScene.gameListGuideLayer = nil
			end
			if cc.dataMgr.guiderFlag["benefit_guide"] then
				display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "BENEFIT_GUIDE" })
			end
		end
	end)


	local nodeType = self.gameAddLayer:getChildByName("Node_type"):show()

	--[[local function setSelected(obj)
		for _, child in pairs(nodeType:getChildren()) do
			child:setSelected(false)
			child:setEnabled(true)
			child.userdata:hide()
		end
		obj:setSelected(true)
		obj:setEnabled(false)
		obj.userdata:show()
	end]]

	local listViewMahj = self.gameAddLayer:getChildByName("ListView_mahj")
	local listViewPoker = self.gameAddLayer:getChildByName("ListView_poker")
	local listViewOther = self.gameAddLayer:getChildByName("ListView_other")

	local checkBoxMahj = nodeType:getChildByName("CheckBox_mahj")
	--checkBoxMahj.userdata = listViewMahj
	local checkBoxPoker = nodeType:getChildByName("CheckBox_poker")
	--checkBoxPoker.userdata = listViewPoker
	local checkBoxOther = nodeType:getChildByName("CheckBox_other")
	--checkBoxOther.userdata = listViewOther

	local function onCheckBoxEvt()
		app.audioPlayer:playClickBtnEffect()
		
		if not self.isCheckjson then
			self:readAddGamesList()
		end
	end

	local groupBox = require("app.func.GroupBox").new({
		{checkBox = checkBoxMahj, node = listViewMahj, callBack = onCheckBoxEvt },
		{checkBox = checkBoxPoker, node = listViewPoker, callBack = onCheckBoxEvt },
		{checkBox = checkBoxOther, node = listViewOther, callBack = onCheckBoxEvt }
	})

	--[[setSelected(checkBoxMahj)

	local function onCheckBoxEvt(obj, type)
		if not self.isCheckjson then
			self:readAddGamesList()
		end
		setSelected(obj)
	end
	checkBoxMahj:addEventListener(onCheckBoxEvt)
	checkBoxPoker:addEventListener(onCheckBoxEvt)
	checkBoxOther:addEventListener(onCheckBoxEvt)]]

end

function GameAddLayerCtrller:showLayer()
	if not self.isCheckjson then
		self:readAddGamesList()
	end

	self.gameAddLayer:show()
	local bGuide = cc.dataMgr.guiderFlag["newbie_guide"]
	if bGuide then
		local btnExit = self.gameAddLayer:getChildByName("Button_exit")
		print("show close guide")
		if app.hallScene.gameListGuideLayer ~= nil then
			app.hallScene.gameListGuideLayer:showCloseAddGameGuide(btnExit)
		end
	end
end

function GameAddLayerCtrller:readAddGamesList()
	local function readJsonAndUpdateUI()
		local filePath = cc.FileUtils:getInstance():getWritablePath() .."addgames.json"
		if cc.FileUtils:getInstance():isFileExist(filePath) then
			local jsonFileData = cc.FileUtils:getInstance():getStringFromFile(filePath)
			local gamelistInfo = json.decode(jsonFileData)

			self.gamelistInfo = gamelistInfo

       		_imagePath = gamelistInfo["title"]["imageRoot"]
       		if g_Platform_Win32 or clientConfig.platform == "INNER" then
       			_imagePath = gamelistInfo["title"]["imageRoot_win32"]
       		end
       		
			local version = gamelistInfo["title"]["version"]
			local games = gamelistInfo["games"]

			_data["mahj"] = games["mahj"]
			_data["poker"] = games["poker"]
			_data["other"] = games["other"]

			self.gameAddLayer:show()
			self:updateUI()
		else

		end
	end

	local function download(serverVersion)
		app.holdOn.show("正在读取游戏列表")
		local strUrl = urls.addgameslist
		httpUtils.reqHttp(strUrl, function(ret, response)
			if self.isExitLayer then return end
			app.holdOn.hide()
			if ret then	
				print("<---response = " ..response)
				self.isCheckjson = true
				local gamelistInfo = json.decode(response)

				local filePath = cc.FileUtils:getInstance():getWritablePath() .."addgames.json"
				local file = io.open(filePath, "w+")
				if file then
					file:write(response)
					file:close()

					readJsonAndUpdateUI()
					cc.UserDefault:getInstance():setStringForKey("addgamelist_version", tostring(serverVersion))
				else
					print("can not open " ..fileName)
				end
			else
			--app.toast.show("没有游戏可以添加")
			end
		end)
	end
	local function readAddGamesListJsonVersion()
		local strUrl = urls.addgameslistVersion
		print("readAddGamesListJsonVersion url = " ..strUrl)
		httpUtils.reqHttp(strUrl, function(ret, response)
			if self.isExitLayer then return end
			if ret then	
				self.isCheckjson = true
				print("<---addgameliset response = " ..response)
				local localVersion = cc.UserDefault:getInstance():getStringForKey("addgamelist_version", "0")
				
				localVersion = tonumber(localVersion)
				local serverVersion = tonumber(response)

				print("serversion = " ..serverVersion)
				print("localVersion = " ..localVersion)

				if serverVersion > localVersion then
					download(serverVersion)
				end
			end
		end)
	end

	readJsonAndUpdateUI()
	readAddGamesListJsonVersion()
end

function GameAddLayerCtrller:downLoadingUI(gamename, onResult, strZipUrl)
	local layDownloadCtrller = require("app.views.layers.DownLoadLayer").new()
	self.layDownload = layDownloadCtrller:createLayer(2):addTo(self.gameAddLayer, 100)


	layDownloadCtrller:startDownload(gamename, onResult, strZipUrl)
end

function GameAddLayerCtrller:downloadIcon(strUrl, imgIconFile, callback)
	--cpp_downloadFile(strUrl, iconName, callback)
	--local filePath = cc.FileUtils:getInstance():getWritablePath() ..iconName
	print("downiconurl = " ..strUrl)
	httpUtils.reqHttp(strUrl, function(ret, response)
		if self.isExitLayer then return end
		if ret then
			if string.len(response) < 100 then
				callback(1) --没有对应文件
				return
			end
			
			print("imgIconFile = " ..imgIconFile)
			local file = io.open(imgIconFile, "wb+")
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

function GameAddLayerCtrller:updateUI()
	local listViewMahj = self.gameAddLayer:getChildByName("ListView_mahj")
	listViewMahj:removeAllItems()
	local listViewPoker = self.gameAddLayer:getChildByName("ListView_poker")
	listViewPoker:removeAllItems()
	local listViewOther = self.gameAddLayer:getChildByName("ListView_other")
	listViewOther:removeAllItems()

	local item = self.gameAddLayer:getChildByName("Panel_item"):hide()
	local node1 = item:getChildByName("Node_1"):hide()
	local node2 = item:getChildByName("Node_2"):hide()

	local mahjData = _data["mahj"]
	local pokerData = _data["poker"]
	local otherData = _data["other"]


	local function updateCell(itemClone, i, j, data)
		if i <= #data then
			local nodeClone = itemClone:getChildByName("Node_" ..j):show()
			local icon = nodeClone:getChildByName("Image_icon")
			print("data[i].name = " ..data[i].name)
			--iconFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(data[i].icon)
			local imgIconFile = cc.FileUtils:getInstance():getWritablePath() ..data[i].icon
			if cc.FileUtils:getInstance():isFileExist(imgIconFile) then
				icon:loadTexture(imgIconFile)	
			else
				self:downloadIcon(_imagePath ..data[i].icon, imgIconFile, function(ret)
					if ret == 0 then
						--local imagePath = cc.FileUtils:getInstance():getWritablePath() ..data[i].icon
						if self.isExitLayer then return end
						icon:loadTexture(imgIconFile)	
					end
				end)
			end

			local name = nodeClone:getChildByName("Text_name")

			name:setString(data[i].nameZH)

			local btnAdd = nodeClone:getChildByName("Button_add"):hide()
			btnAdd:setPressedActionEnabled(true)
			local btnDelete = nodeClone:getChildByName("Button_delete"):hide()
			btnDelete:setPressedActionEnabled(true)
			btnAdd:addTouchEventListener(function(obj, type)
				if type == 2 then
					app.audioPlayer:playClickBtnEffect()
					-- do sth
					local ret = gamedb.checkIsDownloaded(data[i].gameid)
					if ret == 0 then --重未安装过 --从服务器下载
						local function startDown()
							local function onResult(ret)--回调
								if ret == 0 then --下载解压完
									app.toast.show("下载成功")
									self.layDownload:hide()
									btnDelete:show()
									btnAdd:hide()
									gamedb.addNewGame(data[i].gameid, data[i].name, data[i].nameZH, 1, 1)
									self.gameAddLayer:getParent():updateGameListUI()
								elseif ret == 1 then
									app.toast.show("没有新版本")
									self.layDownload:hide()
								elseif ret == 2 then
									app.toast.show("网络错误")
									self.layDownload:hide()
								elseif ret == 3 then --开始下载
									self.layDownload:show()
								else
									--app.toast.show("下载失败")
									self.layDownload:hide()
								end
							end

							self:downLoadingUI(data[i].name, onResult, urls.fullZipDownloadurl)
							--self.layDownload:hide()
						end
					
						local strMsg = "是否下载" ..data[i].nameZH
						app.msgBox.showMsgBoxTwoBtn(strMsg, startDown, nil, strMsg, "下载", "取消")
					else --安装过，但又删除
						if gamedb.updateShowingState(data[i].gameid, 1) == 0 then  --成功
							btnDelete:show()
							btnAdd:hide()
							self.gameAddLayer:getParent():updateGameListUI()
						end
					end
				end
			end)

			btnDelete:addTouchEventListener(function(obj, type)
				if type == 2 then
					app.audioPlayer:playClickBtnEffect()
					--do sth
					if gamedb.deleteGame(data[i].gameid, 0) == 0 then

						local bSuccess = false
						if cc.FileUtils:getInstance():removeDirectory("src/" ..data[i].name .."/") then
						 	bSuccess = true
						end

						if cc.FileUtils:getInstance():removeDirectory(g_writablePath .."/update/" ..data[i].name .."/") then
							bSuccess = true
						end

						if bSuccess then
							btnDelete:hide()
							btnAdd:show()
							self.gameAddLayer:getParent():updateGameListUI()
							cc.UserDefault:getInstance():setStringForKey(data[i].name .."_version", "0")
						end

					end
				end
			end)

			--设置按钮状态
			local ret = gamedb.checkIsDownloaded(data[i].gameid)
			if ret == 0  then
				btnDelete:hide()
				btnAdd:show()
			elseif ret == 1 or ret == 2 then
				btnDelete:show()
				btnAdd:hide()
			end
		end
	end

	if #mahjData > 0 then
		for i = 1, #mahjData, 2 do
			local itemClone = item:clone():show()	
			updateCell(itemClone, i, 1, mahjData)
			updateCell(itemClone, i + 1, 2, mahjData)
			listViewMahj:pushBackCustomItem(itemClone)
		end
	end

	if #pokerData > 0 then
		for i = 1, #pokerData, 2 do
			local itemClone = item:clone():show()	
			updateCell(itemClone, i, 1, pokerData)
			updateCell(itemClone, i + 1, 2, pokerData)
			listViewPoker:pushBackCustomItem(itemClone)
		end
	end

	if #otherData > 0 then
		for i = 1, #otherData, 2 do
			local itemClone = item:clone():show()	
			updateCell(itemClone, i, 1, otherData)
			updateCell(itemClone, i + 1, 2, otherData)
			listViewOther:pushBackCustomItem(itemClone)
		end
	end


end

function GameAddLayerCtrller:createLayer()
	self.gameAddLayer = cc.CSLoader:createNode("Layers/GameAddLayer.csb")
	self.gamelistInfo = nil
	--self:readAddGamesList()
	
	self.isCheckjson = false
	procUI(self)

	self.isExitLayer = false
	self.gameAddLayer:onNodeEvent("exit", function()
		print("<------exit self.gameAddLayer")
		self.isExitLayer = true
		self.gameAddLayer = nil
	end)
	
	return self.gameAddLayer
end

--- 加载大厅模块
function app.checkPackUpdateOnlyName(data,func)
	local url = urls.fullZipDownloadurl
	if g_Platform_Win32 or clientConfig.platform == "INNER" then
		url = "http://192.168.1.119/2d_web_ini/fullzip/"
	end
	--local url = "http://192.168.1.119/2d_web_ini/fullzip/"
	--cc.sceneTransFini = false
	local layDownloadCtrller = require("app.views.layers.DownLoadLayer").new()
	local ctrl = layDownloadCtrller:createLayer(2):addTo(app.runningScene, 100)
	layDownloadCtrller:startDownload(data.name, function(rst)
		if rst == 0 then		-- 下载成功
			ctrl:hide()
			--cc.sceneTransFini = true
			func(rst)
		elseif rst == 1 then	-- 没有新版本
			ctrl:hide()
			--cc.sceneTransFini = true
			func(rst)
		elseif rst == 2 then 	--网络错误
			ctrl:hide()
			--cc.sceneTransFini = true
			func(rst)
		elseif rst == 3 then	-- 开始下载
			ctrl:show()
		elseif rst == 6 then
			ctrl:show()
		end
	end, url)
end

return GameAddLayerCtrller