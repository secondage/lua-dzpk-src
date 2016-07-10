--
-- Author: ChenShao
-- Date: 2015-08-14 16:27:49
--
local bridge = {}
local targetPlatform = cc.Application:getInstance():getTargetPlatform()
local luaj
local luaoc
if cc.PLATFORM_OS_ANDROID == targetPlatform then
	luaj = require("cocos.cocos2d.luaj")
end
if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) then 
	luaoc = require("cocos.cocos2d.luaoc")
end


local javaClassName = "org/cocos2dx/lua/AppActivity"
local iosClassName = "CallOC"

function bridge.getAppInfo()
	local versionCode = 0
	local methodName = "getAppInfo"
	if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) then 
		local ok, ret = luaoc.callStaticMethod(iosClassName, methodName)
		if ok then
			ret.app_build = ret.app_build or "1"
			ret.app_version = ret.app_version or "1.0"
			print("app_build = " ..ret.app_build)
			print("app_version = " ..ret.app_version)
			return ret
		end
	elseif cc.PLATFORM_OS_ANDROID == targetPlatform then
		local args = {}
		local sig = "()Ljava/lang/String;"
		local ok, ret = luaj.callStaticMethod(javaClassName, methodName, args, sig)
		if ok then
			print("getAppInfo:"..ret)
			ret = tostring(ret)
			print("getAppInfo:"..ret)
			local data = loadstring("return "..ret)
			ret = data()
			print("app_build = " ..ret.app_build)
			print("app_version = " ..ret.app_version)
			return ret
		end
	else 
		return {app_version = 1.0, app_build = 1}
	end
end

function bridge.playPhoneShock()
	local methodName = "playPhoneShock" 
	if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) then
		local ok, ret = luaoc.callStaticMethod(iosClassName, methodName)
		if not ok then
			print("------------IOS shock fail")
		end 
	elseif cc.PLATFORM_OS_ANDROID == targetPlatform then
		local args = {}
		local sig = "()V"
		local ok, ret = luaj.callStaticMethod(className, methodName, args, sig)
		if not ok then
			print("------------Android shock fail")
		end 
	else
		print("------------win32 shock")
	end
end

function bridge.isWeChatInstalled()
	local methodName = "isWeChatInstalled"
	print(methodName)
	local sig = "()Z"
	if cc.PLATFORM_OS_ANDROID == targetPlatform then
		local args = {}
		local ok, ret = luaj.callStaticMethod(javaClassName, methodName, args, sig)
		if not ok then
			print("------------Android isWeChatInstalled fail")
		else
			return ret
		end
	elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) then
		local args = {}
		local ok, ret = luaoc.callStaticMethod(iosClassName, methodName)
		if not ok then
			print("------------IOS isWeChatInstalled fail")
		else
			return ret
		end
	end
end

function bridge.isWeChatAPISupported()
	local methodName = "isTimeLineSupported"
	print(methodName)
	local sig = "()Z"
	if cc.PLATFORM_OS_ANDROID == targetPlatform then
		local args = {}
		local ok, ret = luaj.callStaticMethod(javaClassName, methodName, args, sig)
		if not ok then
			print("------------Android isWeChatAPISupported fail")
		else
			return ret
		end
	elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) then
		return true
	end
end


local function callBackShareToWeChat(result)
	if cc.PLATFORM_OS_ANDROID == targetPlatform then
		print("callBackShareToWeChat, string from JAVA:"..result)
		local data = loadstring("return "..result)
		data = data()
		print("type="..data.type..",result="..data.result)
		display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "SHARE_TO_WECHAT_RESULT", data = data })
	elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) then
		local data = result
		print("type="..data.type..",result="..data.result)
		display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "SHARE_TO_WECHAT_RESULT", data = data })
	end
end

function bridge.shareToWeChat(scene, strTitle, strContent, strUrl)
	local methodName = "shareToWeChat"
	print(methodName)
	local sig = "(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V"
	if cc.PLATFORM_OS_ANDROID == targetPlatform then
		local args = {scene, strTitle, strContent, strUrl, callBackShareToWeChat}
		local ok, ret = luaj.callStaticMethod(javaClassName, methodName, args, sig)
		if not ok then
			print("------------Android shareToWeChat fail")
		end
	elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) then
		local args = {}
		args.scene = scene
		args.title = strTitle
		args.content = strContent
		args.url = strUrl
		args.imagepath = "Icon-29.png"
		args.listener = callBackShareToWeChat
		local ok, ret = luaoc.callStaticMethod(iosClassName, methodName, args)
		if not ok then
			print("------------IOS shareToWeChat fail")
		end
	end
end

local function callBackPay(result)
	if cc.PLATFORM_OS_ANDROID == targetPlatform then
		print("callBackPay, string from JAVA:"..result)
		local data = loadstring("return "..result)
		data = data()
		print("type="..data.type..",result="..data.result)
		display:getRunningScene().root.eventProtocol:dispatchEvent({ name = "PAY_RESULT", data = data })
	elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) then
		print("callBackPay, result:"..result.userId..result.transActionId..result.receiptData)
		app.shopLogic:reqIOSRecharge(result.userId, result.transActionId, result.receiptData)
	end
end

function bridge.AliPay(strOrderInfo)
	local methodName = "AliPay"
	if cc.PLATFORM_OS_ANDROID == targetPlatform then
		local args = {strOrderInfo, callBackPay}
		local ok, ret = luaj.callStaticMethod(javaClassName, methodName, args)
		if not ok then
			print("------------Android AliPay fail")
		end
	end
end

function bridge.UPPay(strTn, strDebug)
	local methodName = "UPPay"
	if cc.PLATFORM_OS_ANDROID == targetPlatform then
		local args = {strTn, strDebug, callBackPay}
		local ok, ret = luaj.callStaticMethod(javaClassName, methodName, args)
		if not ok then
			print("------------Android UPPay fail")
		end
	end
end

function bridge.WXPay(strOrderInfo)
	local methodName = "WXPay"
	if cc.PLATFORM_OS_ANDROID == targetPlatform then
		local args = {strOrderInfo, callBackPay}
		local ok, ret = luaj.callStaticMethod(javaClassName, methodName, args)
		if not ok then
			print("------------Android WXPay fail")
		end
	end
end

function bridge.IOSPay(productId)
	local methodName = "IOSPay"
	if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) then
		local args = {}
		args.productId = productId
		args.listener = callBackPay
		local ok, ret = luaoc.callStaticMethod(iosClassName, methodName, args)
		if not ok then
			print("------------IOS pay fail")
		end
	end
end

function bridge.setIOSPayCallBack()
	local methodName = "setCallBackPay"
	if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) then
		local args = {}
		args.listener = callBackPay
		local ok, ret = luaoc.callStaticMethod(iosClassName, methodName, args)
		if not ok then
			print("------------IsetCallBackPay fail")
		end
	end
end

function bridge.setCurrUserId(userId)
	if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) then
		bridge.setIOSPayCallBack()
		local methodName = "iosSetCurrUserId"
		local args = {}
		args.userId = userId
		print("userId:"..userId)
		local ok, ret = luaoc.callStaticMethod(iosClassName, methodName, args)
		if not ok then
			print("------------IOS set userId failed")
		end
	end
end

function bridge.onIOSRechargeResult(result)
	local methodName = "onIOSRechargeResult"
	if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) then
		local args = result
		args.currUserId = userId
		local ok, ret = luaoc.callStaticMethod(iosClassName, methodName, args)
		if not ok then
			print("------------IOS set userId failed")
		end
	end
end

function bridge.getExternalStorageDirectory()
	local methodName = "getExternalStorageDirectory"
	print(methodName)
	if cc.PLATFORM_OS_ANDROID == targetPlatform then
		local sign = "()Ljava/lang/String;"
		local args = {}
		local ok, ret = luaj.callStaticMethod(javaClassName, methodName, args, sign)
		if not ok then
			print("------------Android getExternalStorageDirectory fail")
		end
		return ret
	end
end

function bridge.callPhone(strPhone)
	local methodName = "callPhone"
	print(methodName)
	if cc.PLATFORM_OS_ANDROID == targetPlatform then
		local sign = "(Ljava/lang/String;)V"
		local args = {strPhone}
		local ok, ret = luaj.callStaticMethod(javaClassName, methodName, args, sign)
		if not ok then
			print("------------Android callPhone fail")
		end
		return ret
	elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) then
		local args = {["strPhone"] = strPhone}
		local ok, ret = luaoc.callStaticMethod(iosClassName, methodName, args)
		return ret
	end
end

function bridge.openAppStore(url)
	local methodName = "openAppStore"
	if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) then
		local args = {}
		print(methodName.." "..url)
		args.url = url
		local ok, ret = luaoc.callStaticMethod(iosClassName, methodName, args)
		if not ok then
			print("------------IOS open app store failed")
		end
	end
end

function bridge.updateApplication()
	if cc.PLATFORM_OS_ANDROID == targetPlatform then
		local methodName = "doNewVersionUpdate"
		local sign = "()Ljava/lang/String;"
		local args = {}
		local ok, ret = luaj.callStaticMethod(javaClassName, methodName, args, sign)
		if not ok then
			print("------------Android doNewVersionUpdate fail")
		end
		return ret
	elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) then
		local strUrl = "itms-apps://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftwareUpdate?id="..clientConfig.appStoreId.."&mt=8"
		bridge.openAppStore(strUrl)
	end
end

return bridge