--
-- Author: ChenShao
-- Date: 2016-07-25 10:00:06
--
local UpdateScene = class("UpdateScene", cc.load("mvc").ViewBase)
UpdateScene.RESOURCE_FILENAME = "UpdateScene/UpdateScene.csb"

function UpdateScene:onCreate()
	self.resRoot = self:getResourceNode()

    local pathToSave = cc.FileUtils:getInstance():getWritablePath() .."/update"
    if not cc.FileUtils:getInstance():isDirectoryExist(pathToSave) then
        cc.FileUtils:getInstance():createDirectory(pathToSave)
    end

	local nodeUpdate = self.resRoot:getChildByName("Node_Update"):hide()

	local txtStatus = nodeUpdate:getChildByName("Text_update")
	local barPercent = nodeUpdate:getChildByName("Image_bar_bg"):getChildByName("LoadingBar_update")
    :setPercent(0)
	local txtPercent = nodeUpdate:getChildByName("Text_percent"):setString(0)

	local assetsManager = nil

	local function onError(errorCode)
        print("errorCode = " ..errorCode)
        if errorCode == 2 then    
            print("---no new version")

            require("app.MyApp"):create({viewsRoot = "hall/src/app/views"}):enterScene("LoadingScene")
        elseif errorCode == 1 then
            print("---network error")
            txtStatus:setString("Network Error!")
        elseif errorCode == 4 then

            barPercent:setPercent(100)
            txtPercent:setString("Decompress...")
            
        else
            txtPercent:setString("Error...")
        end
    end

    local isStart = false
    local function onProgress( percent )
        barPercent:setPercent(percent)
        txtPercent:setString(percent .."%")
        if not isStart then
            isStart = true
            nodeUpdate:show()
        end
    end

    local function onSuccess()
        print("downloading ok")
   		assetsManager:release()
        require("app.MyApp"):create({viewsRoot = "hall/src/app/views"}):enterScene("LoadingScene")
    end
 	
    local function getAssetsManager()
        if nil == assetsManager then
            
            assetsManager = cc.AssetsManager:new("http://121.42.61.41/update_dzpk/update.zip",
                                           "121.42.61.41/update_dzpk/version",
                                           pathToSave, "dzpk")
            assetsManager:retain()
            
            assetsManager:setDelegate(onSuccess, 1)
            assetsManager:setDelegate(onProgress, 0)
            assetsManager:setDelegate(onError, 2)
            assetsManager:setConnectionTimeout(3)
        end

        return assetsManager
    end

    getAssetsManager():update()
end


return UpdateScene