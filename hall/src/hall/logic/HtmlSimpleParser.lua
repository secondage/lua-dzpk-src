--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/10/13
-- Time: 10:04
-- To change this template use File | Settings | File Templates.
--

local HtmlSimpleParser = class("HtmlSimpleParser")

function HtmlSimpleParser.parsHtmlString(strHtml)
    local elementList = {}
    local function getOneElement(strElement)
        print("getOneElement:"..strElement)
        local element = {}
        element.attributes = {}
        element.content = ""
        local i = 1
        local length = string.len(strElement)
        while i <= length do
            local ch = string.sub(strElement, i, i)
            if ch == '\t' or ch == '\n' or ch == '\r' then
                i = i + 1
                --do noting
            else
                if ch == '<' then
                    strAtr = ""
                    strVal = ""
                    i = i + 1
                    while i <= length and string.sub(strElement, i, i) ~= ' ' and string.sub(strElement, i, i) ~= '>' do
                        strAtr = strAtr.. string.sub(strElement, i, i)
                        i = i + 1
                    end
                    if string.sub(strElement, i, i) == '>' then
                        element[strAtr] = ""
                        print("key:"..strAtr.."  value:")
                        i = i + 1
                    else
                        i = i + 1
                        while i <= length and string.sub(strElement, i, i) ~= '>' do
                            strVal = strVal..string.sub(strElement, i, i)
                            i = i + 1
                        end
                        print("key:"..strAtr.."  value:"..strVal)
                        element[strAtr] = strVal
                        i = i + 1
                    end
                else
                    local strText = ""
                    while i <= length and string.sub(strElement, i, i) ~= '<' do
                        strText = strText..string.sub(strElement, i, i)
                        i = i + 1
                    end
                    --print("content:"..strText)
                    element.content = strText
                    elementList[#elementList + 1] = element
                    return
                end
            end
        end
    end
    local i = 1
    local length = string.len(strHtml)
    while i <= length do
        local ch = string.sub(strHtml, i, i)
        if ch == '\t' or ch == '\n' or ch == '\r' then
            i = i + 1
            --do noting
        else
            if ch == '<' then
                local nBegin = i
                i = i + 1
                local count = 0
                local strAtr = ""
                while i <= length and string.sub(strHtml, i, i) ~= ' ' and string.sub(strHtml, i, i) ~= '>' do
                    strAtr = strAtr..string.sub(strHtml, i, i)
                    i = i + 1
                    count = count + 1
                end
                local strEnd = "</"..strAtr..">"
                while i + string.len(strEnd) - 1 <= length do
                    local strTemp = string.sub(strHtml, i, i + string.len(strEnd) - 1)
                    if strTemp == strEnd then
                        count = count + string.len(strEnd)
                        getOneElement(string.sub(strHtml, nBegin, nBegin + count))
                        i = i + string.len(strEnd)
                        break
                    else
                        i = i + 1
                        count = count + 1
                    end
                end
            else
                local nBegin = i
                local count = 0
                while i <= length do
                    --print("check char:"..string.sub(strHtml, i, i))
                    if string.sub(strHtml, i, i) == '<' then
                        getOneElement(string.sub(strHtml, nBegin, nBegin + count - 1))
                        break
                    end
                    i = i + 1
                    count = count + 1
                    if i == length + 1 then
                        getOneElement(string.sub(strHtml, nBegin, length))
                    end
                end
            end
        end
    end
    return elementList
end

return HtmlSimpleParser

