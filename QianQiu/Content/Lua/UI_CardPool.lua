require "Global"

local UI_CardPool = {}

function UI_CardPool:Construct()
    self:PlayAnimation(self.ShowIn, 0, 1, 0, 1, false)
end

return UI_CardPool