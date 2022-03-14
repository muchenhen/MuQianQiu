require "Global"
local UIBase = class("UIBase")

-- 播放UI动画
-- InAnimation UWidgetAnimation UserWidget的Animation
-- StartAtTime float 开始动画的时间
-- NumLoopsToPlay int32 动画循环次数
-- PlayMode EUMGSequencePlayMode 动画播放模式
-- PlaybackSpeed float 播放倍速
-- bRestoreState bool  动画停止时是否要将状态还原到未播放动画的状态
function UIBase:PlayAnim(InAnimation, StartAtTime, NumLoopsToPlay, PlayMode, PlaybackSpeed, bRestoreState)
    if not PlayMode then
        PlayMode = EUMGSequencePlayMode.Forward
    end
    if not bRestoreState then
        bRestoreState = false
    end
    if not NumLoopsToPlay then
        NumLoopsToPlay = 1
    end
    if not StartAtTime then
        StartAtTime = 0
    end
    if not PlaybackSpeed then
        PlaybackSpeed = 1
    end
    self:PlayAnimmation(InAnimation, StartAtTime, NumLoopsToPlay, PlayMode, PlaybackSpeed, bRestoreState)
end

function UIBase:Close()
    -- 立即关闭交互
	self:SetVisibility(ESlateVisibility.HitTestInvisible)

end

return UIBase
