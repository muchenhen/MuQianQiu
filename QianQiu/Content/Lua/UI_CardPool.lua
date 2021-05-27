require "Global"
local UI_CardPool = {}

function UI_CardPool:Initialize()
    self:PlayAnimation(self.ShowIn, 0, 1, 0, 1, false)
end

function UI_CardPool:Construct()
    CommandMap:AddCommand("OnPlayerCardChoose", self, self.OnCardChoose)
    CommandMap:AddCommand("OnPlayerCardUnchoose", self, self.OnCardUnchoose)
    CommandMap:AddCommand("ResetPlayerCardUnChoose", self, self.ResetPlayerCardUnChoose)
    CommandMap:AddCommand("PopAndPushOneCardForPublic", self, self.PopAndPushOneCardForPublic)
    CommandMap:AddCommand("CheckPublicSeason", self, self.CheckPublicSeason)
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
                    card:SetCardState(ECardState.Choose)
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
    local publicCardID = param.PlayerChooseID or param.EnemyChooseID
    local cardsNum = self.HaveCards:GetChildrenCount()
    for i = 0, cardsNum-1 do
        local card = self.HaveCards:GetChildAt(i)
        if card.ID == publicCardID then
            local newCardID = RandomCards(1)[1]
            print("卡池新生成卡牌：", Cards[newCardID].Name)
            -- local newCard = CreateUI('UI_Card')
            for i=1, #self.Cards do
                if self.Cards[i] == publicCardID then
                    self.Cards[i] = newCardID
                end
            end
            local param  = {
                ID = newCardID,
                cardOwner = ECardOwner.PublicPool,
                cardPosition = ECardPostion.OnHand,
                state = ECardState.Choose
            }
            card:UpdateSelf(param)
            self:ResetPlayerCardUnChoose()
            break
        end
    end
end

function UI_CardPool:ResetPlayerCardUnChoose()
    local cards = self.HaveCards:GetAllChildren()
    for key, value in pairs(cards) do
        value:SetCardState(ECardState.UnChoose)
    end
end

function UI_CardPool:CheckPublicSeason()
    PublicSeason[ECardSeason.Spring] = false
    PublicSeason[ECardSeason.Summer] = false
    PublicSeason[ECardSeason.Autumn] = false
    PublicSeason[ECardSeason.Winter] = false
    local cardsNum = self.HaveCards:GetChildrenCount()
    for i = 0, cardsNum-1 do
        local card = self.HaveCards:GetChildAt(i)
        PublicSeason[ESeason[card.season]] = true
    end
end

function UI_CardPool:Reset()

end

return UI_CardPool