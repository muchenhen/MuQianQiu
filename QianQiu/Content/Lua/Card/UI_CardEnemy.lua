local UI_CardEnemy = {}

function UI_CardEnemy:Construct()
    
end

function UI_CardEnemy:Initialize()
    
end

function UI_CardEnemy:UpdateSelf(cardID)
    self.ID = cardID
    self.UI_Card:UpdateSelf(cardID)
end

function UI_CardEnemy:OnDestroy()
    
end

return UI_CardEnemy