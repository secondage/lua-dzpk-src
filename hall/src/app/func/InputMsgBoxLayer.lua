--
-- Author: ChenShao
-- Date: 2015-12-19 11:38:37
--
local inputMsgBox = {}

local popLayerAction = require("app.func.PopLayerAction")

function inputMsgBox.show(args)

	local text = args.text or ""
	local holdText = args.holdText or ""
	local funcOK = args.funcOK
	local parent = args.parent or display:getRunningScene()

	local lay = cc.CSLoader:createNode("Layers/InputMsgBoxLayer.csb")
	lay:setAnchorPoint(cc.p(0.5, 0.5))
	lay:ignoreAnchorPointForPosition(false)
	lay:setPosition(display.cx, display.cy)
	parent:addChild(lay)



	local imgBg = lay:getChildByName("Image_bg")

	popLayerAction.show(imgBg)

	local txtTitle = imgBg:getChildByName("Text_title")
	txtTitle:setString(text)

	local inputTmp = imgBg:getChildByName("Image_input_bg"):hide()
	local input = app.EditBoxFactory:createEditBoxByImage(inputTmp, holdText)

	local btnOK = imgBg:getChildByName("Button_OK")
	btnOK:setPressedActionEnabled(true)
	btnOK:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			local inputText = input:getString()
			lay:removeSelf()
			if funcOK then	
				funcOK(inputText)
			end
		end
	end)

	local btnClose = imgBg:getChildByName("Button_close")
	btnClose:setPressedActionEnabled(true)
	btnClose:addTouchEventListener(function(obj, type)
		if type == 2 then
			app.audioPlayer:playClickBtnEffect()
			lay:removeSelf()
		end
	end)

	lay:onNodeEvent("exit", function()
		print("inputMsgBox exit")
	end)
end

return inputMsgBox