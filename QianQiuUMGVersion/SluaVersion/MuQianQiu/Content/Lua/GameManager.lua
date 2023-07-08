require("AI")

MuBPFunction = import("MuBPFunction")

GameManager = {}

GameManager.Min1 = 101
GameManager.Max1 = 124
GameManager.Min2 = 201
GameManager.Max2 = 224
GameManager.Min3 = 301
GameManager.Max3 = 324

GameManager.AllStory = {}

GameManager.PlayerAScore = 0
GameManager.PlayerBScore = 0

GameManager.PlayerAChoosing = false
GameManager.PlayerAChoosingCard = nil

GameManager.PlayerADealCards = {}

GameManager.PlayerBChoosing = false
GameManager.PlayerBChoosingCard = nil

GameManager.PlayerBDealCards = {}

GameManager.GameRound = EGameRound.PlayerA

CardStoreIDList = {}

function GameManager:GameStart()
    GameManager.PlayerAScore = 0
    GameManager.PlayerBScore = 0

    GameManager.GameRound = EGameRound.PlayerA

    -- 将所有的故事数据存入AllStory 并 = false
    local Stories = DataManager.GetAllStoryData()
    for i = 0, Stories:Num() - 1 do
        local Story = {Story = Stories:Get(i), bFinished = false}
        table.insert(GameManager.AllStory, Story)
    end

    self.RoundNum = 0
    self:InitCardOnBegin()

    GameManager.PlayerADealCards = {}
end

function GameManager:ChangeRound()
    self.RoundNum = self.RoundNum + 1
    if self.RoundNum == 19 then
        
    else
        if GameManager.GameRound == EGameRound.PlayerA then
            GameManager.GameRound = EGameRound.PlayerB
            if AIPlayer.bAIMode then
                Timer:Add(1, function()
                    AIPlayer:DoAction()
                end)
                
            end
        else
            GameManager.GameRound = EGameRound.PlayerA
        end
    end
end

function GameManager:GameEnd()
end

function GameManager:GameRestart()
end

-- 洗牌
function GameManager:Shuffle(array)
    local counter = #array

    while counter > 1 do
        local index = math.random(counter)
        array[counter], array[index] = array[index], array[counter]
        counter = counter - 1
    end

    return array
end

function GameManager:InitCardOnBegin()
    -- 清空CardIDList
    CardStoreIDList = {}
    for i = GameManager.Min2, GameManager.Max2 do
        table.insert(CardStoreIDList, i)
    end
    for i = GameManager.Min3, GameManager.Max3 do
        table.insert(CardStoreIDList, i)
    end
    self:Shuffle(CardStoreIDList)
end

function GameManager:GetOneCardFromStore()
    local cardID = CardStoreIDList[1]
    table.remove(CardStoreIDList, 1)
    return cardID
end

function GameManager:GetPlayerAScore()
    return GameManager.PlayerAScore
end

function GameManager:GetPlayerBScore()
    return GameManager.PlayerBScore
end

function GameManager:UpdatePlayerScore(PlayerCard, PublicCard)


    if PlayerCard.CardOwner == ECardOwnerType.PlayerA then
        table.insert(self.PlayerADealCards, PlayerCard.CardID)
        table.insert(self.PlayerADealCards, PublicCard.CardID)
        self.PlayerAScore = self.PlayerAScore + PlayerCard.Value + PublicCard.Value
    elseif PlayerCard.CardOwner == ECardOwnerType.PlayerB then
        table.insert(self.PlayerBDealCards, PlayerCard.CardID)
        table.insert(self.PlayerBDealCards, PublicCard.CardID)
        self.PlayerBScore = self.PlayerBScore + PlayerCard.Value + PublicCard.Value
    end

    -- 遍历所有故事
    for Key, Value in pairs(self.AllStory) do
        if not Value.bFinished then
            local bPlayerHaveAllRequiredCard = true
            local RequiredCardIDs = Value.Story.CardsID
            for i = 0, RequiredCardIDs:Num() - 1 do
                if not GameManager:IsPlayerHaveThisCard(RequiredCardIDs:Get(i), PlayerCard.CardOwner) then
                    bPlayerHaveAllRequiredCard = false
                    break
                end
            end
            -- 如果玩家拥有所有需要的卡牌
            if PlayerCard.CardOwner == ECardOwnerType.PlayerA then
                if bPlayerHaveAllRequiredCard then
                    self.PlayerAScore = Value.Story.Score + self.PlayerAScore
                    Value.bFinished = true
                    print("玩家A完成了故事：" .. Value.Story.Name .. "，获得了" .. Value.Story.Score .. "分" .. "相关卡牌名称为：" .. LogLuaIntArray(Value.Story.CardsName))
                end
            elseif PlayerCard.CardOwner == ECardOwnerType.PlayerB then
                if bPlayerHaveAllRequiredCard then
                    self.PlayerBScore = Value.Story.Score + self.PlayerBScore
                    Value.bFinished = true
                    print("玩家B完成了故事：" .. Value.Story.Name .. "，获得了" .. Value.Story.Score .. "分" .. "相关卡牌名称为：" .. LogLuaIntArray(Value.Story.CardsName))
                end
            end
        end
    end
end

function GameManager:IsPlayerHaveThisCard(CardID, CardOwner)
    local Cards = nil
    if CardOwner == ECardOwnerType.PlayerA then
        Cards = GameManager.PlayerADealCards
    else
        Cards = GameManager.PlayerBDealCards
    end

    for index, value in ipairs(Cards) do
        if value == CardID then
            return true
        end
    end
    return false
end