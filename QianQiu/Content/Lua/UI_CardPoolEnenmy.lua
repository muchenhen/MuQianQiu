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
    local cardsNum = self.HaveCards:GetChildrenCount()
    for i = 0, cardsNum-1 do
        local card = self.HaveCards:GetChildAt(i)
        if card.ID == enemyHaveCard then
            self.HaveCards:RemoveChildAt(i)
            break
        end
    end
end

function UI_CardPoolEnenmy:SetAllCardsbCanEnemy(param)
    local cardsNum = self.HaveCards:GetChildrenCount()
    for i = 0, cardsNum-1 do
        local card = self.HaveCards:GetChildAt(i)
        card:SetbCan(param.bCan)
    end
end

function UI_CardPoolEnenmy:PopAndPushOneCardForEnemy(param)
    local playerHaveID = param.PlayerHaveID
    local cardsNum = self.HaveCards:GetChildrenCount()
    for i = 0, cardsNum-1 do
        local card = self.HaveCards:GetChildAt(i)
        if card.ID == playerHaveID then
            local newCardID = ChangeCard(playerHaveID)[1]
            print("对手用卡牌", Cards[playerHaveID].Name, Cards[playerHaveID].Season, "交换出了", Cards[newCardID].Name, Cards[newCardID].Season)
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
    local cardsNum = self.HaveCards:GetChildrenCount()
    for i = 0, cardsNum-1 do
        local card = self.HaveCards:GetChildAt(i)
        EnemySeason[ESeason[card.season]] = true
    end
end

return UI_CardPoolEnenmy