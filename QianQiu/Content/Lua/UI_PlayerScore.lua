require "Global"

local UI_PlayerScore = {}

function UI_PlayerScore:Construct()
    CommandMap:AddCommand("UpdatePlayerScore", self, self.UpdatePlayerScore)
    CommandMap:AddCommand("UpdateEnemyScore", self, self.UpdateEnemyScore)
end

function UI_PlayerScore:Initialize()
    self.Text_EnemyPoint:SetText(0)
    self.Text_PlayerPoint:SetText(0)
    self.playerScore = 0
    self.enemyScore = 0
end

function UI_PlayerScore:UpdatePlayerScore(param)
    if param.PlayerChooseID then
        local playerChooseID = param.PlayerChooseID
        local playChooseCard = Cards[playerChooseID]
        local playerChooseScore = playChooseCard.Value
        local playerHaveID = param.PlayerHaveID
        local playerHaveCard = Cards[playerHaveID]
        local playerHaveScore = playerHaveCard.Value
        local score = playerChooseScore + playerHaveScore
        self.Text_PlayerPoint:SetText(tostring(self.playerScore + score))
        print("分数更新 ", "旧分数：", self.playerScore, "新分数：", self.playerScore + score)
        self.playerScore = self.playerScore + score
    elseif param.Score then
        local score = param.Score
        self.Text_PlayerPoint:SetText(tostring(self.playerScore + score))
        print("分数更新 ", "旧分数：", self.playerScore, "新分数：", self.playerScore + score)
        self.playerScore = self.playerScore + score
    end
end

function UI_PlayerScore:UpdateEnemyScore(param)
    if param.EnemyChooseID then
        local playerChooseID = param.EnemyChooseID
        local playChooseCard = Cards[playerChooseID]
        local playerChooseScore = playChooseCard.Value
        local playerHaveID = param.EnemyHaveCard
        local playerHaveCard = Cards[playerHaveID]
        local playerHaveScore = playerHaveCard.Value
        local score = playerChooseScore + playerHaveScore
        self.Text_EnemyPoint:SetText(tostring(self.enemyScore + score))
        print("分数更新 ", "旧分数：", self.enemyScore, "新分数：", self.enemyScore + score)
        self.enemyScore = self.enemyScore + score
    elseif param.Score then
        local score = param.Score
        self.Text_EnemyPoint:SetText(tostring(self.enemyScore + score))
        print("分数更新 ", "旧分数：", self.enemyScore, "新分数：", self.enemyScore + score)
        self.enemyScore = self.enemyScore + score
    end

end

return UI_PlayerScore