--
-- Author: ChenShao
-- Date: 2015-09-09 19:43:41
--
local SettingLayerCtrller = class("SettingLayerCtrller")

function SettingLayerCtrller:createLayer(pathRes)
	pathRes = pathRes or "MahjUI/Layers/SettingLayer.csb"
	self.settingLayer = cc.CSLoader:createNode(pathRes)

	self.settingLayer:setAnchorPoint(cc.p(0.5, 0.5))
	self.settingLayer:ignoreAnchorPointForPosition(false)
	self.settingLayer:setPosition(display.cx, display.cy)

	self:procUI()
	return self.settingLayer
end

function SettingLayerCtrller:procUI()
	local layRoof = self.settingLayer:getChildByName("Panel_roof"):show()
	layRoof:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			self.settingLayer:hide()
		end
	end)

	local imgBg = self.settingLayer:getChildByName("Image_setbg"):show()
	imgBg:setTouchEnabled(true)

	local function procEffectUI(parentName, keyName)
		local nodeEffect = imgBg:getChildByName(parentName)
		if not nodeEffect then
			return
		end
		local imgOpen = nodeEffect:getChildByName("Image_open")
		local imgClose = nodeEffect:getChildByName("Image_close")
		local btnOp = nodeEffect:getChildByName("Button_btnOp")

		local btnClosePos = {x = imgOpen:getPositionX() - imgOpen:getContentSize().width / 2 + btnOp:getContentSize().width / 2, 
							y = imgOpen:getPositionY()}
		local btnOpenPos = {x = imgOpen:getPositionX() + imgOpen:getContentSize().width / 2 - btnOp:getContentSize().width / 2, 
							y = imgOpen:getPositionY()}

		local function getBtnPos(state)
			if state then
				return btnOpenPos
			else 
				return btnClosePos
			end
		end

		local function getState()
			if keyName == "isDoubleClick" or keyName == "isShock" then
				return cc.UserDefault:getInstance():getBoolForKey(keyName, false)
			else
				return cc.UserDefault:getInstance():getBoolForKey(keyName, true)
			end
		end
		local state = getState()
		imgOpen:setVisible(state)
		imgClose:setVisible(not state)
		btnOp:setPosition(getBtnPos(state))
		
		local function onBtnEvt(obj, type)
			if type == 2 then
				app.audioPlayer:playClickBtnEffect()
				local function exc(state)
					cc.UserDefault:getInstance():setBoolForKey(keyName, state)
					imgOpen:setVisible(state)
					imgClose:setVisible(not state)
					local moveTo = cc.MoveTo:create(0.2, getBtnPos(state))
					btnOp:stopAllActions()
					btnOp:runAction(moveTo)
				
					if keyName == "isMusic" then	
						cc.UserDefault:getInstance():setFloatForKey("musicVolume", state and 0.5 or 0)
						cc.UserDefault:getInstance():setBoolForKey("isMusic", state and true or false)
						if state then
							app.audioPlayer:playGamingMusic()
							app.audioPlayer:setMusicVolume(0.5)
						else
							app.audioPlayer:stopMusic()
							app.audioPlayer:setMusicVolume(0)
						end
					elseif keyName == "isEffect" then
						app.audioPlayer:setEffectsVolume(state and 0.5 or 0)
						cc.UserDefault:getInstance():setFloatForKey("effectVolume", state and 0.5 or 0)
						cc.UserDefault:getInstance():setBoolForKey("isEffect", state and true or false)
					end
				end

				local state = getState()
				exc(not state)
			end
		end

		imgOpen:addTouchEventListener(onBtnEvt)
		imgClose:addTouchEventListener(onBtnEvt)
		btnOp:addTouchEventListener(onBtnEvt)
	end
	procEffectUI("Node_effect", "isEffect")
	procEffectUI("Node_music", "isMusic")
	procEffectUI("Node_click", "isDoubleClick")
	procEffectUI("Node_shock", "isShock")
end

return SettingLayerCtrller