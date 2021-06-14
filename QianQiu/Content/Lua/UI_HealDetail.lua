require "Global"

local UI_HealDetail = {}

function UI_HealDetail:Construct()
    self.Button_Close.OnClicked:Add(self.OnCloseClick)
    self.Button_HaveCards.OnClicked:Add(self.OnHaveCards)
    self.Button_Finish.OnClicked:Add(self.OnFinish)
    self.Button_Finding.OnClicked:Add(self.OnFinding)
end

function UI_HealDetail:Initialize()
    for i = 1, 20 do
        self["UI_Card_" .. i]:SetVisibility(ESlateVisibility.Collapsed)
    end
    self:PlayAnimation(self.ShowIn, 0, 1, 0, 1, false)
end

function UI_HealDetail:UpdateSelf(cards)
    if next(cards) then
        for i = 1, #cards do
            self["UI_Card_" .. i]:SetVisibility(ESlateVisibility.Visible)
            self["UI_Card_" .. i]:UpdateSelf(cards[i])
        end
    end
end

function UI_HealDetail:OnCloseClick()
    UIStack:PopUIByName("UI_HealDetail", true)
end

function UI_HealDetail:OnFinish()
    ShowTip("暂未开发")
end

function UI_HealDetail:OnFinding()
    ShowTip("暂未开发")
end

function UI_HealDetail:OnHaveCards()
    ShowTip("暂未开发")
end

function UI_HealDetail:OnDestroy()
end

function UI_HealDetail:OnAnimationFinished(anim)
    if anim == self.ShowOut then
        self:RemoveFromParent()
    end
end

return UI_HealDetail
