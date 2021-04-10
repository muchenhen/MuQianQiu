require "Global"

local UI_CardHeal = {}

function UI_CardHeal:Construct()
    CommandMap:AddCommand("UpdatePlayerHeal", self, self.UpdatePlayerHeal)
end

function UI_CardHeal:Initialize()
    self.cards = {}
    self.Cards:ClearChildren()
end

function UI_CardHeal:UpdatePlayerHeal(param)
    local haveCardID = param.PlayerHaveID
    local chooseCardID = param.PlayerChooseID
    local haveCard = Cards[haveCardID]
    local chooseCard = Cards[chooseCardID]
    local card = CreateUI("UI_Card")
    local param = {
        ID = haveCardID,
        cardPosition = ECardPostion.OnStory,
        cardOwner = ECardOwner.Player,
        state = ECardState.UnChoose,
    }
    card:UpdateSelf(param)
    self.Cards:AddChildToGrid(card, 0, 0)
    card.Slot:SetHorizontalAlignment(self.HorAli)
    card.Slot:SetVerticalAlignment(self.VerAli)
    card = nil
    card = CreateUI("UI_Card")
    param = {
        ID = chooseCardID,
        cardPosition = ECardPostion.OnStory,
        cardOwner = ECardOwner.Player,
        state = ECardState.UnChoose,
    }
    card:UpdateSelf(param)
    self.Cards:AddChildToGrid(card, 0, 0)
    card.Slot:SetHorizontalAlignment(self.HorAli)
    card.Slot:SetVerticalAlignment(self.VerAli)
    local totalAngle = 75
    local cardsNum = self.Cards:GetChildrenCount()
    local singleAngle = totalAngle/cardsNum
    for i=0, cardsNum-1 do
        card = self.Cards:GetChildAt(i)
        card.Slot:SetLayer(i)
        card:SetRenderTransformAngle(i * -singleAngle)
    end
end

return UI_CardHeal