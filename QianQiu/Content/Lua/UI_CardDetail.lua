require "Global"

local UI_CardDetail = {}

function UI_CardDetail:Initialize()

end

function UI_CardDetail:Construct()
    CommandMap:AddCommand("CardDetailPlayShowIn", self, self.PlayShowIn)
    CommandMap:AddCommand("CardDetailPlayShowOut", self, self.PlayShowOut)
end

function UI_CardDetail:UpdateSelf(param)
    local formatEffectDetail = {
        [ESpecialType.CardUp] = function(effectID, param)
            local params = Split(param,';')
            local EffectDetail = ESpecialDetail[effectID]
            EffectDetail = string.gsub(EffectDetail,"{$Card}", params[1])
            EffectDetail = string.gsub(EffectDetail,"{$Point}", params[2])
            return EffectDetail
        end,
        [ESpecialType.SeeCards] = function(param)
            local EffectDetail = ESpecialDetail[ESpecialType.SeeCards]
            EffectDetail = string.gsub(EffectDetail,"{$Num}", param)
            return EffectDetail
        end
    }
    self.UI_Card:UpdateSelf(param)
    self.Text_Score:SetText("基础分值：" .. param.score)
    self.Text_CardDetail:SetText(Table.Cards[param.id].Describe)
    -- if param.bSpecial then
        local effectFirst = Table.Cards[param.id].EffectFirst
        if effectFirst~= '' then
            local effectFirstID = tonumber(effectFirst)
            local effectFirstParam = Table.Cards[param.id].ParamFirst
            local firstEffectDetail = formatEffectDetail[effectFirstID](effectFirstParam)
            self.Text_EffectOneDetail:SetText(firstEffectDetail)
            print(firstEffectDetail)
        end
        
        local effectSecond = Table.Cards[param.id].EffectSecond
        print(effectSecond)
    -- end
end

function UI_CardDetail:PlayShowIn(param)
    self:PlayAnimation(self.ShowIn, 0, 1, 0, 1, false)
    self:UpdateSelf(param)
    print("DetailShowIn")
end

function UI_CardDetail:PlayShowOut()
    self:PlayAnimation(self.ShowOut, 0, 1, 0, 1, false)
    print("DetailShowOut")
end

return UI_CardDetail