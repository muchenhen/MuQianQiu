require "Global"

local UI_GameResult = {}

function UI_GameResult:Construct()

end

function UI_GameResult:Initialize()
    self:PlayAnimation(self.ShowIn, 0, 1, 0, 1, false)
end

function UI_GameResult:UpdateSelf(param)
    local result
    if param.playerScore > param.enemyScore then
        result = EResult.Win
    elseif param.playerScore < param.enemyScore then
        result = EResult.Fail
    else
        result = EResult.Draw
    end
    local text
    if result == EResult.Win then
        text = "胜利"
        self.Text_Result:SetColorAndOpacity(self.WinColor)
        self.Text_Score:SetColorAndOpacity(self.WinColor)
    elseif result == EResult.Fail then
        text = "失败"
        self.Text_Result:SetColorAndOpacity(self.FailColor)
        self.Text_Score:SetColorAndOpacity(self.FailColor)
    elseif result == EResult.Draw then
        text = "平局"
        self.Text_Result:SetColorAndOpacity(self.DrawColor)
        self.Text_Score:SetColorAndOpacity(self.DrawColor)
    end
    self.Text_Result:SetText(text)
    self.Text_Score:SetText(param.playerScore)
end

return UI_GameResult