--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/8/27
-- Time: 10:26
-- To change this template use File | Settings | File Templates.
--

local MessageBox = class("MessageBox")

function MessageBox:ctor()

end

function MessageBox.showMsgBoxEx(args) --����add
    args = args or {}
    

    MessageBox.showMsgBox(args.strMsg, args.funcOk, args.strTitle, args.strOk, args.isHideX)
end

function MessageBox.showMsgBox(strMsg, funcOk, strTitle, strOk, isHideX)
    if MessageBox.root ~= nil then
        MessageBox.root:removeFromParent()
        MessageBox.root = nil
    end

    MessageBox.root = cc.CSLoader:createNode("Layers/MessageBoxLayer.csb")
    local rootLayer = MessageBox.root:getChildByName("Panel_MsgBox1")
    rootLayer:setVisible(true)
    local tmp = MessageBox.root:getChildByName("Panel_MsgBox2")
    tmp:setVisible(fasle)

    if strTitle ~= nil then
        local labelTitle = ccui.Helper:seekWidgetByName(rootLayer, "Text_title")
        if labelTitle ~= nil then labelTitle:setString(strTitle) end
    end

    local labelMsg = ccui.Helper:seekWidgetByName(rootLayer, "Text_msg")
    labelMsg:setString(strMsg)

    local btnOk = ccui.Helper:seekWidgetByName(rootLayer, "Button_ok")
    btnOk:setPressedActionEnabled(true)
    if strOk ~= nil then
        btnOk:setTitleText(strOk)
    end
    btnOk:addTouchEventListener(function(widget, type)
        if type == 2 then
            if app.audioPlayer then
                app.audioPlayer:playClickBtnEffect()
            end
            if funcOk ~= nil then
                funcOk()
            end
            MessageBox.root:removeFromParent()
            MessageBox.root = nil
        end
    end)
    local btnClose = ccui.Helper:seekWidgetByName(rootLayer, "Button_close")
    btnClose:setPressedActionEnabled(true)
    btnClose:addTouchEventListener(function(widget, type)
        if type == 2 then
            if app.audioPlayer then
                app.audioPlayer:playClickBtnEffect()
            end
            MessageBox.root:removeFromParent()
            MessageBox.root = nil
        end
    end)
    display:getRunningScene():addChild(MessageBox.root, 100)
    if app ~= nil and app.popLayer ~= nil then
        app.popLayer.show(rootLayer:getChildByName("Image_background"))
    end

    isHideX = isHideX or false
    if isHideX then
        btnClose:hide()
    end

    MessageBox.root:onNodeEvent("exit", function()
        print("MessageBox exit")
         MessageBox.root = nil
    end)
end

function MessageBox.showMsgBoxTwoBtn(strMsg, funcOk, funcCancel, strTitle, strOk, strCancel, funcClose)
    if MessageBox.root ~= nil then
        MessageBox.root:removeFromParent()
        MessageBox.root = nil
    end

    MessageBox.root = cc.CSLoader:createNode("Layers/MessageBoxLayer.csb")
    local rootLayer = MessageBox.root:getChildByName("Panel_MsgBox2")
    rootLayer:setVisible(true)
    local tmp = MessageBox.root:getChildByName("Panel_MsgBox1")
    tmp:setVisible(fasle)

    if strTitle ~= nil then
        local labelTitle = ccui.Helper:seekWidgetByName(rootLayer, "Text_title")
        if labelTitle ~= nil then labelTitle:setString(strTitle) end
    end

    local labelMsg = ccui.Helper:seekWidgetByName(rootLayer, "Text_msg")
    labelMsg:setString(strMsg)

    local btnOk = ccui.Helper:seekWidgetByName(rootLayer, "Button_ok")
    btnOk:setPressedActionEnabled(true)
    if strOk ~= nil then
        btnOk:setTitleText(strOk)
    end
    btnOk:addTouchEventListener(function(widget, type)
        if type == 2 then
             if app.audioPlayer then
                app.audioPlayer:playClickBtnEffect()
            end
            if funcOk ~= nil then
                funcOk()
            end
            MessageBox.root:removeFromParent()
            MessageBox.root = nil
        end
    end)

    local btnCancel = ccui.Helper:seekWidgetByName(rootLayer, "Button_cancel")
    btnCancel:setPressedActionEnabled(true)
    if strCancel ~= nil then
        btnCancel:setTitleText(strCancel)
    end
    btnCancel:addTouchEventListener(function(widget, type)
        if type == 2 then
             if app.audioPlayer then
                app.audioPlayer:playClickBtnEffect()
            end
            if funcCancel ~= nil then
                funcCancel()
            end
            MessageBox.root:removeFromParent()
            MessageBox.root = nil
        end
    end)
    local btnClose = ccui.Helper:seekWidgetByName(rootLayer, "Button_close")
    btnClose:setPressedActionEnabled(true)
    btnClose:addTouchEventListener(function(widget, type)
        if type == 2 then
            if app.audioPlayer then
                app.audioPlayer:playClickBtnEffect()
            end
            if funcClose ~= nil then
                funcClose()
            end
            MessageBox.root:removeFromParent()
            MessageBox.root = nil
        end
    end)
    display:getRunningScene():addChild(MessageBox.root, 100)
    if app ~= nil and app.popLayer ~= nil then
        app.popLayer.show(rootLayer:getChildByName("Image_background"))
    end
end

function MessageBox.hide()
    MessageBox.root:removeFromParent()
    MessageBox.root = nil
end

return MessageBox

