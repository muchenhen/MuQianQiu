require("Global")
local Card = require("UI_Card")

local UI_GameMain = {}

function UI_GameMain:Initialize()
    self:SetVisibility(ESlateVisibility.Hidden)
    self:OnInit()
end

function UI_GameMain:OnInit()
    -- 清理分数
    self.Text_PlayerAScore:SetText(GameManager:GetPlayerAScore())
    self.Text_PlayerBScore:SetText(GameManager:GetPlayerBScore())

    -- 设置每一边的卡牌ID
    -- A01-A10
    for index = 1, 10 do
        self["Card_A" .. string.format("%02d", index)]:SetCardID(GameManager:GetOneCardFromStore())
    end
    -- B01-B10
    for index = 1, 10 do
        self["Card_B" .. string.format("%02d", index)]:SetCardID(GameManager:GetOneCardFromStore())
    end
    -- P01-P08
    for index = 1, 8 do
        self["Card_P" .. string.format("%02d", index)]:SetCardID(GameManager:GetOneCardFromStore())
    end


    self:PlayAnimationForward(self.InitAnim, 1.0, false)
    self:SetVisibility(ESlateVisibility.Visible)
    -- 绑定所有卡的点击回调
    -- A01-A10
    for index = 1, 10 do
        self["Card_A" .. string.format("%02d", index)]:AddOnClickEvent(self.OnCardClicked)
    end
    -- B01-B10
    for index = 1, 10 do
        self["Card_B" .. string.format("%02d", index)]:AddOnClickEvent(self.OnCardClicked)
    end
    -- P01-P08
    for index = 1, 8 do
        self["Card_P" .. string.format("%02d", index)]:AddOnClickEvent(self.OnCardClicked)
    end
end

function UI_GameMain:OnCardClicked(Card)
    print(Card.CardID)
end

function UI_GameMain:OnDestroy()
    -- body
end


return Class(nil, nil, UI_GameMain)
