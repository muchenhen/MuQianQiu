require "Global"

local UI_GameResult = {}

function UI_GameResult:Construct()
    self.Button_More.OnClicked:Add(self.OnMoreClick)
    self.Button_Restart.OnClicked:Add(self.OnRestartClick)
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

function UI_GameResult:OnMoreClick()
    UIStack:PopUIByName("UI_GameResult")
    Reset()
    CommandMap:DoCommand(CommandList.UIMainReset)
end

function UI_GameResult:OnRestartClick()
    UIStack:PopUIByName("UI_GameResult")
    Reset()
    CommandMap:DoCommand(CommandList.UIStartRestart)
end

function UI_GameResult:OnDestroy()

end

return UI_GameResult