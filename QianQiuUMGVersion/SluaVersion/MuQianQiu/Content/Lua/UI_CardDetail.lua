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
    -- TArray<int>
    self.SkillsID = CardInfo.SkillsID

    self.UI_Card:SetCardID(self.CardID)

    self.RelativeCardNames, self.StoryNames = self:GetRelative(self.SpecialName)

    self.Text_CardName:SetText(self.CardName)
    self.Text_CardSeason:SetText(self.Season)
    self.Text_CardValue:SetText(self.Value)
    self.Text_RelativeCard:SetText(self.RelativeCardNames)
    self.Text_Stories:SetText(self.StoryNames)

    self:UpdateSkillInfo()
end

function UI_CardDetail:GetRelative(CardID)
    local RelativeCardNames = {}
    local RelativeStories = {}

    local AllStories = GameManager.AllStory
    for key, value in pairs(AllStories) do
        local CardsName = value.Story.CardsName
        local CardsID = value.Story.CardsID
        -- CardsID中是否包含CardID
        for i=0, CardsID:Num()-1 do
            if CardsID:Get(i) == CardID then
                self:AddToRelativeStories(RelativeStories, value.Story.Name)
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
        RelativeCardNameString = RelativeCardNameString .. '[' .. RelativeCardNames[i] .. ']' .. " "
    end

    local RelativeStoryString = ""
    for i=1, #RelativeStories do
        RelativeStoryString = RelativeStoryString .. '[' .. RelativeStories[i] .. ']' .. " "
    end

    return RelativeCardNameString, RelativeStoryString
end

function UI_CardDetail:AddToRelativeStories(RelativeStories, Story)
    local bExist = false
    for i=1, #RelativeStories do
        if RelativeStories[i] == Story then
            bExist = true
            break
        end
    end
    if not bExist then
        table.insert(RelativeStories, Story)
    end
end

function UI_CardDetail:UpdateSkillInfo()
    for i=0, self.SkillsID:Num()-1 do
        local SkillInfo = DataManager.GetSkillData(self.SkillsID:Get(i))
        if i==0 then
            self.Text_SkillOne:SetText("技能一：" .. SkillInfo.SkillDesc)
        elseif i==1 then
            self.Text_SkillTwo:SetText("技能二：" .. SkillInfo.SkillDesc)
        end
    end
    if self.SkillsID:Num()==0 then
        self.Text_SkillOne:SetVisibility(ESlateVisibility.Hidden)
        self.Text_SkillTwo:SetVisibility(ESlateVisibility.Hidden)
    elseif self.SkillsID:Num()==1 then
        self.Text_SkillOne:SetVisibility(ESlateVisibility.SelfHitTestInvisible)
        self.Text_SkillTwo:SetVisibility(ESlateVisibility.Hidden)
    else
        self.Text_SkillTwo:SetVisibility(ESlateVisibility.SelfHitTestInvisible)
    end
end

function UI_CardDetail:OnDestroy()

end

return Class(nil, nil, UI_CardDetail)