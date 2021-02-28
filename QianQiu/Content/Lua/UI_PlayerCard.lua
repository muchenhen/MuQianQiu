require "Global"

local UI_PlayerCard = {}

function UI_PlayerCard:Construct()
    CommandMap:AddCommand("EnsureJustOneCardChoose",self, self.UpdateChooseState)
end

function UI_PlayerCard:Initialize()
    self:PlayAnimation(self.FirstInit, 0, 1, 0, 1, false)
end

function UI_PlayerCard:UpdateChooseState(ID)
    local cardsNum = self.HaveCards:GetChildrenCount()
    for i = 0, cardsNum-1 do
        local card = self.HaveCards:GetChildAt(i)
        local cardID = card:GetID()
        if ID ~= cardID and card.state == ECardState.Choose then
            card:PlayAnimation(card.PlayDown, 0, 1, 0, 1, false)
            card:SetChooseState(ECardState.UnChoose)
        end
    end
end

function UI_PlayerCard:FirstInitCards()
    self.Cards = RandomCards(10)
    local cardsNum = self.HaveCards:GetChildrenCount()
    for i = 0, cardsNum-1 do
        local card = self.HaveCards:GetChildAt(i)
        card:UpdateSelfByID(self.Cards[i+1],true)
        card:SetHovered(true)
        card:SetOwner(EOwner.Player)
    end
end

return UI_PlayerCard