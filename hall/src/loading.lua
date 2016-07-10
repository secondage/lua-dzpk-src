local loadingLayer = class("LoadingLayer", function()
	return cc.Scene:create()
end)

function loadingLayer:create()
	local scene = loadingLayer.new()
	scene:addChild(scene:createMainUI())
	scene:retain()
	scene:setVisible(false)
	return scene
end

function loadingLayer:ctor()
end


function loadingLayer:createMainUI()
	local layout = ccs.GUIReader:getInstance():widgetFromJsonFile("hall/loading.ExportJson")
	return layout
end

cc.__loadingLayer = nil
cc.__loadingShown = false
function cc.showLoading(text, delayTime)
	app.holdOn.show(text, delayTime)
end

function cc.hideLoading()
	app.holdOn.hide()
end
