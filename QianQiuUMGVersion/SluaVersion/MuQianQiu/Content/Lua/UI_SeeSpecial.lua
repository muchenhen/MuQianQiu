require("Global")

local UI_SeeSpecial = {}

function UI_SeeSpecial:Initialize()
    self.Button_Close.OnClicked:Add(MakeCallBack(self.OnButtonCloseClick, self))

    for i=1, 10 do
        local UI_Card = self["UI_Card_"..string.format("%02d", i)]
        UI_Card:SetVisibility(ESlateVisibility.Hidden)
    end

    for i=1, #GameManager.PlayerASpecialCards do
        local CardData = GameManager.PlayerASpecialCards[i]
        local UI_Card = self["UI_Card_"..string.format("%02d", i)]
        UI_Card:SetCardID(CardData.CardID)
        UI_Card:SetVisibility(ESlateVisibility.Visible)
    end
end

function UI_SeeSpecial:OnButtonCloseClick()
    self:RemoveFromParent()
end

function UI_SeeSpecial:Construct()

end

function UI_SeeSpecial:OnDestroy()
end

return Class(nil, nil, UI_SeeSpecial)