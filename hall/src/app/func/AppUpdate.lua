local AppUpdate = {}
local bridge = require("app.func.Bridge")
local httpUtils = require("app.func.HttpUtils") 
local json = require("framework.json")
local msgBox = require("app.func.MessageBox")
--local holdOn = require("app.func.HoldOnLayer")

function AppUpdate.checkUpdate(onCheckResult)
	local url = ""
	---[[
	if g_Platform_Android then
		url = urls.androidUpdateCheck
	elseif g_Platform_Ios then
		url = urls.iosUpdateCheck
	else
		onCheckResult(false, false)
	end
	--]]

	--url = urls.androidUpdateCheck
	
	local currVersion = tonumber(bridge.getAppInfo().app_version)
	local function onVersionInfoReceived(ret, response)
		if ret then
			print("version info is received:"..response)
			--holdOn.hide()
			local versionInfo = json.decode(response) or {version = 0, minimum_version = 0}
			--dump(versionInfo)
			local newVersion = tonumber(versionInfo.version)
			local minVersion = tonumber(versionInfo.minimum_version)
			print("currVersion:"..currVersion.." newVersion:"..newVersion.." minVersion:"..minVersion)
			local needUpdate = currVersion < minVersion
			local canUpdate = currVersion < newVersion
			onCheckResult(canUpdate, needUpdate)
		else
			print("checkupdate failed")
			local funcOk = function()
				httpUtils.reqHttp(url, onVersionInfoReceived)
			end
			local funcCancel = function()
				cc.Director:getInstance():endToLua()
			end
			msgBox.showMsgBoxTwoBtn("检查更新失败，再试一次？", funcOk, funcCancel, "应用更新", "重试", "不更新", funcCancel)
		end
	end
	--holdOn.show("正在检查更新", 2)
	httpUtils.reqHttp(url, onVersionInfoReceived)

end

function AppUpdate.doUpdate()
	print("downloadApp")
	--下载应用并更新
	local bridge = require("app.func.Bridge")
	bridge.updateApplication()
end

return AppUpdate