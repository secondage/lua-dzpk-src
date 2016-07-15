--
-- Author: ChenShao
-- Date: 2015-10-29 15:49:40
--
local UserAddressInfoLayerCtrller = class("UserAddressInfoLayerCtrller")

local httpUtils = require("app.func.HttpUtils")
local iconv = require "iconv"
local encoding = iconv.new("gbk", "utf-8") -- utf8-->gbk for URL or Webapi
local json = require("framework.json")
local inputCheck = require("app.func.InputCheck")

local function encode(str)
	local targetPlatform = cc.Application:getInstance():getTargetPlatform()
	if cc.PLATFORM_OS_ANDROID == PLATFORM_OS_WINDOWS then
		return str
	else
		local s = string.gsub(str, "([^%w%.%-])", function(c) return string.format("%%%02X", string.byte(c)) end)
		return string.gsub(s, " ", "+")
	end	
end

local function reqUpdateAddress(self)

end

local function procAddressLayer(self)
	local imgAddressbg = self.userAddressInfoLayer:getChildByName("Image_addressinfo"):show()
	self.imgAddressbg = imgAddressbg
	
	--姓名
	local tfNameTmp = imgAddressbg:getChildByName("TextField_name"):hide()
	tfName = app.EditBoxFactory:createEditBoxByImage(tfNameTmp, "请输入联系人")
	self.tfName = tfName

	--电话
	local tfTelTmp = imgAddressbg:getChildByName("TextField_tel"):hide()
	tfTel = app.EditBoxFactory:createEditBoxByImage(tfTelTmp, "请输入电话")
	self.tfTel = tfTel
	tfTel:setInputMode(2)
	tfTel:setMaxLength(11)

	--地址显示
	local txtAddress = imgAddressbg:getChildByName("TextField_addressShow")
	txtAddress:setColor(display.COLOR_BLACK)
	self.txtAddress = txtAddress
	local tfAddressTmp = imgAddressbg:getChildByName("TextField_addressInput")
	tfAddress = app.EditBoxFactory:createEditBoxByImage(tfAddressTmp, "请输入收货地址", nil, 46)
	self.tfAddress = tfAddress

	--地址输入
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

	local tfPostTmp = imgAddressbg:getChildByName("TextField_tel_1")
	tfPost = app.EditBoxFactory:createEditBoxByImage(tfPostTmp, "请输入邮编")
	self.tfPost = tfPost
	tfPost:setInputMode(2)
	tfPost:setMaxLength(6)

	local function btnOKEvt(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()

			local strName = self.tfName:getString()
			local strTel = self.tfTel:getString()
			local strAddredd = self.tfAddress:getString()
			local strPost = self.tfPost:getString()

			if strName == "" or strTel =="" or strAddredd == "" or strPost == "" then
				app.toast.show("信息填写不完整")
				return
			end

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

			local url = urls.updateAddressUrl .."?UserId=" ..encode(cc.dataMgr.lobbyLoginData.userID)
							 .."&ContactName=" ..encode(strName)
							 .."&ContactTel=" ..encode(strTel)
							 .."&PostAddress=" ..encode(strAddredd)
							 .."&PostCode=" ..encode(strPost)

			print("url = " ..url)
			httpUtils.reqHttp(url, function(ret, response)
				if self.isExitLayer then return end
				if ret then
					print("response" ..response)
					local info = json.decode(response)
					if info.IsSuccessed == true then
						app.toast.show("信息已确认")
					else
						app.msgBox.showMsgBox(info.Message)
					end
				end
			end, true)
		end
	end

	local btnOK = imgAddressbg:getChildByName("Button_23")
	btnOK:setPressedActionEnabled(true)
	btnOK:addTouchEventListener(btnOKEvt)
end

local function procTelPhoneLayer(self)
	local imgTelPhonebg = self.userAddressInfoLayer:getChildByName("Image_telphone"):hide()
	self.imgTelPhonebg = imgTelPhonebg

	--电话
	local tfTelTmp = imgTelPhonebg:getChildByName("TextField_tel"):hide()
	tfTel = app.EditBoxFactory:createEditBoxByImage(tfTelTmp, "请输入电话")
	self.tfTel_ = tfTel
	tfTel:setInputMode(2)
	tfTel:setMaxLength(11)

	local function btnOKEvt(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()

			local strTel = self.tfTel:getString()
			if strTel == "" then
				app.toast.show("信息填写不完整")
				return
			elseif not inputCheck.checkIsNumberOnly(strTel) then
				app.toast.show("手机号填写不正确")
				return
			elseif string.len(strTel) ~= 11 then
				app.toast.show("手机号填写不正确")
				return
			end

			local url = urls.updateAddressUrl .."?UserId=" ..encode(cc.dataMgr.lobbyLoginData.userID)
							 .."&ContactTel=" ..encode(strTel)

			print("url = " ..url)
			httpUtils.reqHttp(url, function(ret, response)
				if self.isExitLayer then return end
				if ret then
					print("response" ..response)
					local info = json.decode(response)
					if info.IsSuccessed == true then
						app.toast.show("个人信息修改成功")
					else
						app.msgBox.showMsgBox(info.Message)
					end
				end
			end, true)
		end
	end

	local btnOK = imgTelPhonebg:getChildByName("Button_23")
	btnOK:setPressedActionEnabled(true)
	btnOK:addTouchEventListener(btnOKEvt)	
end

local function procUI(self)
	procAddressLayer(self)
	procTelPhoneLayer(self)
end

local function showAddressLayer(self)
	self.imgTelPhonebg:hide()
	self.imgAddressbg:show()
end

local function showTelPhoneLayer(self)
	self.imgTelPhonebg:show()
	self.imgAddressbg:hide()
end

function UserAddressInfoLayerCtrller:showLayer(k)
	if k == 0 then
		showAddressLayer(self)
	else
		showTelPhoneLayer(self)
	end
end

function UserAddressInfoLayerCtrller:reqGetUserAddressInfo()
	local url = urls.reqExchangeAddressUrl ..cc.dataMgr.lobbyLoginData.userID
	print("url = " ..url)
	httpUtils.reqHttp(url, function(ret, response)
		if self.isExitLayer then return end
		if ret then
			--app.holdOn.hide()
			local info = json.decode(response)
			if info == nil then
				return
			end
		--	dump(info)
			self.tfName:setString(info.ContactName)
			self.tfTel:setString(info.ContactTel)
			self.tfTel_:setString(info.ContactTel)
			self.tfAddress:setString(info.PostAddress)
			self.txtAddress:setString(info.PostAddress)
			self.tfPost:setString(info.PostCode)

			if info.ContactTel == ""  then
				self.isTelFilled = false
			else
				self.isTelFilled = true
			end

			if self.txtAddress == "" then --有其中一项填写，断定为全部填写
				self.isAllFilled = false
			else
				self.isAllFilled = true
				self.isTelFilled = true
			end
		end
	end, true)
end

function UserAddressInfoLayerCtrller:createLayer()
	self.userAddressInfoLayer = cc.CSLoader:createNode("Layers/UerAddressInfoLayer.csb")

	procUI(self)

	self.isTelFilled = false
	self.isAllFilled = false
	self.isExitLayer = false
	self.userAddressInfoLayer:onNodeEvent("exit", function()
		print("<------exit self.userAddressInfoLayer")
		self.isExitLayer = true
	end)

	return self.userAddressInfoLayer
end

return UserAddressInfoLayerCtrller