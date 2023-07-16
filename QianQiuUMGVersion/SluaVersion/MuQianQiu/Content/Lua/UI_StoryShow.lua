require("Global")

local UI_StoryShow = {}

function UI_StoryShow:Initialize()

end

function UI_StoryShow:SetStoryInfo(StoryData)
    local CardIDs = StoryData.CardsID
    for _, CardID in pairs(CardIDs) do
        local UI_Card = MuBPFunction.CreateUserWidget("UI_Card")
        UI_Card:SetCardID(CardID)
        self.Box_StoryCards:AddChildToHorizontalBox(UI_Card)
        UI_Card.Slot:SetHorizontalAlignment(EHorizontalAlignment.HAlign_Center)
        UI_Card.Slot:SetVerticalAlignment(EVerticalAlignment.VAlign_Center)
    end
    self.Text_StoryName:SetText(StoryData.Name)
    self.Text_StoryValue:SetText(StoryData.Score)
end

function UI_StoryShow:Construct()

end

function UI_StoryShow:OnDestroy()

end

return Class(nil, nil, UI_StoryShow)