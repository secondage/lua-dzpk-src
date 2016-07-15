--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/9/24
-- Time: 15:45
-- To change this template use File | Settings | File Templates.
--
local ReminderPoint = class("ReminderPoint")

function ReminderPoint:init(parent, name, currScene)
    self.root = display.newSprite("#Resources/newResources/HallScene/hong.png")
    if self.root == nil then return end

    self.eventProtocol = currScene.eventProtocol
    self.name = name
    local sizeSelf = self.root:getContentSize()
    local sizeParent = parent:getContentSize()
    local posX = sizeParent.width - sizeSelf.width / 2
    local posY = sizeParent.height - sizeSelf.height / 2
    self.root:setPosition(posX, posY)
    self.root:addTo(parent)
    self:setVisible(false)
    self:listenEvent()
end

function ReminderPoint:listenEvent()
    print("ReminderPoint:listenEvent")
    self.eventProtocol:addEventListener("UPDATE_REMINDER_POINT", function(event) --刷新提醒点状态
        local data = event.data
        if data.name == self.name then
            print("reminder name:"..data.name.." show?"..tostring(data.bShow))
            self:setVisible(data.bShow)
        end
    end)
end

function ReminderPoint:setVisible(bShow)
    self.root:setVisible(bShow)
end

return ReminderPoint

