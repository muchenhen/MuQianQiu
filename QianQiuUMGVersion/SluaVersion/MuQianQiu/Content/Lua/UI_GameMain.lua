require("Global")
local Card = require("UI_Card")

local UI_GameMain = {}

UI_GameMain.Cards_A = {}
UI_GameMain.Cards_B = {}
UI_GameMain.Cards_P = {}

function UI_GameMain:Initialize()
    self:SetVisibility(ESlateVisibility.Hidden)

    -- Card实例加到对应的table里 需要数字做索引
    for index = 1, 10 do
        self.Cards_A[index] = self["Card_A" .. string.format("%02d", index)]
        self.Cards_B[index] = self["Card_B" .. string.format("%02d", index)]
        self.Cards_P[index] = self["Card_P" .. string.format("%02d", index)]
    end

    self:OnInit()
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

    self:PlayAnimationForward(self.InitAnim, 1.0, false)
    self:SetVisibility(ESlateVisibility.Visible)
end

function UI_GameMain:OnCardClicked(Card)
    print(Card.CardID, Card.Name, Card.Value, Card.Season)

    -- 玩家A的回合 并且点击的是玩家A的卡牌
    if Card.CardOwner == ECardOwnerType.PlayerA and GameManager.GameRound == EGameRound.PlayerA then
        Card:PlayChooseAnim()
        -- 玩家当前不处于已选中一张手牌的状态
        if not GameManager.PlayerAChoosing then
            self:OnPlayerChooseCard(Card, true)
            GameManager.PlayerAChoosing = true
            GameManager.PlayerAChoosingCard = Card
        -- 玩家当前处于已选中一张手牌的状态
        else
            self:OnPlayerChooseCard(Card, false)
            GameManager.PlayerAChoosing = false
            GameManager.PlayerAChoosingCard = nil
        end
    -- 玩家B的回合 并且点击的是玩家B的卡牌
    elseif Card.CardOwner == ECardOwnerType.PlayerB and GameManager.GameRound == EGameRound.PlayerB then
        Card:PlayChooseAnim()
    -- 玩家A的回合 但是点击的是P区的卡牌
    elseif Card.CardOwner == ECardOwnerType.Public and GameManager.GameRound == EGameRound.PlayerA then
        -- 玩家当前处于已选中一张手牌的状态
        if GameManager.PlayerAChoosing then
            -- 如果 玩家当前选择的牌 和 Card（被点击P区的牌）的Season相同
            if GameManager.PlayerAChoosingCard.Season == Card.Season then
                -- 将两张牌移动到玩家A的牌堆
                print(self.Card_A_Deal.Slot:GetPosition())
                print(self.Card_A_Deal.Slot:GetSize())
                print(self.Card_A_Deal.Slot)

                -- 更新玩家A的分数

                -- 补充P区的牌

                -- 切换到玩家B的回合
            end

        -- 玩家当前不处于已选中一张手牌的状态
        else
        end
    end
end

function UI_GameMain:OnPlayerChooseCard(Card, bChoosing)
    -- 遍历Cards_P找到Season相同的卡牌
    for index = 1, 8 do
        if self.Cards_P[index].Season == Card.Season then
            self.Cards_P[index]:PlayChooseAnim()
            if bChoosing then
                Card.Image_Choosed:SetVisibility(ESlateVisibility.HitTestInvisible)
                self.Cards_P[index].Image_Choosed:SetVisibility(ESlateVisibility.HitTestInvisible)
            else
                Card.Image_Choosed:SetVisibility(ESlateVisibility.Hidden)
                self.Cards_P[index].Image_Choosed:SetVisibility(ESlateVisibility.Hidden)
            end
        end
    end
end

function UI_GameMain:OnDestroy()
    -- body
end

return Class(nil, nil, UI_GameMain)
