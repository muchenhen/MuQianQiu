local WBL = import("WidgetBlueprintLibrary")
require "Global"

local UI_Card = {}

function UI_Card:Initialize()

end

function UI_Card:Construct()
    self.state = ECardState.UnChoose

    -- 卡牌点击
    self.Button_Card.OnClicked:Add(function()
        if self.state == ECardState.UnChoose then
            
            self.state = ECardState.Choose
            print("Chosse card")
        elseif self.state == ECardState.Choose then
            
            self.state = ECardState.UnChoose
            print("Unchose card")
        end
    end)
    self.Button_Card.OnHovered:Add(function ()
        self:PlayAnimation(self.PlayerHovered, 0, 1, 0, 1, false)
        print("OnUnHovered card")
    end)
    -- self:BindDelegate(self.Button_Card.OnHovered, MakeCallBack(self.Hovered, self))
    self.Button_Card.OnUnhovered:Add(function ()
        self:PlayAnimation(self.PlayUnChoose, 0, 1, 0, 1, false)
        print("OnUnHovered card")
    end)
end

function UI_Card:Hovered()
    self:PlayAnimation(self.PlayerHovered, 0, 1, 0, 1, false)
    print("OnHovered card")
end

return UI_Card