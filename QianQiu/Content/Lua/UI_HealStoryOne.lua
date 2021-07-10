require "Global"

local UI_HealStoryOne = {}

function UI_HealStoryOne:Initialize()
end

function UI_HealStoryOne:OnListItemObjectSet(param)
    for i = 1, 8 do
        self["UI_Card_" .. i]:SetVisibility(ESlateVisibility.Collapsed)
    end
    local story = param.story
    self.Text_StoryName:SetText(story.Name)
    local names = ""
    for key, cardID in pairs(story.Cards) do
        self["UI_Card_" .. key]:SetVisibility(ESlateVisibility.HitTestInvisible)
        self["UI_Card_" .. key]:SetRenderTranslation(self.CardTrans * key)
        self["UI_Card_" .. key]:UpdateSelf(cardID)
        local bHave = true
        if param.bPlayerHeal then
            bHave = CheckIsHaveThisCardInHeal(param.bPlayerHeal, cardID)
        end
        local richTextStyle = "<Red>"
        if bHave then
            self["UI_Card_" .. key]:SetColorAndOpacity(self["UI_Card_" .. key].CardWhite)
            richTextStyle = "<White>"
        else
            self["UI_Card_" .. key]:SetColorAndOpacity(self["UI_Card_" .. key].CardGray)
        end
        local addName = ""
        if key ~= #story.Cards then
            addName = Table.Cards[cardID].Name .. "、"
        else
            addName = Table.Cards[cardID].Name
        end
        names = names .. richTextStyle .. addName .. "</>"
    end
    self.Text_Names:SetText(names)
    self.Text_StoryScore:SetText(story.Score .. "分")
end

function UI_HealStoryOne:OnDestroy()
end

return UI_HealStoryOne
