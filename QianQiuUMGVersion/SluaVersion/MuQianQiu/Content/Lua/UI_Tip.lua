require("Global")

local UI_Tip = {}

function UI_Tip:Initialize()

end

function UI_Tip:ShowTip(TipText)
    self.Text_Tip:SetText(TipText)
    self:PlayAnimationForward(self.Show, 1.0, false)
end

function UI_Tip:OnDestroy()
    
end

return Class(nil, nil, UI_Tip)