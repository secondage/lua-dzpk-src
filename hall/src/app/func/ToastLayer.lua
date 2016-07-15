--
-- Author: ChenShao
-- Date: 2015-08-18 16:07:11
--
local toast = class("toast")

local toastLayers = {}


function toast.show(content, parent)
	parent = parent or display:getRunningScene()

	----------------自动换行
	local mutiplyContent = UTF82Mutiple(content)
	local subIndex = 26
	print("string.len(mutiplyContent) = " ..string.len(mutiplyContent))
	if string.len(mutiplyContent) >= subIndex then
		local k = 1
		for i = 1, string.len(mutiplyContent) do
			local ch_0 = string.byte(mutiplyContent, k)
			if ch_0 == nil then
				break
			end

			if ch_0 >= 0 and ch_0 <= 127 then
				k = k + 1
			else
				k = k + 2
			end

			print("k = " ..k)
			if k == subIndex or k == subIndex + 1 then
				local preTxt = string.sub(mutiplyContent, 1, k - 1)
				local suffTxt = string.sub(mutiplyContent, k, -1)
				print("suffTxt = " ..suffTxt)
				if string.len(suffTxt) == 0 then
					mutiplyContent = preTxt
				else
					mutiplyContent = preTxt .."\n" ..suffTxt
				end
				break
			end
		end
	end

    content = Mutiple2UTF8(mutiplyContent)
    print("content = " ..content)
    --------------------

	local toastBG = display.newSprite("toastbg.png"):pos(display.cx, display.cy):addTo(parent, 100)
	toastBG:setCascadeOpacityEnabled(true)
	local label = cc.Label:create():pos(toastBG:getContentSize().width / 2,  toastBG:getContentSize().height / 2)
								   :addTo(toastBG)
	label:setString(content)
	label:setSystemFontSize(20)
	label:setColor(cc.c3b(249, 242, 208))
	label:setAlignment(1)			--居中

	toastBG:setOpacity(0)
	toastLayers[#toastLayers + 1] = toastBG
	local action1 = cc.FadeIn:create(0.3)
	local action2 = cc.MoveBy:create(0.2, {x = 0, y = toastBG:getContentSize().height})
	local action3 = cc.CallFunc:create(function()
		toastBG:hide()  ------ps：待优化 
		--toastBG:removeSelf()
		--toastLayers[#toastLayers] = nil
	end)
	local delay = cc.DelayTime:create(1)
	toastBG:runAction(transition.sequence({action1, delay, action3}))
	

	for i = 1, #toastLayers - 1 do
		print("<----#toastLayers = " ..#toastLayers)
		local toastLayer = toastLayers[i]
		if toastLayer then
			toastLayer:runAction(transition.sequence({action2:clone()}))
		end
	end

	return 1.5
end

function toast.clearToastLayers()
	toastLayers = {}
end

return toast