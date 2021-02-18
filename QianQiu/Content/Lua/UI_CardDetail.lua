require "Global"

local UI_CardDetail = {}

function UI_CardDetail:Initialize()

end

function UI_CardDetail:Construct()

end

function UI_CardDetail:UpdateSelf(param)
    self.UI_Card:UpdateSelf(param)
end

function UI_CardDetail:PlayShowIn()
    self:PlayAnimation(self.ShowIn, 0, 1, 0, 1, false)
    print("DetailShowIn")
end

function UI_CardDetail:PlayShowOut()
    self:PlayAnimation(self.ShowOut, 0, 1, 0, 1, false)
    print("DetailShowOut")
end

return UI_CardDetail