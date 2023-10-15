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
GameManager.PlayerBChoosing = false
GameManager.PlayerBChoosingCard = nil

GameManager.PlayerADealCards = {}
GameManager.PlayerBDealCards = {}

GameManager.GameRound = EGameRound.PlayerA

GameManager.bNeedShuffleAllPublicCards = false

GameManager.UI_GameStart = nil
GameManager.UI_GameMain = nil

GameManager.StoryNeedToShow = {}

CardStoreIDList = {}

GameManager.UI_RoundTip = nil

GameManager.UI_ChangeCardTip = nil

GameManager.PlayerASpecialCards = {}

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
    GameManager.PlayerBDealCards = {}

    GameManager.UI_RoundTip = MuBPFunction.CreateUserWidget("UI_RoundTip")
    GameManager.UI_ChangeCardTip = MuBPFunction.CreateUserWidget("UI_ChangeCardTip")
end

function GameManager:ChangeRound()
    self.RoundNum = self.RoundNum + 1
    if self.RoundNum == 20 then
        print("游戏结束")
        self:GameEnd()
    else
        if GameManager.GameRound == EGameRound.PlayerA then
            GameManager.GameRound = EGameRound.PlayerB
            GameManager.UI_RoundTip:ShowRoundTip(EPlayer.PlayerB)
            GameManager.PlayerAChoosing = false
            GameManager.PlayerAChoosingCard = nil
            if AIPlayer.bAIMode then
                print("AI开始行动")
            else
                print("玩家B开始行动")
            end
            self:CheckPlayerCardsIfCanContinue(EGameRound.PlayerB)
            if AIPlayer.bAIMode then
                Timer:Add(1, function()
                    AIPlayer:DoAction()
                end)
            end
        else
            GameManager.GameRound = EGameRound.PlayerA
            GameManager.UI_RoundTip:ShowRoundTip(EPlayer.PlayerA)
            AIPlayer.AIChoosing = false
            AIPlayer.AIChoosingCard = nil
            GameManager.PlayerBChoosing = false
            GameManager.PlayerBChoosingCard = nil
            print("玩家A开始行动")
            self:CheckPlayerCardsIfCanContinue(EGameRound.PlayerA)
        end
    end
end

-- @brief 检查玩家的手牌是否可以继续游戏
-- @param GameRound: EGameRound
-- @return bool 是否需要进入选牌重抽模式
function GameManager:CheckPlayerCardsIfCanContinue(GameRound)
    if GameRound == EGameRound.PlayerA then
        self.PLayerAChangingCard = not self.UI_GameMain:CheckPlayerCardsIfCanContinue() 
        if self.PLayerAChangingCard then
            print("由于玩家A的手牌无法继续游戏，将进入选牌重抽模式，接下来选择的牌会被送回牌库并重新洗牌后获得一张新牌")
        end
    else
        self.PLayerBChangingCard = not self.UI_GameMain:CheckPlayerCardsIfCanContinue() 
        if self.PLayerBChangingCard then
            if AIPlayer.bAIMode then
                print("由于AI的手牌无法继续游戏，将进入选牌重抽模式，接下来选择的牌会被送回牌库并重新洗牌后获得一张新牌")
            else
                print("由于玩家B的手牌无法继续游戏，将进入选牌重抽模式，接下来选择的牌会被送回牌库并重新洗牌后获得一张新牌")
            end
        end
    end
end

function GameManager:GameEnd()
    local UI_GameEnd = MuBPFunction.CreateUserWidget("UI_GameEnd")
    if GameManager.PlayerAScore > GameManager.PlayerBScore then
        print("玩家A获胜, 玩家A得分：" .. GameManager.PlayerAScore .. " 玩家B得分：" .. GameManager.PlayerBScore)
        UI_GameEnd:SetWinner(ECardOwnerType.PlayerA, GameManager.PlayerAScore)
    elseif GameManager.PlayerAScore < GameManager.PlayerBScore then
        print("玩家B获胜, 玩家A得分：" .. GameManager.PlayerAScore .. " 玩家B得分：" .. GameManager.PlayerBScore)
        UI_GameEnd:SetWinner(ECardOwnerType.PlayerB, GameManager.PlayerAScore)
    else
        print("平局")
        UI_GameEnd:SetWinner(nil, GameManager.PlayerAScore)
    end
    UI_GameEnd:AddToViewport(0)
    GameManager.PlayerAScore = 0
    GameManager.PlayerBScore = 0
    self.RoundNum = 0
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

function GameManager:GetPlayerADealCards()
    return GameManager.PlayerADealCards
end

function GameManager:UpdatePlayerScore(PlayerCard, PublicCard)
    if PlayerCard.CardOwner == ECardOwnerType.PlayerA then
        table.insert(self.PlayerADealCards, PlayerCard.CardID)
        table.insert(self.PlayerADealCards, PublicCard.CardID)
        self.PlayerAScore = self.PlayerAScore + PlayerCard.Value + PublicCard.Value
        print("玩家A获得了 " .. PlayerCard.Value + PublicCard.Value .. " 分, " .. "Deal卡牌：" .. PlayerCard.Name .. " " .. PublicCard.Name, "分数从 " .. self.PlayerAScore - PlayerCard.Value - PublicCard.Value .. " 变为 " .. self.PlayerAScore)
    elseif PlayerCard.CardOwner == ECardOwnerType.PlayerB then
        table.insert(self.PlayerBDealCards, PlayerCard.CardID)
        table.insert(self.PlayerBDealCards, PublicCard.CardID)
        self.PlayerBScore = self.PlayerBScore + PlayerCard.Value + PublicCard.Value
        if not AIPlayer.bAIMode then
            print("玩家B获得了 " .. PlayerCard.Value + PublicCard.Value .. " 分, " .. "Deal卡牌：" .. PlayerCard.Name .. " " .. PublicCard.Name, "分数从 " .. self.PlayerBScore - PlayerCard.Value - PublicCard.Value .. " 变为 " .. self.PlayerBScore)
        else
            print("AI获得了 " .. PlayerCard.Value + PublicCard.Value .. " 分, " .. "Deal卡牌：" .. PlayerCard.Name .. " " .. PublicCard.Name, "分数从 " .. self.PlayerBScore - PlayerCard.Value - PublicCard.Value .. " 变为 " .. self.PlayerBScore)
        end
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
                    print("玩家A完成了故事：" .. Value.Story.Name .. "，额外获得了 " .. Value.Story.Score .. " 分, " .. "相关卡牌：" .. LogLuaIntArray(Value.Story.CardsName), "分数从 " .. self.PlayerAScore - Value.Story.Score .. " 变为 " .. self.PlayerAScore)
                    table.insert(self.StoryNeedToShow, Value.Story.StoryID)
                end
            elseif PlayerCard.CardOwner == ECardOwnerType.PlayerB then
                if bPlayerHaveAllRequiredCard then
                    self.PlayerBScore = Value.Story.Score + self.PlayerBScore
                    Value.bFinished = true
                    if not AIPlayer.bAIMode then
                        print("玩家B完成了故事：" .. Value.Story.Name .. "，额外获得了 " .. Value.Story.Score .. " 分, " .. "相关卡牌：" .. LogLuaIntArray(Value.Story.CardsName), "分数从 " .. self.PlayerBScore - Value.Story.Score .. " 变为 " .. self.PlayerBScore)
                        table.insert(self.StoryNeedToShow, Value.Story.StoryID)
                    else
                        print("AI完成了故事：" .. Value.Story.Name .. "，额外获得了 " .. Value.Story.Score .. " 分, " .. "相关卡牌：" .. LogLuaIntArray(Value.Story.CardsName), "分数从 " .. self.PlayerBScore - Value.Story.Score .. " 变为 " .. self.PlayerBScore)
                        table.insert(self.StoryNeedToShow, Value.Story.StoryID)
                    end
                end
            end
        end
    end
end

function GameManager:CheckStory()
    GameManager.CurrentStoryShow:Close()
    GameManager:ShowStory()
end

function GameManager:ShowStory()
    if #self.StoryNeedToShow > 0 then
        self.UI_GameMain.bStoryShowing = true
        local StoryID = self.StoryNeedToShow[1]
        table.remove(self.StoryNeedToShow, 1)
        local StoryData = DataManager.GetStoryData(StoryID)
        local CardsID = StoryData.CardsID
        local UI_StoryShow = MuBPFunction.CreateUserWidget("UI_StoryShow")
        GameManager.CurrentStoryShow = UI_StoryShow
        UI_StoryShow:SetStoryInfo(StoryData)
        UI_StoryShow:AddToViewport(99)
        UI_StoryShow:PlayAnimationForward(UI_StoryShow.Show, 1.0, false)
        local AudioID = StoryData.AudioID
        local Audio = MuBPFunction.LoadSoundBase(AudioID)
        GameManager.A_AudioPlayer.Audio:SetSound(Audio)
        GameManager.A_AudioPlayer.Audio:Play(0)
        GameManager.A_AudioPlayer.Audio.OnAudioFinished:Clear()
        GameManager.A_AudioPlayer.Audio.OnAudioFinished:Add(GameManager.CheckStory)
    else
        self.UI_GameMain.bStoryShowing = false
        self.UI_GameMain.bCheckStoryShow = false
        self.UI_GameMain.bNeedChangeRound = true
    end
end

-- 判断玩家是否拥有某张卡牌
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

-- 送回Store一张牌 重新洗牌 并返回一张新牌
function GameManager:ReturnCardToStore(CardID, Player)
    -- 检查是否需要整个Public重新洗牌
    -- self:CheckbNeedShuffleAllPublicCards(Player)
    -- 由于实际上不重新将public一起洗牌，基本无法成功继续游戏，强制重洗所有牌
    GameManager.bNeedShuffleAllPublicCards = true
    if GameManager.bNeedShuffleAllPublicCards then
        -- 将 CardID 和 UI_GameMain.Cards_P中的牌全部放回牌库
        table.insert(CardStoreIDList, CardID)
        for i = 1, #self.UI_GameMain.Cards_P do
            local Card = self.UI_GameMain.Cards_P[i]
            table.insert(CardStoreIDList, Card.CardID)
        end
        self:Shuffle(CardStoreIDList)
        -- 重新设置UI_Main.Cards_P中的牌
        for i = 1, #self.UI_GameMain.Cards_P do
            local CardID = self:GetOneCardFromStore()
            local Card = self.UI_GameMain.Cards_P[i]
            Card:SetCardID(CardID)
        end
        return self:GetOneCardFromStore()
    else
        table.insert(CardStoreIDList, CardID)
        self:Shuffle(CardStoreIDList)
        return self:GetOneCardFromStore()
    end
end

function GameManager:CheckbNeedShuffleAllPublicCards(Player)
    if Player == EPlayer.PlayerA then
        -- 遍历玩家A的手牌 确认CardStoreIDList中的所有牌 是否都是同一个Season

        -- 获取玩家A的手牌的所有Season
        local ACardSeasons = {}
        for i = 1, #self.UI_GameMain.Cards_A do
            local ACardSeasn = self.UI_GameMain.Cards_A[i].Season
            table.insert(ACardSeasons, ACardSeasn)
        end

        -- 获取CardStoreIDList中的所有Season
        local CardStoreSeasons = {}
        for j = 1, #CardStoreIDList do
            local StoreCardID = CardStoreIDList[j]
            local StoreCardData = DataManager.GetCardData(StoreCardID)
            table.insert(CardStoreSeasons, StoreCardData.Season)
        end

        -- 比较两个Seasons是否存在相同的
        for i = 1, #ACardSeasons do
            local ACardSeason = ACardSeasons[i]
            for j = 1, #CardStoreSeasons do
                local StoreCardSeason = CardStoreSeasons[j]
                if ACardSeason == StoreCardSeason then
                    self.bNeedShuffleAllPublicCards = false
                    return
                end
            end
        end
        self.bNeedShuffleAllPublicCards = true

    elseif Player == EPlayer.PlayerB then
        -- 遍历玩家B的手牌 确认CardStoreIDList中的所有牌 是否都是同一个Season
        
        -- 获取玩家B的手牌的所有Season
        local BCardSeasons = {}
        for i = 1, #self.UI_GameMain.Cards_B do
            local BCardSeasn = self.UI_GameMain.Cards_B[i].Season
            table.insert(BCardSeasons, BCardSeasn)
        end

        -- 获取CardStoreIDList中的所有Season
        local CardStoreSeasons = {}
        for j = 1, #CardStoreIDList do
            local StoreCardID = CardStoreIDList[j]
            local StoreCardData = DataManager.GetCardData(StoreCardID)
            table.insert(CardStoreSeasons, StoreCardData.Season)
        end

        -- 比较两个Seasons是否存在相同的
        for i = 1, #BCardSeasons do
            local BCardSeason = BCardSeasons[i]
            for j = 1, #CardStoreSeasons do
                local StoreCardSeason = CardStoreSeasons[j]
                if BCardSeason == StoreCardSeason then
                    self.bNeedShuffleAllPublicCards = false
                    return
                end
            end
        end

        self.bNeedShuffleAllPublicCards = true
    end
end

function GameManager:CheckCardIDIsSpecial(CardID)
    local CardData = DataManager.GetCardData(CardID)
    if CardData.Special then
        return true
    else
        return false
    end
end

function GameManager:GetStoryCardID(CardID)
    if self:CheckCardIDIsSpecial(CardID) then
        local CardData = DataManager.GetCardData(CardID)
        return CardData.SpecialName
    else
        return CardID    
    end
end