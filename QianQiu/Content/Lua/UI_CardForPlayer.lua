require "Global"


local UI_CardForPlayer = {}

function UI_CardForPlayer:Initialize()
    -- 卡牌点击
    -- self.Button_Card.OnClicked:Add(self.OnCardClick)
    -- -- 鼠标经过
    -- self.Button_Card.OnHovered:Add(self.OnCardHovered)
    -- -- 鼠标离开
    -- self.Button_Card.OnUnhovered:Add(self.OnCardUnHovered)

    self.bChoose = false
end

function UI_CardForPlayer:Construct()
    self.Button_Card.OnClicked:Add(self.OnCardClick)
end

function UI_CardForPlayer:UpdateSelf(param)
    self.UI_Card:UpdateSelf(param)
end

function UI_CardForPlayer:OnCardClick()
    local self = UI_CardForPlayer
    if self.bCan then
        if self.bChoose then
            self.bChoose = false
            self.UI_Card:PlayUnchooseAnimation()
        else
            -- CommandMap:DoCommand(CommandList.EnsureJustOneCardChoose, self.ID)
            -- CommandMap:DoCommand(CommandList.OnPlayerCardChoose, self.ID)
            self.bChoose = true
            self.UI_Card:PlayChooseAnimation()
            UIStack:PushUIByName("UI_CardDetail", self.ID)
        end
    else
    end
end

function UI_CardForPlayer:OnDestroy()
end

return UI_CardForPlayer
