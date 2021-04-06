require "Global"

local UI_CardHeal = {}

function UI_CardHeal:Construct()
    self.owner = ECardOwner.Player
    self.cards = {}
end

function UI_CardHeal:Initialize()

end

function UI_CardHeal:UpdateSelf()

end

function UI_CardHeal:SetOwner(owner)
    self.owner = owner
end

return UI_CardHeal