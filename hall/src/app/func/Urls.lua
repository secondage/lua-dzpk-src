--
-- Author: ChenShao
-- Date: 2015-10-09 16:09:37
--
urls = {}


local urlHeader
if clientConfig.platform == "INNER" then
	urlHeader = "http://192.168.1.100/"
	urlHeader_ = "http://192.168.1.69/"
elseif clientConfig.platform == "FL_GAME_DEBUG" then
	urlHeader = "http://125.32.114.18/"
	urlHeader_ = "http://125.32.113.103/" --http 直接读取文件配置
else
	urlHeader = "http://www.flgame.net/"
	urlHeader_ = "http://125.32.113.103/"
end

urls.drawStrUrl_small = urlHeader .."Service/SmallDraw/Config?userId="
urls.drawRunUrl_small = urlHeader .."Service/SmallDraw/Run?userId="
urls.drawMyAwardUrl_small = urlHeader .."Service/SmallDraw/MyLogs?userid="

urls.drawStrUrl = urlHeader .."Service/Draw/Config?userId="
urls.drawRunUrl = urlHeader .."Service/Draw/Run?userId="
urls.drawMyAwardUrl = urlHeader .."Service/Draw/MyLogs?userid="

urls.confirmAddressUrl = urlHeader .."Service/Draw/ConfirmAddress"
urls.confirmAddressUrl_Small = urlHeader .."Service/SmallDraw/ConfirmAddress"

urls.updateAddressUrl =  urlHeader .."Service/Draw/UpdateAddress"
urls.updateAddressUrl_Small = urlHeader .."Service/Draw/UpdateAddress"

--urls.updateAddressUrl =  urlHeader .."Service/Common/UserAddress"
--urls.updateAddressUrl_Small = urlHeader .."Service/Common/UserAddress"

urls.exchangeReqGoodsList = urlHeader .."Service/Exchange/Awards?"
urls.exchangeReqGoodsDetail = urlHeader .."Service/Exchange/Award?awardId="
urls.reqExchangeAddressUrl = urlHeader .."Service/Common/UserAddress?userId="
urls.reqExchangeRecord = urlHeader .."Service/Exchange/Mylogs?userId="
urls.reqExchageGoods = urlHeader .."Service/Exchange/DoExchange"

urls.taskJsonVerion = urlHeader_ .."2d_web_ini/"
urls.taskJson = urlHeader_ .."2d_web_ini/"
urls.addgameslist = urlHeader_ .."2d_web_ini/addgames.json"
urls.addgameslistVersion = urlHeader_ .."2d_web_ini/addgames_version"
urls.minigameHot = urlHeader_ .."2d_web_ini/"
urls.minigameDownloadurl = urlHeader_ .."2d_web_ini/"
urls.preGamesList = urlHeader_ .."2d_web_ini/pre_games.json"
urls.accessAppleStore = urlHeader_ .."2d_web_ini/access_apple_store.json"
urls.accessAndroidStore = urlHeader_ .."2d_web_ini/access_android_store.json"
urls.iosUpdateCheck = urlHeader_ .."2d_web_ini/ios_version.json"
urls.androidUpdateCheck = urlHeader_ .."2d_web_ini/android_version.json"

urls.channelUrl = urlHeader .."Service/App/Activate?"

urls.publicNoticeUrl = urlHeader .."Service/MG/Notice"

urls.updateZipDownloadurl = "" --http获取
urls.fullZipDownloadurl = "" --http获取