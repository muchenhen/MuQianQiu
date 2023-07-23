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

function UI_PlayerStory:OnDestroy()
    -- body
end

return Class(nil, nil, UI_PlayerStory)