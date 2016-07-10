--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/8/25
-- Time: 16:30
-- To change this template use File | Settings | File Templates.
--
local ToastLayer = require("app.func.ToastLayer")

local AvatarSelectLayer = class("AvatarSelectLayer")

local function listenEvent(self)

end

local function initWidgets(self)
    local root = self.rootLayer
    root:addTouchEventListener(function(widget, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            self:setVisible(false)
        end
    end)

    self.listAvatar = ccui.Helper:seekWidgetByName(root, "ListView_avatar")
    self.listItem = ccui.Helper:seekWidgetByName(root, "Image_avatarItem")
    self.listItem:setVisible(false)
    self.listItemBig = ccui.Helper:seekWidgetByName(root, "Image_avatarItemBig")
    self.listItemBig:setVisible(false)
    local userData = cc.dataMgr.lobbyUserData.lobbyUser
    self.selectedIcon = userData.icon
    for i = 1, 10 do
        self:insertItem(i)
    end
    local btnOk = ccui.Helper:seekWidgetByName(root, "Button_ok")
    btnOk:setPressedActionEnabled(true)
    btnOk:addTouchEventListener(function(widget, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            if self.selectedIcon ~= userData.icon then
                app.individualLogic:reqChangeBasicInfo(userData.gender, "", self.selectedIcon)
            end
            self:setVisible(false)
        end
    end)

    --local btnReturn = ccui.Helper:seekWidgetByName(root, "Button_return")
    local btnClose = ccui.Helper:seekWidgetByName(root, "Button_close")
    btnClose:setPressedActionEnabled(true)
    local function closeUI(widget, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            self:setVisible(false)
        end
    end
    btnClose:addTouchEventListener(closeUI)
    --btnReturn:addTouchEventListener(closeUI)

end

function AvatarSelectLayer:insertItem(index)
    local item = self.listItem:clone()
    item:addTouchEventListener(function(widget, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            self:setItemSelected(self.selectedIcon, false)
            self.selectedIcon = index
            self:setItemSelected(self.selectedIcon, true)
        end
    end)
    item:setVisible(true)
    local size = item:getContentSize()
    local filePath = "avatar/"..index..".jpg"
    local spIcon = cc.Sprite:create(filePath)
    spIcon:setScale(0.8)
    spIcon:setPosition(size.width/2, size.height/2 + 6)
    local stencil = cc.Sprite:create("avatar/stencil1.png")
    size = spIcon:getContentSize()
    stencil:setPosition(size.width/2, size.height/2)
    stencil:setScale(1.11)
    spIcon:addChild(stencil)
    item:addChild(spIcon)
    self.listAvatar:insertCustomItem(item, index - 1)
end

function AvatarSelectLayer:insertBigItem(index)
    local item = self.listItemBig:clone()
    item:setVisible(true)
    item:setVisible(true)
    local size = item:getContentSize()
    local filePath = "avatar/"..index..".jpg"
    local spIcon = cc.Sprite:create(filePath)
    spIcon:setScale(0.9)
    spIcon:setPosition(size.width/2, size.height/2)
    local stencil = cc.Sprite:create("avatar/stencil1.png")
    size = spIcon:getContentSize()
    stencil:setPosition(size.width/2, size.height/2)
    stencil:setScale(1.11)
    spIcon:addChild(stencil)
    item:addChild(spIcon)
    self.listAvatar:insertCustomItem(item, index - 1)
end

function AvatarSelectLayer:setItemSelected(index, isSelected)
    if index == 0 then return end
    self.listAvatar:removeItem(index - 1)
    if isSelected then
        self:insertBigItem(index)
        self.selectedIcon = index
    else
        self:insertItem(index)
    end
end

function AvatarSelectLayer:init(currScene)
    self.root = cc.CSLoader:createNode("Layers/AvatarSelectLayer.csb")
    self.rootLayer = self.root:getChildByName("Panel_avatarSelect")
    self.currScene = currScene
    self.currScene:addChild(self.root, 25)
    initWidgets(self)
    listenEvent(self)
    self:setVisible(false)
end

function AvatarSelectLayer:fillDataToUI()
    local userData = cc.dataMgr.lobbyUserData.lobbyUser
    self:setItemSelected(self.selectedIcon, false)
    self:setItemSelected(userData.icon, true)
end

function AvatarSelectLayer:setVisible(bShow)
    if bShow then
        self:fillDataToUI()
        app.hallScene.nPopLayers = app.hallScene.nPopLayers + 1
    else
        app.hallScene.nPopLayers = app.hallScene.nPopLayers - 1
    end
    self.root:setVisible(bShow)
end

return AvatarSelectLayer

