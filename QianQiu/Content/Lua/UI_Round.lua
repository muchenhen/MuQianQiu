require "Global"
local UI_Round = {}

function UI_Round:Construct()

end

function UI_Round:Initialize()
    self:PlayAnimation(self.ShowIn, 0, 1, 0, 1, false)
end

function UI_Round:OnAnimationFinished(anim)
    if anim == self.ShowIn then
        UIStack:PopUIByName("UI_Round", true)
    elseif anim == self.ShowOut then
        self:RemoveFromParent()
    end
end

function UI_Round:OnDestroy()

end

function UI_Round:UpdateSelf(text)
    self.Text_Round:SetText(text)
end

return UI_Round