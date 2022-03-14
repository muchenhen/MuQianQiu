require "Global"

local UI_HealCards = {}

function UI_HealCards:Initialize()
    for i = 1, 20 do
        self["UI_Card_" .. i]:SetVisibility(ESlateVisibility.Collapsed)
    end
end

function UI_HealCards:UpdateHealHaveCards(cards)
    for i = 1, #cards do
        self["UI_Card_" .. i]:SetVisibility(ESlateVisibility.HitTestInvisible)
        self["UI_Card_" .. i]:UpdateSelf(cards[i])
    end
end

function UI_HealCards:OnDestroy()
end

return UI_HealCards
