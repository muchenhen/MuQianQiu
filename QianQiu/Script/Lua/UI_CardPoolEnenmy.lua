require "Global"

local UI_CardPoolEnenmy = {}

function UI_CardPoolEnenmy:Initialize()

end

function UI_CardPoolEnenmy:Construct()
    CommandMap:AddCommand("PopOneCardForEnemy", self, self.PopOneCardForEnemy)
    CommandMap:AddCommand("CheckEnemySeason", self, self.CheckEnemySeason)
    CommandMap:AddCommand("PopAndPushOneCardForEnemy", self, self.PopAndPushOneCardForEnemy)
    CommandMap:AddCommand("SetAllCardsbCanEnemy", self, self.SetAllCardsbCanEnemy)
end

function UI_CardPoolEnenmy:FirstInitCards()
    self.Cards = RandomCards(10)
    local cardsNum = self.HaveCards:GetChildrenCount()
    local i = 0
    for i = 0, cardsNum-1 do
        local card = self.HaveCards:GetChildAt(i)
        card:UpdateSelf(self.Cards[i+1])
        i = i + 1
    end
end

function UI_CardPoolEnenmy:PopOneCardForEnemy(param)
    local enemyHaveCard = param.EnemyHaveCard
    local cards = self.HaveCards:GetAllChildren()
    for key, value in pairs(cards) do
        if value.ID == enemyHaveCard then
            value:SetVisibility(ESlateVisibility.Hidden)
            break
        end
    end
end

function UI_CardPoolEnenmy:SetAllCardsbCanEnemy(param)
    local cards = self.HaveCards:GetAllChildren()
    for key, value in pairs(cards) do
        value:SetbCan(param.bCan)
    end
end

function UI_CardPoolEnenmy:PopAndPushOneCardForEnemy(param)
    local playerHaveID = param.PlayerHaveID
    local cards = self.HaveCards:GetAllChildren()
    for key, card in pairs(cards) do
        local cardVisibility = card:GetVisibility()
        if card.ID == playerHaveID and cardVisibility ~= ESlateVisibility.Hidden then
            local newCardID = ChangeCard(playerHaveID)[1]
            --print("对手用卡牌", Cards[playerHaveID].Name, Cards[playerHaveID].Season, "交换出了", Cards[newCardID].Name, Cards[newCardID].Season)
            for i=1, #self.Cards do
                if self.Cards[i] == playerHaveID then
                    self.Cards[i] = newCardID
                end
            end
            card:UpdateSelf(newCardID)
            Enemy.Basic:Action()
            break
        end
    end
end

function UI_CardPoolEnenmy:CheckEnemySeason()
    EnemySeason[ECardSeason.Spring] = false
    EnemySeason[ECardSeason.Summer] = false
    EnemySeason[ECardSeason.Autumn] = false
    EnemySeason[ECardSeason.Winter] = false
    local cards = self.HaveCards:GetAllChildren()
    for key, card in pairs(cards) do
        if card:GetVisibility() ~= ESlateVisibility.Hidden then
            local season = Table.Cards[card.ID].Season
            EnemySeason[ESeason[season]] = true
        end
    end
end

function UI_CardPoolEnenmy:Reset()
    local cards = self.HaveCards:GetAllChildren()
    for key, value in pairs(cards) do
        value:SetVisibility(ESlateVisibility.SelfHitTestInvisible)
    end
end

return UI_CardPoolEnenmy