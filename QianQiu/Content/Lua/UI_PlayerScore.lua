require "Global"

local UI_PlayerScore = {}

function UI_PlayerScore:Construct()
    CommandMap:AddCommand("UpdatePlayerScore", self, self.UpdatePlayerScore)
end

function UI_PlayerScore:Initialize()
    self.Text_EnemyPoint:SetText(0)
    self.Text_PlayerPoint:SetText(0)
    self.playerScore = 0
    self.enemyScore = 0
end

function UI_PlayerScore:UpdatePlayerScore(param)
    local playerChooseID = param.PlayerChooseID
    local playChooseCard = Cards[playerChooseID]
    local playerChooseScore = playChooseCard.Value
    local playerHaveID = param.PlayerHaveID
    local playerHaveCard = Cards[playerHaveID]
    local playerHaveScore = playerHaveCard.Value
    local score = playerChooseScore + playerHaveScore
    self.Text_PlayerPoint:SetText(self.playerScore + score)
end

return UI_PlayerScore