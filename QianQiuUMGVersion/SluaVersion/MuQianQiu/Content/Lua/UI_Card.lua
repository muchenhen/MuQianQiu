require("Global")

local UI_Card = {}

function UI_Card:Initialize()

end

function UI_Card:SetCardID(CardID)
    self.CardID = CardID
    self:InitTexture()
end

return Class(nil, nil, UI_Card)