require "Global"

local UI_CardDetail = {}

function UI_CardDetail:Initialize()

end

function UI_CardDetail:Construct()
    CommandMap:AddCommand("CardDetailPlayShowIn", self, self.PlayShowIn)
    CommandMap:AddCommand("CardDetailPlayShowOut", self, self.PlayShowOut)
end

function UI_CardDetail:UpdateSelf(param)
    self.UI_Card:UpdateSelf(param)
    self.Text_Score:SetText("基础分值：" .. param.score)
    self.Text_CardDetail:SetText(Table.Cards[param.ID].Describe)
    if param.bSpecial then
        local effectFirst = Table.Cards[param.ID].EffectFirst
        if effectFirst~= '' then
            local effectFirstID = tonumber(effectFirst)
            local effectFirstParam = Table.Cards[param.ID].ParamFirst
            local firstEffectDetail = FormatEffectDetail[effectFirstID](effectFirstParam)
            self.Text_EffectOneDetail:SetText(firstEffectDetail)
        end
        local effectSecond = Table.Cards[param.ID].EffectSecond
        if effectSecond~= '' then
            local effectSecondID = tonumber(effectSecond)
            local effectSecondParam = Table.Cards[param.ID].ParamSecond
            local secondEffectDetail = FormatEffectDetail[effectSecondID](effectSecondParam)
            self.Text_EffectSecondDetail:SetText(secondEffectDetail)
        end
    else
        self.Text_EffectOne:SetVisibility(ESlateVisibility.Collapsed)
        self.Text_EffectOneDetail:SetVisibility(ESlateVisibility.Collapsed)
        self.Text_EffectSecond:SetVisibility(ESlateVisibility.Collapsed)
        self.Text_EffectSecondDetail:SetVisibility(ESlateVisibility.Collapsed)
    end
    self.Text_CanStory:SetText(FindStory(param.ID))
end

function UI_CardDetail:PlayShowIn(param)
    self:PlayAnimation(self.ShowIn, 0, 1, 0, 1, false)
    self:UpdateSelf(param)
end

function UI_CardDetail:PlayShowOut()
    self:PlayAnimation(self.ShowOut, 0, 1, 0, 1, false)
end

return UI_CardDetail