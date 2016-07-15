--
-- Author: ChenShao
-- Date: 2015-11-02 09:36:07
--
local GroupBox = class("GroupBox")

function GroupBox:ctor(args)
	assert(args, "args == nil")

	local checkBoxGroup = {}

	local function setSelected(obj)
		for _, checkBox in pairs(checkBoxGroup) do
			checkBox:setSelected(false)
			checkBox:setEnabled(true)
			checkBox.userdata:hide()
		end
		obj:setSelected(true)
		obj:setEnabled(false)
		obj.userdata:show()
	end


	for _, box in pairs(args) do
		checkBoxGroup[#checkBoxGroup + 1] = box.checkBox
		box.checkBox.userdata = box.node 
		box.checkBox:addEventListener(function(obj, type)
			box.callBack(obj, type)
			setSelected(obj)
		end)
	end

	
	setSelected(checkBoxGroup[1])
end

return GroupBox