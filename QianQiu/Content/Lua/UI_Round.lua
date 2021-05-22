require "Global"
local UI_Round = {}

function UI_Round:Construct()

end

function UI_Round:Initialize()
    self:PlayAnimation(self.ShowIn, 0, 1, 0, 1, false)
end

function UI_Round:OnAnimationFinished(anim)
    if anim == self.ShowIn then
        UIStack:PopUIByName("UI_Round")
    elseif anim == self.ShowOut then
        if not self.bCan then
            UIStack:PushUIByName("UI_StaticTip")
            local param = {
                bCan = false
            }
            CommandMap:DoCommand(CommandList.SetAllCardsbCanPlayer, param)
        else
            if self.round%2 == 1 then
                Enemy.Basic:Action()
            end
        end
        self:RemoveFromParent()
    end
end

function UI_Round:OnDestroy()

end

function UI_Round:UpdateSelf(param)
    self.round = param.round
    self.Text_Round:SetText(param.text)
    self.bCan = param.bCan
end

return UI_Round