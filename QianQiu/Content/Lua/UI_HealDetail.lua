require "Global"

local UI_HealDetail = {}

function UI_HealDetail:Construct()
    self.Button_Close.OnClicked:Add(self.OnCloseClick)
end

function UI_HealDetail:Initialize()
    for i=1,20 do
        self["UI_Card_" .. i]:SetVisibility(ESlateVisibility.Collapsed)
    end
    self:PlayAnimation(self.ShowIn, 0, 1, 0, 1, false)
end

function UI_HealDetail:UpdateSelf(cards)
    if next(cards) then
        for i=1, #cards do
            self["UI_Card_" .. i]:SetVisibility(ESlateVisibility.Visible)
            local param = {
                ID = cards[i],
                cardPosition = ECardPostion.OnStory,
                cardOwner = ECardOwner.Player,
                state = ECardState.UnChoose,
            }
            self["UI_Card_" .. i]:UpdateSelf(param)
        end
    end
end

function UI_HealDetail:OnCloseClick()
    UIStack:PopUIByName("UI_HealDetail", true)
end

function UI_HealDetail:OnDestroy()

end

function UI_HealDetail:OnAnimationFinished(anim)
    if anim == self.ShowOut then
        self:RemoveFromParent()
    end
end

return UI_HealDetail