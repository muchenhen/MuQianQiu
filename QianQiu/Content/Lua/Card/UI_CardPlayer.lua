local UI_CardPlayer = {}

function UI_CardPlayer:Construct()
    self.Button_Player.OnClicked:Add(self.OnCardClick)
end

function UI_CardPlayer:Initialize()
    self.state = ECardState.UnChoose

end

function UI_CardPlayer:UpdateSelf(cardID)
    self.ID = cardID
    self.UI_Card:UpdateSelf(cardID)
end

function UI_CardPlayer:OnCardClick()
    local self = UI_CardPlayer
    self:ChangeChooseState()
    CommandMap:DoCommand("SetChooseCardID", self.ID)
end

function UI_CardPlayer:ChangeChooseState()
    local self = UI_CardPlayer
    if self.state == ECardState.Choose then
        PlayAnim(self, "Unchoose", true)
        self.state = ECardState.UnChoose
    elseif self.state == ECardState.UnChoose then
        PlayAnim(self, "Choose", true)
        self.state = ECardState.Choose
    end
end

function UI_CardPlayer:OnDestroy()
end

return UI_CardPlayer
