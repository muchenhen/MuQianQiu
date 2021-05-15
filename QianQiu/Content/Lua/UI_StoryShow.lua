require "Global"
local UI_StoryShow = {}

function UI_StoryShow:Construct()

end

function UI_StoryShow:Initialize()
    CommandMap:DoCommand(CommandList.SetStoryShowTick, false)
    self:PlayAnimation(self.ShowIn, 0, 1, 0, 1, false)
    
end

function UI_StoryShow:OnAnimationFinished(anim)
    -- if anim == self.ShowIn then
    --     self:PlayAnimation(self.ShowOut, 0, 1, 0, 1, false)
    -- else
    if anim == self.ShowOut then
        self:RemoveFromParent()
        CommandMap:DoCommand(CommandList.SetStoryShowTick, true)
    end
end

function UI_StoryShow:UpdateSelf(param)
    if not param then
        return
    end
    self.Text_StoryName:SetText(param.Name)
    self.Text_Score:SetText(param.Score)
    self.Cards:ClearChildren()
    local cardsID = param.Cards
    for i=1, #cardsID do
        local card = CreateUI("UI_Card")
        local param = {
            ID = cardsID[i],
            cardPosition = ECardPostion.OnStory,
            cardOwner = ECardOwner.Player,
            state = ECardState.UnChoose,
        }
        self.Cards:AddChild(card)
        card:UpdateSelf(param)
        card:SetPadding(self.CardPadding)
    end
end

function UI_StoryShow:OnDestroy()

end

return UI_StoryShow