require "Global"

local UI_CardDetail = {}

function UI_CardDetail:Initialize()

end

function UI_CardDetail:Construct()
    CommandMap:AddCommand("CardDetailPlayShowIn", self, self.PlayShowIn)
    CommandMap:AddCommand("CardDetailPlayShowOut", self, self.PlayShowOut)
end

function UI_CardDetail:UpdateSelf(param)
    self.UI_Card:UpdateSelf(param)
    self.Text_Score:SetText("基础分值：" .. param.score)
end

function UI_CardDetail:PlayShowIn(param)
    self:PlayAnimation(self.ShowIn, 0, 1, 0, 1, false)
    self:UpdateSelf(param)
    print("DetailShowIn")
end

function UI_CardDetail:PlayShowOut()
    self:PlayAnimation(self.ShowOut, 0, 1, 0, 1, false)
    print("DetailShowOut")
end

return UI_CardDetail