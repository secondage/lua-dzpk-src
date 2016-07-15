--
-- Author: ChenShao
-- Date: 2015-10-10 09:30:42
--
app.EditBoxFactory = {}


function app.EditBoxFactory:createEditBoxByImage(image, strHolder, sp9editboxbg, height)
	sp9editboxbg = sp9editboxbg or "editboxbg1.png"
	height = height or image:getContentSize().height
	local editbox = ccui.EditBox:create(cc.size(image:getContentSize().width, height), sp9editboxbg)
	editbox:addTo(image:getParent(), image:getLocalZOrder())
	editbox:setPosition(image:getPosition())
	editbox:setPlaceHolder(strHolder)
	editbox:setFontColor(cc.c4b(0, 0, 0, 255))
	return editbox
end