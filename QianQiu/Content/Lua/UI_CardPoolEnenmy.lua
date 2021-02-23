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
        card:UpdateSelfByID(self.Cards[i+1],true)
    end
end

function UI_CardPoolEnenmy:SetBackOn()
    for i=0,9 do
        local cardName = "UI_Card_" .. i
        self[cardName]:SetPlayer(false)
        self[cardName]:SetClick(false)
    end
end

return UI_CardPoolEnenmy