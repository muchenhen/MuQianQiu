require "Global"

local UI_CardDetail = {}

function UI_CardDetail:Initialize()
    self:PlayAnimation(self.ShowIn, 0, 1, 0, 1, false)
end

function UI_CardDetail:Construct()
end

function UI_CardDetail:UpdateSelf(ID)
    self.UI_Card:UpdateSelf(ID)
    self.Text_Score:SetText("基础分值：" .. Table.Cards[ID].Value)
    self.Text_CardDetail:SetText(Table.Cards[ID].Describe)
    if Table.Cards[ID].Special == 1 then
        local effectFirst = Table.Cards[ID].EffectFirst
        if effectFirst~= '' then
            local effectFirstID = tonumber(effectFirst)
            local effectFirstParam = Table.Cards[ID].ParamFirst
            local firstEffectDetail = FormatEffectDetail[effectFirstID](effectFirstParam)
            self.Text_EffectOneDetail:SetText(firstEffectDetail)
        end
        local effectSecond = Table.Cards[ID].EffectSecond
        if effectSecond~= '' then
            local effectSecondID = tonumber(effectSecond)
            local effectSecondParam = Table.Cards[ID].ParamSecond
            local secondEffectDetail = FormatEffectDetail[effectSecondID](effectSecondParam)
            self.Text_EffectSecondDetail:SetText(secondEffectDetail)
        end
    else
        self.Text_EffectOne:SetVisibility(ESlateVisibility.Collapsed)
        self.Text_EffectOneDetail:SetVisibility(ESlateVisibility.Collapsed)
        self.Text_EffectSecond:SetVisibility(ESlateVisibility.Collapsed)
        self.Text_EffectSecondDetail:SetVisibility(ESlateVisibility.Collapsed)
    end
    self.Text_CanStory:SetText(FindStory(ID))
end

function UI_CardDetail:PlayShowIn()
    self:PlayAnimation(self.ShowIn, 0, 1, 0, 1, false)
end

function UI_CardDetail:PlayShowOut()
    self:PlayAnimation(self.ShowOut, 0, 1, 0, 1, false)
end

function UI_CardDetail:OnAnimationFinished(anim)
    if anim == self.ShowOut then
        self:RemoveFromViewport()
    end
end

function UI_CardDetail:OnDestroy()

end

return UI_CardDetail