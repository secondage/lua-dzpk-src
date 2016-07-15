--
-- Author: ChenShao
-- Date: 2015-09-16 15:21:23
--
local httpUtils = {}
local network = require("framework.network")

function httpUtils.reqHttp(strUrl, callBack, isPost)
	
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = 4 --貌似无用

    local reqType = "GET"
    if isPost then
        reqType = "POST"
    end
	xhr:open(reqType, strUrl)

	local function onResult()
        if xhr.readyState == 4 and xhr.status == 200 then
            callBack(true, xhr.response)
        else
            callBack(false)
        end
    end
    xhr:registerScriptHandler(onResult)
    xhr.timeout = 10
    xhr:send()

    return xhr
end

return httpUtils