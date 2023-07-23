require("Global")

local UI_PlayerStories = {}

function UI_PlayerStories:Initialize()
end

function UI_PlayerStories:UpdatePlayerStoryStates(Player)
    -- 遍历玩家Deal的所有牌，检查出来已经完成的故事和未完成的故事
    local StoryCompleted = {}
    local StoryUncompleted = {}
    local Cards
    if Player == EPlayer.PlayerA then
        Cards = GameManager:GetPlayerADealCards()
    elseif Player == EPlayer.PlayerB then
        Cards = GameManager:GetPlayerBDealCards()
    end
    for i = 1, #Cards do
        local CardID = Cards[i]
        for key, Story in pairs(GameManager.AllStory) do
            -- Story.CardsID中有没有CardID
            local bHasCard = false
            local CardsID = Story.Story.CardsID
            for i=0, CardsID:Num() - 1 do
                if CardsID:Get(i) == CardID then
                    bHasCard = true
                    break
                end
            end
            if bHasCard then
                if Story.bFinished then
                    table.insert(StoryCompleted, Story)
                else
                    table.insert(StoryUncompleted, Story)
                end
            end
        end
    end

    print("Player " .. Player .. " Completed Story:")
    for key, Story in pairs(StoryCompleted) do
        print(Story.Story.StoryID)
        local UI_PlayerStory = MuBPFunction.CreateUserWidget("UI_PlayerStory")
        UI_PlayerStory:InitCards(Story)
        self.UI_PlayerStoryCompleted:AddChild(UI_PlayerStory)
    end
    print("Player " .. Player .. " Uncompleted Story:")
    for key, Story in pairs(StoryUncompleted) do
        print(Story.Story.StoryID)
        local UI_PlayerStory = MuBPFunction.CreateUserWidget("UI_PlayerStory")
        UI_PlayerStory:InitCards(Story)
        self.UI_PlayerStoryUncompleted:AddChild(UI_PlayerStory)
    end
    self:AddToViewport(1)
end

function UI_PlayerStories:OnDestroy()
end

return Class(nil, nil, UI_PlayerStories)