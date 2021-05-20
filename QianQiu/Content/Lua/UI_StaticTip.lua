require "Global"

local UI_StaticTip = {}

function UI_StaticTip:Initialize()
    self:PlayAnimation(self.ShowIn, 0, 1, 0, 1, false)
end

return UI_StaticTip