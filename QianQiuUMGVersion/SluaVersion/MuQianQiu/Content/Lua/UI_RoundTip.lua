require("Global")

local UI_RoundTip = {}

function UI_RoundTip:Initialize()
    -- body
end

function UI_RoundTip:ShowRoundTip(Player)
    self:AddToViewport(0)
    self:PlayAnimationForward(self.ShowAnim, 1.0, false)
    if Player == EPlayer.PlayerA then
        self.Text_Round:SetText("你的回合")
    elseif Player == EPlayer.PlayerB then
        self.Text_Round:SetText("对方回合")
    end
    local Delay = self.ShowAnim:GetEndTime() + 0.1
    Timer:Add(
        Delay,
        function()
            self:RemoveFromParent()
        end
    )
end

function UI_RoundTip:OnDestroy()
    -- body
end

return Class(nil, nil, UI_RoundTip)
