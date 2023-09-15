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

    self.RelativeCardNames = self:GetRelativeCardNames(self.SpecialName)
    self.StoryNames = self:GetStoryNames(self.CardID)
    self.SkillOneDesc = self:GetSkillDesc(self.SkillOneID, self.SkillOneParam)
    self.SkillTwoDesc = self:GetSkillDesc(self.SkillTwoID, self.SkillTwoParam)

    self.Text_CardName:SetText(self.CardName)
    self.Text_CardSeason:SetText(self.Season)
    self.Text_CardValue:SetText(self.Value)
    self.Text_RelativeCard:SetText(self.RelativeCardNames)
end

function UI_CardDetail:GetRelativeCardNames(CardID)
    local RelativeCardNames = {}

    local AllStories = GameManager.AllStory
    for key, value in pairs(AllStories) do
        local CardsName = value.Story.CardsName
        local CardsID = value.Story.CardsID
        -- CardsID中是否包含CardID
        for i=0, CardsID:Num()-1 do
            if CardsID:Get(i) == CardID then
                -- 将CardsName中的所有卡牌名字加入RelativeCardNames (不重复)
                for j=0, CardsName:Num()-1 do
                    local bExist = false
                    for k=1, #RelativeCardNames do
                        if RelativeCardNames[k] == CardsName:Get(j) then
                            bExist = true
                            break
                        end
                    end
                    if not bExist then
                        table.insert(RelativeCardNames, CardsName:Get(j))
                    end
                end
            end
        end
    end

    local RelativeCardNameString = ""
    for i=1, #RelativeCardNames do
        RelativeCardNameString = RelativeCardNameString .. RelativeCardNames[i] .. " "
    end

    return RelativeCardNameString
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