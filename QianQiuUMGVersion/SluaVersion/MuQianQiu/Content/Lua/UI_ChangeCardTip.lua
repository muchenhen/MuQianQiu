require ("Global")

local UI_ChangeCardTip = {}

function UI_ChangeCardTip:Initialize()
    self.bAddedToView = false
end

function UI_ChangeCardTip:ShowChangeCardTip()
    if not self.bAddedToView then
        self:AddToViewport(0)
        self.bAddedToView = true
    end
    self:SetVisibility(ESlateVisibility.SelfHitTestInvisible)
end

function UI_ChangeCardTip:HideChangeCardTip()
    self:SetVisibility(ESlateVisibility.Collapsed)
end

function UI_ChangeCardTip:OnDestroy()

end

return Class(nil, nil, UI_ChangeCardTip)