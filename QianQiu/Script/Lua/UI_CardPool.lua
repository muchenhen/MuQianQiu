require "Global"
local UI_CardPool = {}

function UI_CardPool:Initialize()
    self:PlayAnimation(self.ShowIn, 0, 1, 0, 1, false)
end

function UI_CardPool:Construct()
    CommandMap:AddCommand("ResetPlayerCardUnChoose", self, self.ResetPlayerCardUnChoose)
    CommandMap:AddCommand("PopAndPushOneCardForPublic", self, self.PopAndPushOneCardForPublic)
    CommandMap:AddCommand("CheckPublicSeason", self, self.CheckPublicSeason)
end

function UI_CardPool:FirstInitCards()
    self.Cards = RandomCards(8)
    local cardsNum = self.HaveCards:GetChildrenCount()
    for i = 0, cardsNum - 1 do
        local card = self.HaveCards:GetChildAt(i)
        card:UpdateSelf(self.Cards[i + 1])
    end
end

function UI_CardPool:PopAndPushOneCardForPublic(ID)
    local publicCardID = ID
    local cardsNum = self.HaveCards:GetChildrenCount()
    for i = 0, cardsNum - 1 do
        local card = self.HaveCards:GetChildAt(i)
        if card.ID == publicCardID then
            local newCardID = RandomCards(1)[1]
            --print("卡池新生成卡牌：", Cards[newCardID].Name)
            -- local newCard = CreateUI('UI_Card')
            for i = 1, #self.Cards do
                if self.Cards[i] == publicCardID then
                    self.Cards[i] = newCardID
                end
            end
            card:UpdateSelf(newCardID)
            self:ResetPlayerCardUnChoose()
            break
        end
    end
end

function UI_CardPool:ResetPlayerCardUnChoose()
    local cards = self.HaveCards:GetAllChildren()
    for key, value in pairs(cards) do
        if value.state == ECardState.Choose then
            value:ChangeChooseState()
        end
    end
end

function UI_CardPool:CheckPublicSeason()
    PublicSeason[ECardSeason.Spring] = false
    PublicSeason[ECardSeason.Summer] = false
    PublicSeason[ECardSeason.Autumn] = false
    PublicSeason[ECardSeason.Winter] = false
    local cards = self.HaveCards:GetAllChildren()
    for k, card in pairs(cards) do
        local season = Table.Cards[card.ID].Season
        PublicSeason[ESeason[season]] = true
    end
end

function UI_CardPool:Reset()
end

return UI_CardPool
