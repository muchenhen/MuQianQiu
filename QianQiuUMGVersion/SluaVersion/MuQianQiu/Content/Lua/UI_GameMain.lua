require("Global")
local Card = require("UI_Card")

local UI_GameMain = {}

UI_GameMain.Cards_A = {}
UI_GameMain.Cards_B = {}
UI_GameMain.Cards_P = {}

UI_GameMain.StoryNeedToShow = {}
UI_GameMain.bCheckStoryShow = false
UI_GameMain.bStoryShowing = false

function UI_GameMain:Initialize()
    GameManager.UI_GameMain = self
    self.bHasScriptImplementedTick = true
    self:SetVisibility(ESlateVisibility.Hidden)

    -- Card实例加到对应的table里 需要数字做索引
    for index = 1, 10 do
        self.Cards_A[index] = self["Card_A" .. string.format("%02d", index)]
        self.Cards_B[index] = self["Card_B" .. string.format("%02d", index)]
        self.Cards_P[index] = self["Card_P" .. string.format("%02d", index)]
    end

    self:OnInit()
end

function UI_GameMain:Tick()
   Timer:Update()

   if self.bCheckStoryShow and not self.bStoryShowing then
        self.bStoryShowing = true
        GameManager:ShowStory()
   end

   if self.bNeedChangeRound then
        -- 切换回合
        GameManager:ChangeRound()
        self.bNeedChangeRound = false
   end
end

function UI_GameMain:OnInit()
    -- 清理分数
    self.Text_PlayerAScore:SetText(GameManager:GetPlayerAScore())
    self.Text_PlayerBScore:SetText(GameManager:GetPlayerBScore())

    -- 设置每一边的卡牌ID 并设置对应的Owner
    -- A01-A10
    for index = 1, 10 do
        self.Cards_A[index]:SetCardID(GameManager:GetOneCardFromStore())
        self.Cards_A[index]:SetCardOwner(ECardOwnerType.PlayerA)
        self.Cards_A[index]:AddOnClickEvent(MakeCallBack(self.OnCardClicked, self))
    end
    -- B01-B10
    for index = 1, 10 do
        self.Cards_B[index]:SetCardID(GameManager:GetOneCardFromStore())
        self.Cards_B[index]:SetCardOwner(ECardOwnerType.PlayerB)
        self.Cards_B[index]:AddOnClickEvent(MakeCallBack(self.OnCardClicked, self))
    end
    -- P01-P08
    for index = 1, 8 do
        self.Cards_P[index]:SetCardID(GameManager:GetOneCardFromStore())
        self.Cards_P[index]:SetCardOwner(ECardOwnerType.Public)
        self.Cards_P[index]:AddOnClickEvent(MakeCallBack(self.OnCardClicked, self))
    end

    -- 设置特殊卡
    self:InitSpecialCards()

    self:PlayAnimationForward(self.InitAnim, 1.0, false)
    self:SetVisibility(ESlateVisibility.Visible)

    if AIPlayer.bAIMode then
        AIPlayer.Cards = self.Cards_B
        AIPlayer.PCards = self.Cards_P
    end

    -- 绑定A查看故事按钮
    self.Button_PlayerAStoryDetail.OnClicked:Add(MakeCallBack(self.OnPlayerAStoryDetailClick, self))
end

function UI_GameMain:OnCardClicked(Card)
    -- 玩家A的回合 并且点击的是玩家A的卡牌
    if Card.CardOwner == ECardOwnerType.PlayerA and GameManager.GameRound == EGameRound.PlayerA then
        -- 玩家当前不处于已选中一张手牌的状态
        if not GameManager.PlayerAChoosing then
            print("玩家A选择自己的手牌：" .. Card.CardID, Card.Name, Card.Value, Card.Season)

            -- 玩家A手中的牌不存在在P区能找到相同Season的牌 进入弃牌重选流程
            if GameManager.PLayerAChangingCard then
                local NewCardID = GameManager:ReturnCardToStore(Card.CardID, EPlayer.PlayerA)
                print(string.format("玩家A使用 %d %s 交换了 %d %s", Card.CardID, Card.Name, NewCardID, DataManager.GetCardData(NewCardID).Name))
                Card:SetCardID(NewCardID)
                -- 重新检查
                if self:CheckPlayerCardsIfCanContinue() then
                    print("玩家A交换手牌完成，通过检查，继续游戏")
                    GameManager.PLayerAChangingCard = false

                    GameManager.PlayerAChoosing = false
                    GameManager.PlayerAChoosingCard = nil
                else
                    print("玩家A交换手牌完成，未通过检查，继续交换")
                end

            -- 玩家A手中的牌至少存在一张在P区能找到相同Season的牌 继续游戏
            else
                self:OnPlayerChooseCard(Card, true)
                GameManager.PlayerAChoosing = true
                GameManager.PlayerAChoosingCard = Card
            end


        -- 玩家当前处于已选中一张手牌的状态
        else
            -- 如果 玩家当前记录的选择的牌 和 Card（现在被点击的牌） 是同一张牌 则取消选择
            if GameManager.PlayerAChoosingCard == Card then
                self:OnPlayerChooseCard(Card, false)
                GameManager.PlayerAChoosing = false
                GameManager.PlayerAChoosingCard = nil
            -- 如果 玩家当前记录的选择的牌 和 Card（现在被点击的牌） 不是同一张牌 则取消选择 并选择新的牌
            else
                self:ClearAllChooseState()
                self:OnPlayerChooseCard(Card, true)
                GameManager.PlayerAChoosing = true
                GameManager.PlayerAChoosingCard = Card
            end
        end
        
    -- 玩家A的回合 但是点击的是P区的卡牌
    elseif Card.CardOwner == ECardOwnerType.Public and GameManager.GameRound == EGameRound.PlayerA then
        -- 玩家当前处于已选中一张手牌的状态
        if GameManager.PlayerAChoosing then
            -- 如果 玩家当前选择的牌 和 Card（被点击P区的牌）的Season相同
            if GameManager.PlayerAChoosingCard.Season == Card.Season then
                print("玩家A拿走了一张牌：" .. Card.CardID, Card.Name, Card.Value, Card.Season)
                -- 玩家A回合结束 进入结算
                self:RoundCheck(GameManager.PlayerAChoosingCard, Card)
            end

        -- 玩家当前不处于已选中一张手牌的状态
        else
        end

    -- 玩家B的回合 并且点击的是玩家B的卡牌
    elseif Card.CardOwner == ECardOwnerType.PlayerB and GameManager.GameRound == EGameRound.PlayerB then
        -- AI模式
        if bAIMode then
            -- AI模式 AI当前不处于已选中一张手牌的状态
            if not AIPlayer.AIChoosing then
                print("AI选择自己的手牌：" .. Card.CardID, Card.Name, Card.Value, Card.Season)

                -- 玩家B手中的牌不存在在P区能找到相同Season的牌 进入弃牌重选流程
                if GameManager.PLayerBChangingCard then
                    local NewCardID = GameManager:ReturnCardToStore(Card.CardID, EPlayer.PlayerB)
                    print(string.format("AI使用 %d %s 交换了 %d %s", Card.CardID, Card.Name, NewCardID, DataManager.GetCardData(NewCardID).Name))
                    Card:SetCardID(NewCardID)
                    -- 重新检查
                    if self:CheckPlayerCardsIfCanContinue() then
                        print("AI交换牌完成，通过检查，可以继续游戏")
                        GameManager.PLayerBChangingCard = false
                        AIPlayer.AIChoosing = false
                        AIPlayer.AIChoosingCard = nil
                    else
                        print("AI交换牌完成，未通过检查，需要继续交换")
                    end
                    Timer:Add(1, function()
                        AIPlayer:DoAction()
                    end)

                -- 玩家B手中的牌至少存在一张在P区能找到相同Season的牌 继续游戏
                else
                    self:OnPlayerChooseCard(Card, true)
                    AIPlayer.AIChoosing = true
                    AIPlayer.AIChoosingCard = Card
                    GameManager.PlayerBChoosing = true
                    GameManager.PlayerBChoosingCard = Card
                    Timer:Add(1, function()
                        AIPlayer:DoAction()
                    end)
                end
            end
        else
            if not GameManager.PlayerBChoosing then
                print("玩家B选择自己的手牌：" .. Card.CardID, Card.Name, Card.Value, Card.Season)

            else
                
            end
        end

    -- 玩家B的回合 但是点击的是P区的卡牌
    elseif Card.CardOwner == ECardOwnerType.Public and GameManager.GameRound == EGameRound.PlayerB then
        -- AI模式
        if AIPlayer.bAIMode then
            -- AI当前处于已选中一张手牌的状态
            if AIPlayer.AIChoosing then
                -- 如果 AI当前选择的牌 和 Card（被点击P区的牌）的Season相同 不会让AI乱选 一定会选相同的
                if AIPlayer.AIChoosingCard.Season == Card.Season then
                    print("AI拿走了一张牌：" .. Card.CardID, Card.Name, Card.Value, Card.Season)
                    -- AI回合结束 进入结算
                    self:RoundCheck(AIPlayer.AIChoosingCard, Card)
                end
            end
        else

        end
    end
end

function UI_GameMain:CheckPlayerCardsIfCanContinue()
    if GameManager.GameRound == EGameRound.PlayerA then
        -- 遍历self.Cards_A中的所有牌
        for i = 1, #self.Cards_A do
            local Card = self.Cards_A[i]
            -- 遍历self.Cards_P中的所有牌
            for j = 1, #self.Cards_P do
                local PublicCard = self.Cards_P[j]
                -- 如果玩家A的手牌中存在一张牌 在P区能找到相同Season的牌
                if Card.Season == PublicCard.Season then
                    GameManager.UI_ChangeCardTip:HideChangeCardTip()
                    return true
                end
            end
        end
    else
        -- 遍历self.Cards_B中的所有牌
        for i = 1, #self.Cards_B do
            local Card = self.Cards_B[i]
            -- 遍历self.Cards_P中的所有牌
            for j = 1, #self.Cards_P do
                local PublicCard = self.Cards_P[j]
                -- 如果玩家B的手牌中存在一张牌 在P区能找到相同Season的牌
                if Card.Season == PublicCard.Season then
                    GameManager.UI_ChangeCardTip:HideChangeCardTip()
                    return true
                end
            end
        end
    end
    GameManager.UI_ChangeCardTip:ShowChangeCardTip()
    return false
end

function UI_GameMain:RoundCheck(PlayerCard, PublicCard)
    local Player = PlayerCard.CardOwner
    -- 记录P区的牌的位置信息
    self:SavaOldPublicCardInfo(PublicCard)
    -- 清除选中状态
    self:ClearAllChooseState()
    -- 更新玩家的分数
    GameManager:UpdatePlayerScore(PlayerCard, PublicCard)
    -- 将两张牌移动到对应玩家的牌堆
    self:MoveCardsToDeal(PlayerCard, PublicCard)
    -- 更新UI分数
    if Player == ECardOwnerType.PlayerA then
        self.Text_PlayerAScore:SetText(GameManager:GetPlayerAScore())
    elseif Player == ECardOwnerType.PlayerB then
        self.Text_PlayerBScore:SetText(GameManager:GetPlayerBScore())
    end
    -- 补充P区的牌
    self:SetNewPublicCardInfo()
    -- 设置两张牌的Owner
    if Player == ECardOwnerType.PlayerA then
        PlayerCard:SetCardOwner(ECardOwnerType.PlayerADeal)
        PublicCard:SetCardOwner(ECardOwnerType.PlayerADeal)
    else
        PlayerCard:SetCardOwner(ECardOwnerType.PlayerBDeal)
        PublicCard:SetCardOwner(ECardOwnerType.PlayerBDeal)
    end

    -- 开始检查故事展示
    self.bCheckStoryShow = true
end

function UI_GameMain:SavaOldPublicCardInfo(PublicCard)
    UI_GameMain.OldPublicCardPosition = PublicCard.Slot:GetPosition()
    UI_GameMain.OldPublicCardRenderTransformAngle = PublicCard:GetRenderTransformAngle()
    UI_GameMain.OldPublicCardAnchor = PublicCard.Slot:GetAnchors()
    UI_GameMain.OldPublicCardLayer = PublicCard.Slot:GetZOrder()
    UI_GameMain.OldPublicCardLayout = PublicCard.Slot:GetLayout()
    UI_GameMain.OldPublicCardSize = PublicCard.Slot:GetSize()
    -- 记录PublicCard是self.Cards_P的第几个
    for i = 1, #self.Cards_P do
        if self.Cards_P[i].CardID == PublicCard.CardID then
            UI_GameMain.OldPublicCardIndex = i
            break
        end
    end
end

function UI_GameMain:SetNewPublicCardInfo()
    local NewCard = MuBPFunction.CreateUserWidget("UI_Card")
    local NewPublicCardID = GameManager:GetOneCardFromStore()
    self.PublicCards:AddChild(NewCard)
    NewCard:SetVisibility(ESlateVisibility.Visible)
    NewCard:SetCardID(NewPublicCardID)
    NewCard:SetCardOwner(ECardOwnerType.Public)
    NewCard:AddOnClickEvent(MakeCallBack(self.OnCardClicked, self))
    NewCard.Slot:SetAnchors(UI_GameMain.OldPublicCardAnchor)
    NewCard.Slot:SetPosition(UI_GameMain.OldPublicCardPosition)
    NewCard.Slot:SetZorder(UI_GameMain.OldPublicCardLayer)
    NewCard.Slot:SetLayout(UI_GameMain.OldPublicCardLayout)
    NewCard.Slot:SetSize(UI_GameMain.OldPublicCardSize)
    NewCard:SetRenderTransformAngle(UI_GameMain.OldPublicCardRenderTransformAngle)
    -- 将self.Cards_P中的牌更新
    self.Cards_P[UI_GameMain.OldPublicCardIndex] = NewCard
end

function UI_GameMain:MoveCardsToDeal(PlayerCard, PublicCard)
    -- 获取Deal区的位置
    local AnimPosPlayer = nil
    local AnimPosPublic = nil
    if PlayerCard.CardOwner == ECardOwnerType.PlayerA then
        -- 获取当前Deal下面有几张牌
        local PlayerACardNum = #GameManager.PlayerADealCards
        -- 更新一下两张牌的ZOrder
        PlayerCard.Slot:SetZorder(PlayerACardNum + 1)
        PublicCard.Slot:SetZorder(PlayerACardNum + 2)

        AnimPosPlayer = self.Card_A_Deal.Slot:GetPosition()
        AnimPosPublic = self.Card_P_A_Deal.Slot:GetPosition()
        -- 趁机更新self.Cards_A 将PlayerCard从self.Cards_A中移除 并重新生成table
        local NewCards_A = {}
        local index = 1
        for key, value in pairs(self.Cards_A) do
            if value.CardID ~= PlayerCard.CardID then
                NewCards_A[index] = value
                index = index + 1
            end
        end
        self.Cards_A = NewCards_A
    else
        -- 获取当前Deal下面有几张牌
        local PlayerBCardNum = #GameManager.PlayerBDealCards
        -- 更新一下两张牌的ZOrder
        PlayerCard.Slot:SetZorder(PlayerBCardNum + 1)
        PublicCard.Slot:SetZorder(PlayerBCardNum + 2)

        AnimPosPlayer = self.Card_B_Deal.Slot:GetPosition()
        AnimPosPublic = self.Card_P_B_Deal.Slot:GetPosition()
        -- 趁机更新self.Cards_B 将PlayerCard从self.Cards_B中移除 并重新生成table
        local NewCards_B = {}
        local index = 1
        for key, value in pairs(self.Cards_B) do
            if value.CardID ~= PlayerCard.CardID then
                NewCards_B[index] = value
                index = index + 1
            end
        end
        self.Cards_B = NewCards_B
        -- 如果是AI 更新AIPlayer.Cards
        if AIPlayer.bAIMode then
            AIPlayer.Cards = self.Cards_B
            AIPlayer.PCards = self.Cards_P
        end
    end

    -- 移动到Deal区
    if PlayerCard.CardOwner == ECardOwnerType.PlayerA then
        self.PlayerACards:RemoveChild(PlayerCard)
        self.Score:AddChild(PlayerCard)
        self.PublicCards:RemoveChild(PublicCard)
        self.Score:AddChild(PublicCard)
        self:UpdateDealCardLayout(PlayerCard, self.Card_A_Deal)
        self:UpdateDealCardLayout(PublicCard, self.Card_P_A_Deal)
    elseif PlayerCard.CardOwner == ECardOwnerType.PlayerB then
        self.PlayerBCards:RemoveChild(PlayerCard)
        self.Score:AddChild(PlayerCard)
        self.PublicCards:RemoveChild(PublicCard)
        self.Score:AddChild(PublicCard)
        self:UpdateDealCardLayout(PlayerCard, self.Card_B_Deal)
        self:UpdateDealCardLayout(PublicCard, self.Card_P_B_Deal)

    end
    PlayerCard.Slot:SetPosition(AnimPosPlayer)
    PublicCard.Slot:SetPosition(AnimPosPublic)
end

function UI_GameMain:UpdateDealCardLayout(Card, AimCard)
    Card.Slot:SetAnchors(AimCard.Slot:GetAnchors())
    Card.Slot:SetZorder(AimCard.Slot:GetZOrder())
    Card.Slot:SetLayout(AimCard.Slot:GetLayout())
    Card.Slot:SetSize(AimCard.Slot:GetSize())
end

function UI_GameMain:ClearAllChooseState()
    -- 遍历Cards_A 数量不定
    for index = 1, #self.Cards_A do
        self.Cards_A[index]:ClearChooseState()
    end
    -- 遍历Cards_B
    for index = 1, #self.Cards_B do
        self.Cards_B[index]:ClearChooseState()
    end
    -- 遍历Cards_P
    for index = 1, 8 do
        self.Cards_P[index]:ClearChooseState()
    end

end

function UI_GameMain:OnPlayerChooseCard(Card, bChoosing)
    -- 遍历Cards_P找到Season相同的卡牌
    local bFind = false
    for index = 1, 8 do
        if self.Cards_P[index].Season == Card.Season then
            self.Cards_P[index]:SetChooseState(bChoosing, true)
            bFind = true
        end
    end
    Card:SetChooseState(bChoosing, true)
end

function UI_GameMain:OnPlayerAStoryDetailClick()
    local UI_PlayerStories = MuBPFunction.CreateUserWidget("UI_PlayerStories")
    UI_PlayerStories:UpdatePlayerStoryStates(EPlayer.PlayerA)

end

function UI_GameMain:InitSpecialCards()
    local SpecialCardsNum = #GameManager.PlayerASpecialCards
    print("特殊牌数量：" .. SpecialCardsNum)
    local MaxXOffset = self.CanvasPanel_PlayerASpecialCards.Slot:GetSize().X - 256
    local XOffset = MaxXOffset / (SpecialCardsNum - 1)
    -- 创建所有的特殊牌
    for key, value in pairs(GameManager.PlayerASpecialCards) do
        local NewCard = MuBPFunction.CreateUserWidget("UI_Card")
        NewCard:SetCardID(value.CardID)
        NewCard:SetCardOwner(ECardOwnerType.PlayerASpecial)
        self.CanvasPanel_PlayerASpecialCards:AddChild(NewCard)
        NewCard:SetVisibility(ESlateVisibility.HitTestInvisible)
        NewCard.Slot:SetAutoSize(true)
        local Pos = NewCard.Slot:GetPosition()
        Pos.X = (key - 1) * XOffset
        NewCard.Slot:SetPosition(Pos)
    end
end

function UI_GameMain:OnDestroy()
    -- body
end

return Class(nil, nil, UI_GameMain)
