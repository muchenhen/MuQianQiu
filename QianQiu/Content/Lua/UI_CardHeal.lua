require "Global"

local UI_CardHeal = {}

function UI_CardHeal:Construct()
    self.Button_HealDetail.OnClicked:Add(self.OnHealDetailClick)
    if self.bPlayerHeal then
        CommandMap:AddCommand("UpdatePlayerHeal", self, self.UpdateHeal)
    else
        CommandMap:AddCommand("UpdateEnemyHeal", self, self.UpdateHeal)
    end
    CommandMap:AddCommand("SetTick", self, self.SetTick)
    self.bHasScriptImplementedTick = true
    self.bTick = true
end

function UI_CardHeal:Tick()
    if self.bTick then
        self.bTick = false
        DoPlayerStoryShowAndUpdateScore()
    end
end

function UI_CardHeal:Initialize()
    self.cards = {}
    self.Cards:ClearChildren()
end

function UI_CardHeal:SetTick(bTick)
    self.bTick = bTick
end

function UI_CardHeal:UpdateHeal(param)
    local haveCardID
    local chooseCardID
    if self.bPlayerHeal then
        haveCardID = param.PlayerHaveID
        chooseCardID = param.PlayerChooseID
    else
        haveCardID = param.EnemyHaveCard
        chooseCardID = param.EnemyChooseID
    end
    table.insert(self.cards, haveCardID)
    table.insert(self.cards, chooseCardID)
    local card = CreateUI("UI_Card")
    local param = {
        ID = haveCardID,
        cardPosition = ECardPostion.Heal,
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
        cardPosition = ECardPostion.Heal,
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
        if Table.Story[i].bHold == nil or (not Table.Story[i].bHold) then
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
            if checkNum == checkNumber then
                Table.Story[i].bHold = true
                AddNeedStoryShowList(Table.Story[i])
            end
        end
    end
    if not next(NeedShowStorys) then
        -- CommandMap:DoCommand(CommandList.ShowRound)
    end
end

function UI_CardHeal:OnHealDetailClick()
    local self = UI_CardHeal
    UIStack:PopUIByName("UI_CardDetail", true)
    UIStack:PushUIByName("UI_HealDetail", self.cards)
end

return UI_CardHeal