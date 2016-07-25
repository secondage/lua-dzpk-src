cc.FileUtils:getInstance():setPopupNotify(false)

g_writablePath = cc.FileUtils:getInstance():getWritablePath()

cc.FileUtils:getInstance():addSearchPath("src/apis")

cc.FileUtils:getInstance():addSearchPath("res/")
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("src/hall/res")
cc.FileUtils:getInstance():addSearchPath("src/hall/src")
cc.FileUtils:getInstance():addSearchPath("src/hall/res/projui")


cc.FileUtils:getInstance():addSearchPath(g_writablePath .."/update", true)
cc.FileUtils:getInstance():addSearchPath(g_writablePath .."/update/hall/res", true)
cc.FileUtils:getInstance():addSearchPath(g_writablePath .."/update/hall/src", true)
cc.FileUtils:getInstance():addSearchPath(g_writablePath .."/update/hall/res/projui", true)

require "config"
require "cocos.init"
 
g_Platform_Ios = false
g_Platform_Android = false
g_Platform_Win32 = false

local targetPlatform = cc.Application:getInstance():getTargetPlatform()
if cc.PLATFORM_OS_ANDROID == targetPlatform then
	g_Platform_Android = true
elseif (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) then 
	g_Platform_Ios = true
else
	g_Platform_Win32 = true
end

app = {} -- 存放自定义实例
app.isDownloading = false

--require("init")

function table.deepcopy(object)
	local lookup_table = {}
	local function _copy(object)
		if type(object) ~= "table" then
			return object
		elseif lookup_table[object] then
			return lookup_table[object]
		end  -- if
		local new_table = {}
		lookup_table[object] = new_table
		for index, value in pairs(object) do
			new_table[_copy(index)] = _copy(value)
		end  -- for
		return setmetatable(new_table, getmetatable(object))
	end  -- function _copy
	return _copy(object)
end

-- cclog
local cclog = function(...)
	print(string.format(...))
end

--for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
	local targetPlatform = cc.Application:getInstance():getTargetPlatform()
	if targetPlatform == cc.PLATFORM_OS_ANDROID then
		local bridge = require("app.func.Bridge")
		--local pathRoot = bridge.getExternalStorageDirectory()
		if pathRoot ~= nil then
			cclog("android storagePath:"..pathRoot)
			local file = io.open(pathRoot.."/hallLog.txt", "a+")
			file:write("\n----------------------------------------")
			local time = os.date("%Y-%m-%d %H:%M:%S")
			file:write("\n"..time.."\n")
			file:write("LUA ERROR: " .. tostring(msg) .. "\n")
			file:write(debug.traceback())
			file:write("\n----------------------------------------")
			file:close()
		else
			cclog("getExternalStorageDirectory failed")
		end
	elseif targetPlatform == cc.PLATFORM_OS_WINDOWS then
		local pathRoot = cc.FileUtils:getInstance():getWritablePath()
		print("pathRoot:"..pathRoot)
		local file = io.open(pathRoot.."/hallLog.txt", "a+")
		file:write("\n----------------------------------------")
		local time = os.date("%Y-%m-%d %H:%M:%S")
		file:write("\n"..time.."\n")
		file:write("LUA ERROR: " .. tostring(msg) .. "\n")
		file:write(debug.traceback())
		file:write("\n----------------------------------------")
		file:close()
	end
	cclog("----------------------------------------")
	cclog("LUA ERROR: " .. tostring(msg) .. "\n")
	cclog(debug.traceback())
	cclog("----------------------------------------")
	--cc.msgHandler:stopReceiveMsg()
	if targetPlatform == cc.PLATFORM_OS_WINDOWS or clientConfig.platform == "FL_GAME_DEBUG" then
		cc.Director:getInstance():endToLua()
	end
	return msg
end

local function main()
	require("app.MyApp"):create({viewsRoot = "hall/src/app/views"}):enterScene("UpdateScene")
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
	error(msg)
end
