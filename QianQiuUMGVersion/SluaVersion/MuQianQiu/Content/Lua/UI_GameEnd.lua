require("Global")

local UI_GameEnd = {}

function UI_GameEnd:Initialize()

end

function UI_GameEnd:SetWinner(Player, Score)
    self.Text_PlayerScore:SetText(Score)
    if Player == EPlayer.PlayerA then
        self.Text_Winner:SetText("你赢了！")
        self.Text_Winner:SetColorAndOpacity(self.TextWinColor)
        self.Text_PlayerScore:SetColorAndOpacity(self.TextWinColor)
    else
        self.Text_Winner:SetText("你输了")
        self.Text_Winner:SetColorAndOpacity(self.TextLoseColor)
        self.Text_PlayerScore:SetColorAndOpacity(self.TextLoseColor)
    end
end

function UI_GameEnd:OnDestroy()
    -- body
end

return Class(nil, nil, UI_GameEnd)