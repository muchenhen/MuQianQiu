require("Global")

local UI_CardDetail = {}

function UI_CardDetail:Initialize()

end

function UI_CardDetail:SetCardID(CardID)
    local CardInfo = DataManager.GetCardData(CardID)
    self.CardID = CardInfo.CardID
    self.CardName = CardInfo.Name
    self.Season = CardInfo.Season
    self.Value = CardInfo.Value
    self.bSpecial = CardInfo.Special
    self.SpecialName = CardInfo.SpecialName
    self.SkillOneID = CardInfo.EffectFirst
    self.SkillOneParam = CardInfo.ParamFirst
    self.SkillTwoID = CardInfo.EffectSecond
    self.SkillTwoParam = CardInfo.ParamSecond

    self.UI_Card:SetCardID(self.CardID)

    self.RelativeCardNames = self:GetRelativeCardNames(self.CardID)
    self.StoryNames = self:GetStoryNames(self.CardID)
    self.SkillOneDesc = self:GetSkillDesc(self.SkillOneID, self.SkillOneParam)
    self.SkillTwoDesc = self:GetSkillDesc(self.SkillTwoID, self.SkillTwoParam)

    self.Text_CardName:SetText(self.CardName)
    self.Text_CardSeason:SetText(self.Season)
    self.Text_CardValue:SetText(self.Value)
end

function UI_CardDetail:GetRelativeCardNames(CardID)
    local RelativeCardNames = {}

    return RelativeCardNames
end

function UI_CardDetail:GetStoryNames(CardID)
    local StoryNames = {}

    return StoryNames
end

function UI_CardDetail:GetSkillDesc(SkillID, SkillParam)
    local SkillDesc = ""

    return SkillDesc
end

function UI_CardDetail:OnDestroy()

end

return Class(nil, nil, UI_CardDetail)