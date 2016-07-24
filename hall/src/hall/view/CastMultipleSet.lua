--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/11/10
-- Time: 9:59
-- To change this template use File | Settings | File Templates.
--- 底注设置
local castMultipleSet = class("CastMultipleSet",function()
    return display.newLayer()
end)

--以node为基础的查找函数
function app.seekChildByName(root,name)
    if root:getName()==name then
        return root
    else
        local child = root:getChildren()
        for i=1,#child do
            local tmp = app.seekChildByName(child[i],name)
            if tmp~=nil then
                return tmp
            end
        end
    end
    return nil
end

function app.seekChildByTag(root,tag)
    if root:getTag()==tag then
        return root
    else
        local child = root:getChildren()
        for i=1,#child do
            local tmp = app.seekChildByTag(child[i],tag)
            if tmp~=nil then
                return tmp
            end
        end
    end
    return nil
end

--- 将map排序返回，isBiggerFunc(Des,res)
local function _sortBigMapByKey(sortMap,isBiggerFunc)
    local tmpSort = {}
    for k,v in pairs(sortMap) do
        local isHave = false
        local orgItem = {}
        orgItem.key = k
        orgItem.v = v
        for i=1,#tmpSort do
            if isHave==false and isBiggerFunc(tmpSort[i].key,k)==true then
                isHave = true
                orgItem.key = tmpSort[i].key
                orgItem.v = tmpSort[i].v
                tmpSort[i].key = k
                tmpSort[i].v = v
            elseif isHave==true then
                local tmp = {}
                tmp.k = tmpSort[i].key
                tmp.v = tmpSort[i].v
                tmpSort[i].key = orgItem.key
                tmpSort[i].v = orgItem.v
                orgItem.key = tmp.k
                orgItem.v = tmp.v
                end
        end
        tmpSort[#tmpSort+1] = {}
        tmpSort[#tmpSort].key = orgItem.key
        tmpSort[#tmpSort].v = orgItem.v
    end
    return tmpSort
end

function castMultipleSet:init(root,data,bShow)
    print("<===castMultipleSet")
    -- 初始化数据
    cc.dataMgr.castMultSetInfo.useCastMultSet = true    -- 使用自定义底注
    self.rootLyr = root
    data = data or cc.dataMgr.castMultSet.beiShuInfo
    bShow = bShow or true
    cc.dataMgr.castMultSet = {}
    local tmpData = {}
    tmpData.bSetBet = data.bSetBet
    tmpData.nBet = data.nBet
    tmpData.betInfo = table.deepcopy(data.betInfo)
    tmpData.gameCurrencyLimit = data.gameCurrencyLimit
    cc.dataMgr.castMultSet.beiShuInfo = tmpData

    -- 将底注列表按从大到小排序
    self.sortCastMultList = _sortBigMapByKey(cc.dataMgr.castMultSet.beiShuInfo.betInfo,function(des,res)
        if res>des then
            return true
        end
        return false
    end)
    self.tmpSelectCast = 0
    for k,v in pairs(cc.dataMgr.castMultSet.beiShuInfo.betInfo) do
        if v==cc.dataMgr.castMultSet.beiShuInfo.gameCurrencyLimit then
            cc.dataMgr.castMultSet.beiShuInfo.beiShuKey=k
            break
        end
    end
    self.castMultSetLogic = require("hall/src/hall/logic/CastMultipleSetLogic.lua").new()

    -- 初始化UI
    --display.loadSpriteFrames("src/hall/res/hall/Resources/diZhuSet/diZhuSetRes.plist","src/hall/res/hall/Resources/diZhuSet/diZhuSetRes.png")
    local rmLyr = cc.CSLoader:createNode("Layers/DiZhuSetLayer.csb")
    self.resLyr = rmLyr
    self.rootLyr:addChild(rmLyr)

    --self:initUI()

    self.tableSignWight = app.seekChildByName(rmLyr,"Image_dzs_tableSignBg"):setVisible(false)
    self.diZhuText = app.seekChildByName(rmLyr,"Text_setsingle")
    self.limtDouText = app.seekChildByName(rmLyr,"Text_dzs_min")
    self.listPanel = app.seekChildByName(rmLyr,"Panel_dzs_listPanel"):setVisible(false)
    self.listPanel:addTouchEventListener(function(obj,type)
        if type==2 then
            app.castMultSet.listPanel:setVisible(false)
        end
    end)
    self.dzsPanel = app.seekChildByName(rmLyr,"Panel_diZhuSet"):setVisible(false)
    self.dzsPanel:addTouchEventListener(function(obj,type)
        if type==2 then
            app.castMultSet.dzsPanel:setVisible(false)
        end
    end)
    self.switchBtn = app.seekChildByName(rmLyr,"Button_dzs_dzSetSwitch"):setVisible(false):setPressedActionEnabled(true)
    self.switchBtn:addTouchEventListener(function(obj,type)
        if type==2 then
            app.audioPlayer:playClickBtnEffect()
            app.castMultSet.dzsPanel:setVisible(true)
            if self:checkDiZhuInvalid(cc.dataMgr.castMultSet.beiShuInfo.gameCurrencyLimit)==false then
                cc.dataMgr.castMultSet.beiShuInfo.gameCurrencyLimit = 0
                cc.dataMgr.castMultSet.beiShuInfo.nBet = 0
            end
            app.castMultSet:initDiZhuUI(cc.dataMgr.castMultSet.beiShuInfo.gameCurrencyLimit,1)
        end
    end)
    if bShow and cc.dataMgr.selectGameType~=12 then
        self.switchBtn:setVisible(true)
    end
    app.seekChildByName(self.dzsPanel,"Button_dzs_close"):setPressedActionEnabled(true):addTouchEventListener(function(obj,type)
        if type==2 then
            app.audioPlayer:playClickBtnEffect()
            app.castMultSet.dzsPanel:setVisible(false)
        end
    end)
    app.seekChildByName(self.dzsPanel,"Image_dzs_setBg"):addTouchEventListener(function(obj,type)
        if type==2 then
            app.audioPlayer:playClickBtnEffect()
            app.castMultSet.listPanel:setVisible(true)
        end
    end)
    app.seekChildByName(self.dzsPanel,"Button_dzs_ok"):setPressedActionEnabled(true):addTouchEventListener(function(obj,type)
        if type==2 then
            app.audioPlayer:playClickBtnEffect()
            if app.castMultSet.tmpSelectCast==nil or app.castMultSet.tmpSelectCast == cc.dataMgr.castMultSet.beiShuInfo.nBet then
                app.msgBox.showMsgBox("Succeeful")
                app.castMultSet.dzsPanel:setVisible(false)
            elseif cc.dataMgr.castMultSet.beiShuInfo.betInfo[app.castMultSet.tmpSelectCast]>i64_toInt(cc.dataMgr.lobbyUserData.lobbyUser.gameCurrency) then
                app.msgBox.showMsgBox("Bet, exceeding the maximum limit their games beans please cap again, please reset")
            else
                app.castMultSet.listPanel:setVisible(false)
                app.holdOn.show("Bet setting...")
                app.castMultSet.castMultSetLogic:sendCastSetReq(app.castMultSet.tmpSelectCast,cc.dataMgr.castMultSet.beiShuInfo.betInfo[app.castMultSet.tmpSelectCast])
            end
        end
    end)

--[[
--  创建最低游戏豆输入框
    self.limtDouText:setVisible(false)
    local crcyBg = app.seekChildByName(rmLyr,"Image_dzs_minBg"):setVisible(false)
    self.crcyEdit = app.EditBoxFactory:createEditBoxByImage(crcyBg,"至少需要"..self.sortCastMultList[#(self.sortCastMultList)-1].v.."游戏豆")
    self.crcyEdit:setInputMode(2)
    --self.phoneNumEdit:setInputFlag(0)
    self.crcyEdit:registerScriptEditBoxHandler(function(type,obj)
        if type=="began" then
            obj:setString("")
        elseif type=="changed" then
            local currcy = obj:getString()
            local bet = app.castMultSet:checkCurrcyBet(currcy)
            if bet==-1 then
                app.msgBox.showMsgBox("没有此倍数的游戏豆设置")
                obj:setString(cc.dataMgr.castMultSet.beiShuInfo.betInfo[app.castMultSet.tmpSelectCast])
                return
            end
            app.castMultSet:initDiZhuUI(currcy,1)
        elseif type=="ended" then
        end
    end)
    ]]
    self.crcyEdit = self.limtDouText

    -- 初始化底注类型下拉列表
    local itemDis = app.seekChildByName(self.listPanel,"Image_dzs_listItemBg"):setVisible(false)
    local listView = app.seekChildByName(self.listPanel,"ListView_dzs_list")
    local tmpSort = self.sortCastMultList

    local index = 0
    for i=1,#tmpSort do
        local key = tmpSort[i].key
        local value = tmpSort[i].v
        local keyText = key
        if key==0 then
            keyText = "Cancel"
        end
        local item = itemDis:clone()
        app.seekChildByName(item,"Text_dzs_listItem"):setString(keyText)
        item:setVisible(true)
        item.key = key
        item:addTouchEventListener(function(obj,type)
            if type==2 then
                app.castMultSet:initDiZhuUI(obj.key)
                app.castMultSet.listPanel:setVisible(false)
            end
        end)
        listView:insertCustomItem(item,index)
        index = index+1
    end

    self:initDiZhuUI()

end

--- 通过游戏豆检查倍数，返回-1 未检查失败
function castMultipleSet:checkCurrcyBet(currcy)
    local bet = -1
    if currcy==nil then
        return -1
    end
    for k,v in pairs(cc.dataMgr.castMultSet.beiShuInfo.betInfo) do
        if v==tonumber(currcy) then
            bet=k
            break
        end
    end
    return bet
end

--- 初始化UI
function castMultipleSet:initUI()
    local rmLyr = self.resLyr
end

--- 通过倍数或者游戏豆重置设置UI，默认为 0 倍数key   ,1为游戏豆
function castMultipleSet:initDiZhuUI(infoKey,kind)
    if infoKey and cc.dataMgr.castMultSet.beiShuInfo==nil then
        return
    end
    local bet = -1
    local currcy = -1
    if infoKey==nil or (kind and kind==1) then
        local tmpCry = cc.dataMgr.castMultSet.beiShuInfo.gameCurrencyLimit
        if infoKey~=nil then
            tmpCry = infoKey
        end
        currcy = tmpCry
        bet = self:checkCurrcyBet(currcy)
    else
        bet = infoKey
        currcy = cc.dataMgr.castMultSet.beiShuInfo.betInfo[bet]
    end

    self.tmpSelectCast = bet    -- 临时选择倍数储存
    local stateStr = ""
    local keyStr = ""
    local valueStr = ""
    if bet==0 or bet==-1 then
        stateStr = "Not setup"
        keyStr = "Cancel"
        valueStr = ""
    else
        stateStr = "Ante:"..bet
        keyStr = bet
        valueStr = currcy
    end
    app.seekChildByName(self.dzsPanel,"Text_dzs_state"):setString(stateStr)
    self.diZhuText:setString(keyStr)
    --self.limtDouText:setString(valueStr)
    self.crcyEdit:setString(valueStr)

    if self:checkDiZhuInvalid(currcy) then
        app.seekChildByName(self.resLyr,"Text_invailText"):setVisible(false)
    else
        app.seekChildByName(self.resLyr,"Text_invailText"):setVisible(true)
    end
end

--- 添加桌子底注标识 kind:传入的参数是倍数还是游戏豆值,默认为 0 倍数
function castMultipleSet:addTableSign(tableID,bet,kind)
    local table = cc.dataMgr.tables[tableID]
    if self.tableSignWight == nil then
        return
    end
    local signText = "Ante：1"
    local curry = 0
    if kind~=nil and kind==1 then
        curry = self:checkCurrcyBet(bet)
    else
        curry = bet
    end
    cc.dataMgr.tableBetInfoInRoom[tableID] = curry
    if math.floor(curry/10000)>=1 then
        signText = "Ante："..math.floor(curry/10000).."TK"
    elseif math.floor(curry/1000)>=1 then
        signText = "Ante："..math.floor(curry/1000).."K"
    elseif math.floor(curry/100)>=1 then
        signText = "Ante："..math.floor(curry/100).."H"
    else
        signText = "Ante："..curry
    end

    local sign = app.seekChildByName(table,"Image_dzs_tableSignBg")
    if sign==nil then
        sign = self.tableSignWight:clone()
        sign:setPosition(table:getContentSize().width/2,table:getContentSize().height/2 - 25)
        table:addChild(sign,100)
    end

    if curry==0 then
        sign:setVisible(false)
    else
        sign:setVisible(true)
        app.seekChildByName(sign,"Text_dzs_tableSign"):setString(signText)
    end
end

--- 设置底注回复
function castMultipleSet:respSastSet(data)
    print("ftest respSastSet 1")
    if data.nResult == 0 then
        print("ftest respSastSet 2")
        cc.dataMgr.castMultSet.beiShuInfo.nBet = data.nBet
        cc.dataMgr.castMultSet.beiShuInfo.gameCurrencyLimit = data.gamecurrencyLimit
        self:initDiZhuUI(data.nBet)
        if app.setBetLayerDZPK and app.setBetLayerDZPK:isVisible() then
            app.setBetLayerDZPK:hideSetBetUI()

            -- 发送入座消息
            app.setBetLayerDZPK:sendEnterSeat()
            app.setBetLayerDZPK = nil
        else
            app.msgBox.showMsgBox("Setup ante succeed.")
            app.castMultSet.dzsPanel:setVisible(false)
        end
    elseif data.nResult==1 then
        print("ftest respSastSet 2")
        app.msgBox.showMsgBox("Setup ante failed.")
    elseif data.nResult==2 then
        app.msgBox.showMsgBox("Not enough chips.")
    elseif data.nResult==3 then
        app.toast.show("Not enough chips, ante setup failed.")
        cc.dataMgr.castMultSet.beiShuInfo.nBet = data.nBet
        cc.dataMgr.castMultSet.beiShuInfo.gameCurrencyLimit = data.gamecurrencyLimit
        cc.dataMgr.tableBetInfoInRoom[cc.dataMgr.selectTableIDNow] = cc.dataMgr.castMultSet.beiShuInfo.nBet
    end
end

--- 检测底注设置是否失效;kind 默认0游戏豆；
function castMultipleSet:checkDiZhuInvalid(bet,kind)
    if kind and kind==1 then
        bet = cc.dataMgr.castMultSet.beiShuInfo.betInfo[bet]
    end
    if bet>i64_toInt(cc.dataMgr.lobbyUserData.lobbyUser.gameCurrency) then
        return false
    end
    return true
end

function castMultipleSet:onExit()
    self.castMultSetLogic:onExit()
    --display.removeSpriteFrames("src/hall/res/hall/Resources/diZhuSet/diZhuSetRes.plist","src/hall/res/hall/Resources/diZhuSet/diZhuSetRes.png")
    app.castMultSet = nil
end

return castMultipleSet

