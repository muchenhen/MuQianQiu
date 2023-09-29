require("Global")

local UI_Card = {}

function UI_Card:Initialize()
    self.Button.OnClicked:Add(MakeCallBack(self.OnClick, self))
    self.bChoosed = false
end

function UI_Card:SetCardID(CardID)
    self.CardID = CardID
    self:InitTexture()
    local CardInfo = DataManager.GetCardData(CardID)
    self.Name = CardInfo.Name
    self.Value = CardInfo.Value
    self.Season = CardInfo.Season
    self.SpecialName = CardInfo.SpecialName
    self.Special = CardInfo.Special
end

function UI_Card:SetSpecialCardID(SepcialCardID)
    self.CardID = SepcialCardID
    self:InitTexture()
    local CardInfo = DataManager.GetCardData(SepcialCardID)
    self.Name = CardInfo.Name
    self.Value = CardInfo.Value
    self.Season = CardInfo.Season
    self.SpecialID = CardInfo.SepcialCardID
    self.CardID = CardInfo.SpecialName
    self.Special = CardInfo.Special
end

function UI_Card:SetCardOwner(Owner)
    self.CardOwner = Owner
end

function UI_Card:OnClick()
    if self.OnClickEvent then
        self:OnClickEvent(self)
    end
end

function UI_Card:AddOnClickEvent(callback)
    self.OnClickEvent = callback
end

function UI_Card:PlayChooseAnim()
    if self.bChoosed then
        self:PlayAnimationReverse(self.ChooseAnim, 1.0, false)
        self.bChoosed = false
    else
        self:PlayAnimationForward(self.ChooseAnim, 1.0, false)
        self.bChoosed = true
    end
end

function UI_Card:SetChooseState(bChoosing, bAnim)
    if bChoosing then
        self.bChoosed = true
        if bAnim then
            self:PlayAnimationForward(self.ChooseAnim, 1.0, false)
        end
        self.Image_Choosed:SetVisibility(ESlateVisibility.HitTestInvisible)
    else
        self.bChoosed = false
        if bAnim then
            self:PlayAnimationReverse(self.ChooseAnim, 1.0, false)
        end
        self.Image_Choosed:SetVisibility(ESlateVisibility.Hidden)
    end
end

function UI_Card:ClearChooseState()
    if self.bChoosed then
        self:PlayAnimationReverse(self.ChooseAnim, 1.0, false)
        self.Image_Choosed:SetVisibility(ESlateVisibility.Hidden)
        self.bChoosed = false
    end
end

function UI_Card:OnDestroy()
    -- body
end


return Class(nil, nil, UI_Card)