require "Global"

local UI_FinishedStory = {}

function UI_FinishedStory:Initialize()
end

function UI_FinishedStory:UpdateFinishedStory(bPlayerHeal)
    self.ListView_Finished:ClearListItems()
    if bPlayerHeal then
        if next(PlayerFinishStories) then
            for index, story in pairs(PlayerFinishStories) do
                local oneStory = CreateUI("CardHeal/UI_HealStoryOne")
                oneStory.story = story
                self.ListView_Finished:AddItem(oneStory)
            end
        end
    else
        if next(EnemyFinishStories) then
            for index, story in pairs(EnemyFinishStories) do
                local oneStory = CreateUI("CardHeal/UI_HealStoryOne")
                oneStory.story = story
                self.ListView_Finished:AddItem(oneStory)
            end
        end
    end
end

function UI_FinishedStory:UpdateCanFinishStory(bPlayerHeal)
    self.ListView_Finished:ClearListItems()
    if bPlayerHeal then
        if next(PlayerFinishStories) then
            for index, story in pairs(PlayerFinishStories) do
                local oneStory = CreateUI("CardHeal/UI_HealStoryOne")
                oneStory.story = story
                self.ListView_Finished:AddItem(oneStory)
            end
        end
    else
        if next(EnemyFinishStories) then
            for index, story in pairs(EnemyFinishStories) do
                local oneStory = CreateUI("CardHeal/UI_HealStoryOne")
                oneStory.story = story
                self.ListView_Finished:AddItem(oneStory)
            end
        end
    end
end

function UI_FinishedStory:OnDestroy()
end

return UI_FinishedStory
