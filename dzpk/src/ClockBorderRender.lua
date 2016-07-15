--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/12/9
-- Time: 14:35
-- To change this template use File | Settings | File Templates.
--

local ClockBorderRender = class("ClockBorderRender")
function ClockBorderRender:cotr()

end

function ClockBorderRender:drawNodeRoundRect(drawNode, rect, borderWidth, radius, color, fillColor)
    -- segments 表示圆角的精细度，值越大越精细
    local segments = 100
    local origin = cc.p(rect.x, rect.y)
    local destination = cc.p(rect.x + rect.width, rect.y - rect.height)
    local points = {}

    -- 算出1/4圆
    local coef = math.pi/2/segments
    local vertices = {}

    for i = 0, segments do
        local rads = (segments - i) * coef
        local x = radius * math.sin(rads)
        local y = radius * math.cos(rads)

        table.insert(vertices, cc.p(x, y))
    end

    local tagCenter = cc.p(0, 0)
    local minX = math.min(origin.x, destination.x)
    local maxX = math.max(origin.x, destination.x)
    local minY = math.min(origin.y, destination.y)
    local maxY = math.max(origin.y, destination.y)
    local dwPolygonPtMax = (segments + 1) * 4
    local pPolygonPtArr = {}

    -- 左上角
    tagCenter.x = minX + radius
    tagCenter.y = maxY - radius

    for i = 0, segments do
        local x = tagCenter.x - vertices[i + 1].x
        local y = tagCenter.y + vertices[i + 1].y
        table.insert(pPolygonPtArr, cc.p(x, y))
    end

    -- 右上角
    tagCenter.x = maxX - radius
    tagCenter.y = maxY - radius

    for i = 0, segments do
        local x = tagCenter.x + vertices[#vertices - i].x
        local y = tagCenter.y + vertices[#vertices - i].y
        table.insert(pPolygonPtArr, cc.p(x, y))
    end

    -- 右下角
    tagCenter.x = maxX - radius
    tagCenter.y = minY + radius

    for i = 0, segments do
        local x = tagCenter.x + vertices[i + 1].x
        local y = tagCenter.y - vertices[i + 1].y
        table.insert(pPolygonPtArr, cc.p(x, y))
    end

    -- 左下角
    tagCenter.x = minX + radius
    tagCenter.y = minY + radius

    for i = 0, segments do
        local x = tagCenter.x - vertices[#vertices - i].x
        local y = tagCenter.y - vertices[#vertices - i].y
        table.insert(pPolygonPtArr, cc.p(x, y))
    end

    if fillColor == nil then
        fillColor = cc.c4f(0, 0, 0, 0)
    end


    drawNode:drawPolygon(pPolygonPtArr, #pPolygonPtArr, fillColor, borderWidth, color)
end

function ClockBorderRender:drawNodeRoundRectEx(drawNode, rect, borderWidth, radius, color)
    -- segments 表示圆角的精细度，值越大越精细
    local segments = 100
    local origin = cc.p(rect.x, rect.y)
    local destination = cc.p(rect.x + rect.width, rect.y - rect.height)
    local points = {}

    -- 算出1/4圆
    local coef = math.pi/2/segments
    local vertices = {}

    for i = 0, segments do
        local rads = (segments - i) * coef
        local x = radius * math.sin(rads)
        local y = radius * math.cos(rads)

        table.insert(vertices, cc.p(x, y))
    end

    local tagCenter = cc.p(0, 0)
    local minX = math.min(origin.x, destination.x)
    local maxX = math.max(origin.x, destination.x)
    local minY = math.min(origin.y, destination.y)
    local maxY = math.max(origin.y, destination.y)
    local dwPolygonPtMax = (segments + 1) * 4
    local function primitivesDraw(transform, transformUpdated)
        kmGLPushMatrix()
        kmGLLoadMatrix(transform)

        cc.DrawPrimitives.drawColor4B(color.r,color.g,color.b,color.a)

        -- 左上角
        tagCenter.x = minX + radius
        tagCenter.y = maxY - radius

        local pPolygonPtArr = {}
        for i = 0, segments do
            local x = tagCenter.x - vertices[i + 1].x
            local y = tagCenter.y + vertices[i + 1].y
            table.insert(pPolygonPtArr, cc.p(x, y))
        end
        cc.DrawPrimitives.setPointSize(4)
        cc.DrawPrimitives.drawPoints(pPolygonPtArr, #pPolygonPtArr)

        -- 右上角
        tagCenter.x = maxX - radius
        tagCenter.y = maxY - radius

        local pPolygonPtArr2 = {}
        for i = 0, segments do
            local x = tagCenter.x + vertices[#vertices - i].x
            local y = tagCenter.y + vertices[#vertices - i].y
            table.insert(pPolygonPtArr2, cc.p(x, y))
        end
        cc.DrawPrimitives.setPointSize(4)
        cc.DrawPrimitives.drawPoints(pPolygonPtArr2, #pPolygonPtArr2)

        -- 右下角
        tagCenter.x = maxX - radius
        tagCenter.y = minY + radius

        local pPolygonPtArr3 = {}
        for i = 0, segments do
            local x = tagCenter.x + vertices[i + 1].x
            local y = tagCenter.y - vertices[i + 1].y
            table.insert(pPolygonPtArr3, cc.p(x, y))
        end
        cc.DrawPrimitives.setPointSize(4)
        cc.DrawPrimitives.drawPoints(pPolygonPtArr3, #pPolygonPtArr3)

        -- 左下角
        tagCenter.x = minX + radius
        tagCenter.y = minY + radius

        local pPolygonPtArr4 = {}
        for i = 0, segments do
            local x = tagCenter.x - vertices[#vertices - i].x
            local y = tagCenter.y - vertices[#vertices - i].y
            table.insert(pPolygonPtArr4, cc.p(x, y))
        end
        cc.DrawPrimitives.setPointSize(4)
        cc.DrawPrimitives.drawPoints(pPolygonPtArr4, #pPolygonPtArr4)

        gl.lineWidth( 4.0 )
        cc.DrawPrimitives.drawLine(pPolygonPtArr[#pPolygonPtArr], pPolygonPtArr2[1])
        cc.DrawPrimitives.drawLine(pPolygonPtArr2[#pPolygonPtArr2], pPolygonPtArr3[1])
        cc.DrawPrimitives.drawLine(pPolygonPtArr3[#pPolygonPtArr3], pPolygonPtArr4[1])
        cc.DrawPrimitives.drawLine(pPolygonPtArr4[#pPolygonPtArr4], pPolygonPtArr[1])

        kmGLPopMatrix()
    end
    drawNode:registerScriptDrawHandler(primitivesDraw)
end

function ClockBorderRender:drawCountDownRoundRect(drawNode, rect, radius, color, xIndex, totalCount)
    local rate = xIndex / totalCount
    --local totalRemainLen = (1 - rate) * (rect.width + rect.height) * 2

    -- segments 表示圆角的精细度，值越大越精细
    local segments = 100
    local origin = cc.p(rect.x, rect.y)
    local destination = cc.p(rect.x + rect.width, rect.y - rect.height)
    local points = {}

    -- 算出1/4圆
    local coef = math.pi/2/segments
    local vertices = {}

    for i = 0, segments do
        local rads = (segments - i) * coef
        local x = radius * math.sin(rads)
        local y = radius * math.cos(rads)

        table.insert(vertices, cc.p(x, y))
    end

    local tagCenter = cc.p(0, 0)
    local minX = math.min(origin.x, destination.x)
    local maxX = math.max(origin.x, destination.x)
    local minY = math.min(origin.y, destination.y)
    local maxY = math.max(origin.y, destination.y)
    local dwPolygonPtMax = (segments + 1) * 4
    local function primitivesDraw(transform, transformUpdated)
        kmGLPushMatrix()
        kmGLLoadMatrix(transform)

        cc.DrawPrimitives.drawColor4B(color.r,color.g,color.b,color.a)

        -- 左上角
        tagCenter.x = minX + radius
        tagCenter.y = maxY - radius

        local pPolygonPtArr = {}
        for i = 0, segments do
            local x = tagCenter.x - vertices[i + 1].x
            local y = tagCenter.y + vertices[i + 1].y
            table.insert(pPolygonPtArr, cc.p(x, y))
        end

        -- 右上角
        tagCenter.x = maxX - radius
        tagCenter.y = maxY - radius

        local pPolygonPtArr2 = {}
        for i = 0, segments do
            local x = tagCenter.x + vertices[#vertices - i].x
            local y = tagCenter.y + vertices[#vertices - i].y
            table.insert(pPolygonPtArr2, cc.p(x, y))
        end

        -- 右下角
        tagCenter.x = maxX - radius
        tagCenter.y = minY + radius

        local pPolygonPtArr3 = {}
        for i = 0, segments do
            local x = tagCenter.x + vertices[i + 1].x
            local y = tagCenter.y - vertices[i + 1].y
            table.insert(pPolygonPtArr3, cc.p(x, y))
        end

        -- 左下角
        tagCenter.x = minX + radius
        tagCenter.y = minY + radius

        local pPolygonPtArr4 = {}
        for i = 0, segments do
            local x = tagCenter.x - vertices[#vertices - i].x
            local y = tagCenter.y - vertices[#vertices - i].y
            table.insert(pPolygonPtArr4, cc.p(x, y))
        end


        local tmp = 0
        for i = 2, #pPolygonPtArr do
            tmp = tmp + math.sqrt(math.pow((pPolygonPtArr[i].y - pPolygonPtArr[i - 1].y), 2) +  math.pow((pPolygonPtArr[i].x - pPolygonPtArr[i - 1].x), 2))
        end
        --print("最后的tmp值：".. tmp)
        local totalLen = (pPolygonPtArr2[1].x - pPolygonPtArr[#pPolygonPtArr].x) * 2
                + (pPolygonPtArr2[#pPolygonPtArr2].y - pPolygonPtArr3[1].y) * 2
                + tmp * 4
       -- print("圆角矩形周长:".. totalLen)

        local totalRemainLen = rate * totalLen
        gl.lineWidth( 4.0 )
        cc.DrawPrimitives.setPointSize(4)
        --print("实际倒计时长度:"..totalRemainLen)
        if totalRemainLen > 0 then
            if totalRemainLen <= (pPolygonPtArr2[1].x - pPolygonPtArr[#pPolygonPtArr].x) / 2 then
                cc.DrawPrimitives.drawLine(cc.p((pPolygonPtArr2[1].x - pPolygonPtArr[#pPolygonPtArr].x) / 2 - totalRemainLen + pPolygonPtArr[#pPolygonPtArr].x, pPolygonPtArr[#pPolygonPtArr].y), cc.p((pPolygonPtArr2[1].x - pPolygonPtArr[#pPolygonPtArr].x) / 2 + pPolygonPtArr[#pPolygonPtArr].x, pPolygonPtArr[#pPolygonPtArr].y))
            elseif totalRemainLen <= (pPolygonPtArr2[1].x - pPolygonPtArr[#pPolygonPtArr].x) / 2 + tmp then
                cc.DrawPrimitives.drawLine(pPolygonPtArr[#pPolygonPtArr], cc.p((pPolygonPtArr2[1].x - pPolygonPtArr[#pPolygonPtArr].x) / 2 + pPolygonPtArr[#pPolygonPtArr].x, pPolygonPtArr[#pPolygonPtArr].y))
                local huChang = totalRemainLen - (pPolygonPtArr2[1].x - pPolygonPtArr[#pPolygonPtArr].x) / 2
                local pointCount = (1 - huChang / tmp) * #pPolygonPtArr
                pointCount = pointCount - pointCount % 1
                local tmpPtArr = {}
                for i = pointCount, #pPolygonPtArr do
                    table.insert(tmpPtArr, pPolygonPtArr[i])
                end
                cc.DrawPrimitives.drawPoints(tmpPtArr, #tmpPtArr)
            elseif  totalRemainLen <= (pPolygonPtArr2[1].x - pPolygonPtArr[#pPolygonPtArr].x) / 2 + tmp + (pPolygonPtArr[1].y - pPolygonPtArr4[#pPolygonPtArr4].y) then
                cc.DrawPrimitives.drawLine(pPolygonPtArr[#pPolygonPtArr], cc.p((pPolygonPtArr2[1].x - pPolygonPtArr[#pPolygonPtArr].x) / 2 + pPolygonPtArr[#pPolygonPtArr].x, pPolygonPtArr[#pPolygonPtArr].y))
                cc.DrawPrimitives.drawPoints(pPolygonPtArr, #pPolygonPtArr)
                local xian = totalRemainLen - (pPolygonPtArr2[1].x - pPolygonPtArr[#pPolygonPtArr].x) / 2 - tmp
                cc.DrawPrimitives.drawLine(cc.p(pPolygonPtArr[1].x, pPolygonPtArr[1].y - xian), pPolygonPtArr[1])
            elseif totalRemainLen <= (pPolygonPtArr2[1].x - pPolygonPtArr[#pPolygonPtArr].x) / 2 + tmp * 2 + (pPolygonPtArr[1].y - pPolygonPtArr4[#pPolygonPtArr4].y) then
                cc.DrawPrimitives.drawLine(pPolygonPtArr[#pPolygonPtArr], cc.p((pPolygonPtArr2[1].x - pPolygonPtArr[#pPolygonPtArr].x) / 2 + pPolygonPtArr[#pPolygonPtArr].x, pPolygonPtArr[#pPolygonPtArr].y))
                cc.DrawPrimitives.drawPoints(pPolygonPtArr, #pPolygonPtArr)
                cc.DrawPrimitives.drawLine(pPolygonPtArr4[#pPolygonPtArr4], pPolygonPtArr[1])
                local huChang = totalRemainLen - (pPolygonPtArr2[1].x - pPolygonPtArr[#pPolygonPtArr].x) / 2 - tmp - (pPolygonPtArr[1].y - pPolygonPtArr4[#pPolygonPtArr4].y)
                local pointCount = (1 - huChang / tmp) * #pPolygonPtArr4
                pointCount = pointCount - pointCount % 1
                local tmpPtArr = {}
                for i = pointCount, #pPolygonPtArr4 do
                    table.insert(tmpPtArr, pPolygonPtArr4[i])
                end
                cc.DrawPrimitives.drawPoints(tmpPtArr, #tmpPtArr)
            elseif totalRemainLen <= (pPolygonPtArr2[1].x - pPolygonPtArr[#pPolygonPtArr].x) / 2 + tmp * 2 + (pPolygonPtArr[1].y - pPolygonPtArr4[#pPolygonPtArr4].y) + (pPolygonPtArr3[#pPolygonPtArr3].x - pPolygonPtArr4[1].x) then
                cc.DrawPrimitives.drawLine(pPolygonPtArr[#pPolygonPtArr], cc.p((pPolygonPtArr2[1].x - pPolygonPtArr[#pPolygonPtArr].x) / 2 + pPolygonPtArr[#pPolygonPtArr].x, pPolygonPtArr[#pPolygonPtArr].y))
                cc.DrawPrimitives.drawPoints(pPolygonPtArr, #pPolygonPtArr)
                cc.DrawPrimitives.drawLine(pPolygonPtArr4[#pPolygonPtArr4], pPolygonPtArr[1])
                cc.DrawPrimitives.drawPoints(pPolygonPtArr4, #pPolygonPtArr4)
                local xian = totalRemainLen - (pPolygonPtArr2[1].x - pPolygonPtArr[#pPolygonPtArr].x) / 2 - tmp * 2 - (pPolygonPtArr[1].y - pPolygonPtArr4[#pPolygonPtArr4].y)
                cc.DrawPrimitives.drawLine(cc.p(pPolygonPtArr4[1].x + xian, pPolygonPtArr4[1].y), pPolygonPtArr4[1])
            elseif totalRemainLen <= (pPolygonPtArr2[1].x - pPolygonPtArr[#pPolygonPtArr].x) / 2 + tmp * 3 + (pPolygonPtArr[1].y - pPolygonPtArr4[#pPolygonPtArr4].y) + (pPolygonPtArr3[#pPolygonPtArr3].x - pPolygonPtArr4[1].x) then
                cc.DrawPrimitives.drawLine(pPolygonPtArr[#pPolygonPtArr], cc.p((pPolygonPtArr2[1].x - pPolygonPtArr[#pPolygonPtArr].x) / 2 + pPolygonPtArr[#pPolygonPtArr].x, pPolygonPtArr[#pPolygonPtArr].y))
                cc.DrawPrimitives.drawPoints(pPolygonPtArr, #pPolygonPtArr)
                cc.DrawPrimitives.drawLine(pPolygonPtArr4[#pPolygonPtArr4], pPolygonPtArr[1])
                cc.DrawPrimitives.drawPoints(pPolygonPtArr4, #pPolygonPtArr4)
                cc.DrawPrimitives.drawLine(pPolygonPtArr3[#pPolygonPtArr3], pPolygonPtArr4[1])
                local huChang = totalRemainLen - (pPolygonPtArr2[1].x - pPolygonPtArr[#pPolygonPtArr].x) / 2
                        - tmp * 2
                        - (pPolygonPtArr[1].y - pPolygonPtArr4[#pPolygonPtArr4].y)
                        - (pPolygonPtArr3[#pPolygonPtArr3].x - pPolygonPtArr4[1].x)
                local pointCount = (1 - huChang / tmp) * #pPolygonPtArr3
                pointCount = pointCount - pointCount % 1
                local tmpPtArr = {}
                for i = pointCount, #pPolygonPtArr3 do
                    table.insert(tmpPtArr, pPolygonPtArr3[i])
                end
                cc.DrawPrimitives.drawPoints(tmpPtArr, #tmpPtArr)
            elseif totalRemainLen <= (pPolygonPtArr2[1].x - pPolygonPtArr[#pPolygonPtArr].x) / 2
                    + tmp * 3 + (pPolygonPtArr[1].y - pPolygonPtArr4[#pPolygonPtArr4].y)
                    + (pPolygonPtArr3[#pPolygonPtArr3].x - pPolygonPtArr4[1].x)
                    + (pPolygonPtArr2[#pPolygonPtArr2].y - pPolygonPtArr3[1].y)
            then
                cc.DrawPrimitives.drawLine(pPolygonPtArr[#pPolygonPtArr], cc.p((pPolygonPtArr2[1].x - pPolygonPtArr[#pPolygonPtArr].x) / 2 + pPolygonPtArr[#pPolygonPtArr].x, pPolygonPtArr[#pPolygonPtArr].y))
                cc.DrawPrimitives.drawPoints(pPolygonPtArr, #pPolygonPtArr)
                cc.DrawPrimitives.drawLine(pPolygonPtArr4[#pPolygonPtArr4], pPolygonPtArr[1])
                cc.DrawPrimitives.drawPoints(pPolygonPtArr4, #pPolygonPtArr4)
                cc.DrawPrimitives.drawLine(pPolygonPtArr3[#pPolygonPtArr3], pPolygonPtArr4[1])
                cc.DrawPrimitives.drawPoints(pPolygonPtArr3, #pPolygonPtArr3)
                local xian = totalRemainLen - (pPolygonPtArr2[1].x - pPolygonPtArr[#pPolygonPtArr].x) / 2
                        - tmp * 3
                        - (pPolygonPtArr[1].y - pPolygonPtArr4[#pPolygonPtArr4].y)
                        - (pPolygonPtArr3[#pPolygonPtArr3].x - pPolygonPtArr4[1].x)
                cc.DrawPrimitives.drawLine(cc.p(pPolygonPtArr3[1].x, pPolygonPtArr3[1].y + xian), pPolygonPtArr3[1])
            elseif totalRemainLen <= (pPolygonPtArr2[1].x - pPolygonPtArr[#pPolygonPtArr].x) / 2
                    + tmp * 4 + (pPolygonPtArr[1].y - pPolygonPtArr4[#pPolygonPtArr4].y)
                    + (pPolygonPtArr3[#pPolygonPtArr3].x - pPolygonPtArr4[1].x)
                    + (pPolygonPtArr2[#pPolygonPtArr2].y - pPolygonPtArr3[1].y)
            then
                cc.DrawPrimitives.drawLine(pPolygonPtArr[#pPolygonPtArr], cc.p((pPolygonPtArr2[1].x - pPolygonPtArr[#pPolygonPtArr].x) / 2 + pPolygonPtArr[#pPolygonPtArr].x, pPolygonPtArr[#pPolygonPtArr].y))
                cc.DrawPrimitives.drawPoints(pPolygonPtArr, #pPolygonPtArr)
                cc.DrawPrimitives.drawLine(pPolygonPtArr4[#pPolygonPtArr4], pPolygonPtArr[1])
                cc.DrawPrimitives.drawPoints(pPolygonPtArr4, #pPolygonPtArr4)
                cc.DrawPrimitives.drawLine(pPolygonPtArr3[#pPolygonPtArr3], pPolygonPtArr4[1])
                cc.DrawPrimitives.drawPoints(pPolygonPtArr3, #pPolygonPtArr3)
                cc.DrawPrimitives.drawLine(pPolygonPtArr2[#pPolygonPtArr2], pPolygonPtArr3[1])
                local huChang = totalRemainLen - (pPolygonPtArr2[1].x - pPolygonPtArr[#pPolygonPtArr].x) / 2
                        - tmp * 3
                        - (pPolygonPtArr[1].y - pPolygonPtArr4[#pPolygonPtArr4].y)
                        - (pPolygonPtArr3[#pPolygonPtArr3].x - pPolygonPtArr4[1].x)
                        - (pPolygonPtArr2[#pPolygonPtArr2].y - pPolygonPtArr3[1].y)
                local pointCount = (1 - huChang / tmp) * #pPolygonPtArr2
                pointCount = pointCount - pointCount % 1
                local tmpPtArr = {}
                for i = pointCount, #pPolygonPtArr2 do
                    table.insert(tmpPtArr, pPolygonPtArr2[i])
                end
                cc.DrawPrimitives.drawPoints(tmpPtArr, #tmpPtArr)
            elseif totalRemainLen <= totalLen then
                cc.DrawPrimitives.drawLine(pPolygonPtArr[#pPolygonPtArr], cc.p((pPolygonPtArr2[1].x - pPolygonPtArr[#pPolygonPtArr].x) / 2 + pPolygonPtArr[#pPolygonPtArr].x, pPolygonPtArr[#pPolygonPtArr].y))
                cc.DrawPrimitives.drawPoints(pPolygonPtArr, #pPolygonPtArr)
                cc.DrawPrimitives.drawLine(pPolygonPtArr4[#pPolygonPtArr4], pPolygonPtArr[1])
                cc.DrawPrimitives.drawPoints(pPolygonPtArr4, #pPolygonPtArr4)
                cc.DrawPrimitives.drawLine(pPolygonPtArr3[#pPolygonPtArr3], pPolygonPtArr4[1])
                cc.DrawPrimitives.drawPoints(pPolygonPtArr3, #pPolygonPtArr3)
                cc.DrawPrimitives.drawLine(pPolygonPtArr2[#pPolygonPtArr2], pPolygonPtArr3[1])
                cc.DrawPrimitives.drawPoints(pPolygonPtArr2, #pPolygonPtArr2)
                local xian = totalRemainLen - (pPolygonPtArr2[1].x - pPolygonPtArr[#pPolygonPtArr].x) / 2
                        - tmp * 4
                        - (pPolygonPtArr[1].y - pPolygonPtArr4[#pPolygonPtArr4].y)
                        - (pPolygonPtArr3[#pPolygonPtArr3].x - pPolygonPtArr4[1].x)
                        - (pPolygonPtArr2[#pPolygonPtArr2].y - pPolygonPtArr3[1].y)
                cc.DrawPrimitives.drawLine(cc.p(pPolygonPtArr2[1].x - xian, pPolygonPtArr2[1].y), pPolygonPtArr2[1])
            end
        end
        kmGLPopMatrix()
    end
    drawNode:registerScriptDrawHandler(primitivesDraw)
end

return ClockBorderRender
