require("Global")

local UI_PlayerStory = {}

function  UI_PlayerStory:Initialize()
    -- body
end

function UI_PlayerStory:InitCards(Story)
    local CardsID = Story.Story.CardsID
    for i=0, CardsID:Num() - 1 do
        local CardID = CardsID:Get(i)
        local Card = MuBPFunction.CreateUserWidget("UI_Card")
        Card:SetCardID(CardID)
        self.HorizontalBox_Cards:AddChild(Card)
        self.Text_StoryName:SetText(Story.Story.Name)
    end
end

function UI_PlayerStory:UpdateCardHaveState(Player)
    local Cards = {}
    if Player == EPlayer.PlayerA then
        Cards = GameManager:GetPlayerADealCards()
    elseif Player == EPlayer.PlayerB then
        Cards = GameManager:GetPlayerBDealCards()
    end
    local WidgetCards = self.HorizontalBox_Cards:GetAllChildren()
    for i=0, WidgetCards:Num()-1 do
        local Card = WidgetCards:Get(i)
        local CardID = Card.CardID
        local bHasCard = false
        for j = 1, #Cards do
            if Cards[j] == CardID then
                bHasCard = true
                break
            end
        end
        Card:SetHave(bHasCard)
    end
end

function UI_PlayerStory:OnDestroy()
    -- body
end

return Class(nil, nil, UI_PlayerStory)