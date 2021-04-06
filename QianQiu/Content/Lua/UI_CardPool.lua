require "Global"

local UI_CardPool = {}

function UI_CardPool:Initialize()
    self:PlayAnimation(self.ShowIn, 0, 1, 0, 1, false)
    
end

function UI_CardPool:Construct()
    CommandMap:AddCommand("OnPlayerCardChoose", self, self.OnCardChoose)
    CommandMap:AddCommand("OnPlayerCardUnchoose", self, self.OnCardUnchoose)
end

function UI_CardPool:FirstInitCards()
    self.Cards = RandomCards(8)
    local cardsNum = self.HaveCards:GetChildrenCount()
    for i = 0, cardsNum-1 do
        local card = self.HaveCards:GetChildAt(i)
        local param = {
            ID = self.Cards[i+1],
            cardOwner = ECardOwner.PublicPool,
            cardPosition = ECardPostion.OnHand,
        }
        card:UpdateSelf(param)
    end
end

function UI_CardPool:OnCardChoose(cardID)
    local cardsNum = self.HaveCards:GetChildrenCount()
    for i = 1, #self.Cards do
        if Table.Cards[self.Cards[i]].Season == Table.Cards[cardID].Season then
            for j = 0, cardsNum-1 do
                local card = self.HaveCards:GetChildAt(j)
                if card:GetID() == self.Cards[i] then
                    card:PlayAnimation(card.PlayerHovered, 0, 1, 0, 1, false)
                    card.Img_CardChoose:SetVisibility(ESlateVisibility.HitTestInvisible)
                end
            end
        end
    end
end

function UI_CardPool:OnCardUnchoose(cardID)
    local cardsNum = self.HaveCards:GetChildrenCount()
    for i = 1, #self.Cards do
        if Table.Cards[self.Cards[i]].Season == Table.Cards[cardID].Season then
            for j = 0, cardsNum-1 do
                local card = self.HaveCards:GetChildAt(j)
                if card:GetID() == self.Cards[i] then
                    card:PlayAnimation(card.PlayerUnhovered, 0, 1, 0, 1, false)
                    card.Img_CardChoose:SetVisibility(ESlateVisibility.Collapsed)
                end
            end
        end
    end
end

return UI_CardPool