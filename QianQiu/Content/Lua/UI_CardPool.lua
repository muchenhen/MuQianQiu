require "Global"
local UI_Card = require "UI_Card"

local UI_CardPool = {}

function UI_CardPool:Initialize()
    self:PlayAnimation(self.ShowIn, 0, 1, 0, 1, false)
    
end

function UI_CardPool:Construct()
    CommandMap:AddCommand("OnPlayerCardChoose", self, self.OnCardChoose)
    CommandMap:AddCommand("OnPlayerCardUnchoose", self, self.OnCardUnchoose)
    CommandMap:AddCommand("ResetPlayerCardUnChoose", self, self.ResetPlayerCardUnChoose)
    CommandMap:AddCommand("PopAndPushOneCardForPublic", self, self.PopAndPushOneCardForPublic)
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
                    card.cardState = ECardState.Choose
                    -- card:SetVisibility(ESlateVisibility.HitTestInvisible)
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
                    card.cardState = ECardState.UnChoose
                    -- card:SetVisibility(ESlateVisibility.SelfHitTestInvisible)
                    card.Img_CardChoose:SetVisibility(ESlateVisibility.Collapsed)
                end
            end
        end
    end
end

function UI_CardPool:PopAndPushOneCardForPublic(param)
    local publicCardID = param.PlayerChooseID
    local cardsNum = self.HaveCards:GetChildrenCount()
    for i = 0, cardsNum-1 do
        local card = self.HaveCards:GetChildAt(i)
        if card.ID == publicCardID then
            local newCardID = RandomCards(1)[1]
            local newCard = CreateUI('UI_Card')
            local param  = {
                ID = newCardID,
                cardOwner = ECardOwner.PublicPool,
                cardPosition = ECardPostion.OnHand,
            }
            newCard:UpdateSelf(param)
            local pos = card.Slot:GetPosition()
            local trans = card.RenderTransform
            local zOrder = card.Slot:GetZOrder()
            self.HaveCards:RemoveChildAt(i)
            self.HaveCards:AddChild(newCard)
            newCard.Slot:SetPosition(pos)
            newCard.Slot:SetZOrder(zOrder)
            newCard:SetRenderTransform(trans)
            break
        end
    end
end

function UI_CardPool:ResetPlayerCardUnChoose()
    local cardsNum = self.HaveCards:GetChildrenCount()
    for i = 1, #self.Cards do
        local card = self.HaveCards:GetChildAt(i)
        if card.cardState == ECardState.Choose then
            card.cardState = ECardState.UnChoose
        end
    end
end

return UI_CardPool