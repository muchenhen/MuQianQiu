require("Global")

local UI_Card = {}

function UI_Card:Initialize()
    self.Button.OnClicked:Add(MakeCallBack(self.OnClick, self))
end

function UI_Card:SetCardID(CardID)
    self.CardID = CardID
    self:InitTexture()
end

function UI_Card:OnClick()
    if self.OnClickEvent then
        self:OnClickEvent(self)
    end
end

function UI_Card:AddOnClickEvent(callback)
    self.OnClickEvent = callback
end

function UI_Card:OnDestroy()
    -- body
end


return Class(nil, nil, UI_Card)