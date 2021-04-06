require "Global"

local UI_CardPoolPlayer = {}

function UI_CardPoolPlayer:Construct()
    CommandMap:AddCommand("EnsureJustOneCardChoose",self, self.UpdateChooseState)
    CommandMap:AddCommand("GetPlayerChooseID",self, self.GetPlayerChooseID)
end

function UI_CardPoolPlayer:Initialize()
    self:PlayAnimation(self.FirstInit, 0, 1, 0, 1, false)
end

function UI_CardPoolPlayer:UpdateChooseState(ID)
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

function UI_CardPoolPlayer:GetPlayerChooseID()
    local cardsNum = self.HaveCards:GetChildrenCount()
    for i = 0, cardsNum-1 do
        local card = self.HaveCards:GetChildAt(i)
        local cardID = card:GetID()
        if card.state == ECardState.Choose then
            -- self:PlayAnimation(self["comb" .. i+1], 0, 1, 0, 1, false)
            return cardID
        end
    end
end

function UI_CardPoolPlayer:FirstInitCards()
    self.Cards = RandomCards(10)
    local cardsNum = self.HaveCards:GetChildrenCount()
    for i = 0, cardsNum-1 do
        local card = self.HaveCards:GetChildAt(i)
        local param = {
            ID = self.Cards[i+1],
            cardOwner = ECardOwner.Player,
            cardPosition = ECardPostion.OnHand,
        }
        card:UpdateSelf(param)
    end
end

return UI_CardPoolPlayer