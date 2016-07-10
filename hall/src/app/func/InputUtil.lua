--
-- Author: ChenShao
-- Date: 2015-08-19 10:01:24
--
local inputUtil = {}

 --- 大于127说明含有中文字符

--
-- 禁止中字输入
--
function inputUtil.ban_ZH_input(str)
    local newStr = ""
    for i = 1, string.len(str) do
        local ch = string.byte(str, i)
        if ch > 0 and ch <= 127 then
            newStr = newStr ..string.sub(str, i, i)
        end
    end
    return newStr
end

--
--之允许数字输入
--
function inputUtil.pick_Number_input(str)
    local newStr = ""
    for i = 1, string.len(str) do
        local ch = string.byte(str, i)
        if ch >= 48 and ch <= 57 then
            newStr = newStr ..string.sub(str, i, i)
        end
    end
    return newStr
end

---
--- 限制字符数 返回string  中文字符2个 英文字符1个
--- str 源字符串 subCount 所需字符数
---

function inputUtil.pick_Input_Counts(str, subCount)
   local mutiplyContent = UTF82Mutiple(str)
    local subIndex = subCount
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
                mutiplyContent = string.sub(mutiplyContent, 1, k - 1)
                break
            end
        end
    end

    return Mutiple2UTF8(mutiplyContent)
end

---返回限制长度的字符串
--- str 原字符串
--- length 所需长度(包含尾部填充字符)
--- strReplace 尾部填充字符串
function inputUtil.getReducedString(str, length, strReplace)
    local len = length
    if strReplace ~= nil then
        len = len + string.len(strReplace)
    end
    local mutiplyContent = UTF82Mutiple(str)
    if string.len(mutiplyContent) <= len then
        return str
    else
        return inputUtil.pick_Input_Counts(str, length)..strReplace
    end
end

return inputUtil