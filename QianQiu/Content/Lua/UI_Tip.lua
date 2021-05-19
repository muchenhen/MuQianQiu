require "Global"

local UI_Tip = {}

function UI_Tip:Initialize()

end

function UI_Tip:UpdateSelf(param)
    local text = param.text
    self.Text_Tip:SetText(text)
    self:PlayAnimation(self.ShowTip, 0, 1, 0, 1, false)
end

function UI_Tip:OnAnimationFinished(anim)
    UIStack:PopUIByName("UI_Tip")
end

return UI_Tip