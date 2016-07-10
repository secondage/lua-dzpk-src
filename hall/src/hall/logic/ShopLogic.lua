--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/8/19
-- Time: 15:33
-- To change this template use File | Settings | File Templates.
--
local strShopUrl = clientConfig.homePage.."/Service/Pay/"
local scheduler = require("framework.scheduler")

local network = require "framework.network"
local json = require "framework.json"
local packBody = require "data.packBody"

local targetPlatform = cc.Application:getInstance():getTargetPlatform()


local ShopLogic = class("ShopLogic")

function ShopLogic:ctor()
    self.shopProcs = {}
    function self.shopProcs.proc_PL_PHONE_LC_SHOWFIRSTINFO_ACK_P(buf)
        local data = wnet.PL_LC_SHOWFIRSTINFO.new()
        data:bufferOut(buf)
        cc.dataMgr.rechargeAwardConfig = data
        print("bStartRechargeAward"..data.bStartRechargeAward)
        self:reqGetRechargeAwardInfo()
        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "PL_PHONE_LC_SHOWFIRSTINFO_ACK_P"})
    end

    function self.shopProcs.proc_PL_PHONE_LC_GETRECHARGEAWARDINFO_ACK_P(buf)
        local data = wnet.PL_PHONE_LC_GETRECHARGEAWARDINFO.new()
        data:bufferOut(buf)
        cc.dataMgr.rechargeAwardInfo = data
        app.reminderLogic:upDateBenefitReminder()

        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "PL_PHONE_LC_GETRECHARGEAWARDINFO_ACK_P"})
    end

    function self.shopProcs.proc_PL_PHONE_LC_GETRECHARGEAWARD_ACK_P(buf)
        local data = wnet.PL_PHONE_LC_GETRECHARGEAWARD.new()
        data:bufferOut(buf)
        local vipData = data.vipData
        local userData = cc.dataMgr.lobbyUserData.lobbyUser
        local userInfoMore = cc.dataMgr.userInfoMore
        --没有奖励时发过来的数据是0
        if i64_toInt(data.totalGameCurrency) > 0 then
            userData.gameCurrency = data.totalGameCurrency
        end
        if i64_toInt(data.totalYuanBao) > 0 then
            userInfoMore.ingot = data.totalYuanBao
        end
        userData.vipExp = vipData.vipExp
        userData.vipBegin = vipData.vipBegin
        userData.vipEnd = vipData.vipEnd
        userData.vipLevel = vipData.vipLevel
        userData.vipUp = vipData.vipUp

        self:reqGetRechargeAwardInfo()

        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "USERDATA_CHANGED"})
        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "PL_PHONE_LC_GETRECHARGEAWARD_ACK_P", data = data})
    end

    --IOS商品列表
    function self.shopProcs.proc_PL_PHONE_IOS_RECHARGEINFO_ACK_P(buf)
        print("-------product info----------")
        local data = wnet.PL_PHONE_IOS_RECHARGEINFO.new()
        data:bufferOut(buf)
        cc.dataMgr.productsList = data.iosRechargeInfo
        --[[
        local productsList = cc.dataMgr.productsList
        for i = 1, #productsList do
            local tmp = productsList[i]
            print("productId", tmp.productId)
            print("productType", tmp.productType)
            print("productPrice", tmp.productPrice)
            print("productNum", tmp.productNum)
            print("productIcon", tmp.productIcon)
        end
        --]]
        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "PRODUCT_LIST"})
    end

    function self.shopProcs.proc_PL_PHONE_IOS_RECHARGE_ACK_P(buf)
        print("验证恢复……")
        local data = wnet.PL_PHONE_IOS_RECHARGE_ACK.new()
        data:bufferOut(buf)
        if data.nRet == 0 then
            self:upDateCurrencyInfo()
        end
        if targetPlatform ~= cc.PLATFORM_OS_WINDOWS then
            local bridge = require("app.func.Bridge")
            bridge.onIOSRechargeResult(data)
        end
    end
end

function ShopLogic:procMsgs(socket, buf, opCode)
    local msgProc = self.shopProcs["proc_" .. (cc.protocolNumber:getProtocolName(opCode) or "")]

    if msgProc ~= nil then
        printf("This is a shop message.\n")
        msgProc(buf)
        return true
    else
        return false
    end
end

--获取商品列表
function ShopLogic:reqGetProductsList()
    print("request productList")
    local strUrl = strShopUrl.."PayProducts"
    local request = network.createHTTPRequest(function(event)self:onGetProductsListResult(event)
    end, strUrl, "GET")
    request:start()
end

--IOS从大厅服务器获取商品列表
function ShopLogic:ios_reqGetProductsList()
    print("ios request productList")
    local data = packBody.new(cc.protocolNumber.PL_PHONE_IOS_RECHARGEINFO_REQ_P, cc.dataMgr.lobbyLoginData.userID)
    local pack = data:bufferIn():getPack()
    self:sendReqLobby(pack)
end

--商品列表
function ShopLogic:onGetProductsListResult(event)

    if event == nil then
        printf("event is nil")
        return
    end

    printf("event.name :"..event.name)
    local ok = (event.name == "completed")
    local request = event.request

    if not ok then
        -- 请求失败，显示错误代码和错误消息
        print(request:getErrorCode(), request:getErrorMessage())
        return
    end

    local code = request:getResponseStatusCode()
    if code ~= 200 then
        -- 请求结束，但没有返回 200 响应代码
        print(code)
        return
    end

    -- 请求成功，显示服务端返回的内容
    local strProductsList = request:getResponseString()
    --print(strProductsList)
    local table = json.decode(strProductsList)
    cc.dataMgr.productsList = table.data
    local productsList = cc.dataMgr.productsList
    for key, value in pairs(productsList) do
        local data = value
        printf("id:"..value.Id.."    name:"..value.ProductName.."    Price:"..data.Price)
    end
    display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "PRODUCT_LIST"})
end

--获取支付宝支付订单信息
function ShopLogic:reqGetOderInfoAliPay(productId)
    local userData = cc.dataMgr.lobbyUserData.lobbyUser
    local strUrl = strShopUrl.."AlipayOrder"
    --strUrl = strUrl.."?accountId="..userData.userID.."&productId="..productId
    local request = network.createHTTPRequest(function(event)self:onGetOrderInfoResultAliPay(event)
    --end, strUrl, "GET")
    ---[[
    end, strUrl, "POST")
    request:addPOSTValue("accountId", userData.userID)
    request:addPOSTValue("productId", productId)
    --]]
    request:start()
    print("reqGetOderInfoAliPay")
end

--支付宝支付订单信息
function ShopLogic:onGetOrderInfoResultAliPay(event)
    print("onGetOrderInfoResultAliPay")
    if event == nil then
        printf("event is nil")
        return
    end

    printf("event.name :"..event.name)
    local ok = (event.name == "completed")
    local request = event.request

    if not ok then
        -- 请求失败，显示错误代码和错误消息
        print(request:getErrorCode(), request:getErrorMessage())
        return
    end

    local code = request:getResponseStatusCode()
    if code ~= 200 then
        -- 请求结束，但没有返回 200 响应代码
        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "ORDER_INFO", data = "failed"})
        print(code)
        return
    end

    -- 请求成功，显示服务端返回的内容
    local strOrderInfo = request:getResponseString()
    --print(strOrderInfo)
    local resultTable = json.decode(strOrderInfo)
    if resultTable.message == "success" then
        local orderInfo = resultTable.data
        print(orderInfo)
        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "ORDER_INFO", data = resultTable.message})
        --调用支付宝SDK的支付API
        if targetPlatform ~= cc.PLATFORM_OS_WINDOWS then
            local bridge = require("app.func.Bridge")
            bridge.AliPay(orderInfo)
        end
    else
        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "ORDER_INFO", data = resultTable.message})
    end
end

--获取微信支付订单信息
function ShopLogic:reqGetOrderInfoWeChat(productId)
    local userData = cc.dataMgr.lobbyUserData.lobbyUser
    local strUrl = strShopUrl.."WechatpayOrder"
    --strUrl = strUrl.."?accountId="..userData.userID.."&productId="..productId
    local request = network.createHTTPRequest(function(event)self:onGetOrderInfoResultWeChat(event)
    --end, strUrl, "GET")
    end, strUrl, "POST")
    request:addPOSTValue("accountId", userData.userID)
    request:addPOSTValue("productId", productId)
    request:start()
end

--微信支付订单信息
function ShopLogic:onGetOrderInfoResultWeChat(event)
    if event == nil then
        printf("event is nil")
        return
    end

    printf("event.name :"..event.name)
    local ok = (event.name == "completed")
    local request = event.request

    if not ok then
        -- 请求失败，显示错误代码和错误消息
        print(request:getErrorCode(), request:getErrorMessage())
        return
    end

    local code = request:getResponseStatusCode()
    if code ~= 200 then
        -- 请求结束，但没有返回 200 响应代码
        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "ORDER_INFO", data = "failed"})
        print(code)
        return
    end

    -- 请求成功，显示服务端返回的内容
    local strOrderInfo = request:getResponseString()
    --print(strOrderInfo)
    local resultTable = json.decode(strOrderInfo)
    if resultTable.message == "success" then
        local orderInfo = resultTable.data
        print(orderInfo)
        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "ORDER_INFO", data = resultTable.message})
        --调用微信支付API
        if targetPlatform ~= cc.PLATFORM_OS_WINDOWS then
            local bridge = require("app.func.Bridge")
            bridge.WXPay(orderInfo)
        end
    else
        --获取订单失败
        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "ORDER_INFO", data = resultTable.message})
    end
end

--获取银联支付订单信息
function ShopLogic:reqGetOrderInfoUPPay(productId)
    local userData = cc.dataMgr.lobbyUserData.lobbyUser
    local strUrl = strShopUrl.."UnionpayOrder"
    --strUrl = strUrl.."?accountId="..userData.userID.."&productId="..productId
    local request = network.createHTTPRequest(function(event)self:onGetOrderInfoResultUPPay(event)
    --end, strUrl, "GET")
    end, strUrl, "POST")
    request:addPOSTValue("accountId", userData.userID)
    request:addPOSTValue("productId", productId)
    request:start()
end

--银联支付订单信息
function ShopLogic:onGetOrderInfoResultUPPay(event)
    if event == nil then
        printf("event is nil")
        return
    end

    printf("event.name :"..event.name)
    local ok = (event.name == "completed")
    local request = event.request

    if not ok then
        -- 请求失败，显示错误代码和错误消息
        print(request:getErrorCode(), request:getErrorMessage())
        return
    end

    local code = request:getResponseStatusCode()
    if code ~= 200 then
        -- 请求结束，但没有返回 200 响应代码
        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "ORDER_INFO", data = "failed"})
        print(code)
        return
    end

    -- 请求成功，显示服务端返回的内容
    local strOrderInfo = request:getResponseString()
    --print(strOrderInfo)
    local resultTable = json.decode(strOrderInfo)
    if resultTable.message == "success" then
        local orderInfo = resultTable.data
        local strTn = orderInfo.tn
        local strDebug = orderInfo.debug

        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "ORDER_INFO", data = resultTable.message})
        if targetPlatform ~= cc.PLATFORM_OS_WINDOWS then
            local bridge = require("app.func.Bridge")
            bridge.UPPay(strTn, strDebug)
        end
    else
        display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "ORDER_INFO", data = resultTable.message})
    end
end

function ShopLogic:sendReqLobby(pack)
    if cc.msgHandler.socketLobby ~= nil then
        cc.msgHandler.socketLobby:send(pack)
    else
        print("cc.msgHandler.socketLobby is nil")
    end
end

function ShopLogic:reqGetRechargeAwardInfo()
    local data = packBody.new(cc.protocolNumber.PL_PHONE_GETRECHARGEAWARDINFO_REQ_P, cc.dataMgr.lobbyLoginData.userID)
    local pack = data:bufferIn():getPack()
    self:sendReqLobby(pack)
end

function ShopLogic:reqGetRechargeAward(awardOrder)
    print("reqGetRechargeAward, awardOrder"..awardOrder)
    local data = wnet.PL_PHONE_CL_GETRECHARGEAWARD.new(cc.protocolNumber.PL_PHONE_CL_GETRECHARGEAWARD_REQ_P, cc.dataMgr.lobbyLoginData.userID, 0, 0, 0)
    local pack = data:bufferIn(awardOrder):getPack()
    self:sendReqLobby(pack)
end

function ShopLogic:reqIOSRecharge(userId, transActionId, recevieData)
    local data = wnet.PL_PHONE_IOS_RECHARGE.new(cc.protocolNumber.PL_PHONE_IOS_RECHARGE_REQ_P, cc.dataMgr.lobbyLoginData.userID, 0, 0, 0)
    local pack = data:bufferIn(userId, transActionId, recevieData):getPack()
    self:sendReqLobby(pack)
end

function ShopLogic:upDateCurrencyInfo()
    --刷新代币信息直到信息变化
    self.tickScheduler = nil
    local currGameCurrencyNum = cc.dataMgr.lobbyUserData.lobbyUser.gameCurrency
    local currGoldCurrencyNum = cc.dataMgr.lobbyUserData.lobbyUser.goldCurrency
    local function _doUpdateCurrencyInfo()
        print("_doUpdateCurrencyInfo")
        if currGameCurrencyNum == cc.dataMgr.lobbyUserData.lobbyUser.gameCurrency and
                currGoldCurrencyNum == cc.dataMgr.lobbyUserData.lobbyUser.goldCurrency then
            app.cofferLogic:reqGetBankData()
        else
            --变化后请求充值奖励信息
            if self.tickScheduler ~= nil then
                scheduler.unscheduleGlobal(self.tickScheduler)
                self.tickScheduler = nil
            end
            app.shopLogic:reqGetRechargeAwardInfo()
        end
    end
    _doUpdateCurrencyInfo()
    self.tickScheduler = scheduler.scheduleGlobal(_doUpdateCurrencyInfo, 10)
end

function ShopLogic:stopTimer()
    if self.tickScheduler ~= nil then
        scheduler.unscheduleGlobal(self.tickScheduler)
        self.tickScheduler = nil
    end
end

return ShopLogic