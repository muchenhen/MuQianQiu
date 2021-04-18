require "Global"

local UI_CardPoolEnenmy = {}

function UI_CardPoolEnenmy:Initialize()

end

function UI_CardPoolEnenmy:Construct()
    CommandMap:AddCommand("PopOneCardForEnemy", self, self.PopOneCardForEnemy)
end

function UI_CardPoolEnenmy:FirstInitCards()
    self.Cards = RandomCards(10)
    local cardsNum = self.HaveCards:GetChildrenCount()
    for i = 0, cardsNum-1 do
        local card = self.HaveCards:GetChildAt(i)
        local param = {
            ID = self.Cards[i+1],
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

return UI_CardPoolEnenmy