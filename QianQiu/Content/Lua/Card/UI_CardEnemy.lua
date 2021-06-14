local UI_CardEnemy = {}

function UI_CardEnemy:Construct()
end

function UI_CardEnemy:Initialize()
end

function UI_CardEnemy:UpdateSelf(cardID)
    self.ID = cardID
    self.UI_Card:UpdateSelf(cardID)
    if bEnemyDark then
        self.Img_Back:SetVisibility(ESlateVisibility.HitTestInvisible)
    else
        self.Img_Back:SetVisibility(ESlateVisibility.Collapsed)
    end
end

function UI_CardEnemy:OnDestroy()
end

return UI_CardEnemy
