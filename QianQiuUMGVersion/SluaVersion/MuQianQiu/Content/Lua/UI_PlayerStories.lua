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
        self.Player = EPlayer.PlayerA
        Cards = GameManager:GetPlayerADealCards()
    elseif Player == EPlayer.PlayerB then
        self.Player = EPlayer.PlayerB
        Cards = GameManager:GetPlayerBDealCards()
    end
    for i = 1, #Cards do
        local CardID = Cards[i]
        -- 检查是否有特殊牌的ID
        CardID = GameManager:GetStoryCardID(CardID)
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
                    self:InsertStory(Story, StoryCompleted)
                else
                    self:InsertStory(Story, StoryUncompleted)
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
    self:UpdateAllPlayerStoryHaveState()
    self:AddToViewport(1)
end

function UI_PlayerStories:InsertStory(Story, InTable)
    -- 加入之前要进行去重检查
    for key, value in pairs(InTable) do
        if value.Story.StoryID == Story.Story.StoryID then
            return
        end
    end
    table.insert(InTable, Story)
end

function UI_PlayerStories:UpdateAllPlayerStoryHaveState()
    local PlayerStorys = self.UI_PlayerStoryCompleted:GetAllChildren()
    for i=0, PlayerStorys:Num()-1 do
        local Card = PlayerStorys:Get(i)
        Card:UpdateCardHaveState(self.Player)
    end
    PlayerStorys = self.UI_PlayerStoryUncompleted:GetAllChildren()
    for i=0, PlayerStorys:Num()-1 do
        local Card = PlayerStorys:Get(i)
        Card:UpdateCardHaveState(self.Player)
    end
end

function UI_PlayerStories:OnDestroy()
end

return Class(nil, nil, UI_PlayerStories)