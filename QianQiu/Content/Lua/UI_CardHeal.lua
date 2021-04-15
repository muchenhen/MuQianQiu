require "Global"

local UI_CardHeal = {}

function UI_CardHeal:Construct()
    CommandMap:AddCommand("UpdatePlayerHeal", self, self.UpdatePlayerHeal)
end

function UI_CardHeal:Initialize()
    self.cards = {}
    self.Cards:ClearChildren()
end

function UI_CardHeal:UpdatePlayerHeal(param)
    local haveCardID = param.PlayerHaveID
    local chooseCardID = param.PlayerChooseID
    table.insert(self.cards, haveCardID)
    table.insert(self.cards, chooseCardID)
    local card = CreateUI("UI_Card")
    local param = {
        ID = haveCardID,
        cardPosition = ECardPostion.OnStory,
        cardOwner = ECardOwner.Player,
        state = ECardState.UnChoose,
    }
    card:UpdateSelf(param)
    self.Cards:AddChildToGrid(card, 0, 0)
    card.Slot:SetHorizontalAlignment(self.HorAli)
    card.Slot:SetVerticalAlignment(self.VerAli)
    card = nil
    card = CreateUI("UI_Card")
    param = {
        ID = chooseCardID,
        cardPosition = ECardPostion.OnStory,
        cardOwner = ECardOwner.Player,
        state = ECardState.UnChoose,
    }
    card:UpdateSelf(param)
    self.Cards:AddChildToGrid(card, 0, 0)
    card.Slot:SetHorizontalAlignment(self.HorAli)
    card.Slot:SetVerticalAlignment(self.VerAli)
    local totalAngle = 75
    local cardsNum = self.Cards:GetChildrenCount()
    local singleAngle = totalAngle/cardsNum
    for i=0, cardsNum-1 do
        card = self.Cards:GetChildAt(i)
        card.Slot:SetLayer(i)
        card:SetRenderTransformAngle(i * -singleAngle)
    end
    self:FindAllStory()
end

-- 遍历当前牌堆的所有牌 找到所有组合 对每个组合播放动画，更新分数
function UI_CardHeal:FindAllStory()
    print("检查是否有故事组合……")
    for i=1,#Table.Story do
        if Table.Story[i].bHold == nil or not Table.Story[i].bHold then
            local IDs = Table.Story[i].Cards
            local checkNum = #IDs
            local checkNumber = 0
            for j=1, #IDs do
                -- checkNumber = 0
                for k=1, #self.cards do
                    if IDs[j] == self.cards[k] then
                        checkNumber = checkNumber + 1
                        -- break
                    end
                end
                if checkNum == checkNumber then
                    break
                end
            end
            -- print("checkNum", checkNum, "checkNumber", checkNumber)
            if checkNum == checkNumber then
                Table.Story[i].bHold = true
                AddNeedStoryShowList(Table.Story[i])

                -- OpenUI("UI_StoryShow")
            end
        end
    end
    DoPlayerStoryShowAndUpdateScore()
end

return UI_CardHeal