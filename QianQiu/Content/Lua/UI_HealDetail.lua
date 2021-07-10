require "Global"

local UI_HealDetail = {}

function UI_HealDetail:Construct()
    self.Button_Close.OnClicked:Add(self.OnCloseClick)
    self.Button_HaveCards.OnClicked:Add(self.OnHaveCards)
    self.Button_Finish.OnClicked:Add(self.OnFinish)
    self.Button_Finding.OnClicked:Add(self.OnFinding)
end

function UI_HealDetail:Initialize()
    self:PlayAnimation(self.ShowIn, 0, 1, 0, 1, false)
    self.bCreateFinish = false
    self.bCreateCanFinish = false
end

function UI_HealDetail:UpdateSelf(param)
    self.cards = param.cards
    self.bPlayerHeal = param.bPlayerHeal
    self.UI_HealCards:UpdateHealHaveCards(self.cards)
end

function UI_HealDetail:OnCloseClick()
    UIStack:PopUIByName("UI_HealDetail", true)
end

function UI_HealDetail:OnFinish()
    local self = UI_HealDetail
    self.HealDetailSwitcher:SetActiveWidget(self.UI_FinishedStory)
    if not self.bCreateFinish then
        self.UI_FinishedStory:UpdateFinishedStory(self.bPlayerHeal)
        self.bCreateFinish = true
    end
end

function UI_HealDetail:OnFinding()
    local self = UI_HealDetail
    self.HealDetailSwitcher:SetActiveWidget(self.UI_CanFinishStory)
    if not self.bCreateCanFinish then
        self.UI_CanFinishStory:UpdateCanFinishCards(self.bPlayerHeal, self.cards)
        self.bCreateCanFinish = true
    end
end

function UI_HealDetail:OnHaveCards()
    local self = UI_HealDetail
    self.HealDetailSwitcher:SetActiveWidget(self.UI_HealCards)
end

function UI_HealDetail:OnDestroy()
    self.bCreateFinish = false
end

function UI_HealDetail:OnAnimationFinished(anim)
    if anim == self.ShowOut then
        self:RemoveFromParent()
    end
end

return UI_HealDetail
