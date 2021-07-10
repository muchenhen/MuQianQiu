require "Global"

local UI_CanFinishStory = {}

function UI_CanFinishStory:Initialize()

end

function UI_CanFinishStory:UpdateCanFinishCards(bPlayerHeal, cards)
    -- 对所有没有解锁的故事进行遍历
    for i=1,#Table.AllStory do
        if Table.AllStory[i].bHold == nil or (not Table.AllStory[i].bHold) then
            local IDs = Table.AllStory[i].Cards
            local checkNumber = 0
            for j=1, #IDs do
                for k=1, #cards do
                    -- 对某个故事所需要的所有卡的ID进行遍历 与自己持有的卡进行对比
                    if IDs[j] == cards[k] then
                        local oneStory = CreateUI("CardHeal/UI_HealStoryOne")
                        oneStory.story = Table.AllStory[i]
                        oneStory.bPlayerHeal = bPlayerHeal
                        self.ListView_Canfinish:AddItem(oneStory)
                        break
                    end
                end
            end
        end
    end
end

function UI_CanFinishStory:OnDestroy()

end

return UI_CanFinishStory