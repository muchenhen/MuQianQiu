require "Global"

local UI_CardPoolPlayer = {}

function UI_CardPoolPlayer:Construct()
    CommandMap:AddCommand("EnsureJustOneCardChoose",self, self.UpdateChooseState)
    CommandMap:AddCommand("GetPlayerChooseID",self, self.GetPlayerChooseID)
    CommandMap:AddCommand("PopAndPushOneCardForPlayer", self, self.PopAndPushOneCardForPlayer)
end

function UI_CardPoolPlayer:Initialize()
    self:PlayAnimation(self.FirstInit, 0, 1, 0, 1, false)
end

function UI_CardPoolPlayer:UpdateChooseState(ID)
    local cardsNum = self.HaveCards:GetChildrenCount()
    for i = 0, cardsNum-1 do
        local card = self.HaveCards:GetChildAt(i)
        local cardID = card:GetID()
        if ID ~= cardID and card.cardState == ECardState.Choose then
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
        if card.cardState == ECardState.Choose then
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

function UI_CardPoolPlayer:PopAndPushOneCardForPlayer(param)
    local playerHaveID = param.PlayerHaveID
    local cardsNum = self.HaveCards:GetChildrenCount()
    for i = 0, cardsNum-1 do
        local card = self.HaveCards:GetChildAt(i)
        if card.ID == playerHaveID then
            local newCardID = RandomCards(1)[1]
            print("玩家新生成卡牌：", Cards[newCardID].Name)
            local newCard = CreateUI('UI_Card')
            for i=1, #self.Cards do
                if self.Cards[i] == playerHaveID then
                    self.Cards[i] = newCardID
                end
            end
            local param  = {
                ID = newCardID,
                cardOwner = ECardOwner.Player,
                cardPosition = ECardPostion.OnHand,
            }
            newCard:UpdateSelf(param)
            local col = card.Slot.Column
            local layer = card.Slot.Layer
            local trans = card.Slot.Nudge
            local horAli = card.Slot.HorizontalAlignment
            local verAli = card.Slot.VerticalAlignment
            self.HaveCards:RemoveChildAt(i)
            self.HaveCards:AddChild(newCard)
            newCard.Slot:SetColumn(col)
            newCard.Slot:SetLayer(layer)
            newCard.Slot:SetNudge(trans)
            newCard.Slot:SetHorizontalAlignment(horAli)
            newCard.Slot:SetVerticalAlignment(verAli)
            break
        end
    end
end

return UI_CardPoolPlayer