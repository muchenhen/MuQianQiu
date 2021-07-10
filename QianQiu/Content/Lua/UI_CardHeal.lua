require "Global"

local UI_CardHeal = {}

function UI_CardHeal:Initialize()
    self.cards = {}
    self.Cards:ClearChildren()

    self.Button_HealDetail.OnClicked:Add(self.OnHealDetailClick)
    if self.bPlayerHeal then
        CommandMap:AddCommand("UpdatePlayerHeal", self, self.UpdateHeal)
        CommandMap:AddCommand("SetStoryShowTickPlayer", self, self.SetStoryShowTick)
    else
        CommandMap:AddCommand("UpdateEnemyHeal", self, self.UpdateHeal)
        CommandMap:AddCommand("SetStoryShowTickEnemy", self, self.SetStoryShowTick)
    end
    self.bHasScriptImplementedTick = true
    self.bTick = false

end

function UI_CardHeal:Tick()
    if self.bTick then
        self.bTick = false
        self:DoStoryShowAndUpdateScore()
    end
end

function UI_CardHeal:SetStoryShowTick(bTick)
    self.bTick = bTick
end

function UI_CardHeal:UpdateHeal(param)
    local haveCardID
    local chooseCardID
    if self.bPlayerHeal then
        haveCardID = param.PlayerHaveID
        chooseCardID = param.PlayerChooseID
        CommandMap:DoCommand(CommandList.UpdatePlayerScore, param)
    else
        haveCardID = param.EnemyHaveCard
        chooseCardID = param.EnemyChooseID
    end
    table.insert(self.cards, haveCardID)
    table.insert(self.cards, chooseCardID)
    if self.bPlayerHeal then
        PlayerHealCards = self.cards
    else
        EnemyHealCards = self.cards
    end
    local card = CreateUI("Card/UI_Card")
    card:UpdateSelf(haveCardID)
    self.Cards:AddChildToGrid(card, 0, 0)
    card.Slot:SetHorizontalAlignment(self.HorAli)
    card.Slot:SetVerticalAlignment(self.VerAli)
    card = nil
    card = CreateUI("Card/UI_Card")
    card:UpdateSelf(chooseCardID)
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
    --print("检查是否有故事组合……")
    -- 将所有需要播放的故事添加到了一个全局缓冲表
    for i=1,#Table.AllStory do
        if Table.AllStory[i].bHold == nil or (not Table.AllStory[i].bHold) then
            local IDs = Table.AllStory[i].Cards
            local checkNum = #IDs
            local checkNumber = 0
            for j=1, #IDs do
                for k=1, #self.cards do
                    if IDs[j] == self.cards[k] then
                        checkNumber = checkNumber + 1
                    end
                end
                if checkNum == checkNumber then
                    break
                end
            end
            if checkNum == checkNumber then
                Table.AllStory[i].bHold = true
                self:AddNeedStoryShowList(Table.AllStory[i])
            end
        end
    end
    -- 在添加完所有需要的故事之后打开tick进行播放
    self.bTick = true
end

function UI_CardHeal:OnHealDetailClick()
    local self = UI_CardHeal
    UIStack:PopUIByName("UI_CardDetail")
    local param = {
        cards = self.cards,
        bPlayerHeal = self.bPlayerHeal
    }
    UIStack:PushUIByName("UI_HealDetail", param)
end

function UI_CardHeal:AddNeedStoryShowList(story)
    NeedShowStorys[#NeedShowStorys+1] = story
end

function UI_CardHeal:DoStoryShowAndUpdateScore()
    local self = UI_CardHeal
    if next(NeedShowStorys) then
        local story = NeedShowStorys[1]
        -- --print("bPlayer", self.bPlayerHeal)
        if self.bPlayerHeal then
            --print("我方完成一个组合：", story.Name, " 组合分数：", story.Score)
            PlayerFinishStories[#PlayerFinishStories+1] = story
            CommandMap:DoCommand(CommandList.UpdatePlayerScore, {Score = story.Score})
        else
            --print("对方完成一个组合：", story.Name, " 组合分数：", story.Score)
            EnemyFinishStories[#EnemyFinishStories+1] = story
            CommandMap:DoCommand(CommandList.UpdateEnemyScore, {Score = story.Score})
        end
        UIStack:PushUIByName("UI_StoryShow", story)
        table.remove(NeedShowStorys, 1)
    else
        NeedShowStorys = {}
        self.bTick = false
        CommandMap:DoCommand(CommandList.ShowRound)
    end
end

function UI_CardHeal:Reset()
    self.cards = {}
    self.Cards:ClearChildren()
end

return UI_CardHeal