--
-- Author: ChenShao
-- Date: 2015-09-16 13:07:13
--
local DownLoadLayerCtrller = class("DownLoadLayer")

function DownLoadLayerCtrller:ctor()

end

function DownLoadLayerCtrller:startDownload(gamename, onResult, strZipUrl)

    local pathToSave = cc.FileUtils:getInstance():getWritablePath() .."/update"
   
   if not cc.FileUtils:getInstance():isDirectoryExist(pathToSave) then
        cc.FileUtils:getInstance():createDirectory(pathToSave)
   end

    local layLoading = self.layDownload:getChildByName("Panel_loading")
    local bar = layLoading:getChildByName("LoadingBar_loading")
    bar:setPercent(0)
    local txtProgress = layLoading:getChildByName("Text_progress")
    txtProgress:setString("")

	local function onError(errorCode)
        print("errorCode = " ..errorCode)
        if errorCode == 2 then    
            print("---no new version")
            app.isDownloading = false
            onResult(1)
        elseif errorCode == 1 then
            print("---network error")
            app.isDownloading = false
            onResult(2)       
        elseif errorCode == 3 then
            print("---file error")
            app.isDownloading = false
            onResult(4)
        elseif errorCode == 4 then
            onResult(5)
            bar:setPercent(100)
            txtProgress:setString("Decompress...")
        elseif errorCode == 5 then --服务器端未找到该游戏  “正在开发中，敬请期待”
            app.isDownloading = false
            onResult(6)
        end
    end
 
    local startDownload = true
    local function onProgress( percent )
        if percent <= 0 then percent = 0 end
    	bar:setPercent(percent)
        print("percent = " ..percent)
        local progress = string.format("%d%%", percent)
        txtProgress:setString(progress)

        if percent == 100 then
            txtProgress:setString("Decompress...")
        end

        if startDownload and percent >= 0 then
            app.isDownloading = true
            onResult(3) --开始下载
            startDownload = false
           
        end
    end

     local function onSuccess()
        print("downloading ok")
        app.isDownloading = false
        onResult(0)
    end

    local assetsManager = nil
    local function getAssetsManager()
        if nil == assetsManager then
   
            print("strZipUrl = " ..strZipUrl ..gamename ..".zip")
            assetsManager = cc.AssetsManager:new(strZipUrl ..gamename ..".zip",
                                           strZipUrl ..gamename .."_version",
                                           pathToSave, gamename)
            assetsManager:retain()
            assetsManager:setDelegate(onError, 2)
            assetsManager:setDelegate(onProgress, 0)
            assetsManager:setDelegate(onSuccess, 1)
            assetsManager:setConnectionTimeout(3)
        end

        return assetsManager
    end

     app.isDownloading = true
    getAssetsManager():update()
end


function DownLoadLayerCtrller:createLayer(layType)
    if layType then
        layType = 2
    else
        layType = ""
    end

    print("layType = " ..layType)
	self.layDownload = cc.CSLoader:createNode("Layers/DownLoadLayer" ..layType ..".csb")

	return self.layDownload
end

return DownLoadLayerCtrller