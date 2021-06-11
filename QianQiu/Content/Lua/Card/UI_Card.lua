local UI_Card = {}

function UI_Card:Construct()
end

function UI_Card:Initialize()
end

function UI_Card:UpdateSelf(cardID)
    self.ID = cardID
    local cardType = Table.Cards[self.ID].Type
    local texturePath = cardType .. "/" .. Table.Cards[self.ID].Texture
    local imgCard = LoadObject(UI_TEXTURE_PATH .. texturePath)
    self.Img_Card:SetBrushFromTexture(imgCard, false)
    self.season = Table.Cards[self.ID].Season -- 卡面属性
    self.value = Table.Cards[self.ID].Value -- 卡片分数
    self.bSpecial = (Table.Cards[self.ID].Special == 1) -- 是否是特殊卡
end

function UI_Card:ChangeChooseState()

end

function UI_Card:OnDestroy()
end

return UI_Card
