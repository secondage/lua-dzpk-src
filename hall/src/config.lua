
-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 1

-- use framework, will disable all deprecated API, false - use legacy API
CC_USE_FRAMEWORK = true

-- show FPS on screen
CC_SHOW_FPS = false

-- disable create unexpected global variable
CC_DISABLE_GLOBAL = false


-- for module display
CC_DESIGN_RESOLUTION = {
    width = 1136,
    height = 640,
    autoscale = "SHOW_ALL",
    callback = function(framesize)
        local ratio = framesize.width / framesize.height
        if ratio <= 1.34 then
            -- iPad 768*1024(1536*2048) is 4:3 screen
            return {autoscale = "SHOW_ALL"}
        end
    end
}

clientConfig = {}
--clientConfig.platform = "FL_GAME_DEBUG"
clientConfig.platform = "INNER"
--clientConfig.platform = "DEVELOP_DEBUG"
--clientConfig.platform = "FL_GAME_RELEASE"

if clientConfig.platform == "FL_GAME_DEBUG" then
    clientConfig.serverAddress = "125.32.114.18"
    clientConfig.serverPort = 26661
    clientConfig.retryConnectWhenFailure = true
    clientConfig.homePage = "http://125.32.114.18"
elseif clientConfig.platform == "FL_GAME_RELEASE" then
    clientConfig.serverAddress = "125.32.113.107"
    clientConfig.serverPort = 26761
    clientConfig.retryConnectWhenFailure = true
    clientConfig.homePage = "http://www.flgame.net"
elseif clientConfig.platform == "DEVELOP_DEBUG" then
    clientConfig.serverAddress = "192.168.1.43"
    clientConfig.serverPort = 6310
    clientConfig.retryConnectWhenFailure = true
    clientConfig.homePage = "http://192.168.1.100"
else
    clientConfig.serverAddress = "192.168.11.103"
    clientConfig.serverPort = 6310
    clientConfig.retryConnectWhenFailure = true
    clientConfig.homePage = "http://192.168.1.100"
end

clientConfig.appStoreId = "1067164777"
clientConfig.regPresent = true          --注册礼包