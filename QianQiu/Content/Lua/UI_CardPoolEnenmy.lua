require "Global"

local UI_CardPoolEnenmy = {}

function UI_CardPoolEnenmy:Initialize()

end

function UI_CardPoolEnenmy:Construct()
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

return UI_CardPoolEnenmy