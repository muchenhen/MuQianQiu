require "Global"
local UI_StoryShow = {}

function UI_StoryShow:Construct()

end

function UI_StoryShow:Initialize()
    self:PlayAnimation(self.ShowIn, 0, 1, 0, 1, false)
end

function UI_StoryShow:OnAnimationFinished(anim)
    if anim == self.ShowIn then
        self:PlayAnimation(self.ShowOut, 0, 1, 0, 1, false)
    elseif anim == self.ShowOut then
        self.Cards:ClearChildren()
        self:RemoveFromParent()
    end
end

function UI_StoryShow:OnDestroy()

end

return UI_StoryShow