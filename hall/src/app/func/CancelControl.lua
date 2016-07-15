--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/9/25
-- Time: 9:28
-- To change this template use File | Settings | File Templates.
--
local CancelControl = class("CancelControl")
CancelControl.layers = {}
CancelControl.scenes = {}

function CancelControl:pushScene(scene)
    if self.scenes[#self.scenes] ~= scene then
        self.scenes[#self.scenes + 1] = scene
        self.layers = {}
    end
end

function CancelControl:popScene(name)
    if name ~= nil then
        if self.scenes[#self.scenes] == name then
            return table.remove(self.scenes)
        end
    else
        return table.remove(self.scenes)
    end
end

function CancelControl:pushLayer(layer)
    if self.layers[#self.layers] ~= layer then
        self.layers[#self.layers + 1] = layer
    end
end

function CancelControl:popLayer(layer)
    if layer ~= nil then
        if self.layers[#self.layers] == layer then
            return table.remove(self.layers)
        end
    else
        return table.remove(self.layers)
    end
end

function CancelControl:doCancel()
    if app.holdOn.holdOnLayer ~= nil then
        app.holdOn.hide()
    elseif app.msgBox.root ~= nil then
        app.msgBox.hide()
    elseif #self.layers ~= 0 then
        self:doCancelLayer()
    elseif #self.scenes ~= 0 then
        self:doCancelScene()
    end
end

function CancelControl:doCancelScene()
    local currSceneName = self.scenes[#self.scenes]
    if currSceneName ~= nil then
        if currSceneName == "HallScene" then
            local function funcOk()
                app.sceneSwitcher:enterScene("LoginScene")
            end
            app.msgBox.showMsgBoxTwoBtn("Back to the login screen？", funcOk)
        elseif currSceneName == "LoginScene" then
            local function funcOk()
                --todo:退出游戏
            end
            app.msgBox.showMsgBoxTwoBtn("Exit Game？", funcOk)
        else
            self:popScene()
            local lastSceneName = self.scenes[#self.scenes]
            if lastSceneName ~= nil then
                app.sceneSwitcher:enterScene(lastSceneName)
            end
        end
    end
end

function CancelControl:doCancelLayer()
    local currLayer = self:popLayer()
    currLayer:setVisible(false)
end

return CancelControl
