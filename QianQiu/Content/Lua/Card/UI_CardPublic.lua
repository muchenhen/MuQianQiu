local UI_CardPlayer = {}

function UI_CardPlayer:Construct()
    self.Button_Public.OnClicked:Add(self.OnCardClick)
    CommandMap:AddCommand("PlayerTryToChoose", self, self.PlayerTryToChoose)
end

function UI_CardPlayer:Initialize()
    self.state = ECardState.UnChoose
    self.bClick = false
    self.bCanTake = false -- 当前玩家有没有选择任何一张卡
end

function UI_CardPlayer:UpdateSelf(cardID)
    self.ID = cardID
    self.UI_Card:UpdateSelf(cardID)
end

function UI_CardPlayer:OnCardClick()
    local self = UI_CardPlayer
    if self.bClick then
        CommandMap:DoCommand("PlayerChooseOneCard", self.ID)
    end
end

function UI_CardPlayer:PlayerTryToChoose(cardID)
    if cardID then
        local cardSeanson = Table.Cards[cardID].Season
        local season = Table.Cards[self.ID].Season
        if cardSeanson == season then
            if self.state == ECardState.UnChoose then
                PlayAnim(self, "Choose", true)
                self.state = ECardState.Choose
                self.bClick = true
            end
        else
            if self.state == ECardState.Choose then
                PlayAnim(self, "Unchoose", true)
                self.state = ECardState.UnChoose
                self.bClick = false
            end
        end
    end
end

function UI_CardPlayer:ChangeChooseState()
    local self = UI_CardPlayer
    if self.state == ECardState.Choose then
        PlayAnim(self, "Unchoose", true)
        self.state = ECardState.UnChoose
        self.bClick = false
    elseif self.state == ECardState.UnChoose then
        PlayAnim(self, "Choose", true)
        self.state = ECardState.Choose
        self.bClick = true
    end
end

function UI_CardPlayer:OnDestroy()
end

return UI_CardPlayer
