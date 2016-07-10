--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2015/9/22
-- Time: 18:57
-- To change this template use File | Settings | File Templates.
--
local CoinDropAnim = class("CoinDropAnim")

function CoinDropAnim:init(x, y, speed, bounceHeight, finalHeight, time)
    self.constValue = speed             --决定下落速度的一个常量
    self.bounceHeight = bounceHeight    --每次下落弹起的高度，值为0~1之间
    self.finalHeight = finalHeight      --低于该高度将不再弹起
    self.delayTime = time               --开始下落前延时范围
    self.baseX = x
    self.baseY = y
    self.root = cc.Node:create()
    self.root:setPosition(x, y)
    self:initCoinRotateAnim()
    self:initCoinDropAnim()
    return self.root
end

function CoinDropAnim:initCoinRotateAnim()

    local frames = {}
    local file = "#Resources/signIn/coin_%02d.png"
    local spriteFrame = cc.SpriteFrameCache:getInstance()
    local offset = math.random(1, 7)
    for i = 1, 7 do
        local strFile = string.format(file, (i + offset) % 7 + 1)
        --local spFrame = spriteFrame:getSpriteFrame(strFile)
        local spFrame = display.newSpriteFrame(strFile)
        frames[i] = spFrame
    end

    --local frames = display.newFrames("Resources/signIn/coin_%02d.png", 1, 7)
    local animation, firstFrame = display.newAnimation(frames, 0.05)
    firstFrame:addTo(self.root)
    firstFrame:playAnimationForever(animation)
end

function CoinDropAnim:initCoinDropAnim()
    local height = self.baseY
    local anims = {}

    --math.randomseed(os.time())
    local delayTime = math.random() * self.delayTime
    anims[#anims + 1] = cc.DelayTime:create(delayTime)

    while height > self.finalHeight do
        local dropDown = cc.MoveTo:create(math.sqrt(height) / self.constValue, cc.p(self.baseX, 0))
        local speedUp = cc.EaseIn:create(dropDown, 2)

        height = height * self.bounceHeight * math.random()

        local bounce = cc.MoveTo:create(math.sqrt(height) / self.constValue, cc.p(self.baseX, height))
        local speedDown = cc.EaseOut:create(bounce, 2)

        anims[#anims + 1] = cc.Sequence:create(speedUp, speedDown)
    end

    local dropDown = cc.MoveTo:create(math.sqrt(height) / self.constValue, cc.p(self.baseX, 0))
    local speedUp = cc.EaseIn:create(dropDown, 2)

    anims[#anims + 1] = speedUp
    anims[#anims + 1] = cc.CallFunc:create(function ()
        self.root:removeFromParent()
    end)

    local sequence = cc.Sequence:create(anims)
    self.root:runAction(sequence)
end

return CoinDropAnim

