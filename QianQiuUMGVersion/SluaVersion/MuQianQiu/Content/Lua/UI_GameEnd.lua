require("Global")

local UI_GameEnd = {}

function UI_GameEnd:Initialize()

end

function UI_GameEnd:Construct()
    self.Button_Return.OnClicked:Add(MakeCallBack(self.OnReturnClick, self))
    self.Button_ReStart.OnClicked:Add(MakeCallBack(self.OnReStartClick, self))
end

function UI_GameEnd:OnReStartClick()
    GameManager.UI_GameMain:RemoveFromParent()
    GameManager:GameStart()
    local UI_GameMain = MuBPFunction.CreateUserWidget("UI_GameMain")
    UI_GameMain:AddToViewport(0)
    self:RemoveFromParent()
end

function UI_GameEnd:OnReturnClick()
    GameManager.UI_GameMain:RemoveFromParent()
    GameManager.UI_GameStart:SetVisibility(ESlateVisibility.Visible)
    self:RemoveFromParent()
end

function UI_GameEnd:SetWinner(Player, Score)
    self.Text_PlayerScore:SetText(Score)
    if Player == EPlayer.PlayerA then
        self.Text_Winner:SetText("你赢了！")
        self.Text_Winner:SetColorAndOpacity(self.TextWinColor)
        self.Text_PlayerScore:SetColorAndOpacity(self.TextWinColor)
    elseif Player == EPlayer.PlayerB then
        self.Text_Winner:SetText("你输了")
        self.Text_Winner:SetColorAndOpacity(self.TextLoseColor)
        self.Text_PlayerScore:SetColorAndOpacity(self.TextLoseColor)
    elseif Player == nil then
        self.Text_Winner:SetText("平局")
        self.Text_Winner:SetColorAndOpacity(self.TextDrawColor)
        self.Text_PlayerScore:SetColorAndOpacity(self.TextDrawColor)
    end
end

function UI_GameEnd:OnDestroy()
    -- body
end

return Class(nil, nil, UI_GameEnd)