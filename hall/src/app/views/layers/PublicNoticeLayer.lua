--
-- Author: ChenShao
-- Date: 2015-12-28 09:25:01
--
local PublicNoticeLayerCtrller = class("PublicNoticeLayerCtrller")

function PublicNoticeLayerCtrller:ctor()

end

local function registerExitEvent(self)
	self.publicNoticeLayer:onNodeEvent("exit", function()
		print("<------exit self.publicNoticeLayer")
		
	end)
end

local function procUI(self)
	local imgBg = self.publicNoticeLayer:getChildByName("Image_bg")

	local btnClose = imgBg:getChildByName("Button_close")
	btnClose:setPressedActionEnabled(true)
	btnClose:addTouchEventListener(function(obj, type)
		if type == 2 then
			self.publicNoticeLayer:removeSelf()
		end
	end)

	
end

function PublicNoticeLayerCtrller:createLayer()
	self.publicNoticeLayer = cc.CSLoader:createNode("Layers/PublicNoticeLayer.csb")

	procUI(self)
	registerExitEvent(self)

	return self.publicNoticeLayer
end

function PublicNoticeLayerCtrller:initWebView(strURL)
	local imgBg = self.publicNoticeLayer:getChildByName("Image_bg")
	local layTmp = imgBg:getChildByName("Panel_tmp"):hide()
	
	local pWebView = ccui.WebView:create()
	pWebView:clearBackground()
	pWebView:loadURL(strURL)
	pWebView:setContentSize(layTmp:getContentSize())
	pWebView:setPosition(cc.p(layTmp:getPositionX() + layTmp:getContentSize().width/2, layTmp:getPositionY()+ layTmp:getContentSize().height/2))
	imgBg:addChild(pWebView)
end


return PublicNoticeLayerCtrller