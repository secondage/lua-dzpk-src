--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/12/30
-- Time: 11:36
-- To change this template use File | Settings | File Templates.
--
local utils = {}
function utils.updateTextNum(label, newNum)
    local oldNum = tonumber(label:getString()) or 0
    local delta = newNum - oldNum
    local actions = {}
    local tmpNum = oldNum
    for i = 1, 10 do
        tmpNum = delta / 10 + tmpNum
        local num = math.floor(tmpNum)
        if i == 10 then
            num = newNum
        end
        local delay = cc.DelayTime:create(0.05)
        local funcNext = cc.CallFunc:create(function()
            label:setString(num)
        end)
        actions[#actions + 1] = delay
        actions[#actions + 1] = funcNext
    end
    local action = cc.Sequence:create(actions)
    label:runAction(action)
end

return utils

