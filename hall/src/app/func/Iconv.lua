--
-- Author: ChenShao
-- Date: 2015-10-13 15:31:36
--
local iconv = require "iconv"
local encoding = iconv.new("utf-8", "GB18030") --多字节 -->utf8  接受服务器带中文字字段
local decoding = iconv.new("GB18030", "utf-8") --utf8 -->多字节 发送到服务器 带中文字字段

function UTF82Mutiple(str)
	if str == "" then return str end
	return decoding:iconv(str)
end

function Mutiple2UTF8(str)
	if str == "" then return str end
	return encoding:iconv(str)
end