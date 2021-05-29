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
    for i = 0, cardsNum-1 do
        local card = self.HaveCards:GetChildAt(i)
        local param = {
            ID = self.Cards[i+1], -- 测试Enemy替换卡片
            cardOwner = ECardOwner.Enemy,
            cardPosition = ECardPostion.OnHand,
        }
        card:UpdateSelf(param)
    end
end

function UI_CardPoolEnenmy:PopOneCardForEnemy(param)
    local enemyHaveCard = param.EnemyHaveCard
    local cards = self.HaveCards:GetAllChildren()
    for key, value in pairs(cards) do
        if value.ID == enemyHaveCard then
            value:SetCardVisibile(ESlateVisibility.Hidden)
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
        local cardVisibility = card:GetCardVisibility()
        if card.ID == playerHaveID and cardVisibility ~= ESlateVisibility.Hidden then
            local newCardID = ChangeCard(playerHaveID)[1]
            --print("对手用卡牌", Cards[playerHaveID].Name, Cards[playerHaveID].Season, "交换出了", Cards[newCardID].Name, Cards[newCardID].Season)
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
            card:UpdateSelf(param)
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
        if card:GetCardVisibility() ~= ESlateVisibility.Hidden then
            EnemySeason[ESeason[card.season]] = true
        end
    end
end

function UI_CardPoolEnenmy:Reset()
    local cards = self.HaveCards:GetAllChildren()
    for key, value in pairs(cards) do
        local param  = {
            cardOwner = ECardOwner.Enemy,
            cardPosition = ECardPostion.OnHand,
        }
        value:UpdateSelf(param)
        value:SetCardVisibile(ESlateVisibility.SelfHitTestInvisible)
    end
end

return UI_CardPoolEnenmy