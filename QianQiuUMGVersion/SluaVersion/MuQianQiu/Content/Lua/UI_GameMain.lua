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
        self.Cards_P[index]:SetCardOwner(ECardOwnerType.PlayerP)
        self.Cards_P[index]:AddOnClickEvent(MakeCallBack(self.OnCardClicked, self))
    end

    self:PlayAnimationForward(self.InitAnim, 1.0, false)
    self:SetVisibility(ESlateVisibility.Visible)
end

function UI_GameMain:OnCardClicked(Card)
    print(Card.CardID, Card.Name, Card.Value, Card.Season)

    -- 玩家A的回合 并且点击的是玩家A的卡牌
    if Card.CardOwner == ECardOwnerType.PlayerA and GameManager.GameRound == EGameRound.PlayerA then
        -- 播放动画
        Card:PlayChooseAnim()
        self:OnPlayerChooseCard(Card)

    elseif  Card.CardOwner == ECardOwnerType.PlayerB and GameManager.GameRound == EGameRound.PlayerB then
        Card:PlayChooseAnim()
    end
        
end

function UI_GameMain:OnPlayerChooseCard(Card)
    -- 遍历Cards_P找到Season相同的卡牌
    for index = 1, 8 do
        if self.Cards_P[index].Season == Card.Season then
            self.Cards_P[index]:PlayChooseAnim()
        end
    end
end

function UI_GameMain:OnDestroy()
    -- body
end


return Class(nil, nil, UI_GameMain)
