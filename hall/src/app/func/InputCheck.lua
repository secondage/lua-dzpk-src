--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/9/14
-- Time: 11:30
-- To change this template use File | Settings | File Templates.
--

local InputCheck = class("InputCheck")

local function isNumberOnly(str)
    for i = 1, string.len(str) do
        local ch = string.byte(str, i)
        if ch < 48 or ch > 57 then
            return false
        end
    end
    return true
end

local function isLetterOnly(str)
    local count = 0
    for i = 1, string.len(str) do
        local ch = string.byte(str, i)
        if (ch >= 65 and ch <= 90) or (ch >= 97 and ch <= 122) then
            count = count + 1
        end
    end
    if count == string.len(str) then
        return true
    end

    return false
end

local function isSingleType(str)
    if isLetterOnly(str) or isNumberOnly(str) then
        return true
    end

    return false
end

function InputCheck.checkIsSingleType(str)
    return isSingleType(str)
end

function InputCheck.checkIsNumberOnly(str)
    return isNumberOnly(str)
end

function InputCheck.checkPsw(str)
    if string.len(str) == 0 then
        --为空
        return 1
    elseif string.len(str) < 6 or string.len(str) > 16 then
        --长度错误
        return 2
    elseif isSingleType(str) then
        --纯数字或字母
        return 3
    else
        --正确
        return 0
    end
end

function InputCheck.checkSePsw(str)
    if string.len(str) == 0 then
        --为空
        return 1
    elseif string.len(str) < 8 or string.len(str) > 16 then
        --长度错误
        return 2
    elseif isSingleType(str) then
        --纯数字或字母
        return 3
    else
        --正确
        return 0
    end
end

function InputCheck.checkNickName(str)
    if string.len(str) == 0 then
        --昵称为空
        return 1
    elseif string.len(str) < 8 or string.len(str) > 16 then
        --昵称长度错误
        return 2
    else
        --正确
        return 0
    end
end

function InputCheck.checkCardId(str)

    local function isBirthDayRight(str)
        local function getDay(year, month)
            local dayOfFeb = 28
            if tonumber(year) % 4 == 0 and tonumber(year) % 100 ~= 0
                    or tonumber(year) % 400 == 0 then
                dayOfFeb = 29
            end
            local day = {
                31, dayOfFeb, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
            }
            return day[tonumber(month)]
        end
        local length = string.len(str)
        local year, month, day
        if length == 18 then
            year = string.sub(str, 7, 10)
            month = string.sub(str, 11, 12)
            day = string.sub(str, 13, 14)
        else
            year = "19"..string.sub(str, 7, 8)
            month = string.sub(str, 9, 10)
            day = string.sub(str, 11, 12)
        end
        print("year,month,day:"..year..month..day)
        if tonumber(year) == 0 or tonumber(month) == 0 or tonumber(day) == 0 then
            return false
        elseif getDay(year, month) > tonumber(day) then
            return true
        else
            return false
        end
    end

    local function isCheckDigitRight(str)
        local no = {7,9,10,5,8,4,2,1,6,3,7,9,10,5,8,4,2}
        local id = {'1','0','X','9','8','7','6','5','4','3','2' }
        local wi, sum = 0, 0
        for i = 1, string.len(str) - 1 do
            local ch = string.byte(str, i) - 48
            wi = ch * no[i]
            sum = sum + wi
        end

        local chLast = string.byte(str, -1)
        if chLast < 48 or chLast > 57 then
            if chLast ~= 88 or chLast ~= 120 then
                print("last character is not X 1")
                return false
            end
        end
        wi = sum % 11 + 1
        print("sum:"..sum..", wi:"..wi)
        if chLast == 88 or chLast == 120 then
            if id[wi] ~= 'x' or id[wi] ~= 'X' then
                print("last character is not X 2")
                return false
            end
        else
            if id[wi] ~= string.char(chLast) then
                print("last character should be "..id[wi]..", not "..string.char(chLast))
                return false
            end
        end
        return true
    end

    if string.len(str) == 0 then
        --为空
        return 1
    elseif string.len(str) ~= 15 and string.len(str) ~= 18 then
        --长度错误
        return 2
    elseif not isNumberOnly(string.sub(1, 17)) then
        --有错误的字符
        return 3
    elseif not isBirthDayRight(str) then
        --生日日期有误
        return 4
    elseif not isCheckDigitRight(str) then
        --校验位错误
        return 5
    else
        --正确
        return 0
    end
end

function InputCheck.checkPhoneNum(str)
    print("checkPhoneNum:"..str)
    if string.len(str) < 11 then
        print("length error")
        return false
    end

    local ch1 = string.byte(str, 1) - 48
    local ch2 = string.byte(str, 2) - 48
    if ch1 ~= 1 or (ch2 ~= 3 and ch2 ~= 4 and ch2 ~= 5 and ch2 ~= 7 and ch2 ~= 8) then
        print("checkPhoneNum failed")
        print(ch1.." "..ch2)
        return false
    else
        return true
    end
end

function InputCheck.contaiIllegalChar(str)
    for i = 1, string.len(str) do
        local ch = string.byte(str, i)
        if ch < 48 or (ch > 57 and ch < 65) or (ch > 90 and ch < 97) or (ch > 122 and ch < 128) then
            print("contaiIllegalChar"..ch)
            return true
        end
    end
    return false
end

return InputCheck

