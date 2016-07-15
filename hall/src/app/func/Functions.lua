--
-- Author: ChenShao
-- Date: 2015-10-12 15:11:18
--
function banBtn(btn)
	btn:setTouchEnabled(false)
	--btn:setBright(false)
end

function pickBtn(btn)
	btn:setTouchEnabled(true)
	--btn:setBright(true)
end


require "framework.utils.bit"
function evt_bor(tbl)
	local p = 0
	for _, v in pairs(tbl) do
		p = bit.bor(v, p)
	end
	return p
end

function evt_band(a, b)
	return bit.band(a, b)
end

function g_addLayBulletin(parent)
	--跑马灯的初始化已经优化，不需要逐个场景添加
	--[[
	if app.layBulletin == nil then
		local layBulletin = require("hall.view.BulletinLayer").new()
		layBulletin:init(parent)
		layBulletin.root:setName("layBulletin")
		app.layBulletin = layBulletin
	end
	--]]
end

function g_isMahj(gameName)
	local flag = false

	local s, e = string.find(gameName, "mj")
	
	if s then
		print(gameName .."is mahj")
		flag = true
	end

	print(gameName .."is not mahj")
	return flag
end

function g_pauseMsgHandlerForAWhile(time)
	--暂停处理服务器消息
	if time == nil then 
		time = 1
	end
	
	local scheduler = require("framework.scheduler")
	if app.msgPauseSchedualer ~= nil then
		scheduler.unscheduleGlobal(app.msgPauseSchedualer)
		app.msgPauseSchedualer = nil
		cc.dataMgr.msgHandlerPaused = false
	end

	if time <= 0 then return end

	cc.dataMgr.msgHandlerPaused = true
	local function enablehandle()
		cc.dataMgr.msgHandlerPaused = false
	end
	app.msgPauseSchedualer = scheduler.performWithDelayGlobal(enablehandle, time)
end