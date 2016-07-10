--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/12/30
-- Time: 9:40
-- To change this template use File | Settings | File Templates.
--


local UserInfoLayer = class("UserInfoLayer", function()
    return display.newLayer()
end)

function UserInfoLayer:cotr()

end

function UserInfoLayer:createUserInfoLayer(path)
    path = path or "dzpk/res/NodeUserInfo.csb"
    local node = cc.CSLoader:createNode(path)
    node:setPosition(568, 360)
    node:addTo(self)
    self:hide()
    return self
end

local function getWinRate(win, lose, draw)
    if win == 0 then
        return "0%"
    elseif lose + draw == 0 then
        return "100%"
    else
        local rate = win / (win + lose + draw) * 100
        print("rate = " ..rate)
        return string.format("%.2f", rate) .."%"
    end
end

function UserInfoLayer:updateUserInfoLayerByChair(chair)
    if app.runningScene.tableUsersByChair == nil or app.runningScene.tableUsersByChair[chair] == nil then return end
    local userID = app.runningScene.tableUsersByChair[chair].userData.userID
    local userdata =  cc.dataMgr.tableUsers[userID]

    local imgBack = app.seekChildByName(self, "Image_background")
    local head = imgBack:getChildByName("Image_head")
    local _icon = userdata.userData.icon
    if _icon > 10 then
        _icon = 0
    end
    local fn = "avatar/" .. _icon .. ".jpg"
    head:loadTexture(fn)

    local name = imgBack:getChildByName("Text_name")
    local strNickName = userdata.userData.strNickName
    name:setString(strNickName)

    local beansNum = imgBack:getChildByName("BitmapFontLabel_beans_num")
    beansNum:setString(string.format("%d", i64_toInt(userdata.userData.gameCurrency)))

    local shenglvNum = imgBack:getChildByName("BitmapFontLabel_sheng_lv_num")
    shenglvNum:setString(getWinRate(userdata.gameData.nWin, userdata.gameData.nLose, userdata.gameData.nDraw))

    local idNum = imgBack:getChildByName("BitmapFontLabel_id_num")
    idNum:setString(string.format("%d", userID))
end

return UserInfoLayer