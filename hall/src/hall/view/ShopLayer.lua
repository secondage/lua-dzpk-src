--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/9/14
-- Time: 13:41
-- To change this template use File | Settings | File Templates.
--


local ShopLayer = class("ShopLayer")

--ShopLayer.layVip = require("hall.view.VipLayer").new()
ShopLayer.layRecharge = require("hall.view.RechargeLayer").new()

function ShopLayer:init(currScene)
    print("-------------ShopLayer:init")

    self.root = cc.CSLoader:createNode("Layers/ShopLayer.csb")
    self.currScene = currScene
    self.currScene:addChild(self.root, 20)

    --self.layVip:init(currScene, self.root)
    self.layRecharge:init(currScene, self.root)

    self:initWidgets()
    self:setVisible(false)

end

function ShopLayer:initWidgets()
    local layRoot = self.root:getChildByName("Panel_shop")

    self.checkRecharge = ccui.Helper:seekWidgetByName(layRoot, "CheckBox_recharge")
    self.checkRecharge:addEventListener(function(obj, type)
        app.audioPlayer:playClickBtnEffect()
        self:switchLayer(1)
    end)

    --[[
    self.checkVip = ccui.Helper:seekWidgetByName(layRoot, "CheckBox_vip")
    self.checkVip:addEventListener(function(obj, type)
        app.audioPlayer:playClickBtnEffect()
        self:switchLayer(2)
    end)

    self.checkOther = ccui.Helper:seekWidgetByName(layRoot, "CheckBox_other")
    self.checkOther:addEventListener(function(obj, type)
        app.audioPlayer:playClickBtnEffect()
        self:switchLayer(3)
    end)

    self.checkMore = ccui.Helper:seekWidgetByName(layRoot, "CheckBox_more")
    self.checkMore:addEventListener(function(obj, type)
        app.audioPlayer:playClickBtnEffect()
        self:switchLayer(4)
    end)
    --]]
    local btnReturn = ccui.Helper:seekWidgetByName(layRoot, "Button_return")
    btnReturn:addTouchEventListener(function(obj, type)
        if type == 2 then
            app.audioPlayer:playClickBtnEffect()
            self:setVisible(false)
        end
    end)
end

function ShopLayer:switchLayer(flag)
    self.layRecharge:setVisible(flag == 1)
    self.checkRecharge:setSelected(flag == 1)
    --self.layVip:setVisible(flag == 2)
    --self.checkVip:setSelected(flag == 2)
    --[[
    self.checkOther:setSelected(flag == 3)
    self.checkMore:setSelected(flag == 4)
    --]]
end

function ShopLayer:setVisible(bShow, flag)
    self.root:setVisible(bShow)
    if bShow then
        if flag == nil then
            self:switchLayer(1)
            app.popLayer.showEx(self.root)
        else
            self:switchLayer(flag)
        end
    else
        app.hallScene:showHallUI()
    end
end

return ShopLayer

